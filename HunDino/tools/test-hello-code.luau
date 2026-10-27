-- Disposable accounts only: exact rewards, durable claims, failure and retry.
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local serde=require('@lune/serde')
local Policy=require('../src/hunting/AdminRedeemPolicy')
local Store=require('../src/data/ProfileStore')
local SchemaModule=require('../src/data/ProfileSchema')
local checks=0
local function check(ok,message) checks+=1;assert(ok,message) end
local function json(value) return if value==nil then nil else serde.decode('json',serde.encode('json',value)) end
local function same(a,b) return serde.encode('json',a)==serde.encode('json',b) end
local NOW=1792550000
local ITEMS={'RawTrap','IronTrap','SleepPotion'}
local function request(user)
 local r=assert(Policy.Resolve(user or 123456,'HelloHunDino'));r.RedeemedAt=NOW;return r
end
for _,user in {1,123456,11605296816,999999999} do
 local r=request(user)
 check(r.CodeId=='HelloHunDino' and r.Coins==50 and r.Materials==nil,'Public policy fixes reward for every player')
 for _,item in ITEMS do check(r.Consumables[item]==2,'Two of each consumable') end
end
check(Policy.Resolve(123,'  hellohundino  ')~=nil,'Input normalizes whitespace and case')
for _,input in {'',false,{},50,string.rep('X',65),'HelloHunDino\nOTHER'} do
 check(Policy.Resolve(123,input)==nil,'Malformed code rejected')
end
local r=request();r.Consumables.RawTrap=100
check(request().Consumables.RawTrap==2,'Policy returns independent reward table')
check(Policy.Resolve(123,'HUNDINO-ADMIN-500')==nil,'Admin reward remains restricted')
check(Policy.Resolve(11605296816,'HUNDINO-ADMIN-500').Coins==500,'Admin reward remains available')

local bindings={{'src/hunting/HuntEconomyRules','src/data/ProfileSchema'},
 {'assets/redeem/hello-code/HuntEconomyRules','backups/savegame-before-redeem-20261022/ProfileSchema.original'}}
if table.find(require('@lune/process').args,'--profile-compat') then
 table.insert(bindings,{'assets/profile-compat/HuntEconomyRules','backups/profile-compat-20261027/ProfileSchema'})
end
for _,binding in bindings do
 local E=require('../'..binding[1]);local Schema=require('../'..binding[2]).new(E)
 local function balances(p,coins,n)
  check(p.Coins==coins,'Exact coin balance')
  for _,item in ITEMS do check(p.StoredConsumables[item]==n,'Exact consumable balance '..item) end
  for _,m in {'Skin','Tooth','Scale','Bone','Iron'} do check(p.Materials[m]==0,'Materials preserved') end
 end
 local function reject(p,r,code)
  local before=json(p);local result=E.apply(p,r)
  check(not result.Ok and (not code or result.Code==code),'Rejected '..tostring(code))
  check(same(p,before),'Rejected grant leaves all data unchanged')
 end
 local p=E.new();check(E.apply(p,request()).Ok,'First redemption succeeds');balances(p,130,2)
 local claim=p.RedeemedCodes.HelloHunDino
 check(claim.Consumables.RawTrap==2 and claim.Materials==nil,'Permanent receipt includes items')
 check(Schema.Validate({})==nil,'Invalid schema fails closed')
 check(E.new(json(p))~=nil,'New receipt passes JSON reload')
 reject(p,request(),'AlreadyRedeemed')
 for _,mutate in {
  function(x) x.Consumables=nil end,function(x) x.Consumables=false end,
  function(x) x.Consumables.RawTrap=nil end,function(x) x.Consumables.RawTrap=-1 end,
  function(x) x.Consumables.IronTrap=.5 end,function(x) x.Consumables.SleepPotion=0 end,
  function(x) x.Consumables.Unknown=2 end,function(x) x.Consumables.RawTrap=math.huge end,
  function(x) x.Consumables.RawTrap=E.Config.MaximumCount+1 end,
 } do local bad=request();mutate(bad);reject(E.new(),bad,'InvalidGrant') end
 for _,item in ITEMS do
  local full=E.new();full.StoredConsumables[item]=E.Config.MaximumCount-1
  reject(full,request(),'Capacity');check(full.RedeemedCodes.HelloHunDino==nil,'Overflow does not consume code')
 end
 local full=E.new();full.Coins=E.Config.MaximumCount-49;reject(full,request(),'Capacity')
 local edge=E.new();edge.Coins=E.Config.MaximumCount-50
 for _,item in ITEMS do edge.StoredConsumables[item]=E.Config.MaximumCount-2 end
 check(E.apply(edge,request()).Ok,'Exact storage maximum accepted')
 for _,corrupt in {
  function(x) x.Consumables.RawTrap=nil end,function(x) x.Consumables.SleepPotion=-2 end,
  function(x) x.Consumables.Unknown=2 end,function(x) x.Consumables=false end,
 } do local bad=json(p);corrupt(bad.RedeemedCodes.HelloHunDino);check(E.new(bad)==nil,'Corrupt saved receipt rejected') end
 local both=E.new();local admin=assert(Policy.Resolve(11605296816,'HUNDINO-ADMIN-500'));admin.RedeemedAt=NOW
 check(E.apply(both,admin).Ok and E.apply(both,request()).Ok,'Admin and public claims independent')
 check(both.Coins==630 and both.Materials.Iron==10 and both.StoredConsumables.IronTrap==2,'Combined rewards exact')
 for _,version in {1,2} do
  local old=E.new();old.RedeemedCodes=nil;old.Coins=31
  if version==1 then old.DataVersion=1;old.OwnedSpecimens=nil;old.SpecimenSerial=nil end
  local restored=assert(E.new(old));check(E.apply(restored,request()).Ok and restored.Coins==81,'Legacy progress preserved')
 end

 local ds={Values={},FailBefore=0,FailAfter=0}
 function ds:UpdateAsync(key,transform)
  if self.FailBefore>0 then self.FailBefore-=1;error('Before write') end
  transform(json(self.Values[key]))
  local next=transform(json(self.Values[key]));if next~=nil then self.Values[key]=json(next) end
  if self.FailAfter>0 then self.FailAfter-=1;error('Response lost') end
  return json(self.Values[key])
 end
 local function repository(token)
  return Store.new({Store=ds,Token=token,Now=function() return NOW end,Sleep=function() end,
   MaxAttempts=3,LeaseSeconds=120,Validate=Schema.Validate,Encode=Schema.Encode})
 end
 for _,failure in {'FailBefore','FailAfter'} do
  ds.Values={};local repo=repository(failure)
  local ok,why,account=repo:Load('fake-public-account',Schema.Default(NOW));check(ok,tostring(why))
  local candidate=json(account);check(E.apply(candidate.Economy,request()).Ok,'Grant candidate')
  ds[failure]=3;local saved=repo:Save('fake-public-account',candidate)
  check(not saved,'Unconfirmed save stays pending');balances(account.Economy,80,0)
  ok,why=repo:Save('fake-public-account',candidate);check(ok,'Retry saves once '..tostring(why))
  check(ds.Values['fake-public-account'].Revision==1,'Exactly one durable reward commit')
  check(repo:Save('fake-public-account',candidate,true),'Release account')
  local nextRepo=repository(failure..'-next');local loaded
  ok,why,loaded=nextRepo:Load('fake-public-account',Schema.Default(NOW));check(ok,tostring(why))
  balances(loaded.Economy,130,2);reject(loaded.Economy,request(),'AlreadyRedeemed')
 end
end
for _,row in serde.decode('json',fs.readFile('assets/redeem/hello-code/install.json')) do
 check(pcall(luau.compile,row.Source),'Compile '..row.Path)
end
print('HelloHunDino:',checks,'checks PASS; isolated memory backends, no real accounts touched')
