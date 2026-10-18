-- Studio Edit/Server integration test, using an isolated dinosaur/character copy.
-- Requires the installed combat and route modules. Does not move live players,
-- change the live dinosaur, run its scripts, or leave any test Instances behind.
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local forest = assert(workspace:FindFirstChild("HuntingRainforest"), "Hunting map missing")
local original = assert(workspace:FindFirstChild("Dinosaur01_TRex_Visual"), "Dinosaur missing")
local runtime = assert(ServerScriptService:FindFirstChild("HuntingRuntime"), "Hunting runtime missing")
local combatModule = assert(runtime:FindFirstChild("DinosaurCombat"), "Combat module missing")
local Routes = require(assert(runtime:FindFirstChild("DinosaurRouteController"), "Route module missing"))
local config = require(ReplicatedStorage:WaitForChild("HuntingMapConfig"))
local report = {version = "DinosaurCombatTest.2", ok = false, checks = 0, passed = 0, failures = {}}
local function check(condition, name)
	report.checks += 1
	if condition then report.passed += 1 else table.insert(report.failures, name) end
	return condition
end
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local originalPivot = original:GetPivot()
local originalHealth = original:GetAttribute("Health")
local originalCount = #original:GetDescendants()
local originalEnabled = {}
for _, instance in original:GetDescendants() do
	if instance:IsA("BaseScript") then originalEnabled[instance] = instance.Enabled end
end
local container = Instance.new("Folder")
container.Name = "CombatIntegrationTest_" .. HttpService:GenerateGUID(false)
container.Parent = workspace
-- Studio's command context cannot create Player Instances (WritePlayer).
-- A disposable module copy accepts table players in this isolated test only;
-- all session, alive, bounds, camp, LOS and hit checks remain the real source.
-- The unmodified Player type gate is separately exercised in live Play.
local testModule = combatModule:Clone()
local substitutions
testModule.Source, substitutions = testModule.Source:gsub(
	'if typeof%(player%) ~= "Instance" or not player:IsA%("Player"%) or',
	'if type(player) ~= "table" or', 1)
assert(substitutions == 1, "Player test adapter did not match the production type gate")
testModule.Parent = container
local testConfig = assert(runtime:FindFirstChild("DinosaurCombatConfig"), "Combat settings missing"):Clone()
testConfig.Parent = container
-- Read the same fresh configuration as the disposable combat controller;
-- Studio may retain a cached result for the installed module after source edits.
local combatSettings = require(testConfig)
report.biteWindupSeconds = combatSettings.BiteWindup
report.biteCooldownSeconds = combatSettings.BiteCooldown
local Combat = require(testModule)
local clone, patrol, combat
local testPlayers = {}
local function character(name)
	local attributes = {}
	local player = {Name = name, UserId = -100 - #testPlayers}
	function player:GetAttribute(key) return attributes[key] end
	function player:SetAttribute(key, value) attributes[key] = value end
	function player:Destroy() self.Character = nil end
	local model = Instance.new("Model"); model.Name = name .. "Character"
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"; root.Size = Vector3.new(2, 2, 1)
	root.Anchored = true; root.CanCollide = false; root.CanTouch = false
	root.Transparency = 1; root.Parent = model; model.PrimaryPart = root
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 1000; humanoid.Health = 1000; humanoid.Parent = model
	model.Parent = container; player.Character = model
	player:SetAttribute("InHunting", true)
	table.insert(testPlayers, player)
	return player, root, humanoid
end
local session = {Players = {}}
local function step(seconds, route)
	local remaining = seconds
	while remaining > 1e-7 do
		local dt = math.min(.05, remaining)
		combat:Step(dt)
		if route then patrol:Step(dt) end
		remaining -= dt
	end
end
local success, errorMessage = xpcall(function()
	clone = original:Clone(); clone.Name = "TestDinosaur"
	for _, instance in clone:GetDescendants() do
		if instance:IsA("BaseScript") then instance.Enabled = false end
		if instance:IsA("BasePart") then instance.Transparency = 1; instance.CanCollide = false; instance.CanTouch = false end
	end
	-- Offset from the live model inside A's large clearing; this avoids its mesh
	-- becoming an unrelated line-of-sight obstruction in the isolated tests.
	clone:PivotTo(clone:GetPivot() + Vector3.new(85, 0, 0))
	clone.Parent = container
	patrol = Routes.new(clone, forest, config, {AutoConnect = false})
	session.Patrol = patrol
	patrol:Start(); patrol:Step(.05)
	local rest = patrol:GetSnapshot()
	check(math.abs(rest.RestRemaining - 59.95) < .01, "Default initial rest must be 60 real seconds")
	local anchor = rest.SupportPosition
	for _ = 1, 590 do patrol:Step(.1) end
	local waiting = patrol:GetSnapshot()
	check(waiting.State == "RestingHome" and waiting.Speed == 0 and waiting.RestRemaining > .8,
		"Patrol moved before its 60-second initial rest completed")
	check((flat(waiting.SupportPosition) - flat(anchor)).Magnitude < .01, "Rest foot anchor moved")
	-- Traverse one authored cycle. At each new stop, consume 59.9 synthetic
	-- real seconds and confirm it still rests before crossing the minute.
	local stopLegs, stops = {}, {}
	patrol:Step(1)
	for index = 1, 16000 do
		local current = patrol:GetSnapshot()
		if (current.State == "Resting" or current.State == "RestingHome")
			and current.CompletedLegs > 0 and not stopLegs[current.CompletedLegs] then
			stopLegs[current.CompletedLegs] = true
			stops[current.CurrentZone] = current.RestRemaining
			check(math.abs(current.RestRemaining - 60) < .001, current.CurrentZone .. " rest is not 60 seconds")
			local before = current.SupportPosition
			patrol:Step(59.9)
			local almost = patrol:GetSnapshot()
			check(almost.State == current.State and almost.RestRemaining > .09 and almost.Speed == 0,
				current.CurrentZone .. " left before the full minute")
			check((flat(almost.SupportPosition) - flat(before)).Magnitude < .01,
				current.CurrentZone .. " moved during rest")
			if current.CompletedCycles >= 1 then break end
			patrol:Step(.11)
		else patrol:Step(.1) end
		if index % 500 == 0 then task.wait() end
	end
	for _, zone in {"A", "B", "C", "R1", "R2", "R3", "R4", "R5"} do
		check(stops[zone] ~= nil, "Full route did not test rest at " .. zone)
	end
	report.restSecondsByZone = stops
	check(patrol:GetSnapshot().CompletedCycles == 1, "Minute-rest route did not complete its cycle")
	-- Use a fresh route owner after relocating the test copy away from the live
	-- home model. Its cached foot support must agree with the moved model.
	patrol:Destroy(); patrol = nil
	clone:PivotTo(clone:GetPivot() + Vector3.new(85, 0, 0))
	patrol = Routes.new(clone, forest, config, {AutoConnect = false})
	session.Patrol = patrol
	patrol:Start(); patrol:Step(.05)
	anchor = patrol:GetSnapshot().SupportPosition
	combat = Combat.new(clone, forest, config, session, {AutoConnect = false})
	combat:Start()
	local hunter, playerRoot, humanoid = character("CombatTestHunter")
	local bystander, bystanderRoot, bystanderHumanoid = character("CombatTestBystander")
	session.Players[hunter] = {}; session.Players[bystander] = {}
	-- Further cases below use the actual generated hurtboxes and real raycasts.
	local initial = combat:GetSnapshot()
	check(initial.Health == initial.MaxHealth and initial.Health > 0, "Dinosaur starts with full health")
	check(initial.AttackHits == 0, "Dinosaur has no attacks before being hit")
	local healthbar = clone:FindFirstChild("DinosaurHealthbar")
	check(healthbar and healthbar:IsA("BillboardGui") and healthbar.Adornee == clone.PrimaryPart,
		"Dinosaur healthbar is missing or follows the wrong part")
	local boxes = combat:GetHurtboxes()
	check(#boxes == 4, "Expected body, head, and two low-leg hurtboxes")
	for _, hurtbox in boxes do
		check(hurtbox.CanQuery and not hurtbox.CanCollide and not hurtbox.CanTouch,
			hurtbox.Name .. " does not provide a query-only damage volume")
	end
	local attackBox = clone.CombatHitboxes:FindFirstChild("BiteAttackHitbox")
	check(attackBox and not attackBox.CanQuery and not attackBox.CanCollide and not attackBox.CanTouch,
		"Bite volume can obstruct projectiles or push players")
	report.initial = initial
	-- The module exposes nearest surface selection so melee works at leg height.
	local forward = flat(clone.PrimaryPart.CFrame:VectorToWorldSpace(clone:GetAttribute("ForwardInRoot"))).Unit
	local side = Vector3.new(forward.Z, 0, -forward.X)
	local support = patrol:GetSnapshot().SupportPosition
	playerRoot.Position = Vector3.new(support.X, anchor.Y + 3, support.Z) + side * 20
	bystanderRoot.Position = playerRoot.Position + forward * 5
	step(1)
	check(humanoid.Health == 1000 and bystanderHumanoid.Health == 1000, "Unprovoked dinosaur damaged a hunter")
	check(combat:GetSnapshot().AttackHits == 0, "Unprovoked dinosaur attacked")
	local origin = playerRoot.Position + Vector3.new(0, 2, 0)
	local aim = -side
	local point, box = combat:GetClosestHitPoint(origin, 25, aim, -.1)
	assert(point and box, "No leg/body hurtbox reachable at player height")
	report.meleePoint = {heightAbovePlayer = point.Y - playerRoot.Position.Y, distance = (point - origin).Magnitude}
	check((point - origin).Magnitude <= 25, "Closest hurtbox exceeds requested range")
	check(combat:FromRayHit(box), "Own hurtbox was not recognized as a projectile hit")
	local canHit = combat:CanHit(hunter, point, 25)
	check(canHit == true, "Valid unobstructed hunter cannot hit a low hurtbox")
	local health = combat:GetSnapshot().Health
	local applied = combat:MeleeStrike(hunter, origin, aim, 25, -.1, 36, "test-melee-1")
	check(applied == 36 and combat:GetSnapshot().Health == health - 36, "Trusted melee damage did not reduce health")
	check(combat:Damage(hunter, 36, point, "test-melee-1") == 0, "Same server strike token applied twice")
	step(.1)
	check(combat:Damage(hunter, 36, point, "test-melee-1") == 0, "Repeated strike token passed after minimum damage interval")
	local beforeDenied = combat:GetSnapshot().Health
	for index, amount in {0, -10, math.huge, 0/0, 1e6} do
		check(combat:Damage(hunter, amount, point, "bad-amount-" .. index) == 0, "Malformed damage accepted")
	end
	check(combat:GetSnapshot().Health == beforeDenied, "Invalid damage changed health")
	local fakePoint = point + Vector3.new(0, 200, 0)
	check(combat:Damage(hunter, 10, fakePoint, "outside-box") == 0, "Point outside all hurtboxes accepted")
	local originalPosition = playerRoot.Position
	playerRoot.Position += Vector3.new(500, 0, 0)
	check(combat:Damage(hunter, 10, point, "too-far") == 0, "Out-of-range damage accepted")
	playerRoot.Position = originalPosition
	-- A solid wall blocks both melee and a projectile confirmation.
	local obstruction = Instance.new("Part"); obstruction.Name = "TestSolidLOS"
	obstruction.Anchored = true; obstruction.Size = Vector3.new(12, 24, 2)
	obstruction.CFrame = CFrame.lookAt((playerRoot.Position + point) * .5, point)
	obstruction.Parent = container
	check(combat:CanHit(hunter, point, 30) == false, "Solid obstruction did not deny hit")
	check(combat:Damage(hunter, 10, point, "through-wall") == 0, "Damage passed through solid obstruction")
	obstruction:Destroy()
	hunter:SetAttribute("InHunting", false)
	check(combat:Damage(hunter, 10, point, "outside-visit") == 0, "Lobby player damaged dinosaur")
	hunter:SetAttribute("InHunting", true)
	session.Players[hunter] = nil
	check(combat:Damage(hunter, 10, point, "not-session") == 0, "Player without server visit damaged dinosaur")
	session.Players[hunter] = {}
	humanoid.Health = 0
	check(combat:Damage(hunter, 10, point, "dead-player") == 0, "Dead player damaged dinosaur")
	humanoid.Health = 1000
	combat:PlayerExited(hunter)
	step(1)
	check(bystanderHumanoid.Health == 1000, "Dinosaur retargeted an unprovoked bystander")
	-- Put the attacker in the real frontal overlap volume. Check the telegraph,
	-- one hit per active window, and the independent attack cooldown.
	combat:Reset()
	support = patrol:GetSnapshot().SupportPosition
	forward = patrol:GetSnapshot().FacingDirection
	side = Vector3.new(forward.Z, 0, -forward.X)
	playerRoot.Position = support + forward * 25 + Vector3.new(0, 3, 0)
	bystanderRoot.Position = support + side * 55 + Vector3.new(0, 3, 0)
	point = assert(combat:GetClosestHitPoint(playerRoot.Position + Vector3.new(0, 2, 0), 60, -forward, -1))
	check(combat:Damage(hunter, 29, point, "retaliation") == 29, "Valid arrow-equivalent hit failed")
	step(.05, true)
	check(combat:GetSnapshot().AttackPhase == "Windup", "Attacked dinosaur did not telegraph retaliation")
	local attackStarted = combat:GetSnapshot().Time
	check(humanoid.Health == 1000, "Retaliation damaged before warning")
	step(combatSettings.BiteWindup - .05, true)
	check(humanoid.Health == 1000 and combat:GetSnapshot().AttackPhase == "Windup",
		"Warning did not last the configured windup")
	step(.1, true)
	check(humanoid.Health == 976 and combat:GetSnapshot().AttackHits == 1, "Frontal active hitbox failed to deal one bite")
	step(combatSettings.BiteActiveSeconds, true)
	check(humanoid.Health == 976 and combat:GetSnapshot().AttackHits == 1, "Single active window dealt repeated damage")
	step(combatSettings.BiteCooldown - (combat:GetSnapshot().Time - attackStarted) - .05, true)
	check(humanoid.Health == 976 and combat:GetSnapshot().AttackSequence == 1, "Bite cooldown allowed early repeated attack")
	step(combatSettings.BiteWindup + .15, true)
	check(humanoid.Health == 952 and combat:GetSnapshot().AttackHits == 2, "Dinosaur did not attack again after cooldown")
	check(bystanderHumanoid.Health == 1000, "Bite hit an unprovoked bystander")
	-- Moving sideways during the telegraph must evade the short active window.
	combat:Reset(); humanoid.Health = 1000
	playerRoot.Position = support + forward * 25 + Vector3.new(0, 3, 0)
	point = assert(combat:GetClosestHitPoint(playerRoot.Position + Vector3.new(0, 2, 0), 60, -forward, -1))
	check(combat:Damage(hunter, 29, point, "evade-warning") == 29, "Evasion setup hit failed")
	step(.05, true)
	check(combat:GetSnapshot().AttackPhase == "Windup", "Evasion setup has no warning")
	playerRoot.Position = support + side * 45 + Vector3.new(0, 3, 0)
	step(combatSettings.BiteWindup + combatSettings.BiteActiveSeconds + .1, true)
	check(humanoid.Health == 1000 and combat:GetSnapshot().AttackHits == 0, "Bite tracked through a successful sideways evade")
	-- Leaving during a warning cancels it; the next visitor must not inherit it.
	combat:Reset()
	playerRoot.Position = support + forward * 25 + Vector3.new(0, 3, 0)
	point = assert(combat:GetClosestHitPoint(playerRoot.Position + Vector3.new(0, 2, 0), 60, -forward, -1))
	check(combat:Damage(hunter, 29, point, "exit-warning") == 29, "Exit setup hit failed")
	step(.05, true)
	hunter:SetAttribute("InHunting", false); session.Players[hunter] = nil
	combat:PlayerExited(hunter)
	step(combatSettings.BiteWindup + combatSettings.BiteActiveSeconds + .1, true)
	check(humanoid.Health == 1000 and combat:GetSnapshot().AttackHits == 0, "Exit failed to cancel pending bite")
	hunter:SetAttribute("InHunting", true); session.Players[hunter] = {}
	-- Death disables damage and route movement until the session resets it.
	combat:Reset()
	point = assert(combat:GetClosestHitPoint(playerRoot.Position + Vector3.new(0, 2, 0), 60, -forward, -1))
	for index = 1, 6 do
		check(combat:Damage(hunter, 200, point, "lethal-" .. index) == 200, "Valid lethal hit failed")
		step(.1)
	end
	check(combat:GetSnapshot().Health == 0 and combat:GetSnapshot().State == "Dead", "Zero-health dinosaur is not dead")
	check(patrol:GetSnapshot().MotionMode == "Dead", "Dead dinosaur patrol was not stopped")
	check(combat:Damage(hunter, 29, point, "after-death") == 0, "Dead dinosaur accepted damage")
	local deadSupport = patrol:GetSnapshot().SupportPosition
	step(3, true)
	check((patrol:GetSnapshot().SupportPosition - deadSupport).Magnitude < .01 and humanoid.Health == 1000,
		"Dead dinosaur moved or attacked")
	combat:Reset()
	check(combat:GetSnapshot().Health == combat:GetSnapshot().MaxHealth
		and combat:GetSnapshot().AttackSequence == 0 and combat:GetSnapshot().AttackPhase == "Idle",
		"Fresh session reset did not restore health and clear combat")
	report.final = combat:GetSnapshot()
end, debug.traceback)

if combat then combat:Destroy() end
if patrol then patrol:Destroy() end
for _, player in testPlayers do player:Destroy() end
container:Destroy()
if not success then table.insert(report.failures, tostring(errorMessage)) end
check((original:GetPivot().Position - originalPivot.Position).Magnitude < .001, "Live dinosaur moved during isolated test")
check(original:GetAttribute("Health") == originalHealth and #original:GetDescendants() == originalCount,
	"Live dinosaur health/structure changed during isolated test")
for instance, enabled in originalEnabled do check(instance.Enabled == enabled, "Live script Enabled changed") end
report.ok = #report.failures == 0
return report
