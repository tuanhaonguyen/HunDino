local fs=require('@lune/fs')
local roblox=require('@lune/roblox')
local serde=require('@lune/serde')
local place=roblox.deserializePlace(fs.readFile('HunDino_SaveGame_before_close_20261022.rbxl'))
local out={}
for _,s in place:GetDescendants() do
 if s:IsA('LuaSourceContainer') then table.insert(out,{Path=s:GetFullName(),Source=s.Source}) end
end
fs.writeFile('backups/close-recovery-20261022-scripts.json',serde.encode('json',out))
print('Recovered scripts: '..#out)
