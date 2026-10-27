-- Failure-injection tests: these never contact real Roblox accounts/DataStores.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local ProfileStore = require("../src/data/ProfileStore")
local groups, checks = 0, 0
local function check(ok, message) checks += 1; assert(ok, message) end
local function clone(value)
	if type(value) ~= "table" then return value end
	local result = {}
	for key, item in value do result[key] = clone(item) end
	return result
end
local function test(name, body) body(); groups += 1; print("PASS", name) end
local function fake()
	local store = {Values = {}, Calls = 0, FailBefore = 0, FailAfter = 0, Writes = 0}
	function store:UpdateAsync(key, transform)
		self.Calls += 1
		if self.FailBefore > 0 then self.FailBefore -= 1; error("Injected unavailable") end
		if self.BeforeCallback then self.BeforeCallback(self, key) end
		local result = transform(clone(self.Values[key]))
		-- Roblox can call a transform again when its first proposal loses a race.
		-- An intermediate proposal is not committed and must have no side effects.
		if self.RetryTransform then
			self.RetryTransform(self, key, clone(result))
			result = transform(clone(self.Values[key]))
		end
		if result ~= nil then self.Values[key] = clone(result); self.Writes += 1 end
		if self.FailAfter > 0 then self.FailAfter -= 1; error("Injected response lost after commit") end
		return clone(result)
	end
	return store
end
local clock = 1000
local function validate(data)
	if data.DataVersion and data.DataVersion > 2 then return nil, "FutureData" end
	if type(data.Coins) ~= "number" or data.Coins < 0 or data.Coins % 1 ~= 0 then return nil, "InvalidData" end
	data.DataVersion = 2
	return data
end
local function instance(store, token, fields)
	local options = {Store = store, Token = token, Now = function() return clock end,
		Sleep = function() end, LeaseSeconds = 30, MaxAttempts = 3, Validate = validate}
	for key, value in fields or {} do options[key] = value end
	return ProfileStore.new(options)
end
local function load(service, coins)
	local ok, status, data = service:Load("player:1", {DataVersion = 2, Coins = coins or 80})
	check(ok, "Load failed: " .. status)
	return data, status
end

test("Repository compiles and creates starter data once, returning detached copies", function()
	luau.compile(fs.readFile("src/data/ProfileStore.luau"))
	local ds = fake()
	local a = instance(ds, "server-a")
	local data, status = load(a)
	check(status == "Created" and data.Coins == 80, "New profile initialized")
	data.Coins = 12
	check(ds.Values["player:1"].Data.Coins == 80, "Caller does not mutate DS cache")
	check(a:Save("player:1", data, true), "Save/release")
	local b = instance(ds, "server-b")
	local restored, existing = load(b, 999)
	check(existing == "Loaded" and restored.Coins == 12, "Default never resets existing profile")
	check(ds.Values["player:1"].Revision == 1, "Saved revision")
end)

test("Live lease blocks a second server and expired owners cannot overwrite", function()
	clock = 2000
	local ds = fake()
	local a, b = instance(ds, "a"), instance(ds, "b")
	load(a)
	local ok, status = b:Load("player:1", {Coins = 999})
	check(not ok and status == "Locked", "Second server locked")
	check(ds.Values["player:1"].Data.Coins == 80, "Locked load never changes data")
	clock += 31
	load(b)
	local saved, why = a:Save("player:1", {Coins = 999})
	check(not saved and why == "SessionLost", "Expired owner denied")
	check(b:Save("player:1", {Coins = 77}), "New owner may save")
	check(ds.Values["player:1"].Data.Coins == 77, "Only new owner changed account")
end)

test("Bounded exponential retries recover outages without overwriting on failed load", function()
	clock = 3000
	local ds, delays = fake(), {}
	local a = instance(ds, "a", {MaxAttempts = 4, BaseDelay = 0.25, MaxDelay = 0.75,
		Sleep = function(seconds) table.insert(delays, seconds) end})
	ds.FailBefore = 4
	local ok, status = a:Load("player:1", {Coins = 80})
	check(not ok and status == "LoadFailed" and ds.Values["player:1"] == nil, "Unavailable load has no starter save")
	local saved, why = a:Save("player:1", {Coins = 80}, true)
	check(not saved and why == "NotLoaded" and ds.Calls == 4, "Saving after failed load never touches DS")
	check(#delays == 3 and delays[1] == 0.25 and delays[2] == 0.5 and delays[3] == 0.75, "Capped backoff")
	load(a)
	ds.FailBefore = 2
	check(a:Save("player:1", {Coins = 41}), "Retry save recovers")
	check(ds.Values["player:1"].Revision == 1 and ds.Values["player:1"].Data.Coins == 41, "One committed revision")
end)

test("Lost responses use the same commit receipt without duplicate revisions", function()
	local ds = fake()
	local a = instance(ds, "a")
	load(a)
	ds.FailAfter = 2
	check(a:Save("player:1", {Coins = 45}), "Unknown commit resolves")
	check(ds.Values["player:1"].Revision == 1, "Retries never apply commit twice")
	check(#ds.Values["player:1"].RecentCommits == 1, "One receipt")
	ds.FailAfter = 3
	local ok, status = a:Save("player:1", {Coins = 46})
	check(not ok and status == "SaveFailed", "Exhausted uncertain result remains pending")
	check(ds.Values["player:1"].Revision == 2, "Unknown operation actually committed once")
	check(a:Save("player:1", {Coins = 47}), "Resolve old commit then save newer generation")
	check(ds.Values["player:1"].Revision == 3 and ds.Values["player:1"].Data.Coins == 47, "Newer snapshot preserved")
end)

test("Release remains idempotent after a lost response and a successor save", function()
	local ds = fake()
	local a, b = instance(ds, "a"), instance(ds, "b")
	load(a)
	ds.FailAfter = 3
	local ok, status = a:Save("player:1", {Coins = 32}, true)
	check(not ok and status == "SaveFailed" and ds.Values["player:1"].Session == nil, "Release applied, response unknown")
	load(b)
	check(b:Save("player:1", {Coins = 33}), "Successor modifies profile")
	local revision = ds.Values["player:1"].Revision
	local released, why = a:Save("player:1", {Coins = 32}, true)
	check(released and why == "Released", "Old release acknowledged from history")
	check(ds.Values["player:1"].Data.Coins == 33 and ds.Values["player:1"].Session.Token == "b", "Late release cannot erase successor data/lock")
	check(ds.Values["player:1"].Revision == revision, "Late retry cannot increment revision")
	check(a:Save("player:1", {Coins = 32}, true), "Repeated release is safe")
end)

test("Lease renews without changing revision, but expires without unsafe force takeover", function()
	clock = 4000
	local ds = fake()
	local a = instance(ds, "a")
	load(a)
	clock += 20
	check(a:Renew("player:1"), "Renew live lease")
	check(ds.Values["player:1"].Session.ExpiresAt == 4050 and ds.Values["player:1"].Revision == 0, "Renew does not create data revision")
	clock = 4050
	local ok, status = a:Renew("player:1")
	check(not ok and status == "SessionLost", "Expiry boundary rejects old session")
	check(not a:Save("player:1", {Coins = 999}), "Save cannot reacquire expired session")
	check(ds.Values["player:1"].Data.Coins == 80, "Stale data never overwrites")
end)

test("Invalid/future profiles and malformed envelopes never fall back to defaults", function()
	for _, fixture in {
		{Value = {FormatVersion = 2, Revision = 0, Data = {Coins = 5}}, Status = "FutureFormat"},
		{Value = {FormatVersion = 1, Revision = 0, Data = {DataVersion = 99, Coins = 5}}, Status = "FutureData"},
		{Value = {FormatVersion = 1, Revision = 0, Data = {Coins = -1}}, Status = "InvalidData"},
		{Value = {Coins = 42}, Status = "InvalidEnvelope"},
		{Value = {FormatVersion = 1, Revision = 0, Data = {Coins = 5}, Session = {Token = "x", ExpiresAt = "yesterday"}}, Status = "InvalidEnvelope"},
	} do
		local ds = fake()
		ds.Values["player:1"] = clone(fixture.Value)
		local a = instance(ds, "a")
		local ok, status = a:Load("player:1", {Coins = 999})
		check(not ok and status == fixture.Status, "Reject " .. fixture.Status .. ": " .. status)
		check(ds.Writes == 0, "Rejected profile has zero writes")
		check(not a:Save("player:1", {Coins = 999}), "Cannot save a rejected profile")
	end
end)

test("Sanitization/migration stays in memory and Encode creates DS-safe string keys", function()
	local ds = fake()
	local options = {
		Validate = function(data)
			local normalized, why = validate(data)
			if not normalized then return nil, why end
			local receipts = {}
			for key, value in normalized.Receipts or {} do receipts[tonumber(key)] = value end
			normalized.Receipts = receipts
			return normalized
		end,
		Encode = function(data)
			local receipts = {}
			for key, value in data.Receipts do receipts[tostring(key)] = value end
			data.Receipts = receipts
			return data
		end,
	}
	local a = instance(ds, "a", options)
	local ok, _, data = a:Load("player:1", {Coins = 10, Receipts = {[19] = "craft:1"}})
	check(ok and data.DataVersion == 2 and data.Receipts[19] == "craft:1", "Normalized numeric in memory")
	check(ds.Values["player:1"].Data.Receipts["19"] == "craft:1", "Encoded string in DS")
	data.Coins = 9
	check(a:Save("player:1", data, true), "Save encoded snapshot")
	local b = instance(ds, "b", options)
	local loaded, _, restored = b:Load("player:1", {Coins = 999})
	check(loaded and restored.Coins == 9 and restored.Receipts[19] == "craft:1", "Encoded data roundtrips through validator")
end)

test("Revision conflicts, unsupported data and concurrent calls are rejected safely", function()
	local ds = fake()
	local a = instance(ds, "a")
	load(a)
	local cycle = {Coins = 50}; cycle.Self = cycle
	local ok, why = a:Save("player:1", cycle)
	check(not ok and why == "InvalidData", "Cycles rejected")
	check(not a:Save("player:1", {Coins = 50, Sparse = {[7] = "unsafe"}}), "Sparse arrays require Encode")
	check(ds.Values["player:1"].Revision == 0, "Malformed data never sent")
	ds.Values["player:1"].Revision = 8
	local saved, status = a:Save("player:1", {Coins = 60})
	check(not saved and status == "RevisionConflict", "Unexpected revision rejects")
	check(ds.Values["player:1"].Data.Coins == 80, "Revision conflict leaves data unchanged")
	local concurrent = instance(fake(), "concurrent")
	load(concurrent)
	local innerStatus
	concurrent._store.BeforeCallback = function()
		local accepted, rejected = concurrent:Save("player:1", {Coins = 12})
		check(not accepted, "Concurrent operation rejected")
		innerStatus = rejected
	end
	check(concurrent:Save("player:1", {Coins = 13}), "Outer save succeeds")
	check(innerStatus == "Busy", "Per-key operations serialized")
end)

test("Receipt history stays bounded across repeated writes", function()
	local ds = fake()
	local a = instance(ds, "bounded")
	load(a)
	for i = 1, 80 do check(a:Save("player:1", {Coins = i}), "Repeated save") end
	check(ds.Values["player:1"].Revision == 80 and #ds.Values["player:1"].RecentCommits == 32, "Bounded receipt retention")
end)

test("UpdateAsync double callbacks create one revision and reject intervening conflicts", function()
	local ds = fake()
	ds.RetryTransform = function() end
	local a = instance(ds, "callback-repeat")
	load(a)
	check(a:Save("player:1", {Coins = 22}), "Repeated callback save")
	check(ds.Values["player:1"].Revision == 1 and #ds.Values["player:1"].RecentCommits == 1,
		"Discarded proposal does not advance state or add receipt")
	check(a:Save("player:1", {Coins = 23}), "Following save still has correct revision")
	local revision = ds.Values["player:1"].Revision
	ds.RetryTransform = function(store, key, proposal)
		check(proposal.Revision == revision + 1, "First callback proposes expected revision")
		store.Values[key].Revision += 1
		store.Values[key].Data.Coins = 99
	end
	local ok, status = a:Save("player:1", {Coins = 24})
	check(not ok and status == "RevisionConflict", "Final callback rejects changed durable revision")
	check(ds.Values["player:1"].Data.Coins == 99 and ds.Values["player:1"].Revision == revision + 1,
		"Stale proposal cannot overwrite intervening durable change")
end)

print(string.format("PASS ProfileStore: %d groups, %d checks", groups, checks))
