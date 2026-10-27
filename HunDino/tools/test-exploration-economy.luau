-- Pure reward/retry tests. No Studio objects, user accounts or DataStore access.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local E = require("../src/hunting/HuntEconomyRules")
local Schema = require("../src/data/ProfileSchema").new(E)
local checks, groups = 0, 0
local function check(value, message) checks += 1; assert(value, message) end
local function clone(value)
	if type(value) ~= "table" then return value end
	local copy = {}; for key, child in value do copy[key] = clone(child) end; return copy
end
local function same(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for key, value in a do if not same(value, b[key]) then return false end end
	for key, value in b do if not same(value, a[key]) then return false end end
	return true
end
local function test(name, body) body(); groups += 1; print("PASS", name) end
local function apply(profile, operation, fields)
	local request = clone(fields or {})
	request.Op = operation
	if operation ~= "OpenRun" then
		request.RunId, request.RunSerial = request.RunId or "explore:1", request.RunSerial or 1
	end
	local receipt = E.apply(profile, request)
	check(receipt.Ok, operation .. " rejected: " .. receipt.Code)
	return receipt, request
end
local function reject(profile, operation, fields, code)
	local before = clone(profile)
	local request = clone(fields or {}); request.Op = operation
	request.RunId, request.RunSerial = request.RunId or "explore:1", request.RunSerial or 1
	local receipt = E.apply(profile, request)
	check(not receipt.Ok and receipt.Code == code, operation .. " must reject " .. code .. ", got " .. receipt.Code)
	check(same(profile, before), "Rejected operation is atomic")
end
local function opened(profile, mode)
	return apply(profile, "OpenRun", {RunId="explore:1", MonsterId="wild:TRex:1", RunSerial=1, Mode=mode})
end
local function defeated(profile)
	opened(profile, "Exploration")
	apply(profile, "StartRun")
	return apply(profile, "Finish", {Result="Defeated", Traps=0, Potions=0})
end
local function stocked()
	local p = E.new()
	p.StoredConsumables.IronTrap, p.StoredConsumables.SleepPotion, p.StoredConsumables.RawTrap = 7, 9, 4
	return p
end

test("Exploration reserves no supplies and grants no mission bonus", function()
	local p = stocked()
	local stored = clone(p.StoredConsumables)
	local receipt = opened(p, "Exploration")
	check(receipt.Mode == "Exploration" and receipt.Traps == 0 and receipt.Potions == 0, "Zero reserve receipt")
	check(p.ActiveRun.Mode == "Exploration" and same(p.StoredConsumables, stored), "Supplies stay in inventory")
	check(p.ActiveRun.InitialTraps == 0 and p.ActiveRun.InitialPotions == 0, "No hidden reserve")
	apply(p, "StartRun")
	local available, reason = E.canCapture(p, "explore:1", 1)
	check(not available and reason == "InvalidMode", "Exploration cannot capture")
	local finish = apply(p, "Finish", {Result="Defeated"})
	check(finish.Mode == "Exploration" and finish.BonusBone == 0 and finish.BonusCoins == 0, "No hunt completion package")
	check(#finish.Rewards == 0 and p.Coins == 80 and p.Materials.Bone == 0, "No automatic materials or coins")
	local close = apply(p, "CloseRun", {Traps=0, Potions=0})
	check(close.Mode == "Exploration" and close.ReturnedTraps == 0 and close.ReturnedPotions == 0, "Zero returned supplies")
	check(same(p.StoredConsumables, stored), "Close never duplicates inventory supplies")
end)

test("Exactly three sequential carves grant materials and replay after closure", function()
	local p = E.new(); defeated(p)
	local requests = {}
	for index, roll in {0.1, 0.6, 0.9} do
		local receipt, request = apply(p, "Carve", {Index=index, TypeRoll=roll})
		requests[index] = request
		check(receipt.Mode == "Exploration" and receipt.Quantity == 1, "Carve receipt identifies exploration")
		local before = clone(p)
		local replayed = E.apply(p, request)
		check(replayed.Ok and replayed.Replay and same(p, before), "Duplicate carve does not reroll or grant")
	end
	check(p.Materials.Skin == 1 and p.Materials.Tooth == 1 and p.Materials.Scale == 1, "Three deterministic material rolls")
	check(p.ActiveRun.Carves == 3 and p.Coins == 80 and p.Materials.Bone == 0, "Only carve rewards")
	reject(p, "Carve", {Index=4, TypeRoll=0}, "InvalidIndex")
	apply(p, "CloseRun", {Traps=0, Potions=0})
	local before = clone(p)
	for _, request in requests do check(E.apply(p, request).Replay, "Closed carve receipt retained") end
	check(same(p, before), "Closed retries cannot grant another three materials")
	local openReplay = opened(p, "Exploration")
	check(openReplay.Replay and p.ActiveRun == nil and p.RunSerial == 1, "Closed run cannot reopen")
end)

test("Capacity rejection keeps the carve available for a stable retry", function()
	local p = E.new(); defeated(p)
	p.Materials.Skin = E.Config.MaximumCount
	reject(p, "Carve", {Index=1, TypeRoll=0.1}, "Capacity")
	check(p.ActiveRun.Carves == 0 and p.ActiveRun.Claims["Carve:1"] == nil, "Full inventory consumes no carve claim")
	p.Materials.Skin -= 1
	apply(p, "Carve", {Index=1, TypeRoll=0.1})
	check(p.Materials.Skin == E.Config.MaximumCount and p.ActiveRun.Carves == 1, "Same carve can commit after space clears")
	local finishReplay = apply(p, "Finish", {Result="Defeated"})
	check(finishReplay.Replay and p.Coins == 80 and p.Materials.Bone == 0, "Finishing again has no bonus")
end)

test("Exploration rejects capture, ore, drops and forged remaining supplies", function()
	local p = E.new(); opened(p, "Exploration"); apply(p, "StartRun")
	reject(p, "Finish", {Result="Captured", Traps=0, Potions=0}, "InvalidOutcome")
	reject(p, "Ore", {Index=1}, "InvalidMode")
	reject(p, "Drop", {}, "InvalidMode")
	reject(p, "SyncItems", {Traps=1, Potions=0}, "InvalidRemaining")
	reject(p, "Finish", {Result="Defeated", Traps=0, Potions=1}, "InvalidRemaining")
	reject(p, "Carve", {Index=1, TypeRoll=0}, "InvalidState")
	apply(p, "Finish", {Result="Failed"})
	reject(p, "Carve", {Index=1, TypeRoll=0}, "InvalidState")
	check(p.Coins == 80 and next(p.OwnedSpecimens) == nil, "Failed exploration receives no rewards or specimen")
	apply(p, "CloseRun", {Traps=0, Potions=0})
end)

test("Mode validation rejects corrupted data while legacy hunts retain bonuses", function()
	for _, mode in {false, 1, "Mission", "exploration", {}, ""} do
		local p = E.new()
		reject(p, "OpenRun", {MonsterId="wild:TRex:1", Mode=mode}, "InvalidMode")
	end
	local p = E.new(); opened(p, "Exploration")
	reject(p, "OpenRun", {MonsterId="wild:TRex:1"}, "InvalidMode")
	local corrupt = clone(p); corrupt.ActiveRun.Mode = "Other"
	check(E.new(corrupt) == nil, "Unknown persisted mode rejected")
	corrupt = clone(p); corrupt.ActiveRun.Claims.OpenRun.Mode = nil
	check(E.new(corrupt) == nil, "Receipt mode cannot disagree with active run")
	corrupt = clone(p); corrupt.ActiveRun.Traps = 1; corrupt.ActiveRun.InitialTraps = 1
	check(E.new(corrupt) == nil, "Exploration cannot persist reserved supplies")
	apply(p, "CloseRun", {EntryFailed=true})
	reject(p, "OpenRun", {MonsterId="wild:TRex:1"}, "InvalidMode")
	check(E.new(p) ~= nil and p.ClosedRuns[1].Mode == "Exploration", "Closed mode survives profile validation")
	local mission = E.new(); opened(mission); apply(mission, "StartRun")
	local finish = apply(mission, "Finish", {Result="Defeated"})
	check(finish.Mode == nil and finish.BonusCoins == 40 and mission.Materials.Bone == 1, "Legacy nil mode keeps mission rewards")
end)

test("Profile JSON and recovery preserve exploration loot without hunt failures", function()
	for _, state in {"Preparing", "Hunting", "Defeated", "Failed"} do
		local data = Schema.Default(1792400000)
		data.Economy.StoredConsumables.IronTrap, data.Economy.StoredConsumables.SleepPotion = 3, 2
		local stored = clone(data.Economy.StoredConsumables)
		opened(data.Economy, "Exploration")
		if state ~= "Preparing" then apply(data.Economy, "StartRun") end
		if state == "Defeated" or state == "Failed" then apply(data.Economy, "Finish", {Result=state}) end
		if state == "Defeated" then apply(data.Economy, "Carve", {Index=1, TypeRoll=0.6}) end
		local encoded = assert(Schema.Encode(data))
		local decoded = assert(Schema.Decode(serde.decode("json", serde.encode("json", encoded))))
		check(decoded.Economy.ActiveRun.Mode == "Exploration", "Mode survives durable serialization")
		local recovered = assert(Schema.Recover(decoded))
		check(recovered.Economy.ActiveRun == nil and recovered.Economy.ClosedRuns[1].Mode == "Exploration", "Recovery closes exploration ledger")
		check(recovered.Statistics.HuntsCompleted == 0 and recovered.Statistics.HuntsFailed == 0 and recovered.Statistics.Captures == 0, "Exploration recovery does not count as mission")
		check(same(recovered.Economy.StoredConsumables, stored) and recovered.Economy.Coins == 80, "Recovery neither loses supplies nor grants bonus")
		check(recovered.Economy.Materials.Tooth == (if state == "Defeated" then 1 else 0), "Committed carve survives recovery")
	end
end)

local Service = luau.load(fs.readFile("src/hunting/HuntEconomyService.luau"), {
	environment={game={GetService=function() return {} end},
		script={Parent={HuntEconomyRules="Economy",SpecimenPreviewModel="Preview",BioTubeService="Bio",AdminRedeemPolicy="Admin"}},
		require=function(module) return if module == "Economy" then E else {} end}, injectGlobals=true,
})()
local function serviceFixture(failCommit)
	local data = Schema.Default(1792400000)
	data.Economy.StoredConsumables.IronTrap, data.Economy.StoredConsumables.SleepPotion = 3, 3
	local persistence = {DataValue=data, Count=0}
	function persistence:Data() return self.DataValue end
	function persistence:CanMutate() return self.Pending == nil end
	function persistence:CommitEconomy(_, mutate)
		local candidate = clone(self.DataValue)
		local receipt = mutate(candidate.Economy, candidate.Statistics)
		if not receipt.Ok or receipt.Replay or receipt.Unchanged then return receipt end
		self.Count += 1
		if self.Count == failCommit then
			self.Pending = candidate
			return {Ok=false, Code="SavePending", Replay=false}
		end
		self.DataValue = candidate
		return receipt
	end
	function persistence:Flush() self.DataValue = assert(self.Pending); self.Pending = nil end
	local object = setmetatable({Persistence=persistence, Requests={}}, Service)
	function object:Publish() end
	function object:_notice() end
	function object:_runRequest(player, run, op, fields)
		table.insert(self.Requests, {Id=run.Id, MonsterId=run.MonsterId, Serial=run.EconomySerial, Op=op})
		return Service._runRequest(self, player, run, op, fields)
	end
	return object, persistence
end

test("PrepareExploration retries each pending save with one stable ledger", function()
	for failAt = 1, 3 do
		local service, persistence = serviceFixture(failAt)
		local player, run = {}, {Id="explore:1", MonsterId="wild:TRex:1"}
		local ok, reason = service:PrepareExploration(player, run)
		check(not ok and reason == "SavePending" and run.EconomySerial == 1, "Pending mutation does not invent another run serial")
		check((run.EconomyStarted == true) == (failAt == 3), "Started flag reflects committed StartRun")
		local before = #service.Requests
		check(not service:PrepareExploration(player, run) and #service.Requests == before, "No mutation while persistence waits")
		persistence:Flush()
		check(service:PrepareExploration(player, run), "Same exploration can resume after pending save succeeds")
		check(run.EconomyStarted and run.Result == "Defeated" and run.Traps == 0 and run.Potions == 0, "Prepared runtime closes through existing Close API")
		local profile = service:Profile(player)
		check(profile.ActiveRun.Mode == "Exploration" and profile.ActiveRun.State == "Defeated" and profile.RunSerial == 1, "One authoritative exploration ledger")
		check(persistence.Count == 3 and profile.Revision == 3 and profile.Coins == 80 and profile.Materials.Bone == 0, "Exactly three committed setup mutations, no rewards")
		local saved = clone(persistence.DataValue)
		check(service:PrepareExploration(player, run) and same(saved, persistence.DataValue), "Repeated preparation is an idempotent replay")
		for _, request in service.Requests do
			check(request.Id == "explore:1" and request.MonsterId == "wild:TRex:1" and request.Serial == 1, "Retries retain all source identities")
		end
		check(service:Close(player, run), "Existing Close closes prepared exploration")
		local stats = persistence.DataValue.Statistics
		check(stats.HuntsCompleted == 0 and stats.HuntsFailed == 0 and stats.Captures == 0, "Service does not pollute mission statistics")
	end
end)

test("Service rejects conflicting run and excludes exploration abandonment from statistics", function()
	local service, persistence = serviceFixture()
	local p = service:Profile({})
	opened(p, "Exploration"); apply(p, "StartRun")
	local run = {Id="different", MonsterId="different:monster"}
	local ok, reason = service:PrepareExploration({}, run)
	check(not ok and reason == "ActiveRun" and run.EconomySerial == nil, "Different active run cannot be silently replaced")
	local recoveredRun = {Id="explore:1", MonsterId="wild:TRex:1"}
	check(service:PrepareExploration({}, recoveredRun) and recoveredRun.EconomySerial == 1, "Matching ledger supplies stable serial when adapter reconstructs")
	local another, store = serviceFixture()
	local profile = another:Profile({}); opened(profile, "Exploration"); apply(profile, "StartRun")
	check(another:Close({}, {Id="explore:1", MonsterId="wild:TRex:1",EconomySerial=1,EconomyStarted=true,Traps=0,Potions=0}), "Can close interrupted exploration")
	check(store.DataValue.Statistics.HuntsFailed == 0, "Exploration abandonment is not failed mission")
	local mission, missionStore = serviceFixture()
	local missionProfile = mission:Profile({}); opened(missionProfile); apply(missionProfile, "StartRun")
	check(mission:Close({}, {Id="explore:1",EconomySerial=1,EconomyStarted=true,Traps=3,Potions=3}), "Existing mission closes")
	check(missionStore.DataValue.Statistics.HuntsFailed == 1, "Mission abandonment still counts failure")
end)

test("CloseExploration follows committed state after pending saves resolve", function()
	for failAt = 1, 3 do
		local service, persistence = serviceFixture(failAt)
		local run = {Id="explore:1", MonsterId="wild:TRex:1"}
		check(not service:PrepareExploration({}, run), "Fixture leaves an unacknowledged pending stage")
		local closed, reason = service:CloseExploration({}, run)
		check(not closed and reason == "SavePending", "Close waits for pending save acknowledgement")
		persistence:Flush()
		local state = persistence.DataValue.Economy.ActiveRun.State
		check(state == (if failAt == 1 then "Preparing" elseif failAt == 2 then "Hunting" else "Defeated"), "Pending state committed without caller retry")
		check(service:CloseExploration({}, run), "Close uses canonical state even when runtime started flag is stale")
		local data = persistence.DataValue
		check(data.Economy.ActiveRun == nil and data.Economy.ClosedRuns[1].Mode == "Exploration", "Exploration ledger closed")
		check(data.Statistics.HuntsFailed == 0 and data.Statistics.HuntsCompleted == 0, "Abort does not change hunt statistics")
		check(data.Economy.StoredConsumables.IronTrap == 3 and data.Economy.StoredConsumables.SleepPotion == 3, "Abort cannot refund supplies that exploration never reserved")
		local before = clone(data)
		check(service:CloseExploration({}, run) and same(before, persistence.DataValue), "Close replays after closure")
	end
	local service, persistence = serviceFixture()
	check(service:CloseExploration({}, {Id="never:opened", MonsterId="never:monster"}) and persistence.Count == 0, "Never opened exploration closes without a transaction")
	local profile = service:Profile({}); opened(profile, "Exploration"); apply(profile, "StartRun")
	local before = clone(profile)
	local ok, reason = service:CloseExploration({}, {Id="another",MonsterId="another:monster",EconomySerial=1})
	check(not ok and reason == "ActiveRun" and same(before, service:Profile({})), "Closing cannot affect another active ledger")
end)

test("Service finish statistics distinguish exploration from normal missions", function()
	for _, result in {"Defeated", "Failed"} do
		local service, persistence = serviceFixture()
		local p = service:Profile({}); opened(p, "Exploration"); apply(p, "StartRun")
		local receipt = service:_runRequest({}, {Id="explore:1",EconomySerial=1}, "Finish", {Result=result})
		check(receipt.Ok and persistence.DataValue.Statistics.HuntsCompleted == 0
			and persistence.DataValue.Statistics.HuntsFailed == 0, "Exploration " .. result .. " is not a hunt statistic")
	end
	local service, persistence = serviceFixture()
	local p = service:Profile({}); opened(p); apply(p, "StartRun")
	check(service:_runRequest({}, {Id="explore:1",EconomySerial=1}, "Finish", {Result="Defeated"}).Ok, "Normal mission still finishes")
	check(persistence.DataValue.Statistics.HuntsCompleted == 1, "Normal completed hunt statistic retained")
end)

for _, file in {"src/hunting/HuntEconomyRules.luau", "src/hunting/HuntEconomyService.luau", "src/data/ProfileSchema.luau"} do
	luau.compile(fs.readFile(file)); check(true, "Canonical source compiles")
end
print(string.format("Exploration economy: %d checks / %d groups PASS", checks, groups))
