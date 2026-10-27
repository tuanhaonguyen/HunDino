-- Runtime geometry for one server-owned quest. Rules owns quantities, clocks and
-- the final result; this controller supplies real ground, movement and target checks.
local Controller = {}
Controller.__index = Controller

local UP = Vector3.new(0, 1, 0)
local TRAP_RADIUS = 4
local TRIGGER_RADIUS = 10
local PLACE_REACH = 5
local CAPTURE_REACH = 4
local MESSAGES = {
	NotHunting = "Chỉ dùng vật dụng trong lượt săn đang diễn ra.",
	NoTraps = "Đã hết Iron Trap. Bạn vẫn có thể tiêu diệt mục tiêu.",
	NoPotions = "Đã hết thuốc ngủ. Bạn vẫn có thể tiêu diệt mục tiêu.",
	Busy = "Hãy hoàn tất hoặc hủy thao tác hiện tại trước.",
	TrapActive = "Bẫy hiện tại vẫn đang chờ hoặc đang giữ mục tiêu.",
	NotTrapped = "Hãy dẫn mục tiêu vào Iron Trap trước.",
	NotWeak = "Mục tiêu cần còn sống và có không quá 10% máu.",
	TrapEscaped = "Bẫy đã hết hiệu lực; chưa dùng thuốc ngủ.",
	TrapExpired = "Bẫy đã hết thời gian chờ.",
	InvalidHealth = "Mục tiêu đã bị hạ hoặc không thể bắt.",
	ItemsBlocked = "Cất vũ khí và dừng đánh, né hoặc bay trước khi dùng vật dụng.",
	InvalidGround = "Không đặt được bẫy ở đây. Cần mặt đất phẳng, trống và ngoài trại.",
	Moved = "Đã hủy đặt bẫy vì bạn di chuyển. Chưa trừ bẫy.",
	Damaged = "Thao tác bị ngắt vì bạn bị đánh. Chưa dùng vật dụng.",
	TooFar = "Đến gần dấu miệng mục tiêu trong 4 studs để cho uống.",
	Obstructed = "Có vật cản giữa bạn và miệng mục tiêu.",
	SpecimenCapacity = "Kho cá thể đã đầy. Chưa dùng thuốc; bạn vẫn có thể tiêu diệt mục tiêu.",
}

local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function finite(n) return type(n) == "number" and n == n and math.abs(n) < math.huge end
local function vector(v)
	return typeof(v) == "Vector3" and finite(v.X) and finite(v.Y) and finite(v.Z)
end
local function attribute(object, key, value)
	if object and object.Parent and object:GetAttribute(key) ~= value then object:SetAttribute(key, value) end
end
local function decorate(part, name, size, cf, color, parent)
	part.Name = name; part.Size = size; part.CFrame = cf
	part.Anchored = true; part.CanCollide = false; part.CanTouch = false
	part.CanQuery = false; part.CastShadow = false; part.Color = color
	part.Material = Enum.Material.Metal; part.Parent = parent
	return part
end

function Controller.new(options)
	local self = setmetatable({}, Controller)
	for key, value in options do self[key] = value end
	assert(self.Player and self.Run and self.Rules and self.Combat and self.Forest, "Missing capture services")
	assert(type(self.Character) == "function" and type(self.CanUseItems) == "function", "Missing capture owner")
	local folder = Instance.new("Folder")
	folder.Name = "HuntItems_" .. tostring(self.Player.UserId)
	folder:SetAttribute("QuestRunId", self.Run.Id)
	folder:SetAttribute("OwnerUserId", self.Player.UserId)
	folder.Parent = workspace
	self._folder = folder
	self._destroyed = false
	self._captureAvailable = false
	self:_publish()
	return self
end

function Controller:_message(reason)
	local text = MESSAGES[reason]
	if text and self.OnMessage then self.OnMessage(text) end
end
function Controller:_reject(reason)
	self:_message(reason)
	return false, reason
end
function Controller:_capacity()
	if type(self.CanCapture)~="function" then return true end
	local ok,allowed,reason=pcall(self.CanCapture)
	return ok and allowed==true,if ok then reason or "ItemsBlocked" else "ItemsBlocked"
end
function Controller:_actor()
	if self._destroyed or self.Run.State ~= "Hunting" or not self.Player.Parent
		or self.Player:GetAttribute("AdminFlying") == true or not self.CanUseItems() then return nil end
	local character = self.Character()
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not character.Parent or not humanoid or humanoid.Health <= 0
		or not root or not root:IsA("BasePart") or not vector(root.Position) then return nil end
	return character, humanoid, root
end
function Controller:_queryParams(character, overlap)
	local params = if overlap then OverlapParams.new() else RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignored = {self._folder}
	if character then table.insert(ignored, character) end
	if self.PetFolder then table.insert(ignored, self.PetFolder) end
	if self.Combat.Model then table.insert(ignored, self.Combat.Model) end
	params.FilterDescendantsInstances = ignored
	params.RespectCanCollide = true
	if not overlap then params.IgnoreWater = false end
	return params
end
function Controller:_insideMap(point)
	local offset = self.Forest:GetAttribute("WorldOffset") or Vector3.new(0, 0, 6500)
	local width = self.Forest:GetAttribute("MapWidth") or 4000
	local depth = self.Forest:GetAttribute("MapDepth") or 4500
	if not vector(offset) or not finite(width) or not finite(depth) then return false end
	local localPoint = point - offset
	if math.abs(localPoint.X) + TRAP_RADIUS > width * .5
		or math.abs(localPoint.Z) + TRAP_RADIUS > depth * .5 then return false end
	local config = self.Combat.MapConfig
	if config and ((finite(config.TerrainMin) and point.Y < config.TerrainMin - 4)
		or (finite(config.TerrainMax) and point.Y > config.TerrainMax + 10)) then return false end
	local zones = self.Forest:FindFirstChild("Zones")
	local camp = zones and zones:FindFirstChild("Camp")
	local node = camp and camp:FindFirstChild("Node")
	local safeRadius = self.Forest:GetAttribute("CampSafeRadius") or 250
	return not node or flat(point - node.Position).Magnitude > safeRadius + TRAP_RADIUS
end

-- Sample the complete ring, not just its centre: an edge over water, an incline,
-- a nearby trunk or a gap invalidates the placement before an item is consumed.
function Controller:_ground(point, character, humanoid, root)
	if not vector(point) or not self:_insideMap(point) or flat(root.Position - point).Magnitude > PLACE_REACH then return nil end
	if math.abs(root.AssemblyLinearVelocity.Y) > 5 then return nil end
	local state = humanoid:GetState()
	if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then return nil end
	local params = self:_queryParams(character, false)
	local centre = workspace:Raycast(Vector3.new(point.X, root.Position.Y + 2, point.Z), -UP * 12, params)
	if not centre or centre.Material == Enum.Material.Water or centre.Normal.Y < .94 then return nil end
	local height = centre.Position.Y
	if root.Position.Y - height > math.max(5, humanoid.HipHeight + root.Size.Y * .5 + 1.5) then return nil end
	for index = 0, 15 do
		local angle = index * math.pi / 8
		local edge = centre.Position + Vector3.new(math.cos(angle), 0, math.sin(angle)) * TRAP_RADIUS
		local hit = workspace:Raycast(edge + UP * 3, -UP * 6, params)
		if not hit or hit.Material == Enum.Material.Water or hit.Normal.Y < .94 or math.abs(hit.Position.Y - height) > .65 then return nil end
		if workspace:Raycast(centre.Position + UP * .8, flat(edge - centre.Position), params) then return nil end
	end
	local overlap = self:_queryParams(character, true)
	local obstacles = workspace:GetPartBoundsInBox(CFrame.new(centre.Position + UP * 1.05), Vector3.new(8.2, 1.3, 8.2), overlap)
	if #obstacles > 0 then return nil end
	return Vector3.new(point.X, height + .05, point.Z)
end

function Controller:_remember(character, humanoid, root, serial, point)
	self:_clearAction()
	local action = {
		Character = character, Humanoid = humanoid, Root = root, Serial = serial,
		Origin = root.Position, Point = point, LastHealth = humanoid.Health, Damaged = false,
	}
	action.HealthConnection = humanoid.HealthChanged:Connect(function(health)
		if health < action.LastHealth then action.Damaged = true end
		action.LastHealth = health
	end)
	self._action = action
end
function Controller:_clearAction()
	if self._action and self._action.HealthConnection then self._action.HealthConnection:Disconnect() end
	self._action = nil
	if self._preview then self._preview:Destroy(); self._preview = nil end
end
function Controller:Cancel(reason)
	if self._destroyed then return end
	local hadAction = self.Run.Action ~= nil or self._action ~= nil
	self.Rules.cancelAction(self.Run)
	self:_clearAction()
	if hadAction then self:_message(reason) end
	self:_publish()
end

function Controller:RequestPlace(now)
	local character, humanoid, root = self:_actor()
	if not character then return self:_reject("ItemsBlocked") end
	-- Refuse repeated requests before the ring's ground/obstacle queries.
	if self.Run.Action then return self:_reject("Busy") end
	if self.Run.ActiveTrap then return self:_reject("TrapActive") end
	if self.Run.Traps <= 0 then return self:_reject("NoTraps") end
	local look = flat(root.CFrame.LookVector)
	if look.Magnitude < .01 then return self:_reject("InvalidGround") end
	local point = self:_ground(root.Position + look.Unit * 4.25, character, humanoid, root)
	if not point then return self:_reject("InvalidGround") end
	local accepted, reason, serial = self.Rules.beginPlace(self.Run, now)
	if not accepted then return self:_reject(reason) end
	self:_remember(character, humanoid, root, serial or self.Run.Action.Serial, point)
	local preview = decorate(Instance.new("Part"), "TrapPlacement", Vector3.new(8, .07, 8), CFrame.new(point), Color3.fromRGB(211, 173, 86), self._folder)
	preview.Transparency = .7; preview.Material = Enum.Material.Neon
	self._preview = preview
	self:_publish()
	return true
end

function Controller:_mouth(character, root)
	local point = self.Combat:GetCapturePoint()
	if not vector(point) then return nil, "NotTrapped" end
	if (root.Position - point).Magnitude > CAPTURE_REACH then return nil, "TooFar" end
	local delta = point - (root.Position + UP * .5)
	if delta.Magnitude > .01 and workspace:Raycast(root.Position + UP * .5, delta, self:_queryParams(character, false)) then
		return nil, "Obstructed"
	end
	return point
end
function Controller:RequestCapture(now)
	local character, humanoid, root = self:_actor()
	if not character then return self:_reject("ItemsBlocked") end
	local space,spaceReason=self:_capacity();if not space then return self:_reject(spaceReason) end
	local point, reason = self:_mouth(character, root)
	if not point then return self:_reject(reason) end
	local health = self.Combat:GetSnapshot()
	local accepted, ruleReason, serial = self.Rules.beginCapture(self.Run, now, health.Health, health.MaxHealth)
	if not accepted then return self:_reject(ruleReason) end
	self:_remember(character, humanoid, root, serial or self.Run.Action.Serial, point)
	self:_publish() -- Pause the owner's pet as soon as the drinking action begins.
	return true
end

function Controller:_createTrap(trap, point)
	self:_clearTrap()
	local model = Instance.new("Model")
	model.Name = "IronTrap"
	model:SetAttribute("QuestRunId", self.Run.Id)
	model:SetAttribute("TrapId", trap.Id)
	model:SetAttribute("OwnerUserId", self.Player.UserId)
	model.Parent = self._folder
	local copper = Color3.fromRGB(189, 126, 66)
	for index = 0, 15 do
		local angle = index * math.pi / 8
		local at = point + Vector3.new(math.cos(angle) * TRAP_RADIUS, .11, math.sin(angle) * TRAP_RADIUS)
		local bar = decorate(Instance.new("Part"), "IronRing", Vector3.new(.24, .16, 1.64), CFrame.lookAt(at, point + UP * .11) * CFrame.Angles(0, math.pi * .5, 0), copper, model)
		bar.Material = Enum.Material.Neon
		local tooth = decorate(Instance.new("WedgePart"), "IronTooth", Vector3.new(.4, .65, .7), CFrame.lookAt(at + UP * .22, point + UP * .33), Color3.fromRGB(92, 103, 104), model)
		tooth.Material = Enum.Material.DiamondPlate
	end
	decorate(Instance.new("Part"), "TriggerPlate", Vector3.new(2.2, .15, 2.2), CFrame.new(point + UP * .1), Color3.fromRGB(80, 89, 91), model)
	self._trapModel, self._trapPoint, self._trapId = model, point, trap.Id
end
function Controller:_clearTrap()
	if self._trapModel then self._trapModel:Destroy(); self._trapModel = nil end
	self._trapPoint, self._trapId = nil, nil
	if self._held then self.Combat:ReleaseTrap(self.Run.Id); self._held = false end
	if self._mouthMarker then self._mouthMarker:Destroy(); self._mouthMarker = nil end
end
function Controller:_marker(point)
	if not self._mouthMarker then
		local part = decorate(Instance.new("Part"), "CaptureMouth", Vector3.new(.65, .65, .65), CFrame.new(point), Color3.fromRGB(122, 221, 194), self._folder)
		part.Shape = Enum.PartType.Ball; part.Material = Enum.Material.Neon
		local gui = Instance.new("BillboardGui"); gui.Name = "MouthHint"
		gui.Size = UDim2.fromOffset(232, 55); gui.StudsOffsetWorldSpace = UP * 2.3
		gui.AlwaysOnTop = false; gui.MaxDistance = 70; gui.Adornee = part; gui.Parent = part
		local label = Instance.new("TextLabel"); label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(20, 43, 37); label.BackgroundTransparency = .18
		label.TextColor3 = Color3.fromRGB(228, 250, 222); label.TextSize = 14
		label.Font = Enum.Font.GothamBold; label.Text = "MIỆNG MỤC TIÊU\nCất vũ khí • Giữ G để cho uống"; label.Parent = gui
		local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = label
		self._mouthMarker = part
	end
	self._mouthMarker.Position = point
end

function Controller:_publish()
	local run, action, trap = self.Run, self.Run.Action, self.Run.ActiveTrap
	local hunting = not self._destroyed and run.State == "Hunting"
	attribute(self.Player, "HuntAction", if hunting and action then action.Kind else "")
	attribute(self.Player, "HuntActionEnds", if hunting and action then action.FinishAt else 0)
	attribute(self.Player, "HuntCaptureActive", hunting and action ~= nil and action.Kind == "Capture")
	attribute(self.Player, "HuntTrapState", if hunting and trap then trap.State else "")
	attribute(self.Player, "HuntTrapEnds", if hunting and trap then trap.HeldUntil or trap.ExpiresAt else 0)
	attribute(self.Player, "HuntTraps", run.Traps or 0)
	attribute(self.Player, "HuntPotions", run.Potions or 0)
	attribute(self.Player, "HuntCaptureAvailable", hunting and self._captureAvailable == true)
	attribute(self.Player, "HuntCapturePoint", if hunting then self._capturePoint else nil)
end

function Controller:Step(now, _dt)
 if self._pendingTrap then
  if not self.OnItemsChanged or self.OnItemsChanged() then
   local pending=self._pendingTrap;self._pendingTrap=nil
   if not self._destroyed and self.Run.State=="Hunting" then self:_createTrap(pending.Trap,pending.Point) end
  end
  return
 end
	if self._destroyed then return end
	if self.Run.State ~= "Hunting" then
		self:Cancel()
		self:_clearTrap()
		self._captureAvailable, self._capturePoint = false, nil
		self:_publish()
		return
	end
	local trap = self.Run.ActiveTrap
	if self._trapId and (not trap or trap.Id ~= self._trapId) then self:_clearTrap() end
	if trap and self._trapPoint and trap.State == "Waiting" and now <= trap.ExpiresAt then
		local support = self.Combat:GetSupportPoint()
		local health = self.Combat:GetSnapshot()
		if health.Health > 0 and vector(support) and flat(support - self._trapPoint).Magnitude <= TRIGGER_RADIUS
			and math.abs(support.Y - self._trapPoint.Y) <= 5 then
			local accepted = self.Rules.triggerTrap(self.Run, now)
			if accepted then
				self._held = self.Combat:TrapFor(self.Run.Id, trap.HeldUntil) == true
				if self._held then
					self._trapModel:SetAttribute("Triggered", true)
					if self.OnMessage then self.OnMessage("Iron Trap đã giữ mục tiêu trong 13 giây. Còn sống và máu ≤10% mới cho uống được.") end
				else
					-- Another terminal change can win before acquisition. Never leave a
					-- fictitious Holding state from which a potion could capture it.
					self.Run.ActiveTrap = nil
					self:Cancel()
					self:_clearTrap()
				end
			end
		end
	end
	trap = self.Run.ActiveTrap
	if trap and trap.State == "Holding" and now <= trap.HeldUntil and self._held then
		local point = self.Combat:GetCapturePoint()
		self._capturePoint = if vector(point) then point else nil
		if self._capturePoint then self:_marker(self._capturePoint)
		elseif self._mouthMarker then self._mouthMarker:Destroy(); self._mouthMarker = nil end
	else
		self._capturePoint = nil
		if self._mouthMarker then self._mouthMarker:Destroy(); self._mouthMarker = nil end
	end
	local character, humanoid, root = self:_actor()
	self._captureAvailable = false
	if character and self._capturePoint then
		local health = self.Combat:GetSnapshot()
		self._captureAvailable = self:_capacity() and health.Health > 0 and health.Health <= health.MaxHealth * .1
			and self.Run.Potions > 0 and (root.Position - self._capturePoint).Magnitude <= CAPTURE_REACH
			and self:_mouth(character, root) ~= nil
	end
	local action, remembered = self.Run.Action, self._action
	if not action then
		self:_clearAction()
	elseif not remembered or remembered.Serial ~= action.Serial then
		self:Cancel()
	elseif not character or character ~= remembered.Character or humanoid ~= remembered.Humanoid or root ~= remembered.Root then
		self:Cancel("ItemsBlocked")
	elseif remembered.Damaged or humanoid.Health < remembered.LastHealth then
		self:Cancel("Damaged")
	elseif action.Kind == "Place" then
		if (root.Position - remembered.Origin).Magnitude > 1.6 then
			self:Cancel("Moved")
		elseif now >= action.FinishAt then
			local point = self:_ground(remembered.Point, character, humanoid, root)
			if not point or (point - remembered.Point).Magnitude > .7 then
				self:Cancel("InvalidGround")
			else
				local placed, reason = self.Rules.commitPlace(self.Run, now, remembered.Serial)
				self:_clearAction()
				if placed then
     self._pendingTrap={Trap=placed,Point=point}
     if not self.OnItemsChanged or self.OnItemsChanged() then
      self._pendingTrap=nil;self:_createTrap(placed,point)
     end
				else self.Rules.cancelAction(self.Run); self:_message(reason) end
			end
		end
	elseif action.Kind == "Capture" then
		local point, reason = self:_mouth(character, root)
		local space,spaceReason=self:_capacity()
		if not space then self:Cancel(spaceReason)
		elseif not point or not self._held or not trap or trap.State ~= "Holding" or now > trap.HeldUntil then
			self:Cancel(reason or "TrapEscaped")
		else
			local health = self.Combat:GetSnapshot()
			if health.Health <= 0 or health.Health > health.MaxHealth * .1 then
				self:Cancel(if health.Health <= 0 then "InvalidHealth" else "NotWeak")
			elseif now >= action.FinishAt then
				local captured, result = self.Rules.commitCapture(self.Run, now, health.Health, health.MaxHealth, remembered.Serial)
				self:_clearAction()
				if captured then
					self._captureAvailable, self._capturePoint = false, nil
					if self.OnCapture then self.OnCapture() end
					self:_clearTrap()
				else
					self.Rules.cancelAction(self.Run)
					self:_message(result)
				end
			end
		end
	end
	self:_publish()
end

function Controller:GetSnapshot()
	local action, trap = self.Run.Action, self.Run.ActiveTrap
	return {
		Action = if action then action.Kind else "", ActionEnds = if action then action.FinishAt else 0,
		TrapState = if trap then trap.State else "", TrapEnds = if trap then trap.HeldUntil or trap.ExpiresAt else 0,
		TrapPoint = self._trapPoint, CapturePoint = self._capturePoint, CaptureAvailable = self._captureAvailable,
		Traps = self.Run.Traps, Potions = self.Run.Potions, Held = self._held == true,
	}
end
function Controller:Destroy()
	if self._destroyed then return end
	self:Cancel()
	self:_clearTrap()
	self._destroyed = true
	self._captureAvailable, self._capturePoint = false, nil
	if self._folder then self._folder:Destroy() end
	self:_publish()
end

return Controller
