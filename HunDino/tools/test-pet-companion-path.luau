-- Native engine path test. Creates only disposable geometry and a table owner.
-- No live Player, pet, dinosaur or map is moved. Run in Studio Edit/Server.
local HttpService = game:GetService("HttpService")
local runtime = game.ServerScriptService.HuntingRuntime
local folder = Instance.new("Folder")
folder.Name = "PetPathTest_" .. HttpService:GenerateGUID(false)
folder.Parent = workspace
local report = {version = "PetCompanionPath.1", ok = false, samples = {}, failures = {}}
local controller
local function part(parent, name, position, size, collide)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Position = position; p.Anchored = true
	p.CanCollide = collide; p.CanQuery = collide; p.CanTouch = false; p.Transparency = 1
	p.Parent = parent; return p
end
local ok, err = xpcall(function()
	local origin = Vector3.new(24000, 500, 23000)
	part(folder, "Floor", origin - Vector3.yAxis, Vector3.new(180, 2, 180), true)
	local wall = part(folder, "Wall", origin + Vector3.new(0, 5, 0), Vector3.new(4, 10, 24), true)
	local pets = Instance.new("Folder"); pets.Name = "Pets"; pets.Parent = folder
	local pet = Instance.new("Model"); pet.Name = "Pet"; pet.Parent = pets
	pet.PrimaryPart = part(pet, "Root", origin + Vector3.new(-22, .03, 0), Vector3.one, false)
	local char = Instance.new("Model"); char.Name = "Owner"; char.Parent = folder
	local root = part(char, "HumanoidRootPart", origin + Vector3.new(22, 2.03, 0), Vector3.new(2, 2, 1), false)
	char.PrimaryPart = root
	local hum = Instance.new("Humanoid"); hum.RequiresNeck = false
	hum.BreakJointsOnDeath = false; hum.Parent = char
	local attrs = {InHunting = true}
	local player = {UserId = -3001, Parent = folder}
	function player:GetAttribute(key) return attrs[key] end
	function player:SetAttribute(key, value) attrs[key] = value end
	local anim = {}
	function anim:SetMoving(_on) end
	function anim:IsAttacking() return false end
	function anim:CancelAttack() end
	function anim:GetHitCount() return 1 end
	local combat = {}
	function combat:GetClosestHitPoint(_point, _range) return nil end
	local Rules = require(runtime.PetCombatRules)
	controller = require(runtime.PetCompanionController).new({
		Player = player, Pet = pet, Character = char, Humanoid = hum, Root = root,
		PetFolder = pets, Animator = anim, Combat = combat, Rules = Rules,
		Memory = Rules.new(), CanAct = function() return true end,
		IsEngaged = function() return false end,
	})
	local start = workspace:GetServerTimeNow()
	local crossed, detoured, pathObserved = false, false, false
	local closest = math.huge
	local steps = 0
	while workspace:GetServerTimeNow() - start < 16 do
		controller:Step(workspace:GetServerTimeNow(), .1)
		local p = pet.PrimaryPart.Position - origin
		local snapshot = controller:GetSnapshot()
		steps += 1
		pathObserved = pathObserved or snapshot.PathFollowing
		-- Include half the pet's swept body width when testing the wall footprint.
		if math.abs(p.X) < 2.9 and math.abs(p.Z) < 12.8 then crossed = true end
		if math.abs(p.Z) > 13 then detoured = true end
		local goal = root.CFrame:PointToWorldSpace(Vector3.new(3, 0, 4))
		local d = Vector2.new(goal.X - pet.PrimaryPart.Position.X, goal.Z - pet.PrimaryPart.Position.Z).Magnitude
		closest = math.min(closest, d)
		if steps % 5 == 0 then table.insert(report.samples, {t = workspace:GetServerTimeNow() - start, x = p.X, z = p.Z}) end
		if d < 2 then break end
		task.wait(.1)
	end
	report.seconds = workspace:GetServerTimeNow() - start
	report.steps = steps
	report.pathObserved = pathObserved
	report.detoured = detoured
	report.crossedWall = crossed
	report.remainingDistance = closest
	if crossed then table.insert(report.failures, "Pet crossed the solid wall footprint") end
	if not pathObserved then table.insert(report.failures, "No engine path was followed") end
	if not detoured then table.insert(report.failures, "Pet did not walk around the wall") end
	if closest >= 2 then table.insert(report.failures, "Pet did not reach the owner side of the wall") end
	report.ok = #report.failures == 0
end, debug.traceback)
if controller then controller:Destroy() end
folder:Destroy()
if not ok then report.error = tostring(err); report.ok = false end
return HttpService:JSONEncode(report)
