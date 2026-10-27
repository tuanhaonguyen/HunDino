local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local saved=roblox.deserializePlace(fs.readFile("HunDino_ExplorationLoot_20261021.rbxl"))
local before=roblox.deserializePlace(fs.readFile("backups/Hub_before_exploration_loot_20261021.rbxl"))
local function at(root,path) for n in path:gmatch("[^.]+")do root=assert(root:FindFirstChild(n),path)end;return root end
local function norm(s) return s:gsub("\r\n","\n"):gsub("%s+$","") end
local checks=0
for _,row in serde.decode("json",fs.readFile("assets/hunting/exploration-loot-install.json"))do
	assert(norm(at(saved,row.Path).Source)==norm(fs.readFile(row.File)),row.Path);checks+=1
	if row.Baseline then assert(norm(at(saved,"ServerStorage.ExplorationLootBackup_20261021."..row.Name).Value)==norm(at(before,row.Path).Source));checks+=1 end
end
for _,row in {
	{"ReplicatedStorage.Shared.HubUI","src/dark-jungle/HubUI.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoTraining","studio-pet-integration/Training.client.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest","src/hunting/HuntQuest.client.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoProfileStatus","src/data/ProfileStatus.client.luau"},
}do
	local current,old=at(saved,row[1]),at(before,row[1]);local b=at(saved,"ServerStorage.HUDCleanupBackup_20261021."..old.Name)
	assert(norm(current.Source)==norm(fs.readFile(row[2])),row[1]);checks+=1
	assert(norm(b.Value)==norm(old.Source));checks+=1
	local a=b:GetAttributes();assert(a.OriginalPath==row[1] and #b:GetTags()==0 and #b:GetDescendants()==0);checks+=1
	for key in a do assert(key=="OriginalPath") end
end
assert(at(saved,"ServerScriptService.AccountData"):GetAttribute("StudioMemoryTest")==nil);checks+=1
local compiled=0;for _,o in saved:GetDescendants()do if o:IsA("LuaSourceContainer")then luau.compile(o.Source);compiled+=1 end end
assert(compiled==130);checks+=1
print("PASS native bindings, backups and QA cleanup:",checks,"checks;",compiled,"compiled scripts")
