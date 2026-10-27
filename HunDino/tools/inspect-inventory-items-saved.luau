-- Run from HunDino only after a native Roblox Studio Save.
-- READS both rbxl files. Never serialize a place or decode/rewrite Terrain.
-- The sole output is assets/hunting/inventory-items-saved.json.
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local placePath = "HunDino_DarkJungle_v2_4.rbxl"
local baselinePath = "backups/Hub_v24_before_inventory_items_20261019.rbxl"
local reportPath = "assets/hunting/inventory-items-saved.json"
local report = {
	version = "InventoryItemsSavedValidation.1",
	savedPlace = placePath,
	baseline = baselinePath,
	terrain = "Not decoded or serialized; this inspector never writes a place",
}
local checks = 0
local function check(condition, message)
	assert(condition, message)
	checks += 1
end
local function normalized(source)
	return source:gsub("\r\n", "\n"):gsub("\239\187\191", ""):gsub("%s+$", "")
end
local function pathOf(instance, stop)
	local parts = {}
	while instance and instance ~= stop and not instance:IsA("DataModel") do
		table.insert(parts, 1, instance.Name)
		instance = instance.Parent
	end
	return table.concat(parts, ".")
end
local function valueOf(value)
	local kind = typeof(value)
	if kind == "Vector3" then return {value.X, value.Y, value.Z} end
	if kind == "Vector2" then return {value.X, value.Y} end
	if kind == "Color3" then return {value.R, value.G, value.B} end
	if kind == "CFrame" then return {value:GetComponents()} end
	if kind == "PhysicalProperties" then
		return {value.Density, value.Friction, value.Elasticity, value.FrictionWeight, value.ElasticityWeight}
	end
	if kind == "BrickColor" then return value.Number end
	if type(value) == "number" or type(value) == "boolean" or type(value) == "string" then return value end
	if type(value) == "table" then
		local output = {}
		for key, item in value do output[key] = valueOf(item) end
		return output
	end
	return if value ~= nil then tostring(value) else nil
end
local function optional(instance, property)
	local ok, value = pcall(function() return instance[property] end)
	return if ok then valueOf(value) else nil
end
local function attributes(instance)
	return valueOf(instance:GetAttributes())
end
local ASSET_PROPERTIES = {
	"MeshId", "MeshContent", "TextureId", "TextureID", "TextureContent", "MeshType", "Scale", "Offset", "VertexColor",
	"ColorMap", "ColorMapContent", "NormalMap", "NormalMapContent", "MetalnessMap", "MetalnessMapContent",
	"RoughnessMap", "RoughnessMapContent", "AlphaMode", "Color", "Color3", "Texture", "Face", "Transparency",
	"StudsPerTileU", "StudsPerTileV", "OffsetStudsU", "OffsetStudsV", "ZIndex",
}
local function assets(part)
	local rows = {}
	for _, object in part:GetDescendants() do
		if object:IsA("DataModelMesh") or object:IsA("SurfaceAppearance") or object:IsA("Decal") then
			local row = {path = pathOf(object, part), className = object.ClassName, attributes = attributes(object)}
			for _, property in ASSET_PROPERTIES do row[property] = optional(object, property) end
			table.insert(rows, serde.encode("json", row))
		end
	end
	table.sort(rows)
	return rows
end
local PART_PROPERTIES = {
	"CFrame", "Size", "Color", "Material", "MaterialVariant", "Transparency", "Reflectance", "Anchored",
	"CanCollide", "CanTouch", "CanQuery", "CastShadow", "CollisionGroup", "Massless", "RootPriority",
	"CustomPhysicalProperties", "TopSurface", "BottomSurface", "FrontSurface", "BackSurface", "LeftSurface", "RightSurface",
}
local function partRow(part, root)
	local row = {path = pathOf(part, root), className = part.ClassName, attributes = attributes(part), assets = assets(part)}
	for _, property in PART_PROPERTIES do row[property] = optional(part, property) end
	if part:IsA("Part") then row.Shape = optional(part, "Shape") end
	if part:IsA("MeshPart") then
		for _, property in {"MeshId", "MeshContent", "TextureID", "TextureContent", "CollisionFidelity", "RenderFidelity", "DoubleSided", "MeshSize"} do
			row[property] = optional(part, property)
		end
	end
	if part:IsA("SpawnLocation") then
		for _, property in {"Enabled", "Neutral", "Duration", "AllowTeamChangeOnTouch", "TeamColor"} do
			row[property] = optional(part, property)
		end
	end
	return row
end
local function geometry(root)
	local rows = {}
	for _, part in root:GetDescendants() do
		-- Terrain has opaque native fields that Lune must not serialize.
		if part:IsA("BasePart") and not part:IsA("Terrain") then
			table.insert(rows, serde.encode("json", partRow(part, root)))
		end
	end
	table.sort(rows)
	return rows
end
local function compareRows(oldRows, newRows, label)
	check(#oldRows == #newRows, label .. " count changed")
	for index, row in oldRows do
		check(row == newRows[index], label .. " changed at sorted multiset row " .. index)
	end
	return #oldRows
end
local function joints(root)
	local rows = {}
	for _, object in root:GetDescendants() do
		if object:IsA("JointInstance") or object:IsA("WeldConstraint") then
			local row = {path = pathOf(object, root), className = object.ClassName, attributes = attributes(object)}
			for _, property in {"C0", "C1", "Transform", "Enabled"} do row[property] = optional(object, property) end
			for _, property in {"Part0", "Part1"} do
				local part = object[property]
				row[property] = if part then partRow(part, root) else nil
			end
			table.insert(rows, serde.encode("json", row))
		end
	end
	table.sort(rows)
	return rows
end
local function main()
	local bytes, beforeBytes = fs.readFile(placePath), fs.readFile(baselinePath)
	report.savedBytes, report.baselineBytes = #bytes, #beforeBytes
	local saved, before = roblox.deserializePlace(bytes), roblox.deserializePlace(beforeBytes)
	local world, oldWorld = saved:GetService("Workspace"), before:GetService("Workspace")
	report.preservedBaseParts = compareRows(geometry(before), geometry(saved), "All saved BaseParts")
	report.preservedJoints = compareRows(joints(before), joints(saved), "All saved joints")
	check(report.preservedBaseParts == 43775, "Expected all 43,775 saved BaseParts")
	check(report.preservedJoints == 845, "Expected all 845 saved joints")
	local workspaceParts, workspaceJoints = 0, 0
	for _, object in world:GetDescendants() do
		if object:IsA("BasePart") and not object:IsA("Terrain") then workspaceParts += 1 end
		if object:IsA("JointInstance") or object:IsA("WeldConstraint") then workspaceJoints += 1 end
	end
	report.preservedWorkspaceBaseParts = workspaceParts
	report.preservedWorkspaceJoints = workspaceJoints
	check(workspaceParts == 35064 and workspaceJoints == 723, "Workspace geometry counts changed")
	check(world.StreamingEnabled == oldWorld.StreamingEnabled and world.StreamingEnabled, "Streaming configuration changed")
	local intentional = {
		["ReplicatedStorage.Shared.EquipmentInventory"] = true,
		["ServerScriptService.HuntingRuntime.HuntEconomyService"] = true,
		["StarterPlayer.StarterPlayerScripts.HunDinoEconomy"] = true,
	}
	local sources, compiled = {}, 0
	for _, object in saved:GetDescendants() do
		if object:IsA("LuaSourceContainer") then
			luau.compile(object.Source)
			compiled += 1
			local key = pathOf(object) .. "|" .. object.ClassName
			sources[key] = sources[key] or {}
			table.insert(sources[key], object)
		end
	end
	local preserved, changed = 0, {}
	for _, object in before:GetDescendants() do
		if not object:IsA("LuaSourceContainer") then continue end
		local name = pathOf(object)
		local bucket = assert(sources[name .. "|" .. object.ClassName], "Original source removed: " .. name)
		local matched
		for index, current in bucket do
			if intentional[name] or normalized(current.Source) == normalized(object.Source) then matched = index; break end
		end
		check(matched ~= nil, "Unrelated original source changed: " .. name .. "|" .. object.ClassName)
		table.remove(bucket, matched)
		if intentional[name] then table.insert(changed, name) else preserved += 1 end
	end
	table.sort(changed)
	check(#changed == 3, "Expected exactly three intentional original source bindings")
	check(compiled == 111 and preserved == 105, "Expected 111 saved sources and 105 unchanged original sources")
	report.compiledScripts, report.originalScriptsPreserved, report.intentionalOriginalScriptChanges = compiled, preserved, changed
	local backupRoot = assert(saved:GetService("ServerStorage"):FindFirstChild("InventoryItemsBackup_20261019"), "Missing original source backup")
	check(backupRoot:IsA("Folder"), "Source backup must be a Folder")
	local backupSources = {
		EquipmentInventory = "ReplicatedStorage.Shared.EquipmentInventory",
		HuntEconomyService = "ServerScriptService.HuntingRuntime.HuntEconomyService",
		HuntEconomyClient = "StarterPlayer.StarterPlayerScripts.HunDinoEconomy",
	}
	check(#backupRoot:GetChildren() == 3, "Expected exactly three original source backups")
	local verifiedBackups = {}
	for name, originalPath in backupSources do
		local copy = assert(backupRoot:FindFirstChild(name), "Missing source backup: " .. name)
		local original = before
		for component in originalPath:gmatch("[^.]+") do
			original = assert(original:FindFirstChild(component), "Missing baseline source for backup: " .. originalPath)
		end
		check(copy.ClassName == original.ClassName, "Wrong backup script class: " .. name)
		check(normalized(copy.Source) == normalized(original.Source), "Source backup differs from baseline: " .. name)
		check(#copy:GetDescendants() == #original:GetDescendants(), "Unexpected descendants in source backup: " .. name)
		verifiedBackups[pathOf(copy) .. "|" .. copy.ClassName] = true
	end
	local expectedNew = {}
	local newSources = {}
	for key, bucket in sources do
		for _ in bucket do
			if verifiedBackups[key] then
				verifiedBackups[key] = nil
				continue
			end
			check(expectedNew[key] == true, "Unexpected new saved script: " .. key)
			expectedNew[key] = nil
			table.insert(newSources, key)
		end
	end
	check(next(verifiedBackups) == nil, "Original backup source missing from compiled saved sources")
	check(next(expectedNew) == nil and #newSources == 0, "Expected no new production source bindings")
	table.sort(newSources)
	report.newSources = newSources
	report.verifiedOriginalSourceBackups = 3
	local canonical = {}
	local function sourceAt(path, className, file)
		local object = saved
		for name in path:gmatch("[^.]+") do object = assert(object:FindFirstChild(name), "Missing canonical object: " .. path) end
		check(object.ClassName == className, "Wrong canonical script class: " .. path)
		check(normalized(object.Source) == normalized(fs.readFile(file)), "Saved source differs from canonical: " .. file)
		table.insert(canonical, {saved = path, source = file})
		return object
	end
	sourceAt("ServerScriptService.HunDinoTraining", "Script", "studio-pet-integration/Training.server.luau")
	sourceAt("StarterPlayer.StarterPlayerScripts.HunDinoTraining", "LocalScript", "studio-pet-integration/Training.client.luau")
	sourceAt("StarterPlayer.StarterPlayerScripts.ConnectedHuntingViewer", "LocalScript", "src/hunting/ConnectedHuntingViewer.client.luau")
	sourceAt("ReplicatedStorage.Shared.HubUI", "ModuleScript", "src/dark-jungle/HubUI.luau")
	sourceAt("ReplicatedStorage.Shared.EquipmentInventory", "ModuleScript", "src/dark-jungle/EquipmentInventory.luau")
	sourceAt("ServerScriptService.HuntingRuntime.DinosaurCombat", "ModuleScript", "src/hunting/DinosaurCombat.luau")
	sourceAt("ServerScriptService.HuntingRuntime.DinosaurRouteController", "ModuleScript", "src/hunting/DinosaurRouteController.luau")
	sourceAt("ServerScriptService.HuntingRuntime.HuntingSession", "ModuleScript", "src/hunting/HuntingSession.luau")
	local questRules = sourceAt("ServerScriptService.HuntingRuntime.HuntQuestRules", "ModuleScript", "src/hunting/HuntQuestRules.luau")
	sourceAt("ServerScriptService.HuntingRuntime.HuntCaptureController", "ModuleScript", "src/hunting/HuntCaptureController.luau")
	sourceAt("ServerScriptService.HuntingRuntime.HuntQuestService", "ModuleScript", "src/hunting/HuntQuestService.luau")
	sourceAt("StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest", "LocalScript", "src/hunting/HuntQuest.client.luau")
	local rules = sourceAt("ServerScriptService.HuntingRuntime.PetCombatRules", "ModuleScript", "src/hunting/PetCombatRules.luau")
	sourceAt("ServerScriptService.HuntingRuntime.PetCompanionController", "ModuleScript", "src/hunting/PetCompanionController.luau")
	sourceAt("StarterPlayer.StarterPlayerScripts.HunDinoPetCompanion", "LocalScript", "src/hunting/PetCompanion.client.luau")
	sourceAt("ServerScriptService.AdminFly.Main", "Script", "src/admin/AdminFly.server.luau")
	local policy = sourceAt("ServerScriptService.AdminFly.AdminFlyPolicy", "ModuleScript", "src/admin/AdminFlyPolicy.luau")
	sourceAt("StarterPlayer.StarterPlayerScripts.HunDinoAdminFly", "LocalScript", "src/admin/AdminFly.client.luau")
	sourceAt("ServerScriptService.HuntingRuntime.HuntEconomyRules","ModuleScript","src/hunting/HuntEconomyRules.luau")
	sourceAt("ServerScriptService.HuntingRuntime.HuntEconomyService","ModuleScript","src/hunting/HuntEconomyService.luau")
	sourceAt("ServerScriptService.HuntingRuntime.HuntHarvestController","ModuleScript","src/hunting/HuntHarvestController.luau")
	sourceAt("StarterPlayer.StarterPlayerScripts.HunDinoEconomy","LocalScript","src/hunting/HuntEconomy.client.luau")
	local economyObject=saved:GetService("ServerScriptService").HuntingRuntime.HuntEconomyRules
	local economyRules=luau.load(economyObject.Source)()
	local fresh=economyRules.new()
	check(fresh.Coins==80 and fresh.HammerLevel==1 and fresh.ActiveRun==nil,"Unexpected P1-E starter profile")
	for _,n in fresh.Materials do check(n==0,"Unexpected starter material") end
	for _,n in fresh.StoredConsumables do check(n==0,"Unexpected starter consumable") end
	check(economyRules.damageMultiplier(fresh)==1,"Unpurchased upgrade persisted")
	check(not world:FindFirstChild("HuntEconomyStations"),"Runtime stations saved in Edit")
	for _,o in world:GetChildren() do check(not o.Name:match("^HuntHarvest_"),"Runtime loot saved in Edit") end
	check(not saved:GetService("ReplicatedStorage"):FindFirstChild("HunDinoEconomyAction"),"Runtime economy remote saved in Edit")
	check(not saved:GetService("StarterGui"):FindFirstChild("HunDinoEconomy"),"Runtime inventory GUI saved in Edit")
	report.economy={StarterCoins=80,HammerLevels=2,Storage="ServerMemory",NewSources=0}
	check(#canonical == 22, "Expected 22 canonical production source bindings")
	local starterGui = saved:GetService("StarterGui")
	for _, name in {"InventoryShade", "WeaponSelection", "ItemsPage", "CraftingPage", "ItemPrototypeWorld"} do
		check(not starterGui:FindFirstChild(name, true), "Runtime inventory UI or prototype saved in Edit: " .. name)
	end
	report.canonicalSources = canonical
	local loadedQuestRules = luau.load(questRules.Source)()
	local expectedQuestConfig = {
		Duration = 2400, HarvestSeconds = 120, MaxDeaths = 4, RespawnDelay = 5,
		TrapPlaceSeconds = 1, TrapLifetime = 60, TrapHoldSeconds = 13, CaptureSeconds = 3,
		WeakRatio = 0.1, TrapCount = 3, PotionCount = 3,
	}
	for name, value in expectedQuestConfig do
		check(loadedQuestRules.Config[name] == value, "Unexpected quest prototype setting: " .. name)
	end
	report.questConfig = expectedQuestConfig
	local petRules = luau.load(rules.Source)()
	local expectedPetConfig = {MaxHealth = 100, AttackDamage = 12, AttackInterval = 4, AttackRange = 6,
		StunSeconds = 30, HealFraction = 0.7, HealCooldown = 119, HealCastSeconds = 0.8, HealRange = 3.8, MoveSpeed = 18}
	for name, value in expectedPetConfig do
		check(petRules.Config[name] == value, "Unexpected pet prototype setting: " .. name)
	end
	report.petConfig = expectedPetConfig
	local loadedPolicy = luau.load(policy.Source)()
	check(loadedPolicy.Enabled and loadedPolicy.Allowed(11605296816, 0, "User"), "Administrator permission missing")
	check(not loadedPolicy.Allowed(1, 0, "User") and not loadedPolicy.Allowed(123, 123, "Group"), "Automatic Studio/group permission was saved")
	check(loadedPolicy.DefaultSpeed == 160 and loadedPolicy.MaxAltitude == 1800, "Flight defaults differ")
	for _, speed in {80, 160, 260} do check(loadedPolicy.ValidateSpeed(speed), "Missing predefined flight speed") end
	check(not loadedPolicy.ValidateSpeed(1e9), "Unrestricted flight speed accepted")
	local forest = assert(world:FindFirstChild("HuntingRainforest"), "Hunting forest missing")
	check(forest:GetAttribute("Version") == "H2.0" and forest:GetAttribute("MapWidth") == 4000 and forest:GetAttribute("MapDepth") == 4500, "H2 map metadata changed")
	check(#forest.Zones:GetChildren() == 9 and #forest.Paths:GetChildren() == 16, "H2 navigation topology changed")
	local trees = #forest.Decor.Forest:GetChildren()
	check(trees == 2400 and trees == forest:GetAttribute("TreesPlaced"), "Expected 2,400 forest trees")
	local dino = assert(world:FindFirstChild("Dinosaur01_TRex_Visual"), "Dinosaur missing")
	local rig = {parts = 0, meshes = 0, motors = 0, welds = 0, anchors = 0}
	for _, object in dino:GetDescendants() do
		if object:IsA("BasePart") then
			rig.parts += 1
			if object:IsA("MeshPart") then rig.meshes += 1 end
			if object.Anchored then rig.anchors += 1 end
		elseif object:IsA("Motor6D") then rig.motors += 1
		elseif object:IsA("WeldConstraint") then rig.welds += 1 end
	end
	check(rig.parts == 255 and rig.meshes == 21 and rig.motors == 7 and rig.welds == 247 and rig.anchors == 1, "Dinosaur rig counts changed")
	check(not dino:FindFirstChild("CombatHitboxes") and not dino:FindFirstChild("DinosaurHealthbar"), "Runtime dinosaur state was saved")
	check(not world:FindFirstChild("TrainingPets"), "Runtime training pets were saved")
	check(not saved:GetService("ReplicatedStorage"):FindFirstChild("HunDinoPetCompanion"), "Runtime pet remote was saved in Edit")
	check(not saved:GetService("StarterGui"):FindFirstChild("HunDinoPetCompanionHUD"), "Runtime pet HUD was saved in Edit")
	check(not saved:GetService("ReplicatedStorage"):FindFirstChild("HunDinoHuntQuest"), "Runtime quest remote was saved in Edit")
	check(not saved:GetService("StarterGui"):FindFirstChild("HunDinoHuntQuest")
		and not saved:GetService("StarterGui"):FindFirstChild("HunDinoHuntQuestHUD"), "Runtime quest HUD was saved in Edit")
	check(not world:FindFirstChild("HuntQuestBoard"), "Runtime quest board was saved in Edit")
	check(not saved:GetService("ReplicatedStorage"):FindFirstChild("HunDinoAdminFly"), "Runtime flight remote was saved in Edit")
	check(not saved:GetService("TextChatService"):FindFirstChild("HunDinoAdminFlyCommand"), "Runtime chat command was saved in Edit")
	for _, object in world:GetDescendants() do
		check(not object.Name:match("^AdminFlyAttachment$") and not object.Name:match("^AdminFlyVelocity$") and not object.Name:match("^AdminFlyOrientation$"), "Runtime flight actuator was saved")
		check(not object.Name:match("^HuntItems_") and object.Name ~= "HuntQuestInstall", "Runtime hunt items or source installer were saved")
	end
	report.map = {width = 4000, depth = 4500, trees = trees, zones = 9, paths = 16}
	report.dinosaur = rig
end
local ok, err = xpcall(main, debug.traceback)
report.validation = if ok then "passed" else "failed"
report.checksPassed = checks
if not ok then report.error = tostring(err) end
fs.writeFile(reportPath, serde.encode("json", report, true))
print(serde.encode("json", report, true))
assert(ok, "Saved inventory items validation failed; see " .. reportPath .. "\n" .. tostring(err))
