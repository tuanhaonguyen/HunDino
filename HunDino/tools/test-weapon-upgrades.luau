local E=require('../src/hunting/HuntEconomyRules')
local Schema=require('../src/data/ProfileSchema').new(E)
local serde=require('@lune/serde')
local fs=require('@lune/fs')
local luau=require('@lune/luau')
if table.find(require('@lune/process').args,'--native') then
 E=luau.load(fs.readFile('assets/merchant-weapons/ServerScriptService.HuntingRuntime.HuntEconomyRules.luau'))()
 Schema=require('../src/data/ProfileSchema').new(E)
end
local savedIndex=table.find(require('@lune/process').args,'--saved')
if table.find(require('@lune/process').args,'--profile-compat') then
 E=luau.load(fs.readFile('assets/profile-compat/HuntEconomyRules.luau'))()
 Schema=require('../backups/profile-compat-20261027/ProfileSchema').new(E)
end
if savedIndex then
 local savedPath=assert(require('@lune/process').args[savedIndex+1],'--saved requires a place path')
 local place=require('@lune/roblox').deserializePlace(fs.readFile(savedPath))
 E=luau.load(place:GetService('ServerScriptService').HuntingRuntime.HuntEconomyRules.Source)()
 Schema=luau.load(place:GetService('ServerScriptService').AccountData.ProfileSchema.Source)().new(E)
end
local checks=0
local function check(v,m) checks+=1;assert(v,m) end
local function copy(v) if type(v)~='table' then return v end local out={} for k,x in v do out[k]=copy(x) end return out end
local function same(a,b)
 if type(a)~=type(b) then return false end
 if type(a)~='table' then return a==b end
 for k,v in a do if not same(v,b[k]) then return false end end
 for k,v in b do if not same(v,a[k]) then return false end end
 return true
end
local function reject(p,r,reason)
 local before=copy(p);local receipt=E.apply(p,r)
 check(not receipt.Ok and receipt.Code==reason,'Expected '..reason..', got '..receipt.Code)
 check(same(p,before),'Rejected operation must be atomic')
end
for _,file in {'src/hunting/HuntEconomyRules.luau','src/hunting/HuntEconomyService.luau',
 'src/hunting/HuntEconomy.client.luau','src/dark-jungle/HubUI.luau','src/dark-jungle/EquipmentInventory.luau','src/data/ProfileStatus.client.luau'} do
 check(pcall(luau.compile,fs.readFile(file)),'Compile '..file)
end
for _,target in E.WeaponOrder do
 local p=E.new();p.Materials.Bone=14;p.Materials.Iron=14
 local receipt=E.apply(p,{Op='UpgradeWeapon',WeaponId=target,OperationSerial=1})
 check(receipt.Ok and receipt.WeaponId==target and receipt.WeaponLevel==2,'Upgrade '..target)
 check(p.Materials.Bone==12 and p.Materials.Iron==12,'Exactly two bones and iron')
 check(p.Coins==80 and p.Revision==1,'No unrelated currency changes')
 for _,id in E.WeaponOrder do
  check(p.WeaponLevels[id]==(if id==target then 2 else 1),'Independent level '..target..'/'..id)
  check(E.damageMultiplier(p,id)==(if id==target then 1.15 else 1),'Independent combat multiplier')
 end
 local before=copy(p)
 local replay=E.apply(p,{Op='UpgradeWeapon',WeaponId='Bow',OperationSerial=1})
 check(replay.Ok and replay.Replay and replay.WeaponId==target and same(before,p),'Retry or substituted weapon cannot charge twice')
 reject(p,{Op='UpgradeWeapon',WeaponId=target,OperationSerial=2},'MaximumLevel')
 local dto=E.snapshot(p);dto.WeaponLevels[target]=1
 check(p.WeaponLevels[target]==2,'Client snapshot cannot alter levels')
 local account=Schema.Default(100);account.Economy=p
 local encoded=assert(Schema.Encode(account))
 local decoded=assert(Schema.Decode(serde.decode('json',serde.encode('json',encoded))))
 check(same(decoded.Economy,p),'Durable JSON round trip '..target)
end
local all=E.new();all.Materials.Bone=14;all.Materials.Iron=14
for index,id in E.WeaponOrder do check(E.apply(all,{Op='UpgradeWeapon',WeaponId=id,OperationSerial=index}).Ok,'All seven upgrade independently') end
check(all.Materials.Bone==0 and all.Materials.Iron==0 and all.HammerLevel==2,'Seven upgrades debit exactly fourteen of each')
for _,id in E.WeaponOrder do check(E.damageMultiplier(all,id)==1.15,'All maxed damage multipliers') end
for _,bad in {false,{},'Unknown','',1,'Bow\n'} do reject(E.new(),{Op='UpgradeWeapon',WeaponId=bad,OperationSerial=1},'InvalidWeapon') end
reject(E.new(),{Op='UpgradeWeapon',WeaponId='Bow',OperationSerial=1},'InsufficientMaterials')
reject(E.new(),{Op='UpgradeWeapon',WeaponId='Bow',OperationSerial=2},'StaleOperation')
local poor=E.new();poor.Materials.Bone=2;poor.Materials.Iron=1
reject(poor,{Op='UpgradeWeapon',WeaponId='Katana',OperationSerial=1},'InsufficientMaterials')
local active=E.new();active.Materials.Bone=2;active.Materials.Iron=2
check(E.apply(active,{Op='OpenRun',RunId='run',MonsterId='monster',RunSerial=1}).Ok,'Open run')
reject(active,{Op='UpgradeWeapon',WeaponId='Bow',OperationSerial=1},'ActiveRun')
for _,hammerLevel in {1,2} do
 local old=E.new();old.WeaponLevels=nil;old.HammerLevel=hammerLevel;old.Coins=17;old.Materials.Iron=8
 local before=copy(old);local migrated=assert(E.new(old))
 check(same(old,before),'Migration cannot mutate source')
 check(migrated.Coins==17 and migrated.Materials.Iron==8 and migrated.WeaponLevels.Hammer==hammerLevel,'Legacy hammer and all balances preserved')
 for _,id in E.WeaponOrder do if id~='Hammer' then check(migrated.WeaponLevels[id]==1,'No free cross-weapon upgrades') end end
 local restored=assert(E.new(migrated));check(same(restored,migrated),'Migration is idempotent')
end
for _,change in {
 function(p) p.WeaponLevels=false end,function(p) p.WeaponLevels.Bow=nil end,
 function(p) p.WeaponLevels.Katana=3 end,function(p) p.WeaponLevels.Bow=0/0 end,
 function(p) p.WeaponLevels.Unknown=2 end,function(p) p.WeaponLevels.Hammer=2 end,
} do
 local p=E.new();change(p);check(E.new(p)==nil,'Corrupt levels fail closed')
 local wrapped=Schema.Default(100);wrapped.Economy=p;check(Schema.Validate(wrapped)==nil,'Corrupt durable profile cannot reset account')
end
local oldServer=E.new();oldServer.HammerLevel=2;oldServer.WeaponLevels.Katana=2
local upgradedLegacy=assert(E.new(oldServer))
check(upgradedLegacy.WeaponLevels.Hammer==2 and upgradedLegacy.WeaponLevels.Katana==2,'Legacy server hammer upgrade cannot invalidate or wipe independent levels')
-- A new server/session reads the seven independent levels from a JSON store.
local Store=require('../src/data/ProfileStore')
local function json(v) return if v==nil then nil else serde.decode('json',serde.encode('json',v)) end
local ds={Values={}}
function ds:UpdateAsync(key,transform)
 transform(json(self.Values[key])) -- Roblox can repeat a transform callback.
 local value=transform(json(self.Values[key]))
 if value~=nil then self.Values[key]=json(value) end
 return json(self.Values[key])
end
local function repo(token)
 return Store.new({Store=ds,Token=token,Now=function() return 100 end,Sleep=function() end,
  MaxAttempts=3,LeaseSeconds=120,Validate=Schema.Validate,Encode=Schema.Encode})
end
local first=repo('weapon-session-one')
local loaded,why,account=first:Load('disposable-weapon-test',Schema.Default(100))
check(loaded,tostring(why))
account.Economy=all
check(first:Save('disposable-weapon-test',account,true),'Save and release upgraded account')
local second=repo('weapon-session-two')
local reopened,reason,restored=second:Load('disposable-weapon-test',Schema.Default(100))
check(reopened,tostring(reason))
for _,id in E.WeaponOrder do check(restored.Economy.WeaponLevels[id]==2,'New session retains '..id) end
local before=copy(restored.Economy)
local again=E.apply(restored.Economy,{Op='UpgradeWeapon',WeaponId='GreatAxe',OperationSerial=7})
check(again.Ok and again.Replay and same(before,restored.Economy),'New server replay cannot charge again')
print('PASS weapon upgrades:',checks,'checks')
