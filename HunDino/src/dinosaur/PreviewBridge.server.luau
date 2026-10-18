-- The buttons are Studio preview controls; game AI can use the model's bindables.
if not game:GetService("RunService"):IsStudio() then return end
local Players = game:GetService("Players")
local model = workspace:WaitForChild("Dinosaur01_TRex_Visual")
local command = game:GetService("ReplicatedStorage"):WaitForChild("DinosaurPreviewCommand")
local last = {}
command.OnServerEvent:Connect(function(player, action)
	if action ~= "Bite" and action ~= "Walk" and action ~= "Reset" then return end
	local now = os.clock()
	if now - (last[player] or -math.huge) < .15 then return end
	last[player] = now
	if action == "Bite" then model.BiteRequest:Fire()
	elseif action == "Walk" then model.WalkRequest:Fire(not model:GetAttribute("PreviewWalking"))
	else model.ResetMotionRequest:Fire() end
end)
Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
