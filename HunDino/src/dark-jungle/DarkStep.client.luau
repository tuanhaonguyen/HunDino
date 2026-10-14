-- Client visuals for server-approved dodges. No hitboxes or character invisibility.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local entries={}
local effects=Instance.new("Folder");effects.Name="DarkStepFX";effects.Parent=workspace
local purple=Color3.fromRGB(48,34,69)

local function smoke(cf,count)
	local anchor=Instance.new("Part");anchor.Name="StepSmoke";anchor.Size=Vector3.one;anchor.CFrame=cf
	anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false;anchor.Parent=effects
	local emitter=Instance.new("ParticleEmitter");emitter.Name="ShadowSmoke";emitter.Texture="rbxasset://textures/particles/smoke_main.dds"
	emitter.Color=ColorSequence.new(Color3.fromRGB(21,19,28),purple);emitter.LightInfluence=0;emitter.LightEmission=.08
	emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,1.3),NumberSequenceKeypoint.new(.5,2.8),NumberSequenceKeypoint.new(1,3.7)})
	emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.42),NumberSequenceKeypoint.new(.4,.7),NumberSequenceKeypoint.new(1,1)})
	emitter.Lifetime=NumberRange.new(.22,.42);emitter.Speed=NumberRange.new(2,7);emitter.Drag=5;emitter.Rate=0
	emitter.SpreadAngle=Vector2.new(160,160);emitter.Rotation=NumberRange.new(-180,180);emitter.RotSpeed=NumberRange.new(-70,70)
	emitter.Parent=anchor;emitter:Emit(count);Debris:AddItem(anchor,.65)
end
local function snapshot(character)
	local ghost=Instance.new("Model");ghost.Name="Afterimage"
	local count=0
	for _,source in character:GetDescendants() do
		if source:IsA("BasePart") and source.Name~="HumanoidRootPart" and source.Transparency<.8 then
			local copy=source:Clone()
			if copy then
				for _,child in copy:GetChildren() do if not child:IsA("DataModelMesh") then child:Destroy() end end
				copy.Name="Shadow";copy.Anchored=true;copy.CanCollide=false;copy.CanTouch=false;copy.CanQuery=false;copy.CastShadow=false
				copy.Color=purple;copy.Material=Enum.Material.SmoothPlastic;copy.Reflectance=0;copy.Transparency=.64
				if copy:IsA("MeshPart") then copy.TextureID="" elseif copy:IsA("UnionOperation") then copy.UsePartColor=true end
				for _,mesh in copy:GetChildren() do if mesh:IsA("SpecialMesh") then mesh.TextureId="";mesh.VertexColor=Vector3.one end end
				copy.Parent=ghost;TweenService:Create(copy,TweenInfo.new(.38,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=1}):Play()
				count+=1;if count>=64 then break end
			end
		end
	end
	ghost.Parent=effects;Debris:AddItem(ghost,.42)
end
local function restore(entry)
	for _,pose in entry.poses or {} do if pose.motor.Parent then pose.motor.Transform=pose.original end end
	for _,object in entry.ribbon or {} do if object.Parent then object:Destroy() end end
	entry.poses=nil;entry.ribbon=nil;entry.active=false
end
local function ribbon(root,duration)
	local a=Instance.new("Attachment");a.Name="DarkStepLeft";a.Position=Vector3.new(-.75,-.6,.2);a.Parent=root
	local b=Instance.new("Attachment");b.Name="DarkStepRight";b.Position=Vector3.new(.75,-.6,.2);b.Parent=root
	local trail=Instance.new("Trail");trail.Name="DarkStepTrail";trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.16
	trail.FaceCamera=true;trail.MinLength=.15;trail.LightEmission=.08;trail.Color=ColorSequence.new(purple,Color3.fromRGB(108,81,140))
	trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.72),NumberSequenceKeypoint.new(1,1)});trail.Parent=root
	for _,object in {a,b,trail} do Debris:AddItem(object,duration+.4) end
	return {trail,a,b}
end
local function begin(entry,char,root,duration)
	restore(entry);entry.active=true;entry.poses={};entry.nextGhost=0;entry.lastGhost=nil;entry.endSmoke=false
	local motors={}
	for _,m in char:GetDescendants() do if m:IsA("Motor6D") or m:IsA("AnimationConstraint") then motors[m.Name]=m end end
	local lean=motors.Waist or motors.RootJoint or motors.Root
	if lean then table.insert(entry.poses,{motor=lean,original=lean.Transform,kind="Lean"}) end
	for _,pair in {{"RightShoulder","Right Shoulder",1},{"LeftShoulder","Left Shoulder",-1}} do
		local m=motors[pair[1]] or motors[pair[2]]
		if m then table.insert(entry.poses,{motor=m,original=m.Transform,kind="Arm",side=pair[3]}) end
	end
	entry.fx=player:GetAttribute("ShowComboFX")~=false
	if entry.fx then
		entry.ribbon=ribbon(root,duration)
		smoke(root.CFrame*CFrame.new(0,-2,0),12)
	end
end
-- Remove our last overlay before Animator evaluates its next frame.
local beforeAnimation=RunService.PreAnimation:Connect(function()
	for _,entry in entries do for _,pose in entry.poses or {} do if pose.motor.Parent then pose.motor.Transform=pose.original end end end
end)
local connection=RunService.PreSimulation:Connect(function()
	local now=workspace:GetServerTimeNow();local seen={}
	for _,p in Players:GetPlayers() do
		local char=p.Character;local root=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health<=0 or (workspace.CurrentCamera.CFrame.Position-root.Position).Magnitude>180 then continue end
		seen[char]=true
		local seq=char:GetAttribute("DarkStepSequence")
		if not seq then continue end
		local entry=entries[char];if not entry then entry={};entries[char]=entry end
		local started=char:GetAttribute("DarkStepStarted") or 0
		local duration=char:GetAttribute("DarkStepDuration") or .4
		local elapsed=now-started
		if entry.seq~=seq then
			entry.seq=seq
			if elapsed>=-.1 and elapsed<duration then begin(entry,char,root,duration) else restore(entry) end
		end
		if not entry.active then continue end
		if elapsed>duration+.14 or elapsed<-.1 then restore(entry);continue end
		local blend=math.clamp(elapsed/.045,0,1)*math.clamp((duration+.14-elapsed)/.16,0,1)
		local direction=char:GetAttribute("DarkStepDirection") or root.CFrame.LookVector
		for _,pose in entry.poses do
			local m=pose.motor;if not m.Parent then continue end
			local parent,jointCF
			if m:IsA("AnimationConstraint") then
				local a=m.Attachment0;if not a or not a.Parent:IsA("BasePart") then continue end
				parent=a.Parent;jointCF=a.CFrame
			else parent=m.Part0;jointCF=m.C0 end
			if not parent then continue end
			pose.original=m.Transform
			local jointWorld=parent.CFrame*jointCF*pose.original
			local rotation
			if pose.kind=="Lean" then
				local localDirection=jointWorld:VectorToObjectSpace(direction)
				local up=jointWorld:VectorToObjectSpace(Vector3.yAxis)
				local axis=up:Cross(localDirection)
				rotation=if axis.Magnitude>.01 then CFrame.fromAxisAngle(axis.Unit,math.rad(27)) else CFrame.new()
			else
				local axis=jointWorld:VectorToObjectSpace(root.CFrame.RightVector)
				rotation=CFrame.fromAxisAngle(axis,-.55)
			end
			m.Transform=pose.original* CFrame.new():Lerp(rotation,blend)
		end
		if entry.fx then
			if elapsed<duration and elapsed>=entry.nextGhost then
				if not entry.lastGhost or (root.Position-entry.lastGhost).Magnitude>.65 then snapshot(char);entry.lastGhost=root.Position end
				entry.nextGhost=elapsed+.055
			elseif elapsed>=duration and not entry.endSmoke then
				entry.endSmoke=true;snapshot(char);smoke(root.CFrame*CFrame.new(0,-2,0),6)
				if entry.ribbon and entry.ribbon[1].Parent then entry.ribbon[1].Enabled=false end
			end
		end
	end
	for char,entry in entries do if not seen[char] then restore(entry);entries[char]=nil end end
end)
script.Destroying:Connect(function()
	connection:Disconnect();beforeAnimation:Disconnect();for _,entry in entries do restore(entry) end;effects:Destroy()
end)
