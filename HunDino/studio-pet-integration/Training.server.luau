-- L0: sảnh + bãi tập; không có thưởng, DataStore hay nhiệm vụ săn.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Shared.TrainingConfig)
local Rules = require(ReplicatedStorage.Shared.TrainingRules)
local Weapons = require(ReplicatedStorage.Shared.Weapons)
local weaponTemplates = game:GetService("ServerStorage"):WaitForChild("TrainingWeapons")
local PetStanding = require(ReplicatedStorage.Shared:WaitForChild("PetStanding"))
local PetAnimator = require(ReplicatedStorage.Shared:WaitForChild("PetAnimator"))
local PetPlacement = require(ReplicatedStorage.Shared:WaitForChild("PetPlacement"))
local ArmorEquipment=require(ReplicatedStorage.Shared:WaitForChild("ArmorEquipment"))
local map = workspace:WaitForChild("HunDinoL0")
local dummies = map.Training.Dummies
local remote = Instance.new("RemoteEvent")
remote.Name = "HunDinoTrainingAction"; remote.Parent = ReplicatedStorage
local states, owners = {}, {}
local pets = Instance.new("Folder"); pets.Name = "TrainingPets"; pets.Parent = workspace

local function makePart(parent, name, size, color, cf, anchored)
	local p = Instance.new("Part"); p.Name = name; p.Size = size; p.Color = color
	p.CFrame = cf; p.Anchored = anchored or false; p.CanCollide = false
	p.CanTouch = false; p.Massless = true; p.Material = Enum.Material.SmoothPlastic
	p.Parent = parent; return p
end
local function weld(a, b, offset)
	b.CFrame = a.CFrame * offset
	local w = Instance.new("Weld"); w.Part0 = a; w.Part1 = b; w.C0 = offset; w.Parent = b
	return w
end
local function alive(s)
	return s and s.Character and s.Character.Parent and s.Humanoid.Health > 0 and s.Root.Parent
end
local function grounded(s)
	return not s.Humanoid.Sit and not s.Root.Anchored
		and s.Humanoid.FloorMaterial ~= Enum.Material.Air
end
local function sync(s)
	local p = s.Player
	p:SetAttribute("Stamina", math.floor(s.Stamina + 0.5))
	p:SetAttribute("Drawn", s.Drawn)
	p:SetAttribute("Charging",s.Charge~=nil)
	p:SetAttribute("WeaponId", s.WeaponId)
	p:SetAttribute("PetWeaponId",s.PetWeaponId)
	p:SetAttribute("Blocking", s.Blocking)
	p:SetAttribute("BowBoost", s.BowBoostUntil > os.clock())
	p:SetAttribute("TrainingDamage", s.Damage)
	p:SetAttribute("PetDamage", s.PetDamage)
	p:SetAttribute("ComboStep", if os.clock() <= s.ComboUntil then s.ComboStep else 0)
	p:SetAttribute("ComboChain", if os.clock() <= s.ComboUntil then s.ComboChain or "" else "")
end
local function message(s, text)
	remote:FireClient(s.Player, "Message", text)
end
local function applyArmorTarget(s,target)
 local equipment=ArmorEquipment.read(s.Player,target)
 local model=if target=="Pet" then s.Pet else s.Character
 if model then
  local armor=ArmorEquipment.apply(model,target,equipment)
  if target=="Player" then
   s.Armor=armor
   local any=false;for _,id in equipment do if id~="None" then any=true;break end end
   s.Player:SetAttribute("TrainingArmor",any)
  end
 end
end
local function equipArmor(s,enabled)
 for _,slot in ArmorEquipment.Slots do
  local name="PlayerArmor_"..slot
  if not s.ArmorInitialized then
   if s.Player:GetAttribute(name)==nil then s.Player:SetAttribute(name,if enabled then "Training" else "None") end
  else s.Player:SetAttribute(name,if enabled then "Training" else "None") end
 end
 s.ArmorInitialized=true
 applyArmorTarget(s,"Player")
end
local function weaponPose(s)
	if not s.Grip or not s.Grip.Parent then return end
	local torso = s.Character:FindFirstChild("UpperTorso") or s.Character:FindFirstChild("Torso") or s.Root
	local left = s.Character:FindFirstChild("LeftHand") or s.Character:FindFirstChild("Left Arm") or torso
	local right = s.Character:FindFirstChild("RightHand") or s.Character:FindFirstChild("Right Arm") or torso
	if s.Drawn then
		s.Grip.Part0 = if s.WeaponId == "Bow" then left else right
		s.RestPose = if s.WeaponId == "Bow" then CFrame.new(0, .1, -.5) * CFrame.Angles(0, -math.pi/2, 0)
			else CFrame.new(0, -.5, -.5) * CFrame.Angles(math.rad(-25), 0, math.rad(10))
	else
		s.Grip.Part0 = torso
		s.RestPose = CFrame.new(.5, -1, 1) * CFrame.Angles(0, 0, math.rad(-30))
	end
	s.Grip.C0 = s.RestPose
	if s.OffGrip then
		s.OffGrip.Part0 = if s.Drawn then left else torso
		s.OffRest = if s.Drawn then CFrame.new(0, -.3, -.35) else CFrame.new(-.7, -.7, 1.3)
		s.OffGrip.C0 = if s.Blocking then CFrame.new(.5,.5,-1) * CFrame.Angles(0,-.3,0) else s.OffRest
	end
	if s.SheathGrip then s.SheathGrip.Part0 = torso; s.SheathGrip.C0 = CFrame.new(.5,-1,1.04)*CFrame.Angles(0,0,math.rad(-30)) end
end

local function createWeapon(s)
	if s.WeaponModel then s.WeaponModel:Destroy() end
	s.OffGrip = nil; s.SheathGrip = nil
	local model = weaponTemplates[s.WeaponId]:Clone(); model.Name = "TrainingWeapon"
	for _, assembly in model:GetChildren() do
		local handle = assembly.PrimaryPart
		for _, p in assembly:GetChildren() do
			if p:IsA("BasePart") then
				p.Anchored = false; p.CanCollide = false; p.CanQuery = false; p.Massless = true
				if p ~= handle and not p:FindFirstChild("KatanaWeld") and not p:FindFirstChild("WeaponProWeld") then weld(handle,p,handle.CFrame:ToObjectSpace(p.CFrame)) end
			end
		end
		local grip = weld(s.Root,handle,CFrame.new())
		if assembly.Name == "Main" then s.Grip = grip elseif assembly.Name == "Offhand" then s.OffGrip = grip else s.SheathGrip = grip end
	end
	model.Parent = s.Character; s.WeaponModel = model; weaponPose(s)
end
local function equipWeapon(s,id)
	if not Rules.canEquip(s,Weapons,id,os.clock()) then
		message(s,"Cất vũ khí bằng R và dừng động tác trước khi đổi trong bãi tập."); return
	end
	s.WeaponId=id; Rules.clearCombo(s); s.LastTarget=nil; s.BowBoostUntil=0; s.Aiming=false
	s.BusyUntil=os.clock()+.3; s.WantSprint=false
	createWeapon(s)
	sync(s); message(s,"Đã chọn "..Weapons[id].Name..". Nhấn R để rút.")
end
local function destroyPet(s)
	if s.PetAnimator then s.PetAnimator:Destroy(); s.PetAnimator = nil end
	if s.Pet then s.Pet:Destroy(); s.Pet = nil end
	s.PetTarget = nil
end
local function createPet(s)
	local pet, rig = PetStanding.build()
	pet.Name = "Pet_" .. s.Player.UserId
	pet.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	local animator = PetAnimator.new(pet, rig, weaponTemplates)
	animator.RenderPose = false
	s.PetWeaponId=s.Player:GetAttribute("PetWeaponId") or s.WeaponId
 if not table.find(Weapons.Order,s.PetWeaponId) then s.PetWeaponId="Hammer" end
 animator:SetWeapon(s.PetWeaponId)
	pet:SetAttribute("PetWeaponId", s.PetWeaponId)
	pet:SetAttribute("PetMoving", false)
	pet:SetAttribute("PetSpeed", 1)
	pet:SetAttribute("PetAttackSequence", 0)
	pet:SetAttribute("PetAttackStarted", -1)
	PetPlacement.place(pet, s.Character, s.Root.CFrame, pets)
	pet.Parent = pets
	s.Pet, s.PetAnimator, s.PetClock = pet, animator, 0
 for _,slot in ArmorEquipment.Slots do
  if s.Player:GetAttribute("PetArmor_"..slot)==nil then s.Player:SetAttribute("PetArmor_"..slot,"Metal") end
 end
 applyArmorTarget(s,"Pet")
end
local function updateDummy(dummy)
	local gui = dummy.Target.SignGui.Text
	gui.Text = (dummy:GetAttribute("Label") or "HÌNH NỘM " .. dummy.Name:match("%d+")) .. "\n" .. dummy:GetAttribute("Health") .. " / " .. Config.DummyHealth
end
local function hit(s, dummy, damage, isPet)
	if not dummy:IsDescendantOf(dummies) then return end
	local hp = dummy:GetAttribute("Health")
	local applied = math.min(hp, damage)
	hp -= applied
	if isPet then s.PetDamage += applied else s.Damage += applied end
	-- Đây là hình nộm vô hạn, làm đầy lại khi bị hạ; không phát thưởng.
	dummy:SetAttribute("Health", if hp <= 0 then Config.DummyHealth else hp)
	updateDummy(dummy)
	remote:FireAllClients("Hit", dummy.Target.Position, applied, isPet)
	sync(s)
end
local function directionOK(v, ranged)
	return typeof(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z
		and math.abs(v.X) < 2 and math.abs(v.Z) < 2 and math.abs(v.Y) < (if ranged then 2 else .01) and v.Magnitude > 0.5
end
local function lineOfSight(s, pos, dummy)
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {s.Character, pets}
	local result = workspace:Raycast(s.Root.Position, pos - s.Root.Position, params)
	return not result or result.Instance:IsDescendantOf(dummy)
end
local function startPetAttack(s, target)
	local animator = s.PetAnimator
	if not animator or animator:IsAttacking() then return end
	s.PetTarget = target
	local count = animator:GetHitCount()
	animator.OnHit = function(index)
		if not alive(s) or states[s.Player] ~= s or not s.InTraining or s.PetTarget ~= target
			or s.LastTarget ~= target or not target:IsDescendantOf(dummies)
			or os.clock() >= (s.TargetUntil or 0) then return end
		local point = target.Target.Position
		local center = s.Pet.PrimaryPart.Position + Vector3.new(0, 2, 0)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {s.Character, pets}
		local obstruction = workspace:Raycast(center, point - center, params)
		if (center - point).Magnitude > 7 or (s.Root.Position - point).Magnitude >= 18
			or (obstruction and not obstruction.Instance:IsDescendantOf(target)) then return end
		-- Split the original total damage across the two dagger strikes.
		local amount = math.floor(Config.PetDamage / count)
			+ (if index <= Config.PetDamage % count then 1 else 0)
		hit(s, target, amount, true)
		if s.PetWeaponId == "Bow" then remote:FireAllClients("Shot", center, point, false) end
	end
	if animator:Attack() then
		s.PetClock = os.clock() + Config.PetInterval
		s.Pet:SetAttribute("PetAttackStarted", workspace:GetServerTimeNow())
		s.Pet:SetAttribute("PetAttackSequence", s.Pet:GetAttribute("PetAttackSequence") + 1)
	end
end
local function attack(s, action, direction, releasedKind, releasedSpec)
	local weapon=Weapons[s.WeaponId]
	if not s.InTraining or not directionOK(direction,weapon.Ranged) then return end
	local now = os.clock()
	local kind,spec=releasedKind,releasedSpec
	if not kind then kind,spec=Rules.attack(Config,Weapons,s,action,now) end
	if not kind then return end
	direction = direction.Unit
	local flat=Vector3.new(direction.X,0,direction.Z)
	if flat.Magnitude>.01 then s.Root.CFrame = CFrame.lookAt(s.Root.Position, s.Root.Position + flat) end
	s.Humanoid.AutoRotate = false
	local character = s.Character
	local boosted=weapon.Ranged and now<s.BowBoostUntil
	if weapon.Ranged then s.BowBoostUntil=0 end
	s.WeaponModel:SetAttribute("WeaponAttackStarted", workspace:GetServerTimeNow())
	s.WeaponModel:SetAttribute("WeaponAttackDuration", spec.Duration)
	s.WeaponModel:SetAttribute("WeaponAttackWindup", spec.Windup)
	s.WeaponModel:SetAttribute("WeaponAttackHits", (if weapon.Ranged then spec.Shots else spec.Hits) or 1)
	s.WeaponModel:SetAttribute("WeaponAttackHitInterval", (if weapon.Ranged then spec.ShotInterval else spec.HitInterval) or (if weapon.Ranged then 0 else 0.13))
	s.WeaponModel:SetAttribute("WeaponAttackSequence", (s.WeaponModel:GetAttribute("WeaponAttackSequence") or 0) + 1)
	remote:FireClient(s.Player, "Attack", kind, spec.Name, spec.Duration)
	-- A serial prevents a late recovery callback from overwriting the next strike.
	s.AttackSerial=(s.AttackSerial or 0)+1; local serial=s.AttackSerial
	local windup = s.RestPose * CFrame.Angles(math.rad(100), 0, math.rad(-30))
	if spec.Style=="Thrust" then windup=s.RestPose*CFrame.new(0,0,.7)*CFrame.Angles(math.pi/2,0,0)
	elseif spec.Style=="Spin" or spec.Style=="Sweep" then windup=s.RestPose*CFrame.Angles(0,-1.4,math.pi/2) end
	if weapon.Ranged then windup=s.RestPose*CFrame.new(0,0,.25) end
	TweenService:Create(s.Grip, TweenInfo.new(spec.Windup), {C0 = windup}):Play()
	task.delay(spec.Windup, function()
		if not alive(s) or s.Character ~= character or states[s.Player] ~= s or s.AttackSerial~=serial then return end
		if weapon.Ranged then
			TweenService:Create(s.Grip,TweenInfo.new(.16),{C0=s.RestPose}):Play()
			local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances={s.Character,pets}
			for i=1,spec.Shots or 1 do
				if i>1 and spec.ShotInterval then task.wait(spec.ShotInterval) end
				if not alive(s) or s.Character~=character or states[s.Player]~=s or s.AttackSerial~=serial then return end
				local origin=s.Root.Position+Vector3.new(0,.8,0)
				local angle=math.rad(math.ceil((i-1)/2)*(if i%2==0 then -1 else 1)*(spec.Spread or 4))
				local aim=CFrame.fromAxisAngle(Vector3.yAxis,angle):VectorToWorldSpace(direction)
				local result=workspace:Raycast(origin,aim*spec.Range,params)
				local endpoint=if result then result.Position else origin+aim*spec.Range
				remote:FireAllClients("Shot",origin,endpoint,boosted and i==1)
				if result then
					for _,dummy in dummies:GetChildren() do if result.Instance:IsDescendantOf(dummy) then
						hit(s,dummy,math.floor(spec.Damage*(if boosted and i==1 then 1.25 else 1)+.5),false); s.LastTarget=dummy; s.TargetUntil=os.clock()+12
						break
					end end
				end
			end
			return
		end
		for n=1,spec.Hits or 1 do
			if n>1 then task.wait(spec.HitInterval or .13) end
			if not alive(s) or s.Character~=character or states[s.Player]~=s or s.AttackSerial~=serial then return end
			local pose=s.RestPose*CFrame.Angles(math.rad(-95),0,if n%2==0 then -.4 else .4)
			if spec.Style=="Thrust" then pose=s.RestPose*CFrame.new(0,0,-2)*CFrame.Angles(math.pi/2,0,0)
			elseif spec.Style=="Spin" or spec.Style=="Sweep" then pose=s.RestPose*CFrame.Angles(0,if n%2==0 then -1.5 else 1.5,math.pi/2) end
			TweenService:Create(s.Grip, TweenInfo.new(.1), {C0=pose}):Play()
			if spec.Style=="Shield" and s.OffGrip then TweenService:Create(s.OffGrip,TweenInfo.new(.1),{C0=s.OffRest*CFrame.new(.4,.3,-1.2)}):Play() end
			if spec.Name then remote:FireAllClients("ComboFX",s.Root.CFrame,spec.Style,spec.Range) end
			if s.OffGrip and s.WeaponId=="DualDaggers" then TweenService:Create(s.OffGrip,TweenInfo.new(.1),{C0=s.OffRest*CFrame.Angles(-1.5,0,if n%2==0 then .4 else -.4)}):Play() end
			for _, dummy in dummies:GetChildren() do
				local delta = dummy.Target.Position - s.Root.Position
				local targetFlat = Vector3.new(delta.X, 0, delta.Z)
				if delta.Magnitude <= spec.Range and targetFlat.Magnitude > 0 and direction:Dot(targetFlat.Unit) >= (spec.Arc or .3)
					and lineOfSight(s, dummy.Target.Position, dummy) then
					hit(s, dummy, spec.Damage, false); s.LastTarget = dummy; s.TargetUntil = now + 12
				end
			end
		end
	end)
	task.delay(spec.Duration, function()
		if states[s.Player] ~= s or not alive(s) or s.Character ~= character or s.AttackSerial~=serial then return end
		TweenService:Create(s.Grip, TweenInfo.new(0.12), {C0 = s.RestPose}):Play()
		if s.OffGrip then TweenService:Create(s.OffGrip,TweenInfo.new(.12),{C0=s.OffRest}):Play() end
		s.Humanoid.AutoRotate = true
	end)
	sync(s)
end
local function cancelCharge(s)
 if Rules.cancelCharge(s,os.clock()) then
  weaponPose(s);s.Humanoid.AutoRotate=true;s.Character:SetAttribute("ChargePose",nil)
  remote:FireClient(s.Player,"ChargeStop");sync(s)
 end
end
local function releaseCharge(s,direction)
 if not s.Charge then return end
 if not alive(s) or not s.InTraining then cancelCharge(s);return end
 local c=s.Charge;local aim=if directionOK(direction,true) then direction else c.Direction
 local kind,spec=Rules.releaseCharge(Config,s,os.clock())
 s.Character:SetAttribute("ChargePose",nil);weaponPose(s)
 remote:FireClient(s.Player,"ChargeStop");attack(s,c.Action,aim,kind,spec)
end
local function toggleDraw(s, target)
	if os.clock() < s.BusyUntil then return end
	s.BusyUntil = os.clock() + Config.SheatheTime; Rules.clearCombo(s); s.Sprinting = false
	s.Blocking=false; s.BowBoostUntil=0; s.Aiming=false; weaponPose(s)
	s.ChangeDraw = target
	message(s, (if target then "Đang rút " else "Đang cất ")..Weapons[s.WeaponId].Name.."…")
end
local function travel(s, destination, arrivalOverride, arrivalMessage)
	if s.Travelling then return end
	if os.clock() < s.BusyUntil then return end
	cancelCharge(s)
	s.InTraining = destination == "Training"; s.Drawn = false; s.WantSprint = false; s.Sprinting = false
	s.ChangeDraw = nil; Rules.clearCombo(s); s.LastTarget = nil; s.BusyUntil = os.clock() + 0.5
	s.Blocking=false; s.Aiming=false; s.BowBoostUntil=0
	s.Humanoid.AutoRotate = true; weaponPose(s)
	local cf = arrivalOverride or (if s.InTraining then map.Training.Arrival.CFrame * CFrame.Angles(0, 0, 0)
		else map.Lobby.Arrival.CFrame)
	s.Travelling = true
 local before = s.Character
 s.BusyUntil = math.huge
 pcall(function() s.Player:RequestStreamAroundAsync(cf.Position, 3) end)
 s.Travelling = false
 if not alive(s) or states[s.Player] ~= s or s.Character ~= before then return end
 s.BusyUntil = os.clock() + 0.5
 s.Character:PivotTo(cf); s.Root.AssemblyLinearVelocity = Vector3.zero; s.Root.AssemblyAngularVelocity=Vector3.zero
	s.PetAnimator:CancelAttack(); s.PetTarget = nil
	s.Pet:SetAttribute("PetAttackStarted", -1)
	PetPlacement.place(s.Pet, s.Character, cf, pets)
	s.Player:SetAttribute("InTraining", s.InTraining)
	message(s, arrivalMessage or (if s.InTraining then "Nhấn I chọn vũ khí, R để rút. Cận chiến bên trái, cung bên phải." else "Đã trở về trại thợ săn."))
	sync(s)
end
local function bindPrompt(part, callback)
	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	prompt.Triggered:Connect(function(player)
		local s = states[player]
		-- Prompt vẫn phải được xác minh trên server.
		if not alive(s) or (s.Root.Position - part.Position).Magnitude > 12 or os.clock() < s.BusyUntil then return end
		callback(s)
	end)
end
local transit=map:WaitForChild("BaseTransit")
local function transitReady(s)
 if s.Travelling or s.InTraining or s.Drawn or s.Charge or s.Blocking or s.Sprinting or os.clock()<s.BusyUntil then
  message(s,"Cất vũ khí và dừng động tác trước khi dịch chuyển.");return false
 end
 return true
end
bindPrompt(transit.Center.Pad,function(s)
 if not transitReady(s) then return end
 local rows={}
 for id=1,Config.LobbyCapacity do rows[id]={Owner=if owners[id] then owners[id].DisplayName else "Chưa có chủ"} end
 s.BaseTransitUntil=os.clock()+60
 remote:FireClient(s.Player,"BaseTransitOpen",{Bases=rows,Origin=transit.Center.Pad.Position})
end)
for id=1,Config.LobbyCapacity do
 bindPrompt(transit.Bases["Base"..id].Pad,function(s)
  if transitReady(s) then travel(s,"Lobby",transit.Center.Arrival.CFrame,"Đã về sảnh trung tâm.") end
 end)
end
local function selectBaseTransit(s,id)
 if typeof(id)~="number" or id~=id or id%1~=0 or id<1 or id>Config.LobbyCapacity then return end
 if os.clock()>(s.BaseTransitUntil or 0) or (s.Root.Position-transit.Center.Pad.Position).Magnitude>12 or not transitReady(s) then return end
 s.BaseTransitUntil=nil
 travel(s,"Lobby",transit.Bases["Base"..id].Arrival.CFrame,string.format("Đã đến Base %02d.",id))
end
bindPrompt(map.Lobby.ToTraining, function(s) travel(s, "Training") end)
bindPrompt(map.Training.ToLobby, function(s) travel(s, "Lobby") end)
bindPrompt(map.Training.EquipmentRack, function(s)
	if s.Drawn then message(s, "Cất vũ khí bằng R trước khi thay giáp."); return end
	equipArmor(s, not s.Player:GetAttribute("TrainingArmor")); s.BusyUntil = os.clock() + 0.3
end)
bindPrompt(map.Training.ResetPost, function(s)
	if s.Drawn then message(s, "Cất vũ khí bằng R trước khi tương tác."); return end
	s.Damage = 0; s.PetDamage = 0; s.Stamina = Config.MaxStamina; Rules.clearCombo(s); s.LastTarget = nil
	s.Humanoid.Health = s.Humanoid.MaxHealth; s.BusyUntil = os.clock() + 0.3; sync(s)
	message(s, "Đã xóa thống kê của bạn. Bắt đầu lượt tập mới!")
end)
for _,rack in map.Training.WeaponRacks:GetChildren() do
	bindPrompt(rack,function(s) equipWeapon(s,rack.Name) end)
end
local function equipInventory(s,value)
 if typeof(value)~="table" or (value.Target~="Player" and value.Target~="Pet")
  or (value.Kind~="Weapons" and value.Kind~="Armor") then return end
 if not s.InTraining or s.Drawn or s.Charge or s.Blocking or s.Sprinting or os.clock()<s.BusyUntil then
  message(s,"Trang bị trong bãi tập khi đã cất vũ khí và dừng động tác.");return
 end
 if value.Kind=="Weapons" then
  if typeof(value.Id)~="string" or not table.find(Weapons.Order,value.Id) then return end
  if value.Target=="Player" then equipWeapon(s,value.Id)
  else
   s.PetWeaponId=value.Id;s.PetTarget=nil;s.PetAnimator:SetWeapon(value.Id)
   s.Pet:SetAttribute("PetWeaponId",value.Id);s.Pet:SetAttribute("PetAttackStarted",-1)
   s.BusyUntil=os.clock()+.3;sync(s);message(s,"Pet đã trang bị "..Weapons[value.Id].Name..".")
  end
 else
  if typeof(value.Slot)~="string" or typeof(value.Id)~="string" or not ArmorEquipment.valid(value.Slot,value.Id) then return end
  s.Player:SetAttribute(value.Target.."Armor_"..value.Slot,value.Id)
  applyArmorTarget(s,value.Target);s.BusyUntil=os.clock()+.2;sync(s)
  message(s,(if value.Target=="Pet" then "Pet: " else "Người: ")..ArmorEquipment.SlotNames[value.Slot].." • "..(if value.Id=="None" then "Đã tháo" else ArmorEquipment.Sets[value.Id].Name))
 end
end

remote.OnServerEvent:Connect(function(player, action, value)
	local s = states[player]
	if not alive(s) or typeof(action) ~= "string" then return end
	local now = os.clock()
	-- Giới hạn cả request không hợp lệ trước khi xử lý trạng thái.
	if now - s.PacketWindow >= 1 then s.PacketWindow = now; s.Packets = 0 end
	s.Packets += 1; if s.Packets > 30 then return end
	if action=="BaseTransitSelect" then selectBaseTransit(s,value)
 elseif action=="EquipInventory" then equipInventory(s,value)
 elseif action=="ChargeStart" then
  if typeof(value)~="table" or typeof(value.Id)~="number" or value.Id~=value.Id or value.Id<=0 or value.Id%1~=0 or value.Id>1e9 or not s.InTraining then return end
  if not directionOK(value.Direction,true) then remote:FireClient(player,"ChargeRejected",value.Id);return end
  local c=Rules.beginCharge(Config,Weapons,s,value.Action,now)
  if not c then remote:FireClient(player,"ChargeRejected",value.Id);return end
  c.Id=value.Id;c.Action=value.Action;c.Direction=value.Direction.Unit
  s.AttackSerial=(s.AttackSerial or 0)+1;s.WantSprint=false;s.Sprinting=false;s.Humanoid.AutoRotate=false
  s.Character:SetAttribute("ChargePose","Bow")
  TweenService:Create(s.Grip,TweenInfo.new(.18),{C0=s.RestPose*CFrame.new(0,0,.25)}):Play()
  remote:FireClient(player,"ChargeStart",c.Time,c.Id);sync(s)
 elseif action=="ChargeAim" then
  if s.Charge and directionOK(value,true) then s.Charge.Direction=value.Unit end
 elseif action=="ChargeRelease" then
  if typeof(value)=="table" and s.Charge and value.Id==s.Charge.Id then releaseCharge(s,value.Direction) end
 elseif action=="ChargeCancel" then cancelCharge(s)
 elseif action == "EquipWeapon" then
		equipWeapon(s,value)
	elseif action == "TravelMenu" then
		if value~="Training" and value~="Lobby" then return end
		if s.Drawn or s.Blocking or now<s.BusyUntil or s.Sprinting then
			message(s,"Cất vũ khí và dừng động tác trước khi chuyển khu."); return
		end
		travel(s,value)
	elseif action == "Aim" then
		s.Aiming=value==true and s.WeaponId=="Bow" and s.Drawn
	elseif action == "Guard" then
		if value==false then s.Blocking=false; weaponPose(s)
		elseif value==true and s.WeaponId=="SwordShield" and s.Drawn and now>=s.BusyUntil and s.Stamina>0 then
			s.Blocking=true; s.Sprinting=false; s.WantSprint=false; Rules.clearCombo(s); weaponPose(s)
		end
		sync(s)
	elseif action == "Sprint" then
		if typeof(value) ~= "boolean" then return end
		if value then cancelCharge(s) end
		s.WantSprint = value; if value then Rules.clearCombo(s); s.Blocking=false; weaponPose(s) end
		if not value then s.Sprinting = false end
	elseif action == "Draw" then
		if s.Charge then cancelCharge(s);s.BusyUntil=now end
		s.WantSprint = false; toggleDraw(s, not s.Drawn)
	elseif action == "Light" or action == "Heavy" or action == "Skill" then
		attack(s, action, value)
	elseif action == "Jump" and not s.Blocking and now >= s.BusyUntil and grounded(s) and now - s.LastJumpAt >= 0.45 then
		Rules.clearCombo(s); s.LastJumpAt = now; s.BusyUntil = now + 0.15
		remote:FireClient(player, "Jump", s.Character)
	elseif action == "Dodge" and not s.Blocking and directionOK(value) and now >= s.BusyUntil and grounded(s)
		and now - s.LastJumpAt >= 0.45 and Rules.dodge(Config,Weapons,s,now) then
		remote:FireClient(player,"Dodge",Config.DodgeTime)
		s.Humanoid.WalkSpeed=Config.WalkSpeed
		if s.WeaponId=="Bow" and s.Drawn and s.Aiming then s.BowBoostUntil=now+4 end
		local a = Instance.new("Attachment"); a.Name = "DodgeAttachment"; a.Parent = s.Root
		local velocity = Instance.new("LinearVelocity"); velocity.Name = "DodgeVelocity"; velocity.Attachment0 = a
		velocity.RelativeTo = Enum.ActuatorRelativeTo.World; velocity.MaxForce = 100000
		-- Constrain only the ground plane; gravity must remain free on slopes/edges.
		velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
		velocity.PrimaryTangentAxis = Vector3.xAxis; velocity.SecondaryTangentAxis = Vector3.zAxis
		local direction = value.Unit
		s.Character:SetAttribute("DarkStepDuration",Config.DodgeTime)
		s.Character:SetAttribute("DarkStepDirection",direction)
		s.Character:SetAttribute("DarkStepStarted",workspace:GetServerTimeNow())
		s.Character:SetAttribute("DarkStepSequence",(s.Character:GetAttribute("DarkStepSequence") or 0)+1)
		velocity.PlaneVelocity = Vector2.new(direction.X, direction.Z) * Config.DodgeSpeed
		velocity.Parent = s.Root
		-- Ease toward walking speed instead of an abrupt full-speed stop.
		TweenService:Create(velocity,TweenInfo.new(Config.DodgeTime,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
			{PlaneVelocity=Vector2.new(direction.X,direction.Z)*Config.WalkSpeed}):Play()
		local root=s.Root; local character=s.Character
		task.delay(Config.DodgeTime, function()
			velocity:Destroy(); a:Destroy()
			if not alive(s) or s.Character~=character then return end
			local move=s.Humanoid.MoveDirection
			local residual=if move.Magnitude>.1 then move*Config.WalkSpeed else direction*4
			root.AssemblyLinearVelocity=Vector3.new(residual.X,root.AssemblyLinearVelocity.Y,residual.Z)
		end)
		sync(s)
	end
end)
local function baseSign(id, text)
	local part = map.BaseSigns:FindFirstChild("Base" .. id)
	part.SignGui.Text.Text = string.format("BASE %02d\n%s", id, text)
end
local baseRandom=Random.new()
local function chooseFreeBase()
	local candidates={}
	for id=1,Config.LobbyCapacity do candidates[id]=id end
	while #candidates>0 do
		local index=baseRandom:NextInteger(1,#candidates)
		local id=table.remove(candidates,index)
		if not owners[id] then return id end
	end
	return nil
end
local function setup(player)
	local baseId=chooseFreeBase()
	if not baseId then player:Kick("Trại đã đủ 12 người. Hãy vào máy chủ khác."); return end
	owners[baseId] = player; player:SetAttribute("BaseId", baseId); baseSign(baseId, player.DisplayName)
	local function characterAdded(character)
		local old = states[player]; if old then destroyPet(old) end
		local humanoid = character:WaitForChild("Humanoid")
		local rootPart = character:WaitForChild("HumanoidRootPart")
		if player.Character ~= character or not player.Parent then return end
		local s = {
			Player = player, Character = character, Humanoid = humanoid, Root = rootPart,
			Stamina = Config.MaxStamina, LastSpend = 0, BusyUntil = 0, Drawn = false,
			ComboStep = 0, ComboUntil = 0, Damage = 0, PetDamage = 0, InTraining = false,
			WantSprint = false, Sprinting = false, PacketWindow = 0, Packets = 0, LastJumpAt = -math.huge,
			WeaponId=player:GetAttribute("WeaponId") or "Hammer", Blocking=false, Aiming=false, BowBoostUntil=0,
		}
		states[player] = s
		player:SetAttribute("InTraining", false)
		createWeapon(s); equipArmor(s, true); createPet(s); sync(s)
		local previousHealth=humanoid.Health
		humanoid.HealthChanged:Connect(function(health)
			if health<previousHealth then cancelCharge(s) end
			previousHealth=health
		end)
		humanoid.Died:Connect(function()
			cancelCharge(s); s.WantSprint = false; s.LastTarget = nil; destroyPet(s)
		end)
	end
	player.CharacterAdded:Connect(characterAdded)
	if player.Character then task.spawn(characterAdded, player.Character) end
end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player)
	local s = states[player]; if s then destroyPet(s) end
	states[player] = nil
	local id = player:GetAttribute("BaseId")
	if id and owners[id] == player then owners[id] = nil; baseSign(id, "Chưa có chủ") end
end)
for _, player in Players:GetPlayers() do task.spawn(setup, player) end
local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
	accumulator += dt; if accumulator < 0.1 then return end
	local petAnimationDt = accumulator
	dt = math.min(accumulator, 0.25); accumulator = 0
	local now = os.clock()
	for _, s in states do
		if not alive(s) then continue end
		if s.Charge and now-s.Charge.Started>=s.Charge.MaxHold then releaseCharge(s,s.Charge.Direction) end
		if s.ChangeDraw ~= nil and now >= s.BusyUntil then
			s.Drawn = s.ChangeDraw; s.ChangeDraw = nil; weaponPose(s)
		end
		if s.WantSprint and s.Drawn and now >= s.BusyUntil then toggleDraw(s, false) end
		s.Sprinting = s.WantSprint and not s.Drawn and now >= s.BusyUntil and s.Stamina > 0
			and s.Humanoid.MoveDirection.Magnitude > 0.1
		if s.Sprinting then
			s.Stamina = math.max(0, s.Stamina - Rules.staminaCost(Config,Config.SprintCost) * dt); s.LastSpend = now
			if s.Stamina == 0 then s.WantSprint = false; s.Sprinting = false end
		end
		if s.Blocking then
			s.Stamina=math.max(0,s.Stamina-Rules.staminaCost(Config,Config.GuardCost)*dt); s.LastSpend=now
			if s.Stamina==0 then s.Blocking=false; weaponPose(s) end
		end
		Rules.regenerate(Config, s, now, dt)
		s.Humanoid.WalkSpeed = if s.Blocking then 6 elseif now < (s.DodgingUntil or 0) then Config.WalkSpeed elseif now < s.BusyUntil then 8 elseif s.Sprinting then Config.SprintSpeed else Config.WalkSpeed
		-- Standing pet: move the feet along the collision surface.
		local target = s.LastTarget
		local active = s.InTraining and target and now < s.TargetUntil
			and (target.Target.Position - s.Root.Position).Magnitude < 18
		local desired = if active then target.Target.Position + Vector3.new(3, 0, 3)
			else s.Root.CFrame:PointToWorldSpace(Vector3.new(3, 0, 4))
		local petPos = s.Pet.PrimaryPart.Position
		local flat = Vector3.new(desired.X - petPos.X, 0, desired.Z - petPos.Z)
		local step = flat * math.min(1, 18 * dt / math.max(flat.Magnitude, 0.01))
		local filter = RaycastParams.new()
		filter.FilterType = Enum.RaycastFilterType.Exclude
		filter.FilterDescendantsInstances = {s.Character, pets}
		filter.RespectCanCollide = true
		local moved = false
		if flat.Magnitude > 0.2 and not workspace:Raycast(petPos + Vector3.new(0, 1.5, 0), step, filter) then
			local newPos = PetPlacement.position(s.Character, petPos + step, pets)
			s.Pet:PivotTo(CFrame.lookAt(newPos, newPos + flat))
			moved = true
		elseif active then
			local aim = target.Target.Position - petPos
			aim = Vector3.new(aim.X, 0, aim.Z)
			if aim.Magnitude > 0.1 then s.Pet:PivotTo(CFrame.lookAt(petPos, petPos + aim)) end
		end
		s.Pet:SetAttribute("PetMoving", moved)
		s.Pet:SetAttribute("PetSpeed", 1.3)
		if active and (s.Pet.PrimaryPart.Position + Vector3.new(0, 2, 0) - target.Target.Position).Magnitude <= 7
			and now >= s.PetClock and lineOfSight(s, target.Target.Position, target) then
			startPetAttack(s, target)
		end
		s.PetAnimator:Update(petAnimationDt)
		sync(s)
	end
end)
print("[HunDino L0] Sảnh 12 base và bãi tập đã khởi tạo.")


