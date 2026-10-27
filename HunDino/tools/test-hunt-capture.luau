-- Studio engine harness. Run in Edit/Server after installing P1-D. Only cloned
-- modules, disposable far-away geometry and adapter-owned quest data are used.
local HttpService = game:GetService("HttpService")
local runtime = assert(game:GetService("ServerScriptService"):FindFirstChild("HuntingRuntime"), "HuntingRuntime missing")
local source = assert(runtime:FindFirstChild("HuntCaptureController"), "Capture controller missing")
local rulesSource = assert(runtime:FindFirstChild("HuntQuestRules"), "Quest rules missing")
local report = {version = "HuntCaptureIntegration.2", ok = false, checks = 0, passed = 0, failures = {}, skipped = {},
	boundary = "Real controller/rules/Instance/Humanoid/raycast/overlap; fake owner attributes and dinosaur sink. No production player or dinosaur mutation."}
local function check(condition, message)
	report.checks += 1
	if condition then report.passed += 1 else table.insert(report.failures, message) end
end
local function near(a, b) return type(a) == "number" and type(b) == "number" and math.abs(a - b) < .001 end
local UP = Vector3.new(0, 1, 0)
local container = Instance.new("Folder")
container.Name = "HuntCaptureIntegration_" .. HttpService:GenerateGUID(false)
container.Parent = workspace
local clone = source:Clone(); clone.Parent = container
local rulesClone = rulesSource:Clone(); rulesClone.Parent = container
local Controller, Rules
local cases = {}
local started = workspace:GetServerTimeNow()
local originalControllerSource, originalRulesSource = source.Source, rulesSource.Source

local function part(parent, name, position, size, collidable)
	local item = Instance.new("Part")
	item.Name = name; item.Position = position; item.Size = size
	item.Anchored = true; item.CanCollide = collidable; item.CanQuery = collidable
	item.CanTouch = false; item.Transparency = 1; item.Parent = parent
	return item
end
local function makeCharacter(parent, position)
	local character = Instance.new("Model"); character.Name = "Owner"; character.Parent = parent
	local root = part(character, "HumanoidRootPart", position, Vector3.new(2, 2, 1), false)
	character.PrimaryPart = root
	local humanoid = Instance.new("Humanoid"); humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false; humanoid.MaxHealth = 100; humanoid.Health = 100
	humanoid.HipHeight = 2; humanoid.Parent = character
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	humanoid:ChangeState(Enum.HumanoidStateType.Running)
	return character, humanoid, root
end
local function fixture(name, withCapacityGate)
	local index = #cases + 1
	local f = {Now = started + index * 100, Active = true, Captured = 0, Messages = {}, CapacityAllowed = true, CapacityChecks = 0}
	table.insert(cases, f)
	f.Folder = Instance.new("Folder"); f.Folder.Name = name; f.Folder.Parent = container
	f.Origin = Vector3.new(24000 + index * 240, 500, 24000)
	f.Floor = part(f.Folder, "Floor", f.Origin - UP, Vector3.new(180, 2, 180), true)
	f.Forest = Instance.new("Model"); f.Forest.Name = "TestForest"; f.Forest.Parent = f.Folder
	f.Forest:SetAttribute("WorldOffset", f.Origin)
	f.Forest:SetAttribute("MapWidth", 4000); f.Forest:SetAttribute("MapDepth", 4500)
	local zones = Instance.new("Folder"); zones.Name = "Zones"; zones.Parent = f.Forest
	local camp = Instance.new("Model"); camp.Name = "Camp"; camp.Parent = zones
	f.Camp = part(camp, "Node", f.Origin + Vector3.new(1200, 0, 0), Vector3.one, false)
	f.Character, f.Humanoid, f.Root = makeCharacter(f.Folder, f.Origin + UP * 3)
	f.Attributes = {InHunting = true}
	f.Player = {Parent = f.Folder, UserId = -index}
	function f.Player:GetAttribute(key) return f.Attributes[key] end
	function f.Player:SetAttribute(key, value) f.Attributes[key] = value end
	f.Pets = Instance.new("Folder"); f.Pets.Name = "Pets"; f.Pets.Parent = f.Folder
	f.Combat = {Health = 1200, MaxHealth = 1200, Support = f.Origin + Vector3.new(0, 0, -90),
		Mouth = f.Origin + Vector3.new(0, 2.5, -25), TrapCalls = 0, ReleaseCalls = 0}
	f.Combat.Model = Instance.new("Model"); f.Combat.Model.Name = "DinosaurSink"; f.Combat.Model.Parent = f.Folder
	function f.Combat:GetSnapshot() return {Health = self.Health, MaxHealth = self.MaxHealth} end
	function f.Combat:GetSupportPoint() return self.Support end
	function f.Combat:GetCapturePoint() return self.Mouth end
	function f.Combat:TrapFor(runId, untilTime)
		self.TrapCalls += 1
		if self.RejectTrap or self.Owner or self.Health <= 0 then return false end
		self.Owner, self.HeldUntil = runId, untilTime
		return true
	end
	function f.Combat:ReleaseTrap(runId)
		if self.Owner ~= runId then return false end
		self.ReleaseCalls += 1; self.Owner, self.HeldUntil = nil, nil
		return true
	end
	f.Run = assert(Rules.new("capture-test-" .. index, "monster-test-" .. index, f.Now))
	assert(Rules.start(f.Run, f.Now))
	local options = {Player = f.Player, Run = f.Run, Rules = Rules, Combat = f.Combat,
		Forest = f.Forest, PetFolder = f.Pets, Character = function() return f.Character end,
		CanUseItems = function() return f.Active end,
		OnCapture = function() f.Captured += 1 end,
		OnMessage = function(text) table.insert(f.Messages, text) end}
	-- Older fixtures deliberately omit the optional gate to retain regression
	-- coverage for adapters that have no specimen collection yet.
	if withCapacityGate then
		options.CanCapture = function()
			f.CapacityChecks += 1
			return f.CapacityAllowed, "SpecimenCapacity"
		end
	end
	f.Controller = Controller.new(options)
	return f
end
local function step(f, now)
	Rules.tick(f.Run, now)
	f.Controller:Step(now, .02)
end
local function place(f)
	assert(f.Controller:RequestPlace(f.Now))
	step(f, f.Now + 1)
	assert(f.Run.ActiveTrap, "Fixture could not place trap")
	return f.Controller:GetSnapshot().TrapPoint
end
local function hold(f)
	local point = place(f)
	f.Combat.Support = point
	step(f, f.Now + 1.1)
	assert(f.Run.ActiveTrap and f.Run.ActiveTrap.State == "Holding", "Fixture could not trigger trap")
	f.Combat.Mouth = point + Vector3.new(0, 2.5, -3)
	f.Root.Position = f.Combat.Mouth + UP * .5
	f.Combat.Health = 120
	return f.Now + 1.2
end

local ok, exception = xpcall(function()
	Controller, Rules = require(clone), require(rulesClone)
	do
		local f = fixture("PlaceClockAndExpiry")
		check(f.Controller:RequestPlace(f.Now), "Valid ground starts placement")
		check(f.Run.Traps == 3 and f.Run.Action.Kind == "Place", "Starting placement consumes nothing")
		step(f, f.Now + .99)
		check(f.Run.Traps == 3 and f.Run.ActiveTrap == nil, "Placement cannot finish before 1 second")
		step(f, f.Now + 1)
		local trap, snapshot = f.Run.ActiveTrap, f.Controller:GetSnapshot()
		check(trap ~= nil and f.Run.Traps == 2 and f.Run.Action == nil, "Exactly 1 second creates one trap and spends one item")
		check(trap.State == "Waiting" and near(trap.ExpiresAt, f.Now + 61), "Waiting trap lives for exactly 60 seconds after completion")
		check(typeof(snapshot.TrapPoint) == "Vector3" and (snapshot.TrapPoint - f.Root.Position).Magnitude < 6, "Trap position comes from nearby real ground")
		check(f.Controller._trapModel and #f.Controller._trapModel:GetChildren() == 33, "Visible iron ring and trigger plate exist")
		check(f.Controller._trapModel:GetAttribute("QuestRunId") == f.Run.Id and f.Controller._trapModel:GetAttribute("TrapId") == trap.Id, "Physical trap is bound to owner run and rule trap ID")
		step(f, f.Now + 1.5)
		check(f.Run.Traps == 2 and f.Combat.TrapCalls == 0, "Repeated Step neither spends twice nor triggers a distant target")
		local accepted, reason = f.Controller:RequestPlace(f.Now + 2)
		check(not accepted and reason == "TrapActive" and f.Run.Traps == 2, "Existing waiting trap prevents another placement")
		step(f, trap.ExpiresAt)
		check(f.Run.ActiveTrap ~= nil, "Waiting trap accepts its exact endpoint")
		step(f, trap.ExpiresAt + .001)
		check(f.Run.ActiveTrap == nil and f.Controller._trapModel == nil and f.Run.Traps == 2, "Expired waiting trap is removed without refund")
	end
	do
		local f = fixture("PlacementCancel")
		assert(f.Controller:RequestPlace(f.Now)); f.Controller:Cancel("KeyRelease")
		step(f, f.Now + 2)
		check(f.Run.Action == nil and f.Run.Traps == 3 and f.Run.ActiveTrap == nil, "Release before placement finish consumes no trap")
		check(f.Controller._preview == nil, "Cancel removes placement preview")
		assert(f.Controller:RequestPlace(f.Now + 2))
		step(f, f.Now + 2.99)
		check(f.Run.Traps == 3, "Restarted placement requires a new full second")
		step(f, f.Now + 3)
		check(f.Run.Traps == 2, "Restarted placement commits once")
	end
	do
		local f = fixture("PlaceMovedOrDamaged")
		assert(f.Controller:RequestPlace(f.Now)); f.Root.Position += Vector3.new(1.7, 0, 0)
		step(f, f.Now + .5)
		check(f.Run.Action == nil and f.Run.Traps == 3, "Moving beyond 1.6 studs cancels placement")
		assert(f.Controller:RequestPlace(f.Now + 1)); f.Humanoid.Health -= 1
		step(f, f.Now + 1.5)
		check(f.Run.Action == nil and f.Run.Traps == 3, "Damage cancels placement without item loss")
	end
	do
		local f = fixture("MissingFloor")
		f.Floor:Destroy()
		local accepted, reason = f.Controller:RequestPlace(f.Now)
		check(not accepted and reason == "InvalidGround" and f.Run.Traps == 3, "Placement over missing floor is refused")
	end
	do
		local f = fixture("WallInsideFootprint")
		part(f.Folder, "Wall", f.Origin + Vector3.new(3, 1.5, -4.25), Vector3.new(1, 3, 1), true)
		check(not f.Controller:RequestPlace(f.Now) and f.Run.Traps == 3, "A colliding wall within trap footprint is refused")
	end
	do
		local f = fixture("FootprintOverGap")
		f.Floor.Size = Vector3.new(6, 2, 180)
		check(not f.Controller:RequestPlace(f.Now) and f.Run.Traps == 3, "Trap centre support does not excuse unsupported outer ring")
	end
	do
		local f = fixture("ChangedGroundAtCommit")
		assert(f.Controller:RequestPlace(f.Now))
		part(f.Folder, "NewWall", f.Origin + Vector3.new(3, 1.5, -4.25), Vector3.new(1, 3, 1), true)
		step(f, f.Now + 1)
		check(f.Run.Traps == 3 and f.Run.ActiveTrap == nil and f.Run.Action == nil, "Ground and footprint are rechecked at completion")
	end
	do
		local f = fixture("MapAndCampBoundary")
		f.Camp.Position = f.Origin
		check(not f.Controller:RequestPlace(f.Now), "Camp safety radius rejects trap placement")
		f.Camp.Position = f.Origin + Vector3.new(1200, 0, 0)
		f.Forest:SetAttribute("MapWidth", 6)
		check(not f.Controller:RequestPlace(f.Now) and f.Run.Traps == 3, "Whole footprint must stay within map boundary")
	end
	do
		-- Read an existing lake surface. Terrain is never edited by this harness.
		local actualForest = workspace:FindFirstChild("DinosaurHuntingRainforest")
		local offset = actualForest and actualForest:GetAttribute("WorldOffset")
		local water
		if typeof(offset) == "Vector3" then
			local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {container}; params.IgnoreWater = false; params.RespectCanCollide = true
			for _, point in {Vector3.new(-100, 0, 100), Vector3.new(100, 0, -60), Vector3.new(300, 0, 100), Vector3.new(100, 0, 280), Vector3.new(-120, 0, -60)} do
				local hit = workspace:Raycast(offset + point + UP * 1000, -UP * 1800, params)
				if hit and hit.Material == Enum.Material.Water then water = hit.Position; break end
			end
		end
		if water then
			local f = fixture("ExistingLakeReadOnly")
			f.Forest:SetAttribute("WorldOffset", offset)
			f.Root.Position = water + Vector3.new(0, 3, 4.25)
			check(not f.Controller:RequestPlace(f.Now) and f.Run.Traps == 3, "Existing real lake water is refused without spending a trap; Terrain remains read-only")
		else table.insert(report.skipped, "Native water case skipped: no unobstructed existing lake sample found; Terrain is never modified.") end
	end
	do
		local f = fixture("HealthyTargetAndHoldClock")
		local point = place(f)
		f.Combat.Support = point; step(f, f.Now + 1.1)
		local trap = f.Run.ActiveTrap
		check(trap.State == "Holding" and f.Combat.Owner == f.Run.Id, "A healthy dinosaur can trigger the trap")
		check(near(trap.HeldUntil - trap.TriggeredAt, 13), "Physical hold receives exactly 13 seconds")
		f.Combat.Mouth = point + Vector3.new(0, 2.5, -3); f.Root.Position = f.Combat.Mouth + UP * .5
		local accepted, reason = f.Controller:RequestCapture(f.Now + 1.2)
		check(not accepted and reason == "NotWeak" and f.Run.Potions == 3, "Healthy trapped target cannot be given sleeping potion")
		step(f, f.Now + 2)
		check(f.Combat.TrapCalls == 1 and near(f.Run.ActiveTrap.HeldUntil, trap.HeldUntil), "Standing over trap never refreshes the hold")
		step(f, trap.HeldUntil)
		check(f.Run.ActiveTrap ~= nil and f.Combat.Owner ~= nil, "Holding trap accepts its exact endpoint")
		step(f, trap.HeldUntil + .001)
		check(f.Run.ActiveTrap == nil and f.Combat.Owner == nil and f.Combat.ReleaseCalls == 1, "Trap escape releases dinosaur once")
		check(f.Controller._trapModel == nil and f.Controller._mouthMarker == nil, "Expired hold cleans up ring and mouth marker")
	end
	do
		local f = fixture("TriggerDistanceAndHeight")
		local point = place(f)
		f.Combat.Support = point + Vector3.new(10.1, 0, 0); step(f, f.Now + 1.1)
		check(f.Run.ActiveTrap.State == "Waiting", "Target outside 10 studs does not trigger trap")
		f.Combat.Support = point + Vector3.new(8, 5.1, 0); step(f, f.Now + 1.2)
		check(f.Run.ActiveTrap.State == "Waiting", "Target on another height does not trigger through a floor")
		f.Combat.Support = point + Vector3.new(8, 4.9, 0); step(f, f.Now + 1.3)
		check(f.Run.ActiveTrap.State == "Holding", "Real support point within trigger radius activates trap")
	end
	do
		local f = fixture("CaptureClockAndOnce")
		local now = hold(f)
		check(f.Controller:RequestCapture(now), "Alive target exactly at 10 percent starts capture")
		check(f.Run.Potions == 3 and f.Attributes.HuntCaptureActive == true, "Capture start pauses pet and consumes no potion")
		check(near(f.Run.Action.FinishAt - now, 3), "Potion action lasts exactly 3 seconds")
		step(f, now + 2.99)
		check(f.Run.State == "Hunting" and f.Run.Potions == 3 and f.Captured == 0, "Capture cannot complete early")
		step(f, now + 3)
		check(f.Run.State == "Harvest" and f.Run.Result == "Captured" and f.Run.Potions == 2, "Capture commits final result and one potion atomically")
		check(f.Captured == 1 and f.Attributes.HuntCaptureActive == false, "Capture callback runs once and resumes pet state")
		check(f.Combat.Owner == nil and f.Controller._trapModel == nil, "Capture disposes spent trap")
		step(f, now + 3.1); f.Controller:RequestCapture(now + 4)
		check(f.Captured == 1 and f.Run.Potions == 2, "Repeated completion requests cannot duplicate capture or consumption")
	end
	do
		local f = fixture("WeakHealthRevalidation")
		local now = hold(f)
		f.Combat.Health = 120.01
		local accepted, reason = f.Controller:RequestCapture(now)
		check(not accepted and reason == "NotWeak", "Just above 10 percent is refused")
		f.Combat.Health = 0
		accepted, reason = f.Controller:RequestCapture(now)
		check(not accepted and reason == "InvalidHealth" and f.Run.Potions == 3, "Dead target is refused even while trapped")
		f.Combat.Health = 120; assert(f.Controller:RequestCapture(now))
		f.Combat.Health = 121; step(f, now + 1)
		check(f.Run.Action == nil and f.Run.Potions == 3, "Recovering above capture threshold interrupts pending drink")
	end
	do
		local f = fixture("SpecimenCapacityBeforeDrink", true)
		local now = hold(f)
		f.CapacityAllowed = false
		step(f, now)
		local heldUntil = f.Run.ActiveTrap.HeldUntil
		local accepted, reason = f.Controller:RequestCapture(now)
		check(not accepted and reason == "SpecimenCapacity", "Full specimen collection refuses capture before the drink starts")
		check(f.Run.State == "Hunting" and f.Run.Result == nil and f.Run.Action == nil, "Capacity rejection does not finish or fail the normal hunt")
		check(f.Run.Potions == 3 and f.Captured == 0, "Capacity rejection spends no potion and grants no specimen")
		check(f.Run.ActiveTrap.State == "Holding" and near(f.Run.ActiveTrap.HeldUntil, heldUntil) and f.Combat.Owner == f.Run.Id, "Capacity rejection preserves the existing physical trap hold and deadline")
		check(f.Attributes.HuntCaptureAvailable == false and f.Controller:GetSnapshot().CaptureAvailable == false, "Full collection hides capture availability")
		check(f.Attributes.HuntCaptureActive == false, "Rejected full collection does not pause the pet")
		check(#f.Messages > 0 and f.Messages[#f.Messages]:find("đầy", 1, true) ~= nil, "Full collection sends an understandable capacity message")
	end
	do
		local f = fixture("SpecimenCapacityLostDuringDrink", true)
		local now = hold(f)
		step(f, now)
		check(f.Attributes.HuntCaptureAvailable == true, "Available collection allows the mouth interaction hint")
		assert(f.Controller:RequestCapture(now))
		local heldUntil = f.Run.ActiveTrap.HeldUntil
		step(f, now + 1)
		check(f.Run.Action ~= nil and f.Attributes.HuntCaptureActive == true, "Capacity remains valid during the first drink second")
		f.CapacityAllowed = false
		step(f, now + 1.5)
		check(f.Run.Action == nil and f.Attributes.HuntCaptureActive == false, "Losing collection capacity cancels a running drink immediately")
		check(f.Run.State == "Hunting" and f.Run.Result == nil and f.Run.Potions == 3 and f.Captured == 0, "Mid-drink capacity loss keeps the hunt and potion unchanged")
		check(f.Run.ActiveTrap.State == "Holding" and near(f.Run.ActiveTrap.HeldUntil, heldUntil) and f.Combat.Owner == f.Run.Id, "Mid-drink capacity loss leaves the original trap timer running")
		check(f.Attributes.HuntCaptureAvailable == false, "Mid-drink capacity loss removes the interaction hint")
		check(#f.Messages > 0 and f.Messages[#f.Messages]:find("đầy", 1, true) ~= nil, "Interrupted drink explains the full collection")
		step(f, now + 3)
		check(f.Run.Potions == 3 and f.Captured == 0 and f.Run.Result == nil, "Old drink completion cannot award a specimen after capacity cancellation")
	end
	do
		local f = fixture("SpecimenCapacityLostAtCommit", true)
		local now = hold(f)
		assert(f.Controller:RequestCapture(now))
		step(f, now + 2.99)
		check(f.Run.Action ~= nil and f.Run.Potions == 3, "Capacity-gated drink waits for all three seconds")
		f.CapacityAllowed = false
		step(f, now + 3)
		check(f.Run.State == "Hunting" and f.Run.Result == nil and f.Run.Action == nil, "Capacity is checked again at the exact capture commit")
		check(f.Run.Potions == 3 and f.Captured == 0 and f.Attributes.HuntCaptureActive == false, "Final capacity failure commits neither potion nor capture and resumes pet")
		check(f.Run.ActiveTrap and f.Run.ActiveTrap.State == "Holding" and f.Combat.Owner == f.Run.Id, "Final capacity failure preserves the remaining trap hold")
		check(f.Attributes.HuntCaptureAvailable == false and f.CapacityChecks > 1, "Availability and completion both consult the server capacity gate")
	end
	do
		local f = fixture("NoItems")
		f.Run.Traps = 0
		local accepted, reason = f.Controller:RequestPlace(f.Now)
		check(not accepted and reason == "NoTraps" and f.Run.State == "Hunting", "No traps does not fail a normal hunt")
		f.Run.Traps = 3; local now = hold(f); f.Run.Potions = 0
		accepted, reason = f.Controller:RequestCapture(now)
		check(not accepted and reason == "NoPotions" and f.Run.State == "Hunting", "No potions does not fail a normal hunt")
	end
	do
		local f = fixture("CancelAndRestartDrink")
		local now = hold(f)
		assert(f.Controller:RequestCapture(now)); local heldUntil = f.Run.ActiveTrap.HeldUntil
		f.Controller:Cancel("KeyRelease")
		check(f.Run.Action == nil and f.Run.Potions == 3 and near(f.Run.ActiveTrap.HeldUntil, heldUntil), "Releasing drink keeps potion and original trap timer")
		check(f.Attributes.HuntCaptureActive == false, "Cancel clears pet capture pause")
		assert(f.Controller:RequestCapture(now + .4)); step(f, now + 3.1)
		check(f.Run.Potions == 3 and f.Captured == 0, "Restarted drink cannot reuse old elapsed hold")
		step(f, now + 3.4)
		check(f.Run.Potions == 2 and f.Captured == 1, "Restarted drink requires its own complete 3 seconds")
	end
	do
		local f = fixture("MoveOutOfMouthRange")
		local now = hold(f); assert(f.Controller:RequestCapture(now))
		f.Root.Position = f.Combat.Mouth + Vector3.new(4.1, .5, 0); step(f, now + .2)
		check(f.Run.Action == nil and f.Run.Potions == 3 and f.Captured == 0, "Moving beyond 4 studs cancels drink without potion loss")
	end
	do
		local f = fixture("DamageDrink")
		local now = hold(f); assert(f.Controller:RequestCapture(now))
		f.Humanoid.Health -= 1; step(f, now + .2)
		check(f.Run.Action == nil and f.Run.Potions == 3 and f.Captured == 0, "Taking damage interrupts drink without potion loss")
		check(f.Run.ActiveTrap.State == "Holding" and f.Attributes.HuntCaptureActive == false, "Damage cancellation leaves remaining trap hold intact")
	end
	do
		local f = fixture("DrawDodgeOrTravelGate")
		local now = hold(f); assert(f.Controller:RequestCapture(now))
		f.Active = false; step(f, now + .2)
		check(f.Run.Action == nil and f.Run.Potions == 3 and f.Captured == 0, "Drawing, dodging or travel gate cancels active drink")
		check(not f.Controller:RequestPlace(now + 1) and not f.Controller:RequestCapture(now + 1), "Item gate rejects new actions too")
	end
	do
		local f = fixture("AdminFlightInterrupt")
		local now = hold(f); assert(f.Controller:RequestCapture(now))
		f.Attributes.AdminFlying = true; step(f, now + .2)
		check(f.Run.Action == nil and f.Run.Potions == 3 and f.Captured == 0, "Admin flight interrupts capture")
	end
	do
		local f = fixture("CharacterReplacement")
		local now = hold(f); assert(f.Controller:RequestCapture(now))
		f.Character, f.Humanoid, f.Root = makeCharacter(f.Folder, f.Combat.Mouth + UP * .5)
		step(f, now + .2)
		check(f.Run.Action == nil and f.Run.Potions == 3 and f.Captured == 0, "Respawn replacement cannot inherit old character's cast")
	end
	do
		local f = fixture("DeathInterrupt")
		local now = hold(f); assert(f.Controller:RequestCapture(now))
		f.Humanoid.Health = 0; step(f, now + .2)
		check(f.Run.Action == nil and f.Run.Potions == 3 and f.Captured == 0, "Death cancels drink without consuming potion")
	end
	do
		local f = fixture("HoldExpiresBeforeDrink")
		hold(f)
		local untilTime = f.Run.ActiveTrap.HeldUntil
		assert(f.Controller:RequestCapture(untilTime - 2))
		step(f, untilTime + .001)
		check(f.Run.ActiveTrap == nil and f.Run.Action == nil and f.Run.Potions == 3 and f.Captured == 0, "Trap expiring before third drink second cancels capture")
		check(f.Combat.Owner == nil and f.Combat.ReleaseCalls == 1, "Expired in-progress drink releases dinosaur")
	end
	do
		local f = fixture("KilledDuringCapture")
		local now = hold(f); assert(f.Controller:RequestCapture(now))
		f.Combat.Health = 0; step(f, now + 3)
		check(f.Run.Potions == 3 and f.Captured == 0 and f.Run.Action == nil, "Final HP check prevents capturing a newly dead target")
		assert(Rules.finish(f.Run, "Defeated", now + 3)); step(f, now + 3)
		check(f.Run.Result == "Defeated" and f.Captured == 0 and f.Run.Potions == 3, "Defeat result wins without also granting capture")
	end
	do
		local f = fixture("NoGhostPhysicalTrap")
		local point = place(f); f.Combat.RejectTrap = true; f.Combat.Support = point
		step(f, f.Now + 1.1)
		check(f.Run.ActiveTrap == nil and f.Controller._trapModel == nil and f.Run.Traps == 2, "Physical trap rejection leaves no fictitious capturable hold or refund")
	end
	do
		local f = fixture("CaptureLineOfSight")
		local now = hold(f)
		f.Root.Position = f.Combat.Mouth + Vector3.new(3, .5, 0)
		part(f.Folder, "MouthWall", f.Combat.Mouth + Vector3.new(1.5, .8, 0), Vector3.new(.4, 3, 3), true)
		local accepted, reason = f.Controller:RequestCapture(now)
		check(not accepted and reason == "Obstructed" and f.Run.Potions == 3, "Cannot administer potion through a real colliding wall")
	end
	check(source.Source == originalControllerSource and rulesSource.Source == originalRulesSource, "Production module sources are unchanged by tests")
end, function(value) return debug.traceback(tostring(value), 2) end)

if not ok then table.insert(report.failures, "Harness exception: " .. tostring(exception)) end
for _, f in cases do
	local name = if f.Folder then f.Folder.Name else "IncompleteFixture"
	local cleaned, message = pcall(function() if f.Controller then f.Controller:Destroy(); f.Controller:Destroy() end end)
	check(cleaned, "Controller Destroy is idempotent: " .. name .. (if cleaned then "" else " / " .. tostring(message)))
	check(not f.Attributes or f.Attributes.HuntCaptureActive == false, "Destroy clears pet pause: " .. name)
	check(not f.Combat or f.Combat.Owner == nil, "Destroy releases owned dinosaur hold: " .. name)
	check(not f.Controller or f.Controller._folder.Parent == nil, "Destroy removes runtime item folder: " .. name)
end
container:Destroy()
check(container.Parent == nil, "All disposable fixture geometry and cloned modules are removed")
report.ok = ok and #report.failures == 0
report.cases = #cases
report.elapsed = workspace:GetServerTimeNow() - started
return report
