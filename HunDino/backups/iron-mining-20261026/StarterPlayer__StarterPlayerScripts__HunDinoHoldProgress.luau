-- Render only server-acknowledged hold actions; completion and rewards stay server-owned.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Input = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Theme = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UITheme"))
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "HunDinoHoldProgress"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.DisplayOrder = 20; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = playerGui
local ring = Theme.Ring(gui, "ActionRing", 88, 5, Theme.Colors.Gold)
ring.Frame.Visible = false
local function label(name, value, position, size, textSize)
	local item = Instance.new("TextLabel")
	item.Name = name; item.Text = value; item.Position = position; item.Size = size
	item.BackgroundTransparency = 1; item.TextColor3 = Theme.Colors.Text
	item.Font = Enum.Font.GothamBold; item.TextSize = textSize; item.TextStrokeTransparency = .3
	item.ZIndex = 4; item.Parent = ring.Frame; return item
end
local key = label("Key", "G", UDim2.fromOffset(0, 20), UDim2.new(1, 0, 0, 28), 24)
local percent = label("Progress", "0%", UDim2.fromOffset(0, 48), UDim2.new(1, 0, 0, 18), 12)
local caption = label("Action", "", UDim2.new(.5, -160, 1, 10), UDim2.fromOffset(320, 24), 14)
local hint = label("Hint", "Thả phím / nút để hủy", UDim2.new(.5, -160, 1, 34), UDim2.fromOffset(320, 20), 11)
hint.TextColor3 = Theme.Colors.Muted
local connections = {}; local windowFocused = true
local function connect(signal, fn) table.insert(connections, signal:Connect(fn)) end
local function menuOpen()
	if GuiService.MenuIsOpen or Input:GetFocusedTextBox() then return true end
	for guiName, names in {HunDinoTrainingHUD = {"WeaponSelection", "HubPanel", "BaseTransitMenu"}, HunDinoHuntQuest = {"QuestBoard", "ResultModal"}, HunDinoEconomy = {"Panel"}, HuntingMapViewer = {"ZonePicker"}} do
		local screen = playerGui:FindFirstChild(guiName)
		if screen and screen.Enabled then
			for _, name in names do local object = screen:FindFirstChild(name); if object and object.Visible then return true end end
		end
	end
	return false
end
local function actionState()
	local action = player:GetAttribute("HuntAction")
	if action == "Place" then return action, "B", "ĐẶT BẪY SẮT", 1, player:GetAttribute("HuntActionEnds") end
	if action == "Capture" then return action, "G", "CHO UỐNG THUỐC NGỦ", 3, player:GetAttribute("HuntActionEnds") end
	local harvest = player:GetAttribute("HuntHarvestAction")
	if harvest == "Carve" or harvest == true then return "Carve", "G", "MỔ XÁC", player:GetAttribute("HuntHarvestDuration") or 1.5, player:GetAttribute("HuntHarvestEnds") end
	return nil
end
connect(RunService.RenderStepped, function()
	local action, shortcut, title, duration, ends = actionState()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local visible = action ~= nil and windowFocused and type(ends) == "number" and ends == ends
		and type(duration) == "number" and duration > 0 and duration < math.huge
		and hum ~= nil and hum.Health > 0 and player:GetAttribute("InHunting") == true
		and player:GetAttribute("AdminFlying") ~= true and not menuOpen()
	ring.Frame.Visible = visible
	if not visible then return end
	local left = math.max(0, ends - workspace:GetServerTimeNow())
	local progress = math.clamp(1 - left / duration, 0, 1)
	ring:Set(progress); key.Text = shortcut; percent.Text = string.format("%d%%", math.floor(progress * 100))
	caption.Text = string.format("%s · %.1fs", title, left)
end)
-- Quest/economy retain input ownership and cancel the server action on release.
-- An unrelated pointer/key release must not hide a still-active keyboard hold.
connect(Input.WindowFocusReleased, function() windowFocused = false; ring.Frame.Visible = false end)
connect(Input.WindowFocused, function() windowFocused = true end)
connect(player.CharacterRemoving, function() ring.Frame.Visible = false end)
script.Destroying:Connect(function() for _, connection in connections do connection:Disconnect() end; gui:Destroy() end)

