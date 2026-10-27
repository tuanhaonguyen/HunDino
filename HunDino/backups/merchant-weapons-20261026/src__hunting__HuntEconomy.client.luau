-- P1-E merchant, crafting station and harvesting UI. The shared equipment
-- inventory displays all carried items; receipts and harvests belong to the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Input = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Theme = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UITheme"))
local C = Theme.Colors
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("HunDinoEconomyAction")
local connections = {}
local alive, elapsed, nextMutationAt = true, 0, 0
local context, removingCharacter, ownedHold
local pendingToken, pendingUntil, toastUntil
local snapshot = {Coins = 0, Materials = {}, Stored = {}, HammerLevel = 1, Revision = -1}
local INK, CREAM, MUTED, GREEN, AMBER = C.Panel, C.Text, C.Muted, C.Health, C.Gold

local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
	return connection
end
local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function count(value, fallback)
	return if finite(value) then math.max(0, math.floor(value)) else (fallback or 0)
end
local function numberAttribute(name, fallback)
	local value = player:GetAttribute(name)
	return if finite(value) then value else fallback
end
local function rounded(item, radius)
	Theme.round(item, radius or 8)
end
local function frame(name, parent, size, position, anchor)
	local item = Instance.new("Frame")
	item.Name = name; item.Size = size; item.Position = position
	item.AnchorPoint = anchor or Vector2.zero
	item.BackgroundColor3 = INK; item.BackgroundTransparency = .04
	item.BorderSizePixel = 0; item.ZIndex = parent:IsA("GuiObject") and parent.ZIndex + 1 or 2
	item.Parent = parent; Theme.panel(item)
	return item
end
local function label(name, parent, text, position, size, textSize)
	local item = Instance.new("TextLabel")
	item.Name = name; item.Position = position; item.Size = size
	item.BackgroundTransparency = 1; item.Font = Enum.Font.GothamMedium
	item.TextColor3 = CREAM; item.Text = text; item.TextSize = textSize or 13
	item.TextXAlignment = Enum.TextXAlignment.Left; item.TextYAlignment = Enum.TextYAlignment.Center
	item.TextWrapped = true; item.ZIndex = parent:IsA("GuiObject") and parent.ZIndex + 1 or 2
	item.Parent = parent
	return item
end
local function button(name, parent, text, position, size)
	local item = Instance.new("TextButton")
	item.Name = name; item.Position = position; item.Size = size
	item.BackgroundColor3 = Color3.fromRGB(60, 112, 76); item.BorderSizePixel = 0
	item.TextColor3 = CREAM; item.Font = Enum.Font.GothamMedium; item.TextSize = 13
	item.Text = text; item.TextWrapped = true
	item.ZIndex = parent:IsA("GuiObject") and parent.ZIndex + 1 or 2
	item.Parent = parent; Theme.button(item)
	return item
end
local function enabled(item, value)
	item.Active = value; item.Selectable = value; item.AutoButtonColor = false
	item.BackgroundColor3 = C.Card; item.BackgroundTransparency = if value then 0 else .4
	item.TextColor3 = if value then CREAM else MUTED
end

local gui = Instance.new("ScreenGui")
gui.Name = "HunDinoEconomy"; gui.ResetOnSpawn = false
gui.DisplayOrder = 14; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = playerGui
local shade = Instance.new("TextButton")
shade.Name = "ModalShield"; shade.Size = UDim2.fromScale(1, 1); shade.Text = ""
shade.BackgroundColor3 = Color3.fromRGB(7, 15, 12); shade.BackgroundTransparency = .34
shade.BorderSizePixel = 0; shade.AutoButtonColor = false; shade.ZIndex = 5
shade.Visible = false; shade.Parent = gui

-- Existing weapon/quest menu guards read this exact Visible flag.
local panel = frame("Panel", gui, UDim2.fromOffset(580, 460), UDim2.fromScale(.5, .5), Vector2.new(.5, .5))
panel.ZIndex = 6; panel.Visible = false; panel.Active = true
local panelScale = Instance.new("UIScale"); panelScale.Parent = panel
local heading = label("Title", panel, "KHO THỬ TRONG PHIÊN", UDim2.fromOffset(22, 15), UDim2.fromOffset(480, 30), 20)
heading.TextColor3 = C.Gold; heading.Font = Enum.Font.GothamBold
local close = button("Close", panel, "×", UDim2.new(1, -52, 0, 16), UDim2.fromOffset(30, 30))
local saveStatus=label("AccountSaveStatus", panel, "", UDim2.fromOffset(22, 50), UDim2.new(1, -44, 0, 26), 12)
saveStatus.TextColor3 = AMBER
local coins = label("Coins", panel, "XU: 0", UDim2.fromOffset(22, 86), UDim2.fromOffset(250, 26), 18)
coins.TextColor3 = AMBER
local hammer = label("Hammer", panel, "Búa cấp 1", UDim2.fromOffset(296, 86), UDim2.fromOffset(262, 26), 14)
label("StockTitle", panel, "TRONG KHO", UDim2.fromOffset(22, 127), UDim2.fromOffset(220, 24), 13).TextColor3 = MUTED
local stockLabels = {}
local rows = {
	{"Skin", "Da", "Materials"}, {"Tooth", "Răng", "Materials"}, {"Scale", "Vảy", "Materials"},
	{"Bone", "Xương", "Materials"}, {"Iron", "Sắt", "Materials"}, {"RawTrap", "Bẫy thô", "Stored"},
	{"IronTrap", "Bẫy sắt", "Stored"}, {"SleepPotion", "Thuốc ngủ", "Stored"},
}
for index, row in rows do
	stockLabels[row[1]] = label(row[1], panel, row[2] .. " · 0", UDim2.fromOffset(22, 156 + (index - 1) * 25), UDim2.fromOffset(242, 24), 13)
end
local activityTitle = label("ActivityTitle", panel, "VẬT TƯ LƯỢT SĂN", UDim2.fromOffset(296, 127), UDim2.fromOffset(262, 24), 13)
activityTitle.TextColor3 = MUTED
local description = label("Description", panel, "", UDim2.fromOffset(296, 157), UDim2.fromOffset(262, 88), 13)
description.TextYAlignment = Enum.TextYAlignment.Top
local buyTrap = button("MerchantBuyTrap", panel, "MUA BẪY THÔ · 10 XU", UDim2.fromOffset(296, 250), UDim2.fromOffset(262, 42))
local buyPotion = button("MerchantBuyPotion", panel, "MUA THUỐC NGỦ · 10 XU", UDim2.fromOffset(296, 306), UDim2.fromOffset(262, 42))
local craftTrap = button("CraftIronTrap", panel, "CHẾ BẪY SẮT\n1 bẫy thô + 1 sắt", UDim2.fromOffset(296, 250), UDim2.fromOffset(262, 42))
local upgrade = button("UpgradeHammer", panel, "NÂNG BÚA CẤP 2\n2 xương + 2 sắt · +15% sát thương", UDim2.fromOffset(296, 306), UDim2.fromOffset(262, 48))
local recipeStatus = label("RecipeMaterials", panel, "", UDim2.fromOffset(296, 357), UDim2.fromOffset(262, 20), 11)
local activeItems = label("ActiveRunItems", panel, "", UDim2.fromOffset(296, 252), UDim2.fromOffset(262, 102), 14)
activeItems.TextYAlignment = Enum.TextYAlignment.Top
local notice = label("Notice", panel, "", UDim2.fromOffset(22, 374), UDim2.new(1, -44, 0, 50), 12)
notice.TextColor3 = AMBER; notice.TextYAlignment = Enum.TextYAlignment.Top
label("Hint", panel, "Đồ nhặt và mổ được giữ trong kho dù cuộc săn thất bại.", UDim2.fromOffset(22, 430), UDim2.new(1, -44, 0, 18), 10).TextColor3 = MUTED
local toast = frame("NoticeToast", gui, UDim2.fromOffset(330, 58), UDim2.fromOffset(20, 164))
toast.Visible = false
local toastText = label("Message", toast, "", UDim2.fromOffset(12, 6), UDim2.new(1, -24, 1, -12), 12)
toastText.TextColor3 = AMBER

local harvest = frame("HarvestHUD", gui, UDim2.fromOffset(420, 84), UDim2.new(.5, 0, 0, 432), Vector2.new(.5, 0))
harvest.Visible = false
local harvestScale = Instance.new("UIScale"); harvestScale.Parent = harvest
local carveButton = button("Carve", harvest, "GIỮ G · MỔ XÁC (1,5s)", UDim2.fromOffset(12, 10), UDim2.fromOffset(228, 30))
local carved = label("Carves", harvest, "Đã mổ 0 / 3", UDim2.fromOffset(252, 10), UDim2.fromOffset(156, 30), 13)
carved.TextXAlignment = Enum.TextXAlignment.Right
local harvestHint = label("Hint", harvest, "Đến gần xác và cất vũ khí để mổ.", UDim2.fromOffset(12, 44), UDim2.new(1, -24, 0, 24), 11)
harvestHint.TextColor3 = MUTED
local track = frame("Progress", harvest, UDim2.new(1, -24, 0, 4), UDim2.fromOffset(12, 73))
track.ClipsDescendants = true; track.BackgroundColor3 = C.Card
local trackBorder=track:FindFirstChildOfClass("UIStroke"); if trackBorder then trackBorder:Destroy() end
local fill = Instance.new("Frame")
fill.Name = "Fill"; fill.Size = UDim2.fromScale(0, 1); fill.BackgroundColor3 = AMBER
fill.BorderSizePixel = 0; fill.ZIndex = track.ZIndex + 1; fill.Parent = track; rounded(fill, 3)

local function characterParts()
	local character = player.Character
	if not character or character == removingCharacter then return nil, nil end
	return character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end
local function visibleMenu(guiName, names)
	local source = playerGui:FindFirstChild(guiName)
	if not source or not source:IsA("ScreenGui") or not source.Enabled then return false end
	for _, name in names do
		local item = source:FindFirstChild(name)
		if item and item:IsA("GuiObject") and item.Visible then return true end
	end
	return false
end
local function otherMenuOpen()
	return GuiService.MenuIsOpen or Input:GetFocusedTextBox() ~= nil
		or visibleMenu("HunDinoTrainingHUD", {"WeaponSelection", "HubPanel", "BaseTransitMenu"})
		or visibleMenu("HuntingMapViewer", {"ZonePicker"})
		or visibleMenu("HunDinoHuntQuest", {"QuestBoard", "ResultModal"})
end
local function cancelHold()
	if not ownedHold then return end
	ownedHold = nil
	if alive then remote:FireServer("CarveCancel") end
end
local function hidePanel()
	panel.Visible = false; shade.Visible = false
end
local function showNotice(value)
	if type(value) ~= "string" then return end
	notice.Text = value
	if value ~= "" then toastText.Text = value; toastUntil = workspace:GetServerTimeNow() + 5 end
end
local function currentAction()
	local value = player:GetAttribute("HuntHarvestAction")
	return value == "Carve" or value == true
end
local function corpseReady()
	return (player:GetAttribute("QuestState")=="Harvest" and player:GetAttribute("QuestResult")=="Defeated")
		or player:GetAttribute("HuntExplorationHarvest")==true
end
local function lootRunId()
	return if player:GetAttribute("HuntExplorationHarvest")==true then player:GetAttribute("HuntLootRunId") else player:GetAttribute("QuestRunId")
end
local function canCarve()
	local hum = characterParts()
	return alive and hum ~= nil and hum.Health > 0 and player:GetAttribute("InHunting") == true
		and corpseReady()
		and player:GetAttribute("AdminFlying") ~= true and player:GetAttribute("Drawn") ~= true
		and not panel.Visible and not otherMenuOpen()
end
local function startCarve(owner)
	if ownedHold or not canCarve() or currentAction() or player:GetAttribute("HuntCarveAvailable") ~= true then return end
	ownedHold = {Owner = owner, Observed = false, RunId = lootRunId()}
	remote:FireServer("CarveStart")
end
local function availableToken()
	local token = snapshot.OperationToken
	return type(token) == "string" and token ~= "" and token or nil
end
local function requestMutation(action)
	local now = workspace:GetServerTimeNow()
	local hum = characterParts()
	local token = availableToken()
	if not panel.Visible or not token or now < nextMutationAt or not hum or hum.Health <= 0
		or player:GetAttribute("AdminFlying") == true or otherMenuOpen() then return end
	if pendingToken == token and pendingUntil and now < pendingUntil then return end
	if (action == "MerchantBuyTrap" or action == "MerchantBuyPotion") and context ~= "Merchant" then return end
	if (action == "CraftIronTrap" or action == "UpgradeHammer") and context ~= "Craft" then return end
	nextMutationAt = now + .35; pendingToken = token; pendingUntil = now + 2
	notice.Text = "Đang xử lý..."
	remote:FireServer(action, token) -- A receipt token is issued/rotated only by the server.
end
local function updatePanel()
	coins.Text = string.format("XU: %d", count(snapshot.Coins))
	local level = count(snapshot.HammerLevel, 1)
	hammer.Text = if level >= 2 then "Búa cấp 2 · sát thương +15%" else "Búa cấp 1"
	for _, row in rows do
		local stock = snapshot[row[3]]
		stockLabels[row[1]].Text = string.format("%s · %d", row[2], count(type(stock) == "table" and stock[row[1]]))
	end
	local merchant, crafting = context == "Merchant", context == "Craft"
	heading.Text = if merchant then "THƯƠNG NHÂN · KHO TÀI KHOẢN" elseif crafting then "CHẾ TẠO · KHO TÀI KHOẢN" else "KHO TÀI KHOẢN"
 saveStatus.Text=player:GetAttribute("ProfileStatusText") or "Đang tải tiến trình…"
 if player:GetAttribute("ProfileStorageMode")=="TestMemory" then saveStatus.Text="DỮ LIỆU TEST · không lưu qua Stop/Play" end
	activityTitle.Text = if merchant then "VẬT TƯ THƯƠNG NHÂN" elseif crafting then "BÀN CHẾ TẠO TẠI CĂN CỨ" else "VẬT TƯ LƯỢT SĂN"
	description.Text = if merchant then "Bẫy thô cần ghép với sắt tại căn cứ để thành bẫy sắt. Vật tư đã mua ở lại kho cho lượt sau."
		elseif crafting then "Chế từng bẫy sắt hoặc nâng búa một lần. Công thức dùng nguyên liệu đang có trong kho."
		else "Bẫy sắt và thuốc trong kho được chuyển vào lượt săn khi nhận nhiệm vụ. Vật tư chưa dùng được trả về."
	buyTrap.Visible = merchant; buyPotion.Visible = merchant; craftTrap.Visible = crafting; upgrade.Visible = crafting
	activeItems.Visible = not merchant and not crafting
	local run = snapshot.ActiveRun
	activeItems.Text = if type(run) == "table" and type(run.Id) == "string" then string.format("ĐANG MANG TRONG LƯỢT SĂN\nBẫy sắt · %d\nThuốc ngủ · %d", count(run.IronTraps), count(run.Potions)) else "Chưa có lượt săn đang diễn ra.\n\nNhặt sắt trong khu săn để chế bẫy và nâng búa."
	local now = workspace:GetServerTimeNow()
	local ready = player:GetAttribute("ProfileReady")==true and player:GetAttribute("ProfileSaveState")~="Error"
  and player:GetAttribute("ProfileSaveState")~="Saving" and availableToken() ~= nil and now >= nextMutationAt
		and not (pendingToken == availableToken() and pendingUntil and now < pendingUntil)
	local materials = if type(snapshot.Materials) == "table" then snapshot.Materials else {}
	local stored = if type(snapshot.Stored) == "table" then snapshot.Stored else {}
	recipeStatus.Visible = crafting
	recipeStatus.Text = string.format("Bẫy thô %d/1 · Sắt %d/1  |  Xương %d/2 · Sắt %d/2", count(stored.RawTrap), count(materials.Iron), count(materials.Bone), count(materials.Iron))
	recipeStatus.TextColor3 = if count(stored.RawTrap)>=1 and count(materials.Iron)>=1 then GREEN else C.Warning
	enabled(buyTrap, ready and count(snapshot.Coins) >= 10)
	enabled(buyPotion, ready and count(snapshot.Coins) >= 10)
	enabled(craftTrap, ready and count(stored.RawTrap) >= 1 and count(materials.Iron) >= 1)
	enabled(upgrade, ready and level < 2 and count(materials.Bone) >= 2 and count(materials.Iron) >= 2)
	if level >= 2 then upgrade.Text = "BÚA ĐÃ ĐẠT CẤP 2 · +15% SÁT THƯƠNG" end
end
local function applySnapshot(dto)
	if type(dto) ~= "table" then return end
	local revision = if finite(dto.Revision) then dto.Revision else snapshot.Revision
	if revision < snapshot.Revision then return end
	local previousToken = snapshot.OperationToken
	for _, key in {"Coins", "Materials", "Stored", "HammerLevel", "ActiveRun", "OperationToken"} do
		snapshot[key] = dto[key]
	end
	snapshot.Revision = revision
	if snapshot.OperationToken ~= previousToken then pendingToken = nil; pendingUntil = nil end
	if type(dto.Notice) == "string" then showNotice(dto.Notice) end
	updatePanel()
end
local function refresh()
	if not alive then return end
	local now = workspace:GetServerTimeNow()
	local hum = characterParts()
	local state = player:GetAttribute("QuestState")
	local inHunting = player:GetAttribute("InHunting") == true
	local flying = player:GetAttribute("AdminFlying") == true
	local live = hum ~= nil and hum.Health > 0
	toast.Position = UDim2.fromOffset(20, if inHunting then 306 else 164)
	toast.Visible = toastUntil ~= nil and now < toastUntil and live and not panel.Visible and not otherMenuOpen()
	if panel.Visible and (not live or flying or state == "Preparing" or state == "Returning"
		or otherMenuOpen() or ((context == "Merchant" or context == "Craft") and inHunting)) then hidePanel() end
	if ownedHold then
		if currentAction() then ownedHold.Observed = true end
		if not canCarve() or ownedHold.RunId ~= lootRunId() then cancelHold()
		elseif ownedHold.Observed and not currentAction() then ownedHold = nil end
	end
	if panel.Visible then updatePanel() end
	local camera = workspace.CurrentCamera
	if camera then
		local size = gui.AbsoluteSize
		panelScale.Scale = math.min(1, math.max(.45, (size.X - 32) / 580), math.max(.45, (size.Y - 48) / 460))
		local scale = math.min(1, (size.X - 32) / 420, (size.Y - 48) / 460)
		harvestScale.Scale = scale
		local compact=size.X<1000 or size.Y<560
		harvest.AnchorPoint = if compact then Vector2.new(.5,1) else Vector2.new(1,1)
		harvest.Position = if compact then UDim2.new(.5,0,1,-12) else UDim2.new(1,-20,1,-24)
	end
	harvest.Visible = live and inHunting and corpseReady()
		and not flying and not panel.Visible and not otherMenuOpen()
	if not harvest.Visible then return end
	local completed = math.clamp(count(player:GetAttribute("HuntCarves")), 0, 3)
	carved.Text = string.format("Đã mổ %d / 3", completed)
	local action = currentAction()
	local left = math.max(0, numberAttribute("HuntHarvestEnds", now) - now)
	local duration = math.max(.01, numberAttribute("HuntHarvestDuration", 1.5))
	carveButton.Text = if action then string.format("GIỮ G · ĐANG MỔ %.1fs", left)
		elseif completed >= 3 then "ĐÃ MỔ ĐỦ 3 LƯỢT" else "GIỮ G · MỔ XÁC (1,5s)"
	enabled(carveButton, canCarve() and completed < 3 and (action or player:GetAttribute("HuntCarveAvailable") == true))
	fill.Size = UDim2.fromScale(if action then math.clamp(1 - left / duration, 0, 1) else 0, 1)
	harvestHint.Text = if completed >= 3 then "Đã nhận đủ nguyên liệu mổ. Có thể tiếp tục nhặt đồ hoặc về sảnh."
		elseif player:GetAttribute("Drawn") == true then "Nhấn R cất vũ khí trước khi mổ xác."
		elseif action then "Giữ G/nút · đứng yên; thả để hủy."
		elseif player:GetAttribute("HuntCarveAvailable") == true then "Giữ G 1,5 giây để nhận một phần nguyên liệu."
		else "Đến gần xác và cất vũ khí để mổ."
end

connect(close.Activated, hidePanel)
connect(shade.Activated, hidePanel)
for _, item in {buyTrap, buyPotion, craftTrap, upgrade} do
	connect(item.Activated, function() requestMutation(item.Name) end)
end
connect(carveButton.InputBegan, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then startCarve(input) end
end)
connect(Input.InputBegan, function(input, processed)
	if processed or Input:GetFocusedTextBox() or GuiService.MenuIsOpen then return end
	if input.KeyCode == Enum.KeyCode.G then startCarve(Enum.KeyCode.G) end
end)
connect(Input.InputEnded, function(input)
	if not ownedHold then return end
	local owner = ownedHold.Owner
	if owner == input.KeyCode or owner == input
		or (typeof(owner) == "Instance" and owner:IsA("InputObject") and owner.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1) then cancelHold() end
end)
connect(Input.WindowFocusReleased, cancelHold)
connect(Input.TextBoxFocused, cancelHold)
connect(GuiService.MenuOpened, function() cancelHold(); hidePanel() end)
connect(player.CharacterRemoving, function(character)
	removingCharacter = character; cancelHold(); hidePanel(); harvest.Visible = false
end)
connect(player.CharacterAdded, function() removingCharacter = nil; refresh() end)
connect(remote.OnClientEvent, function(event, dto)
	if event == "Snapshot" then applySnapshot(dto)
	elseif event == "Notice" then
		showNotice(dto)
		pendingToken = nil; pendingUntil = nil; updatePanel()
	elseif event == "Open" and type(dto) == "table" then
		if dto.Context == "Inventory" then
			-- EquipmentInventory owns this view, including legacy OpenInventory responses.
			applySnapshot(dto); cancelHold(); hidePanel()
			return
		end
		local hum = characterParts()
		if not hum or hum.Health <= 0 or player:GetAttribute("AdminFlying") == true or otherMenuOpen() then return end
		if dto.Context ~= "Merchant" and dto.Context ~= "Craft" then return end
		cancelHold(); context = dto.Context; applySnapshot(dto)
		panel.Visible = true; shade.Visible = true; refresh()
	end
end)
for _, name in {"QuestRunId", "QuestState", "QuestResult", "HuntExplorationHarvest", "HuntLootRunId", "InHunting", "InTraining", "AdminFlying", "Drawn", "HuntCarves", "HuntHarvestAction", "HuntHarvestEnds", "HuntHarvestDuration", "HuntCarveAvailable"} do
	connect(player:GetAttributeChangedSignal(name), refresh)
end
connect(RunService.Heartbeat, function(dt)
	elapsed += dt
	if elapsed < .1 then return end
	elapsed = 0; refresh()
end)
script.Destroying:Connect(function()
	cancelHold(); alive = false
	for _, connection in connections do connection:Disconnect() end
	gui:Destroy()
end)
refresh()
