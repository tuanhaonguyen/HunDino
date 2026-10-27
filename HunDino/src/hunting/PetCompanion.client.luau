-- P1-C companion HUD. The server owns health, stun and healing; H and the
-- button send the same request without a target, amount or client timestamp.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Theme = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UITheme"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("HunDinoTrainingAction")
local connections = {}
local alive = true
local nextRequestAt = 0
local elapsed = 0
local removingCharacter
local GREEN, AMBER, RED = Theme.Colors.Health, Theme.Colors.Gold, Theme.Colors.Warning
local INK, CREAM, MUTED = Theme.Colors.Panel, Theme.Colors.Text, Theme.Colors.Muted

local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
	return connection
end

local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function numberAttribute(name, fallback)
	local value = player:GetAttribute(name)
	return if finite(value) then value else fallback
end

local function round(item, radius)
	Theme.round(item, radius)
end

local gui = Instance.new("ScreenGui")
gui.Name = "HunDinoPetCompanionHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0, 1)
-- Leave the existing player stats and stamina directly below this card.
panel.Position = UDim2.new(0, 20, 1, -154)
panel.Size = UDim2.fromOffset(328, 150)
panel.BackgroundColor3 = INK
panel.BackgroundTransparency = .12
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
Theme.panel(panel)
local scale = Instance.new("UIScale")
scale.Parent = panel

local function label(name, text, position, size, textSize)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Text = text
	item.Position = position
	item.Size = size
	item.BackgroundTransparency = 1
	item.TextColor3 = CREAM
	item.Font = Enum.Font.GothamMedium
	item.TextSize = textSize
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.Parent = panel
	return item
end

local heading = label("Title", "PET ĐỒNG HÀNH", UDim2.fromOffset(14, 8), UDim2.fromOffset(164, 20), 12)
heading.TextColor3 = AMBER; heading.Font = Enum.Font.GothamBold
local healthText = label("HealthText", "", UDim2.fromOffset(190, 8), UDim2.fromOffset(124, 20), 12)
healthText.TextXAlignment = Enum.TextXAlignment.Right
local track = Instance.new("Frame")
track.Name = "HPTrack"
track.Position = UDim2.fromOffset(14, 34)
track.Size = UDim2.new(1, -28, 0, 8)
track.BackgroundColor3 = Theme.Colors.Card
track.BorderSizePixel = 0
track.ClipsDescendants = true
track.Parent = panel
round(track, 4)
local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.fromScale(1, 1)
fill.BackgroundColor3 = GREEN
fill.BorderSizePixel = 0
fill.Parent = track
round(fill, 4)
local status = label("Status", "", UDim2.fromOffset(14, 48), UDim2.new(1, -28, 0, 19), 12)
status.TextColor3 = MUTED

local healButton = Instance.new("TextButton")
healButton.Name = "HealButton"
healButton.Position = UDim2.fromOffset(74, 77)
healButton.Size = UDim2.new(1, -88, 0, 38)
healButton.BackgroundColor3 = Theme.Colors.Card
healButton.BorderSizePixel = 0
healButton.TextColor3 = CREAM
healButton.Font = Enum.Font.GothamMedium
healButton.TextSize = 12
healButton.Text = "[H] Gọi Pet Hồi Máu (+70% HP)"
healButton.TextWrapped = true
healButton.AutoButtonColor = false
healButton.Parent = panel
Theme.button(healButton)
local cooldownRing = Theme.Ring(panel, "HealCooldown", 48, 4, Theme.Colors.Stamina)
cooldownRing.Frame.Position = UDim2.fromOffset(38, 96)
local cooldownText = label("CooldownText", "H", UDim2.fromOffset(15, 77), UDim2.fromOffset(46, 38), 13)
cooldownText.TextXAlignment = Enum.TextXAlignment.Center; cooldownText.Font = Enum.Font.GothamBold
local help = label("Description", "Hồi 70% HP cho chủ · hồi chiêu 119 giây", UDim2.fromOffset(14, 125), UDim2.new(1, -28, 0, 18), 10)
help.TextColor3 = MUTED

-- A local-only overhead bar follows the owner's streamed pet. Other clients
-- receive neither a duplicate bar nor a health display for an unowned pet.
local billboard = Instance.new("BillboardGui")
billboard.Name = "PetHealthBillboard"
billboard.Size = UDim2.fromOffset(130, 35)
billboard.StudsOffsetWorldSpace = Vector3.new(0, 5.2, 0)
billboard.MaxDistance = 75
billboard.AlwaysOnTop = false
billboard.Enabled = false
billboard.Parent = playerGui
local overhead = Instance.new("TextLabel")
overhead.Name = "HealthText"
overhead.Size = UDim2.new(1, 0, 0, 21)
overhead.BackgroundColor3 = INK
overhead.BackgroundTransparency = .15
overhead.BorderSizePixel = 0
overhead.TextColor3 = CREAM
overhead.TextSize = 11
overhead.Font = Enum.Font.GothamMedium
overhead.Parent = billboard
round(overhead, 5)
local overheadTrack = track:Clone()
overheadTrack.Position = UDim2.fromOffset(4, 25)
overheadTrack.Size = UDim2.new(1, -8, 0, 5)
overheadTrack.Parent = billboard
local overheadFill = overheadTrack.Fill

local function humanoid()
	local character = player.Character
	if character == removingCharacter then return nil end
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function menuOpen()
	if GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then return true end
	local training = playerGui:FindFirstChild("HunDinoTrainingHUD")
	if training and training.Enabled then
		for _, name in {"WeaponSelection", "HubPanel", "BaseTransitMenu"} do
			local menu = training:FindFirstChild(name)
			if menu and menu:IsA("GuiObject") and menu.Visible then return true end
		end
	end
	local viewer = playerGui:FindFirstChild("HuntingMapViewer")
	local picker = viewer and viewer:FindFirstChild("ZonePicker")
	return viewer ~= nil and viewer.Enabled and picker ~= nil and picker.Visible
end

local function healAvailability(now)
	local hum = humanoid()
	if not hum or hum.Health <= 0 then return false, "Chờ hồi sinh" end
	if player:GetAttribute("AdminFlying") == true then return false, "Đang bay · Pet tạm nghỉ" end
	if player:GetAttribute("InHunting") ~= true and player:GetAttribute("InTraining") ~= true then
		return false, "Dùng tại bãi tập hoặc khu săn"
	end
	if numberAttribute("PetMaxHealth", 0) <= 0 then return false, "Đang chờ Pet" end
	local stunned = numberAttribute("PetStunnedUntil", 0) - now
	if stunned > 0 or player:GetAttribute("PetState") == "Stunned" or numberAttribute("PetHealth", 0) <= 1 then
		return false, string.format("Pet đang hồi phục (%ds)", math.max(0, math.ceil(stunned)))
	end
	local state = player:GetAttribute("PetState")
	if player:GetAttribute("PetHealCasting") == true or state == "HealApproach" or state == "Healing" then
		return false, if state == "HealApproach" then "Pet đang tới..." else "Đang hồi..."
	end
	local cooldown = numberAttribute("PetHealReadyAt", 0) - now
	if cooldown > 0 then return false, string.format("Hồi chiêu · %ds", math.ceil(cooldown)) end
	if hum.Health >= hum.MaxHealth - .001 then return false, "Bạn đã đầy máu" end
	if menuOpen() then return false, "Đóng menu để gọi Pet" end
	return true, "[H] Gọi Pet Hồi Máu (+70% HP)"
end

local stateText = {
	Following = "Đang theo",
	Attacking = "Chiến đấu",
	Returning = "Đang trở về chủ",
	Recovering = "Đang rút lui · tự hồi máu",
	HealApproach = "Đang mang thuốc tới chủ",
	Healing = "Đang hồi máu cho chủ",
	Waiting = "Đang chờ chủ",
	Idle = "Đang nghỉ",
	Blocked = "Đường bị chắn · đang tìm lối",
}

local function refresh()
	local hum = humanoid()
	local maximum = numberAttribute("PetMaxHealth", 0)
	local hp = numberAttribute("PetHealth", -1)
	panel.Visible = hum ~= nil and hum.Health > 0 and maximum > 0 and hp >= 0
	if not panel.Visible then billboard.Enabled = false; billboard.Adornee = nil; return end
	local size = gui.AbsoluteSize
	if size.X > 0 and size.Y > 0 then
		local compact = size.X < 1000 or size.Y < 560
		if compact then
			scale.Scale = math.min(.6, (size.X - 32) / 680, (size.Y - 60) / 390)
			panel.Position = UDim2.new(0, 12, 1, -92)
		else
			scale.Scale = math.min(1, math.max(.5, (size.X - 40) / 680), math.max(.5, (size.Y - 80) / 500))
			panel.Position = UDim2.new(0, 20, 1, -154)
		end
	end
	local now = workspace:GetServerTimeNow()
	local ratio = math.clamp(hp / maximum, 0, 1)
	local color = if ratio <= .25 then RED elseif ratio <= .5 then AMBER else GREEN
	fill.Size = UDim2.fromScale(ratio, 1)
	fill.BackgroundColor3 = color
	healthText.Text = string.format("%d / %d HP", math.ceil(math.max(0, hp)), math.ceil(maximum))
	local stunned = numberAttribute("PetStunnedUntil", 0) - now
	local state = player:GetAttribute("PetState")
	if stunned > 0 or state == "Stunned" or hp <= 1 then
		status.Text = string.format("Choáng · hồi phục sau %ds", math.max(0, math.ceil(stunned)))
		status.TextColor3 = RED
	elseif player:GetAttribute("HuntCaptureActive") == true then
		status.Text = "Ngừng đánh (Đang bắt)"
		status.TextColor3 = AMBER
	elseif player:GetAttribute("AdminFlying") == true then
		status.Text = "Chờ chủ đáp xuống đất"
		status.TextColor3 = MUTED
	else
		status.Text = stateText[state] or "Pet đồng hành cùng bạn"
		local healing = numberAttribute("PetHealingUntil", 0) - now
		if state == "Healing" and healing > 0 then
			status.Text ..= string.format(" · %ds", math.ceil(healing))
		end
		status.TextColor3 = MUTED
	end
	local canHeal, reason = healAvailability(now)
	healButton.Text = reason
	healButton.Active = canHeal
	healButton.Selectable = canHeal
	healButton.AutoButtonColor = false
	healButton.BackgroundColor3 = if canHeal then Theme.Colors.Card else INK
	healButton.TextColor3 = if canHeal then CREAM else MUTED
	local cooldown = math.max(0, numberAttribute("PetHealReadyAt", 0) - now)
	local recovering = stunned > 0 or state == "Stunned" or hp <= 1
	cooldownRing:Set(if recovering then math.clamp(stunned / 30, 0, 1) elseif cooldown > 0 then math.clamp(cooldown / 119, 0, 1) else 1, if recovering then RED elseif cooldown > 0 then Theme.Colors.Stamina else GREEN)
	cooldownText.Text = if recovering then string.format("%ds", math.max(0, math.ceil(stunned))) elseif cooldown > 0 then string.format("%ds", math.ceil(cooldown)) else "H"
	cooldownText.TextColor3 = if recovering then RED elseif cooldown > 0 then Theme.Colors.Stamina else GREEN
	local pets = workspace:FindFirstChild("TrainingPets")
	local pet = pets and pets:FindFirstChild("Pet_" .. player.UserId)
	local root = pet and (pet.PrimaryPart or pet:FindFirstChild("Root"))
	billboard.Adornee = if root and root:IsA("BasePart") then root else nil
	billboard.Enabled = billboard.Adornee ~= nil and player:GetAttribute("AdminFlying") ~= true
	overhead.Text = if stunned > 0 then string.format("Pet · choáng %ds", math.ceil(stunned)) else "Pet · " .. healthText.Text
	overheadFill.Size = fill.Size
	overheadFill.BackgroundColor3 = color
end

local function requestHeal()
	local now = workspace:GetServerTimeNow()
	if not alive or not panel.Visible or now < nextRequestAt or not healAvailability(now) then return end
	nextRequestAt = now + .3
	remote:FireServer("PetHeal")
end

connect(healButton.Activated, requestHeal)
connect(UserInputService.InputBegan, function(input, processed)
	if processed or input.KeyCode ~= Enum.KeyCode.H then return end
	requestHeal()
end)
for _, name in {"PetHealth", "PetMaxHealth", "PetState", "PetStunnedUntil", "PetHealReadyAt", "PetHealCasting", "PetHealingUntil", "AdminFlying", "InHunting", "InTraining", "HuntCaptureActive"} do
	connect(player:GetAttributeChangedSignal(name), refresh)
end
connect(player.CharacterAdded, function()
	removingCharacter = nil
	refresh()
end)
connect(player.CharacterRemoving, function(character)
	removingCharacter = character
	panel.Visible = false
	billboard.Enabled = false
	billboard.Adornee = nil
end)
connect(RunService.Heartbeat, function(dt)
	elapsed += dt
	if elapsed < .1 then return end
	elapsed = 0
	refresh()
end)
script.Destroying:Connect(function()
	alive = false
	for _, connection in connections do connection:Disconnect() end
	cooldownRing:Destroy()
	gui:Destroy()
	billboard:Destroy()
end)
refresh()
