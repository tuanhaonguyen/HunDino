-- TEMPORARY Studio Play validation. Never ship or native-save this Script.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local report = {Version = "BioTubePlayQA.1", Ok = false, Checks = 0, Passed = 0, Errors = {}, Slots = {}, Cases = {}}
local player, service, savedDrawn

local function check(condition, message)
	report.Checks += 1
	if condition then report.Passed += 1 else table.insert(report.Errors, message) end
	return condition
end

local function requireCheck(condition, message)
	check(condition, message)
	assert(condition, message)
end

local function waitFor(callback, label)
	local deadline = os.clock() + 70
	repeat
		local result = callback()
		if result then return result end
		task.wait(.1)
	until os.clock() >= deadline
	error("Timed out: " .. label)
end

local function count(container)
	local total = 0
	for _ in container do total += 1 end
	return total
end

local function profile() return service:Profile(player) end

local function apply(request)
	local receipt = service:_apply(player, request)
	requireCheck(receipt and receipt.Ok, "Economy " .. tostring(request.Op) .. " accepted: " .. tostring(receipt and receipt.Code))
	return receipt
end

local function baseOperation(op, item)
	return apply({Op = op, Item = item, OperationSerial = profile().OperationSerial + 1})
end

local function beginRun()
	local serial = profile().RunSerial + 1
	local run = {RunId = "BioTubeQA:Run:" .. serial, RunSerial = serial, MonsterId = "BioTubeQA:Monster:" .. serial}
	apply({Op = "OpenRun", RunId = run.RunId, RunSerial = serial, MonsterId = run.MonsterId})
	apply({Op = "StartRun", RunId = run.RunId, RunSerial = serial})
	return run
end

local function runOperation(run, op, fields)
	local request = table.clone(fields or {})
	request.Op, request.RunId, request.RunSerial = op, run.RunId, run.RunSerial
	return apply(request)
end

local function cluster(baseId)
	return service.BioTubes.World:FindFirstChild("Base" .. tostring(baseId or player:GetAttribute("BaseId")))
end

local function tube(slot, baseId)
	return assert(cluster(baseId):FindFirstChild("BioTube_" .. slot))
end

local function moveToSlot(slot, baseId, offset)
	local target = tube(slot, baseId)
	local origin = target:GetAttribute("StaticOrigin")
	local position = target.Interaction.Position + (offset or Vector3.new(0, 2, 0))
	local look = if typeof(origin) == "CFrame" then origin.Position + Vector3.new(0, 8, 0) else position - Vector3.zAxis
	player.Character:PivotTo(CFrame.lookAt(position, look))
	local state = service.GetState(player)
	state.Root.AssemblyLinearVelocity, state.Root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	task.wait(.22)
	return target
end

local function requestSlot(slot, specimenId)
	task.wait(.16)
	service:Publish(player, nil, "Inventory")
	local offer = assert(service.Offers[player])
	service:Request(player, "SetDisplaySlot", {Slot = slot, SpecimenId = specimenId,
		OperationToken = offer.Token, OperationSerial = profile().OperationSerial + 1})
	task.wait(.05)
end

local function unchangedRequest(label, slot, id)
	local before = profile()
	local revision, serial = before.Revision, before.OperationSerial
	local owned, slots = count(before.OwnedSpecimens), table.clone(before.DisplaySlots)
	requestSlot(slot, id)
	local after = profile()
	local same = after.Revision == revision and after.OperationSerial == serial and count(after.OwnedSpecimens) == owned
	for i = 1, 5 do same = same and after.DisplaySlots[i] == slots[i] end
	check(same, label .. " leaves assignments and ownership unchanged")
	report.Cases[label] = same
end

local ok, exception = xpcall(function()
	requireCheck(RunService:IsStudio(), "Studio-only harness")
	local configModule = assert(ServerScriptService:FindFirstChild("AccountData"))
	local configuration = require(configModule:FindFirstChild("ProfileConfig"))
	requireCheck(configuration.StudioMemoryTest == true or configModule:GetAttribute("StudioMemoryTest") == true, "Explicit Studio memory mode enabled")
	local api = require(ServerScriptService:WaitForChild("HuntingRuntime"):WaitForChild("HuntEconomyService"))
	service = waitFor(function() return api.current() end, "economy service")
	player = waitFor(function() return Players:GetPlayers()[1] end, "local Studio player")
	waitFor(function() return player:GetAttribute("EconomyReady") and service:IsReady(player) and service.GetState(player) end, "loaded economy and real actor")
	requireCheck(service.Persistence and service.Persistence.Mode == "TestMemory", "Persistence literal Mode is TestMemory; no account writes")
	report.StorageMode = service.Persistence.Mode
	player:SetAttribute("BioTubeQAReady", false)
	player:SetAttribute("BioTubeQARunning", true)
	waitFor(function() return service:_quiet(player) end, "quiet player")
	requireCheck(count(profile().OwnedSpecimens) == 0 and profile().ActiveRun == nil, "Fresh disposable memory profile")
	savedDrawn = service.GetState(player).Drawn
	-- Earn ore and money through ordinary transactions. No collection records,
	-- currency or materials are inserted directly into the account.
	local supply = beginRun()
	for index = 1, 6 do runOperation(supply, "Ore", {Index = index}) end
	runOperation(supply, "Finish", {Result = "Defeated", Traps = 0, Potions = 0})
	runOperation(supply, "CloseRun", {Traps = 0, Potions = 0})
	local ids = {}
	for ordinal = 1, 5 do
		baseOperation("Buy", "RawTrap")
		baseOperation("CraftTrap")
		baseOperation("Buy", "SleepPotion")
		local run = beginRun()
		local id = string.format("f20b%04x-2026-4000-8000-%012x", ordinal, ordinal)
		local active = profile().ActiveRun
		local remainingTraps, remainingPotions = active.Traps - 1, active.Potions - 1
		runOperation(run, "Finish", {Result = "Captured", Traps = remainingTraps, Potions = remainingPotions,
			Rolls = {{TypeRoll = .1, QuantityRoll = .1}, {TypeRoll = .5, QuantityRoll = .5}, {TypeRoll = .75, QuantityRoll = .99}},
			Specimen = {Id = id, SpeciesId = "TRex", Name = "T-Rex", Variant = "Normal", Element = "None", SizeScale = 1,
				CapturedAt = DateTime.now().UnixTimestamp, SourceRunId = run.RunId, SourceMonsterId = run.MonsterId}})
		runOperation(run, "CloseRun", {Traps = remainingTraps, Potions = remainingPotions})
		table.insert(ids, id)
	end
	requireCheck(count(profile().OwnedSpecimens) == 5, "Five genuine capture commits own five specimens")
	service:Publish(player)
	for slot = 1, 5 do
		local target = moveToSlot(slot)
		check(service.BioTubes:CanUse(player, slot), "Own tube " .. slot .. " permits quiet nearby actor")
		requestSlot(slot, ids[slot])
		check(profile().DisplaySlots[slot] == ids[slot], "Slot " .. slot .. " assignment accepted")
		local assembly = target:FindFirstChild("SpecimenAssembly")
		requireCheck(assembly ~= nil, "Slot " .. slot .. " has real specimen assembly")
		local beams, pierces, fluid, visible = 0, 0, 0, 0
		for _, object in assembly:GetDescendants() do
			if object:IsA("Beam") then
				beams += 1
				if object:GetAttribute("FluidLine") then fluid += 1 end
				check(object.Attachment0 ~= nil and object.Attachment1 ~= nil, "Slot " .. slot .. " cable endpoints linked: " .. object.Name)
			end
			if object:IsA("Attachment") and object.Name:sub(1, 7) == "Pierce_" then
				pierces += 1
				check(object.Parent:IsA("MeshPart"), "Anatomy attachment uses real mesh: " .. object.Name)
			end
			if object:IsA("BasePart") and object:IsDescendantOf(assembly.Specimen)
				and not object:IsDescendantOf(assembly.Specimen.ImplantSockets) then visible += 1 end
		end
		local sampled = assembly:GetAttribute("SurfaceRaycastCount")
		local radius, height = assembly:GetAttribute("FittedRadius"), assembly:GetAttribute("FittedHeight")
		check(beams == 14 and pierces == 14 and fluid == 4, "Slot " .. slot .. " has 14 implants/cables and four fluid lines")
		check(visible == 255, "Slot " .. slot .. " preserves 255 genuine T-Rex parts")
		check(sampled == 14, "Slot " .. slot .. " samples all 14 actual mesh surfaces")
		check(type(radius) == "number" and radius <= 3.801 and type(height) == "number" and height <= 10.501, "Slot " .. slot .. " fits full rotating footprint")
		local speed = assembly:GetAttribute("AngularSpeedDegrees")
		check(speed == (if slot == 5 then 0 else 10), "Slot " .. slot .. " correct angular speed")
		report.Slots[tostring(slot)] = {Beams = beams, Pierces = pierces, Fluid = fluid, Parts = visible,
			SurfaceRaycasts = sampled, Radius = radius, Height = height, DegreesPerSecond = speed}
	end
	moveToSlot(2)
	requestSlot(2, ids[1])
	check(profile().DisplaySlots[1] == nil and profile().DisplaySlots[2] == ids[1], "Moving specimen atomically frees its prior slot")
	check(count(profile().OwnedSpecimens) == 5, "Move preserves displaced specimen and all five owned IDs")
	local seen = {}
	for _, id in profile().DisplaySlots do check(not seen[id], "No specimen displayed in two tubes"); seen[id] = true end
	for slot = 1, 5 do moveToSlot(slot); requestSlot(slot, false) end
	check(next(profile().DisplaySlots) == nil and count(profile().OwnedSpecimens) == 5, "Clear all slots returns all five specimens to unchanged collection")
	for slot = 1, 5 do check(tube(slot):FindFirstChild("SpecimenAssembly") == nil, "Cleared slot " .. slot .. " removes its visual assembly") end
	moveToSlot(1)
	unchangedRequest("InvalidSpecimen", 1, "ffffffff-0000-4000-8000-ffffffffffff")
	unchangedRequest("MalformedSpecimen", 1, "not-a-guid")
	unchangedRequest("InvalidSlot", 6, ids[1])
	local other = (player:GetAttribute("BaseId") % 12) + 1
	moveToSlot(1, other)
	check(not service.BioTubes:CanUse(player, 1), "Foreign base location cannot authorize own tube")
	unchangedRequest("OtherBase", 1, ids[1])
	check(tube(1, other):FindFirstChild("SpecimenAssembly") == nil, "Other base remains empty")
	moveToSlot(1, nil, Vector3.new(0, 2, 60))
	check(not service.BioTubes:CanUse(player, 1), "Distant actor cannot use tube")
	unchangedRequest("TooFar", 1, ids[1])
	moveToSlot(1)
	service.GetState(player).Drawn = true
	check(not service.BioTubes:CanUse(player, 1), "Drawn weapon prevents tube interaction")
	unchangedRequest("WeaponDrawn", 1, ids[1])
	service.GetState(player).Drawn = savedDrawn
	for slot = 1, 5 do moveToSlot(slot); requestSlot(slot, ids[slot]) end
	for slot = 1, 5 do check(profile().DisplaySlots[slot] == ids[slot] and tube(slot):FindFirstChild("SpecimenAssembly") ~= nil, "Final showcase slot " .. slot .. " populated") end
	check(count(profile().OwnedSpecimens) == 5, "Final showcase preserves exactly five owned specimens")
	moveToSlot(5, nil, Vector3.new(0, 2, 1))
	service:Publish(player)
	report.OwnedSpecimens = count(profile().OwnedSpecimens)
	report.BaseId = player:GetAttribute("BaseId")
	player:SetAttribute("BioTubeQAReady", true)
end, function(err) return debug.traceback(tostring(err), 2) end)

if not ok then table.insert(report.Errors, tostring(exception)) end
if player then
	if service and savedDrawn ~= nil then
		local state = service.GetState(player)
		if state then state.Drawn = savedDrawn end
	end
	player:SetAttribute("BioTubeQARunning", false)
end
report.Ok = ok and #report.Errors == 0
if player then player:SetAttribute("BioTubeQAServerPassed", report.Ok) end
local summary = table.clone(report)
summary.Slots = nil
print("[BioTubeQASummary] " .. HttpService:JSONEncode(summary))
for slot = 1, 5 do
	print("[BioTubeQASlot] " .. HttpService:JSONEncode({Slot = slot, Data = report.Slots[tostring(slot)]}))
end
