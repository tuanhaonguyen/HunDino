-- Read-only place manifest + source compilation. Never serializes Terrain/place.
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local baseline = roblox.deserializePlace(fs.readFile("backups/Hub_v24_before_hunt_quest_20261019.rbxl"))
local bindings = {
	{"TrainingServer", "Script", "ServerScriptService.HunDinoTraining", "studio-pet-integration/Training.server.luau", true},
	{"TrainingClient", "LocalScript", "StarterPlayer.StarterPlayerScripts.HunDinoTraining", "studio-pet-integration/Training.client.luau", true},
	{"DinosaurCombat", "ModuleScript", "ServerScriptService.HuntingRuntime.DinosaurCombat", "src/hunting/DinosaurCombat.luau", true},
	{"DinosaurRouteController", "ModuleScript", "ServerScriptService.HuntingRuntime.DinosaurRouteController", "src/hunting/DinosaurRouteController.luau", true},
	{"HuntingSession", "ModuleScript", "ServerScriptService.HuntingRuntime.HuntingSession", "src/hunting/HuntingSession.luau", true},
	{"PetCompanionController", "ModuleScript", "ServerScriptService.HuntingRuntime.PetCompanionController", "src/hunting/PetCompanionController.luau", true},
	{"HubUI", "ModuleScript", "ReplicatedStorage.Shared.HubUI", "src/dark-jungle/HubUI.luau", true},
	{"ConnectedHuntingViewer", "LocalScript", "StarterPlayer.StarterPlayerScripts.ConnectedHuntingViewer", "src/hunting/ConnectedHuntingViewer.client.luau", true},
	{"HuntQuestRules", "ModuleScript", "ServerScriptService.HuntingRuntime.HuntQuestRules", "src/hunting/HuntQuestRules.luau", false},
	{"HuntCaptureController", "ModuleScript", "ServerScriptService.HuntingRuntime.HuntCaptureController", "src/hunting/HuntCaptureController.luau", false},
	{"HuntQuestService", "ModuleScript", "ServerScriptService.HuntingRuntime.HuntQuestService", "src/hunting/HuntQuestService.luau", false},
	{"HuntQuestClient", "LocalScript", "StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest", "src/hunting/HuntQuest.client.luau", false},
}
local function hash(source)
	source = source:gsub("\r\n", "\n"):gsub("%s+$", "")
	local h = 5381
	for _, cp in utf8.codes(source) do h = (h * 33 + cp) % 4294967296 end
	return h
end
local manifest = {}
for _, row in bindings do
	local source = fs.readFile(row[4]); luau.compile(source)
	local item = {key = row[1], className = row[2], path = row[3], file = row[4], existing = row[5], newHash = hash(source)}
	if row[5] then
		local object = baseline
		for name in row[3]:gmatch("[^.]+") do object = assert(object:FindFirstChild(name), row[3]) end
		item.oldHash = hash(object.Source)
	end
	table.insert(manifest, item)
end
fs.writeFile("assets/hunting/hunt-quest-install.json", serde.encode("json", manifest, true))
print("Compiled all 12 quest source bindings; read-only baseline manifest ready")
