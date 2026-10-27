-- Server-owned, disposable P1-E resources. Inventory changes go through Grant;
-- this module never grants an item merely because a target died or a node spawned.
local Controller = {}
Controller.__index = Controller

local UP = Vector3.new(0, 1, 0)
local CARVE_SECONDS, CARVE_LIMIT, REACH = 1.5, 3, 8
local function finite(n) return type(n) == "number" and n == n and math.abs(n) < math.huge end
local function vector(v) return typeof(v) == "Vector3" and finite(v.X) and finite(v.Y) and finite(v.Z) end
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function set(object, key, value)
	if object and object.Parent and object:GetAttribute(key) ~= value then object:SetAttribute(key, value) end
end
local function nearest(box, origin)
	local p, half = box.CFrame:PointToObjectSpace(origin), box.Size * .5
	return box.CFrame:PointToWorldSpace(Vector3.new(math.clamp(p.X, -half.X, half.X), math.clamp(p.Y, -half.Y, half.Y), math.clamp(p.Z, -half.Z, half.Z)))
end
local function part(name, size, position, color, material, parent)
	local item = Instance.new("Part"); item.Name = name; item.Size = size; item.Position = position
	item.Anchored = true; item.CanCollide = false; item.CanTouch = false; item.CanQuery = false
	item.Color = color; item.Material = material; item.Parent = parent
	return item
end

function Controller.new(options)
	local self = setmetatable({}, Controller)
	for key, value in options do self[key] = value end
	assert(self.Player and self.Run and self.Combat and self.Forest, "Missing harvest services")
	assert(type(self.Character) == "function" and type(self.CanInteract) == "function" and type(self.Grant) == "function", "Missing harvest owner or economy")
	local folder = Instance.new("Folder"); folder.Name = "HuntHarvest_" .. tostring(self.Player.UserId)
	folder:SetAttribute("QuestRunId", self.Run.Id); folder:SetAttribute("OwnerUserId", self.Player.UserId)
	folder.Parent = workspace; self._folder = folder
	self._connections, self._nodes = {}, {}
	self.Run.HarvestProgress = self.Run.HarvestProgress or {Carves = 0, OreCollected = {}, DropConsidered = false, DropSpawned = false, DropCollected = false}
	self.Progress = self.Run.HarvestProgress
	self._lastHealth = self.Combat:GetSnapshot().Health
	local ok, failure = pcall(function() if not self.SkipOre then self:_createOre() end end)
	if not ok then self:Destroy(); error(failure, 2) end
	self:_publish()
	return self
end
function Controller:_message(text)
	if self.OnMessage then self.OnMessage(text) end
end
function Controller:_visit(now)
	local run = self.Run
	if self._destroyed or run.Closed or run.Returned then return false end
	if run.State == "Hunting" then return not finite(run.Deadline) or now <= run.Deadline end
	return run.State == "Harvest" and finite(run.HarvestUntil) and now <= run.HarvestUntil
end
function Controller:_actor(now)
	if not finite(now) or not self:_visit(now) or not self.Player.Parent
		or self.Player:GetAttribute("AdminFlying") == true or not self.CanInteract() then return nil end
	local character = self.Character()
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not character.Parent or not humanoid or humanoid.Health <= 0
		or not root or not root:IsA("BasePart") or not vector(root.Position) then return nil end
	return character, humanoid, root
end
function Controller:_groundParams()
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Include
	local support = {workspace.Terrain}
	for _, name in {"Paths", "Zones"} do
		local group = self.Forest:FindFirstChild(name); if group then table.insert(support, group) end
	end
	params.FilterDescendantsInstances = support; params.RespectCanCollide = true; params.IgnoreWater = false
	return params
end
function Controller:_obstacles()
	local params = OverlapParams.new(); params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {self.Forest}; params.RespectCanCollide = true
	return params
end
function Controller:_insideMap(point)
	local offset = self.Forest:GetAttribute("WorldOffset") or Vector3.new(0, 0, 6500)
	local width, depth = self.Forest:GetAttribute("MapWidth") or 4000, self.Forest:GetAttribute("MapDepth") or 4500
	return vector(point) and vector(offset) and finite(width) and finite(depth)
		and math.abs(point.X - offset.X) + 4 < width * .5 and math.abs(point.Z - offset.Z) + 4 < depth * .5
end
function Controller:_ground(point)
	if not self:_insideMap(point) then return nil end
	local params = self:_groundParams()
	local hit = workspace:Raycast(point + UP * 128, -UP * 256, params)
	if not hit or hit.Material == Enum.Material.Water or hit.Normal.Y < .82 then return nil end
	for _, delta in {Vector3.new(1.7, 0, 0), Vector3.new(-1.7, 0, 0), Vector3.new(0, 0, 1.7), Vector3.new(0, 0, -1.7)} do
		local edge = workspace:Raycast(hit.Position + delta + UP * 3, -UP * 6, params)
		if not edge or edge.Material == Enum.Material.Water or edge.Normal.Y < .82 or math.abs(edge.Position.Y - hit.Position.Y) > .85 then return nil end
	end
	if #workspace:GetPartBoundsInBox(CFrame.new(hit.Position + UP * 2.3), Vector3.new(4, 3.2, 4), self:_obstacles()) > 0 then return nil end
	return hit.Position
end
function Controller:_lineClear(character, origin, point)
	local delta = point - origin
	if delta.Magnitude < .01 then return true end
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
	local ignored = {character, self._folder}
	if self.Combat.Model then table.insert(ignored, self.Combat.Model) end
	if self.PetFolder then table.insert(ignored, self.PetFolder) end
	params.FilterDescendantsInstances = ignored; params.RespectCanCollide = true; params.IgnoreWater = false
	return workspace:Raycast(origin, delta, params) == nil
end
function Controller:_standing(humanoid, root)
	local state = humanoid:GetState()
	if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall or math.abs(root.AssemblyLinearVelocity.Y) > 7 then return false end
	local hit = workspace:Raycast(root.Position + UP, -UP * 8, self:_groundParams())
	return hit ~= nil and hit.Material ~= Enum.Material.Water and hit.Normal.Y > .6
		and root.Position.Y - hit.Position.Y <= math.max(5.5, humanoid.HipHeight + root.Size.Y * .5 + 2)
end
function Controller:_pickup(record, player, now)
	if player ~= self.Player or record.Collected or record.Busy or self._action or self._committing then return false end
	local character, humanoid, root = self:_actor(now)
	if not character or not self:_standing(humanoid, root) or (root.Position - record.Point).Magnitude > REACH
		or not self:_lineClear(character, root.Position + UP * .5, record.Point + UP * .7) then return false end
	record.Busy = true
	local called, granted, result = pcall(self.Grant, record.Kind, record.Id, record.Index)
	record.Busy = false
	if self._destroyed then return called and granted == true end
	if not called or granted ~= true then self:_message("Chưa ghi nhận được vật phẩm; hãy thử lại tại đúng điểm này."); return false end
	record.Collected = true
	if record.Kind == "Ore" then self.Progress.OreCollected[record.Index] = true
	else self.Progress.DropCollected = true end
	if record.Model then record.Model:Destroy(); record.Model = nil end
	self._lootText = if record.Kind == "Ore" then "+1 sắt · đã vào kho thử của phiên" else "+1 vảy · đã vào kho thử của phiên"
	self:_message(self._lootText); self:_publish()
	return true, result
end
function Controller:_resource(kind, id, index, point)
	local record = {Kind = kind, Id = id, Index = index, Point = point, Collected = false}
	local model = Instance.new("Model"); model.Name = if kind == "Ore" then "IronOre_" .. index else "ScaleDrop"
	model:SetAttribute("QuestRunId", self.Run.Id); model:SetAttribute("SourceInstanceId", id)
	model:SetAttribute("OwnerUserId", self.Player.UserId); model:SetAttribute("ResourceKind", kind)
	local base = part("Pickup", if kind == "Ore" then Vector3.new(3.1, 1.8, 2.5) else Vector3.new(1.7, .5, 1.25), point + UP * .9,
		if kind == "Ore" then Color3.fromRGB(70, 83, 91) else Color3.fromRGB(128, 194, 141),
		if kind == "Ore" then Enum.Material.Slate else Enum.Material.SmoothPlastic, model)
	base.CFrame *= CFrame.Angles(0, index * .7, .13)
	if kind == "Ore" then
		for n = 1, 3 do
			local crystal = part("IronSeam", Vector3.new(.35, .9 + n * .1, 1.45), point + Vector3.new((n - 2) * .72, 1.35, 0), Color3.fromRGB(171, 179, 167), Enum.Material.Metal, model)
			crystal.CFrame *= CFrame.Angles(.2, n * .55, .2)
		end
	end
	local light = Instance.new("PointLight"); light.Color = base.Color; light.Brightness = .5; light.Range = 9; light.Parent = base
	local prompt = Instance.new("ProximityPrompt"); prompt.Name = "CollectResource"
	prompt.ActionText = if kind == "Ore" then "Đào +1 sắt" else "Nhặt +1 vảy"
	prompt.ObjectText = if kind == "Ore" then "Quặng sắt · một lần / lượt săn" else "Vảy rơi · giữ dù thắng hay thua"
	prompt.KeyboardKeyCode = Enum.KeyCode.G; prompt.MaxActivationDistance = REACH - .5
	-- A scale may be beneath the dinosaur's visible body. The server still
	-- checks walls from the actor; the creature must not hide its own prompt.
	prompt.HoldDuration = 0; prompt.RequiresLineOfSight = kind == "Ore"; prompt.Parent = base
	record.Model, record.Prompt = model, prompt
	table.insert(self._connections, prompt.Triggered:Connect(function(player) self:_pickup(record, player, workspace:GetServerTimeNow()) end))
	model.PrimaryPart = base; model.Parent = self._folder
	table.insert(self._nodes, record)
	return record
end
function Controller:_createOre()
	local zones = self.Forest:FindFirstChild("Zones")
	local camp = zones and zones:FindFirstChild("Camp")
	local node = camp and camp:FindFirstChild("Node")
	assert(node and node:IsA("BasePart"), "Harvest requires the real Camp node")
	local safe = self.Forest:GetAttribute("CampSafeRadius") or 250
	local points = {}
	for index = 1, 6 do
		local angle = math.rad(25 + (index - 1) * 26)
		local selected
		for _, radiusExtra in {55, 75, 95, 115, 135} do
			for _, twist in {0, -.07, .07, -.14, .14} do
				local candidate = node.Position + Vector3.new(math.cos(angle + twist), 0, math.sin(angle + twist)) * (safe + radiusExtra)
				local point = self:_ground(candidate)
				if point and flat(point - node.Position).Magnitude > safe + 20 then
					local separated = true
					for _, other in points do if flat(point - other).Magnitude < 18 then separated = false; break end end
					if separated then selected = point; break end
				end
			end
			if selected then break end
		end
		assert(selected, "No safe walkable ground for ore " .. index .. "; no floating resource was created")
		table.insert(points, selected)
	end
	for index, point in points do
		if not self.Progress.OreCollected[index] then self:_resource("Ore", self.Run.Id .. ":Ore:" .. index, index, point) end
	end
end
function Controller:ObserveDamage(beforeHealth, afterHealth)
	if self._destroyed or self.Progress.DropConsidered or self.Run.State ~= "Hunting"
		or not finite(beforeHealth) or not finite(afterHealth) then return false end
	local maxHealth = self.Combat:GetSnapshot().MaxHealth
	if not finite(maxHealth) or maxHealth <= 0 or beforeHealth <= maxHealth * .5 or afterHealth > maxHealth * .5 then return false end
	self.Progress.DropConsidered = true
	if afterHealth <= 0 then self:_publish(); return false end
	self.Progress.DropSpawned = true -- reserve this crossing before geometry or callbacks
	local support = self.Combat:GetSupportPoint()
	if vector(support) then
		for _, offset in {Vector3.new(12, 0, 0), Vector3.new(-12, 0, 0), Vector3.new(0, 0, 12), Vector3.new(0, 0, -12), Vector3.zero} do
			local point = self:_ground(support + offset)
			if point then
				self.Progress.DropPoint = point
				self:_resource("Drop", self.Run.MonsterId .. ":ScaleDrop", 1, point)
				self:_message("Một vảy đã rơi gần mục tiêu. Đến gần và bấm G để nhặt; chưa nhặt thì chưa vào kho.")
				self:_publish(); return true
			end
		end
	end
	-- An unsafe location never produces a floating or automatically granted item.
	self.Progress.DropSpawned = false; self:_publish(); return false
end
function Controller:_carvePoint(root)
	local boxes = self.Combat.Model and self.Combat.Model:FindFirstChild("CombatHitboxes")
	local best, distance
	if boxes then
		for _, name in {"BodyHurtbox", "LeftLegHurtbox", "RightLegHurtbox"} do
			local box = boxes:FindFirstChild(name)
			if box and box:IsA("BasePart") then
				local point = nearest(box, root.Position)
				local d = (root.Position - point).Magnitude
				if d <= REACH and (not distance or d < distance) then best, distance = point, d end
			end
		end
	end
	-- Ground support also permits approaching between the two feet of a large rig.
	local support = self.Combat:GetSupportPoint()
	if vector(support) then
		local point = support + UP * 2.5
		local d = (root.Position - point).Magnitude
		if d <= REACH and (not distance or d < distance) then best = point end
	end
	return best
end
function Controller:_canCarve(now)
	if self.Run.State ~= "Harvest" or self.Run.Result ~= "Defeated" or self.Progress.Carves >= CARVE_LIMIT
		or self.Combat:GetSnapshot().Health > 0 then return nil end
	local character, humanoid, root = self:_actor(now)
	if not character or not self:_standing(humanoid, root) then return nil end
	local point = self:_carvePoint(root)
	if not point or not self:_lineClear(character, root.Position + UP * .5, point) then return nil end
	return character, humanoid, root, point
end
function Controller:_clearAction()
	if self._action and self._action.Connection then self._action.Connection:Disconnect() end
	self._action = nil
end
function Controller:Cancel(reason)
	if self._destroyed then return end
	local active = self._action ~= nil
	self:_clearAction()
	if active and reason == "Damaged" then self:_message("Bị đánh nên đã ngắt mổ; chưa dùng lượt mổ.") end
	self:_publish()
end
function Controller:RequestCarve(now)
	if self._destroyed or self._action or self._committing then return false, "Busy" end
	local character, humanoid, root, point = self:_canCarve(now)
	if not character then return false, "NotAvailable" end
	local action = {Character = character, Humanoid = humanoid, Root = root, Origin = root.Position, Point = point,
		Index = self.Progress.Carves + 1, FinishAt = now + CARVE_SECONDS, LastHealth = humanoid.Health, Damaged = false}
	action.Connection = humanoid.HealthChanged:Connect(function(health)
		if health < action.LastHealth then action.Damaged = true end
		action.LastHealth = health
	end)
	self._action = action; self:_publish()
	return true
end
function Controller:_publish()
	local remaining = 0
	if not self.SkipOre then for index = 1, 6 do if not self.Progress.OreCollected[index] then remaining += 1 end end end
	set(self.Player, "HuntCarves", self.Progress.Carves)
	set(self.Player, "HuntHarvestAction", if self._action then "Carve" else "")
	set(self.Player, "HuntHarvestEnds", if self._action then self._action.FinishAt else 0)
	set(self.Player, "HuntHarvestDuration", CARVE_SECONDS)
	set(self.Player, "HuntCarveAvailable", self._carveAvailable == true and not self._destroyed and not self._committing)
	set(self.Player, "HuntCarvePoint", if not self._destroyed then self._carvePointPublished else nil)
	set(self.Player, "HuntLootText", self._lootText or "")
	set(self.Player, "HuntOreRemaining", if self._destroyed then 0 else remaining)
	set(self.Player, "HuntDropSpawned", self.Progress.DropSpawned == true)
	set(self.Player, "HuntDropCollected", self.Progress.DropCollected == true)
end
function Controller:Step(now, _dt)
	if self._destroyed then return end
	local health = self.Combat:GetSnapshot().Health
	self:ObserveDamage(self._lastHealth, health); self._lastHealth = health
	local character, humanoid, root, point = self:_canCarve(now)
	self._carveAvailable, self._carvePointPublished = character ~= nil, point
	for _, node in self._nodes do if node.Prompt and node.Prompt.Parent then node.Prompt.Enabled = self:_visit(now) and not node.Collected end end
	local action = self._action
	if action then
		if not character or character ~= action.Character or humanoid ~= action.Humanoid or root ~= action.Root
			or (root.Position - action.Origin).Magnitude > 1.6 or action.Damaged or humanoid.Health < action.LastHealth then
			self:Cancel(if action.Damaged then "Damaged" else "Interrupted")
		elseif now >= action.FinishAt and not self._committing then
			self._committing = true
			local called, granted, result = pcall(self.Grant, "Carve", self.Run.MonsterId, action.Index)
			self._committing = false; self:_clearAction()
			if not self._destroyed and called and granted == true then
				self.Progress.Carves = action.Index
				self._lootText = "Đã mổ " .. action.Index .. "/3 · nguyên liệu vào kho thử của phiên"
				self:_message(self._lootText)
			elseif not self._destroyed then self:_message("Chưa ghi nhận lượt mổ; có thể thử lại cùng lượt, không cấp trùng.") end
		end
	end
	self:_publish()
end
function Controller:GetSnapshot()
	local resources = {}
	for _, node in self._nodes do table.insert(resources, {Kind = node.Kind, Id = node.Id, Index = node.Index, Point = node.Point, Collected = node.Collected}) end
	return {Carves = self.Progress.Carves, Action = if self._action then "Carve" else "", ActionEnds = if self._action then self._action.FinishAt else 0,
		CarveAvailable = self._carveAvailable == true, CarvePoint = self._carvePointPublished,
		DropConsidered = self.Progress.DropConsidered, DropSpawned = self.Progress.DropSpawned, DropCollected = self.Progress.DropCollected, Resources = resources}
end
function Controller:Destroy()
	if self._destroyed then return end
	self:_clearAction(); self._destroyed = true; self._carveAvailable = false
	for _, connection in self._connections do connection:Disconnect() end
	self._connections = {}
	if self._folder then self._folder:Destroy() end
	self:_publish()
end
return Controller
