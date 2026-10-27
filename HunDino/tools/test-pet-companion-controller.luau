-- Runtime contracts with deterministic server-side geometry/service doubles.
-- Native Studio still verifies actual terrain, Blockcast and PathfindingService.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")
local task = require("@lune/task")
local Vector3, CFrame = roblox.Vector3, roblox.CFrame
local now, blocked, water = 100, false, false

local function object()
	local item = {Parent = true, attributes = {}}
	function item:GetAttribute(key) return self.attributes[key] end
	function item:SetAttribute(key, value) self.attributes[key] = value end
	function item:Destroy() self.Parent = nil end
	function item:IsDescendantOf(parent) return self == parent end
	return item
end
local world = {GetServerTimeNow = function() return now end}
world.Raycast = function(_, origin, delta)
	if delta.Y < -4 then
		return {Position = Vector3.new(origin.X, 0, origin.Z), Normal = Vector3.yAxis,
			Material = if water then roblox.Enum.Material.Water else roblox.Enum.Material.Grass}
	end
	if blocked then return {Position = origin + delta * .4, Distance = delta.Magnitude * .4, Instance = object()} end
	return nil
end
world.Blockcast = function() return if blocked then {} else nil end
local paths = 0
local pathService = {CreatePath = function()
	paths += 1
	return {ComputeAsync = function() end, Status = roblox.Enum.PathStatus.NoPath, Destroy = function() end}
end}
local environment = {
	Vector3 = Vector3, CFrame = CFrame, Enum = roblox.Enum, Color3 = roblox.Color3,
	Instance = {new = function() return object() end}, workspace = world,
	game = {GetService = function() return pathService end},
	RaycastParams = {new = function() return {} end}, task = task,
}
local function load(path)
	local source = fs.readFile(path)
	luau.compile(source)
	return luau.load(source, {environment = environment, injectGlobals = true})()
end
local Rules = load("src/hunting/PetCombatRules.luau")
local Controller = load("src/hunting/PetCompanionController.luau")
local player = object()
player.UserId = 123
player:SetAttribute("InHunting", true)
local character, root, humanoid = object(), object(), object()
root.Position = Vector3.new(0, 3, 0)
root.CFrame = CFrame.new(root.Position)
humanoid.Health, humanoid.MaxHealth = 30, 100
local pets, pet, foot = object(), object(), object()
foot.Position = Vector3.new(0, .03, 0)
foot.CFrame = CFrame.new(foot.Position)
pet.PrimaryPart = foot
function pet:PivotTo(cf) foot.Position, foot.CFrame = cf.Position, cf end
local attacking = false
local animator = {
	SetMoving = function() end,
	IsAttacking = function() return attacking end,
	GetHitCount = function() return 2 end,
	CancelAttack = function() attacking = false end,
	Attack = function() attacking = true; return .9 end,
}
local dinosaur, point = object(), Vector3.new(4, 2, 0)
local totalDamage, tokens = 0, {}
local combat = {
	Model = dinosaur,
	GetSnapshot = function() return {Health=1200,MaxHealth=1200,Captured=false} end,
	GetClosestHitPoint = function(_, origin, range) return if (point - origin).Magnitude <= range then point else nil end,
	Damage = function(_, owner, amount, _, token, kind)
		assert(owner == player and kind == "Pet")
		assert(not tokens[token], "duplicate damage token")
		tokens[token] = true
		totalDamage += amount
		return amount
	end,
}
local canAct, engaged = true, false
local memory = Rules.new()
local companion = Controller.new({
	Player = player, Pet = pet, Character = character, Humanoid = humanoid, Root = root,
	Animator = animator, Combat = combat, PetFolder = pets, Rules = Rules, Memory = memory,
	CanAct = function() return canAct end, IsEngaged = function() return engaged end,
})
local checks = 0
local function check(condition, label)
	checks += 1
	assert(condition, label)
end
check(companion:Step(now, .1) == true, "hunt movement handled")
check(not attacking, "pet never starts autonomous aggro")
engaged = true
companion:Step(now, .1)
check(attacking, "starts owner-engaged attack")
animator.OnHit(1)
animator.OnHit(1)
animator.OnHit(2)
check(totalDamage == 12, "dagger damage split and once-only animation marks")
attacking = false
companion:Step(now, .1)
companion:Step(now + 1, .1)
check(not attacking, "ten second attack cooldown")
now += 10
for _=1,8 do companion:Step(now,.1) end
companion:Step(now, .1)
check(attacking, "attack ready at exact cooldown expiry")
local oldHit = animator.OnHit
companion:Cancel("Test")
oldHit(1)
check(animator.OnHit == nil and not attacking and totalDamage == 12, "cancel invalidates even a retained callback")
check(companion:RequestHeal(now), "request heal")
root.Position=foot.Position+Vector3.new(0,2,0);root.CFrame=CFrame.new(root.Position)
companion:Step(now, .1)
now += .8
companion:Step(now, .1)
check(humanoid.Health == 100, "successful heal restores seventy percent maximum health")
check(memory.HealReadyAt == now + 119, "heal cooldown starts only on success")
humanoid.Health = 40
check(not companion:RequestHeal(now), "heal cooldown rejects spam")
local biteFrame = CFrame.new(foot.Position + Vector3.new(0, 2, 0))
local biteSize = Vector3.new(10, 10, 10)
check(companion:DamageInBite(biteFrame, biteSize, 1, 24, dinosaur, now) == 24, "bite overlaps pet center")
check(companion:DamageInBite(biteFrame, biteSize, 1, 24, dinosaur, now + .1) == 0, "bite once per sequence")
blocked = true
check(companion:DamageInBite(CFrame.new(biteFrame.Position + Vector3.xAxis), biteSize, 2, 24, dinosaur, now + .2) == 0,
	"wall occludes bite")
blocked = false
companion:Cancel("Travel")
check(companion:DamageInBite(biteFrame, biteSize, 1, 24, dinosaur, now + .3) == 24, "new session permits reused bite sequence")
companion:Damage(100, now)
check(memory.Health == 1 and memory.StunnedUntil == now + 30, "pet stuns at one health")
check(companion:Step(now, .1) and companion:GetSnapshot().State == "Stunned", "stunned pet stops")
player:SetAttribute("InHunting", false)
canAct = false
now += 30
check(companion:Step(now, .1) == false and memory.Health == 100, "inactive stun recovery resumes ordinary lobby follow")
player:SetAttribute("AdminFlying", true)
check(companion:Step(now, .1) == true, "flying owner leaves pet on the ground")
player:SetAttribute("AdminFlying", false)
player:SetAttribute("InHunting", true)
canAct, engaged = true, false
root.CFrame = CFrame.new(20, 3, 0)
root.Position = root.CFrame.Position
blocked = true
local before = foot.Position
companion:Step(now, .1)
task.wait()
check(foot.Position == before, "swept wall blocks follow movement")
check(paths == 1, "blocked movement schedules one asynchronous detour")
blocked, water = false, true
companion:Step(now + .2, .1)
check(foot.Position == before, "water prevents follow movement")
water = false
memory.HealReadyAt = 0
root.Position = Vector3.new(20, 3, 0)
root.CFrame = CFrame.new(root.Position)
check(companion:RequestHeal(now), "distant owner can request approach")
companion:Step(now, .1)
check(companion:GetSnapshot().State == "HealApproach" and humanoid.Health == 40,
	"pet approaches before casting and cannot heal remotely")
companion:Cancel("Travel")
check(memory.HealReadyAt == 0 and not companion:GetSnapshot().Healing, "interrupted approach consumes no cooldown")
root.Position = foot.Position + Vector3.new(0, 3, 0)
root.CFrame = CFrame.new(root.Position)
check(companion:RequestHeal(now), "restart interrupted heal")
companion:Step(now, .1)
check(companion:GetSnapshot().State == "Healing", "cast begins only in range")
root.Position += Vector3.new(20, 0, 0)
root.CFrame = CFrame.new(root.Position)
now += .8
companion:Step(now, .1)
check(humanoid.Health == 40 and memory.HealReadyAt == 0 and companion:GetSnapshot().State == "HealApproach",
	"owner leaving range interrupts cast at commit and does not consume cooldown")
companion:Cancel("Test")
companion:Destroy()
check(companion:GetSnapshot().Destroyed, "destroy cleanup")
print("PASS " .. checks .. " companion runtime mocked checks")
