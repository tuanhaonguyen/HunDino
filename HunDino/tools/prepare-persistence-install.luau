-- Read baseline and package source text only. Never serialize a place/Terrain.
local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local baseline=roblox.deserializePlace(fs.readFile("backups/Hub_v24_before_persistence_20261020.rbxl"))
local bindings={
 {"ServerScriptService.AccountData.ProfileConfig","src/data/ProfileConfig.luau","ModuleScript",true},
 {"ServerScriptService.AccountData.ProfileSchema","src/data/ProfileSchema.luau","ModuleScript",true},
 {"ServerScriptService.AccountData.ProfileStore","src/data/ProfileStore.luau","ModuleScript",true},
 {"ServerScriptService.AccountData.ProfileService","src/data/ProfileService.luau","ModuleScript",true},
 {"StarterPlayer.StarterPlayerScripts.HunDinoProfileStatus","src/data/ProfileStatus.client.luau","LocalScript",true},
 {"ServerScriptService.HunDinoTraining","studio-pet-integration/Training.server.luau","Script"},
 {"ServerScriptService.HuntingRuntime.HuntEconomyService","src/hunting/HuntEconomyService.luau","ModuleScript"},
 {"ServerScriptService.HuntingRuntime.HuntQuestService","src/hunting/HuntQuestService.luau","ModuleScript"},
 {"ServerScriptService.HuntingRuntime.HuntCaptureController","src/hunting/HuntCaptureController.luau","ModuleScript"},
 {"ReplicatedStorage.Shared.HubUI","src/dark-jungle/HubUI.luau","ModuleScript"},
 {"StarterPlayer.StarterPlayerScripts.HunDinoEconomy","src/hunting/HuntEconomy.client.luau","LocalScript"},
}
local plan={}
for _,row in bindings do
 local source=fs.readFile(row[2]);luau.compile(source)
 local old=baseline
 for part in row[1]:gmatch("[^.]+") do old=old and old:FindFirstChild(part) end
 assert((old~=nil)~= (row[4]==true),"Unexpected baseline binding "..row[1])
 table.insert(plan,{Path=row[1],File=row[2],Class=row[3],New=row[4]==true,Source=source,Baseline=old and old.Source,
  SHA256=serde.hash("sha256",source)})
end
if not fs.isDir("assets/data") then fs.writeDir("assets/data") end
fs.writeFile("assets/data/persistence-install.json",serde.encode("json",plan))
print("PASS compilation/preflight plan",#plan,"bindings")
