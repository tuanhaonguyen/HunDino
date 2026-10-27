-- Run as a whole chunk through Studio Server MCP. This uses ONLY disposable fake
-- players and in-memory UpdateAsync doubles; never accesses an account DataStore.
local SSS=game:GetService("ServerScriptService")
local Http=game:GetService("HttpService")
local source=assert(SSS:FindFirstChild("AccountData"),"Install AccountData modules before running QA")
local folder=source:Clone()
folder.Name="__ProfileServiceQA_"..Http:GenerateGUID(false)
for _,object in folder:GetDescendants() do if object:IsA("BaseScript") then object.Enabled=false end end
folder.Parent=SSS
local services,players={},{}
local report={Groups=0,Checks=0,Passed={}}
local function check(condition,message)
 report.Checks+=1;assert(condition,message)
end
local function clone(value)
 if type(value)~="table" then return value end
 local result={};for key,item in value do result[key]=clone(item) end;return result
end
local function fakePlayer(id)
 local player={UserId=id,Parent=true,Attributes={},Signals={}}
 function player:GetAttribute(key) return self.Attributes[key] end
 function player:SetAttribute(key,value)
  if self.Attributes[key]==value then return end
  self.Attributes[key]=value
  if self.Signals[key] then self.Signals[key]:Fire() end
 end
 function player:GetAttributeChangedSignal(key)
  if not self.Signals[key] then self.Signals[key]=Instance.new("BindableEvent") end
  return self.Signals[key].Event
 end
 table.insert(players,player);return player
end
local function fakeStore()
 local backend={Records={},Calls=0,Writes=0,FailBefore=0,FailAfter=0}
 function backend:UpdateAsync(key,transform)
  self.Calls+=1
  if self.OnCall then self.OnCall(self,key) end
  if self.FailBefore>0 then self.FailBefore-=1;error("QA outage before write") end
  local result=transform(clone(self.Records[key]))
  if self.BeforeCommit then self.BeforeCommit(self,key,result) end
  if result~=nil then self.Records[key]=clone(result);self.Writes+=1 end
  if self.FailAfter>0 then self.FailAfter-=1;error("QA response lost after write") end
  return clone(result)
 end
 return backend
end
local function cleanup()
 for _,service in services do
  service.Stopped=true
  for _,entry in service.Entries do for _,connection in entry.Connections or {} do connection:Disconnect() end end
  table.clear(service.Entries)
  for _,connection in service.Connections do connection:Disconnect() end
  if service.Remote then service.Remote:Destroy() end
 end
 for _,player in players do
  player.Parent=nil;for _,signal in player.Signals do signal:Destroy() end
 end
 folder:Destroy()
end
local success,result=xpcall(function()
 local Service=require(folder.ProfileService)
 local Repository=require(folder.ProfileStore)
 local Economy=require(SSS.HuntingRuntime.HuntEconomyRules)
 local Schema=require(folder.ProfileSchema).new(Economy)
 local now=1792400000
 local function repo(backend,token)
  return Repository.new({Store=backend,Token=token or Http:GenerateGUID(false),Now=function() return now end,
   Sleep=function() end,Validate=Schema.Validate,Encode=Schema.Encode,LeaseSeconds=120,MaxAttempts=4})
 end
 local function context(backend,player)
  backend=backend or fakeStore();player=player or fakePlayer(100001+#players)
  local repository=repo(backend)
  local service=Service.new({Repository=repository,Schema=Schema,Now=function() return now end,
   ServerNow=function() return now+.25 end,Stopped=true,Mode="IsolatedQAMemory"})
  service.Remote.Name="__ProfileServiceQAAction_"..#services
  table.insert(services,service)
  return service,backend,player,repository
 end
 local function test(name,body)
  body();report.Groups+=1;table.insert(report.Passed,name)
 end
 local function buy(service,player)
  return service:CommitEconomy(player,function(economy)
   return Economy.apply(economy,{Op="Buy",Item="RawTrap",OperationSerial=economy.OperationSerial+1})
  end)
 end
 test("Load gates use; defaults are granted only once",function()
  local service,backend,player=context()
  check(not service:Ready(player) and not service:CanMutate(player),"No account access before load")
  check(buy(service,player).Code=="SavePending","Economic action blocked before load")
  check(service:Load(player),"Initial load succeeds")
  check(service:Data(player).Economy.Coins==80 and service:CanMutate(player),"Only default starter coins")
  check(buy(service,player).Ok,"Purchase commits")
  service:Release(player)
  check(service.Entries[player]==nil,"Release removes confirmed entry")
  local nextService,_,nextPlayer=context(backend,fakePlayer(player.UserId))
  check(nextService:Load(nextPlayer),"Another session can load released account")
  check(nextService:Data(nextPlayer).Economy.Coins==70,"Starter grant does not reset existing coins")
 end)
 test("Economic success follows durable write and preserves canonical identity",function()
  local service,backend,player=context();check(service:Load(player),"Load")
  local canonical=service:Data(player).Economy
  backend.BeforeCommit=function(_,_,proposal)
   check(canonical.Coins==80,"Canonical coins unchanged until UpdateAsync returns")
   check(proposal.Data.Economy.Coins==70,"Proposed snapshot contains purchase")
  end
  check(buy(service,player).Ok,"Purchase acknowledged after commit")
  backend.BeforeCommit=nil
  check(service:Data(player).Economy==canonical and canonical.Coins==70,"Canonical table updated after save")
  check(backend.Records["player_"..player.UserId].Data.Economy.Coins==70,"Durable snapshot agrees")
 end)
 test("Four failed writes retain pending purchase without early coin changes",function()
  local service,backend,player=context();check(service:Load(player),"Load")
  backend.FailBefore=4
  local receipt=buy(service,player)
  check(not receipt.Ok and receipt.Code=="SavePending","Purchase not reported successful")
  check(service:Data(player).Economy.Coins==80,"No early deduction")
  check(service.Entries[player].Pending~=nil and not service:CanMutate(player),"Pending blocks duplicate economic requests")
  check(backend.Records["player_"..player.UserId].Data.Economy.Coins==80,"Failed writes preserve stored coins")
  check(service:Save(player),"Explicit retry resolves pending")
  check(service:Data(player).Economy.Coins==70,"Deducted once after confirmed retry")
  check(service:Data(player).Economy.StoredConsumables.RawTrap==1,"One purchased trap")
  check(service:Save(player),"Another ordinary save")
  check(service:Data(player).Economy.Coins==70 and service:Data(player).Economy.StoredConsumables.RawTrap==1,"No duplicate purchase")
 end)
 test("Lost write responses resolve pending without duplicate transaction",function()
  local service,backend,player=context();check(service:Load(player),"Load")
  backend.FailAfter=4
  check(not buy(service,player).Ok,"Unknown result not acknowledged early")
  local key="player_"..player.UserId
  check(service:Data(player).Economy.Coins==80 and backend.Records[key].Data.Economy.Coins==70,"Pending snapshot kept separate")
  local revision=backend.Records[key].Revision
  check(service:Save(player),"Resolve commit receipt then save")
  check(service:Data(player).Economy.Coins==70 and service:Data(player).Economy.StoredConsumables.RawTrap==1,"Exactly one purchase")
  check(backend.Records[key].Revision==revision+1,"Only final ordinary save adds one revision")
 end)
 test("Gear changed while Save yields remains Dirty and next Save captures it",function()
  local service,backend,player=context();check(service:Load(player),"Load")
  backend.BeforeCommit=function()
   backend.BeforeCommit=nil
   player:SetAttribute("WeaponId","Bow");task.wait()
  end
  check(service:Save(player),"First save")
  check(service.Entries[player].State=="Dirty","Concurrent generation remains dirty")
  check(backend.Records["player_"..player.UserId].Data.Loadout.WeaponId=="Hammer","In-flight snapshot remains original")
  check(service:Save(player),"Second save captures new gear")
  check(backend.Records["player_"..player.UserId].Data.Loadout.WeaponId=="Bow","Next snapshot persists changed gear")
 end)
 test("Unavailable loads never save defaults over existing data",function()
  local backend=fakeStore();local key="player_900001"
  local original=Schema.Default(now);original.Economy.Coins=7
  backend.Records[key]={FormatVersion=1,Data=assert(Schema.Encode(original)),Revision=4}
  backend.FailBefore=4
  local service,_,player=context(backend,fakePlayer(900001))
  check(not service:Load(player) and not service:Ready(player),"Failed load remains unavailable")
  check(not service:Save(player),"Save cannot run on unverified default")
  check(backend.Records[key].Data.Economy.Coins==7 and backend.Writes==0,"Existing account untouched")
  check(service:Load(player) and service:Data(player).Economy.Coins==7,"Explicit retry restores existing progress")
 end)
 test("Failed recovery stays gated and retries its claimed profile safely",function()
  local backend=fakeStore();local key="player_900002"
  local original=Schema.Default(now)
  check(Economy.apply(original.Economy,{Op="OpenRun",RunId="qa-recover",MonsterId="qa-monster",RunSerial=1}).Ok,"Seed unfinished run")
  backend.Records[key]={FormatVersion=1,Data=assert(Schema.Encode(original)),Revision=2}
  backend.OnCall=function(ds)
   if ds.Calls==2 then ds.FailBefore=4;ds.OnCall=nil end
  end
  local service,_,player=context(backend,fakePlayer(900002))
  check(not service:Load(player),"Recovery save failure prevents readiness")
  check(service.Entries[player].RecoveryData~=nil and not service:CanMutate(player),"Recovery candidate retained")
  check(service:Load(player),"Retry confirms recovery before allowing use")
  check(service:Data(player).Economy.ActiveRun==nil and backend.Records[key].Data.Economy.ActiveRun==nil,"Recovered run durably closed once")
 end)
 test("Failed Release retains Closing entry; explicit retry removes only after confirmation",function()
  local service,backend,player=context();check(service:Load(player),"Load")
  backend.FailBefore=4
  service:Release(player)
  local retained=service.Entries[player]
  check(retained~=nil and retained.Closing and not service:CanMutate(player),"Unconfirmed close retained and gated")
  service:Release(player)
  check(service.Entries[player]==nil,"Confirmed retry removes entry")
  check(backend.Records["player_"..player.UserId].Session==nil,"Confirmed release removes lease")
 end)
 test("Stale lease clears pending; fresh Load cannot overwrite successor data",function()
  local service,backend,player=context();check(service:Load(player),"Load")
  backend.FailBefore=4;check(not buy(service,player).Ok,"Create pending purchase")
  now+=121
  local successor=repo(backend);local key="player_"..player.UserId
  local acquired,_,data=successor:Load(key,Schema.Default(now));check(acquired,"Successor acquires expired lease")
  data.Economy.Coins=51;check(successor:Save(key,data,true),"Successor commits and releases")
  check(not service:Save(player),"Stale session cannot save old pending candidate")
  check(service.Entries[player].Pending==nil and not service:Ready(player),"Pending quarantined on terminal lease loss")
  check(service:Load(player),"Fresh Load uses successor data")
  check(service:Data(player).Economy.Coins==51 and service:Save(player),"Fresh data remains canonical")
  check(backend.Records[key].Data.Economy.Coins==51,"Old pending purchase never overwrites successor")
 end)
 test("Preferences validate server input and cooldown timestamps persist",function()
  local service,backend,player=context();check(service:Load(player),"Load")
  service:Request(player,"Preference","AimSensitivity",99)
  service:Request(player,"Preference","ShowDamage","false")
  service:Request(player,"Preference","Coins",999999)
  check(player:GetAttribute("AimSensitivity")==1 and player:GetAttribute("ShowDamage")==true,"Invalid preference values rejected")
  service:Request(player,"Preference","ShowDamage",false);task.wait()
  check(player:GetAttribute("ShowDamage")==false,"Allowed boolean preference applied")
  player:SetAttribute("PetHealReadyAt",now+.25+89.6);task.wait()
  check(service:Save(player),"Save preferences and cooldown")
  local data=backend.Records["player_"..player.UserId].Data
  check(data.Preferences.ShowDamage==false and data.Pet.HealReadyAt==now+90,"Preference/cooldown encoded as durable account data")
  now+=91;check(service:Save(player),"Save expired cooldown before lease expires")
  check(backend.Records["player_"..player.UserId].Data.Pet.HealReadyAt==0,"Expired cooldown cleared")
 end)
 return report
end,debug.traceback)
cleanup()
if not success then error(result) end
return result
