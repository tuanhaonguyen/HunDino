local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local player = Players.LocalPlayer
local model = workspace:WaitForChild("Dinosaur01_TRex_Visual")
local command = game:GetService("ReplicatedStorage"):WaitForChild("DinosaurPreviewCommand")
local gui = Instance.new("ScreenGui")
gui.Name = "DinosaurPreviewControls"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(.5, 1)
panel.Position = UDim2.new(.5, 0, 1, -20)
panel.Size = UDim2.new(.92, 0, 0, 122)
panel.BackgroundColor3 = Color3.fromRGB(20, 28, 28)
panel.BackgroundTransparency = .08
panel.BorderSizePixel = 0
panel.Parent = gui
local maxSize = Instance.new("UISizeConstraint")
maxSize.MaxSize = Vector2.new(630, 122)
maxSize.Parent = panel
local round = Instance.new("UICorner") round.CornerRadius = UDim.new(0, 14) round.Parent = panel
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -28, 0, 26)
title.Position = UDim2.fromOffset(14, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(236, 237, 221)
title.Text = "THỬ KHỦNG LONG"
title.Parent = panel
local status = title:Clone()
status.Name = "Status"
status.Position = UDim2.fromOffset(14, 33)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(174, 191, 172)
status.Parent = panel
local function button(name, text, index)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = UDim2.new(.25, -10, 0, 42)
	b.Position = UDim2.new((index - 1) * .25, 7, 0, 68)
	b.BackgroundColor3 = Color3.fromRGB(48, 68, 57)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(242, 241, 224)
	b.Text = text
	b.Parent = panel
	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 9) corner.Parent = b
	return b
end
local bite = button("Bite", "Cắn [F]", 1)
local walk = button("Walk", "Đi bộ [G]", 2)
local reset = button("Reset", "Về chỗ cũ [R]", 3)
local view = button("View", "Góc nhìn [C]", 4)
local watching = true
local function send(action) command:FireServer(action) end
bite.Activated:Connect(function() send("Bite") end)
walk.Activated:Connect(function() send("Walk") end)
reset.Activated:Connect(function() send("Reset") end)
local function toggleView()
	watching = not watching
	local camera = workspace.CurrentCamera
	if not watching then
		camera.CameraType = Enum.CameraType.Custom
		local character = player.Character
		if character then camera.CameraSubject = character:FindFirstChildOfClass("Humanoid") end
	end
end
view.Activated:Connect(toggleView)
Input.InputBegan:Connect(function(key, processed)
	if processed or Input:GetFocusedTextBox() then return end
	if key.KeyCode == Enum.KeyCode.F then send("Bite")
	elseif key.KeyCode == Enum.KeyCode.G then send("Walk")
	elseif key.KeyCode == Enum.KeyCode.R then send("Reset")
	elseif key.KeyCode == Enum.KeyCode.C then toggleView() end
end)
local function update()
	local biting = model:GetAttribute("BitePhase") ~= "Idle"
	local walking = model:GetAttribute("PreviewWalking") == true
	status.Text = biting and "Đang cắn…" or (walking and "Đang đi bộ · bấm G để dừng" or "Sẵn sàng · bấm F để cắn, G để đi bộ")
	walk.Text = walking and "Dừng [G]" or "Đi bộ [G]"
end
model:GetAttributeChangedSignal("BitePhase"):Connect(update)
model:GetAttributeChangedSignal("PreviewWalking"):Connect(update)
update()
RunService.RenderStepped:Connect(function(dt)
	if not watching or not model.PrimaryPart then return end
	local root = model.PrimaryPart
	local forward = root.CFrame:VectorToWorldSpace(model:GetAttribute("ForwardInRoot"))
	forward = Vector3.new(forward.X, 0, forward.Z).Unit
	local side = Vector3.new(-forward.Z, 0, forward.X)
	local focus = root.Position + Vector3.new(0, 2, 0) + forward * 2
	local desired = CFrame.lookAt(focus + side * 62 + forward * 34 + Vector3.new(0, 11, 0), focus)
	local camera = workspace.CurrentCamera
	local first = camera.CameraType ~= Enum.CameraType.Scriptable
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = first and desired or camera.CFrame:Lerp(desired, math.min(1, dt * 7))
	camera.Focus = CFrame.new(focus)
end)
