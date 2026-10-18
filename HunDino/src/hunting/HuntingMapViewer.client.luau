local Players=game:GetService("Players")
local Input=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage:WaitForChild("HuntingMapConfig"))
local root=workspace:WaitForChild("HuntingRainforest")
local player=Players.LocalPlayer
local remote=ReplicatedStorage:WaitForChild("HuntingMapPreviewJump")
local gui=Instance.new("ScreenGui");gui.Name="HuntingMapViewer";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local panel=Instance.new("Frame");panel.Name="Location";panel.AnchorPoint=Vector2.new(1,0);panel.Position=UDim2.new(1,-16,0,14)
panel.Size=UDim2.fromOffset(260,98);panel.BackgroundColor3=Color3.fromRGB(26,43,35);panel.BackgroundTransparency=.12
panel.BorderSizePixel=0;panel.Parent=gui
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=panel
local function text(name,y,height,size)
	local label=Instance.new("TextLabel");label.Name=name;label.Position=UDim2.fromOffset(12,y);label.Size=UDim2.new(1,-24,0,height)
	label.BackgroundTransparency=1;label.Font=Enum.Font.GothamMedium;label.TextSize=size;label.TextXAlignment=Enum.TextXAlignment.Left
	label.TextColor3=Color3.fromRGB(231,235,214);label.Parent=panel;return label
end
local title=text("Title",7,22,15);title.Text="RỪNG CỔ"
local location=text("Zone",30,20,13)
local animal=text("Dinosaur",51,18,12)
local hint=text("Keys",73,18,11);hint.Text=RunService:IsStudio() and "Shift · Chạy     M · Chọn khu xem" or "Shift · Chạy"
local picker=Instance.new("Frame");picker.Name="ZonePicker";picker.AnchorPoint=Vector2.new(1,0)
picker.Position=UDim2.new(1,-16,0,123);picker.Size=UDim2.fromOffset(260,316);picker.BackgroundColor3=Color3.fromRGB(26,43,35)
picker.BorderSizePixel=0;picker.Visible=false;picker.Parent=gui
local c=corner:Clone();c.Parent=picker
for i,q in Config.Zones do
	local button=Instance.new("TextButton");button.Name=q.id;button.Position=UDim2.fromOffset(9,9+(i-1)*33)
	button.Size=UDim2.new(1,-18,0,28);button.BackgroundColor3=Color3.fromRGB(54,75,55);button.BorderSizePixel=0
	button.Font=Enum.Font.GothamMedium;button.TextSize=12;button.TextColor3=Color3.fromRGB(236,238,220)
	button.Text=q.id.." · "..q.name;button.Parent=picker
	button.Activated:Connect(function() remote:FireServer(q.id);picker.Visible=false end)
end
local function sprint(enabled)
	local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if h then h.WalkSpeed=enabled and 30 or 16 end
end
Input.InputBegan:Connect(function(input,processed)
	if processed then return end
	if input.KeyCode==Enum.KeyCode.M and RunService:IsStudio() then picker.Visible=not picker.Visible end
	if input.KeyCode==Enum.KeyCode.LeftShift then sprint(true) end
end)
Input.InputEnded:Connect(function(input) if input.KeyCode==Enum.KeyCode.LeftShift then sprint(false) end end)
Input.WindowFocusReleased:Connect(function() sprint(false) end)
local function characterAdded(character)
	local h=character:WaitForChild("Humanoid")
	workspace.CurrentCamera.CameraType=Enum.CameraType.Custom;workspace.CurrentCamera.CameraSubject=h
	player.CameraMinZoomDistance=4;player.CameraMaxZoomDistance=110
end
player.CharacterAdded:Connect(characterAdded);if player.Character then task.spawn(characterAdded,player.Character) end
while gui.Parent do
	local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local nearest,dist=nil,math.huge
	if hrp then for _,q in Config.Zones do local p=Config.position(q);local d=Vector2.new(hrp.Position.X-p.X,hrp.Position.Z-p.Z).Magnitude
		if d<dist then nearest,dist=q,d end end end
	local hours=root:GetAttribute("GameClockHours") or Lighting.ClockTime;local minutes=math.floor(hours*60)%1440
	title.Text=string.format("RỪNG CỔ  ·  %02d:%02d",math.floor(minutes/60),minutes%60)
	location.Text=nearest and (nearest.id.." · "..nearest.name) or "Đang khám phá"
	local dino=workspace:FindFirstChild("Dinosaur01_TRex_Visual")
	local state=dino and dino:GetAttribute("RouteState")
	local from=dino and dino:GetAttribute("RouteCurrentZone") or "A"
	local to=dino and dino:GetAttribute("RouteTargetZone") or from
	if state=="Walking" or state=="Turning" then
		animal.Text="Khủng long · "..from.." → "..to
	elseif state=="Resting" or state=="RestingHome" then
		animal.Text="Khủng long · Đang nghỉ ở "..from
	elseif state=="Paused" then animal.Text="Khủng long · Tạm dừng ở "..from
	else animal.Text="Khủng long · "..from end
	task.wait(.4)
end
