-- Read the saved merged place. Never write place or Terrain data.
local fs=require('@lune/fs')
local r=require('@lune/roblox')
local serde=require('@lune/serde')
local target='HunDino_MerchantWeapons_20261026.rbxl'
local bytes=fs.readFile(target)
local place=r.deserializePlace(bytes)
local checks=0
local function check(ok,label) checks+=1;assert(ok,label) end
local function at(path)
 local item=place
 for name in path:gmatch('[^.]+') do item=assert(item:FindFirstChild(name),path) end
 return item
end
local function norm(source) return source:gsub('\r\n','\n'):gsub('%s+$','') end
local bindings={}
local rows=serde.decode('json',fs.readFile('assets/merchant-weapons/install.json'))
local craftOverrides={}
if fs.isFile('assets/inventory-crafting/install.json') then
 for _,row in serde.decode('json',fs.readFile('assets/inventory-crafting/install.json')) do craftOverrides[row.Path]=row.Source end
end
check(#rows==6,'Expected six retained merchant/UI/save scripts')
for _,row in rows do
 local expected=craftOverrides[row.Path] or row.Source
 check(norm(at(row.Path).Source)==norm(expected),'Merchant source changed in merge: '..row.Path)
 bindings[row.Path]=serde.hash('sha256',norm(expected))
end
local combatRows=serde.decode('json',fs.readFile('assets/qa/bow-pet-merchant-install.json'))
check(#combatRows==9,'Expected nine combat bindings')
for _,row in combatRows do
 check(norm(at(row.Path).Source)==norm(fs.readFile(row.File)),'Combat binding changed: '..row.Path)
end
local training=at('ServerScriptService.HunDinoTraining').Source
check(training:find('economy:DamageMultiplier(s.Player,s.WeaponId)',1,true)~=nil,'Weapon-specific combat multiplier missing')
check(not training:find('s.WeaponId=="Hammer" and economy',1,true),'Legacy hammer-only combat guard remained')
local hud=at('StarterPlayer.StarterPlayerScripts.HunDinoProfileStatus').Source
check(not hud:find('strip.Name="SaveStatus"',1,true),'Persistent save strip restored')
local config=at('ServerScriptService.AccountData.ProfileConfig').Source
check(config:find('StudioMemoryTest=false',1,true)~=nil,'Test mode in saved config')
check(config:find('StudioLocalFileEnabled=true',1,true)~=nil,'Local-file opt-in missing')
check(at('ServerScriptService.AccountData'):GetAttribute('StudioMemoryTest')~=true,'Test-memory override remains')
local old=fs.readFile('CHOI_VA_LUU.cmd')
local direct=fs.readFile('CHOI_CUA_HANG.cmd')
check(old:find('CHOI_CUA_HANG.cmd',1,true)~=nil,'Old launcher points to another main')
check(direct:find('HunDino_MerchantWeapons_20261026.rbxl',1,true)~=nil,'Merchant launcher points to another main')
local report={Ok=true,Checks=checks,Target=target,SHA256=serde.hash('sha256',bytes),
 MerchantSourceBindings=bindings,CombatSourceBindings=#combatRows,LaunchersAgree=true,
 HiddenSaveHUDRetained=true,TestFlagsRemoved=true,Published=false}
fs.writeFile('assets/merchant-weapons/merged-source-audit.json',serde.encode('json',report,true))
print(serde.encode('json',report,true))
