-- Server-memory tests only; no Studio Instances, player accounts or DataStore.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local E = require("../src/hunting/HuntEconomyRules")
local checks, groups = 0, 0
local function check(condition, message)
	checks += 1
	assert(condition, message)
end
local function same(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for key, value in a do if not same(value, b[key]) then return false end end
	for key, value in b do if not same(value, a[key]) then return false end end
	return true
end
local function clone(t)
	if type(t) ~= "table" then return t end
	local r = {}
	for k, v in t do r[k] = clone(v) end
	return r
end
local function test(name, body)
	body()
	groups += 1
	print("PASS", name)
end
local function apply(p, request)
	local receipt = E.apply(p, request)
	check(receipt.Ok, "Expected accepted " .. tostring(request.Op) .. ": " .. receipt.Code)
	return receipt
end
local function reject(p, request, code)
	local before = clone(p)
	local receipt = E.apply(p, request)
	check(not receipt.Ok, "Expected rejection: " .. tostring(if type(request) == "table" then request.Op else request))
	if code then check(receipt.Code == code, "Expected " .. code .. ", got " .. receipt.Code) end
	check(same(p, before), "Rejected transaction leaves all state and ledgers unchanged")
	return receipt
end
local function begin(p)
	local request = {Op = "OpenRun", RunId = "run:" .. p.RunSerial + 1,
		MonsterId = "monster:" .. p.RunSerial + 1, RunSerial = p.RunSerial + 1}
	local opened = apply(p, request)
	local ids = {RunId = request.RunId, RunSerial = request.RunSerial, MonsterId = request.MonsterId}
	apply(p, {Op = "StartRun", RunId = ids.RunId, RunSerial = ids.RunSerial})
	return ids, opened
end
local function specimen(ids, ordinal)
	local n = ordinal or ids.RunSerial
	return {Id = string.format("%08x-0000-4000-8000-%012x", n, n), SpeciesId = "TRex", Name = "T-Rex",
		Variant = "Normal", Element = "None", SizeScale = 1, CapturedAt = 1792400000 + n,
		SourceRunId = ids.RunId, SourceMonsterId = ids.MonsterId}
end
local function inRun(p, ids, operation, fields)
	local request = clone(fields or {})
	request.Op, request.RunId, request.RunSerial = operation, ids.RunId, ids.RunSerial
	if operation == "Finish" and request.Result == "Captured" and request.Specimen == nil then
		request.Specimen = specimen(ids)
	end
	return apply(p, request), request
end
local function base(p, operation, fields)
	local request = clone(fields or {})
	request.Op, request.OperationSerial = operation, p.OperationSerial + 1
	return apply(p, request), request
end
local function equipped()
	local p = E.new()
	local ids = begin(p)
	for i = 1, 6 do inRun(p, ids, "Ore", {Index = i}) end
	inRun(p, ids, "Finish", {Result = "Defeated"})
	inRun(p, ids, "CloseRun", {Traps = 0, Potions = 0})
	for _ = 1, 3 do
		base(p, "Buy", {Item = "RawTrap"})
		base(p, "CraftTrap")
		base(p, "Buy", {Item = "SleepPotion"})
	end
	return p
end
local CaptureRolls = {{TypeRoll = 0.1, QuantityRoll = 0.1},
	{TypeRoll = 0.5, QuantityRoll = 0.5}, {TypeRoll = 0.75, QuantityRoll = 0.99}}

test("Canonical module compiles and profile gets starter coins only on creation", function()
	luau.compile(fs.readFile("src/hunting/HuntEconomyRules.luau"))
	local p = E.new()
	check(p.Coins == 80 and p.StarterGranted and p.HammerLevel == 1, "Starter profile")
	for _, n in p.Materials do check(n == 0, "No starter material") end
	for _, n in p.StoredConsumables do check(n == 0, "No debug items leak into profile") end
	p.Coins = 3
	local restored = assert(E.new(p))
	check(restored.Coins == 3 and restored ~= p, "Existing profile cloned without fresh 80")
	check(E.new({StarterGranted = false}) == nil, "Bad existing profile never becomes a fresh starter profile")
	check(E.damageMultiplier(p) == 1, "Level one baseline")
end)

test("Invalid requests and malformed counts reject without mutation", function()
	local p = E.new()
	for _, value in {false, 5, "Buy", {}} do reject(p, value, "InvalidRequest") end
	for _, quantity in {-1, 0, 2, 0.5, math.huge, 0 / 0, "1"} do
		reject(p, {Op = "Buy", OperationSerial = 1, Item = "RawTrap", Quantity = quantity}, "InvalidQuantity")
	end
	for _, n in {-1, 0, 1.5, math.huge, 0 / 0, "1"} do
		reject(p, {Op = "Buy", OperationSerial = n, Item = "RawTrap"}, "InvalidSerial")
	end
	reject(p, {Op = "Buy", OperationSerial = 1, Item = "IronTrap"}, "InvalidItem")
	reject(p, {Op = "Buy", OperationSerial = 2, Item = "RawTrap"}, "StaleOperation")
	local corrupt = clone(p)
	corrupt.Materials.Iron = -1
	reject(corrupt, {Op = "Buy", OperationSerial = 1, Item = "RawTrap"}, "InvalidProfile")
end)

test("Purchases debit exactly ten; replay cannot substitute another item", function()
	local p = E.new()
	local receipt, request = base(p, "Buy", {Item = "RawTrap"})
	check(p.Coins == 70 and p.StoredConsumables.RawTrap == 1, "Single purchase")
	local state = clone(p)
	request.Item, request.Quantity = "SleepPotion", 100
	local again = apply(p, request)
	check(again.Replay and again.Item == receipt.Item and same(state, p), "Fixed transaction returns cached result")
	for _ = 1, 7 do base(p, "Buy", {Item = "SleepPotion"}) end
	check(p.Coins == 0 and p.StoredConsumables.SleepPotion == 7, "No fractional cost or hidden grant")
	reject(p, {Op = "Buy", OperationSerial = 9, Item = "SleepPotion"}, "InsufficientCoins")
end)

test("Empty inventory and zero coins never block ordinary hunting", function()
	local p = E.new()
	p.Coins = 0
	local ids, receipt = begin(p)
	check(receipt.Traps == 0 and receipt.Potions == 0 and p.Coins == 0, "Free hunt with zero consumables")
	reject(p, {Op = "Buy", OperationSerial = 1, Item = "RawTrap"}, "ActiveRun")
	inRun(p, ids, "Finish", {Result = "Failed"})
	inRun(p, ids, "CloseRun", {Traps = 0, Potions = 0})
	check(p.Coins == 0, "No consolation package on failure")
end)

test("Open transfers up to three owned items without changing ownership totals", function()
	local p = E.new()
	p.StoredConsumables.IronTrap, p.StoredConsumables.SleepPotion = 5, 2
	local request = {Op = "OpenRun", RunId = "r", MonsterId = "m", RunSerial = 1, Traps = 999}
	local first = apply(p, request)
	check(first.Traps == 3 and first.Potions == 2, "Carried counts derived from owned inventory")
	check(p.StoredConsumables.IronTrap == 2 and p.StoredConsumables.SleepPotion == 0, "No duplicated transfers")
	local before = clone(p)
	check(apply(p, request).Replay and same(before, p), "Open retry never transfers twice")
	reject(p, {Op = "OpenRun", RunId = "other", MonsterId = "m", RunSerial = 2}, "ActiveRun")
	reject(p, {Op = "Ore", RunId = "r", RunSerial = 1, Index = 1}, "InvalidState")
end)

test("Entry failure returns all reserved items once; cannot fake entry failure after start", function()
	local p = E.new()
	p.StoredConsumables.IronTrap, p.StoredConsumables.SleepPotion = 2, 3
	apply(p, {Op = "OpenRun", RunId = "r", MonsterId = "m", RunSerial = 1})
	local request = {Op = "CloseRun", RunId = "r", RunSerial = 1, EntryFailed = true}
	local result = apply(p, request)
	check(result.ReturnedTraps == 2 and result.ReturnedPotions == 3 and p.ActiveRun == nil, "Full reservation refund")
	local before = clone(p)
	check(apply(p, request).Replay and same(before, p), "Repeated failed entry returns cached refund")
	local ids = begin(p)
	reject(p, {Op = "CloseRun", RunId = ids.RunId, RunSerial = ids.RunSerial, EntryFailed = true}, "InvalidState")
end)

test("Consumption sync only decreases finite counts and does not refund used items", function()
	local p = equipped()
	local ids = begin(p)
	inRun(p, ids, "SyncItems", {Traps = 2, Potions = 3})
	local revision = p.Revision
	local sameCounts = inRun(p, ids, "SyncItems", {Traps = 2, Potions = 3})
	check(sameCounts.Unchanged and p.Revision == revision, "Duplicate sync has no state change")
	for _, values in {{3, 3}, {-1, 2}, {2, 4}, {0.5, 2}, {0 / 0, 2}, {1, math.huge}, {1, "2"}} do
		reject(p, {Op = "SyncItems", RunId = ids.RunId, RunSerial = ids.RunSerial, Traps = values[1], Potions = values[2]}, "InvalidRemaining")
	end
	inRun(p, ids, "Finish", {Result = "Failed", Traps = 1, Potions = 2})
	local closed = inRun(p, ids, "CloseRun", {Traps = 1, Potions = 2})
	check(closed.ReturnedTraps == 1 and p.StoredConsumables.IronTrap == 1, "Only unused traps returned")
	check(closed.ReturnedPotions == 2 and p.StoredConsumables.SleepPotion == 2, "Only unused potions returned")
end)

test("Six ore sources grant individually; replay and forged source indices cannot multiply ore", function()
	local p = E.new()
	local ids = begin(p)
	for i = 1, 6 do
		local receipt, request = inRun(p, ids, "Ore", {Index = i})
		check(receipt.Material == "Iron" and receipt.Quantity == 1 and p.Materials.Iron == i, "Distinct ore source")
		local before = clone(p)
		check(apply(p, request).Replay and same(before, p), "Repeated ore receipt stable")
	end
	for _, index in {0, 7, 1.5, -1, 0 / 0, math.huge, "1"} do
		reject(p, {Op = "Ore", RunId = ids.RunId, RunSerial = ids.RunSerial, Index = index}, "InvalidIndex")
	end
	check(p.Materials.Iron == 6, "Maximum six iron from one run")
end)

test("One scale pickup is separate from carving and survives failed hunt", function()
	local p = E.new()
	local ids = begin(p)
	local _, request = inRun(p, ids, "Drop")
	check(p.Materials.Scale == 1, "Drop scale granted")
	check(apply(p, request).Replay and p.Materials.Scale == 1, "One drop source per run")
	inRun(p, ids, "Ore", {Index = 1})
	inRun(p, ids, "Finish", {Result = "Failed"})
	reject(p, {Op = "Ore", RunId = ids.RunId, RunSerial = ids.RunSerial, Index = 2}, "InvalidState")
	inRun(p, ids, "CloseRun", {Traps = 0, Potions = 0})
	check(p.Materials.Scale == 1 and p.Materials.Iron == 1 and p.Materials.Bone == 0 and p.Coins == 80, "Failure keeps pickups without mission bonus")
end)

test("Defeat grants only fixed package, then exactly three independent carve claims", function()
	local p = E.new()
	local ids = begin(p)
	reject(p, {Op = "Carve", RunId = ids.RunId, RunSerial = ids.RunSerial, Index = 1, TypeRoll = 0}, "InvalidState")
	local result, finishRequest = inRun(p, ids, "Finish", {Result = "Defeated"})
	check(result.BonusBone == 1 and result.BonusCoins == 40 and #result.Rewards == 0, "Package separate from carve")
	check(p.Materials.Bone == 1 and p.Materials.Skin == 0 and p.Coins == 120, "No automatic corpse materials")
	finishRequest.Result, finishRequest.Rolls = "Captured", CaptureRolls
	check(apply(p, finishRequest).Replay and p.Coins == 120, "Conflicting result cannot grant second package")
	reject(p, {Op = "Carve", RunId = ids.RunId, RunSerial = ids.RunSerial, Index = 2, TypeRoll = 0}, "InvalidIndex")
	local rolls = {0.499999, 0.5, 0.75}
	local expected = {"Skin", "Tooth", "Scale"}
	for i = 1, 3 do
		local carved, request = inRun(p, ids, "Carve", {Index = i, TypeRoll = rolls[i]})
		check(carved.Material == expected[i] and carved.Quantity == 1, "Carve type boundary and unit quantity")
		local before = clone(p)
		request.TypeRoll = 0.99
		local retry = apply(p, request)
		check(retry.Replay and retry.Material == expected[i] and same(before, p), "Carve replay keeps original roll")
	end
	reject(p, {Op = "Carve", RunId = ids.RunId, RunSerial = ids.RunSerial, Index = 4, TypeRoll = 0}, "InvalidIndex")
	check(p.Materials.Skin == 1 and p.Materials.Tooth == 1 and p.Materials.Scale == 1 and p.ActiveRun.Carves == 3, "Exactly three corpse materials")
end)

test("Malformed carve rolls cannot consume claim or change profile", function()
	local p = E.new()
	local ids = begin(p)
	inRun(p, ids, "Finish", {Result = "Defeated"})
	for _, sample in {-0.1, 1, math.huge, 0 / 0, "0.5"} do
		reject(p, {Op = "Carve", RunId = ids.RunId, RunSerial = ids.RunSerial, Index = 1, TypeRoll = sample}, "InvalidRolls")
	end
	check(inRun(p, ids, "Carve", {Index = 1, TypeRoll = 0}).Material == "Skin", "Valid retry still owns first claim")
end)

test("Capture atomically records consumed items, three independent rolls and fixed package", function()
	local p = equipped()
	local ids = begin(p)
	local bone, coins = p.Materials.Bone, p.Coins
	local result, request = inRun(p, ids, "Finish", {Result = "Captured", Traps = 2, Potions = 2, Rolls = CaptureRolls})
	check(p.ActiveRun.Traps == 2 and p.ActiveRun.Potions == 2 and p.ActiveRun.State == "Captured", "Items and result same commit")
	check(#result.Rewards == 3 and result.Rewards[1].Quantity == 1 and result.Rewards[2].Quantity == 2
		and result.Rewards[3].Quantity == 2, "Quantity rolls independent, exact half boundary")
	check(p.Materials.Skin == 1 and p.Materials.Tooth == 2 and p.Materials.Scale == 2, "Three material rolls granted")
	check(p.Materials.Bone == bone + 1 and p.Coins == coins + 40, "One mission package")
	local before = clone(p)
	request.Rolls, request.Potions = {{TypeRoll = 0 / 0}}, -5
	local retry = apply(p, request)
	check(retry.Replay and same(before, p) and same(retry.Rewards, result.Rewards), "Retry no reroll, item consume or duplicate bonus")
	reject(p, {Op = "Carve", RunId = ids.RunId, RunSerial = ids.RunSerial, Index = 1, TypeRoll = 0}, "InvalidState")
	inRun(p, ids, "CloseRun", {Traps = 2, Potions = 2})
	check(p.StoredConsumables.IronTrap == 2 and p.StoredConsumables.SleepPotion == 2, "Capture leftovers returned")
end)

test("Invalid capture is completely atomic, including attempted remaining item sync", function()
	local p = equipped()
	local ids = begin(p)
	local malformed = clone(CaptureRolls)
	malformed[3].QuantityRoll = 1
	reject(p, {Op = "Finish", RunId = ids.RunId, RunSerial = ids.RunSerial, Result = "Captured",
		Traps = 2, Potions = 2, Rolls = malformed, Specimen = specimen(ids)}, "InvalidRolls")
	check(p.ActiveRun.Traps == 3 and p.ActiveRun.Potions == 3 and p.ActiveRun.State == "Hunting", "Failed roll never consumes items")
	for _, rolls in {{}, {{TypeRoll = 0.1, QuantityRoll = 0.1}}, {{}, {}, {}}} do
		reject(p, {Op = "Finish", RunId = ids.RunId, RunSerial = ids.RunSerial, Result = "Captured",
			Traps = 2, Potions = 2, Rolls = rolls, Specimen = specimen(ids)}, "InvalidRolls")
	end
	reject(p, {Op = "Finish", RunId = ids.RunId, RunSerial = ids.RunSerial, Result = "Captured",
		Traps = 3, Potions = 3, Rolls = CaptureRolls, Specimen = specimen(ids)}, "CaptureItemsMissing")
end)

test("Capture cannot fabricate free trap or potion from empty ownership", function()
	local p = E.new()
	local ids = begin(p)
	reject(p, {Op = "Finish", RunId = ids.RunId, RunSerial = ids.RunSerial, Result = "Captured",
		Traps = 0, Potions = 0, Rolls = CaptureRolls, Specimen = specimen(ids)}, "CaptureItemsMissing")
	reject(p, {Op = "SyncItems", RunId = ids.RunId, RunSerial = ids.RunSerial, Traps = 1, Potions = 1}, "InvalidRemaining")
	check(p.Coins == 80 and p.Materials.Bone == 0, "Empty run unchanged")
end)

test("Failed result cannot be replaced by success and does not lose collected ore", function()
	local p = E.new()
	local ids = begin(p)
	inRun(p, ids, "Ore", {Index = 1})
	local _, request = inRun(p, ids, "Finish", {Result = "Failed"})
	request.Result = "Defeated"
	local retry = apply(p, request)
	check(retry.Replay and retry.Result == "Failed" and p.Coins == 80 and p.Materials.Iron == 1, "Failure remains locked")
	check(p.Materials.Bone == 0 and p.ActiveRun.State == "Failed", "No success package")
end)

test("Abandon close is failure, returns only unused items and keeps ore", function()
	local p = equipped()
	local ids = begin(p)
	inRun(p, ids, "Ore", {Index = 1})
	local coins, bones, iron = p.Coins, p.Materials.Bone, p.Materials.Iron
	local receipt, request = inRun(p, ids, "CloseRun", {Traps = 1, Potions = 3})
	check(receipt.Result == "Failed" and p.Coins == coins and p.Materials.Bone == bones and p.Materials.Iron == iron, "Abandon no package, keeps gathered ore")
	check(p.StoredConsumables.IronTrap == 1 and p.StoredConsumables.SleepPotion == 3, "Abandon one-time remaining return")
	local before = clone(p)
	request.Traps, request.Potions = 3, 3
	check(apply(p, request).Replay and same(before, p), "Close retry cannot increase refund")
end)

test("Crafting consumes one raw trap and iron atomically, no alternative purchase shortcut", function()
	local p = E.new()
	reject(p, {Op = "CraftTrap", OperationSerial = 1}, "InsufficientMaterials")
	base(p, "Buy", {Item = "RawTrap"})
	reject(p, {Op = "CraftTrap", OperationSerial = 2}, "InsufficientMaterials")
	local ids = begin(p)
	inRun(p, ids, "Ore", {Index = 1})
	inRun(p, ids, "CloseRun", {Traps = 0, Potions = 0})
	local _, request = base(p, "CraftTrap")
	check(p.Materials.Iron == 0 and p.StoredConsumables.RawTrap == 0 and p.StoredConsumables.IronTrap == 1, "Exact recipe")
	local before = clone(p)
	check(apply(p, request).Replay and same(p, before), "Recipe replay does not double craft")
end)

test("Two completed hunts supply upgrade; +15% level is permanent within profile", function()
	local p = E.new()
	reject(p, {Op = "UpgradeHammer", OperationSerial = 1}, "InsufficientMaterials")
	for i = 1, 2 do
		local ids = begin(p)
		inRun(p, ids, "Ore", {Index = 1})
		inRun(p, ids, "Finish", {Result = "Defeated"})
		inRun(p, ids, "CloseRun", {Traps = 0, Potions = 0})
		if i == 1 then reject(p, {Op = "UpgradeHammer", OperationSerial = 1}, "InsufficientMaterials") end
	end
	check(p.Coins == 160 and p.Materials.Bone == 2 and p.Materials.Iron == 2, "Two hunt resources")
	local result, request = base(p, "UpgradeHammer")
	check(result.HammerLevel == 2 and p.HammerLevel == 2 and E.damageMultiplier(p) == 1.15, "Upgraded damage multiplier")
	check(p.Materials.Bone == 0 and p.Materials.Iron == 0 and p.Coins == 160, "Upgrade consumes exact resources without coin fee")
	local before = clone(p)
	check(apply(p, request).Replay and same(before, p), "Upgrade retry atomic")
	reject(p, {Op = "UpgradeHammer", OperationSerial = 2}, "MaximumLevel")
	local ids = begin(p)
	inRun(p, ids, "CloseRun", {Traps = 0, Potions = 0})
	check(p.HammerLevel == 2 and E.damageMultiplier(assert(E.new(p))) == 1.15, "Run transition and profile clone preserve level")
end)

test("Capacity failures leave entire reward and receipt transaction unapplied", function()
	local p = E.new()
	local ids = begin(p)
	p.Materials.Iron = E.Config.MaximumCount
	reject(p, {Op = "Ore", RunId = ids.RunId, RunSerial = ids.RunSerial, Index = 1}, "Capacity")
	p.Materials.Bone = E.Config.MaximumCount
	reject(p, {Op = "Finish", RunId = ids.RunId, RunSerial = ids.RunSerial, Result = "Defeated"}, "Capacity")
	p.Materials.Bone, p.Coins = 0, E.Config.MaximumCount - 39
	reject(p, {Op = "Finish", RunId = ids.RunId, RunSerial = ids.RunSerial, Result = "Defeated"}, "Capacity")
	check(p.Materials.Bone == 0 and p.ActiveRun.State == "Hunting", "No partial bonus bone on coin capacity rejection")
	p.Coins, p.Materials.Iron = 80, 0
	inRun(p, ids, "Ore", {Index = 1})
	check(p.Materials.Iron == 1, "Rejected source did not get marked already granted")
end)

test("Closed run receipt replays never regrant, and new run has independent source indices", function()
	local p = E.new()
	local first = begin(p)
	local _, ore = inRun(p, first, "Ore", {Index = 1})
	inRun(p, first, "Finish", {Result = "Defeated"})
	local _, carve = inRun(p, first, "Carve", {Index = 1, TypeRoll = 0.1})
	inRun(p, first, "CloseRun", {Traps = 0, Potions = 0})
	local second = begin(p)
	inRun(p, second, "Ore", {Index = 1})
	local before = clone(p)
	check(apply(p, ore).Replay and apply(p, carve).Replay and same(before, p), "Previous source requests return old receipt only")
	check(p.Materials.Iron == 2 and p.ActiveRun.Id == second.RunId, "Second run keeps independent ore")
	reject(p, {Op = "Ore", RunId = first.RunId, RunSerial = first.RunSerial, Index = 2}, "StaleRun")
	reject(p, {Op = "OpenRun", RunId = "reusedserial", MonsterId = "m", RunSerial = 1}, "ActiveRun")
end)

test("Closed run retention stays bounded and evicted sources cannot reopen or grant", function()
	local p = E.new()
	local firstRequest, firstOpen
	for i = 1, 20 do
		local ids = begin(p)
		local _, pickup = inRun(p, ids, "Ore", {Index = 1})
		if i == 1 then
			firstRequest = pickup
			firstOpen = {Op = "OpenRun", RunId = ids.RunId, MonsterId = "monster:1", RunSerial = ids.RunSerial}
		end
		inRun(p, ids, "Finish", {Result = "Failed"})
		inRun(p, ids, "CloseRun", {Traps = 0, Potions = 0})
		check(#p.ClosedRuns <= E.Config.RecentClosedRuns, "Closed records bounded")
	end
	check(p.Materials.Iron == 20 and #p.ClosedRuns == 8, "All independent grants kept despite bounded history")
	reject(p, firstRequest, "StaleRun")
	reject(p, firstOpen, "StaleRun")
	check(p.RunSerial == 20, "Monotonic high water mark survives cleanup")
end)

test("Operation retention stays bounded and evicted operation serial cannot commit again", function()
	local p = E.new()
	p.Coins = 1000
	local oldest
	for i = 1, 80 do
		local _, request = base(p, "Buy", {Item = "RawTrap"})
		if i == 1 then oldest = request end
		check(#p.OperationOrder <= E.Config.RecentOperations, "Base receipt count bounded")
	end
	check(#p.OperationOrder == 64 and p.OperationSerial == 80 and p.StoredConsumables.RawTrap == 80, "Only recent receipts retained")
	reject(p, oldest, "StaleOperation")
	local count = 0
	for _ in p.OperationReceipts do count += 1 end
	check(count == 64, "Eviction removes matching receipt keys")
end)

test("Snapshots and returned receipts never expose references to profile ledger or inventories", function()
	local p = E.new()
	local receipt, request = base(p, "Buy", {Item = "RawTrap"})
	receipt.Item, receipt.Cost = "IronTrap", 0
	check(apply(p, request).Item == "RawTrap", "Receipt is detached")
	local ids = begin(p)
	inRun(p, ids, "Ore", {Index = 1})
	local snapshot = assert(E.snapshot(p))
	check(snapshot.OperationReceipts == nil and snapshot.ClosedRuns == nil and snapshot.ActiveRun.Claims == nil, "Only public state in snapshot")
	snapshot.Coins, snapshot.Materials.Iron, snapshot.StoredConsumables.RawTrap, snapshot.ActiveRun.Traps = 9999, 9999, 9999, 99
	check(p.Coins == 70 and p.Materials.Iron == 1 and p.StoredConsumables.RawTrap == 1 and p.ActiveRun.Traps == 0, "Snapshot detached from authoritative state")
end)

local function captureRequest(ids, fields)
	local request = {Op = "Finish", RunId = ids.RunId, RunSerial = ids.RunSerial, Result = "Captured",
		Traps = 2, Potions = 2, Rolls = clone(CaptureRolls), Specimen = specimen(ids)}
	for key, value in fields or {} do request[key] = value end
	return request
end

local function specimenProfile(number)
	local p = E.new()
	p.StoredConsumables.IronTrap, p.StoredConsumables.SleepPotion = 300, 300
	local requests = {}
	for _ = 1, number do
		local ids = begin(p)
		local request = captureRequest(ids)
		apply(p, request)
		inRun(p, ids, "CloseRun", {Traps = 2, Potions = 2})
		table.insert(requests, request)
	end
	return p, requests
end

test("New collection is version two, empty and available without changing economy", function()
	local p = E.new()
	local ready, code = E.canCapture(p)
	check(p.DataVersion == 2 and p.SpecimenSerial == 0 and next(p.OwnedSpecimens) == nil, "Explicit empty collection schema")
	check(ready and code == "Ready", "Unbound capacity preview supported")
	local snapshot = assert(E.snapshot(p))
	check(snapshot.SpecimenCount == 0 and snapshot.SpecimenLimit == 100 and snapshot.SpecimenSerial == 0, "Bounded collection DTO")
	check(p.Coins == 80 and p.Materials.Bone == 0 and p.StoredConsumables.SleepPotion == 0, "No collection starter rewards")
	check(not E.canCapture(p, "missing", 1), "Unopened run cannot authorize capture")
	for _, args in {{"missing"}, {false, 1}, {"missing", 0}, {"missing", 1.5}, {"missing", math.huge}} do
		local allowed, reason = E.canCapture(p, args[1], args[2])
		check(not allowed and reason == "InvalidRun", "Partial/malformed run keys rejected")
	end
	local ids = begin(p)
	check(E.canCapture(p, ids.RunId, ids.RunSerial), "Active hunting run bound to capture preview")
	local allowed, reason = E.canCapture(p, ids.RunId, ids.RunSerial + 1)
	check(not allowed and reason == "StaleRun", "Old or foreign run cannot authorize")
	inRun(p, ids, "Finish", {Result = "Defeated"})
	allowed, reason = E.canCapture(p, ids.RunId, ids.RunSerial)
	check(not allowed and reason == "InvalidState", "Finished hunt cannot authorize capture")
	check(next(p.OwnedSpecimens) == nil and p.SpecimenSerial == 0, "Ordinary defeat creates no specimen")
end)

test("Two captures receive distinct stable IDs and monotonic order; closed replay cannot reroll", function()
	local p, requests = specimenProfile(2)
	local one, two = requests[1].Specimen.Id, requests[2].Specimen.Id
	check(one ~= two and p.SpecimenSerial == 2, "Distinct capture identifiers and serial high water mark")
	check(p.OwnedSpecimens[one].Serial == 1 and p.OwnedSpecimens[two].Serial == 2, "Sort order follows successful commit")
	check(p.OwnedSpecimens[one].SourceRunId == requests[1].RunId
		and p.OwnedSpecimens[two].SourceMonsterId == "monster:2", "Ownership records bind source run and monster")
	check(p.Materials.Skin == 2 and p.Materials.Tooth == 4 and p.Materials.Scale == 4
		and p.Materials.Bone == 2 and p.Coins == 160, "Specimens share original atomic reward package")
	local before = clone(p)
	requests[1].Specimen.Id, requests[1].Rolls = specimen({RunId = "x", MonsterId = "x", RunSerial = 99}).Id, {}
	requests[1].Traps, requests[1].Potions = -20, -20
	local retry = apply(p, requests[1])
	check(retry.Replay and retry.SpecimenId == one and retry.Specimen.Serial == 1, "Closed replay returns original individual")
	check(same(before, p), "Closed replay neither consumes nor changes collection/rewards")
	retry.Specimen.Name, retry.Rewards[1].Quantity = "changed", 999
	local retryAgain = apply(p, requests[1])
	check(retryAgain.Specimen.Name == "T-Rex" and retryAgain.Rewards[1].Quantity == 1, "Returned nested specimen and rewards detached")
	local snapshot = assert(E.snapshot(p))
	check(snapshot.SpecimenCount == 2 and snapshot.SpecimenLimit == 100, "Public total matches two owned records")
	snapshot.OwnedSpecimens[one].Serial, snapshot.OwnedSpecimens[one].Name = 999, "tampered"
	snapshot.OwnedSpecimens[two], snapshot.SpecimenSerial = nil, 500
	check(p.OwnedSpecimens[one].Serial == 1 and p.OwnedSpecimens[one].Name == "T-Rex"
		and p.OwnedSpecimens[two] ~= nil and p.SpecimenSerial == 2, "DTO cannot mutate authoritative ownership")
	check(snapshot.OperationReceipts == nil and snapshot.ClosedRuns == nil, "Collection DTO does not expose transaction ledger")
end)

test("Capture metadata is canonical, source bound and cannot introduce arbitrary owned data", function()
	local p = E.new()
	p.StoredConsumables.IronTrap, p.StoredConsumables.SleepPotion = 3, 3
	local ids = begin(p)
	local cases = {
		{"Id", ""}, {"Id", "not-a-guid"}, {"Id", string.rep("a", 36)}, {"Id", "00000000-0000-4000-8000-00000000000\n"},
		{"SpeciesId", "Raptor"}, {"Name", "Injected name"}, {"Variant", "Rare"}, {"Element", "Fire"},
		{"SizeScale", 2}, {"SizeScale", 0 / 0}, {"CapturedAt", -1}, {"CapturedAt", 1.5},
		{"CapturedAt", math.huge}, {"CapturedAt", 0 / 0}, {"CapturedAt", E.Config.MaximumTimestamp + 1},
		{"SourceRunId", "foreign-run"}, {"SourceMonsterId", "foreign-monster"}, {"Serial", 1},
		{"Coins", 1000000}, {"OwnerUserId", 1},
	}
	for _, case in cases do
		local request = captureRequest(ids)
		request.Specimen[case[1]] = case[2]
		reject(p, request, "InvalidSpecimen")
	end
	for _, key in {"Id", "SpeciesId", "Name", "Variant", "Element", "SizeScale", "CapturedAt", "SourceRunId", "SourceMonsterId"} do
		local request = captureRequest(ids)
		request.Specimen[key] = nil
		reject(p, request, "InvalidSpecimen")
	end
	for _, bad in {false, "specimen", 5} do
		reject(p, captureRequest(ids, {Specimen = bad}), "InvalidSpecimen")
	end
	local missing = captureRequest(ids)
	missing.Specimen = nil
	reject(p, missing, "InvalidSpecimen")
	check(p.SpecimenSerial == 0 and next(p.OwnedSpecimens) == nil
		and p.ActiveRun.Traps == 3 and p.ActiveRun.Potions == 3 and p.ActiveRun.State == "Hunting", "Metadata rejections consume nothing")
	local request = captureRequest(ids)
	local result = apply(p, request)
	request.Specimen.Name = "changed afterwards"
	result.Specimen.CapturedAt = 0
	check(p.OwnedSpecimens[result.SpecimenId].Name == "T-Rex"
		and p.OwnedSpecimens[result.SpecimenId].CapturedAt == 1792400001, "Accepted request/receipt records detached")
end)

test("Duplicate specimen ID or reused capture source never grants another reward package", function()
	local p, requests = specimenProfile(1)
	local ids = begin(p)
	local request = captureRequest(ids)
	request.Specimen.Id = requests[1].Specimen.Id
	reject(p, request, "DuplicateSpecimen")
	check(p.SpecimenSerial == 1 and p.Coins == 120 and p.ActiveRun.Potions == 3, "Duplicate identifier leaves new run and costs untouched")
	-- Even after the bounded recent-run ledger is evicted, the owned specimen
	-- keeps its source identity and prevents a new run from reusing that monster.
	inRun(p, ids, "CloseRun", {Traps = 3, Potions = 3})
	for _ = 1, 9 do
		local later = begin(p)
		inRun(p, later, "Finish", {Result = "Failed"})
		inRun(p, later, "CloseRun", {Traps = 3, Potions = 3})
	end
	local n = p.RunSerial + 1
	apply(p, {Op = "OpenRun", RunId = "fresh-run", MonsterId = "monster:1", RunSerial = n})
	apply(p, {Op = "StartRun", RunId = "fresh-run", RunSerial = n})
	local duplicateSource = {RunId = "fresh-run", MonsterId = "monster:1", RunSerial = n}
	reject(p, captureRequest(duplicateSource), "DuplicateSpecimen")
	check(p.SpecimenSerial == 1 and E.snapshot(p).SpecimenCount == 1, "Eviction does not erase durable in-memory source ownership")
end)

test("One hundred owned specimens block capture atomically but do not block ordinary hunting", function()
	local p = specimenProfile(E.Config.MaxOwnedSpecimens)
	local allowed, code = E.canCapture(p)
	check(not allowed and code == "SpecimenCapacity" and E.snapshot(p).SpecimenCount == 100, "Collection limit reached exactly")
	check(p.SpecimenSerial == 100 and p.Materials.Bone == 100 and p.Coins == 4080, "Every successful capture granted exactly one individual/package")
	local ids, opened = begin(p)
	check(opened.Traps == 3 and p.ActiveRun.State == "Hunting", "Full collection still allows ordinary hunt entry")
	allowed, code = E.canCapture(p, ids.RunId, ids.RunSerial)
	check(not allowed and code == "SpecimenCapacity", "Bound runtime preflight reports collection full")
	reject(p, captureRequest(ids), "SpecimenCapacity")
	check(p.ActiveRun.Potions == 3 and p.ActiveRun.Traps == 3 and p.ActiveRun.State == "Hunting", "Capacity failure consumes no items or result")
	local result = inRun(p, ids, "Finish", {Result = "Defeated"})
	check(result.Result == "Defeated" and result.SpecimenId == nil and result.Specimen == nil, "Kill branch remains available")
	check(p.Materials.Bone == 101 and p.Coins == 4120 and E.snapshot(p).SpecimenCount == 100, "Kill grants package without adding individual")
	inRun(p, ids, "CloseRun", {Traps = 3, Potions = 3})
	local serialLimit = E.new()
	serialLimit.SpecimenSerial = E.Config.MaximumSerial
	allowed, code = E.canCapture(serialLimit)
	check(not allowed and code == "SpecimenCapacity", "Monotonic serial cannot overflow")
end)

test("Version one migration preserves money, all items, active run and receipt ledgers without another starter grant", function()
	local legacy = equipped()
	legacy.DataVersion, legacy.OwnedSpecimens, legacy.SpecimenSerial = 1, nil, nil
	legacy.Coins, legacy.HammerLevel = 3, 2
	legacy.WeaponLevels = nil -- Version one predates per-weapon upgrades.
	local before = clone(legacy)
	local migrated = assert(E.new(legacy))
	check(same(legacy, before), "Migration never mutates old profile")
	check(migrated.DataVersion == 2 and migrated.SpecimenSerial == 0 and next(migrated.OwnedSpecimens) == nil, "Migration introduces only empty collection schema")
	local reverted = clone(migrated)
	reverted.DataVersion, reverted.OwnedSpecimens, reverted.SpecimenSerial = 1, nil, nil
	reverted.WeaponLevels = nil
	check(same(reverted, legacy), "All legacy values, revision, source marks and item totals preserved exactly")
	check(migrated.Coins == 3 and migrated.HammerLevel == 2 and E.damageMultiplier(migrated) == 1.15, "No 80-coin grant or upgrade reset")
	local ids = begin(migrated)
	local activeLegacy = clone(migrated)
	activeLegacy.DataVersion, activeLegacy.OwnedSpecimens, activeLegacy.SpecimenSerial = 1, nil, nil
	local activeMigrated = assert(E.new(activeLegacy))
	check(same(activeMigrated.ActiveRun, activeLegacy.ActiveRun) and activeMigrated.ActiveRun.State == "Hunting", "Existing active run migration preserved")
	local result = apply(activeMigrated, captureRequest(ids))
	check(result.Specimen.Serial == 1 and activeMigrated.Coins == 43, "Migrated running hunt can commit first individual")
	local oldReceipt = legacy.OperationReceipts[legacy.OperationOrder[1]]
	migrated.OperationReceipts[migrated.OperationOrder[1]].Code = "changed"
	check(oldReceipt.Code ~= "changed", "Migrated ledgers are deep copies")
end)

test("Malformed legacy profiles reject rather than silently resetting account progress", function()
	local function legacy()
		local p = equipped()
		p.DataVersion, p.OwnedSpecimens, p.SpecimenSerial = 1, nil, nil
		return p
	end
	local corruptions = {
		function(p) p.Coins = -1 end,
		function(p) p.Materials.Iron = 0 / 0 end,
		function(p) p.StoredConsumables.SleepPotion = math.huge end,
		function(p) p.StarterGranted = false end,
		function(p) p.OperationReceipts[p.OperationOrder[1]] = nil end,
		function(p) p.OperationReceipts[999] = {Ok = true, Code = "Purchased", Replay = false, OperationSerial = 999} end,
		function(p) table.insert(p.OperationOrder, p.OperationOrder[1]) end,
		function(p) p.ClosedRuns[1].Claims.OpenRun = {} end,
		function(p) p.ClosedRuns[1].Serial = p.RunSerial + 1 end,
		function(p) p.OwnedSpecimens = {} end,
		function(p) p.SpecimenSerial = 0 end,
		function(p) p.Extension = function() end end,
		function(p) p.Extension = p end,
	}
	for _, corrupt in corruptions do
		local profile = legacy()
		corrupt(profile)
		local result, reason = E.new(profile)
		check(result == nil and reason == "InvalidProfile", "Corrupt v1 never becomes a fresh starter profile")
	end
end)

test("Owned record validation rejects malformed schema, mismatched keys and duplicate serial/source identity", function()
	local original = specimenProfile(2)
	local first, second = specimen({RunId = "run:1", MonsterId = "monster:1", RunSerial = 1}).Id,
		specimen({RunId = "run:2", MonsterId = "monster:2", RunSerial = 2}).Id
	local corruptions = {
		function(p) p.SpecimenSerial = 1 end,
		function(p) p.SpecimenSerial = -1 end,
		function(p) p.OwnedSpecimens[first].Serial = 0 end,
		function(p) p.OwnedSpecimens[first].Serial = 1.5 end,
		function(p) p.OwnedSpecimens[first].SizeScale = math.huge end,
		function(p) p.OwnedSpecimens[first].Variant = "Rare" end,
		function(p) p.OwnedSpecimens[first].OwnerUserId = 12 end,
		function(p) p.OwnedSpecimens[first].Id = second end,
		function(p) p.OwnedSpecimens[second].Serial = p.OwnedSpecimens[first].Serial end,
		function(p) p.OwnedSpecimens[second].SourceRunId = p.OwnedSpecimens[first].SourceRunId end,
		function(p) p.OwnedSpecimens[second].SourceMonsterId = p.OwnedSpecimens[first].SourceMonsterId end,
		function(p) p.OwnedSpecimens = false end,
	}
	for _, corrupt in corruptions do
		local p = clone(original)
		corrupt(p)
		reject(p, {Op = "OpenRun", RunId = "new", MonsterId = "new", RunSerial = 3}, "InvalidProfile")
		local restored, reason = E.new(p)
		check(restored == nil and reason == "InvalidProfile" and E.snapshot(p) == nil, "Corrupt owned data cannot load or publish DTO")
		local allowed, code = E.canCapture(p)
		check(not allowed and code == "InvalidProfile", "Malformed collection cannot authorize potion consumption")
	end
	local full = specimenProfile(100)
	local extraIds = {RunId = "run:101", MonsterId = "monster:101", RunSerial = 101}
	local extra = specimen(extraIds)
	extra.Serial = 101
	full.SpecimenSerial, full.OwnedSpecimens[extra.Id] = 101, extra
	check(E.new(full) == nil and E.snapshot(full) == nil, "Oversized collection is invalid, never silently truncated")
end)

test("Five display slots assign, replace, move and clear without losing owned individuals", function()
	local p, captures=specimenProfile(6)
	local owned, coins, materials=clone(p.OwnedSpecimens),p.Coins,clone(p.Materials)
	for slot=1,5 do
		local receipt=base(p,"SetDisplaySlot",{Slot=slot,SpecimenId=captures[slot].Specimen.Id})
		check(receipt.Slot==slot and receipt.SpecimenId==captures[slot].Specimen.Id
			and p.DisplaySlots[slot]==receipt.SpecimenId,"Every tube stores its chosen individual")
	end
	local moved=base(p,"SetDisplaySlot",{Slot=5,SpecimenId=captures[1].Specimen.Id})
	check(moved.MovedFrom==1 and moved.PreviousSpecimenId==captures[5].Specimen.Id
		and p.DisplaySlots[1]==nil and p.DisplaySlots[5]==captures[1].Specimen.Id,"Move atomically frees original tube and returns displaced specimen to collection")
	base(p,"SetDisplaySlot",{Slot=1,SpecimenId=captures[6].Specimen.Id})
	for slot=1,5 do
		local receipt=base(p,"SetDisplaySlot",{Slot=slot,SpecimenId=false})
		check(receipt.SpecimenId==nil and p.DisplaySlots[slot]==nil,"Every tube can be cleared")
	end
	check(next(p.DisplaySlots)==nil and same(owned,p.OwnedSpecimens),"All records and GUIDs survive assignment changes")
	check(p.Coins==coins and same(p.Materials,materials) and p.SpecimenSerial==6,"Displays do not alter economy rewards or capture sequence")
end)

test("Display requests reject invalid slots, unknown GUIDs and active hunts atomically", function()
	local p,captures=specimenProfile(1)
	local validId=captures[1].Specimen.Id
	for _,slot in {0,6,-1,1.5,math.huge,0/0,"1",false} do
		reject(p,{Op="SetDisplaySlot",OperationSerial=p.OperationSerial+1,Slot=slot,SpecimenId=validId},"InvalidDisplaySlot")
	end
	for _,bad in {"", "not-a-guid", true, 123, {}, string.rep("x",129)} do
		reject(p,{Op="SetDisplaySlot",OperationSerial=p.OperationSerial+1,Slot=1,SpecimenId=bad},"InvalidSpecimenId")
	end
	reject(p,{Op="SetDisplaySlot",OperationSerial=p.OperationSerial+1,Slot=1,
		SpecimenId="ffffffff-0000-4000-8000-ffffffffffff"},"SpecimenNotOwned")
	begin(p)
	reject(p,{Op="SetDisplaySlot",OperationSerial=p.OperationSerial+1,Slot=5,SpecimenId=validId},"ActiveRun")
end)

test("Display receipts replay safely and snapshot assignments are detached", function()
	local p,captures=specimenProfile(2)
	local original,request=base(p,"SetDisplaySlot",{Slot=5,SpecimenId=captures[1].Specimen.Id})
	local before=clone(p)
	request.Slot,request.SpecimenId=1,captures[2].Specimen.Id
	local replayed=apply(p,request)
	check(replayed.Replay and replayed.Slot==5 and replayed.SpecimenId==original.SpecimenId
		and same(before,p),"Retried serial cannot redirect original transaction")
	local dto=E.snapshot(p)
	check(dto.DisplaySlotCount==5 and dto.DisplaySlots[5]==original.SpecimenId,"Public snapshot includes five-slot assignment contract")
	dto.DisplaySlots[5],dto.OwnedSpecimens[original.SpecimenId]=nil,nil
	check(p.DisplaySlots[5]==original.SpecimenId and p.OwnedSpecimens[original.SpecimenId]~=nil,"Client snapshot cannot clear display or ownership")
	p.Revision=E.Config.MaximumCount
	reject(p,{Op="SetDisplaySlot",OperationSerial=p.OperationSerial+1,Slot=1,SpecimenId=captures[1].Specimen.Id},"Capacity")
end)

test("Legacy v2 collections gain empty slots while malformed assignments fail closed", function()
	local p,captures=specimenProfile(2)
	local old=clone(p);old.DisplaySlots=nil
	local restored=assert(E.new(old))
	check(next(restored.DisplaySlots)==nil and same(restored.OwnedSpecimens,p.OwnedSpecimens)
		and restored.Revision==p.Revision and restored.Coins==p.Coins,"Existing collection receives only the empty slot field")
	check(old.DisplaySlots==nil,"Migration does not mutate original profile")
	local first,second=captures[1].Specimen.Id,captures[2].Specimen.Id
	for _,slots in {false,{[0]=first},{[6]=first},{[1.5]=first},{["1"]=first},
		{[1]=first,[5]=first},{[1]=false},{[1]="ffffffff-0000-4000-8000-ffffffffffff"},
		{[1]=first,[5]=second,Extra=first}} do
		local bad=clone(p);bad.DisplaySlots=slots
		check(E.new(bad)==nil and E.snapshot(bad)==nil,"Malformed, duplicate or unowned assignment is never silently erased")
	end
end)

print("Hunt economy rules:", checks, "checks /", groups, "groups PASS")
