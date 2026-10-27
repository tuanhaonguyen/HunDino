-- Real installed mining/ore rules on disposable actors and ground. No account,
-- live deposit, Terrain or production dinosaur mutation.
local runtime=game.ServerScriptService.HuntingRuntime
local folder=Instance.new("Folder");folder.Name="IronMiningQA_"..game.HttpService:GenerateGUID(false);folder.Parent=workspace
local modules=Instance.new("Folder");modules.Parent=folder
for _,name in {"IronMiningConfig","IronMiningService","MiningPickaxeVisual","HuntEconomyRules"}do runtime[name]:Clone().Parent=modules end
local report={Version="IronMiningRuntimeQA.1",Checks=0,Failures={},Boundary="Installed production modules, fake players/economy with real rule commits, real Humanoids/Parts/rays. No real profile or deposit is used."}
local function check(v,msg) report.Checks+=1;if not v then table.insert(report.Failures,msg)end end
local fixtures={}
local function part(parent,name,pos,size,solid)
	local p=Instance.new("Part");p.Name=name;p.Position=pos;p.Size=size;p.Anchored=true;p.CanCollide=solid;p.CanQuery=solid;p.Parent=parent;return p
end
local ok,err=xpcall(function()
	local Mining=require(modules.IronMiningService);local Rules=require(modules.HuntEconomyRules)
	local function fixture()
		local f={Time=10,Profiles={},States={},Roll=.5,Calls=0};table.insert(fixtures,f)
		f.Root=Instance.new("Folder");f.Root.Parent=folder;f.Origin=Vector3.new(45000+#fixtures*2500,500,45000)
		f.Forest=Instance.new("Model");f.Forest.Parent=f.Root
		local paths=Instance.new("Folder");paths.Name="Paths";paths.Parent=f.Forest
		local zones=Instance.new("Folder");zones.Name="Zones";zones.Parent=f.Forest
		part(paths,"Floor",f.Origin-Vector3.yAxis,Vector3.new(2000,2,150),true)
		local ores=Instance.new("Folder");ores.Name="MineableIron";ores.Parent=f.Forest
		for i=1,30 do
			local m=Instance.new("Model");m.Name=string.format("IRON_%02d",i);m.Parent=ores
			local p=part(m,"Root",f.Origin+Vector3.new(i*20,0,0),Vector3.one,false);m.PrimaryPart=p
			local crystals=Instance.new("Folder");crystals.Name="Crystals";crystals.Parent=m
			for g=1,3 do local c=Instance.new("Model");c:SetAttribute("StrikeGroup",g);c.Parent=crystals;part(c,"Visual",p.Position+Vector3.yAxis*3,Vector3.one,false)end
		end
		f.Session={Players={}}
		f.Economy={IsReady=function()return not f.Unready end,Profile=function(_,p)return f.Profiles[p]end}
		function f.Economy:MineIron(p,request)
			f.Calls+=1;f.LastRequest=request
			local receipt=Rules.apply(f.Profiles[p],request)
			if f.Pending then f.Pending=false;return{Ok=false,Code="SavePending"}end
			return receipt
		end
		f.Service=Mining.new({Forest=f.Forest,Session=f.Session,GetState=function(p)return f.States[p]end,
			GetEconomy=function()return f.Economy end,Message=function()end,Now=function()return f.Time end})
		f.Service.Random={NextNumber=function()return f.Roll end};f.Service._drop=function()end
		function f:Add(id)
			local p={UserId=id,Parent=f.Root,Attributes={}};function p:GetAttribute(k)return self.Attributes[k]end;function p:SetAttribute(k,v)self.Attributes[k]=v end
			local char=Instance.new("Model");char.Parent=f.Root;p.Character=char
			local root=part(char,"HumanoidRootPart",self.Service.Nodes[1].Root.Position+Vector3.new(5,3,0),Vector3.new(2,2,1),false)
			part(char,"RightHand",root.Position+Vector3.new(1.5,0,0),Vector3.one,false)
			local h=Instance.new("Humanoid");h.RequiresNeck=false;h.HipHeight=2;h.Parent=char;h:SetStateEnabled(Enum.HumanoidStateType.Freefall,false);h:ChangeState(Enum.HumanoidStateType.Running)
			self.States[p]={Character=char,Root=root,Humanoid=h,InHunting=true,BusyUntil=0};self.Profiles[p]=Rules.new();self.Session.Players[p]={};return p
		end
		function f:Finish()self.Time+=2.3;self.Service:Step();task.wait()end
		return f
	end
	do
		local f=fixture();local p=f:Add(-12001);local other=f:Add(-12002)
		check(f.Service:RequestMine(p,1),"G request starts real pickaxe")
		check(p:GetAttribute("MiningActive")and p.Character:FindFirstChild("MiningPickaxe"),"Server creates equipped pickaxe and action attrs")
		check(not f.Service:RequestMine(other,1),"Shared node rejects a second miner")
		check(not f.Service:RequestMine(p,2),"One miner cannot own two simultaneous actions")
		f:Finish();check(f.Profiles[p].Materials.Iron==1 and f.Service.Nodes[1].Hits==1,"First full physical strike grants one iron")
		check(not p:GetAttribute("MiningActive")and not p.Character:FindFirstChild("MiningPickaxe"),"Completion removes pickaxe")
		f.Roll=.1;check(f.Service:RequestMine(other,1),"Second player can take next shared strike");f:Finish()
		check(f.Profiles[other].Materials.Iron==2 and f.Service.Nodes[1].Hits==2,"Twenty percent bonus uses exact same Iron resource")
		check(f.Service:RequestMine(p,1),"Third strike starts");f:Finish()
		check(f.Service.Nodes[1].Hits==3 and not f.Service.Nodes[1].Prompt.Enabled,"Third strike depletes global node")
		check(not f.Service:RequestMine(other,1),"Fourth strike denied")
		local oldCycle=f.Service.Nodes[1].Cycle;f.Time+=299;f.Service:Step();check(f.Service.Nodes[1].Hits==3,"Node stays exhausted before five minutes")
		f.Time+=1.1;f.Service:Step();check(f.Service.Nodes[1].Hits==0 and f.Service.Nodes[1].Cycle~=oldCycle,"Respawn restores same site with new source cycle")
	end
	do
		local f=fixture();local p=f:Add(-12003);local s=f.States[p]
		check(f.Service:RequestMine(p,1),"Cancel fixture starts");s.Root.Position+=Vector3.new(3,0,0);f:Finish()
		check(f.Service.Nodes[1].Hits==0 and f.Profiles[p].Materials.Iron==0,"Movement cancels without consuming strike")
		s.Root.Position-=Vector3.new(3,0,0);check(f.Service:RequestMine(p,1),"Damage fixture starts");s.Humanoid.Health-=1;f:Finish()
		check(f.Service.Nodes[1].Hits==0 and f.Profiles[p].Materials.Iron==0,"Damage cancels without reward")
		p:SetAttribute("AdminFlying",true);check(not f.Service:RequestMine(p,1),"Flight cannot mine");p:SetAttribute("AdminFlying",false)
		s.Drawn=true;check(not f.Service:RequestMine(p,1),"Drawn weapon cannot mine");s.Drawn=false
		s.InHunting=false;check(not f.Service:RequestMine(p,1),"Lobby cannot mine");s.InHunting=true
		s.Root.Position+=Vector3.new(40,0,0);check(not f.Service:RequestMine(p,1),"Remote distance cannot mine")
	end
	do
		local f=fixture();local p=f:Add(-12004);f.Pending=true;check(f.Service:RequestMine(p,1),"Pending-save fixture starts");f:Finish()
		local request=f.LastRequest
		check(f.Service.Claims[p] and f.Service.Nodes[1].Owner==p and f.Service.Nodes[1].Hits==0,"Unknown save outcome reserves node")
		f.Time+=2.1;f.Service:Step();task.wait()
		check(f.LastRequest==request and f.Profiles[p].Materials.Iron==1 and f.Service.Nodes[1].Hits==1,"Retry replays same claim without another roll/grant")
	end
	do
		local f=fixture();local p=f:Add(-12005);f.Pending=true;f.Service:RequestMine(p,1);f:Finish();f.Service:RemovePlayer(p);f.Time+=3;f.Service:Step()
		check(not f.Service.Claims[p]and f.Service.Nodes[1].Hits==1,"Departed pending owner retires without endless reservation or reroll")
		check(f.Profiles[p].Materials.Iron==1,"Already committed iron survives departure")
	end
end,debug.traceback)
if not ok then table.insert(report.Failures,tostring(err))end
for _,f in fixtures do pcall(function()f.Service:Destroy()end)end;folder:Destroy()
report.Ok=#report.Failures==0;return report
