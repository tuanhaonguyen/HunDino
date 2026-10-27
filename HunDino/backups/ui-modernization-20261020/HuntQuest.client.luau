-- P1-D prototype quest UI. Requests carry no target, reward, inventory count or
-- completion claim: the server owns the mission, hold times and capture result.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Input = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("HunDinoTrainingAction")
local connections = {}
local alive, elapsed, nextRequestAt, nextTargetAt = true, 0, 0, 0
local target, ownedHold, removingCharacter
local resultShownFor, dismissedFor
local boardCanAccept = false
local INK = Color3.fromRGB(22, 38, 33)
local CREAM = Color3.fromRGB(239, 235, 214)
local MUTED = Color3.fromRGB(174, 190, 173)
local GREEN = Color3.fromRGB(108, 194, 143)
local AMBER = Color3.fromRGB(231, 184, 101)
local RED = Color3.fromRGB(219, 113, 101)

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
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = item
end
local function frame(name, parent, size, position, anchor)
	local item = Instance.new("Frame")
	item.Name = name; item.Size = size; item.Position = position
	item.AnchorPoint = anchor or Vector2.zero
	item.BackgroundColor3 = INK; item.BackgroundTransparency = .06
	item.BorderSizePixel = 0; item.Parent = parent
	rounded(item, 10)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 136, 107); stroke.Transparency = .45; stroke.Parent = item
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
	item.BackgroundColor3 = Color3.fromRGB(60, 112, 76); item.BorderSizePixel = 0
	item.TextColor3 = CREAM; item.Font = Enum.Font.GothamMedium
	item.TextSize = 13; item.Text = value; item.TextWrapped = true
	item.Parent = parent; rounded(item, 6)
	return item
end
local function enabled(item, value)
	item.Active = value; item.Selectable = value; item.AutoButtonColor = value
	item.BackgroundColor3 = if value then Color3.fromRGB(60, 112, 76) else Color3.fromRGB(46, 62, 52)
	item.TextColor3 = if value then CREAM else MUTED
end

local gui = Instance.new("ScreenGui")
gui.Name = "HunDinoHuntQuest"; gui.ResetOnSpawn = false
gui.DisplayOrder = 12; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui
local openBoard = button("OpenQuestBoard", gui, "J · Nhiệm vụ", UDim2.fromOffset(20, 82), UDim2.fromOffset(170, 34))

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
label("Prototype", board, "P1-E · Kho thử trong phiên; mua tiếp tế tại sảnh, chế tại base.", UDim2.fromOffset(22, 365), UDim2.new(1, -44, 0, 20), 10).TextColor3 = MUTED

local hud = frame("QuestHUD", gui, UDim2.fromOffset(420, 254), UDim2.new(.5, 0, 0, 160), Vector2.new(.5, 0))
hud.Visible = false
local hudScale = Instance.new("UIScale"); hudScale.Parent = hud
local title = label("Target", hud, "T-REX · KHÔNG HỆ", UDim2.fromOffset(12, 8), UDim2.fromOffset(258, 22), 13)
local remaining = label("Remaining", hud, "", UDim2.fromOffset(272, 8), UDim2.fromOffset(136, 22), 13)
remaining.TextXAlignment = Enum.TextXAlignment.Right
local health = label("Health", hud, "Đang tìm dấu vết mục tiêu...", UDim2.fromOffset(12, 33), UDim2.new(1, -24, 0, 20), 12)
local hpTrack = frame("HealthTrack", hud, UDim2.new(1, -24, 0, 7), UDim2.fromOffset(12, 58))
hpTrack.BackgroundColor3 = Color3.fromRGB(48, 67, 56); hpTrack.ClipsDescendants = true
local hpFill = Instance.new("Frame")
hpFill.Name = "Fill"; hpFill.Size = UDim2.fromScale(1, 1); hpFill.BackgroundColor3 = GREEN
hpFill.BorderSizePixel = 0; hpFill.Parent = hpTrack; rounded(hpFill, 4)
local objective = label("Objective", hud, "Hạ gục hoặc bắt sống mục tiêu", UDim2.fromOffset(12, 73), UDim2.new(1, -24, 0, 24), 13)
local resources = label("Resources", hud, "", UDim2.fromOffset(12, 102), UDim2.new(1, -24, 0, 20), 12)
local trapStatus = label("TrapStatus", hud, "", UDim2.fromOffset(12, 126), UDim2.new(1, -24, 0, 26), 12)
trapStatus.TextColor3 = MUTED
local place = button("PlaceTrap", hud, "Giữ B · Đặt bẫy (1s)", UDim2.fromOffset(12, 157), UDim2.fromOffset(193, 34))
local capture = button("Capture", hud, "Giữ G · Cho uống (3s)", UDim2.fromOffset(215, 157), UDim2.fromOffset(193, 34))
local actionTrack = frame("ActionTrack", hud, UDim2.new(1, -24, 0, 5), UDim2.fromOffset(12, 198))
actionTrack.BackgroundColor3 = Color3.fromRGB(48, 67, 56); actionTrack.ClipsDescendants = true
local actionFill = hpFill:Clone(); actionFill.Name = "Fill"; actionFill.Size = UDim2.fromScale(0, 1); actionFill.BackgroundColor3 = AMBER; actionFill.Parent = actionTrack
local hint = label("Hint", hud, "Cất vũ khí trước khi dùng bẫy hoặc thuốc.", UDim2.fromOffset(12, 209), UDim2.new(1, -24, 0, 32), 11)
hint.TextColor3 = MUTED
local earlyReturn = button("ReturnEarly", hud, "VỀ SẢNH NGAY", UDim2.fromOffset(12, 157), UDim2.fromOffset(236, 34))
local details = button("ResultDetails", hud, "Xem kết quả", UDim2.fromOffset(258, 157), UDim2.fromOffset(150, 34))
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

local function refresh()
	if not alive then return end
	local now = workspace:GetServerTimeNow()
	local camera = workspace.CurrentCamera
	if camera then
		local size = camera.ViewportSize
		boardScale.Scale = math.min(1, math.max(.5, (size.X - 32) / 500), math.max(.5, (size.Y - 48) / 400))
		resultScale.Scale = math.min(1, math.max(.5, (size.X - 32) / 480), math.max(.5, (size.Y - 48) / 310))
		hudScale.Scale = math.min(1, math.max(.55, (size.X - 32) / 420), math.max(.55, (size.Y - 230) / 254))
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
	if not hud.Visible then return end
	local harvest = state == "Harvest"
	title.Text = player:GetAttribute("QuestTarget") or "T-REX · KHÔNG HỆ"
	remaining.Text = clock(numberAttribute(if harvest then "QuestHarvestUntil" else "QuestDeadline", now) - now)
	remaining.TextColor3 = if harvest or numberAttribute("QuestDeadline", now) - now <= 60 then AMBER else CREAM
	local maximum = target and target:GetAttribute("MaxHealth")
	local hp = target and target:GetAttribute("Health")
	if finite(maximum) and maximum > 0 and finite(hp) then
		local ratio = math.clamp(hp / maximum, 0, 1)
		health.Text = string.format("Mục tiêu · %d / %d HP", math.ceil(math.max(0, hp)), math.ceil(maximum))
		hpFill.Size = UDim2.fromScale(ratio, 1); hpFill.BackgroundColor3 = if ratio <= .1 then AMBER else GREEN
	else
		health.Text = "Mục tiêu ở ngoài tầm quan sát"; hpFill.Size = UDim2.fromScale(0, 1)
	end
	local deaths = math.clamp(math.floor(numberAttribute("QuestDeaths", 0)), 0, 4)
	resources.Text = string.format("Còn %d lượt hồi sinh  ·  Bẫy %d  ·  Thuốc ngủ %d", math.max(0, 3 - deaths), math.max(0, numberAttribute("HuntTraps", 0)), math.max(0, numberAttribute("HuntPotions", 0)))
	resources.TextColor3 = if deaths >= 2 then AMBER else CREAM
	place.Visible = not harvest; capture.Visible = not harvest
	earlyReturn.Visible = harvest; details.Visible = harvest
	actionTrack.Visible = not harvest
	if harvest then
		objective.Text = if player:GetAttribute("QuestResult") == "Captured" then "Bắt sống thành công · nhiệm vụ hoàn thành" else "Đã hạ gục T-Rex · nhiệm vụ hoàn thành"
		objective.TextColor3 = GREEN
		trapStatus.Text = "Tự động về sảnh sau " .. remaining.Text; trapStatus.TextColor3 = AMBER
		hint.Text = "Bạn có thể tiếp tục di chuyển, xem hiện trường hoặc về sảnh ngay."
		return
	end
	local weak = target and target:GetAttribute("Weak") == true
	objective.Text = if weak then "Quái đủ yếu để bắt · ≤10% HP" else "Hạ gục hoặc bắt sống mục tiêu"
	objective.TextColor3 = if weak then AMBER else CREAM
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
	place.Text = if placing then string.format("Giữ B · Đang đặt %.1fs", left) else "Giữ B · Đặt bẫy (1s)"
	capture.Text = if capturing then string.format("Giữ G · Đang cho uống %.1fs", left) else "Giữ G · Cho uống (3s)"
	enabled(place, available and (placing or action == nil) and numberAttribute("HuntTraps", 0) > 0)
	enabled(capture, available and (capturing or action == nil) and numberAttribute("HuntPotions", 0) > 0 and captureReady())
	local duration = if capturing then 3 else 1
	actionFill.Size = UDim2.fromScale(if placing or capturing then math.clamp(1 - left / duration, 0, 1) else 0, 1)
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
connect(player.CharacterRemoving, function(character) removingCharacter = character; cancelHold(); hud.Visible = false; board.Visible = false end)
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
