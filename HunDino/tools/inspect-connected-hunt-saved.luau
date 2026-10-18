-- Run from HunDino with Lune after saving the combined place in Roblox Studio.
-- Reads the rbxl files only. The sole write is the JSON validation report;
-- never serialize these places through Lune (native Terrain has unknown fields).
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local path = "HunDino_DarkJungle_v2_3.rbxl"
local backupPath = "backups/Hub_before_hunting_link_20261016.rbxl"
local combatBackupPath = "backups/Hub_before_dinosaur_combat_20261016.rbxl"
local bytes = fs.readFile(path)
local beforeBytes = fs.readFile(backupPath)
local saved = roblox.deserializePlace(bytes)
local before = roblox.deserializePlace(beforeBytes)
local combatBeforeBytes = fs.readFile(combatBackupPath)
local combatBefore = roblox.deserializePlace(combatBeforeBytes)
local world = saved:GetService("Workspace")
local oldWorld = before:GetService("Workspace")
local replicated = saved:GetService("ReplicatedStorage")
local server = saved:GetService("ServerScriptService")
local starter = saved:GetService("StarterPlayer").StarterPlayerScripts
local forest = assert(world:FindFirstChild("HuntingRainforest"), "Saved forest missing")
local hub = assert(world:FindFirstChild("HunDinoL0"), "Saved hub missing")
local function normalized(source)
	return (source:gsub("\r\n", "\n"):gsub("\239\187\191", ""):gsub("%s+$", ""))
end
local function relativeName(instance)
	local names = {}
	while instance and not instance:IsA("DataModel") do
		table.insert(names, 1, instance.Name)
		instance = instance.Parent
	end
	return table.concat(names, ".")
end
local function vector(value) return {value.X, value.Y, value.Z} end
local function color(value) return {value.R, value.G, value.B} end
local function assetValue(part, legacy, content)
	local ok, value = pcall(function() return part[legacy] end)
	if ok then return value end
	-- New Studio writes Content properties for some imported MeshParts.
	-- Compare their full decoded value instead of omitting the asset identity.
	return tostring(part[content])
end
local function geometry(root, exclude)
	local rows = {}
	for _, part in root:GetDescendants() do
		if not part:IsA("BasePart") or (exclude and part:IsDescendantOf(exclude)) then continue end
		-- Encode numeric components rather than rounded tostring(CFrame) values.
		-- Sorted rows also retain duplicate-name parts without relying on unique
		-- GetFullName keys or importer-assigned Instance IDs.
		local row = {
			path = relativeName(part), className = part.ClassName,
			cframe = {part.CFrame:GetComponents()}, size = vector(part.Size),
			color = color(part.Color), material = tostring(part.Material),
			materialVariant = part.MaterialVariant, transparency = part.Transparency,
			reflectance = part.Reflectance, anchored = part.Anchored,
			canCollide = part.CanCollide, canTouch = part.CanTouch,
			canQuery = part.CanQuery, castShadow = part.CastShadow,
			collisionGroup = part.CollisionGroup, massless = part.Massless,
		}
		if part:IsA("Part") then row.shape = tostring(part.Shape) end
		if part:IsA("MeshPart") then
			row.meshId = assetValue(part, "MeshId", "MeshContent")
			row.textureId = assetValue(part, "TextureID", "TextureContent")
		end
		if part:IsA("SpawnLocation") then row.spawnEnabled = part.Enabled end
		table.insert(rows, serde.encode("json", row))
	end
	table.sort(rows)
	return rows
end
local geometryCounts = {}
for _, rootName in {"HunDinoL0", "DarkJungle"} do
	local oldRoot = assert(oldWorld:FindFirstChild(rootName), "Backup root missing " .. rootName)
	local newRoot = assert(world:FindFirstChild(rootName), "Current root missing " .. rootName)
	local original = geometry(oldRoot)
	local actual = geometry(newRoot, if rootName == "HunDinoL0" then newRoot:FindFirstChild("HuntingTransit") else nil)
	assert(#original == #actual, rootName .. " original part count changed")
	for index, row in original do assert(row == actual[index], rootName .. " original geometry changed at sorted row " .. index) end
	geometryCounts[rootName] = #original
end

-- Combat changes scripts/UI only. Preserve the entire scene, including the
-- forest, dinosaur, portal parts and all previously preserved lobby geometry.
local combatOriginalGeometry = geometry(combatBefore:GetService("Workspace"))
local combatCurrentGeometry = geometry(world)
assert(#combatOriginalGeometry == #combatCurrentGeometry, "Combat update changed scene part count")
for index, row in combatOriginalGeometry do
	assert(row == combatCurrentGeometry[index], "Combat update changed original scene geometry at sorted row " .. index)
end

-- Compare every original script by full path. Travel, menus, forest traversal,
-- hunting equipment eligibility and combat inputs are intentional changes.
local intentionalChanges = {
	["ServerScriptService.HunDinoTraining"] = true,
	["StarterPlayer.StarterPlayerScripts.HunDinoTraining"] = true,
	["ReplicatedStorage.Shared.HubUI"] = true,
	["ServerScriptService.JungleTraversal"] = true,
	["ReplicatedStorage.Shared.TrainingRules"] = true,
	["ReplicatedStorage.Shared.TrainingConfig"] = true,
	["ReplicatedStorage.Shared.EquipmentInventory"] = true,
}
local savedSources = {}
local compiledScripts = 0
for _, object in saved:GetDescendants() do
	if object:IsA("LuaSourceContainer") then
		luau.compile(object.Source)
		compiledScripts += 1
		savedSources[relativeName(object)] = object
	end
end
local preservedScripts, changedOriginals = 0, {}
for _, object in before:GetDescendants() do
	if object:IsA("LuaSourceContainer") then
		local name = relativeName(object)
		local current = assert(savedSources[name], "Original script removed: " .. name)
		assert(current.ClassName == object.ClassName, "Original script class changed: " .. name)
		if intentionalChanges[name] then
			table.insert(changedOriginals, name)
		else
			assert(normalized(current.Source) == normalized(object.Source), "Unrelated original script changed: " .. name)
			preservedScripts += 1
		end
	end
end
table.sort(changedOriginals)

local matches = {}
local function canonical(object, file)
	assert(object and object:IsA("LuaSourceContainer"), "Saved source missing for " .. file)
	assert(normalized(object.Source) == normalized(fs.readFile(file)), "Saved source differs from canonical: " .. file)
	table.insert(matches, {saved = relativeName(object), source = file})
	return object
end
canonical(replicated.HuntingMapConfig, "src/hunting/ConnectedHuntingConfig.luau")
canonical(replicated.HuntingBaseConfig, "src/hunting/HuntingMapConfig.luau")
canonical(replicated.HuntingEnvironmentClock, "src/hunting/EnvironmentClock.luau")
local runtime = assert(server:FindFirstChild("HuntingRuntime"), "HuntingRuntime missing")
canonical(runtime.HuntingSession, "src/hunting/HuntingSession.luau")
canonical(runtime.DinosaurRouteController, "src/hunting/DinosaurRouteController.luau")
canonical(runtime.DinosaurCombat, "src/hunting/DinosaurCombat.luau")
canonical(runtime.DinosaurCombatConfig, "src/hunting/DinosaurCombatConfig.luau")
canonical(server.HunDinoTraining, "studio-pet-integration/Training.server.luau")
canonical(starter.HunDinoTraining, "studio-pet-integration/Training.client.luau")
canonical(replicated.Shared.HubUI, "src/dark-jungle/HubUI.luau")
canonical(replicated.Shared.TrainingRules, "studio-pet-integration/TrainingRules.luau")
canonical(replicated.Shared.TrainingConfig, "studio-pet-integration/TrainingConfig.luau")
canonical(replicated.Shared.EquipmentInventory, "src/dark-jungle/EquipmentInventory.luau")
canonical(server.JungleTraversal, "src/dark-jungle/Traversal.server.luau")
-- Locate by source so a cosmetic installed script name cannot hide an absent,
-- disabled, duplicated, or stale connected viewer.
local viewerSource = normalized(fs.readFile("src/hunting/ConnectedHuntingViewer.client.luau"))
local viewers = {}
for _, object in starter:GetChildren() do
	if object:IsA("LocalScript") and normalized(object.Source) == viewerSource then table.insert(viewers, object) end
end
assert(#viewers == 1 and not viewers[1].Disabled, "Expected one active canonical connected viewer")
canonical(viewers[1], "src/hunting/ConnectedHuntingViewer.client.luau")

-- Evaluate only the pure configuration modules, using Lune's Vector3 and a
-- narrow require shim. No Studio/runtime services, players, or Terrain are run.
local configCache = {}
local loadConfig
local mockGame = {GetService = function(_, name)
	assert(name == "ReplicatedStorage", "Unexpected pure-config service " .. name)
	return {WaitForChild = function(_, childName) return assert(replicated:FindFirstChild(childName)) end}
end}
loadConfig = function(module)
	if configCache[module] then return configCache[module] end
	assert(module == replicated.HuntingMapConfig or module == replicated.HuntingBaseConfig, "Unexpected config require")
	local value = luau.load(module.Source, {environment = {game = mockGame, Vector3 = roblox.Vector3, require = loadConfig}, injectGlobals = true})()
	configCache[module] = value
	return value
end
local config = loadConfig(replicated.HuntingMapConfig)
assert(config.ConnectedToHub == true and config.TimeScale == 30 and config.TimezoneOffsetMinutes == 420)
assert(config.WorldOffset == roblox.Vector3.new(0, 0, 6500))
assert(config.HuntDurationSeconds == nil or config.HuntDurationSeconds == 40 * 60, "Temporary short visit duration was saved")
local session = luau.load(runtime.HuntingSession.Source, {environment = {Vector3 = roblox.Vector3}, injectGlobals = true})()
local duration = session.new(forest, config, nil, nil).Duration
assert(duration == 40 * 60, "Saved visit duration must be 40 minutes, not the 30-second expiry test")
local combatConfig = luau.load(runtime.DinosaurCombatConfig.Source,
	{environment = {Vector3 = roblox.Vector3}, injectGlobals = true})()
local movementConfig = luau.load(replicated.Shared.TrainingConfig.Source)()
assert(movementConfig.DodgeSpeed == 72 and movementConfig.DodgeTime == .5, "Saved dodge tuning changed")
assert(movementConfig.DodgeCost * movementConfig.StaminaCostScale == 6, "Saved dodge stamina cost changed")
assert(combatConfig.MaxHealth == 1200 and combatConfig.BiteDamage == 24, "Temporary combat test balance was saved")
assert(combatConfig.BiteWindup == .95 and combatConfig.BiteCooldown == 3.5, "Saved retaliation warning/cooldown changed")
assert(combatConfig.BiteActiveSeconds > 0 and combatConfig.BiteActiveSeconds < combatConfig.BiteCooldown)
assert(combatConfig.LeashDistance == 260 and combatConfig.MaxWeaponRange == 250)
assert(config.RestSeconds == nil or config.RestSeconds == 60, "Temporary short patrol rest was saved")

assert(forest:GetAttribute("HubConnected") == true and forest:GetAttribute("WorldOffset") == config.WorldOffset)
assert(forest:GetAttribute("TerrainImportSize") == roblox.Vector3.new(1632, 176, 1632))
assert(forest:GetAttribute("TerrainImportCellSize") == roblox.Vector3.new(408, 44, 408))
assert(#forest.Zones:GetChildren() == 9 and #forest.Paths:GetChildren() == 15)
assert(forest.Camp.CampSpawn:IsA("SpawnLocation") and not forest.Camp.CampSpawn.Enabled)
assert(hub.Lobby.LobbySpawn.Enabled and hub.Lobby.LobbySpawn.CFrame.Position == roblox.Vector3.new(0, 20, 181))
assert(hub.Lobby.Arrival.CFrame.Position == roblox.Vector3.new(0, 23, 181))
assert(hub.Training.Arrival.CFrame.Position == roblox.Vector3.new(2086, 39, 160))
local enabledSpawns = 0
for _, object in world:GetDescendants() do
	if object:IsA("SpawnLocation") and object.Enabled then enabledSpawns += 1; assert(object == hub.Lobby.LobbySpawn) end
end
assert(enabledSpawns == 1)
assert(hub.HuntingTransit.ToHunting:FindFirstChildOfClass("ProximityPrompt"))
assert(forest.Camp.ReturnToLobby:FindFirstChildOfClass("ProximityPrompt"))
local parts, meshes, motors, welds, anchors = 0, 0, 0, 0, 0
local dinosaur = assert(world:FindFirstChild("Dinosaur01_TRex_Visual"))
assert(not dinosaur:FindFirstChild("CombatHitboxes") and not dinosaur:FindFirstChild("DinosaurHealthbar"),
	"Runtime-only healthbar/hitboxes were saved and would duplicate on Play")
for _, object in dinosaur:GetDescendants() do
	if object:IsA("BasePart") then parts += 1; if object.Anchored then anchors += 1 end end
	if object:IsA("MeshPart") then meshes += 1 end
	if object:IsA("Motor6D") then motors += 1; assert(object.Part0 and object.Part1) end
	if object:IsA("WeldConstraint") then welds += 1; assert(object.Part0 and object.Part1) end
end
assert(parts == 255 and motors == 7 and welds == 247 and anchors == 1)
assert(dinosaur.PrimaryPart.CFrame.Position.Z > 5500 and dinosaur.MotionRuntime.Disabled)
for _, container in {server, starter} do
	for _, object in container:GetDescendants() do
		if object:IsA("Script") or object:IsA("LocalScript") then
			if object.Name == "HuntingMapRuntime" or object.Name == "HuntingMapViewer" or object.Name == "DinosaurPreviewControls" or object.Name == "DinosaurPreviewBridge" then assert(object.Disabled, "Legacy standalone runtime enabled") end
		end
	end
end

local report = {
	version = "ConnectedHuntSavedValidation.3-H1.3.1", validation = "passed",
	savedPlace = path, bytes = #bytes, backup = backupPath, backupBytes = #beforeBytes,
	originalGeometryPreserved = geometryCounts, originalScriptsUnchanged = preservedScripts,
	combatBaseline = combatBackupPath, combatBaselineBytes = #combatBeforeBytes,
	combatScenePartsPreserved = #combatOriginalGeometry,
	intentionalOriginalScriptChanges = changedOriginals, canonicalSources = matches,
	compiledScripts = compiledScripts, animalZones = 8, camps = 1,
	mainPaths = 13, humanPaths = 2, enabledSpawns = enabledSpawns,
	worldOffset = vector(config.WorldOffset), huntDurationSeconds = duration,
	timeScale = config.TimeScale, timezoneOffsetMinutes = config.TimezoneOffsetMinutes,
	dinosaur = {parts = parts, meshes = meshes, motors = motors, welds = welds, anchors = anchors},
	combat = {maxHealth = combatConfig.MaxHealth, biteDamage = combatConfig.BiteDamage,
		biteWindupSeconds = combatConfig.BiteWindup, biteActiveSeconds = combatConfig.BiteActiveSeconds,
		biteCooldownSeconds = combatConfig.BiteCooldown, leashStuds = combatConfig.LeashDistance,
		defaultRestSeconds = config.RestSeconds or 60, runtimeVolumesGeneratedOnPlay = true},
	dodge = {initialSpeed = movementConfig.DodgeSpeed, durationSeconds = movementConfig.DodgeTime,
		staminaCost = movementConfig.DodgeCost * movementConfig.StaminaCostScale},
	terrain = {writeMethod = "Roblox Studio native CopyRegion/PasteRegion and Save", importStuds = {1632, 176, 1632}, importCells = {408, 44, 408},
		originalTerrainVoxelEquality = "not inspected by Lune; unsupported Terrain fields are never serialized", liveGroundValidation = "see connected-validation.json"},
}
fs.writeFile("assets/hunting/connected-saved.json", serde.encode("json", report, true))
print(serde.encode("json", report, true))
