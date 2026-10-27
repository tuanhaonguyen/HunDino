local fs=require('@lune/fs')
local serde=require('@lune/serde')
local luau=require('@lune/luau')
local baseline=serde.decode('json',fs.readFile('assets/qa/bow-pet-baseline/scripts.json'))
local sources={}
for _,row in baseline do sources[row.Path]=row.Source end
local bindings={
 {'ServerScriptService.HunDinoTraining','studio-pet-integration/Training.server.luau'},
 {'StarterPlayer.StarterPlayerScripts.HunDinoTraining','src/savegame/Training.client.luau'},
 {'ReplicatedStorage.Shared.Weapons','studio-pet-integration/Weapons.luau'},
 {'ReplicatedStorage.Shared.TrainingRules','studio-pet-integration/TrainingRules.luau'},
 {'ReplicatedStorage.Shared.BowBallistics','src/dark-jungle/BowBallistics.luau'},
 {'ServerScriptService.HuntingRuntime.DinosaurCombat','src/hunting/DinosaurCombat.luau'},
 {'ServerScriptService.HuntingRuntime.PetCombatRules','src/hunting/PetCombatRules.luau'},
 {'ServerScriptService.HuntingRuntime.PetCompanionController','src/hunting/PetCompanionController.luau'},
 {'StarterPlayer.StarterPlayerScripts.HunDinoPetCompanion','src/hunting/PetCompanion.client.luau'},
}
local rows={}
local merchant=table.find(require('@lune/process').args,'--merchant')~=nil
for _,binding in bindings do
 local path,file=binding[1],binding[2]
 if merchant and path=='ServerScriptService.HunDinoTraining'then file='src/savegame/TrainingMerchant.server.luau' end
 local source=fs.readFile(file)
 luau.compile(source)
 assert(sources[path] or path=='ReplicatedStorage.Shared.BowBallistics','Missing baseline: '..path)
 local before=sources[path]
 if merchant and path=='ServerScriptService.HunDinoTraining'then
  local count
  before,count=before:gsub('s%.WeaponId=="Hammer" and economy then economy:DamageMultiplier%(s%.Player%)','economy then economy:DamageMultiplier(s.Player,s.WeaponId)',1)
  assert(count==1,'Merchant baseline multiplier missing')
 end
 table.insert(rows,{Path=path,File=file,Source=source,Before=before})
end
fs.writeFile(if merchant then 'assets/qa/bow-pet-merchant-install.json'else 'assets/qa/bow-pet-install.json',serde.encode('json',rows))
print('Compiled '..#rows..' install sources; native place not modified')
