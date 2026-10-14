-- Each client renders katana cosmetics for the replicated player and pet weapons.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Katana = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("KatanaPro"))
local localPlayer = Players.LocalPlayer
local entries = {}

local function update(weapon, root, started, duration, mark, sequence, height, now)
	if not weapon or not root then return end
	local entry = entries[weapon]
	if not entry then
		local effects = Katana.effects(weapon)
		-- Retry after streaming adds the effects.
		if #effects < 2 then return end
		entry = {effects = effects, sequence = -1, enabled = false}
		entries[weapon] = entry
	end
	entry.seen = true
	local elapsed = now - started
	local visible = localPlayer:GetAttribute("ShowComboFX") ~= false
	local enabled = visible and started > 0 and elapsed >= 0 and elapsed < duration
	if entry.enabled ~= enabled then
		Katana.setEffects(entry.effects, enabled)
		entry.enabled = enabled
	end
	if started > 0 and elapsed >= mark and sequence ~= entry.sequence then
		entry.sequence = sequence
		-- Late/streamed-in attacks must not spawn a wave after recovery.
		if enabled then
			Katana.spawnSlashWave(root.CFrame, height)
			Katana.burst(entry.effects)
		end
	end
end

local connection = RunService.RenderStepped:Connect(function()
	local now = workspace:GetServerTimeNow()
	for _,entry in entries do entry.seen = false end
	local pets = workspace:FindFirstChild("TrainingPets")
	if pets then
		for _,pet in pets:GetChildren() do
			if pet:GetAttribute("PetWeaponId") == "Katana" then
				update(pet:FindFirstChild("WeaponR"), pet.PrimaryPart,
					pet:GetAttribute("PetAttackStarted") or -1, 0.8, 0.36,
					pet:GetAttribute("PetAttackSequence") or 0, 2.3, now)
			end
		end
	end
	for _,player in Players:GetPlayers() do
		local character = player.Character
		local weapon = character and character:FindFirstChild("TrainingWeapon")
		if weapon and player:GetAttribute("WeaponId") == "Katana" then
			update(weapon, character:FindFirstChild("HumanoidRootPart"),
				weapon:GetAttribute("KatanaAttackStarted") or -1,
				weapon:GetAttribute("KatanaAttackDuration") or 0,
				weapon:GetAttribute("KatanaAttackWindup") or 0,
				weapon:GetAttribute("KatanaAttackSequence") or 0, 0.7, now)
		end
	end
	for weapon,entry in entries do
		if not entry.seen then
			Katana.setEffects(entry.effects, false)
			entries[weapon] = nil
		end
	end
end)

script.Destroying:Connect(function()
	connection:Disconnect()
	for _,entry in entries do Katana.setEffects(entry.effects, false) end
	table.clear(entries)
end)
