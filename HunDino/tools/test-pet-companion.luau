-- Studio Edit/Server integration harness. No production models or Players are
-- mutated. Real controller/rules, anchored Humanoids, rays and blockcasts run
-- on disposable geometry; only animation marks and dinosaur damage are adapted.
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runtime = assert(ServerScriptService:FindFirstChild("HuntingRuntime"), "HuntingRuntime missing")
local controllerSource = assert(runtime:FindFirstChild("PetCompanionController"), "PetCompanionController missing")
local shared = ReplicatedStorage:FindFirstChild("Shared")
local rulesSource = assert(runtime:FindFirstChild("PetCombatRules") or (shared and shared:FindFirstChild("PetCombatRules")), "PetCombatRules missing")
local report = {version = "PetCompanionIntegration.1", ok = false, checks = 0, passed = 0, failures = {},
	boundary = "Real controller/rules/physics queries; animation marks and dinosaur sink adapted. Remote authorization tested separately."}
local function check(condition, message)
	report.checks += 1
	if condition then report.passed += 1 else table.insert(report.failures, message) end
end
local function near(a, b) return math.abs(a - b) < .001 end
local container = Instance.new("Folder")
container.Name = "PetCompanionIntegrationTest_" .. HttpService:GenerateGUID(false)
container.Parent = workspace
local sourceClone = controllerSource:Clone(); sourceClone.Parent = container
local rulesClone = rulesSource:Clone(); rulesClone.Parent = container
local Controller, Rules
local base = workspace:GetServerTimeNow()
local cases = {}
local liveDinosaur = workspace:FindFirstChild("Dinosaur01_TRex_Visual")
local livePivot = liveDinosaur and liveDinosaur:GetPivot()
local liveHP = liveDinosaur and liveDinosaur:GetAttribute("Health")

local function part(parent, name, position, size, collidable)
	local item = Instance.new("Part")
	item.Name = name; item.Position = position; item.Size = size
	item.Anchored = true; item.CanCollide = collidable; item.CanQuery = collidable
	item.CanTouch = false; item.Transparency = 1; item.Parent = parent
	return item
end
local function fixture(name, memory, clock)
	local f = {Now = clock or base + #cases * 1000, Active = true, Engaged = false, Damage = 0, DamageCalls = {}}
	table.insert(cases, f)
	f.Folder = Instance.new("Folder"); f.Folder.Name = name; f.Folder.Parent = container
	f.Origin = Vector3.new(24000 + #cases * 250, 500, 24000)
	part(f.Folder, "Floor", f.Origin - Vector3.yAxis, Vector3.new(180, 2, 180), true)
	f.Pets = Instance.new("Folder"); f.Pets.Name = "Pets"; f.Pets.Parent = f.Folder
	f.Pet = Instance.new("Model"); f.Pet.Name = "Pet"; f.Pet.Parent = f.Pets
	f.Pet.PrimaryPart = part(f.Pet, "Root", f.Origin + Vector3.new(0, .03, 0), Vector3.one * .2, false)
	f.Character = Instance.new("Model"); f.Character.Name = "Owner"; f.Character.Parent = f.Folder
	f.Root = part(f.Character, "HumanoidRootPart", f.Origin + Vector3.new(0, 2.03, 1.5), Vector3.new(2, 2, 1), false)
	f.Character.PrimaryPart = f.Root
	f.Humanoid = Instance.new("Humanoid"); f.Humanoid.RequiresNeck = false
	f.Humanoid.BreakJointsOnDeath = false; f.Humanoid.MaxHealth = 100; f.Humanoid.Health = 100
	f.Humanoid.Parent = f.Character
	local attrs = {InHunting = true}
	f.Player = {UserId = -2000 - #cases, Name = name, Parent = f.Folder, Character = f.Character}
	function f.Player:GetAttribute(key) return attrs[key] end
	function f.Player:SetAttribute(key, value) attrs[key] = value end
	f.Target = Instance.new("Model"); f.Target.Name = "DinosaurAdapter"; f.Target.Parent = f.Folder
	f.Target.PrimaryPart = part(f.Target, "Target", f.Origin + Vector3.new(4, 2.03, 0), Vector3.one, true)
	f.Animator = {Attacking = false, AttackCount = 0, CancelCount = 0, HitCount = 1}
	function f.Animator:SetMoving(on) self.Moving = on end
	function f.Animator:IsAttacking() return self.Attacking end
	function f.Animator:GetHitCount() return self.HitCount end
	function f.Animator:CancelAttack() self.Attacking = false; self.CancelCount += 1 end
	function f.Animator:Attack() self.Attacking = true; self.AttackCount += 1; return true end
	f.Combat = {Model = f.Target}
	function f.Combat:GetSnapshot() return {Health=f.TargetHP or 1200,MaxHealth=1200,Captured=false} end
	function f.Combat:GetClosestHitPoint(center, range)
		local point = f.Target.PrimaryPart.Position
		return if (point - center).Magnitude <= range then point else nil
	end
	function f.Combat:Damage(owner, amount, point, token, source)
		table.insert(f.DamageCalls, {Owner = owner, Amount = amount, Point = point, Token = token, Source = source})
		f.Damage += amount
		return amount
	end
	f.Memory = memory or Rules.new(f.Now)
	f.Controller = Controller.new({Player = f.Player, Pet = f.Pet, PetFolder = f.Pets,
		Character = f.Character, Humanoid = f.Humanoid, Root = f.Root, Animator = f.Animator,
		Rules = Rules, Memory = f.Memory, Combat = f.Combat,
		CanAct = function() return f.Active end, IsEngaged = function() return f.Engaged end})
	f.Controller._now = function() return f.Now end
	-- Detours require a live navmesh integration pass. This focused harness never
	-- starts an asynchronous path job; actual movement sweeps remain unmodified.
	f.Controller._pathReadyAt = math.huge
	function f:Step(seconds, dt)
		self.Now += seconds or 0
		return self.Controller:Step(self.Now, dt or .1)
	end
	function f:Wall()
		return part(self.Folder, "Wall", self.Origin + Vector3.new(2, 3, 0), Vector3.new(.5, 8, 12), true)
	end
	return f
end

local success, errorMessage = xpcall(function()
	Controller = require(sourceClone)
	Rules = require(rulesClone)
	check(sourceClone.Source == controllerSource.Source and rulesClone.Source == rulesSource.Source, "Harness changed production source")
	local f = fixture("AttackCadence")
	f:Step(0)
	check(f.Animator.AttackCount == 0 and f.Damage == 0, "Pet opened combat without owner engagement")
	check(f.Player:GetAttribute("PetHealth") == 100 and f.Pet:GetAttribute("PetMaxHealth") == 100, "Initial health was not published")
	f.Engaged = true; f:Step(0)
	check(f.Animator.AttackCount == 1 and f.Animator.OnHit ~= nil, "Engaged pet did not start an in-range attack")
	local firstHit = assert(f.Animator.OnHit)
	firstHit(1); firstHit(1)
	check(f.Damage == 12 and #f.DamageCalls == 1, "Single attack mark applied more than one 12-damage hit")
	check(f.DamageCalls[1].Owner == f.Player and f.DamageCalls[1].Source == "Pet", "Damage lost owner/source attribution")
	check(near(f.Memory.NextAttackAt, f.Now + 10), "Attack did not start a ten-second interval")
	f.Animator.Attacking = false
	for _=1,20 do f:Step(.1) end
	local home=f.Root.CFrame:PointToWorldSpace(Vector3.new(3,0,4))
	check(Vector3.new(home.X-f.Pet.PrimaryPart.Position.X,0,home.Z-f.Pet.PrimaryPart.Position.Z).Magnitude<1.5,"Pet did not return to its owner after one strike")
	f:Step(7.999)
	check(f.Animator.AttackCount == 1, "Pet attacked before ten real seconds")
	f:Step(.002)
	check(f.Animator.AttackCount == 2, "Pet did not attack when the ten-second interval elapsed")

	local dual = fixture("DualMarks"); dual.Animator.HitCount = 2; dual.Engaged = true; dual:Step(0)
	local dualHit = assert(dual.Animator.OnHit); dualHit(2); dualHit(1); dualHit(2)
	check(dual.Damage == 12 and #dual.DamageCalls == 1, "Dual animation marks exceeded one single 12-damage strike")
	check(dual.DamageCalls[1].Amount == 12, "Single visit was split into additional hits")
	local weak=fixture("CaptureProtection");weak.Engaged=true;weak.TargetHP=120;weak:Step(0)
	check(weak.Animator.AttackCount==0,"Pet attacked a target already at ten percent")
	weak.TargetHP=121;weak:Step(0);local weakHit=assert(weak.Animator.OnHit)
	weak.TargetHP=120;weakHit(1)
	check(weak.Damage==0,"An already-started pet strike hit after capture threshold was reached")

	local blocked = fixture("WallAndWindup"); blocked.Engaged = true
	local wall = blocked:Wall(); local before = blocked.Pet.PrimaryPart.Position
	blocked:Step(0)
	check(blocked.Animator.AttackCount == 0 and blocked.Damage == 0, "Pet started an attack through a solid wall")
	check((blocked.Pet.PrimaryPart.Position - before).Magnitude < .01, "Pet moved through a blocking wall")
	wall:Destroy(); blocked:Step(0)
	check(blocked.Animator.AttackCount == 1, "Removing the wall did not allow a valid attack")
	local pendingHit = assert(blocked.Animator.OnHit); wall = blocked:Wall(); pendingHit(1)
	check(blocked.Damage == 0, "Windup hit ignored a wall added before impact")
	wall:Destroy(); pendingHit(1)
	check(blocked.Damage == 0, "An obstructed hit mark replayed after its wall disappeared")

	local cancelled = fixture("CancelledAttack"); cancelled.Engaged = true; cancelled:Step(0)
	local cancelledHit = assert(cancelled.Animator.OnHit); cancelled.Controller:Cancel("Travel"); cancelledHit(1)
	check(cancelled.Damage == 0 and cancelled.Animator.OnHit == nil, "Cancelled windup dealt late damage")
	check(cancelled.Animator.CancelCount > 0 and not cancelled.Animator.Attacking, "Cancellation left the animator attacking")
	cancelled.Player:SetAttribute("AdminFlying", true); cancelled:Step(5)
	check(cancelled.Animator.AttackCount == 1 and cancelled.Controller:Damage(24, cancelled.Now) == 0, "Flying owner left pet attacks/damage active")
	cancelled.Player:SetAttribute("AdminFlying", false); cancelled.Player:SetAttribute("InHunting", false)
	check(cancelled:Step(0) == false and cancelled.Animator.AttackCount == 1, "Non-hunting pet stole training control or attacked dinosaur")

	local heal = fixture("HealingCommit"); heal.Humanoid.Health = 10
	check(heal.Controller:RequestHeal(heal.Now) == true, "Injured owner could not request healing")
	check(heal.Memory.HealReadyAt == 0 and heal.Pet:FindFirstChild("PetMedicineOrb") ~= nil, "Request consumed cooldown before healing or lacked medicine")
	local accepted, reason = heal.Controller:RequestHeal(heal.Now)
	check(not accepted and reason == "Healing", "Duplicate request queued another heal")
	heal:Step(0)
	check(heal.Player:GetAttribute("PetState") == "Healing", "Nearby pet did not begin its cast")
	heal:Step(.799)
	check(heal.Humanoid.Health == 10 and heal.Memory.HealReadyAt == 0, "Heal committed before the 0.8-second cast")
	heal:Step(.002)
	check(heal.Humanoid.Health == 80, "Heal did not restore exactly 70 percent of maximum owner health")
	check(near(heal.Memory.HealReadyAt, heal.Now + 119), "Cooldown did not start 119 seconds after commit")
	check(heal.Pet:FindFirstChild("PetMedicineOrb") == nil and not heal.Player:GetAttribute("PetHealCasting"), "Committed heal retained medicine or casting state")
	heal:Step(0); check(heal.Humanoid.Health == 80, "Completed cast applied healing twice")
	accepted, reason = heal.Controller:RequestHeal(heal.Now)
	check(not accepted and reason == "Cooldown", "Heal ignored its active cooldown")
	local cooldown = heal.Memory.HealReadyAt
	local dealt = heal.Controller:Damage(1000, heal.Now)
	local stunUntil = heal.Memory.StunnedUntil
	check(dealt == 99 and heal.Memory.Health == 1 and near(stunUntil, heal.Now + 30), "Pet damage did not clamp to one HP and stun for thirty seconds")
	heal:Step(1); heal.Controller:Damage(24, heal.Now)
	check(heal.Memory.StunnedUntil == stunUntil and heal.Memory.Health == 1, "New damage restarted or shortened the current stun")
	heal:Step(28.999)
	check(heal.Memory.Health == 1 and heal.Player:GetAttribute("PetState") == "Stunned", "Pet recovered before thirty seconds")
	heal:Step(.002)
	check(heal.Memory.Health == 100 and heal.Memory.StunnedUntil == 0, "Pet did not recover full health after thirty seconds")
	check(heal.Memory.HealReadyAt == cooldown, "Stun/recovery reset the independent heal cooldown")
	accepted, reason = heal.Controller:RequestHeal(heal.Now)
	check(not accepted and reason == "Cooldown", "Recovering from stun incorrectly refreshed healing")

	local capped = fixture("HealingCap"); capped.Humanoid.Health = 85
	capped.Controller:RequestHeal(capped.Now); capped:Step(0); capped:Step(.801)
	check(capped.Humanoid.Health == 100, "Healing exceeded or failed to reach the owner's maximum HP")
	capped.Memory.HealReadyAt = 0
	accepted, reason = capped.Controller:RequestHeal(capped.Now)
	check(not accepted and reason == "FullHealth" and capped.Memory.HealReadyAt == 0, "Full-health request started healing or consumed cooldown")

	local approach = fixture("HealingApproach"); approach.Humanoid.Health = 20
	approach.Root.Position = approach.Origin + Vector3.new(12, 2.03, 0)
	approach.Controller:RequestHeal(approach.Now); before = approach.Pet.PrimaryPart.Position; approach:Step(0)
	check(approach.Humanoid.Health == 20 and approach.Controller._healing.StartedAt == nil, "Out-of-range pet cast without approaching")
	check((approach.Pet.PrimaryPart.Position - before).Magnitude > .1, "Pet did not physically approach its injured owner")
	approach.Active = false; approach:Step(.4)
	check(approach.Controller._healing == nil and approach.Memory.HealReadyAt == 0, "Inactive owner did not cancel the approaching heal without cooldown")
	check(approach.Pet:FindFirstChild("PetMedicineOrb") == nil, "Interrupted approach left medicine behind")
	approach.Active = true; approach.Root.Position = approach.Pet.PrimaryPart.Position + Vector3.new(0, 2, 1.5)
	approach.Controller:RequestHeal(approach.Now); approach:Step(0); approach:Step(.4)
	approach.Controller:Cancel("Travel"); approach:Step(1)
	check(approach.Humanoid.Health == 20 and approach.Memory.HealReadyAt == 0, "Travel cancellation healed late or consumed cooldown")

	local interrupted = fixture("HealingRangeReset"); interrupted.Humanoid.Health = 20
	interrupted.Controller:RequestHeal(interrupted.Now); interrupted:Step(0)
	interrupted.Root.Position += Vector3.new(12, 0, 0); interrupted:Step(.4)
	check(interrupted.Controller._healing.StartedAt == nil and interrupted.Humanoid.Health == 20, "Owner leaving heal range did not reset the cast")
	interrupted.Root.Position = interrupted.Pet.PrimaryPart.Position + Vector3.new(0, 2, 1.5)
	interrupted:Step(.4); interrupted:Step(.799)
	check(interrupted.Humanoid.Health == 20, "Pet reused the old cast duration after the owner returned")
	interrupted:Step(.002)
	check(interrupted.Humanoid.Health == 90, "Pet did not heal after a fresh complete cast")

	local healWall = fixture("HealingLOS"); healWall.Humanoid.Health = 20
	healWall.Root.Position = healWall.Origin + Vector3.new(3, 2.03, 0)
	wall = healWall:Wall(); healWall.Controller:RequestHeal(healWall.Now); healWall:Step(0); healWall:Step(.801)
	check(healWall.Humanoid.Health == 20 and healWall.Memory.HealReadyAt == 0 and healWall.Controller._healing.StartedAt == nil, "Pet healed through a solid wall")
	wall:Destroy(); healWall.Root.Position = healWall.Pet.PrimaryPart.Position + Vector3.new(0, 2, 1.5)
	healWall:Step(0); healWall:Step(.801)
	check(healWall.Humanoid.Health == 90, "Unobstructed pet failed to complete healing")

	local dead = fixture("OwnerDeath"); dead.Humanoid.Health = 20
	dead.Controller:RequestHeal(dead.Now); dead:Step(0); dead.Humanoid.Health = 0; dead:Step(.801)
	check(dead.Humanoid.Health == 0 and dead.Memory.HealReadyAt == 0 and dead.Controller._healing == nil, "Pet healed a dead owner or consumed a cancelled cooldown")
	check(dead.Controller:RequestHeal(dead.Now) == false, "Dead owner could request another heal")

	local stunned = fixture("StunnedDuringCast"); stunned.Humanoid.Health = 20
	stunned.Controller:RequestHeal(stunned.Now); stunned:Step(0); stunned.Controller:Damage(999, stunned.Now); stunned:Step(.801)
	check(stunned.Humanoid.Health == 20 and stunned.Memory.HealReadyAt == 0 and stunned.Controller._healing == nil, "Stunned pet applied an interrupted heal")
	stunned:Step(30)
	check(stunned.Humanoid.Health == 20 and stunned.Memory.Health == 100 and not stunned.Controller._healing, "Recovery queued or automatically replayed a cancelled heal")

	local bite = fixture("BiteDeduplication")
	local biteCF = CFrame.new(bite.Pet.PrimaryPart.Position + Vector3.new(0, 2, 0))
	local biteSize = Vector3.new(8, 8, 8)
	check(bite.Controller:DamageInBite(biteCF, biteSize, 1, 24, bite.Target, bite.Now) == 24, "Valid bite failed to damage pet")
	check(bite.Controller:DamageInBite(biteCF, biteSize, 1, 24, bite.Target, bite.Now) == 0 and bite.Memory.Health == 76, "One bite damaged pet twice")
	bite.Controller:Cancel("Inactive")
	check(bite.Controller:DamageInBite(biteCF, biteSize, 1, 24, bite.Target, bite.Now) == 0, "Ordinary cancellation cleared the current bite deduplication token")
	check(bite.Controller:DamageInBite(biteCF, biteSize, 2, 24, bite.Target, bite.Now) == 24, "A distinct bite sequence was incorrectly deduplicated")
	check(bite.Controller:DamageInBite(biteCF + Vector3.new(20, 0, 0), biteSize, 3, 24, bite.Target, bite.Now) == 0, "Out-of-box bite hit pet")
	check(bite.Controller:DamageInBite(biteCF, Vector3.new(-1, 8, 8), 3, 24, bite.Target, bite.Now) == 0, "Invalid bite dimensions were accepted")

	local savedMemory = heal.Memory; heal.Controller:Destroy()
	local respawn = fixture("ReplacementController", savedMemory, heal.Now)
	respawn.Humanoid.Health = 20
	accepted, reason = respawn.Controller:RequestHeal(respawn.Now)
	check(not accepted and reason == "Cooldown" and respawn.Memory.HealReadyAt == cooldown, "Replacing the character/controller refreshed the heal cooldown")
	respawn.Controller:Damage(999, respawn.Now); stunUntil = respawn.Memory.StunnedUntil
	respawn.Controller:Destroy()
	local stillStunned = fixture("ReplacementWhileStunned", savedMemory, respawn.Now + 1)
	stillStunned:Step(0)
	check(stillStunned.Memory.Health == 1 and stillStunned.Memory.StunnedUntil == stunUntil and stillStunned.Player:GetAttribute("PetState") == "Stunned", "Replacing the controller reset a pending pet stun")
	local disposed = fixture("DestroyPending"); disposed.Humanoid.Health = 20
	disposed.Controller:RequestHeal(disposed.Now); disposed:Step(0); disposed.Controller:Destroy()
	check(disposed.Pet:FindFirstChild("PetMedicineOrb") == nil and disposed.Animator.OnHit == nil, "Destroy left medicine or an animation callback")
	check(disposed.Controller:RequestHeal(disposed.Now) == false and disposed.Controller:Damage(24, disposed.Now) == 0 and disposed:Step(1) == false, "Destroyed controller continued accepting actions")
	for _, item in cases do check(not item.Controller._pathPending, "Harness unexpectedly started an asynchronous path job") end
	report.fixtures = #cases
end, debug.traceback)

-- Always dispose controllers before the instances referenced by their callbacks.
for _, f in cases do if f.Controller then f.Controller:Destroy() end end
container:Destroy()
if not success then table.insert(report.failures, tostring(errorMessage)) end
check(container.Parent == nil, "Harness left its temporary world geometry behind")
if liveDinosaur and liveDinosaur.Parent and not game:GetService("RunService"):IsRunning() then
	check((liveDinosaur:GetPivot().Position - livePivot.Position).Magnitude < .001 and liveDinosaur:GetAttribute("Health") == liveHP,
		"Live dinosaur moved or lost health during isolated Edit test")
end
report.ok = #report.failures == 0
return report
