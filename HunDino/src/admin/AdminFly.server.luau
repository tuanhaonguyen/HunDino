-- Temporary map inspection utility. Remove ServerScriptService.AdminFly and
-- StarterPlayerScripts.HunDinoAdminFly to remove the feature completely.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Chat=game:GetService("TextChatService")
local Policy=require(script.Parent:WaitForChild("AdminFlyPolicy"))
local remote=Instance.new("RemoteEvent");remote.Name="HunDinoAdminFly";remote.Parent=RS
local states,connections,packets={},{},{}
local function allowed(player)
	return Policy.Allowed(player.UserId,game.CreatorId,game.CreatorType.Name)
end
local function message(player,text) remote:FireClient(player,"Message",text) end
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<1e7 end
local function vector(v)
	return typeof(v)=="Vector3" and finite(v.X) and finite(v.Y) and finite(v.Z)
end
local function character(player)
	local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid")
	local r=c and c:FindFirstChild("HumanoidRootPart")
	if c and h and h.Health>0 and r and r:IsA("BasePart") and not r.Anchored then return c,h,r end
end
local function landing(player,s)
	local root=s.root
	local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
	local ignore={s.character}
	for _,name in {"TrainingPets","Dinosaur01_TRex_Visual"} do
		local object=workspace:FindFirstChild(name);if object then table.insert(ignore,object) end
	end
	params.FilterDescendantsInstances=ignore;params.RespectCanCollide=true;params.IgnoreWater=false
	local hit=workspace:Raycast(root.Position+Vector3.new(0,2048,0),Vector3.new(0,-4096,0),params)
	local inArea=true
	if player:GetAttribute("InHunting")==true then
		local map=workspace:FindFirstChild("HuntingRainforest")
		local offset=map and map:GetAttribute("WorldOffset") or Vector3.new(0,0,6500)
		local p=root.Position-offset
		inArea=math.abs(p.X)<=2000 and math.abs(p.Z)<=2250
	end
	if inArea and hit and hit.Material~=Enum.Material.Water and hit.Normal.Y>.5 then
		local p=hit.Position+Vector3.new(0,math.max(3,s.humanoid.HipHeight+root.Size.Y*.5)+.15,0)
		local look=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)
		return CFrame.lookAt(p,p+(if look.Magnitude>.01 then look.Unit else Vector3.zAxis))
	end
	return s.startFrame
end
local function stop(player,land)
	local s=states[player];states[player]=nil
	if s then
		local target=if land and s.root.Parent and player.Character==s.character then landing(player,s) else nil
		for _,object in {s.velocity,s.orientation,s.attachment} do object:Destroy() end
		if s.added then s.added:Disconnect() end
		for p,collide in s.collisions do if p.Parent then p.CanCollide=collide end end
		if s.humanoid.Parent then
			s.humanoid.PlatformStand=s.platformStand;s.humanoid.AutoRotate=s.autoRotate
			if not s.platformStand then s.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
		end
		if s.root.Parent then
			if target then s.character:PivotTo(target) end
			s.root.AssemblyLinearVelocity=Vector3.zero;s.root.AssemblyAngularVelocity=Vector3.zero
			pcall(function() s.root:SetNetworkOwnershipAuto() end)
		end
	end
	player:SetAttribute("AdminFlying",false)
end
local function start(player)
	if not allowed(player) then return end
	if states[player] then return end
	local c,h,r=character(player);if not c then return end
	local a=Instance.new("Attachment");a.Name="AdminFlyAttachment";a.Parent=r
	local lv=Instance.new("LinearVelocity");lv.Name="AdminFlyVelocity";lv.Attachment0=a
	lv.RelativeTo=Enum.ActuatorRelativeTo.World;lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
	lv.ForceLimitsEnabled=false;lv.VectorVelocity=Vector3.zero;lv.Parent=r
	local orientation=Instance.new("AlignOrientation");orientation.Name="AdminFlyOrientation"
	orientation.Mode=Enum.OrientationAlignmentMode.OneAttachment;orientation.Attachment0=a
	orientation.MaxTorque=1e8;orientation.Responsiveness=18;orientation.CFrame=r.CFrame.Rotation;orientation.Parent=r
	local s={character=c,humanoid=h,root=r,attachment=a,velocity=lv,orientation=orientation,
		-- Entering inspection cancels weapon poses, so normal movement resumes
		-- with AutoRotate even if the interrupted charge had disabled it.
		startFrame=r.CFrame,platformStand=h.PlatformStand,autoRotate=true,collisions={},
		direction=Vector3.zero,look=r.CFrame.LookVector,boost=false,lastMove=0,currentVelocity=Vector3.zero}
	states[player]=s
	local function noCollision(p)
		if p:IsA("BasePart") then s.collisions[p]=p.CanCollide;p.CanCollide=false end
	end
	for _,p in c:GetDescendants() do noCollision(p) end
	s.added=c.DescendantAdded:Connect(noCollision)
	r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero
	h.Sit=false;h.PlatformStand=true;h.AutoRotate=false
	pcall(function() r:SetNetworkOwner(player) end)
	player:SetAttribute("AdminFlying",true)
	message(player,"Đang bay · WASD di chuyển · Space lên · Ctrl xuống · Shift nhanh")
end
local function setSpeed(player,value)
	if not Policy.ValidateSpeed(value) then return false end
	player:SetAttribute("AdminFlySpeed",value);return true
end
local function control(player,action,value)
	if not allowed(player) then return end
	if action=="Toggle" then
		if states[player] then stop(player,true) else start(player) end
	elseif action=="SetEnabled" and typeof(value)=="boolean" then
		if value then start(player) else stop(player,true) end
	elseif action=="SetSpeed" or action=="Speed" then setSpeed(player,value) end
end
remote.OnServerEvent:Connect(function(player,action,value,look,boost)
	-- The server policy is checked on every request; client attributes are UI only.
	if not allowed(player) or type(action)~="string" then return end
	local now=os.clock();local p=packets[player]
	if not p or now-p.window>=1 then p={window=now,count=0,lastControl=-math.huge};packets[player]=p end
	p.count+=1;if p.count>60 then return end
	if action=="Move" then
		local s=states[player];if not s or not vector(value) or value.Magnitude>4 then return end
		s.direction=if value.Magnitude>1 then value.Unit else value
		if vector(look) then
			local horizontal=Vector3.new(look.X,0,look.Z)
			if horizontal.Magnitude>.01 then s.look=horizontal.Unit end
		end
		s.boost=boost==true;s.lastMove=now
	else
		if now-p.lastControl<.18 then return end;p.lastControl=now
		control(player,action,value)
	end
end)
local function chatCommand(player,text)
	if not allowed(player) then return end
	local action,value=Policy.ParseChat(text);if not action then return end
	if action=="SetSpeed" then
		if setSpeed(player,value) then start(player) end
	else control(player,action,value) end
end
local command=Instance.new("TextChatCommand");command.Name="HunDinoAdminFlyCommand"
command.PrimaryAlias="/fly";command.SecondaryAlias="/unfly";command.AutocompleteVisible=false
command.Triggered:Connect(function(source,text)
	local player=source and Players:GetPlayerByUserId(source.UserId)
	if player then chatCommand(player,text) end
end)
command.Parent=Chat
local function setup(player)
	player:SetAttribute("AdminFlyAllowed",allowed(player));player:SetAttribute("AdminFlying",false)
	player:SetAttribute("AdminFlySpeed",Policy.DefaultSpeed)
	local list={};connections[player]=list
	table.insert(list,player.CharacterRemoving:Connect(function() stop(player,false) end))
	table.insert(list,player:GetAttributeChangedSignal("AdminFlying"):Connect(function()
		-- Travel/death can cancel flight without snapping back to the old ground.
		if player:GetAttribute("AdminFlying")~=true and states[player] then stop(player,false) end
	end))
	table.insert(list,player:GetAttributeChangedSignal("Area"):Connect(function() stop(player,false) end))
	if Chat.ChatVersion==Enum.ChatVersion.LegacyChatService then
		table.insert(list,player.Chatted:Connect(function(text) chatCommand(player,text) end))
	end
end
local heartbeat=RunService.Heartbeat:Connect(function(dt)
	local now=os.clock()
	for player,s in states do
		if not allowed(player) or player.Character~=s.character or not s.root.Parent or s.humanoid.Health<=0 then
			stop(player,s.humanoid.Health>0);continue
		end
		local dir=if now-s.lastMove<.4 then s.direction else Vector3.zero
		local selected=player:GetAttribute("AdminFlySpeed")
		local speed=if Policy.ValidateSpeed(selected) then selected else Policy.DefaultSpeed
		local wanted=dir*speed*(if s.boost then Policy.BoostMultiplier else 1)
		local p=s.root.Position
		if p.Y>Policy.MaxAltitude or math.abs(p.X)>Policy.MaxHorizontal or math.abs(p.Z)>Policy.MaxHorizontal then
			local point=Vector3.new(math.clamp(p.X,-Policy.MaxHorizontal,Policy.MaxHorizontal),math.min(p.Y,Policy.MaxAltitude),math.clamp(p.Z,-Policy.MaxHorizontal,Policy.MaxHorizontal))
			s.character:PivotTo(s.character:GetPivot()+point-p);wanted=Vector3.zero
		end
		if p.Y< -30 then s.character:PivotTo(s.character:GetPivot()+Vector3.new(0,-30-p.Y,0));wanted=Vector3.zero end
		s.currentVelocity=s.currentVelocity:Lerp(wanted,1-math.exp(-12*math.min(dt,.1)))
		s.velocity.VectorVelocity=s.currentVelocity
		if Vector3.new(s.look.X,0,s.look.Z).Magnitude>.01 then s.orientation.CFrame=CFrame.lookAt(Vector3.zero,Vector3.new(s.look.X,0,s.look.Z)) end
		s.humanoid.PlatformStand=true;s.humanoid.AutoRotate=false
		for part in s.collisions do if part.Parent then part.CanCollide=false end end
	end
end)
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player)
	stop(player,false);packets[player]=nil
	for _,connection in connections[player] or {} do connection:Disconnect() end
	connections[player]=nil
end)
for _,player in Players:GetPlayers() do setup(player) end
script.Destroying:Connect(function()
	heartbeat:Disconnect()
	for player in states do stop(player,true) end
	for player,list in connections do
		for _,connection in list do connection:Disconnect() end
		player:SetAttribute("AdminFlyAllowed",false)
	end
	command:Destroy();remote:Destroy()
end)
