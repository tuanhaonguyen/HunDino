-- Read-only validation for the combined hub and hunting place.
-- Run in Studio Edit or Server. This reports observations and never repairs
-- Instances, changes player state, starts patrols, writes Terrain, or saves files.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local offset = Vector3.new(0, 0, 6500)
local report = {
	version = "ConnectedHuntValidation.1",
	context = if RunService:IsRunning() then "Server" else "Edit",
	ok = false, checks = 0, passed = 0, failures = {}, warnings = {},
	zones = {}, paths = {}, portals = {}, players = {}, terrain = {probes = {}},
}
local function check(ok, code, detail)
	report.checks += 1
	if ok then report.passed += 1 else table.insert(report.failures, {code = code, detail = detail}) end
	return ok
end
local function warning(code, detail) table.insert(report.warnings, {code = code, detail = detail}) end
local function rounded(n) return math.floor(n * 1000 + .5) / 1000 end
local function point(v) return {x = rounded(v.X), y = rounded(v.Y), z = rounded(v.Z)} end
local function near(a, b, tolerance) return typeof(a) == "Vector3" and (a - b).Magnitude <= (tolerance or .1) end
local function get(root, path)
	local found = root
	for name in path:gmatch("[^.]+") do found = found and found:FindFirstChild(name) end
	return found
end
local forest = workspace:FindFirstChild("HuntingRainforest")
local hub = workspace:FindFirstChild("HunDinoL0")
if not check(forest and hub, "BOTH_MAPS", "Expected Workspace.HunDinoL0 and Workspace.HuntingRainforest") then return report end

-- The adapter must translate query coordinates too; moving physical parts alone
-- leaves dinosaur routes and terrain queries pointing back at the lobby.
local adapter = ReplicatedStorage:FindFirstChild("HuntingMapConfig")
local baseModule = ReplicatedStorage:FindFirstChild("HuntingBaseConfig")
local okConfig, config = pcall(function() return require(adapter) end)
local okBase, base = pcall(function() return require(baseModule) end)
if not check(okConfig and okBase and type(config) == "table" and type(base) == "table", "CONFIG_MODULES", "Require HuntingMapConfig adapter and HuntingBaseConfig") then return report end
check(near(config.WorldOffset, offset), "CONFIG_OFFSET", "WorldOffset must be (0,0,6500)")
check(near(forest:GetAttribute("WorldOffset"), offset), "FOREST_OFFSET_TAG", "Forest.WorldOffset must match the adapter")
check(forest:GetAttribute("HubConnected") == true, "HUB_CONNECTION_TAG", "Forest.HubConnected must declare the completed integration")
check(config.TimeScale == 30, "CLOCK_SCALE", "Expected 2 real minutes = 1 hunting hour")
check(config.TimezoneOffsetMinutes == 420, "CLOCK_TIMEZONE", "Expected UTC+7 entry clock")
for _, q in base.Zones do
	check(near(config.position(config.zone(q.id)), base.position(q) + offset), "ZONE_ADAPTER", q.id .. " adapter position is not translated")
end
for _, localProbe in {Vector3.new(0, 0, 0), Vector3.new(-400, 0, 100), Vector3.new(350, 0, -420)} do
	local expected = base.height(localProbe.X, localProbe.Z) + offset.Y
	check(math.abs(config.height(localProbe.X + offset.X, localProbe.Z + offset.Z) - expected) <= .01, "HEIGHT_ADAPTER", "height() must convert world coordinates to local forest coordinates")
	local oldHeight = base.terrainHeight(localProbe.X, localProbe.Z)
	local newHeight = config.terrainHeight(localProbe.X + offset.X, localProbe.Z + offset.Z)
	check(math.abs(newHeight - oldHeight - offset.Y) <= .01, "TERRAIN_ADAPTER", "terrainHeight() must convert world coordinates")
end

-- Record the native Terrain import declaration and verify real voxels separately.
local importSize = forest:GetAttribute("TerrainImportSize")
local sizeType = typeof(importSize)
if sizeType == "Vector3" or sizeType == "Vector3int16" then
	report.terrain.importSize = point(importSize)
	-- Size may be stored in studs or 4-stud Terrain cells. Both describe the
	-- same native CopyRegion/PasteRegion range: 1632 x 176 x 1632 studs.
	local studs = Vector3.new(importSize.X, importSize.Y, importSize.Z)
	check(near(studs, Vector3.new(1632, 176, 1632)) or near(studs * 4, Vector3.new(1632, 176, 1632)), "TERRAIN_IMPORT_SIZE", "Expected source Terrain bounds -816..816, -48..128")
else
	check(false, "TERRAIN_IMPORT_SIZE", "Expected TerrainImportSize Vector3 or Vector3int16 attribute")
end
local terrainParams = RaycastParams.new()
terrainParams.FilterType = Enum.RaycastFilterType.Include
terrainParams.FilterDescendantsInstances = {workspace.Terrain}
terrainParams.IgnoreWater = true
local physicalParams = RaycastParams.new()
physicalParams.FilterType = Enum.RaycastFilterType.Include
physicalParams.FilterDescendantsInstances = {workspace.Terrain, forest.Paths, forest.Zones, forest.Camp}
physicalParams.IgnoreWater = true
physicalParams.RespectCanCollide = true
local function ground(p, params)
	return workspace:Raycast(p + Vector3.new(0, 80, 0), Vector3.new(0, -200, 0), params)
end
local zoneCount, campCount = 0, 0
for _, q in config.Zones do
	local model = get(forest, "Zones." .. q.id)
	local node = model and model:FindFirstChild("Node")
	if check(node and node:IsA("BasePart"), "ZONE_NODE", q.id .. " needs a physical location marker") then
		local expected = config.position(q)
		check(near(node.Position, expected, .2), "MOVED_ZONE", q.id .. " node must match translated config position")
		local voxelHit = ground(expected, terrainParams)
		local physicalHit = ground(expected, physicalParams)
		check(voxelHit ~= nil and math.abs(voxelHit.Position.Y - expected.Y) <= 8, "IMPORTED_ZONE_TERRAIN", q.id .. " expected solid Terrain at transferred height")
		check(physicalHit ~= nil and math.abs(physicalHit.Position.Y - expected.Y) <= 8, "ZONE_GROUND", q.id .. " expected walkable ground")
		table.insert(report.zones, {id = q.id, node = point(node.Position), terrainY = if voxelHit then rounded(voxelHit.Position.Y) else nil, groundY = if physicalHit then rounded(physicalHit.Position.Y) else nil})
	end
	if q.kind == "Camp" then campCount += 1 else zoneCount += 1 end
end
check(zoneCount == 8 and campCount == 1, "ZONE_COUNTS", "Expected 8 animal zones and 1 camp")
for i, localProbe in {Vector3.new(-700, 40, -650), Vector3.new(680, 30, 650), Vector3.new(0, 10, 0)} do
	local p = localProbe + offset
	local hit = ground(p, terrainParams)
	check(hit ~= nil, "IMPORTED_TERRAIN_PROBE", "Missing native Terrain at remote sample " .. i)
	table.insert(report.terrain.probes, {probe = point(p), groundY = if hit then rounded(hit.Position.Y) else nil})
end

local roadCount, humanCount, surfaceCount = 0, 0, 0
local function road(edge, humanOnly)
	local name = edge.a .. "_" .. edge.b
	local path = get(forest, "Paths." .. name)
	if not check(path and path:IsA("Model"), "PATH_MODEL", name) then return end
	if humanOnly then humanCount += 1 else roadCount += 1 end
	check(path:GetAttribute("FromZone") == edge.a and path:GetAttribute("ToZone") == edge.b and path:GetAttribute("Bidirectional") == true, "PATH_GRAPH", name .. " graph attributes")
	local samples = config.samples(edge, 12)
	local originals = base.samples(edge, 12)
	check(#samples == #originals, "PATH_SAMPLE_COUNT", name .. " adapter changed path sampling")
	local adapterErrors = 0
	for i, p in samples do if not originals[i] or not near(p, originals[i] + offset, .01) then adapterErrors += 1 end end
	check(adapterErrors == 0, "PATH_SAMPLE_ADAPTER", name .. " has " .. adapterErrors .. " unshifted generated samples")
	local surfaces = {}
	for _, p in path:GetDescendants() do if p:IsA("BasePart") and p.Name == "WalkSurface" then table.insert(surfaces, p) end end
	table.sort(surfaces, function(a, b) return (a:GetAttribute("SampleIndex") or 0) < (b:GetAttribute("SampleIndex") or 0) end)
	check(#surfaces == #samples - 1, "PATH_SURFACE_COUNT", name .. " physical path count must match configured samples")
	local attributeErrors, geometryErrors = 0, 0
	for _, p in surfaces do
		surfaceCount += 1
		local i, a, b = p:GetAttribute("SampleIndex"), p:GetAttribute("RouteStart"), p:GetAttribute("RouteEnd")
		if type(i) ~= "number" or typeof(a) ~= "Vector3" or typeof(b) ~= "Vector3" or not samples[i] or not samples[i + 1] then
			attributeErrors += 1
		else
			-- Builder's declared route samples sit 2.2 studs above terrain.
			local rise = Vector3.new(0, 2.2, 0)
			if not near(a, samples[i] + rise, .2) or not near(b, samples[i + 1] + rise, .2) then attributeErrors += 1 end
			local top = p.CFrame:PointToWorldSpace(Vector3.new(0, p.Size.Y * .5, 0))
			if not near(top, a:Lerp(b, .5), 1.5) or a.Z < 5500 or b.Z < 5500 then geometryErrors += 1 end
		end
	end
	check(attributeErrors == 0, "TRANSLATED_ROUTE_ATTRIBUTES", name .. " has " .. attributeErrors .. " route attribute mismatches")
	check(geometryErrors == 0, "TRANSLATED_ROUTE_GEOMETRY", name .. " has " .. geometryErrors .. " physical/attribute mismatches")
	table.insert(report.paths, {name = name, segments = #surfaces, adapterErrors = adapterErrors, attributeErrors = attributeErrors, geometryErrors = geometryErrors})
	task.wait()
end
for _, edge in config.Edges do road(edge, false) end
for _, edge in config.HumanPaths do road(edge, true) end
check(roadCount == 13 and humanCount == 2 and surfaceCount > 100, "CORRIDOR_COUNTS", "Expected all 13 animal and 2 player corridors")
report.surfaceCount = surfaceCount

-- Hub coordinates are intentionally frozen to the user's existing saved place.
for _, item in {{"Lobby.Arrival", Vector3.new(0, 23, 181)}, {"Lobby.LobbySpawn", Vector3.new(0, 20, 181)}, {"Training.Arrival", Vector3.new(2086, 39, 160)}} do
	local p = get(hub, item[1])
	check(p and p:IsA("BasePart") and near(p.Position, item[2]), "ORIGINAL_HUB_LOCATION", item[1] .. " must remain in its original position")
end
check(get(hub, "Training.Dummies") and #hub.Training.Dummies:GetChildren() == 7, "TRAINING_DUMMIES", "Preserve seven existing targets")
local bases = get(workspace, "DarkJungle.Bases")
check(bases and #bases:GetChildren() == 12, "ORIGINAL_BASES", "Preserve all twelve player bases")
check(get(hub, "Lobby.ToTraining") and get(hub, "Training.ToLobby"), "ORIGINAL_TRAINING_GATES", "Preserve both original training gates")
local enabledSpawns = {}
for _, p in workspace:GetDescendants() do if p:IsA("SpawnLocation") and p.Enabled then table.insert(enabledSpawns, p:GetFullName()) end end
check(#enabledSpawns == 1 and enabledSpawns[1] == "Workspace.HunDinoL0.Lobby.LobbySpawn", "LOBBY_ONLY_SPAWN", table.concat(enabledSpawns, ", "))
report.enabledSpawns = enabledSpawns
local campSpawn = get(forest, "Camp.CampSpawn")
check(campSpawn and campSpawn:IsA("SpawnLocation") and not campSpawn.Enabled, "HUNT_SPAWN_DISABLED", "Visits must begin through server-owned travel, respawn at hub")

local function portal(parent, path, expectedOffset)
	local root = get(parent, path)
	local prompt = root and root:FindFirstChildWhichIsA("ProximityPrompt", true)
	check(root ~= nil and prompt ~= nil, "HUNT_PORTAL", path .. " needs a ProximityPrompt")
	if not prompt then return end
	check(prompt.Enabled and prompt.KeyboardKeyCode == Enum.KeyCode.G and prompt.MaxActivationDistance >= 8 and prompt.MaxActivationDistance <= 15, "PORTAL_INTERACTION", path .. " needs an enabled reachable G prompt")
	local anchor = if prompt.Parent:IsA("BasePart") then prompt.Parent else prompt.Parent.Parent
	if anchor and anchor:IsA("BasePart") then
		check((anchor.Position - expectedOffset).Magnitude < 600, "PORTAL_LOCATION", path .. " must be near its source arrival")
		table.insert(report.portals, {path = root:GetFullName(), prompt = prompt:GetFullName(), position = point(anchor.Position)})
	end
end
portal(hub, "HuntingTransit.ToHunting", Vector3.new(0, 23, 181))
portal(forest, "Camp.ReturnToLobby", config.position(config.zone("Camp")))

local dinosaur = workspace:FindFirstChild("Dinosaur01_TRex_Visual")
check(dinosaur and dinosaur:IsA("Model"), "PROTOTYPE_PRESENT", "Preserve existing dinosaur prototype")
if dinosaur then
	check(dinosaur:GetPivot().Position.Z > 5500, "PROTOTYPE_TRANSFERRED", "Dinosaur must be inside the transferred forest")
	local motion = dinosaur:FindFirstChild("MotionRuntime")
	check(motion and motion.Disabled, "OLD_CIRCLE_MOTION_DISABLED", "Route controller owns dinosaur motion")
end
local oldScripts = {}
for _, container in {ServerScriptService, StarterPlayer, workspace, game:GetService("StarterGui")} do
	for _, script in container:GetDescendants() do
		if script:IsA("Script") or script:IsA("LocalScript") then
			local name = script.Name
			if not script.Disabled and (name == "HuntingMapRuntime" or name == "HuntingMapViewer" or name == "DinosaurPreviewControls" or name == "DinosaurPreviewBridge") then table.insert(oldScripts, script:GetFullName()) end
		end
	end
end
check(#oldScripts == 0, "NO_STANDALONE_RUNTIME", table.concat(oldScripts, ", "))
local trainingRuntime = ServerScriptService:FindFirstChild("HunDinoTraining")
check(trainingRuntime ~= nil, "ORIGINAL_SERVER_RUNTIME", "Keep original equipment, pet, movement and combat runtime")
if ReplicatedStorage:FindFirstChild("HuntingMapPreviewJump") then
	-- The combined place intentionally retains Studio-only M jumps. They are
	-- handled by the integrated runtime rather than the old standalone viewer.
	local source = trainingRuntime and trainingRuntime.Source or ""
	check(source:find("previewRemote.OnServerEvent", 1, true) ~= nil and source:find("not RunService:IsStudio()", 1, true) ~= nil
		and source:find("not s.InHunting", 1, true) ~= nil, "STUDIO_PREVIEW_GUARD", "A preview remote requires Studio and active-visit guards in the integrated runtime")
end

if RunService:IsRunning() then
	local inHunting = 0
	for _, player in Players:GetPlayers() do
		local active = player:GetAttribute("InHunting") == true
		if active then inHunting += 1 end
		local row = {name = player.Name, inHunting = active, baseId = player:GetAttribute("BaseId"), entryClockHours = player:GetAttribute("HuntEntryClockHours"), huntStartedAt = player:GetAttribute("HuntStartedAt"), huntTimeScale = player:GetAttribute("HuntTimeScale")}
		if active then
			check(type(row.huntStartedAt) == "number" and type(row.entryClockHours) == "number" and row.entryClockHours >= 0 and row.entryClockHours < 24 and row.huntTimeScale == 30, "PLAYER_VISIT_CLOCK", player.Name .. " active hunt needs valid server-owned time attributes")
		else
			check(row.huntStartedAt == nil and row.entryClockHours == nil, "PLAYER_VISIT_CLEANUP", player.Name .. " outside hunt must not retain visit clock")
		end
		table.insert(report.players, row)
	end
	check(forest:GetAttribute("ActiveHunters") == inHunting, "ACTIVE_HUNTERS", "Forest count must equal players with InHunting=true")
	warning("RUNTIME_LIMIT", "This snapshot does not simulate entry, exit, timer expiry, death, gear preservation or per-client Lighting restoration; exercise those in Play.")
end
report.ok = #report.failures == 0
return report
