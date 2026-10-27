local fs=require('@lune/fs')
local roblox=require('@lune/roblox')
local serde=require('@lune/serde')
local root=roblox.deserializePlace(fs.readFile('HunDino_SaveGame.rbxl'))
local rows={}
local function path(o)
 local names={}
 while o and not o:IsA('DataModel') do table.insert(names,1,o.Name);o=o.Parent end
 return table.concat(names,'.')
end
for _,o in root:GetDescendants() do
 if o:IsA('LuaSourceContainer') then table.insert(rows,{Path=path(o),Source=o.Source,Class=o.ClassName}) end
end
fs.writeFile('backups/merchant-weapons-20261026/saved-sources.json',serde.encode('json',rows))
print('Exported',#rows,'scripts from saved place; no place serialization')
