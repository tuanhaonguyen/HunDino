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
gui.DisplayOrder = 80; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = playerGui
local shade = Instance.new("TextButton")
shade.Name = "ModalShield"; shade.Size = UDim2.fromScale(1, 1); shade.Text = ""
shade.BackgroundColor3 = Color3.fromRGB(7, 15, 12); shade.BackgroundTransparency = .34
shade.BorderSizePixel = 0; shade.AutoButtonColor = false; shade.ZIndex = 5
shade.Visible = false; shade.Parent = gui

-- A single shop surface is used by the icon, merchant and owned crafting table.
-- Layer order is assigned before children are created.
local selectedWeapon = player:GetAttribute("WeaponId") or "Hammer"
local selectedTab = "Supplies"
local weaponOrder = {"Hammer", "SwordShield", "Katana", "Glaive", "DualDaggers", "Bow", "GreatAxe"}
local weaponNames = {Hammer="Búa tạ", SwordShield="Kiếm & khiên", Katana="Katana", Glaive="Thương cán dài", DualDaggers="Song dao", Bow="Cung", GreatAxe="Rìu đại"}
local panel = frame("Panel", gui, UDim2.fromOffset(820, 586), UDim2.fromScale(.5, .5), Vector2.new(.5, .5))
panel.ZIndex = 6; panel.Visible = false; panel.Active = true
panel.BackgroundTransparency = .04
local panelScale = Instance.new("UIScale"); panelScale.Parent = panel
local heading = label("Title", panel, "THƯƠNG NHÂN", UDim2.fromOffset(24, 16), UDim2.fromOffset(700, 32), 22)
heading.TextColor3 = C.Gold; heading.Font = Enum.Font.GothamBold
local close = button("Close", panel, "×", UDim2.new(1, -56, 0, 16), UDim2.fromOffset(32, 32))
local coins = label("Coins", panel, "XU  0", UDim2.fromOffset(24, 54), UDim2.fromOffset(350, 30), 19)
coins.TextColor3 = C.Gold
local locationHint = label("LocationHint", panel, "", UDim2.fromOffset(24, 89), UDim2.new(1, -48, 0, 38), 13)
locationHint.TextColor3 = MUTED
local supplyTab = button("SuppliesTab", panel, "VẬT TƯ & CHẾ TẠO", UDim2.fromOffset(24, 139), UDim2.fromOffset(376, 40))
local weaponTab = button("WeaponsTab", panel, "NÂNG CẤP VŨ KHÍ", UDim2.fromOffset(412, 139), UDim2.fromOffset(384, 40))
label("StockTitle", panel, "KHO CỦA BẠN", UDim2.fromOffset(24, 197), UDim2.fromOffset(188, 26), 13).TextColor3 = C.Gold
local stockLabels = {}
local rows = {
 {"Skin", "Da", "Materials"}, {"Tooth", "Răng", "Materials"}, {"Scale", "Vảy", "Materials"},
 {"Bone", "Xương", "Materials"}, {"Iron", "Sắt", "Materials"}, {"RawTrap", "Bẫy thô", "Stored"},
 {"IronTrap", "Bẫy sắt", "Stored"}, {"SleepPotion", "Thuốc ngủ", "Stored"},
}
for index, row in rows do
 stockLabels[row[1]] = label(row[1], panel, row[2].." · 0", UDim2.fromOffset(24, 228+(index-1)*31), UDim2.fromOffset(188, 28), 14)
end
local supplies = Instance.new("Frame")
supplies.Name="Supplies";supplies.BackgroundTransparency=1;supplies.Position=UDim2.fromOffset(236,197)
supplies.Size=UDim2.fromOffset(560,308);supplies.ZIndex=panel.ZIndex+1;supplies.Parent=panel
local function supplyCard(name, title, detail, y)
 local card=frame(name,supplies,UDim2.fromOffset(560,94),UDim2.fromOffset(0,y))
 card.BackgroundColor3=C.Card;card.BackgroundTransparency=.12
 label("Name",card,title,UDim2.fromOffset(16,10),UDim2.fromOffset(310,26),16).TextColor3=C.Gold
 label("Detail",card,detail,UDim2.fromOffset(16,39),UDim2.fromOffset(310,42),12).TextColor3=MUTED
 return card
end
local trapCard=supplyCard("RawTrapCard","BẪY THÔ","Vật tư dùng để chế bẫy sắt. Giá: 10 xu.",0)
local buyTrap=button("MerchantBuyTrap",trapCard,"MUA · 10 XU",UDim2.fromOffset(350,25),UDim2.fromOffset(192,44))
local potionCard=supplyCard("PotionCard","THUỐC NGỦ","Dùng để bắt sống khủng long suy yếu. Giá: 10 xu.",104)
local buyPotion=button("MerchantBuyPotion",potionCard,"MUA · 10 XU",UDim2.fromOffset(350,25),UDim2.fromOffset(192,44))
local ironCard=supplyCard("IronTrapCard","CHẾ BẪY SẮT","",208)
local recipeStatus=ironCard.Detail
local craftTrap=button("CraftIronTrap",ironCard,"CHẾ TẠO",UDim2.fromOffset(350,25),UDim2.fromOffset(192,44))
local weapons=Instance.new("Frame")
weapons.Name="Weapons";weapons.BackgroundTransparency=1;weapons.Position=UDim2.fromOffset(236,197)
weapons.Size=UDim2.fromOffset(560,308);weapons.ZIndex=panel.ZIndex+1;weapons.Parent=panel
local weaponList=Instance.new("ScrollingFrame")
weaponList.Name="WeaponList";weaponList.Position=UDim2.fromOffset(0,0);weaponList.Size=UDim2.fromOffset(224,308)
weaponList.BackgroundTransparency=1;weaponList.BorderSizePixel=0;weaponList.ScrollBarThickness=4
weaponList.ScrollBarImageColor3=C.Gold;weaponList.CanvasSize=UDim2.fromOffset(0,#weaponOrder*43)
weaponList.ZIndex=weapons.ZIndex+1;weaponList.Parent=weapons
local weaponButtons={}
for index,id in weaponOrder do
 local b=button("Select_"..id,weaponList,"",UDim2.fromOffset(0,(index-1)*43),UDim2.fromOffset(212,39))
 b.TextSize=13;weaponButtons[id]=b
end
local weaponDetail=frame("WeaponDetail",weapons,UDim2.fromOffset(320,308),UDim2.fromOffset(240,0))
weaponDetail.BackgroundColor3=C.Card
local weaponTitle=label("WeaponName",weaponDetail,"",UDim2.fromOffset(18,12),UDim2.fromOffset(284,28),19)
weaponTitle.TextColor3=C.Gold
local weaponLevelLabel=label("WeaponLevel",weaponDetail,"",UDim2.fromOffset(18,44),UDim2.fromOffset(284,26),14)
local weaponBonus=label("WeaponBonus",weaponDetail,"",UDim2.fromOffset(18,78),UDim2.fromOffset(284,48),13)
label("RecipeTitle",weaponDetail,"NGUYÊN LIỆU NÂNG CẤP",UDim2.fromOffset(18,132),UDim2.fromOffset(284,22),12).TextColor3=MUTED
local boneProgress=label("BoneProgress",weaponDetail,"",UDim2.fromOffset(18,158),UDim2.fromOffset(284,24),14)
local ironProgress=label("IronProgress",weaponDetail,"",UDim2.fromOffset(18,186),UDim2.fromOffset(284,24),14)
local upgrade=button("UpgradeWeapon",weaponDetail,"NÂNG LÊN CẤP 2",UDim2.fromOffset(18,222),UDim2.fromOffset(284,44))
label("IndependentHint",weaponDetail,"Cấp nâng riêng cho từng loại vũ khí của Người.",UDim2.fromOffset(18,271),UDim2.fromOffset(284,30),11).TextColor3=MUTED
local notice=label("Notice",panel,"",UDim2.fromOffset(24,516),UDim2.new(1,-48,0,44),12)
notice.TextColor3=C.Gold;notice.TextYAlignment=Enum.TextYAlignment.Top
local toast=frame("NoticeToast",gui,UDim2.fromOffset(330,58),UDim2.fromOffset(20,164))
toast.Visible=false
local toastText=label("Message",toast,"",UDim2.fromOffset(12,6),UDim2.new(1,-24,1,-12),12)
toastText.TextColor3=C.Gold


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
local function canCarve()
	local hum = characterParts()
	return alive and hum ~= nil and hum.Health > 0 and player:GetAttribute("InHunting") == true
		and player:GetAttribute("QuestState") == "Harvest" and player:GetAttribute("QuestResult") == "Defeated"
		and player:GetAttribute("AdminFlying") ~= true and player:GetAttribute("Drawn") ~= true
		and not panel.Visible and not otherMenuOpen()
end
local function startCarve(owner)
	if ownedHold or not canCarve() or currentAction() or player:GetAttribute("HuntCarveAvailable") ~= true then return end
	ownedHold = {Owner = owner, Observed = false, RunId = player:GetAttribute("QuestRunId")}
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
	if (action == "MerchantBuyTrap" or action == "MerchantBuyPotion") and snapshot.CanBuy ~= true then return end
 if (action == "CraftIronTrap" or action == "UpgradeWeapon") and snapshot.CanCraft ~= true then return end
	nextMutationAt = now + .35; pendingToken = token; pendingUntil = now + 8
	notice.Text = "Đang xử lý..."
	if action=="UpgradeWeapon" then
  remote:FireServer(action,{OperationToken=token,WeaponId=selectedWeapon,SnapshotVersion=snapshot.Revision,OperationSerial=snapshot.OperationSerial+1})
 else remote:FireServer(action,token) end
end
local function updatePanel()
 coins.Text=string.format("XU  %d",count(snapshot.Coins))
 for _,row in rows do
  local stock=snapshot[row[3]]
  stockLabels[row[1]].Text=string.format("%s · %d",row[2],count(type(stock)=="table" and stock[row[1]]))
 end
 heading.Text=if context=="Craft" then "BÀN CHẾ TẠO · NÂNG VŨ KHÍ" else "THƯƠNG NHÂN"
 locationHint.Text=if selectedTab=="Weapons" then
  (if snapshot.CanCraft then "Bàn chế tạo đã sẵn sàng · Chọn đúng vũ khí để nâng cấp riêng."
  else "Xem cấp vũ khí tại đây. Đến bàn chế tạo ở base của bạn, cất vũ khí để nâng cấp.")
  else (if snapshot.CanBuy then "Đang ở quầy tiếp tế · Mua vật tư vào kho của bạn."
  elseif snapshot.CanCraft then "Đang ở bàn chế tạo · Có thể ghép bẫy sắt. Mua vật tư tại thương nhân."
  else "Mua tại thương nhân ở sảnh · Chế tạo và nâng cấp tại bàn ở base của bạn.")
 supplies.Visible=selectedTab=="Supplies";weapons.Visible=selectedTab=="Weapons"
 supplyTab.TextColor3=if supplies.Visible then C.Gold else MUTED
 weaponTab.TextColor3=if weapons.Visible then C.Gold else MUTED
 local now=workspace:GetServerTimeNow()
 local state=player:GetAttribute("ProfileSaveState")
 local ready=player:GetAttribute("ProfileReady")==true and state~="Error" and state~="Saving" and state~="Conflict" and state~="Closing"
  and availableToken()~=nil and now>=nextMutationAt
  and not (pendingToken==availableToken() and pendingUntil and now<pendingUntil)
 local materials=if type(snapshot.Materials)=="table" then snapshot.Materials else {}
 local stored=if type(snapshot.Stored)=="table" then snapshot.Stored else {}
 local bone,iron=count(materials.Bone),count(materials.Iron)
 recipeStatus.Text=string.format("Bẫy thô %d/1 · Sắt %d/1\nGhép tại bàn chế tạo ở base của bạn.",count(stored.RawTrap),iron)
 recipeStatus.TextColor3=if count(stored.RawTrap)>=1 and iron>=1 then GREEN else C.Warning
 enabled(buyTrap,ready and snapshot.CanBuy==true and count(snapshot.Coins)>=10)
 enabled(buyPotion,ready and snapshot.CanBuy==true and count(snapshot.Coins)>=10)
 enabled(craftTrap,ready and snapshot.CanCraft==true and count(stored.RawTrap)>=1 and iron>=1)
 local levels=if type(snapshot.WeaponLevels)=="table" then snapshot.WeaponLevels else {}
 for _,id in weaponOrder do
  local level=count(levels[id],if id=="Hammer" then snapshot.HammerLevel or 1 else 1)
  local b=weaponButtons[id]
  b.Text=string.format("%s · Cấp %d",weaponNames[id],level)
  b.TextColor3=if selectedWeapon==id then C.Gold else CREAM
  b.BackgroundColor3=if selectedWeapon==id then Color3.fromRGB(53,49,39) else C.Card
 end
 local level=count(levels[selectedWeapon],if selectedWeapon=="Hammer" then snapshot.HammerLevel or 1 else 1)
 weaponTitle.Text=weaponNames[selectedWeapon]
 weaponLevelLabel.Text=string.format("CẤP %d%s",level,if player:GetAttribute("WeaponId")==selectedWeapon then " · ĐANG TRANG BỊ" else "")
 weaponBonus.Text=if level>=2 then "+15% sát thương cho vũ khí này.\nCác vũ khí khác giữ cấp riêng." else "Cấp 1 → Cấp 2\nTăng 15% sát thương cho vũ khí này."
 weaponBonus.TextColor3=if level>=2 then GREEN else CREAM
 boneProgress.Text=string.format("Xương  %d / 2",bone);boneProgress.TextColor3=if bone>=2 then GREEN else C.Warning
 ironProgress.Text=string.format("Sắt        %d / 2",iron);ironProgress.TextColor3=if iron>=2 then GREEN else C.Warning
 upgrade.Text=if level>=2 then "ĐÃ ĐẠT CẤP 2" elseif not snapshot.CanCraft then "NÂNG TẠI BASE CỦA BẠN" else "NÂNG LÊN CẤP 2 · +15%"
 enabled(upgrade,ready and snapshot.CanCraft==true and level<2 and bone>=2 and iron>=2)
end

local function applySnapshot(dto)
	if type(dto) ~= "table" then return end
	local revision = if finite(dto.Revision) then dto.Revision else snapshot.Revision
	if revision < snapshot.Revision then return end
	local previousToken = snapshot.OperationToken
	for _, key in {"Coins", "Materials", "Stored", "HammerLevel", "WeaponLevels", "CanBuy", "CanCraft", "OperationSerial", "ActiveRun", "OperationToken"} do
		snapshot[key] = dto[key]
	end
	snapshot.Revision = revision
	if snapshot.OperationToken ~= previousToken then pendingToken = nil; pendingUntil = nil end
	if type(dto.Notice) == "string" then showNotice(dto.Notice) end
	updatePanel()
end
local nextShopRefresh=0
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
		if not canCarve() or ownedHold.RunId ~= player:GetAttribute("QuestRunId") then cancelHold()
		elseif ownedHold.Observed and not currentAction() then ownedHold = nil end
	end
	if panel.Visible then
  updatePanel()
  if now>=nextShopRefresh then nextShopRefresh=now+.7;remote:FireServer("RefreshShop") end
 end
	local camera = workspace.CurrentCamera
	if camera then
		local size = gui.AbsoluteSize
		panelScale.Scale = math.min(1, (size.X - 24) / 820, (size.Y - 32) / 586)
		local scale = math.min(1, (size.X - 32) / 420, (size.Y - 48) / 460)
		harvestScale.Scale = scale
		local compact=size.X<1000 or size.Y<560
		harvest.AnchorPoint = if compact then Vector2.new(.5,1) else Vector2.new(1,1)
		harvest.Position = if compact then UDim2.new(.5,0,1,-12) else UDim2.new(1,-20,1,-24)
	end
	harvest.Visible = live and inHunting and state == "Harvest" and player:GetAttribute("QuestResult") == "Defeated"
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
connect(shade.Activated,function(input)
 local inset=if gui.IgnoreGuiInset then Vector2.zero else GuiService:GetGuiInset()
 local point=Vector2.new(input.Position.X,input.Position.Y)-inset
 local pos,size=panel.AbsolutePosition,panel.AbsoluteSize
 if point.X>=pos.X and point.X<=pos.X+size.X and point.Y>=pos.Y and point.Y<=pos.Y+size.Y then return end
 hidePanel()
end)
connect(supplyTab.Activated,function() selectedTab="Supplies";updatePanel() end)
connect(weaponTab.Activated,function() selectedTab="Weapons";updatePanel() end)
for id,b in weaponButtons do connect(b.Activated,function() selectedWeapon=id;updatePanel() end) end
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
		if dto.Context ~= "Merchant" and dto.Context ~= "Craft" and dto.Context ~= "Shop" then return end
		cancelHold(); context = dto.Context
  selectedTab=if context=="Craft" then "Weapons" else "Supplies"
  selectedWeapon=player:GetAttribute("WeaponId") or "Hammer"
  notice.Text="";applySnapshot(dto)
		panel.Visible = true; shade.Visible = true; refresh()
	end
end)
for _, name in {"QuestRunId", "QuestState", "QuestResult", "InHunting", "InTraining", "AdminFlying", "Drawn", "HuntCarves", "HuntHarvestAction", "HuntHarvestEnds", "HuntHarvestDuration", "HuntCarveAvailable"} do
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
