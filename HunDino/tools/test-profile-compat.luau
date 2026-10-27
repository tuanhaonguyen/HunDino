-- Regression for v12 rejecting an existing HelloHunDino receipt. Fake records only.
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local serde=require('@lune/serde')
local Old=require('../backups/profile-compat-20261027/HuntEconomyRules.original')
local Fixed=require('../assets/profile-compat/HuntEconomyRules')
local Policy=require('../assets/profile-compat/AdminRedeemPolicy')
local Legacy=require('../assets/redeem/hello-code/HuntEconomyRules')
local SchemaModule=require('../backups/profile-compat-20261027/ProfileSchema')
local Store=require('../backups/profile-compat-20261027/ProfileStore')
local LegacySchema=require('../backups/savegame-before-redeem-20261022/ProfileSchema.original').new(Legacy)
local Schema=SchemaModule.new(Fixed)
local NOW=1792550000
local checks=0
local function check(ok,why) checks+=1;assert(ok,why) end
local function json(v) return if v==nil then nil else serde.decode('json',serde.encode('json',v)) end
local function same(a,b)
 if type(a)~=type(b) then return false end
 if type(a)~='table' then return a==b end
 for k,v in a do if not same(v,b[k]) then return false end end
 for k in b do if a[k]==nil then return false end end
 return true
end
local fixture=LegacySchema.Default(NOW)
check(Legacy.apply(fixture.Economy,{Op='RedeemCode',CodeId='HelloHunDino',Coins=50,
 Consumables={RawTrap=2,IronTrap=2,SleepPotion=2},RedeemedAt=NOW}).Ok,'Create historical receipt in isolated fixture')
fixture.Preferences.AimSensitivity=.75
fixture.Economy.Coins=41
fixture.Economy.StoredConsumables={RawTrap=0,IronTrap=1,SleepPotion=2}
fixture.Economy.Materials={Skin=3,Tooth=4,Scale=5,Bone=6,Iron=7}
fixture.Economy.HammerLevel=2
fixture.Statistics={HuntsCompleted=17,HuntsFailed=3,Captures=1}
local specimenId='00000000-0000-4000-8000-000000000001'
fixture.Economy.SpecimenSerial=1
fixture.Economy.OwnedSpecimens[specimenId]={Id=specimenId,SpeciesId='TRex',Name='T-Rex',Variant='Normal',
 Element='None',SizeScale=1,CapturedAt=NOW,SourceRunId='legacy-run-1',SourceMonsterId='legacy-monster-1',Serial=1}
fixture.Economy.DisplaySlots[5]=specimenId
fixture=assert(LegacySchema.Validate(fixture))
local encoded=json(assert(LegacySchema.Encode(fixture)))
local oldSchema=SchemaModule.new(Old)
local invalid,why=oldSchema.Validate(encoded)
check(invalid==nil and why=='Economy:InvalidProfile','Reproduces live v12 failure without touching the account')
local fixed=assert(Schema.Validate(encoded))
local function preserved(data)
 check(data.Economy.Coins==41,'Keep earned/spent coin balance')
 check(same(data.Economy.StoredConsumables,fixture.Economy.StoredConsumables),'Keep spent items; do not replenish a redeemed code')
 check(same(data.Economy.Materials,fixture.Economy.Materials),'Keep all materials')
 check(same(data.Economy.RedeemedCodes,fixture.Economy.RedeemedCodes),'Keep permanent claim receipt')
 check(same(data.Economy.OwnedSpecimens,fixture.Economy.OwnedSpecimens),'Keep captured specimen')
 check(same(data.Economy.DisplaySlots,fixture.Economy.DisplaySlots),'Keep display assignment')
 check(same(data.Preferences,fixture.Preferences) and same(data.Loadout,fixture.Loadout),'Keep preferences and equipment')
 check(same(data.Statistics,fixture.Statistics),'Keep hunt statistics')
 check(data.Economy.HammerLevel==2 and data.Economy.WeaponLevels.Hammer==2,'Migrate per-weapon levels without losing upgrade')
 check(not Fixed.apply(data.Economy,{Op='RedeemCode',CodeId='HelloHunDino',Coins=50,
  Consumables={RawTrap=2,IronTrap=2,SleepPotion=2},RedeemedAt=NOW}).Ok,'Claim stays used after reload')
end
preserved(fixed)
local ds={Value={FormatVersion=1,Revision=257,Data=encoded},Writes=0}
function ds:UpdateAsync(_,transform)
 local result=transform(json(self.Value))
 if result~=nil then self.Value=json(result);self.Writes+=1 end
 return json(result)
end
local function repository(token,schema)
 return Store.new({Store=ds,Token=token,Now=function()return NOW end,Sleep=function()end,
  Validate=schema.Validate,Encode=schema.Encode})
end
local oldRepo=repository('old-v12',oldSchema)
local ok,status=oldRepo:Load('fixture-only',oldSchema.Default(NOW))
check(not ok and status=='Economy:InvalidProfile' and ds.Writes==0,'Rejected load neither resets nor overwrites old data')
local repo=repository('fixed-A',Schema)
local data
ok,status,data=repo:Load('fixture-only',Schema.Default(NOW))
check(ok,'Patched load accepts historical record: '..tostring(status))
preserved(data)
check(repo:Save('fixture-only',data),'Save migrated profile')
check(ds.Value.Revision==258,'Exactly one new data revision')
check(repo:Save('fixture-only',data,true),'Release normally')
local second=repository('fixed-B',Schema)
ok,status,data=second:Load('fixture-only',Schema.Default(NOW))
check(ok,'Rejoin after save/release')
preserved(data)
check(ds.Value.Revision==259,'Acquisition does not replay a reward write')
local bad=json(encoded);bad.Economy.RedeemedCodes.HelloHunDino.Consumables.SleepPotion=nil
check(Schema.Validate(bad)==nil,'Malformed receipt remains rejected')
local mining=Fixed.new()
local receipt=Fixed.apply(mining,{Op='MineIron',OperationSerial=1,
 SourceId='2afe6b27-01c4-4ef9-bba2-6a266d477099:1:1',NodeId=1,HitIndex=1,QuantityRoll=.1})
check(receipt.Ok and receipt.Code=='IronMined' and mining.Materials.Iron==2,'Keep current branch mining operation')
check(Policy.Resolve(123456,'HelloHunDino').Coins==50,'Public policy restored')
check(Policy.Resolve(123456,'HUNDINO-ADMIN-500')==nil,'Admin restriction retained')
for _,row in serde.decode('json',fs.readFile('assets/profile-compat/install.json')) do
 check(pcall(luau.compile,row.Source),'Compile '..row.Path)
end
print(string.format('Profile compatibility: %d checks PASS; v12 failure reproduced, preserved progress saved and reloaded',checks))
