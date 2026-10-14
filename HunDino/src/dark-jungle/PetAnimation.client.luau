local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PetStanding = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetStanding"))
local PetAnimator = require(ReplicatedStorage.Shared:WaitForChild("PetAnimator"))
local pets = workspace:WaitForChild("TrainingPets")
local entries = {}

local function discard(model)
	local entry = entries[model]
	if entry then entry.anim:Destroy(); entries[model] = nil end
end

local connection = RunService.PreSimulation:Connect(function(dt)
	for model in entries do
		if model.Parent ~= pets or not model:FindFirstChild("Root") then discard(model) end
	end
	for _, model in pets:GetChildren() do
		if not model:IsA("Model") then continue end
		local entry = entries[model]
		if not entry then
			local rig = PetStanding.bind(model)
			if not rig then continue end
			entry = { anim = PetAnimator.new(model, rig, nil), sequence = -1, weapon = nil }
			entries[model] = entry
		end
		local anim = entry.anim
		local id = model:GetAttribute("PetWeaponId")
		if entry.weapon ~= id or (anim.motorR and not anim.motorR.Parent) or (anim.motorL and not anim.motorL.Parent) then
			if not id or not anim:BindWeapon(id) then continue end
			entry.weapon = id
			entry.sequence = -1
		end
		anim:SetMoving(model:GetAttribute("PetMoving") == true, model:GetAttribute("PetSpeed") or 1)
		local sequence = model:GetAttribute("PetAttackSequence") or 0
		local started = model:GetAttribute("PetAttackStarted") or -1
		if started < 0 then
			anim:CancelAttack()
		elseif sequence ~= entry.sequence then
			anim:SyncAttack(workspace:GetServerTimeNow() - started)
		end
		entry.sequence = sequence
		anim:Update(dt)
	end
end)

script.Destroying:Connect(function()
	connection:Disconnect()
	for model in entries do discard(model) end
end)
