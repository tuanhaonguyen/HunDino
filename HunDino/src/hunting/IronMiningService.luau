-- Shared fixed deposits; only acknowledged physical strikes award inventory.
local Http=game:GetService("HttpService")
local RS=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local Config=require(script.Parent.IronMiningConfig)
local Pickaxe=require(script.Parent.MiningPickaxeVisual)
local Service={};Service.__index=Service
local function attr(p,k,v) if p.Parent and p:GetAttribute(k)~=v then p:SetAttribute(k,v) end end
local function flat(v) return Vector3.new(v.X,0,v.Z) end
function Service:_now() return if self.Now then self.Now() else workspace:GetServerTimeNow() end
function Service.new(options)
	local self=setmetatable({Nodes={},Actions={},Claims={},Connections={},Random=Random.new()},Service)
	for k,v in options do self[k]=v end
	self.World=assert(self.Forest:FindFirstChild(Config.FolderName),"Fixed mining sites missing")
	self.Remote=Instance.new("RemoteEvent");self.Remote.Name="HunDinoMiningAction";self.Remote.Parent=RS
	table.insert(self.Connections,self.Remote.OnServerEvent:Connect(function(p,action) if action=="Cancel" then self:CancelAction(p) end end))
	for _,row in Config.Nodes do
		local model=assert(self.World:FindFirstChild(row.Id));local node={Index=row.Index,Id=row.Id,Model=model,Root=model.PrimaryPart,Hits=0,Cycle=Http:GenerateGUID(false)}
		assert(node.Root,"Missing ore root");self.Nodes[row.Index]=node
		local prompt=Instance.new("ProximityPrompt");prompt.Name="MineIron";prompt.KeyboardKeyCode=Enum.KeyCode.G
		prompt.HoldDuration=0;prompt.MaxActivationDistance=8;prompt.RequiresLineOfSight=false;prompt.Parent=node.Root;node.Prompt=prompt
		local gui=Instance.new("BillboardGui");gui.Name="MiningLabel";gui.Size=UDim2.fromOffset(210,42);gui.StudsOffset=Vector3.new(0,8,0);gui.MaxDistance=45;gui.AlwaysOnTop=false;gui.Parent=node.Root
		local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextSize=13;text.TextColor3=Color3.fromRGB(221,228,211);text.TextStrokeTransparency=.35;text.Parent=gui;node.Label=text
		table.insert(self.Connections,prompt.Triggered:Connect(function(p) self:RequestMine(p,node.Index) end));self:_updateNode(node)
	end
	return self
end
function Service:_updateNode(node)
	local left=Config.MaxHits-node.Hits
	node.Model:SetAttribute("HitsRemaining",left);node.Model:SetAttribute("RespawnAt",node.RespawnAt or 0)
	node.Prompt.Enabled=not self.Stopped and left>0 and node.Owner==nil
	node.Prompt.ObjectText="Quặng sắt · "..left.."/3";node.Prompt.ActionText="Lấy cuốc đào"
	node.Label.Text=if node.RespawnAt then "QUẶNG ĐÃ CẠN · "..math.max(0,math.ceil(node.RespawnAt-self:_now())).."s"
		elseif node.Owner then "ĐANG ĐÀO / GHI NGUYÊN LIỆU" else "QUẶNG SẮT · "..left.."/3"
	for _,crystal in node.Model.Crystals:GetChildren() do
		local hidden=(crystal:GetAttribute("StrikeGroup") or 0)<=node.Hits
		for _,p in crystal:GetDescendants() do if p:IsA("BasePart") then p.Transparency=if hidden then 1 else 0 end end
	end
end
function Service:_actor(player,node)
	local s=self.GetState(player);local economy=self.GetEconomy()
	if self.Stopped or not player.Parent or not s or not s.Character or not s.Character.Parent or not s.Root or not s.Root.Parent
		or not s.Humanoid or s.Humanoid.Health<=0 or not s.InHunting or not self.Session.Players[player]
		or s.Travelling or s.Drawn or s.ChangeDraw~=nil or s.Charge or s.Blocking or s.Sprinting
		or os.clock()<(s.BusyUntil or 0) or os.clock()<(s.DodgingUntil or 0) or player:GetAttribute("AdminFlying")==true
		or player:GetAttribute("HuntCaptureActive")==true or (player:GetAttribute("HuntAction") or "")~=""
		or (player:GetAttribute("HuntHarvestAction") or "")~="" or not economy or not economy:IsReady(player) then return nil end
	if not node.Root.Parent or (s.Root.Position-node.Root.Position).Magnitude>Config.Reach then return nil end
	local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={workspace.Terrain,self.Forest.Paths,self.Forest.Zones}
	params.RespectCanCollide=true;params.IgnoreWater=false
	local hit=workspace:Raycast(s.Root.Position+Vector3.yAxis,-Vector3.yAxis*8,params)
	local hs=s.Humanoid:GetState()
	if not hit or hit.Material==Enum.Material.Water or hit.Normal.Y<.6 or math.abs(s.Root.AssemblyLinearVelocity.Y)>7
		or s.Root.Position.Y-hit.Position.Y>6 or hs==Enum.HumanoidStateType.Freefall or hs==Enum.HumanoidStateType.Jumping then return nil end
	params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={s.Character,self.World,self.PetFolder}
	local origin=s.Root.Position+Vector3.yAxis;local goal=node.Root.Position+Vector3.yAxis*2
	if workspace:Raycast(origin,goal-origin,params) then return nil end
	return s
end
function Service:_equip(action)
	local char=action.Character;local hand=char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
	if not hand then return false end
	local tool=Pickaxe.build();tool.Name="MiningPickaxe";tool:PivotTo(hand.CFrame*CFrame.new(0,-.55,-.2)*CFrame.Angles(0,0,math.rad(-12)));tool.Parent=char
	local grip=Instance.new("Motor6D");grip.Name="MiningGrip";grip.Part0=hand;grip.Part1=tool.PrimaryPart;grip.C0=hand.CFrame:ToObjectSpace(tool.PrimaryPart.CFrame);grip.Parent=tool.PrimaryPart
	action.Tool=tool;action.Grip=grip;action.GripRest=grip.C0
	action.Shoulder=char:FindFirstChild("RightShoulder",true) or char:FindFirstChild("Right Shoulder",true)
	if action.Shoulder and action.Shoulder:IsA("Motor6D") then action.ShoulderRest=action.Shoulder.C0 end
	return true
end
function Service:_unequip(player,action)
	if action.Connection then action.Connection:Disconnect() end
	if action.ShoulderRest and action.Shoulder.Parent then action.Shoulder.C0=action.ShoulderRest end
	if action.Tool then action.Tool:Destroy() end
	if action.Humanoid.Parent then action.Humanoid.AutoRotate=action.AutoRotate end
	attr(player,"MiningActive",false);attr(player,"MiningEnds",0);attr(player,"MiningNodeId",nil)
	self.Actions[player]=nil
end
function Service:RequestMine(player,index)
	local node=self.Nodes[index]
	if not node or self.Actions[player] or self.Claims[player] or node.Owner or node.Hits>=Config.MaxHits then return false end
	local s=self:_actor(player,node);if not s then return false end
	local action={Node=node,Character=s.Character,Humanoid=s.Humanoid,Root=s.Root,Origin=s.Root.Position,
		Visit=self.Session.Players[player],Start=self:_now(),Finish=self:_now()+Config.StrikeSeconds,Health=s.Humanoid.Health,AutoRotate=s.Humanoid.AutoRotate}
	if not self:_equip(action) then return false end
	action.Connection=s.Humanoid.HealthChanged:Connect(function(h) if h<action.Health then action.Damaged=true end;action.Health=h end)
	local direction=flat(node.Root.Position-s.Root.Position);if direction.Magnitude>.01 then s.Root.CFrame=CFrame.lookAt(s.Root.Position,s.Root.Position+direction) end
	s.Humanoid.AutoRotate=false;node.Owner=player;self.Actions[player]=action
	attr(player,"MiningDuration",Config.StrikeSeconds);attr(player,"MiningEnds",action.Finish);attr(player,"MiningNodeId",node.Id);attr(player,"MiningActive",true)
	self:_updateNode(node);return true
end
function Service:CancelAction(player)
	local action=self.Actions[player];if not action then return end
	self:_unequip(player,action);action.Node.Owner=nil;self:_updateNode(action.Node)
end
function Service:IsBusy(player) return self.Actions[player]~=nil or self.Claims[player]~=nil end
function Service:_spent(node)
	node.Hits+=1;node.Owner=nil
	if node.Hits>=Config.MaxHits then node.RespawnAt=self:_now()+Config.RespawnSeconds end
	if not self.Stopped and node.Model.Parent then self:_updateNode(node) end
end
function Service:_drop(player,node,quantity)
	for i=1,quantity do
		local p=Instance.new("Part");p.Name="MinedIronChunk";p.Size=Vector3.new(.65,.5,.7);p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(174,191,187)
		p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Position=node.Root.Position+Vector3.new(i*.6-.9,2,0);p.Parent=workspace
		local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart")
		Tween:Create(p,TweenInfo.new(.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=p.Position+Vector3.new(i*.45,2.4,0)}):Play()
		task.delay(.45,function()if p.Parent then Tween:Create(p,TweenInfo.new(.45),{Position=if root and root.Parent then root.Position else p.Position+Vector3.yAxis,Transparency=1,Size=Vector3.one*.1}):Play() end end)
		task.delay(1.05,function()p:Destroy()end)
	end
end
function Service:_attempt(player,claim)
	if claim.Busy then return end;claim.Busy=true;claim.NextTry=self:_now()+2
	task.spawn(function()
		local called,receipt=pcall(function()return self.GetEconomy():MineIron(player,claim.Request)end);claim.Busy=false
		if called and receipt and receipt.Ok and receipt.Code=="IronMined" then
			self.Claims[player]=nil;self:_spent(claim.Node);if not claim.Departed and not self.Stopped then self:_drop(player,claim.Node,receipt.Quantity) end
		elseif claim.Departed or not player.Parent then
			-- An ambiguous durable write must never release this strike for a reroll.
			self.Claims[player]=nil;self:_spent(claim.Node)
		elseif called and receipt and receipt.Code~="SavePending" then
			self.Claims[player]=nil;claim.Node.Owner=nil;self:_updateNode(claim.Node)
			self.Message(player,"Chưa nhận được sắt ("..tostring(receipt.Code).."). Có thể đào lại khi hồ sơ sẵn sàng.")
		end
	end)
end
function Service:Step()
	local time=self:_now()
	for player,action in self.Actions do
		local s=self:_actor(player,action.Node)
		if not s or s.Character~=action.Character or self.Session.Players[player]~=action.Visit or action.Damaged
			or (action.Root.Position-action.Origin).Magnitude>1.6 then self:CancelAction(player)
		elseif time>=action.Finish then
			local profile=self.GetEconomy():Profile(player)
			local request={Op="MineIron",OperationSerial=profile.OperationSerial+1,SourceId=action.Node.Cycle..":"..action.Node.Id..":"..(action.Node.Hits+1),
				NodeId=action.Node.Index,HitIndex=action.Node.Hits+1,QuantityRoll=self.Random:NextNumber()}
			self:_unequip(player,action);local claim={Node=action.Node,Request=request};self.Claims[player]=claim;self:_attempt(player,claim)
		else
			local p=math.clamp((time-action.Start)/Config.StrikeSeconds,0,1)
			local angle=if p<.32 then -1.8*p/.32 elseif p<.65 then -1.8 else -1.8+2.2*math.min(1,(p-.65)/.23)
			if action.ShoulderRest then action.Shoulder.C0=action.ShoulderRest*CFrame.Angles(angle,0,-.15) end
			action.Grip.C0=action.GripRest*CFrame.Angles(angle*.22,0,0)
		end
	end
	for player,claim in self.Claims do
		if not claim.Busy then
			if claim.Departed or not player.Parent then self.Claims[player]=nil;self:_spent(claim.Node)
			elseif time>=(claim.NextTry or 0) and self.GetEconomy():IsReady(player) then self:_attempt(player,claim) end
		end
	end
	for _,node in self.Nodes do if node.RespawnAt then
		if time>=node.RespawnAt then node.Hits=0;node.Cycle=Http:GenerateGUID(false);node.RespawnAt=nil end
		self:_updateNode(node)
	end end
end
function Service:RemovePlayer(player)
	self:CancelAction(player);local claim=self.Claims[player]
	if claim then claim.Departed=true;if not claim.Busy then self.Claims[player]=nil;self:_spent(claim.Node) end end
end
function Service:Destroy()
	self.Stopped=true;for p in self.Actions do self:CancelAction(p) end
	for _,c in self.Connections do c:Disconnect() end
	for _,node in self.Nodes do node.Prompt:Destroy();node.Label.Parent:Destroy() end
	self.Remote:Destroy()
end
return Service
