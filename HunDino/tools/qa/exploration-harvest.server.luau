-- Native integration with cloned production services, disposable players and real
-- Humanoids/raycast geometry. Never touches an account, Terrain or live dinosaur.
local runtime=game.ServerScriptService.HuntingRuntime
local container=Instance.new("Folder");container.Name="ExplorationLootQA_"..game.HttpService:GenerateGUID(false);container.Parent=workspace
local modules=runtime:Clone();modules.Name="Runtime";modules.Parent=container
local report={version="ExplorationHarvestIntegration.1",checks=0,failures={},boundary="Disposable actors and combat adapter; real exploration/economy/harvest code and native geometry. No real account or dinosaur mutation."}
local fixtures={}
local function check(v,message) report.checks+=1;if not v then table.insert(report.failures,message) end end
local function part(parent,name,pos,size,collision)
	local p=Instance.new("Part");p.Name=name;p.Position=pos;p.Size=size;p.Anchored=true;p.CanCollide=collision;p.CanQuery=collision;p.Transparency=1;p.Parent=parent;return p
end
local Explore,Economy,Rules
local function fixture()
	local f={States={},Mission=false,Messages={}};table.insert(fixtures,f)
	f.Root=Instance.new("Folder");f.Root.Parent=container
	f.Origin=Vector3.new(60000+#fixtures*1500,500,60000)
	f.Forest=Instance.new("Model");f.Forest.Parent=f.Root;f.Forest:SetAttribute("WorldOffset",f.Origin)
	local paths=Instance.new("Folder");paths.Name="Paths";paths.Parent=f.Forest
	part(paths,"Floor",f.Origin-Vector3.yAxis,Vector3.new(200,2,200),true)
	f.Combat={Health=1200,MaxHealth=1200,Model=Instance.new("Model")};f.Combat.Model.Parent=f.Root
	local boxes=Instance.new("Folder");boxes.Name="CombatHitboxes";boxes.Parent=f.Combat.Model
	part(boxes,"BodyHurtbox",f.Origin+Vector3.yAxis*4,Vector3.new(10,8,10),false)
	function f.Combat:GetSnapshot() return {Health=self.Health,MaxHealth=self.MaxHealth} end
	function f.Combat:GetSupportPoint() return f.Origin end
	f.Session={Patrol={},Players={}}
	f.Economy=setmetatable({Profiles={},Random=Random.new(9),Publish=function() end,_notice=function() end},{__index=Economy})
	f.Service=Explore.new({Session=f.Session,Combat=f.Combat,Forest=f.Forest,
		GetEconomy=function() return f.Economy end,GetState=function(p) return f.States[p] end,
		IsMission=function() return f.Mission end,Message=function(_,text) table.insert(f.Messages,text) end})
	function f:AddPlayer(id)
		local p={Parent=f.Root,UserId=id,Attributes={}}
		function p:GetAttribute(k) return self.Attributes[k] end
		function p:SetAttribute(k,v) self.Attributes[k]=v end
		local char=Instance.new("Model");char.Parent=f.Root
		local root=part(char,"HumanoidRootPart",f.Origin+Vector3.new(6,3,0),Vector3.new(2,2,1),false)
		local hum=Instance.new("Humanoid");hum.RequiresNeck=false;hum.HipHeight=2;hum.Parent=char
		hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,false);hum:ChangeState(Enum.HumanoidStateType.Running)
		p.Character=char;f.States[p]={Character=char,Root=root,Humanoid=hum,InHunting=true,BusyUntil=0}
		f.Session.Players[p]={};f.Economy.Profiles[id]=Rules.new()
		return p
	end
	function f:Kill(p) f.Service:ObserveDamage(p,1200,0);f.Combat.Health=0;self.Service:Step(.1);task.wait();self.Service:Step(.1) end
	return f
end
local ok,err=xpcall(function()
	Explore=require(modules.ExplorationHarvestService);Economy=require(modules.HuntEconomyService);Rules=require(modules.HuntEconomyRules)
	do
		local f=fixture();local p=f:AddPlayer(-10001);f:Kill(p)
		local e=f.Service.Entries[p]
		check(e and e.Harvest~=nil,"Exploration defeat creates a real harvest controller")
		check(p:GetAttribute("HuntExplorationHarvest")==true and p:GetAttribute("HuntLootRunId")==e.Run.Id,"Separate exploration UI context is published")
		check(p:GetAttribute("QuestState")==nil,"Exploration does not fabricate a quest state")
		check(#e.Harvest._nodes==0 and p:GetAttribute("HuntOreRemaining")==0,"Corpse-only mode creates no ore or ghost count")
		for i=1,3 do
			f.Service:HarvestAction(p,"CarveStart")
			check(e.Harvest._action~=nil,"Carve begins "..i)
			e.Harvest._action.FinishAt=workspace:GetServerTimeNow()-.01
			f.Service:Step(.1)
			check(p:GetAttribute("HuntCarves")==i,"Native carve commits "..i)
		end
		local profile=f.Economy:Profile(p);local total=profile.Materials.Skin+profile.Materials.Tooth+profile.Materials.Scale
		check(total==3 and profile.Coins==80 and profile.Materials.Bone==0,"Exactly three materials, no quest bonus")
		f.Service:HarvestAction(p,"CarveStart");check(e.Harvest._action==nil,"Fourth carve cannot begin")
		check(f.Service:BeforeTravel(p,"Lobby") and not profile.ActiveRun,"Leaving closes the durable exploration ledger")
		f.Session.Players[p]=nil;f.Session.Players[p]={};f.Service:Step(.1);task.wait()
		check(f.Service.Entries[p]==nil,"Rejoining the same corpse cannot obtain another allocation")
		local late=f:AddPlayer(-10002);f.Service:ObserveDamage(late,0,0);f.Service:Step(.1)
		check(f.Service.Entries[late]==nil,"Late nonparticipant cannot harvest")
	end
	do
		local f=fixture();local a=f:AddPlayer(-10003);local b=f:AddPlayer(-10004)
		f.Service:ObserveDamage(a,1200,1100);f.Service:ObserveDamage(b,1100,0);f.Combat.Health=0
		f.Service:Step(.1);task.wait();f.Service:Step(.1)
		check(f.Service.Entries[a] and f.Service.Entries[b],"Two contributors receive independent allocations")
		check(f.Service.Entries[a].Run.Id~=f.Service.Entries[b].Run.Id,"Contributor ledgers have distinct run IDs")
		local e=f.Service.Entries[a];f.Service:HarvestAction(a,"CarveStart")
		f.States[a].Root.Position+=Vector3.new(3,0,0);f.Service:Step(.1)
		check(e.Harvest._action==nil and e.Run.HarvestProgress.Carves==0,"Movement cancels with no claim consumed")
		f.Session.Patrol={};f.Combat.Health=1200;f.Service:Step(.1)
		check(not f.Service.Entries[a] and not f.Service.Entries[b],"Reset invalidates both old corpse contexts")
	end
	do
		local f=fixture();local p=f:AddPlayer(-10005);f.Mission=true;f:Kill(p)
		check(f.Service.Entries[p]==nil and f.Economy:Profile(p).RunSerial==0,"Mission mode never starts exploration ledger")
	end
	do
		local f=fixture();local p=f:AddPlayer(-10006);local prepare=f.Economy.PrepareExploration
		f.Economy.PrepareExploration=function(self,owner,run) task.wait(.1);return prepare(self,owner,run) end
		f.Service:ObserveDamage(p,1200,0);f.Combat.Health=0;f.Service:Step(.1)
		f.Session.Players[p]=nil;task.wait(.2);f.Service:Step(.1)
		check(p:GetAttribute("HuntExplorationHarvest")~=true,"Leaving during a yielding save never exposes harvest")
		check(not f.Economy:Profile(p).ActiveRun and not f.Service.Entries[p],"Yielded preparation closes after visit ends")
	end
	do
		local f=fixture();local p=f:AddPlayer(-10007);f:Kill(p)
		local e=f.Service.Entries[p];e.Busy=true
		f.Service:RemovePlayer(p)
		check(f.Service.Entries[p]==e and e.Departed,"Disconnect waits for the in-flight claim before disposal")
		f.Economy.IsReady=function() return false end;e.Busy=false;f.Service:Step(.1)
		check(not f.Service.Entries[p] and e.Harvest==nil,"Released profile cannot leave an endless cleanup retry")
		check(f.Economy:Profile(p).ActiveRun~=nil,"Unacknowledged ledger remains for durable recovery")
	end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
for _,f in fixtures do pcall(function() f.Service:Destroy() end) end
container:Destroy();report.ok=#report.failures==0
return report
