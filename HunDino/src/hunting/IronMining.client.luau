-- G starts a strike through the server-owned ProximityPrompt. This client only
-- cancels that strike when its input context is lost; it never grants iron.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local remote=ReplicatedStorage:WaitForChild("HunDinoMiningAction")
local connections={}
local alive,windowFocused=true,true
local lastCancelledKey
local elapsed=0
local function connect(signal,callback)
	table.insert(connections,signal:Connect(callback))
end
local function menuOpen()
	if GuiService.MenuIsOpen or Input:GetFocusedTextBox()~=nil then return true end
	for guiName,names in {
		HunDinoTrainingHUD={"WeaponSelection","HubPanel","BaseTransitMenu"},
		HunDinoHuntQuest={"QuestBoard","ResultModal"},
		HunDinoEconomy={"Panel"},
		HuntingMapViewer={"ZonePicker"},
	} do
		local screen=playerGui:FindFirstChild(guiName)
		if screen and screen:IsA("ScreenGui") and screen.Enabled then
			for _,name in names do
				local object=screen:FindFirstChild(name)
				if object and object:IsA("GuiObject") and object.Visible then return true end
			end
		end
	end
	return false
end
local function cancelMining()
	if not alive or player:GetAttribute("MiningActive")~=true then return end
	local nodeId,ends=player:GetAttribute("MiningNodeId"),player:GetAttribute("MiningEnds")
	if type(nodeId)~="string" or nodeId=="" or type(ends)~="number" or ends~=ends or math.abs(ends)==math.huge then return end
	local actionKey=nodeId.."@"..string.format("%.9f",ends)
	if lastCancelledKey==actionKey then return end
	lastCancelledKey=actionKey
	remote:FireServer("Cancel")
end
local function cancelIfBlocked()
	if not windowFocused or menuOpen() then cancelMining() end
end
connect(Input.WindowFocusReleased,function() windowFocused=false;cancelMining() end)
connect(Input.WindowFocused,function() windowFocused=true;cancelIfBlocked() end)
connect(Input.TextBoxFocused,cancelMining)
connect(GuiService.MenuOpened,cancelMining)
connect(player.CharacterRemoving,cancelMining)
for _,name in {"MiningActive","MiningNodeId","MiningEnds"} do
	connect(player:GetAttributeChangedSignal(name),cancelIfBlocked)
end
connect(RunService.Heartbeat,function(dt)
	elapsed+=dt;if elapsed<.1 then return end;elapsed=0
	if player:GetAttribute("MiningActive")==true then cancelIfBlocked() end
end)
script.Destroying:Connect(function()
	cancelMining();alive=false
	for _,connection in connections do connection:Disconnect() end
end)
