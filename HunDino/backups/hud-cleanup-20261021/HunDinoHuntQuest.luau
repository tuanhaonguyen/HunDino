-- P1-D prototype quest UI. Requests carry no target, reward, inventory count or
-- completion claim: the server owns the mission, hold times and capture result.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Input = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Theme = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UITheme"))
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("HunDinoTrainingAction")
local connections = {}
local alive, elapsed, nextRequestAt, nextTargetAt = true, 0, 0, 0
local target, ownedHold, removingCharacter
local resultShownFor, dismissedFor
local boardCanAccept = false
local INK, CREAM, MUTED = Theme.Colors.Panel, Theme.Colors.Text, Theme.Colors.Muted
local GREEN, AMBER, RED = Theme.Colors.Health, Theme.Colors.Gold, Theme.Colors.Warning

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
local function currentAction()
	local value = player:GetAttribute("HuntAction")
	return if value == "Place" or value == "Capture" then value else nil
end
local function rounded(item, radius)
	Theme.round(item, radius or 8)
end
local function frame(name, parent, size, position, anchor)
	local item = Instance.new("Frame")
	item.Name = name; item.Size = size; item.Position = position
	item.AnchorPoint = anchor or Vector2.zero
	item.BackgroundColor3 = INK; item.BackgroundTransparency = .12
	item.BorderSizePixel = 0; item.Parent = parent
	Theme.panel(item)
	return item
end
local function label(name, parent, value, position, size, textSize)
	local item = Instance.new("TextLabel")
	item.Name = name; item.Position = position; item.Size = size
	item.BackgroundTransparency = 1; item.Font = Enum.Font.GothamMedium
	item.TextColor3 = CREAM; item.Text = value; item.TextSize = textSize or 13
	item.TextXAlignment = Enum.TextXAlignment.Left; item.TextYAlignment = Enum.TextYAlignment.Center
	item.TextWrapped = true; item.Parent = parent
	return item
end
local function button(name, parent, value, position, size)
	local item = Instance.new("TextButton")
	item.Name = name; item.Position = position; item.Size = size
	item.BackgroundColor3 = Theme.Colors.Card; item.BorderSizePixel = 0
	item.TextColor3 = CREAM; item.Font = Enum.Font.GothamMedium
	item.TextSize = 13; item.Text = value; item.TextWrapped = true
	item.Parent = parent; Theme.button(item)
	return item
end
local function enabled(item, value)
	item.Active = value; item.Selectable = value; item.AutoButtonColor = false
	item.BackgroundColor3 = if value then Theme.Colors.Card else INK
	item.TextColor3 = if value then CREAM else MUTED
end

local gui = Instance.new("ScreenGui")
gui.Name = "HunDinoHuntQuest"; gui.ResetOnSpawn = false
gui.DisplayOrder = 12; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui
local openBoard = button("OpenQuestBoard", gui, "[ J ]  NHIỆM VỤ", UDim2.fromOffset(20, 82), UDim2.fromOffset(170, 36))

-- These exact Visible flags are also read by the existing combat menu guard.
local board = frame("QuestBoard", gui, UDim2.fromOffset(500, 400), UDim2.fromScale(.5, .5), Vector2.new(.5, .5))
board.Visible = false; board.Active = true
local boardScale = Instance.new("UIScale"); boardScale.Parent = board
label("Title", board, "BẢNG NHIỆM VỤ SĂN", UDim2.fromOffset(22, 17), UDim2.fromOffset(420, 30), 20)
local closeBoard = button("Close", board, "×", UDim2.new(1, -52, 0, 16), UDim2.fromOffset(30, 30))
label("Target", board, "T-REX · KHÔNG HỆ", UDim2.fromOffset(22, 62), UDim2.new(1, -44, 0, 30), 18)
label("Objective", board, "Hạ gục hoặc bắt sống T-Rex để hoàn thành cuộc săn.", UDim2.fromOffset(22, 102), UDim2.new(1, -44, 0, 43), 15)
label("Rules", board, "• Thời hạn 40 phút · 3 lượt hồi sinh; ngã lần 4 thì thua.\n• Tự mang tối đa 3 bẫy sắt + 3 thuốc từ kho đang có.\n• Cất vũ khí: giữ B 1 giây để đặt bẫy.\n• Quái ≤10% máu, mắc bẫy: tới miệng, giữ G 3 giây. Hết vật tư vẫn được săn tiêu diệt.", UDim2.fromOffset(22, 153), UDim2.new(1, -44, 0, 126), 13)
local boardReason = label("Availability", board, "", UDim2.fromOffset(22, 282), UDim2.new(1, -44, 0, 30), 12)
boardReason.TextColor3 = AMBER
local accept = button("AcceptQuest", board, "NHẬN NHIỆM VỤ · VÀO KHU SĂN", UDim2.fromOffset(22, 318), UDim2.new(1, -44, 0, 38))
label("Prototype", board, "Chuẩn bị tiếp tế ở sảnh · Chế bẫy sắt tại Base của bạn.", UDim2.fromOffset(22, 365), UDim2.new(1, -44, 0, 20), 10).TextColor3 = MUTED

-- The boss and quest panels have separate visual hierarchy. Their visibility
-- still comes only from the server-published quest state below.
local boss = frame("BossHUD", gui, UDim2.fromOffset(520, 118), UDim2.new(.5, 0, 0, 82), Vector2.new(.5, 0))
boss.Visible = false
local bossScale = Instance.new("UIScale"); bossScale.Parent = boss
local title = label("Target", boss, "T-REX · KHÔNG HỆ", UDim2.fromOffset(16, 8), UDim2.fromOffset(290, 24), 15)
title.Font = Enum.Font.GothamBold; title.TextColor3 = AMBER
local health = label("Health", boss, "Đang tìm dấu vết mục tiêu...", UDim2.fromOffset(310, 8), UDim2.fromOffset(194, 24), 12)
health.TextXAlignment = Enum.TextXAlignment.Right
local hpTrack = Instance.new("Frame")
hpTrack.Name = "HealthTrack"; hpTrack.Size = UDim2.new(1, -32, 0, 10); hpTrack.Position = UDim2.fromOffset(16, 39)
hpTrack.BackgroundColor3 = Theme.Colors.Card; hpTrack.BorderSizePixel = 0; hpTrack.ClipsDescendants = true; hpTrack.Parent = boss; rounded(hpTrack, 5)
local hpFill = Instance.new("Frame")
hpFill.Name = "Fill"; hpFill.Size = UDim2.fromScale(1, 1); hpFill.BackgroundColor3 = GREEN
hpFill.BorderSizePixel = 0; hpFill.Parent = hpTrack; rounded(hpFill, 5)
local weakBadge = label("WeakBadge", boss, "SUY YẾU — CÓ THỂ BẮT SỐNG", UDim2.fromOffset(16, 53), UDim2.new(1, -32, 0, 22), 12)
weakBadge.Font = Enum.Font.GothamBold; weakBadge.TextColor3 = RED; weakBadge.Visible = false
local bossTrap = label("TrapCountdown", boss, "", UDim2.fromOffset(16, 78), UDim2.new(1, -32, 0, 20), 12)
bossTrap.Font = Enum.Font.GothamBold; bossTrap.TextColor3 = AMBER
local trapTrack = hpTrack:Clone(); trapTrack.Name = "TrapTrack"; trapTrack.Position = UDim2.fromOffset(16, 103); trapTrack.Size = UDim2.new(1, -32, 0, 4); trapTrack.Parent = boss
local trapFill = trapTrack.Fill; trapFill.BackgroundColor3 = AMBER; trapTrack.Visible = false

local hud = frame("QuestHUD", gui, UDim2.fromOffset(300, 310), UDim2.new(1, -20, 0, 220), Vector2.new(1, 0))
hud.Visible = false
local hudScale = Instance.new("UIScale"); hudScale.Parent = hud
label("Heading", hud, "CUỘC SĂN", UDim2.fromOffset(14, 9), UDim2.new(1, -28, 0, 20), 12).TextColor3 = AMBER
local environment = label("EnvironmentClock", hud, "☀  GIỜ RỪNG UTC+7 ×30", UDim2.fromOffset(14, 33), UDim2.new(1, -28, 0, 20), 11)
environment.TextColor3 = MUTED
local remaining = label("Remaining", hud, "40:00", UDim2.fromOffset(14, 58), UDim2.fromOffset(126, 31), 26)
remaining.Font = Enum.Font.GothamBold
local resources = label("Resources", hud, "", UDim2.fromOffset(145, 59), UDim2.fromOffset(141, 29), 12)
resources.TextXAlignment = Enum.TextXAlignment.Right
local objective = label("Objective", hud, "Hạ gục hoặc bắt sống mục tiêu", UDim2.fromOffset(14, 96), UDim2.new(1, -28, 0, 35), 13)
local trapStatus = label("TrapStatus", hud, "", UDim2.fromOffset(14, 135), UDim2.new(1, -28, 0, 33), 11)
trapStatus.TextColor3 = MUTED
local place = button("PlaceTrap", hud, "[Giữ B] Đặt Bẫy Sắt (0/3)", UDim2.fromOffset(14, 175), UDim2.new(1, -28, 0, 34))
local capture = button("Capture", hud, "[Giữ G] Thuốc Ngủ / Tương tác (0/3)", UDim2.fromOffset(14, 217), UDim2.new(1, -28, 0, 34))
place.TextSize = 12; capture.TextSize = 11
local hint = label("Hint", hud, "Cất vũ khí trước khi dùng bẫy hoặc thuốc.", UDim2.fromOffset(14, 262), UDim2.new(1, -28, 0, 35), 10)
hint.TextColor3 = MUTED
local earlyReturn = button("ReturnEarly", hud, "VỀ SẢNH NGAY", UDim2.fromOffset(14, 175), UDim2.new(1, -28, 0, 34))
local details = button("ResultDetails", hud, "XEM KẾT QUẢ", UDim2.fromOffset(14, 217), UDim2.new(1, -28, 0, 34))
earlyReturn.Visible = false; details.Visible = false

local result = frame("ResultModal", gui, UDim2.fromOffset(480, 310), UDim2.fromScale(.5, .5), Vector2.new(.5, .5))
result.Visible = false; result.Active = true
local resultScale = Instance.new("UIScale"); resultScale.Parent = result
local resultTitle = label("Title", result, "KẾT QUẢ CUỘC SĂN", UDim2.fromOffset(22, 18), UDim2.new(1, -44, 0, 32), 20)
local resultBody = label("Description", result, "", UDim2.fromOffset(22, 68), UDim2.new(1, -44, 0, 112), 15)
label("Prototype", result, "Kho thử trong phiên. Đồ chưa nhặt/mổ không tự cấp; chưa lưu tài khoản.", UDim2.fromOffset(22, 184), UDim2.new(1, -44, 0, 38), 12).TextColor3 = MUTED
local resultReturn = button("Return", result, "VỀ SẢNH NGAY", UDim2.fromOffset(22, 242), UDim2.fromOffset(264, 40))
local dismiss = button("Dismiss", result, "Đóng", UDim2.fromOffset(298, 242), UDim2.fromOffset(160, 40))

local function characterParts()
	local character = player.Character
	if not character or character == removingCharacter then return nil, nil end
	return character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end
local function otherMenuOpen()
	if GuiService.MenuIsOpen or Input:GetFocusedTextBox() then return true end
	local economy=playerGui:FindFirstChild("HunDinoEconomy")
	if economy and economy:FindFirstChild("Panel") and economy.Panel.Visible then return true end
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
local function cancelHold()
	if not ownedHold then return end
	ownedHold = nil
	if alive then remote:FireServer("QuestActionCancel") end
end
local function canAct()
	local hum = characterParts()
	return alive and hum ~= nil and hum.Health > 0 and player:GetAttribute("QuestState") == "Hunting"
		and player:GetAttribute("InHunting") == true and player:GetAttribute("AdminFlying") ~= true
		and player:GetAttribute("Drawn") ~= true and not board.Visible and not result.Visible and not otherMenuOpen()
end
local function captureRange()
	local point = player:GetAttribute("HuntCapturePoint")
	if typeof(point) ~= "Vector3" and target then point = target:GetAttribute("CapturePoint") end
	local _, root = characterParts()
	if typeof(point) ~= "Vector3" or not root or not root:IsA("BasePart") then return math.huge end
	return (point - root.Position).Magnitude
end
local function captureReady()
	if player:GetAttribute("SpecimenFull")==true then return false end
	if player:GetAttribute("HuntCaptureAvailable") == true then return true end
	return target ~= nil and target:GetAttribute("Weak") == true and target:GetAttribute("Trapped") == true
		and target:GetAttribute("Captured") ~= true and captureRange() <= 4
end
local function startHold(action, owner)
	if ownedHold or not canAct() or currentAction() ~= nil then return end
	if action == "Place" and numberAttribute("HuntTraps", 0) <= 0 then return end
	if action == "Capture" and (numberAttribute("HuntPotions", 0) <= 0 or not captureReady()) then return end
	ownedHold = {Action = action, Owner = owner, Observed = false}
	remote:FireServer(if action == "Place" then "TrapPlaceStart" else "CaptureStart")
end
local function requestBoard()
	local now = workspace:GetServerTimeNow()
	local hum = characterParts()
	if now < nextRequestAt or not hum or hum.Health <= 0 or otherMenuOpen()
		or player:GetAttribute("InHunting") == true or player:GetAttribute("InTraining") == true
		or player:GetAttribute("AdminFlying") == true then return end
	if board.Visible then board.Visible = false; return end
	nextRequestAt = now + .4
	remote:FireServer("QuestBoard") -- The board opens only on the server reply.
end
local function clock(seconds)
	seconds = math.max(0, math.ceil(seconds))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end
local failureReasons = {
	Deaths = "Bạn đã dùng hết 3 lượt hồi sinh và ngã lần thứ 4.", FourDeaths = "Bạn đã dùng hết 3 lượt hồi sinh và ngã lần thứ 4.", DeathLimit = "Bạn đã dùng hết 3 lượt hồi sinh và ngã lần thứ 4.",
	Timeout = "Đã hết thời hạn 40 phút.", TimeLimit = "Đã hết thời hạn 40 phút.",
	TimeExpired = "Đã hết thời hạn 40 phút.",
	EntryInterrupted = "Việc vào khu săn bị gián đoạn. Hãy về sảnh để nhận lượt săn mới.",
	Abandoned = "Bạn đã rời cuộc săn trước khi hoàn thành.",
}
local function refreshResult()
	local outcome = player:GetAttribute("QuestResult")
	local success = outcome == "Captured" or outcome == "Defeated"
	resultTitle.Text = if outcome == "Captured" then "BẮT SỐNG THÀNH CÔNG" elseif outcome == "Defeated" then "ĐÃ HẠ GỤC T-REX" else "CUỘC SĂN KẾT THÚC"
	resultTitle.TextColor3 = if success then GREEN else AMBER
	local reason = player:GetAttribute("QuestFailureReason")
	resultBody.Text = if success then (player:GetAttribute("QuestRewardText") or "Nhiệm vụ hoàn thành! Bạn có 120 giây thu hoạch trước khi về sảnh.")
		else (failureReasons[reason] or (if type(reason) == "string" and reason ~= "" then reason else "Cuộc săn chưa hoàn thành."))
	local state = player:GetAttribute("QuestState")
	resultReturn.Visible = state == "Harvest" or state == "Failed"
	dismiss.Text = if success and state == "Harvest" then "Tiếp tục xem" else "Đóng"
end

local function refreshBoss(now, visible, harvest)
	boss.Visible = visible and target ~= nil
	if not boss.Visible then return false end
	title.Text = player:GetAttribute("QuestTarget") or "T-REX · KHÔNG HỆ"
	local maximum = target:GetAttribute("MaxHealth")
	local hp = target:GetAttribute("Health")
	local weak = false
	if finite(maximum) and maximum > 0 and finite(hp) then
		local ratio = math.clamp(hp / maximum, 0, 1)
		weak = hp > 0 and ratio <= .1
		health.Text = string.format("%d / %d HP", math.ceil(math.max(0, hp)), math.ceil(maximum))
		hpFill.Size = UDim2.fromScale(ratio, 1); hpFill.BackgroundColor3 = if weak then RED else GREEN
	else
		health.Text = "Mục tiêu ở ngoài tầm quan sát"; hpFill.Size = UDim2.fromScale(0, 1)
	end
	weakBadge.Visible = weak and not harvest
	weakBadge.TextTransparency = if weak then .08 + .48 * ((math.sin(now * 6) + 1) / 2) else 0
	local trapLeft = math.max(0, numberAttribute("HuntTrapEnds", now) - now)
	local trapped = player:GetAttribute("HuntTrapState") == "Holding" and trapLeft > 0
	local urgent = trapped and trapLeft <= 3
	bossTrap.Text = if harvest then (if player:GetAttribute("QuestResult") == "Captured" then "ĐÃ BẮT SỐNG · CUỘC SĂN HOÀN THÀNH" else "ĐÃ HẠ GỤC · CUỘC SĂN HOÀN THÀNH")
		elseif trapped then string.format("GIỮ BẪY: %.1fs", trapLeft) else "BẪY SẮT · GIỮ MỤC TIÊU 13 GIÂY"
	bossTrap.TextColor3 = if harvest then GREEN elseif urgent then RED elseif trapped then AMBER else MUTED
	bossTrap.TextTransparency = if urgent and not harvest then .4 * ((math.sin(now * 13) + 1) / 2) else 0
	-- Only the countdown label moves; the health bar and camera remain steady.
	bossTrap.Position = UDim2.fromOffset(16 + (if urgent and not harvest then math.sin(now * 39) * 1.5 else 0), 78)
	trapTrack.Visible = trapped and not harvest
	trapFill.Size = UDim2.fromScale(math.clamp(trapLeft / 13, 0, 1), 1)
	trapFill.BackgroundColor3 = if urgent then RED else AMBER
	return weak
end

local function refresh()
	if not alive then return end
	local now = workspace:GetServerTimeNow()
	local size = gui.AbsoluteSize
	if size.X > 0 and size.Y > 0 then
		boardScale.Scale = math.min(1, math.max(.5, (size.X - 32) / 500), math.max(.5, (size.Y - 48) / 400))
		resultScale.Scale = math.min(1, math.max(.5, (size.X - 32) / 480), math.max(.5, (size.Y - 48) / 310))
		local compact = size.X < 1000 or size.Y < 560
		if compact then
			hudScale.Scale = math.min(.6, (size.Y - 144) / 310, (size.X - 32) / 600)
			hud.Position = UDim2.new(1, -12, 0, 132)
			bossScale.Scale = math.min(.62, (size.X - 32) / 520)
			boss.Position = UDim2.new(.5, 0, 0, 66)
		else
			hudScale.Scale = math.min(1, math.max(.5, (size.X - 40) / 560), math.max(.5, (size.Y - 235) / 310))
			hud.Position = UDim2.new(1, -20, 0, if size.Y < 650 then 174 else 220)
			bossScale.Scale = math.min(1, math.max(.5, (size.X - 40) / 700))
			boss.Position = UDim2.new(.5, 0, 0, 82)
		end
	end
	local state = player:GetAttribute("QuestState")
	local runId = tostring(player:GetAttribute("QuestRunId") or "")
	local inHunting = player:GetAttribute("InHunting") == true
	local hum = characterParts()
	openBoard.Visible = not inHunting and player:GetAttribute("InTraining") ~= true and player:GetAttribute("AdminFlying") ~= true
		and hum ~= nil and hum.Health > 0 and state ~= "Preparing" and state ~= "Returning"
	if state == "Preparing" or inHunting then board.Visible = false end
	if not hum or hum.Health <= 0 then board.Visible = false end
	local outcome = player:GetAttribute("QuestResult")
	local failed = outcome == "Failed" or outcome == "Abandoned"
	if state == "Returning" and not failed then result.Visible = false end
	if (state == "Failed" or (state == "Closed" and failed)) and runId ~= resultShownFor and runId ~= dismissedFor then
		resultShownFor = runId; result.Visible = true; cancelHold()
	end
	if board.Visible and (player:GetAttribute("AdminFlying") == true or player:GetAttribute("InTraining") == true) then board.Visible = false end
	if state == "Hunting" then result.Visible = false end
	hud.Visible = inHunting and (state == "Hunting" or state == "Harvest")
	refreshResult()
	if not target or not target.Parent then
		if now >= nextTargetAt then
			nextTargetAt = now + 1
			local candidate = workspace:FindFirstChild("Dinosaur01_TRex_Visual")
			target = if candidate and candidate:IsA("Model") then candidate else nil
		end
	end
	if ownedHold then
		local action = currentAction()
		if action == ownedHold.Action then ownedHold.Observed = true end
		if not canAct() then cancelHold()
		elseif ownedHold.Observed and action ~= ownedHold.Action then ownedHold = nil end
	end
	local harvest = state == "Harvest"
	local weak = refreshBoss(now, inHunting and hum ~= nil and hum.Health > 0, harvest)
	if not hud.Visible then return end
	remaining.Text = clock(numberAttribute(if harvest then "QuestHarvestUntil" else "QuestDeadline", now) - now)
	remaining.TextColor3 = if harvest or numberAttribute("QuestDeadline", now) - now <= 60 then AMBER else CREAM
	local hours = numberAttribute("GameClockHours", numberAttribute("HuntEntryClockHours", 14)) % 24
	local minutes = math.floor(hours * 60) % 1440
	environment.Text = string.format("%s  %02d:%02d · GIỜ RỪNG UTC+7 ×%g", if hours >= 6 and hours < 18 then "☀" else "☾", math.floor(minutes / 60), minutes % 60, numberAttribute("HuntTimeScale", 30))
	local deaths = math.clamp(math.floor(numberAttribute("QuestDeaths", 0)), 0, 4)
	resources.Text = string.format("HỒI SINH\n%d / 3", math.max(0, 3 - deaths))
	resources.TextColor3 = if deaths >= 2 then AMBER else CREAM
	place.Visible = not harvest; capture.Visible = not harvest
	earlyReturn.Visible = harvest; details.Visible = harvest
	if harvest then
		objective.Text = if player:GetAttribute("QuestResult") == "Captured" then "Bắt sống thành công · nhiệm vụ hoàn thành" else "Đã hạ gục T-Rex · nhiệm vụ hoàn thành"
		objective.TextColor3 = GREEN
		trapStatus.Text = "Tự động về sảnh sau " .. remaining.Text; trapStatus.TextColor3 = AMBER
		hint.Text = "Bạn có thể tiếp tục di chuyển, xem hiện trường hoặc về sảnh ngay."
		return
	end
	objective.Text = if weak then "Quái đủ yếu để bắt · ≤10% HP" else "Hạ gục hoặc bắt sống mục tiêu"
	objective.TextColor3 = if weak then RED else CREAM
	local trap = player:GetAttribute("HuntTrapState")
	local trapLeft = math.max(0, numberAttribute("HuntTrapEnds", now) - now)
	trapStatus.TextColor3 = if trap == "Holding" and trapLeft <= 3 then RED elseif trap == "Holding" then AMBER else MUTED
	trapStatus.Text = if trap == "Holding" then string.format("MẮC BẪY · còn %.1fs để cho uống thuốc", trapLeft)
		elseif trap == "Waiting" then "Bẫy đã đặt · dụ quái bước vào bẫy"
		elseif trap == "Expired" then "Bẫy đã hết hạn · cần đặt bẫy khác"
		elseif trap == "Escaped" then "Quái đã thoát bẫy" else "Chưa có bẫy · cất vũ khí, giữ B để đặt"
	local available = canAct()
	local action = currentAction()
	local placing, capturing = action == "Place", action == "Capture"
	local left = math.max(0, numberAttribute("HuntActionEnds", now) - now)
	place.Text = if placing then string.format("[Giữ B] Đang đặt · %.1fs", left) else string.format("[Giữ B] Đặt Bẫy Sắt (%d/3)", math.max(0, numberAttribute("HuntTraps", 0)))
	capture.Text = if capturing then string.format("[Giữ G] Đang cho uống · %.1fs", left) else string.format("[Giữ G] Thuốc Ngủ / Tương tác (%d/3)", math.max(0, numberAttribute("HuntPotions", 0)))
	enabled(place, available and (placing or action == nil) and numberAttribute("HuntTraps", 0) > 0)
	enabled(capture, available and (capturing or action == nil) and numberAttribute("HuntPotions", 0) > 0 and captureReady())
	hint.Text = if player:GetAttribute("AdminFlying") == true then "Đáp xuống đất trước khi dùng bẫy hoặc thuốc."
		elseif player:GetAttribute("SpecimenFull")==true then "Kho cá thể đầy. Chưa dùng thuốc; bạn vẫn có thể săn tiêu diệt."
		elseif player:GetAttribute("Drawn") == true then "Nhấn R cất vũ khí trước khi đặt bẫy hoặc cho uống thuốc."
		elseif capturing then "Tiếp tục giữ G/nút · không di chuyển, rút vũ khí hoặc nhận đòn."
		elseif placing then "Tiếp tục giữ B/nút · thả để hủy đặt bẫy."
		elseif weak and target:GetAttribute("Trapped") == true and captureRange() > 4 then "Đến gần miệng quái (≤4 studs), giữ G 3 giây."
		elseif captureReady() then "Giữ G 3 giây để cho uống thuốc · thả để hủy."
		else "Bắt sống: ≤10% HP → mắc bẫy → đến miệng, giữ G 3 giây."
	local respawnLeft = numberAttribute("QuestRespawnAt", 0) - now
	if respawnLeft > 0 then hint.Text = string.format("Bạn đã ngã · hồi sinh tại trại sau %.0f giây.", math.ceil(respawnLeft)) end
end

connect(openBoard.Activated, requestBoard)
connect(closeBoard.Activated, function() board.Visible = false end)
connect(accept.Activated, function()
	local now = workspace:GetServerTimeNow()
	if not board.Visible or not boardCanAccept or now < nextRequestAt or otherMenuOpen() then return end
	nextRequestAt = now + .5; enabled(accept, false)
	boardReason.Text = "Đang chuẩn bị cuộc săn..."
	remote:FireServer("QuestAccept")
end)
connect(earlyReturn.Activated, function() remote:FireServer("QuestReturnEarly") end)
connect(resultReturn.Activated, function() remote:FireServer("QuestReturnEarly") end)
connect(details.Activated, function() cancelHold(); refreshResult(); result.Visible = true end)
connect(dismiss.Activated, function()
	dismissedFor = tostring(player:GetAttribute("QuestRunId") or "")
	result.Visible = false; remote:FireServer("QuestDismissResult")
end)
for item, action in {[place] = "Place", [capture] = "Capture"} do
	connect(item.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startHold(action, input)
		end
	end)
end
connect(Input.InputBegan, function(input, processed)
	if processed or Input:GetFocusedTextBox() or GuiService.MenuIsOpen then return end
	if input.KeyCode == Enum.KeyCode.J then requestBoard()
	elseif input.KeyCode == Enum.KeyCode.B then startHold("Place", Enum.KeyCode.B)
	elseif input.KeyCode == Enum.KeyCode.G then startHold("Capture", Enum.KeyCode.G) end
end)
connect(Input.InputEnded, function(input)
	if not ownedHold then return end
	local owner = ownedHold.Owner
	if owner == input.KeyCode or owner == input
		or (typeof(owner) == "Instance" and owner:IsA("InputObject") and owner.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1) then cancelHold() end
end)
connect(Input.WindowFocusReleased, cancelHold)
connect(Input.TextBoxFocused, cancelHold)
connect(GuiService.MenuOpened, cancelHold)
connect(player.CharacterRemoving, function(character) removingCharacter = character; cancelHold(); hud.Visible = false; boss.Visible = false; board.Visible = false end)
connect(player.CharacterAdded, function() removingCharacter = nil; refresh() end)
connect(remote.OnClientEvent, function(event, dto)
	if event == "QuestBoard" then
		if player:GetAttribute("InHunting") == true or player:GetAttribute("AdminFlying") == true then return end
		cancelHold(); result.Visible = false
		boardCanAccept = type(dto) ~= "table" or dto.CanAccept ~= false
		boardReason.Text = if type(dto) == "table" and type(dto.Reason) == "string" then dto.Reason else "Vật tư dùng thử chỉ có hiệu lực trong lượt săn này."
		enabled(accept, boardCanAccept); board.Visible = true
	elseif event == "QuestState" then refresh() end
end)
for _, name in {"QuestRunId", "QuestState", "QuestResult", "QuestTarget", "QuestDeaths", "QuestDeadline", "QuestHarvestUntil", "QuestFailureReason", "QuestRespawnAt", "HuntTraps", "HuntPotions", "HuntTrapState", "HuntTrapEnds", "HuntAction", "HuntActionEnds", "HuntCaptureActive", "HuntCaptureAvailable", "HuntCapturePoint", "InHunting", "InTraining", "AdminFlying", "Drawn"} do
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


