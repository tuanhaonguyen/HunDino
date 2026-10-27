-- Read-only baseline + source manifest. No place/Terrain serialization.
local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local before=roblox.deserializePlace(fs.readFile("backups/Hub_v24_before_hunt_economy_20261019.rbxl"))
local bindings={
 {"TrainingServer","Script","ServerScriptService.HunDinoTraining","studio-pet-integration/Training.server.luau",true},
 {"TrainingClient","LocalScript","StarterPlayer.StarterPlayerScripts.HunDinoTraining","studio-pet-integration/Training.client.luau",true},
 {"DinosaurCombat","ModuleScript","ServerScriptService.HuntingRuntime.DinosaurCombat","src/hunting/DinosaurCombat.luau",true},
 {"HuntQuestService","ModuleScript","ServerScriptService.HuntingRuntime.HuntQuestService","src/hunting/HuntQuestService.luau",true},
 {"HuntQuestClient","LocalScript","StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest","src/hunting/HuntQuest.client.luau",true},
 {"HubUI","ModuleScript","ReplicatedStorage.Shared.HubUI","src/dark-jungle/HubUI.luau",true},
 {"HuntEconomyRules","ModuleScript","ServerScriptService.HuntingRuntime.HuntEconomyRules","src/hunting/HuntEconomyRules.luau",false},
 {"HuntEconomyService","ModuleScript","ServerScriptService.HuntingRuntime.HuntEconomyService","src/hunting/HuntEconomyService.luau",false},
 {"HuntHarvestController","ModuleScript","ServerScriptService.HuntingRuntime.HuntHarvestController","src/hunting/HuntHarvestController.luau",false},
 {"HuntEconomyClient","LocalScript","StarterPlayer.StarterPlayerScripts.HunDinoEconomy","src/hunting/HuntEconomy.client.luau",false},
}
local function hash(s)
 s=s:gsub("\r\n","\n"):gsub("%s+$","");local h=5381
 for _,cp in utf8.codes(s) do h=(h*33+cp)%4294967296 end;return h
end
local manifest={}
for _,b in bindings do
 local s=fs.readFile(b[4]);luau.compile(s)
 local row={key=b[1],className=b[2],path=b[3],file=b[4],existing=b[5],newHash=hash(s)}
 if b[5] then local o=before;for n in b[3]:gmatch("[^.]+") do o=assert(o:FindFirstChild(n)) end;row.oldHash=hash(o.Source) end
 table.insert(manifest,row)
end
fs.writeFile("assets/hunting/hunt-economy-install.json",serde.encode("json",manifest,true))
print("Compiled all10 P1-E source bindings; read-only baseline manifest ready")
