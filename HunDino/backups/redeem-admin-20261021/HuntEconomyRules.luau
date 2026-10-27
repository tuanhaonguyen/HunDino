-- P1-E economy and first P1-F specimen collection in server memory. Runtime supplies trusted source IDs, rolls and
-- physical/context validation. Every accepted change commits with its receipt;
-- this module never yields, touches Instances or writes persistent account data.
local Rules = {}

Rules.Config = table.freeze({
	StarterCoins = 80,
	PurchaseCost = 10,
	MaxCarried = 3,
	OreCount = 6,
	CarveCount = 3,
	BonusCoins = 40,
	UpgradeBones = 2,
	UpgradeIron = 2,
	HammerMultiplier = 1.15,
	MaximumCount = 1000000000,
	MaximumSerial = 2147483647,
	RecentOperations = 64,
	RecentClosedRuns = 8,
	MaxOwnedSpecimens = 100,
	MaximumTimestamp = 253402300799,
})
local C = Rules.Config
local Materials = {"Skin", "Tooth", "Scale", "Bone", "Iron"}
local Items = {"RawTrap", "IronTrap", "SleepPotion"}
local RunStates = {Preparing = true, Hunting = true, Defeated = true, Captured = true, Failed = true}

local function clone(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for key, item in value do copy[key] = clone(item) end
	return copy
end

local function integer(value, maximum)
	return type(value) == "number" and value == value and value >= 0
		and value <= (maximum or C.MaximumCount) and value % 1 == 0
end

local function id(value)
	return type(value) == "string" and #value > 0 and #value <= 128 and not value:find("%c")
end

local function serial(value)
	return integer(value, C.MaximumSerial) and value > 0
end

local function roll(value)
	return type(value) == "number" and value == value and value >= 0 and value < 1
end

local function rejected(code)
	return {Ok = false, Code = code, Replay = false}
end

local function accepted(code, fields)
	local receipt = fields or {}
	receipt.Ok, receipt.Code, receipt.Replay = true, code, false
	return receipt
end

local function replay(receipt)
	local copy = clone(receipt)
	copy.Replay = true
	return copy
end

local function counts(container, keys)
	if type(container) ~= "table" then return false end
	for _, key in keys do if not integer(container[key]) then return false end end
	return true
end

local function guid(value)
	return type(value) == "string" and #value == 36
		and value:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

local SpecimenFields = {Id = true, SpeciesId = true, Name = true, Variant = true,
	Element = true, SizeScale = true, CapturedAt = true, SourceRunId = true, SourceMonsterId = true, Serial = true}

local function validSpecimen(record, owned)
	if type(record) ~= "table" or not guid(record.Id) or record.SpeciesId ~= "TRex"
		or record.Name ~= "T-Rex" or record.Variant ~= "Normal" or record.Element ~= "None"
		or record.SizeScale ~= 1 or not integer(record.CapturedAt, C.MaximumTimestamp)
		or not id(record.SourceRunId) or not id(record.SourceMonsterId) then return false end
	if owned then
		if not serial(record.Serial) then return false end
	elseif record.Serial ~= nil then return false end
	for key in record do if not SpecimenFields[key] then return false end end
	return true
end

-- Migration accepts validated, acyclic data, never an unreadable profile that
-- would otherwise fall back to fresh starter money. Receipts are kept intact.
local function plainTree(value, visiting, depth)
	local kind = type(value)
	if kind == "number" then return value == value and math.abs(value) < math.huge end
	if kind ~= "table" then return kind == "string" or kind == "boolean" end
	if depth > 12 or visiting[value] then return false end
	visiting[value] = true
	for key, child in value do
		if (type(key) ~= "string" and (type(key) ~= "number" or not integer(key, C.MaximumTimestamp)))
			or not plainTree(child, visiting, depth + 1) then visiting[value] = nil return false end
	end
	visiting[value] = nil
	return true
end

local function validReceipt(receipt)
	return type(receipt) == "table" and receipt.Ok == true and receipt.Replay == false
		and id(receipt.Code) and plainTree(receipt, {}, 0)
end

local function validClaims(claims)
	if type(claims) ~= "table" then return false end
	for key, receipt in claims do
		local known = key == "OpenRun" or key == "StartRun" or key == "Finish" or key == "CloseRun" or key == "Drop"
			or (type(key) == "string" and (key:match("^Ore:[1-6]$") or key:match("^Carve:[1-3]$")))
		if not known or not validReceipt(receipt) then return false end
	end
	return validReceipt(claims.OpenRun)
end

local function validRun(run)
	return type(run) == "table" and id(run.Id) and id(run.MonsterId) and serial(run.Serial)
		and RunStates[run.State] and integer(run.Traps, C.MaxCarried) and integer(run.Potions, C.MaxCarried)
		and integer(run.InitialTraps, C.MaxCarried) and integer(run.InitialPotions, C.MaxCarried)
		and run.Traps <= run.InitialTraps and run.Potions <= run.InitialPotions
		and integer(run.Carves, C.CarveCount) and validClaims(run.Claims)
end

local function validBaseProfile(profile, version)
	if type(profile) ~= "table" or profile.DataVersion ~= version or profile.StarterGranted ~= true
		or profile.StorageMode ~= "ServerMemory"
		or not integer(profile.Revision) or not integer(profile.Coins)
		or not counts(profile.Materials, Materials) or not counts(profile.StoredConsumables, Items)
		or (profile.HammerLevel ~= 1 and profile.HammerLevel ~= 2)
		or not integer(profile.RunSerial, C.MaximumSerial) or not integer(profile.OperationSerial, C.MaximumSerial)
		or type(profile.OperationReceipts) ~= "table" or type(profile.OperationOrder) ~= "table"
		or type(profile.ClosedRuns) ~= "table" or #profile.OperationOrder > C.RecentOperations
		or #profile.ClosedRuns > C.RecentClosedRuns then return false end
	if profile.ActiveRun ~= nil and (not validRun(profile.ActiveRun) or profile.ActiveRun.Serial ~= profile.RunSerial) then return false end
	local operations = {}
	for index, operationSerial in profile.OperationOrder do
		if not serial(index) or index > #profile.OperationOrder or not serial(operationSerial)
			or operationSerial > profile.OperationSerial or operations[operationSerial]
			or not validReceipt(profile.OperationReceipts[operationSerial]) then return false end
		operations[operationSerial] = true
	end
	for operationSerial, receipt in profile.OperationReceipts do
		if not operations[operationSerial] or receipt.OperationSerial ~= operationSerial then return false end
	end
	local closedIds, closedSerials = {}, {}
	for index, run in profile.ClosedRuns do
		if not serial(index) or index > #profile.ClosedRuns or type(run) ~= "table" or not id(run.Id)
			or not serial(run.Serial) or run.Serial > profile.RunSerial or not validClaims(run.Claims)
			or closedIds[run.Id] or closedSerials[run.Serial]
			or (profile.ActiveRun and (run.Id == profile.ActiveRun.Id or run.Serial == profile.ActiveRun.Serial)) then return false end
		closedIds[run.Id], closedSerials[run.Serial] = true, true
	end
	return true
end

local function specimenCount(profile)
	local count = 0
	for _ in profile.OwnedSpecimens do count += 1 end
	return count
end

local function validProfile(profile)
	if not validBaseProfile(profile, 2) or type(profile.OwnedSpecimens) ~= "table"
		or not integer(profile.SpecimenSerial, C.MaximumSerial) then return false end
	local count, serials, sourceRuns, sourceMonsters = 0, {}, {}, {}
	for key, record in profile.OwnedSpecimens do
		if not validSpecimen(record, true) or key ~= record.Id or record.Serial > profile.SpecimenSerial
			or serials[record.Serial] or sourceRuns[record.SourceRunId] or sourceMonsters[record.SourceMonsterId] then return false end
		count += 1
		if count > C.MaxOwnedSpecimens then return false end
		serials[record.Serial], sourceRuns[record.SourceRunId], sourceMonsters[record.SourceMonsterId] = true, true, true
	end
	return true
end

function Rules.new(existing)
	if existing ~= nil then
		if type(existing) == "table" and existing.DataVersion == 1 then
			if not validBaseProfile(existing, 1) or not plainTree(existing, {}, 0)
				or existing.OwnedSpecimens ~= nil or existing.SpecimenSerial ~= nil then return nil, "InvalidProfile" end
			local migrated = clone(existing)
			migrated.DataVersion, migrated.OwnedSpecimens, migrated.SpecimenSerial = 2, {}, 0
			return migrated
		end
		if not validProfile(existing) or not plainTree(existing, {}, 0) then return nil, "InvalidProfile" end
		return clone(existing)
	end
	return {
		DataVersion = 2, Revision = 0, StarterGranted = true, StorageMode = "ServerMemory",
		Coins = C.StarterCoins, HammerLevel = 1, RunSerial = 0, OperationSerial = 0,
		Materials = {Skin = 0, Tooth = 0, Scale = 0, Bone = 0, Iron = 0},
		StoredConsumables = {RawTrap = 0, IronTrap = 0, SleepPotion = 0},
		OperationReceipts = {}, OperationOrder = {}, ClosedRuns = {},
		OwnedSpecimens = {}, SpecimenSerial = 0,
	}
end

function Rules.canCapture(profile, runId, runSerial)
	if not validProfile(profile) then return false, "InvalidProfile" end
	if runId ~= nil or runSerial ~= nil then
		if not id(runId) or not serial(runSerial) then return false, "InvalidRun" end
		local run = profile.ActiveRun
		if not run or run.Id ~= runId or run.Serial ~= runSerial then return false, "StaleRun" end
		if run.State ~= "Hunting" then return false, "InvalidState" end
	end
	if specimenCount(profile) >= C.MaxOwnedSpecimens or profile.SpecimenSerial >= C.MaximumSerial then return false, "SpecimenCapacity" end
	return true, "Ready"
end

local function commit(profile, nextProfile, receipt)
	if not validProfile(nextProfile) then return rejected("InvalidResult") end
	if profile.Revision >= C.MaximumCount then return rejected("Capacity") end
	nextProfile.Revision = profile.Revision + 1
	for key in profile do profile[key] = nil end
	for key, value in nextProfile do profile[key] = value end
	return clone(receipt)
end

local function add(container, key, quantity)
	if not integer(quantity) or not integer(container[key]) or container[key] + quantity > C.MaximumCount then return false end
	container[key] += quantity
	return true
end

local function typeFor(sample)
	if not roll(sample) then return nil end
	if sample < 0.5 then return "Skin" end
	if sample < 0.75 then return "Tooth" end
	return "Scale"
end

local function sync(run, request)
	if request.Traps == nil and request.Potions == nil then return true end
	if not integer(request.Traps, C.MaxCarried) or not integer(request.Potions, C.MaxCarried)
		or request.Traps > run.Traps or request.Potions > run.Potions then return false end
	run.Traps, run.Potions = request.Traps, request.Potions
	return true
end

local function currentRun(profile, request)
	if not id(request.RunId) or not serial(request.RunSerial) then return nil, "InvalidRun" end
	local run = profile.ActiveRun
	if run and run.Id == request.RunId and run.Serial == request.RunSerial then return run end
	return nil, "StaleRun"
end

local function closedRun(profile, request)
	for _, record in profile.ClosedRuns do
		if record.Id == request.RunId and record.Serial == request.RunSerial then return record end
	end
	return nil
end

local function requestKey(request)
	if request.Op == "Ore" and integer(request.Index, C.OreCount) and request.Index > 0 then return "Ore:" .. request.Index end
	if request.Op == "Carve" and integer(request.Index, C.CarveCount) and request.Index > 0 then return "Carve:" .. request.Index end
	if request.Op == "Drop" or request.Op == "StartRun" or request.Op == "Finish" or request.Op == "CloseRun" then return request.Op end
	return nil
end

local function runTransaction(profile, request)
	local run, failure = currentRun(profile, request)
	local key = requestKey(request)
	if not run then
		local closed = closedRun(profile, request)
		if closed and key and closed.Claims[key] then return replay(closed.Claims[key]) end
		return rejected(failure)
	end
	if key and run.Claims[key] then return replay(run.Claims[key]) end
	local nextProfile = clone(profile)
	local nextRun = nextProfile.ActiveRun
	local receipt
	if request.Op == "StartRun" then
		if run.State ~= "Preparing" then return rejected("InvalidState") end
		nextRun.State = "Hunting"
		receipt = accepted("Started", {RunId = run.Id, RunSerial = run.Serial})
	elseif request.Op == "SyncItems" then
		if run.State == "Preparing" then return rejected("InvalidState") end
		if not sync(nextRun, request) or request.Traps == nil then return rejected("InvalidRemaining") end
		if nextRun.Traps == run.Traps and nextRun.Potions == run.Potions then
			return accepted("Synced", {Traps = run.Traps, Potions = run.Potions, Unchanged = true})
		end
		receipt = accepted("Synced", {Traps = nextRun.Traps, Potions = nextRun.Potions})
	elseif request.Op == "Finish" then
		if run.State ~= "Hunting" then return rejected("InvalidState") end
		if request.Result ~= "Defeated" and request.Result ~= "Captured" and request.Result ~= "Failed" then return rejected("InvalidOutcome") end
		if not sync(nextRun, request) then return rejected("InvalidRemaining") end
		local rewards, capturedSpecimen = {}, nil
		if request.Result == "Captured" then
			if nextRun.InitialTraps - nextRun.Traps < 1 or nextRun.InitialPotions - nextRun.Potions < 1 then return rejected("CaptureItemsMissing") end
			if type(request.Rolls) ~= "table" or #request.Rolls ~= 3 then return rejected("InvalidRolls") end
			if not validSpecimen(request.Specimen, false) or request.Specimen.SourceRunId ~= run.Id
				or request.Specimen.SourceMonsterId ~= run.MonsterId then return rejected("InvalidSpecimen") end
			for specimenId, specimen in profile.OwnedSpecimens do
				if specimenId == request.Specimen.Id or specimen.SourceRunId == run.Id
					or specimen.SourceMonsterId == run.MonsterId then return rejected("DuplicateSpecimen") end
			end
			local available, capacityCode = Rules.canCapture(profile, run.Id, run.Serial)
			if not available then return rejected(capacityCode) end
			for index = 1, 3 do
				local sample = request.Rolls[index]
				if type(sample) ~= "table" or not roll(sample.QuantityRoll) then return rejected("InvalidRolls") end
				local material = typeFor(sample.TypeRoll)
				if not material then return rejected("InvalidRolls") end
				local quantity = if sample.QuantityRoll < 0.5 then 1 else 2
				if not add(nextProfile.Materials, material, quantity) then return rejected("Capacity") end
				table.insert(rewards, {Material = material, Quantity = quantity})
			end
			nextProfile.SpecimenSerial += 1
			capturedSpecimen = clone(request.Specimen)
			capturedSpecimen.Serial = nextProfile.SpecimenSerial
			nextProfile.OwnedSpecimens[capturedSpecimen.Id] = capturedSpecimen
		end
		if request.Result ~= "Failed" then
			if not add(nextProfile.Materials, "Bone", 1) or nextProfile.Coins + C.BonusCoins > C.MaximumCount then return rejected("Capacity") end
			nextProfile.Coins += C.BonusCoins
		end
		nextRun.State = request.Result
		nextRun.Result = request.Result
		receipt = accepted("Finished", {Result = request.Result, Rewards = rewards,
			BonusBone = if request.Result == "Failed" then 0 else 1,
			BonusCoins = if request.Result == "Failed" then 0 else C.BonusCoins,
			SpecimenId = if capturedSpecimen then capturedSpecimen.Id else nil,
			Specimen = if capturedSpecimen then clone(capturedSpecimen) else nil,
			Traps = nextRun.Traps, Potions = nextRun.Potions, RunId = run.Id, RunSerial = run.Serial})
	elseif request.Op == "Ore" or request.Op == "Drop" then
		if run.State ~= "Hunting" and run.State ~= "Defeated" and run.State ~= "Captured" then return rejected("InvalidState") end
		if not key then return rejected("InvalidIndex") end
		local material = if request.Op == "Ore" then "Iron" else "Scale"
		if not add(nextProfile.Materials, material, 1) then return rejected("Capacity") end
		receipt = accepted("PickupGranted", {Material = material, Quantity = 1, Source = key, RunId = run.Id, RunSerial = run.Serial})
	elseif request.Op == "Carve" then
		if run.State ~= "Defeated" then return rejected("InvalidState") end
		if not key or request.Index ~= run.Carves + 1 then return rejected("InvalidIndex") end
		local material = typeFor(request.TypeRoll)
		if not material then return rejected("InvalidRolls") end
		if not add(nextProfile.Materials, material, 1) then return rejected("Capacity") end
		nextRun.Carves += 1
		receipt = accepted("CarveGranted", {Material = material, Quantity = 1, Index = request.Index, RunId = run.Id, RunSerial = run.Serial})
	elseif request.Op == "CloseRun" then
		if request.EntryFailed ~= nil and type(request.EntryFailed) ~= "boolean" then return rejected("InvalidEntryFailure") end
		if request.EntryFailed == true then
			if run.State ~= "Preparing" then return rejected("InvalidState") end
			nextRun.Traps, nextRun.Potions = run.InitialTraps, run.InitialPotions
			nextRun.Result = "EntryFailed"
		else
			if run.State == "Preparing" then return rejected("InvalidState") end
			if not sync(nextRun, request) then return rejected("InvalidRemaining") end
			if run.State == "Hunting" then nextRun.State, nextRun.Result = "Failed", "Failed" end
		end
		if not add(nextProfile.StoredConsumables, "IronTrap", nextRun.Traps)
			or not add(nextProfile.StoredConsumables, "SleepPotion", nextRun.Potions) then return rejected("Capacity") end
		receipt = accepted("Closed", {Result = nextRun.Result, ReturnedTraps = nextRun.Traps,
			ReturnedPotions = nextRun.Potions, RunId = run.Id, RunSerial = run.Serial})
		nextRun.Claims[key] = clone(receipt)
		table.insert(nextProfile.ClosedRuns, {Id = nextRun.Id, Serial = nextRun.Serial, Claims = nextRun.Claims})
		while #nextProfile.ClosedRuns > C.RecentClosedRuns do table.remove(nextProfile.ClosedRuns, 1) end
		nextProfile.ActiveRun = nil
		return commit(profile, nextProfile, receipt)
	else
		return rejected("InvalidOperation")
	end
	if key then nextRun.Claims[key] = clone(receipt) end
	return commit(profile, nextProfile, receipt)
end

local function baseTransaction(profile, request)
	if not serial(request.OperationSerial) then return rejected("InvalidSerial") end
	local cached = profile.OperationReceipts[request.OperationSerial]
	if cached then return replay(cached) end
	if request.OperationSerial ~= profile.OperationSerial + 1 then return rejected("StaleOperation") end
	if profile.ActiveRun then return rejected("ActiveRun") end
	if request.Quantity ~= nil and request.Quantity ~= 1 then return rejected("InvalidQuantity") end
	local nextProfile, receipt = clone(profile)
	if request.Op == "Buy" then
		if request.Item ~= "RawTrap" and request.Item ~= "SleepPotion" then return rejected("InvalidItem") end
		if profile.Coins < C.PurchaseCost then return rejected("InsufficientCoins") end
		if not add(nextProfile.StoredConsumables, request.Item, 1) then return rejected("Capacity") end
		nextProfile.Coins -= C.PurchaseCost
		receipt = accepted("Purchased", {Item = request.Item, Quantity = 1, Cost = C.PurchaseCost})
	elseif request.Op == "CraftTrap" then
		if profile.StoredConsumables.RawTrap < 1 or profile.Materials.Iron < 1 then return rejected("InsufficientMaterials") end
		if not add(nextProfile.StoredConsumables, "IronTrap", 1) then return rejected("Capacity") end
		nextProfile.StoredConsumables.RawTrap -= 1
		nextProfile.Materials.Iron -= 1
		receipt = accepted("Crafted", {Item = "IronTrap", Quantity = 1})
	elseif request.Op == "UpgradeHammer" then
		if profile.HammerLevel ~= 1 then return rejected("MaximumLevel") end
		if profile.Materials.Bone < C.UpgradeBones or profile.Materials.Iron < C.UpgradeIron then return rejected("InsufficientMaterials") end
		nextProfile.Materials.Bone -= C.UpgradeBones
		nextProfile.Materials.Iron -= C.UpgradeIron
		nextProfile.HammerLevel = 2
		receipt = accepted("Upgraded", {HammerLevel = 2, DamageMultiplier = C.HammerMultiplier})
	else
		return rejected("InvalidOperation")
	end
	nextProfile.OperationSerial = request.OperationSerial
	receipt.OperationSerial = request.OperationSerial
	nextProfile.OperationReceipts[request.OperationSerial] = clone(receipt)
	table.insert(nextProfile.OperationOrder, request.OperationSerial)
	while #nextProfile.OperationOrder > C.RecentOperations do
		local oldest = table.remove(nextProfile.OperationOrder, 1)
		nextProfile.OperationReceipts[oldest] = nil
	end
	return commit(profile, nextProfile, receipt)
end

function Rules.apply(profile, request)
	if not validProfile(profile) then return rejected("InvalidProfile") end
	if type(request) ~= "table" or type(request.Op) ~= "string" then return rejected("InvalidRequest") end
	if request.Op == "OpenRun" then
		if not id(request.RunId) or not id(request.MonsterId) or not serial(request.RunSerial) then return rejected("InvalidRun") end
		if profile.ActiveRun and profile.ActiveRun.Id == request.RunId and profile.ActiveRun.Serial == request.RunSerial then
			return replay(profile.ActiveRun.Claims.OpenRun)
		end
		local old = closedRun(profile, request)
		if old and old.Claims.OpenRun then return replay(old.Claims.OpenRun) end
		if profile.ActiveRun then return rejected("ActiveRun") end
		if request.RunSerial ~= profile.RunSerial + 1 then return rejected("StaleRun") end
		local nextProfile = clone(profile)
		local traps = math.min(C.MaxCarried, profile.StoredConsumables.IronTrap)
		local potions = math.min(C.MaxCarried, profile.StoredConsumables.SleepPotion)
		nextProfile.StoredConsumables.IronTrap -= traps
		nextProfile.StoredConsumables.SleepPotion -= potions
		nextProfile.RunSerial = request.RunSerial
		local receipt = accepted("Opened", {RunId = request.RunId, MonsterId = request.MonsterId,
			RunSerial = request.RunSerial, Traps = traps, Potions = potions})
		nextProfile.ActiveRun = {Id = request.RunId, MonsterId = request.MonsterId, Serial = request.RunSerial,
			State = "Preparing", Traps = traps, Potions = potions, InitialTraps = traps, InitialPotions = potions,
			Carves = 0, Claims = {OpenRun = clone(receipt)}}
		return commit(profile, nextProfile, receipt)
	end
	if request.Op == "Buy" or request.Op == "CraftTrap" or request.Op == "UpgradeHammer" then
		return baseTransaction(profile, request)
	end
	return runTransaction(profile, request)
end

function Rules.snapshot(profile)
	if not validProfile(profile) then return nil end
	local active = profile.ActiveRun
	return {DataVersion = profile.DataVersion, Revision = profile.Revision, StarterGranted = profile.StarterGranted,
		StorageMode = "ServerMemory", Coins = profile.Coins, Materials = clone(profile.Materials),
		StoredConsumables = clone(profile.StoredConsumables), HammerLevel = profile.HammerLevel,
		RunSerial = profile.RunSerial, OperationSerial = profile.OperationSerial,
		OwnedSpecimens = clone(profile.OwnedSpecimens), SpecimenSerial = profile.SpecimenSerial,
		SpecimenCount = specimenCount(profile), SpecimenLimit = C.MaxOwnedSpecimens,
		ActiveRun = if active then {Id = active.Id, MonsterId = active.MonsterId, Serial = active.Serial,
			State = active.State, Result = active.Result, Traps = active.Traps, Potions = active.Potions,
			InitialTraps = active.InitialTraps, InitialPotions = active.InitialPotions, Carves = active.Carves} else nil}
end

function Rules.damageMultiplier(profile)
	if not validProfile(profile) then return nil end
	return if profile.HammerLevel == 2 then C.HammerMultiplier else 1
end

return Rules

