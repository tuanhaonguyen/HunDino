local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local VFX=require(RS:WaitForChild("Shared"):WaitForChild("WeaponVFX"))
local Animator=require(RS.Shared:WaitForChild("PetAnimator"))
local localPlayer=Players.LocalPlayer
local entries={}

local function update(model,id,main,off,baseCF,started,duration,marks,sequence,now)
	if not main then return end
	local entry=entries[model]
	if not entry or entry.main~=main or entry.off~=off or entry.id~=id then
		if entry then VFX.set(entry.effects,false) end
		local effects=VFX.effects(model)
		local required=if id=="DualDaggers" then 4 else 2
		if #effects<required then entries[model]=nil; return end
		entry={main=main,off=off,id=id,effects=effects,sequence=-1,fired={},enabled=false}
		entries[model]=entry
	end
	entry.seen=true
	if entry.sequence~=sequence then entry.sequence=sequence;entry.fired={} end
	local elapsed=now-started
	local enabled=localPlayer:GetAttribute("ShowComboFX")~=false and started>0 and elapsed>=0 and elapsed<duration
	if entry.enabled~=enabled then VFX.set(entry.effects,enabled);entry.enabled=enabled end
	for i,mark in marks do
		if started>0 and elapsed>=mark and not entry.fired[i] then
			entry.fired[i]=true
			if enabled then
				-- Bow already receives a green Shot tracer towards the actual target.
				if id~="Bow" then VFX.trigger(id,baseCF,i) end
				VFX.burst(entry.effects)
			end
		end
	end
end

local connection=RunService.RenderStepped:Connect(function()
	local now=workspace:GetServerTimeNow()
	for _,entry in entries do entry.seen=false end
	local pets=workspace:FindFirstChild("TrainingPets")
	if pets then
		for _,pet in pets:GetChildren() do
			local id=pet:GetAttribute("PetWeaponId")
			local profile=id and Animator.profile(id)
			if profile and pet.PrimaryPart then
				local marks={}
				for _,mark in profile.marks do table.insert(marks,mark*profile.dur) end
				update(pet,id,pet:FindFirstChild("WeaponR") or pet:FindFirstChild("WeaponL"),
					pet:FindFirstChild("WeaponL"),pet.PrimaryPart.CFrame,pet:GetAttribute("PetAttackStarted") or -1,
					profile.dur,marks,pet:GetAttribute("PetAttackSequence") or 0,now)
			end
		end
	end
	for _,player in Players:GetPlayers() do
		local char=player.Character
		local weapon=char and char:FindFirstChild("TrainingWeapon")
		local root=char and char:FindFirstChild("HumanoidRootPart")
		local humanoid=char and char:FindFirstChildOfClass("Humanoid")
		local id=player:GetAttribute("WeaponId")
		if weapon and root and humanoid and Animator.profile(id) then
			local marks={}
			local windup=weapon:GetAttribute("WeaponAttackWindup") or 0
			local interval=weapon:GetAttribute("WeaponAttackHitInterval") or 0.13
			for i=1,weapon:GetAttribute("WeaponAttackHits") or 1 do table.insert(marks,windup+(i-1)*interval) end
			local feet=root.CFrame*CFrame.new(0,-humanoid.HipHeight-root.Size.Y/2,0)
			update(weapon,id,weapon:FindFirstChild("Main"),weapon:FindFirstChild("Offhand"),feet,
				weapon:GetAttribute("WeaponAttackStarted") or -1,weapon:GetAttribute("WeaponAttackDuration") or 0,
				marks,weapon:GetAttribute("WeaponAttackSequence") or 0,now)
		end
	end
	for model,entry in entries do
		if not entry.seen then VFX.set(entry.effects,false);entries[model]=nil end
	end
end)

script.Destroying:Connect(function()
	connection:Disconnect()
	for _,entry in entries do VFX.set(entry.effects,false) end
	table.clear(entries)
end)
