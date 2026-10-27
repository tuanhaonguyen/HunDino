-- Connected forest HUD and per-player environment. Hub controls retain movement
-- and camera ownership; the server owns entry, exit and the session timestamps.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Input = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("HuntingMapConfig"))
local Clock = require(ReplicatedStorage:WaitForChild("HuntingEnvironmentClock"))
local preview = ReplicatedStorage:WaitForChild("HuntingMapPreviewJump")
local travel = ReplicatedStorage:WaitForChild("HunDinoTrainingAction")

local gui = Instance.new("ScreenGui")
gui.Name = "HuntingMapViewer"; gui.ResetOnSpawn = false; gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.Name = "Location"; panel.Position = UDim2.fromOffset(20, 82)
panel.Size = UDim2.fromOffset(330, 174); panel.BorderSizePixel = 0
panel.BackgroundColor3 = Color3.fromRGB(26, 43, 35); panel.BackgroundTransparency = .12
panel.Parent = gui
local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = panel
local function text(name, y, height, size)
	local label = Instance.new("TextLabel")
	label.Name = name; label.Position = UDim2.fromOffset(12, y)
	label.Size = UDim2.new(1, -24, 0, height); label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium; label.TextSize = size
	label.TextXAlignment = Enum.TextXAlignment.Left; label.TextColor3 = Color3.fromRGB(231, 235, 214)
	label.Parent = panel
	return label
end
local title = text("Title", 7, 22, 15)
local location = text("Zone", 31, 20, 13)
local animal = text("Dinosaur", 53, 18, 12)
local timer = text("Remaining", 75, 20, 12)
local hint = text("Keys", 98, 20, 11)
hint.Text = if RunService:IsStudio() then "Shift · Chạy     V · Nhảy     M · Chọn khu xem" else "Shift · Chạy     V · Nhảy     G · Tương tác"
local back = Instance.new("TextButton")
back.Name = "ReturnToLobby"; back.Position = UDim2.fromOffset(10, 129)
back.Size = UDim2.new(1, -20, 0, 34); back.BorderSizePixel = 0
back.BackgroundColor3 = Color3.fromRGB(64, 83, 56); back.TextColor3 = Color3.fromRGB(239, 235, 213)
back.Font = Enum.Font.GothamMedium; back.TextSize = 13; back.Text = "VỀ SẢNH TRUNG TÂM"; back.Parent = panel
corner:Clone().Parent = back
back.Activated:Connect(function()
	if player:GetAttribute("InHunting") == true then travel:FireServer("TravelMenu", "Lobby") end
end)

local picker = Instance.new("Frame")
picker.Name = "ZonePicker"; picker.Position = UDim2.fromOffset(20, 266)
picker.Size = UDim2.fromOffset(330, 316); picker.BorderSizePixel = 0
picker.BackgroundColor3 = Color3.fromRGB(26, 43, 35); picker.Visible = false; picker.Parent = gui
corner:Clone().Parent = picker
for index, zone in Config.Zones do
	local button = Instance.new("TextButton")
	button.Name = zone.id; button.Position = UDim2.fromOffset(9, 9 + (index - 1) * 33)
	button.Size = UDim2.new(1, -18, 0, 28); button.BorderSizePixel = 0
	button.BackgroundColor3 = Color3.fromRGB(54, 75, 55); button.TextColor3 = Color3.fromRGB(236, 238, 220)
	button.Font = Enum.Font.GothamMedium; button.TextSize = 12; button.Text = zone.id .. " · " .. zone.name; button.Parent = picker
	button.Activated:Connect(function()
		if RunService:IsStudio() and player:GetAttribute("InHunting") == true then preview:FireServer(zone.id) end
		picker.Visible = false
	end)
end

local clock, startedAt, scale, entryHours
local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function stopClock()
	if clock then clock:Destroy(true); clock = nil end
	startedAt, scale, entryHours = nil, nil, nil
end
local function updateSession()
	local active = player:GetAttribute("InHunting") == true
	gui.Enabled = active
	if not active then picker.Visible = false; stopClock(); return end
	local timestamp = player:GetAttribute("HuntStartedAt")
	local speed = player:GetAttribute("HuntTimeScale") or Config.TimeScale
	local entry = player:GetAttribute("HuntEntryClockHours")
	if not finite(timestamp) or not finite(speed) then return end
	if clock and startedAt == timestamp and scale == speed and entryHours == entry then return end
	stopClock()
	local settings = table.clone(Config); settings.TimeScale = speed
	clock = Clock.new(player, settings); startedAt, scale, entryHours = timestamp, speed, entry
	clock:Start(timestamp)
	-- The original standalone clock owns a wall-time Heartbeat. The connected
	-- viewer instead advances it with Roblox's synchronized server timestamp.
	clock:Stop()
	if finite(entry) then clock.EntryClockHours = entry end
	clock:Step(workspace:GetServerTimeNow())
end
local connections = {}
for _, name in {"InHunting", "HuntStartedAt", "HuntTimeScale", "HuntEntryClockHours"} do
	table.insert(connections, player:GetAttributeChangedSignal(name):Connect(updateSession))
end
table.insert(connections, Input.InputBegan:Connect(function(input, processed)
	if processed or Input:GetFocusedTextBox() then return end
	if input.KeyCode == Enum.KeyCode.M and RunService:IsStudio() and player:GetAttribute("InHunting") == true then
		picker.Visible = not picker.Visible
	end
end))
local active = true
script.Destroying:Connect(function()
	active = false; stopClock()
	for _, connection in connections do connection:Disconnect() end
	gui:Destroy()
end)
updateSession()
while active and gui.Parent do
	if gui.Enabled then
		if clock then
			-- Daylight keeps advancing through the 120-second result window;
			-- stopping the mission deadline does not stop the forest's day/night.
			clock:Step(workspace:GetServerTimeNow())
		end
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local nearest, distance = nil, math.huge
		if hrp then
			for _, zone in Config.Zones do
				local point = Config.position(zone)
				local d = Vector2.new(hrp.Position.X - point.X, hrp.Position.Z - point.Z).Magnitude
				if d < distance then nearest, distance = zone, d end
			end
		end
		local hours = player:GetAttribute("GameClockHours") or player:GetAttribute("HuntEntryClockHours") or 14
		local minutes = math.floor(hours * 60) % 1440
		title.Text = string.format("%s · %02d:%02d", Config.Name or "Rừng cổ", math.floor(minutes / 60), minutes % 60)
		location.Text = if nearest then nearest.id .. " · " .. nearest.name else "Đang khám phá"
		local dino = workspace:FindFirstChild("Dinosaur01_TRex_Visual")
		local state = dino and dino:GetAttribute("RouteState")
		local from = dino and dino:GetAttribute("RouteCurrentZone") or "A"
		local to = dino and dino:GetAttribute("RouteTargetZone") or from
		local combat=dino and dino:GetAttribute("CombatState")
		local rest=dino and dino:GetAttribute("RouteRestRemaining") or 0
		animal.Text = if combat=="Captured" then "Khủng long · Đã bắt sống"
			elseif combat=="Trapped" then "Khủng long · Mắc bẫy"
			elseif combat=="Dead" then "Khủng long · Đã hạ"
			elseif combat=="Windup" then "Khủng long · Chuẩn bị cắn!"
			elseif combat=="Chasing" or combat=="Biting" or combat=="Recovering" then "Khủng long · Đang phản công"
			elseif combat=="Returning" then "Khủng long · Quay lại tuyến"
			elseif state == "Walking" or state == "Turning" then "Khủng long · " .. from .. " → " .. to
			elseif state == "Resting" or state == "RestingHome" then "Nghỉ ở " .. from .. " · " .. math.ceil(rest) .. " giây"
			else "Khủng long · " .. from
		local remaining = player:GetAttribute("HuntRemainingSeconds")
		local harvest = player:GetAttribute("QuestState") == "Harvest"
		if harvest then remaining = math.max(0, (player:GetAttribute("QuestHarvestUntil") or 0) - workspace:GetServerTimeNow()) end
		timer.Visible = finite(remaining)
		if finite(remaining) then
			local seconds = math.max(0, math.ceil(remaining))
			timer.Text = string.format((if harvest then "Thu hoạch · %02d:%02d" else "Thời gian còn · %02d:%02d"), math.floor(seconds / 60), seconds % 60)
		end
	end
	task.wait(.25)
end
