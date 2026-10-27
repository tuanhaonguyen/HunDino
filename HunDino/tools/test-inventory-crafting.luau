local fs=require('@lune/fs')
local luau=require('@lune/luau')
local r=require('@lune/roblox')
local E=luau.load(fs.readFile('assets/merchant-weapons/ServerScriptService.HuntingRuntime.HuntEconomyRules.luau'))()
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
local guid=0
local http={GenerateGUID=function()guid+=1;return 'test-token-'..guid end}
local Service=luau.load(fs.readFile('assets/inventory-crafting/ServerScriptService.HuntingRuntime.HuntEconomyService.luau'),{
 environment={game={GetService=function(_,name)return if name=='HttpService' then http else {} end},
 script={Parent={HuntEconomyRules=E,SpecimenPreviewModel={},BioTubeService={},AdminRedeemPolicy={}}},
 require=function(v)return v end,workspace={}},injectGlobals=true})()
local function fixture(raw,iron)
 local p={UserId=17,Parent=true,Attributes={BaseId=1}}
 function p:GetAttribute(name)return self.Attributes[name]end
 function p:SetAttribute(name,v)self.Attributes[name]=v end
 local profile=E.new();profile.StoredConsumables.RawTrap=raw;profile.Materials.Iron=iron
 local state={Character={Parent=true},Root={Parent=true,Position=r.Vector3.zero},Humanoid={Health=100},BusyUntil=0}
 local events={}
 local service=setmetatable({Profiles={[17]=profile},Offers={},LastRequest={},Stations={[1]={Position=r.Vector3.zero}},
  GetState=function()return state end,GetQuest=function()return nil end,
  Remote={FireClient=function(_,_,event,data)table.insert(events,{Event=event,Data=data})end}},Service)
 service:Publish(p)
 return service,p,profile,state,events
end
local function payload(s,p)
 local profile=s:Profile(p)
 return {OperationToken=s.Offers[p].Token,SnapshotVersion=profile.Revision,OperationSerial=profile.OperationSerial+1}
end
local function request(s,p,v)
 s.LastRequest[p]=-math.huge;s:Request(p,'InventoryCraftIronTrap',v)
end
local s,p,profile,state=fixture(2,2)
check(s.Offers[p].Context=='Inventory','Inventory receives its own transaction offer')
local first=payload(s,p);request(s,p,first)
check(profile.StoredConsumables.RawTrap==1 and profile.Materials.Iron==1 and profile.StoredConsumables.IronTrap==1,'Recipe consumes exactly one raw trap and iron, gives one iron trap')
check(profile.Coins==80 and profile.Revision==1,'No coin debit, one committed revision')
request(s,p,first)
check(profile.Revision==1 and profile.StoredConsumables.IronTrap==1,'Repeated token cannot duplicate craft')
request(s,p,payload(s,p))
check(profile.StoredConsumables.RawTrap==0 and profile.Materials.Iron==0 and profile.StoredConsumables.IronTrap==2,'Second distinct craft consumes another exact pair')
request(s,p,payload(s,p))
check(profile.Revision==2 and profile.StoredConsumables.IronTrap==2,'No materials means no partial craft')
for _,stock in {{0,1},{1,0},{0,0}} do
 s,p,profile=fixture(stock[1],stock[2]);request(s,p,payload(s,p))
 check(profile.Revision==0 and profile.StoredConsumables.IronTrap==0,'Missing ingredients reject atomically')
end
for _,change in {
 function(v)v.OperationToken='forged'end,function(v)v.SnapshotVersion=-1 end,
 function(v)v.OperationSerial=3 end,function(v)v.SnapshotVersion=nil end,
} do
 s,p,profile=fixture(1,1);local bad=payload(s,p);change(bad);request(s,p,bad)
 check(profile.Revision==0 and profile.StoredConsumables.RawTrap==1 and profile.Materials.Iron==1,'Forged/stale payload rejected')
end
s,p,profile=fixture(1,1);request(s,p,s.Offers[p].Token)
check(profile.Revision==0,'Inventory crafting requires a versioned structured request')
s,p,profile,state=fixture(1,1);state.Root.Position=r.Vector3.new(30,0,0);request(s,p,payload(s,p))
check(profile.Revision==0,'Cannot craft from far away')
s,p,profile,state=fixture(1,1);p:SetAttribute('BaseId',2);request(s,p,payload(s,p))
check(profile.Revision==0,'Cannot use a different owner base')
s,p,profile,state=fixture(1,1);state.Drawn=true;request(s,p,payload(s,p))
check(profile.Revision==0,'Must sheath weapon')
s,p,profile,state=fixture(1,1);state.InHunting=true;request(s,p,payload(s,p))
check(profile.Revision==0,'Cannot craft while hunting')
s,p,profile,state=fixture(1,1);s.Persistence={Data=function()return {Economy=profile}end,CanMutate=function()return false end};request(s,p,payload(s,p))
check(profile.Revision==0,'Unavailable profile cannot consume ingredients')
for _,path in {'assets/inventory-crafting/ReplicatedStorage.Shared.EquipmentInventory.luau','src/dark-jungle/EquipmentInventory.luau','src/hunting/HuntEconomyService.luau'}do
 check(pcall(luau.compile,fs.readFile(path)),'Compile '..path)
end
print('PASS inventory crafting:',checks,'checks')
