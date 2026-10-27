-- Inspect only: native Terrain must never be reserialized by Lune.
local fs = require('@lune/fs')
local roblox = require('@lune/roblox')
local serde = require('@lune/serde')
local files = {'HunDino_SaveGame.rbxl', 'HunDino_SaveGame_CodeFix.rbxl', 'HunDino_SaveGame_before_close_20261022.rbxl'}
local previous
for _, file in files do
 local place = roblox.deserializePlace(fs.readFile(file))
 local scripts, rows, changed = {}, {}, {}
 for _, s in place:GetDescendants() do
  if s:IsA('LuaSourceContainer') and not s:IsDescendantOf(place:GetService('ServerStorage')) then
   scripts[s:GetFullName()] = s.Source:gsub('\r\n','\n'):gsub('%s+$','')
  end
 end
 if previous then
  for path, source in scripts do
   if previous[path] ~= source then table.insert(changed,path) end
  end
  for path in previous do if not scripts[path] then table.insert(changed,'REMOVED: '..path) end end
 end
 table.sort(changed)
 print(serde.encode('json',{File=file,SHA256=serde.hash('sha256',fs.readFile(file)),ChangedFromPrevious=changed}))
 if file == files[1] then
  fs.writeDir('assets/qa/bow-pet-baseline')
  for path, source in scripts do
   table.insert(rows,{Path=path,Source=source})
   if path:find('HunDinoTraining',1,true) or path:find('PetCompanionController',1,true) or path:find('PetCombatRules',1,true)
    or path=='ReplicatedStorage.Shared.TrainingRules' or path=='ReplicatedStorage.Shared.Weapons' then
    fs.writeFile('assets/qa/bow-pet-baseline/'..path..'.luau',source)
   end
  end
  fs.writeFile('assets/qa/bow-pet-baseline/scripts.json',serde.encode('json',rows))
 end
 previous=scripts
end
