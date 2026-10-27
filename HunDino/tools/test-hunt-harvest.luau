-- Native engine integration harness; cloned production module, real Humanoids,
-- rays, overlap queries and disposable geometry. No production player, dinosaur,
-- economy or Terrain writes. Inventory is an idempotent in-memory test adapter.
local HttpService = game:GetService("HttpService")
local runtime = assert(game:GetService("ServerScriptService"):FindFirstChild("HuntingRuntime"), "HuntingRuntime missing")
local source = assert(runtime:FindFirstChild("HuntHarvestController"), "HuntHarvestController missing")
local originalSource = source.Source
local report = {version = "HuntHarvestIntegration.1", ok = false, checks = 0, passed = 0, failures = {}, skipped = {},
	boundary = "Cloned production controller, native Humanoid/raycast/overlap/Instance; fake owner and idempotent inventory. No production source, player, dinosaur or Terrain mutation."}
local function check(value, text)
	report.checks += 1
	if value then report.passed += 1 else table.insert(report.failures, text) end
end
local function near(a, b) return type(a) == "number" and type(b) == "number" and math.abs(a - b) < .002 end
local UP, cases = Vector3.yAxis, {}
local started = workspace:GetServerTimeNow()
local container = Instance.new("Folder"); container.Name = "HuntHarvestIntegration_" .. HttpService:GenerateGUID(false); container.Parent = workspace
local clone = source:Clone(); clone.Parent = container
local Controller
local function makePart(parent, name, point, size, collision)
	local p = Instance.new("Part"); p.Name = name; p.Position = point; p.Size = size
	p.Anchored = true; p.CanCollide = collision; p.CanTouch = false; p.CanQuery = collision
	p.Transparency = 1; p.Parent = parent; return p
end
local function fixture(name)
	local index = #cases + 1
	local f = {Now = started + index * 100, Active = true, Transactions = {}, Grants = {}, Quantity = {Ore = 0, Drop = 0, Carve = 0}, Messages = {}}
	table.insert(cases, f)
	f.Folder = Instance.new("Folder"); f.Folder.Name = name; f.Folder.Parent = container
	f.Origin = Vector3.new(30000 + index * 1300, 500, 30000)
	f.Forest = Instance.new("Model"); f.Forest.Name = "TestForest"; f.Forest.Parent = f.Folder
	f.Forest:SetAttribute("WorldOffset", f.Origin); f.Forest:SetAttribute("MapWidth", 4000); f.Forest:SetAttribute("MapDepth", 4500); f.Forest:SetAttribute("CampSafeRadius", 250)
	f.Paths = Instance.new("Folder"); f.Paths.Name = "Paths"; f.Paths.Parent = f.Forest
	f.Floor = makePart(f.Paths, "Ground", f.Origin - UP, Vector3.new(1000, 2, 1000), true)
	local zones = Instance.new("Folder"); zones.Name = "Zones"; zones.Parent = f.Forest
	local camp = Instance.new("Model"); camp.Name = "Camp"; camp.Parent = zones
	f.Camp = makePart(camp, "Node", f.Origin, Vector3.one, false)
	f.Character = Instance.new("Model"); f.Character.Name = "TestOwner"; f.Character.Parent = f.Folder
	f.Root = makePart(f.Character, "HumanoidRootPart", f.Origin + Vector3.new(0, 3, 65), Vector3.new(2, 2, 1), false); f.Character.PrimaryPart = f.Root
	f.Humanoid = Instance.new("Humanoid"); f.Humanoid.RequiresNeck = false; f.Humanoid.BreakJointsOnDeath = false
	f.Humanoid.MaxHealth = 100; f.Humanoid.Health = 100; f.Humanoid.HipHeight = 2; f.Humanoid.Parent = f.Character
	f.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false); f.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	f.Attributes = {}
	f.Player = {Parent = f.Folder, UserId = -1000 - index}
	function f.Player:GetAttribute(key) return f.Attributes[key] end
	function f.Player:SetAttribute(key, value) f.Attributes[key] = value end
	f.Combat = {Health = 1200, MaxHealth = 1200, Support = f.Origin + Vector3.new(0, 0, 65)}
	f.Combat.Model = Instance.new("Model"); f.Combat.Model.Name = "DinosaurSink"; f.Combat.Model.Parent = f.Folder
	local boxes = Instance.new("Folder"); boxes.Name = "CombatHitboxes"; boxes.Parent = f.Combat.Model
	makePart(boxes, "LeftLegHurtbox", f.Combat.Support + Vector3.new(-5, 4, 0), Vector3.new(3, 8, 4), false)
	makePart(boxes, "RightLegHurtbox", f.Combat.Support + Vector3.new(5, 4, 0), Vector3.new(3, 8, 4), false)
	makePart(boxes, "BodyHurtbox", f.Combat.Support + UP * 13, Vector3.new(15, 10, 18), false)
	function f.Combat:GetSnapshot() return {Health = self.Health, MaxHealth = self.MaxHealth} end
	function f.Combat:GetSupportPoint() return self.Support end
	f.Run = {Id = "harvest-run-" .. index, MonsterId = "harvest-monster-" .. index, State = "Hunting", Deadline = f.Now + 2400}
	f.Grant = function(kind, sourceId, claimIndex)
		if f.RejectGrant then return false, "AdapterUnavailable" end
		if f.ErrorGrant then error("Deliberate adapter failure") end
		local key = kind .. ":" .. sourceId .. ":" .. claimIndex
		if f.Transactions[key] then return true, f.Transactions[key] end
		local result = {Kind = kind, SourceId = sourceId, Index = claimIndex}
		f.Transactions[key] = result; table.insert(f.Grants, result); f.Quantity[kind] += 1
		return true, result
	end
	f.Options = {Player = f.Player, Run = f.Run, Combat = f.Combat, Forest = f.Forest,
		Character = function() return f.Character end, CanInteract = function() return f.Active end,
		Grant = f.Grant, OnMessage = function(text) table.insert(f.Messages, text) end}
	f.Controller = Controller.new(f.Options)
	return f
end
local function defeat(f)
	f.Combat.Health = 0; f.Run.State = "Harvest"; f.Run.Result = "Defeated"; f.Run.HarvestUntil = f.Now + 120
	f.Controller:Step(f.Now, .02)
end
local function moveTo(f, point) f.Root.Position = point + UP * 3 end
local function pickup(f, node, now) return f.Controller:_pickup(node, f.Player, now or f.Now) end
local function drop(f)
	f.Combat.Health = 600; f.Controller:ObserveDamage(1200, 600)
	for _, node in f.Controller._nodes do if node.Kind == "Drop" then return node end end
end
local ok, exception = xpcall(function()
	Controller = require(clone)
	do
		local f = fixture("SixGroundedOre")
		local nodes = f.Controller:GetSnapshot().Resources
		check(#nodes == 6 and f.Attributes.HuntOreRemaining == 6, "Exactly six ore nodes are created")
		local ids = {}
		for index, node in nodes do
			check(node.Kind == "Ore" and node.Index == index and node.Id == f.Run.Id .. ":Ore:" .. index, "Ore IDs and indexes are stable server-derived values " .. index)
			check(not ids[node.Id], "Ore source ID is unique " .. index); ids[node.Id] = true
			check(near(node.Point.Y, f.Origin.Y) and (node.Point - f.Camp.Position).Magnitude > 270, "Ore rests on ground outside Camp " .. index)
			local record = f.Controller._nodes[index]
			check(record.Model:GetAttribute("OwnerUserId") == f.Player.UserId and record.Model:GetAttribute("QuestRunId") == f.Run.Id, "World resource is bound to run owner " .. index)
			check(record.Prompt.KeyboardKeyCode == Enum.KeyCode.G and record.Prompt.RequiresLineOfSight, "G pickup prompt uses LOS " .. index)
		end
		check(#f.Grants == 0, "Creating ore does not grant inventory")
		for _, node in f.Controller._nodes do moveTo(f, node.Point); check(pickup(f, node), "Owner can collect grounded ore " .. node.Index) end
		check(f.Quantity.Ore == 6 and f.Attributes.HuntOreRemaining == 0, "Six distinct ore produce exactly six grants")
		check(not pickup(f, f.Controller._nodes[1]) and f.Quantity.Ore == 6, "Repeated pickup cannot grant collected ore twice")
		check(f.Controller._nodes[1].Model == nil, "Picked resource is removed from world")
	end
	do
		local f = fixture("PickupAuthorization")
		local node = f.Controller._nodes[1]
		check(not pickup(f, node), "Distant pickup is refused")
		moveTo(f, node.Point)
		check(not f.Controller:_pickup(node, {UserId = f.Player.UserId + 1}, f.Now), "Another player cannot collect owner's resources")
		f.Active = false; check(not pickup(f, node), "Drawn/busy external state blocks pickup"); f.Active = true
		f.Attributes.AdminFlying = true; check(not pickup(f, node), "Admin flight blocks pickup"); f.Attributes.AdminFlying = false
		f.Root.Position += UP * 30; check(not pickup(f, node), "Airborne pickup is refused"); moveTo(f, node.Point)
		f.Run.State = "Failed"; check(not pickup(f, node), "Failed run cannot collect new resources"); f.Run.State = "Hunting"
		check(not pickup(f, node, f.Run.Deadline + .001), "Pickup after quest deadline is refused")
		check(#f.Grants == 0 and node.Model ~= nil, "Rejected requests leave node and inventory unchanged")
		check(pickup(f, node, f.Run.Deadline), "Pickup exactly on hunting deadline is accepted")
	end
	do
		local f = fixture("PickupWallAndNoGround")
		local node = f.Controller._nodes[1]; moveTo(f, node.Point + Vector3.new(0, 0, 6))
		local wall = makePart(f.Forest, "Wall", node.Point + Vector3.new(0, 2, 3), Vector3.new(12, 6, 1), true)
		check(not pickup(f, node) and #f.Grants == 0, "A wall blocks pickup despite valid distance")
		wall:Destroy(); f.Floor.CanCollide = false
		check(not pickup(f, node), "Missing standing support blocks pickup")
	end
	do
		local f = fixture("PickupInventoryFailure")
		local node = f.Controller._nodes[1]; moveTo(f, node.Point)
		f.RejectGrant = true; check(not pickup(f, node) and node.Model ~= nil and not node.Collected, "Rejected inventory transaction retains node")
		f.RejectGrant = false; f.ErrorGrant = true
		check(not pickup(f, node) and node.Model ~= nil and not node.Busy, "Inventory exception retains node and unlocks retry")
		f.ErrorGrant = false; check(pickup(f, node) and f.Quantity.Ore == 1, "Retry uses same source and succeeds once")
	end
	do
		local f = fixture("DropCrossingAndPickup")
		f.Controller:ObserveDamage(1200, 601)
		check(not f.Controller:GetSnapshot().DropConsidered and #f.Controller._nodes == 6, "Above 50 percent no scale exists")
		local node = drop(f)
		check(node ~= nil and f.Controller:GetSnapshot().DropSpawned, "First alive crossing at exactly 50 percent creates scale")
		check(node.Id == f.Run.MonsterId .. ":ScaleDrop" and node.Index == 1, "Drop ID is fixed to monster source")
		check(not node.Prompt.RequiresLineOfSight, "Dinosaur cannot visually occlude the scale prompt; server still validates static LOS")
		check(f.Quantity.Drop == 0 and not f.Controller:GetSnapshot().DropCollected, "Spawned scale is not automatically granted")
		f.Controller:ObserveDamage(1200, 400); f.Controller:ObserveDamage(600, 300); f.Controller:Step(f.Now + 1, .02)
		check(#f.Controller._nodes == 7, "Repeated threshold notifications cannot spawn another scale")
		moveTo(f, node.Point); check(pickup(f, node), "Owner explicitly picks up scale")
		check(f.Quantity.Drop == 1 and f.Attributes.HuntDropCollected and not pickup(f, node), "Scale is collected and granted once")
		f.Run.State = "Failed"; f.Controller:Step(f.Now + 2, .02); f.Controller:Destroy()
		check(f.Quantity.Drop == 1, "Already picked scale survives failed run and cleanup")
	end
	do
		local f = fixture("SynchronousAliveCrossingBeforeKill")
		f.Controller:ObserveDamage(1200, 590); f.Combat.Health = 0; f.Controller:Step(f.Now, .02)
		check(f.Controller:GetSnapshot().DropSpawned and #f.Controller._nodes == 7, "Damage hook preserves alive crossing even when target is killed before next Step")
		local g = fixture("DirectLethalCrossing")
		g.Combat.Health = 0; g.Controller:ObserveDamage(1200, 0)
		check(not g.Controller:GetSnapshot().DropSpawned and #g.Controller._nodes == 6, "Direct hit from above half to zero never spawns a scale")
		g.Combat.Health = 500; g.Controller:ObserveDamage(1200, 500)
		check(#g.Controller._nodes == 6, "Consumed lethal crossing cannot be reused by later health changes")
	end
	do
		local f = fixture("StepThresholdFallback")
		f.Combat.Health = 590; f.Controller:Step(f.Now, .02)
		check(f.Controller:GetSnapshot().DropSpawned and #f.Controller._nodes == 7, "Step detects a living crossing if synchronous hook is unavailable")
		f.Controller:ObserveDamage(0 / 0, 0); f.Controller:ObserveDamage(1200, math.huge)
		check(#f.Controller._nodes == 7, "Invalid damage values never create additional resources")
	end
	do
		local f = fixture("UnpickedDropAndOreAreLost")
		drop(f); f.Run.State = "Failed"; f.Controller:Step(f.Now, .02)
		for _, node in f.Controller._nodes do check(not node.Prompt.Enabled, "Terminal run disables remaining prompts") end
		f.Controller:Destroy()
		check(f.Quantity.Ore == 0 and f.Quantity.Drop == 0 and f.Controller._folder.Parent == nil, "Destroy grants no unpicked resource and removes all world objects")
	end
	do
		local f = fixture("CarveClockAndThreeClaims"); defeat(f)
		check(f.Attributes.HuntCarveAvailable and f.Attributes.HuntCarves == 0 and near(f.Attributes.HuntHarvestDuration, 1.5), "Defeated corpse advertises three available 1.5-second carves")
		check(f.Controller:RequestCarve(f.Now), "Nearby sheathed owner starts carving")
		check(not f.Controller:RequestCarve(f.Now), "Repeated start cannot overlap carves")
		check(f.Attributes.HuntHarvestAction == "Carve" and near(f.Attributes.HuntHarvestEnds, f.Now + 1.5) and #f.Grants == 0, "Starting carve replicates timer but grants nothing")
		f.Controller:Step(f.Now + 1.499, .02)
		check(f.Quantity.Carve == 0, "Carve cannot complete early")
		f.Controller:Step(f.Now + 1.5, .02)
		check(f.Quantity.Carve == 1 and f.Attributes.HuntCarves == 1 and f.Attributes.HuntHarvestAction == "", "Full duration grants one carve and clears action")
		for index = 2, 3 do
			local time = f.Now + index * 2
			check(f.Controller:RequestCarve(time), "Further distinct carve can begin " .. index)
			f.Controller:Step(time + 1.5, .02)
			check(f.Quantity.Carve == index and f.Run.HarvestProgress.Carves == index, "Distinct carve index grants once " .. index)
		end
		f.Controller:Step(f.Now + 20, .02)
		check(not f.Controller:RequestCarve(f.Now + 20) and not f.Attributes.HuntCarveAvailable, "Fourth carve is refused")
		for index, grant in f.Grants do check(grant.Kind == "Carve" and grant.SourceId == f.Run.MonsterId and grant.Index == index, "Carve transaction keeps monster source and original claim index " .. index) end
	end
	do
		local f = fixture("NoCorpseBeforeWinOrAfterCapture")
		check(not f.Controller:RequestCarve(f.Now), "Living target cannot be carved")
		f.Combat.Health = 0
		check(not f.Controller:RequestCarve(f.Now), "Dead target without locked result cannot be carved")
		f.Run.State = "Harvest"; f.Run.Result = "Captured"; f.Run.HarvestUntil = f.Now + 120
		check(not f.Controller:RequestCarve(f.Now), "Captured result never creates carve entitlement")
		check(f.Quantity.Carve == 0, "Invalid corpse requests grant nothing")
	end
	do
		local f = fixture("CarveReleaseAndMovement"); defeat(f)
		assert(f.Controller:RequestCarve(f.Now)); f.Controller:Cancel("KeyRelease"); f.Controller:Step(f.Now + 2, .02)
		check(f.Quantity.Carve == 0 and f.Attributes.HuntCarves == 0, "Releasing key before completion does not consume claim")
		assert(f.Controller:RequestCarve(f.Now + 3)); f.Root.Position += Vector3.new(1.7, 0, 0); f.Controller:Step(f.Now + 4.5, .02)
		check(f.Quantity.Carve == 0 and f.Attributes.HuntHarvestAction == "", "Moving during hold cancels without reward")
		f.Root.Position -= Vector3.new(1.7, 0, 0)
		assert(f.Controller:RequestCarve(f.Now + 5)); f.Controller:Step(f.Now + 6.49, .02)
		check(f.Quantity.Carve == 0, "Restarted carve needs full fresh duration")
		f.Controller:Step(f.Now + 6.5, .02)
		check(f.Quantity.Carve == 1 and f.Grants[1].Index == 1, "Canceled attempts retain first claim index")
	end
	do
		local f = fixture("CarveDamageAndBlockedAction"); defeat(f)
		assert(f.Controller:RequestCarve(f.Now)); f.Humanoid.Health -= 1; f.Controller:Step(f.Now + 1.5, .02)
		check(f.Quantity.Carve == 0 and f.Controller._action == nil, "Taking damage cancels carve before commit")
		assert(f.Controller:RequestCarve(f.Now + 2)); f.Active = false; f.Controller:Step(f.Now + 3.5, .02)
		check(f.Quantity.Carve == 0, "Drawing, attacking or other blocked owner action interrupts hold")
		f.Active = true; assert(f.Controller:RequestCarve(f.Now + 4)); f.Attributes.AdminFlying = true; f.Controller:Step(f.Now + 5.5, .02)
		check(f.Quantity.Carve == 0 and f.Attributes.HuntHarvestAction == "", "Admin flight interrupts pending carve")
	end
	do
		local f = fixture("CarveDistanceWallAndGround"); defeat(f)
		f.Root.Position = f.Combat.Support + Vector3.new(0, 3, 35)
		check(not f.Controller:RequestCarve(f.Now), "Distant player cannot carve")
		-- Stand beyond the body's front face: all reachable corpse points must
		-- be across this wall, including the elevated underside of the torso.
		f.Root.Position = f.Combat.Support + Vector3.new(0, 3, 12)
		local wall = makePart(f.Forest, "Wall", f.Combat.Support + Vector3.new(0, 3, 10.5), Vector3.new(30, 20, .6), true)
		check(not f.Controller:RequestCarve(f.Now), "Static wall blocks corpse interaction")
		wall:Destroy(); f.Floor.CanCollide = false
		check(not f.Controller:RequestCarve(f.Now), "Carving requires real standing support")
	end
	do
		local f = fixture("LegSurfaceReach"); defeat(f)
		f.Root.Position = f.Combat.Support + Vector3.new(-13, 3, 0)
		check((f.Root.Position - (f.Combat.Support + UP * 2.5)).Magnitude > 8, "Leg reach fixture is outside support-centre radius")
		check(f.Controller:RequestCarve(f.Now), "A nearby lower-leg surface permits carving a large corpse")
		f.Controller:Step(f.Now + 1.5, .02)
		check(f.Quantity.Carve == 1, "Real hurtbox surface reach commits valid carve")
	end
	do
		local f = fixture("CarveExpiresAndDies"); defeat(f)
		local time = f.Run.HarvestUntil - 1
		assert(f.Controller:RequestCarve(time)); f.Controller:Step(f.Run.HarvestUntil + .5, .02)
		check(f.Quantity.Carve == 0 and f.Attributes.HuntHarvestAction == "", "Completion after harvest deadline is canceled")
		check(not f.Controller:RequestCarve(f.Run.HarvestUntil + .01), "Expired harvest cannot start another action")
		local g = fixture("CarveDeath"); defeat(g)
		assert(g.Controller:RequestCarve(g.Now)); g.Humanoid.Health = 0; g.Controller:Step(g.Now + 1.5, .02)
		check(g.Quantity.Carve == 0 and g.Attributes.HuntHarvestAction == "", "Death interrupts pending carve without using it")
	end
	do
		local f = fixture("CarveAdapterFailure"); defeat(f)
		f.RejectGrant = true; assert(f.Controller:RequestCarve(f.Now)); f.Controller:Step(f.Now + 1.5, .02)
		check(f.Quantity.Carve == 0 and f.Attributes.HuntCarves == 0, "Rejected inventory transaction does not consume carve")
		f.RejectGrant = false; f.ErrorGrant = true; assert(f.Controller:RequestCarve(f.Now + 2)); f.Controller:Step(f.Now + 3.5, .02)
		check(f.Quantity.Carve == 0 and not f.Controller._committing and f.Controller._action == nil, "Adapter exception unlocks same claim retry")
		f.ErrorGrant = false; assert(f.Controller:RequestCarve(f.Now + 4)); f.Controller:Step(f.Now + 5.5, .02)
		check(f.Quantity.Carve == 1 and f.Grants[1].Index == 1, "Retry commits original claim exactly once")
	end
	do
		local f = fixture("ProgressSurvivesControllerRecreation"); defeat(f)
		assert(f.Controller:RequestCarve(f.Now)); f.Controller:Step(f.Now + 1.5, .02)
		local ore = f.Controller._nodes[1]; moveTo(f, ore.Point); assert(pickup(f, ore, f.Now + 2))
		f.Controller:Destroy(); f.Controller = Controller.new(f.Options)
		check(#f.Controller._nodes == 5 and f.Attributes.HuntOreRemaining == 5 and f.Attributes.HuntCarves == 1, "Recreated controller respects collected ore and completed carve indexes")
		moveTo(f, f.Combat.Support); assert(f.Controller:RequestCarve(f.Now + 3)); f.Controller:Step(f.Now + 4.5, .02)
		check(f.Quantity.Carve == 2 and f.Grants[#f.Grants].Index == 2, "Recreated controller cannot reuse first carve ID")
	end
	do
		local f = fixture("InvalidGroundConstructorCleanup")
		f.Controller:Destroy(); f.Floor.CanCollide = false
		local accepted = pcall(function() Controller.new(f.Options) end)
		check(not accepted, "Absent ore ground fails construction rather than spawning floating items")
		local leftovers = 0
		for _, item in workspace:GetChildren() do if item.Name == "HuntHarvest_" .. f.Player.UserId then leftovers += 1 end end
		check(leftovers == 0 and #f.Grants == 0, "Failed construction cleans its runtime folder and grants nothing")
	end
	do
		local f = fixture("DestroyDuringHold"); defeat(f)
		assert(f.Controller:RequestCarve(f.Now)); f.Controller:Destroy(); f.Controller:Destroy(); f.Controller:Step(f.Now + 5, .02)
		check(f.Quantity.Carve == 0 and f.Controller._action == nil and #f.Controller._connections == 0, "Destroy is idempotent and disconnects pending actions and prompt handlers")
		check(f.Attributes.HuntHarvestAction == "" and f.Attributes.HuntHarvestEnds == 0 and not f.Attributes.HuntCarveAvailable and f.Attributes.HuntOreRemaining == 0, "Destroy clears actionable replicated state")
	end
	check(source.Source == originalSource, "Production source remains unchanged")
end, debug.traceback)
if not ok then table.insert(report.failures, exception) end
for _, f in cases do if f.Controller then pcall(function() f.Controller:Destroy() end) end end
container:Destroy()
report.cases = #cases; report.elapsedSeconds = workspace:GetServerTimeNow() - started
report.ok = ok and #report.failures == 0
return report
