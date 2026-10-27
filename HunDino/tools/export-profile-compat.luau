-- Read the pre-fix native place. Never serialize a place or touch account stores.
local fs=require('@lune/fs')
local roblox=require('@lune/roblox')
local serde=require('@lune/serde')
local root='backups/profile-compat-20261027/'
local place=roblox.deserializePlace(fs.readFile(root..'HunDino_MerchantWeapons_20261026.rbxl'))
local function at(path)
 local o=place;for name in path:gmatch('[^.]+') do o=assert(o:FindFirstChild(name),path) end;return o
end
local rows={}
for _,name in {'HuntEconomyRules','HuntEconomyService','AdminRedeemPolicy'} do
 local path='ServerScriptService.HuntingRuntime.'..name
 local source=at(path).Source:gsub('\r\n','\n')
 fs.writeFile(root..name..'.original.luau',source)
 table.insert(rows,{Path=path,Source=source,Name=name})
end
for _,name in {'ProfileSchema','ProfileStore'} do
 fs.writeFile(root..name..'.luau',at('ServerScriptService.AccountData.'..name).Source:gsub('\r\n','\n'))
end
fs.writeFile(root..'sources.json',serde.encode('json',rows,true))
print('Exported three original sources and native schema/store for isolated compatibility tests')
