-- Source compilation and read-only baseline manifest; never serialize a place.
local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local before=roblox.deserializePlace(fs.readFile("backups/Hub_v24_before_specimen_collection_20261019.rbxl"))
local bindings={
 {key="EquipmentInventory",path="ReplicatedStorage.Shared.EquipmentInventory",file="src/dark-jungle/EquipmentInventory.luau"},
 {key="HuntEconomyRules",path="ServerScriptService.HuntingRuntime.HuntEconomyRules",file="src/hunting/HuntEconomyRules.luau"},
 {key="HuntEconomyService",path="ServerScriptService.HuntingRuntime.HuntEconomyService",file="src/hunting/HuntEconomyService.luau"},
 {key="HuntQuestService",path="ServerScriptService.HuntingRuntime.HuntQuestService",file="src/hunting/HuntQuestService.luau"},
 {key="HuntCaptureController",path="ServerScriptService.HuntingRuntime.HuntCaptureController",file="src/hunting/HuntCaptureController.luau"},
 {key="HuntQuestClient",path="StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest",file="src/hunting/HuntQuest.client.luau"},
 {key="SpecimenPreviewModel",path="ServerScriptService.HuntingRuntime.SpecimenPreviewModel",file="src/hunting/SpecimenPreviewModel.luau",isNew=true,className="ModuleScript"},
}
local function hash(s)
 s=s:gsub("\r\n","\n"):gsub("%s+$","");local h=5381
 for _,cp in utf8.codes(s) do h=(h*33+cp)%4294967296 end;return h
end
for _,row in bindings do
 local s=fs.readFile(row.file);luau.compile(s);row.newHash=hash(s)
 if not row.isNew then
  local o=before;for n in row.path:gmatch("[^.]+") do o=assert(o:FindFirstChild(n)) end
  row.oldHash=hash(o.Source);row.className=o.ClassName
 end
end
fs.writeFile("assets/hunting/specimen-collection-install.json",serde.encode("json",bindings,true))
print("Specimen sources compile; 6 original bindings and 1 new module ready")
