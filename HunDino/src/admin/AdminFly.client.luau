-- Temporary admin map preview. Delete this LocalScript with AdminFly.server to remove it.
-- The server grants access and owns the flight constraints; this client sends input only.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("HunDinoAdminFly")
local ACTION = "HunDinoAdminFlightMovement"
local SPEEDS = {80, 160, 260}
local ZERO = Vector3.zero
local UP = Vector3.yAxis
local held = {}
local connections = {}
local characterConnections = {}
local gui, mainButton, statusLabel, touchControls
local speedButtons = {}
local active = false
local focused = true
local destroyed = false
local sendElapsed = 0
local streamElapsed = 0
local streamInFlight = false
local restoreGeneration = 0
local noticeUntil = 0
local noticeText = ""

local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
	return connection
end

local function allowed()
	return player:GetAttribute("AdminFlyAllowed") == true
end

local function alive()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
		and character:FindFirstChild("HumanoidRootPart") ~= nil
end

local function blocked()
	return not focused or UserInputService:GetFocusedTextBox() ~= nil or GuiService.MenuIsOpen
end

local function clearHeld()
	table.clear(held)
end

local function zeroInput()
	clearHeld()
	if allowed() and player:GetAttribute("AdminFlying") == true then
		remote:FireServer("Move", ZERO, Vector3.new(0, 0, -1), false)
	end
end

local function round(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function button(parent, text, position, size)
	local item = Instance.new("TextButton")
	item.BackgroundColor3 = Color3.fromRGB(45, 58, 54)
	item.BorderSizePixel = 0
	item.TextColor3 = Color3.fromRGB(239, 244, 226)
	item.Font = Enum.Font.GothamMedium
	item.TextSize = 13
	item.Text = text
	item.Position = position
	item.Size = size
	item.AutoButtonColor = true
	item.Parent = parent
	round(item, 6)
	return item
end

local function updateText()
	if not gui then return end
	mainButton.Text = active and "Dừng bay" or "Bay xem map"
	mainButton.BackgroundColor3 = active and Color3.fromRGB(118, 74, 45) or Color3.fromRGB(69, 105, 76)
	local speed = player:GetAttribute("AdminFlySpeed") or 160
	for value, item in speedButtons do
		item.BackgroundColor3 = value == speed and Color3.fromRGB(87, 111, 72) or Color3.fromRGB(45, 58, 54)
	end
	if os.clock() < noticeUntil then
		statusLabel.Text = noticeText
	elseif active then
		statusLabel.Text = "WASD · Space/E lên · Ctrl/Q xuống · Shift nhanh"
	else
		statusLabel.Text = "ADMIN · /fly bật/tắt · Tốc độ studs/giây"
	end
	touchControls.Visible = active and UserInputService.TouchEnabled
end

local function destroyGui()
	if gui then gui:Destroy() end
	gui, mainButton, statusLabel, touchControls = nil, nil, nil, nil
	table.clear(speedButtons)
end

local function createGui()
	if gui or not allowed() or destroyed then return end
	gui = Instance.new("ScreenGui")
	gui.Name = "HunDinoAdminFlyHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 70
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")
	local panel = Instance.new("Frame")
	panel.Name = "FlightPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, 78)
	panel.Size = UDim2.fromOffset(350, 73)
	panel.BackgroundColor3 = Color3.fromRGB(22, 33, 31)
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Parent = gui
	round(panel, 9)
	local border = Instance.new("UIStroke")
	border.Color = Color3.fromRGB(108, 130, 96)
	border.Transparency = 0.35
	border.Parent = panel
	mainButton = button(panel, "Bay xem map", UDim2.fromOffset(9, 8), UDim2.fromOffset(137, 32))
	mainButton.Name = "ToggleFlight"
	mainButton.Activated:Connect(function()
		if allowed() then remote:FireServer("Toggle") end
	end)
	for index, speed in SPEEDS do
		local item = button(panel, tostring(speed), UDim2.fromOffset(153 + (index - 1) * 63, 8), UDim2.fromOffset(58, 32))
		item.Name = "Speed" .. speed
		speedButtons[speed] = item
		item.Activated:Connect(function()
			if allowed() then remote:FireServer("Speed", speed) end
		end)
	end
	statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "Instructions"
	statusLabel.BackgroundTransparency = 1
	statusLabel.Position = UDim2.fromOffset(7, 44)
	statusLabel.Size = UDim2.fromOffset(336, 23)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 11
	statusLabel.TextColor3 = Color3.fromRGB(202, 212, 190)
	statusLabel.TextWrapped = true
	statusLabel.Parent = panel
	touchControls = Instance.new("Frame")
	touchControls.Name = "TouchAltitude"
	touchControls.BackgroundTransparency = 1
	touchControls.AnchorPoint = Vector2.new(0.5, 1)
	touchControls.Position = UDim2.new(0.5, 0, 1, -45)
	touchControls.Size = UDim2.fromOffset(190, 55)
	touchControls.Parent = gui
	for index, entry in {{"Lên", "TouchUp"}, {"Xuống", "TouchDown"}} do
		local item = button(touchControls, entry[1], UDim2.fromOffset((index - 1) * 100, 0), UDim2.fromOffset(90, 48))
		item.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				held[entry[2]] = true
			end
		end)
		item.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				held[entry[2]] = nil
			end
		end)
	end
	updateText()
end

local function flightAction(_, state, input)
	if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
		held[input.KeyCode] = nil
	elseif state == Enum.UserInputState.Begin then
		if blocked() then return Enum.ContextActionResult.Pass end
		held[input.KeyCode] = true
	end
	return active and not blocked() and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
end

local function restoreLocomotion()
	-- PlatformStand and the player attributes can arrive in adjacent replication updates.
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	local generation = restoreGeneration
	task.defer(function()
		for _ = 1, 20 do
			if destroyed or active or generation ~= restoreGeneration
				or player.Character ~= character or not humanoid.Parent or humanoid.Health <= 0 then return end
			if player:GetAttribute("AdminFlying") ~= true and not humanoid.PlatformStand then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				return
			end
			task.wait(0.05)
		end
	end)
end

local function refresh()
	if destroyed then return end
	local shouldFly = allowed() and player:GetAttribute("AdminFlying") == true and alive()
	if active ~= shouldFly then
		active = shouldFly
		clearHeld()
		sendElapsed = 0
		streamElapsed = 0
		restoreGeneration += 1
		ContextActionService:UnbindAction(ACTION)
		if active then
			ContextActionService:BindActionAtPriority(ACTION, flightAction, false, 4000,
				Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
				Enum.KeyCode.Space, Enum.KeyCode.E, Enum.KeyCode.Q,
				Enum.KeyCode.LeftControl, Enum.KeyCode.LeftShift)
		else
			restoreLocomotion()
		end
	end
	if allowed() then createGui() else destroyGui() end
	updateText()
end

local function watchCharacter(character)
	restoreGeneration += 1
	for _, connection in characterConnections do connection:Disconnect() end
	table.clear(characterConnections)
	zeroInput()
	refresh()
	if not character then return end
	local function watchHumanoid(humanoid)
		if not humanoid:IsA("Humanoid") then return end
		table.insert(characterConnections, humanoid.Died:Connect(function()
			zeroInput()
			refresh()
		end))
	end
	for _, child in character:GetChildren() do watchHumanoid(child) end
	table.insert(characterConnections, character.ChildAdded:Connect(function(child)
		watchHumanoid(child)
		refresh()
	end))
	table.insert(characterConnections, character.ChildRemoved:Connect(refresh))
end

local function direction()
	local camera = workspace.CurrentCamera
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local look = camera and camera.CFrame.LookVector or (root and root.CFrame.LookVector) or Vector3.new(0, 0, -1)
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude < 0.01 then
		look = root and Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z) or Vector3.new(0, 0, -1)
	end
	if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
	look = look.Unit
	if blocked() then return ZERO, look, false end
	local right = look:Cross(UP)
	local forward = (held[Enum.KeyCode.W] and 1 or 0) - (held[Enum.KeyCode.S] and 1 or 0)
	local side = (held[Enum.KeyCode.D] and 1 or 0) - (held[Enum.KeyCode.A] and 1 or 0)
	local rise = (held[Enum.KeyCode.Space] or held[Enum.KeyCode.E] or held.TouchUp) and 1 or 0
	local fall = (held[Enum.KeyCode.LeftControl] or held[Enum.KeyCode.Q] or held.TouchDown) and 1 or 0
	local movement = look * forward + right * side + UP * (rise - fall)
	if movement.Magnitude > 1 then movement = movement.Unit end
	return movement, look, held[Enum.KeyCode.LeftShift] == true
end

connect(player:GetAttributeChangedSignal("AdminFlyAllowed"), refresh)
connect(player:GetAttributeChangedSignal("AdminFlying"), refresh)
connect(player:GetAttributeChangedSignal("AdminFlySpeed"), updateText)
connect(player.CharacterAdded, watchCharacter)
connect(player.CharacterRemoving, function()
	restoreGeneration += 1
	zeroInput()
	active = false
	ContextActionService:UnbindAction(ACTION)
	updateText()
end)
connect(UserInputService.WindowFocusReleased, function()
	focused = false
	zeroInput()
end)
connect(UserInputService.WindowFocused, function() focused = true end)
connect(UserInputService.TextBoxFocused, zeroInput)
connect(GuiService.MenuOpened, zeroInput)
connect(remote.OnClientEvent, function(kind, message)
	if kind == "Message" and type(message) == "string" and allowed() then
		noticeText = message
		noticeUntil = os.clock() + 4
		updateText()
	end
end)
connect(RunService.Heartbeat, function(dt)
	if destroyed then return end
	if active and not alive() then refresh() end
	if active then streamElapsed = math.min(streamElapsed + dt, 1) else streamElapsed = 0 end
	sendElapsed += dt
	if sendElapsed < 0.05 then return end
	sendElapsed %= 0.05
	if active then
		local movement, look, boost = direction()
		remote:FireServer("Move", movement, look, boost)
		if workspace.StreamingEnabled and streamElapsed >= 1 and not streamInFlight then
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				streamElapsed = 0
				streamInFlight = true
				local speed = tonumber(player:GetAttribute("AdminFlySpeed")) or 160
				local predicted = root.Position + movement * math.clamp(speed, 80, 260) * 1.5
				task.spawn(function()
					pcall(function() player:RequestStreamAroundAsync(predicted, 1) end)
					streamInFlight = false
				end)
			end
		end
	end
	if gui and noticeUntil > 0 and os.clock() >= noticeUntil then
		noticeUntil = 0
		updateText()
	end
end)
script.Destroying:Connect(function()
	if destroyed then return end
	zeroInput()
	destroyed = true
	ContextActionService:UnbindAction(ACTION)
	for _, connection in connections do connection:Disconnect() end
	for _, connection in characterConnections do connection:Disconnect() end
	destroyGui()
end)

watchCharacter(player.Character)
refresh()
