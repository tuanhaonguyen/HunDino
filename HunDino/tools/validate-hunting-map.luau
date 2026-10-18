-- Read-only Studio validation. Paste into execute_luau (Edit or Server context).
-- Reports observations; never repairs, moves, enables or creates Instances.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local report = {
	version = "HuntingMapValidation.1", context = if RunService:IsRunning() then "Server" else "Edit",
	ok = false, counts = {checks = 0, passed = 0, failed = 0, warnings = 0},
	failures = {}, warnings = {}, paths = {}, routes = {}, dinosaur = {},
}
local function check(ok, code, detail)
	report.counts.checks += 1
	if ok then report.counts.passed += 1 else
		report.counts.failed += 1
		table.insert(report.failures, {code = code, detail = detail})
	end
	return ok
end
local function warnOnly(code, detail)
	report.counts.warnings += 1
	table.insert(report.warnings, {code = code, detail = detail})
end
local function round(n)
	return math.floor(n * 100 + 0.5) / 100
end
local function position(p)
	return {x = round(p.X), y = round(p.Y), z = round(p.Z)}
end
local function planarDistance(a, b)
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end
local root = workspace:FindFirstChild("HuntingRainforest")
if not check(root ~= nil, "MAP_MISSING", "Expected workspace.HuntingRainforest") then return report end
local configModule = ReplicatedStorage:FindFirstChild("HuntingMapConfig", true)
	or root:FindFirstChild("HuntingMapConfig", true)
if not check(configModule ~= nil and configModule:IsA("ModuleScript"), "CONFIG_MISSING", "Install HuntingMapConfig ModuleScript in ReplicatedStorage") then return report end
local configOK, config = pcall(require, configModule)
if not check(configOK and type(config) == "table", "CONFIG_LOAD", tostring(if configOK then "Module must return a table" else config)) then return report end
local zones = root:FindFirstChild("Zones")
local paths = root:FindFirstChild("Paths")
if not check(zones ~= nil and paths ~= nil, "MAP_FOLDERS", "Map needs Zones and Paths folders") then return report end
local decor = root:FindFirstChild("Decor")
check(decor ~= nil, "DECOR_FOLDER", "Expected HuntingRainforest.Decor for obstruction checks")
check(config.RoadWidth == 72, "MAIN_ROAD_CONFIG_WIDTH", "Main corridors must be 72 studs wide")

local expectedZones, actualNodes, adjacency, actualModels = {}, {}, {}, {}
for _, zone in config.Zones do expectedZones[zone.id] = zone end
local animals, camps = 0, 0
for _, model in zones:GetChildren() do
	if model:IsA("Model") then
		actualModels[model.Name] = model
		local expected = expectedZones[model.Name]
		check(expected ~= nil, "UNEXPECTED_ZONE", model.Name)
		if expected then
			if expected.kind == "Camp" then camps += 1 else animals += 1 end
			check(model:GetAttribute("Kind") == expected.kind, "ZONE_KIND", model.Name .. " expected " .. expected.kind)
			check(type(model:GetAttribute("Width")) == "number" and model:GetAttribute("Width") > 0, "ZONE_WIDTH", model.Name .. " needs a positive Width attribute")
			local node = model:FindFirstChild("Node")
			if check(node ~= nil and node:IsA("BasePart"), "ZONE_NODE", model.Name .. " needs Node BasePart") then
				actualNodes[model.Name] = node
				adjacency[model.Name] = {}
				check(node.Anchored and not node.CanCollide and node.Transparency >= 0.99, "ZONE_NODE_STATE", model.Name .. " Node must be anchored, invisible and non-colliding")
				check(planarDistance(node.Position, config.position(expected)) <= 2, "ZONE_LOCATION", model.Name .. " Node differs from approved layout")
			end
		end
	end
end
for id in expectedZones do check(actualModels[id] ~= nil, "ZONE_MISSING", id) end
report.counts.animalZones, report.counts.camps = animals, camps
check(animals == 8 and camps == 1, "ZONE_COUNTS", "Expected 8 animal zones and 1 Camp; got " .. animals .. " and " .. camps)

-- Ground query includes physical Terrain and the constructed roads. Water and
-- non-colliding markers/leaves cannot stand in for a walkable surface.
local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Include
groundParams.FilterDescendantsInstances = {workspace.Terrain, paths}
groundParams.IgnoreWater = true
groundParams.RespectCanCollide = true
local obstacleParams = OverlapParams.new()
obstacleParams.FilterType = Enum.RaycastFilterType.Include
obstacleParams.FilterDescendantsInstances = if decor then {decor} else {}
obstacleParams.RespectCanCollide = true
obstacleParams.MaxParts = 0
local function groundRay(point)
	return workspace:Raycast(point + Vector3.new(0, 48, 0), Vector3.new(0, -168, 0), groundParams)
end
local function pathKey(a, b) return a .. "_" .. b end
local expectedPaths, mainCount, humanCount = {}, 0, 0
local groundSampleCount, obstructionQueries = 0, 0
local allDecorObstacles = {}

local function validatePath(edge, humanOnly)
	local key = (if humanOnly then "Camp_" else "") .. pathKey(edge.a, edge.b)
	-- Human path builders may use Camp_R1 rather than Camp_Camp_R1.
	local model = paths:FindFirstChild(key)
	if humanOnly and not model then key = pathKey(edge.a, edge.b); model = paths:FindFirstChild(key) end
	expectedPaths[key] = true
	if not check(model ~= nil and model:IsA("Model"), "PATH_MISSING", key) then return end
	if humanOnly then humanCount += 1 else mainCount += 1 end
	local pathReport = {name = key, humanOnly = humanOnly, segments = 0, samples = 0, missingGround = 0,
		groundHeightErrors = 0, maxSurfaceSlopeDegrees = 0, maxGroundSlopeDegrees = 0,
		decorObstacles = {}, obstructionSampleCount = 0, terrainHits = 0, roadHits = 0}
	table.insert(report.paths, pathReport)
	local from = model:GetAttribute("FromZone")
	local to = model:GetAttribute("ToZone")
	local bidirectional = model:GetAttribute("Bidirectional")
	check(from == edge.a and to == edge.b and bidirectional == true, "PATH_GRAPH_ATTRIBUTES", key .. " FromZone/ToZone/Bidirectional do not match the approved graph")
	if adjacency[from] and adjacency[to] and bidirectional == true then
		adjacency[from][to] = true; adjacency[to][from] = true
	end
	local width = model:GetAttribute("WalkWidth")
	check(type(width) == "number" and (if humanOnly then width >= 20 else math.abs(width - 72) <= 0.1), "PATH_WIDTH", key .. " WalkWidth=" .. tostring(width))
	if humanOnly then check(model:GetAttribute("HumanOnly") == true, "HUMAN_PATH_MARKER", key .. " needs HumanOnly=true") end
	local segments = {}
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part.Name == "WalkSurface" then table.insert(segments, part) end
	end
	table.sort(segments, function(a, b)
		local ai, bi = a:GetAttribute("SampleIndex"), b:GetAttribute("SampleIndex")
		if type(ai) ~= "number" then ai = math.huge end
		if type(bi) ~= "number" then bi = math.huge end
		return ai < bi
	end)
	pathReport.segments = #segments
	if not check(#segments > 0, "PATH_SURFACES", key .. " has no WalkSurface parts") then return end
	local previousEnd, previousIndex = nil, nil
	local missingAttributes, invalidGeometry, invalidStates, continuityErrors = 0, 0, 0, 0
	local expectedOffsets = if humanOnly then {0, -7, 7} else {0, -20, 20}
	local obstacleSet, badGroundExamples = {}, {}
	for _, part in segments do
		local start = part:GetAttribute("RouteStart")
		local finish = part:GetAttribute("RouteEnd")
		local index = part:GetAttribute("SampleIndex")
		local segmentWidth = part:GetAttribute("WalkWidth")
		if not part.Anchored or not part.CanCollide or not part.CanQuery then invalidStates += 1 end
		if typeof(start) ~= "Vector3" or typeof(finish) ~= "Vector3" or type(index) ~= "number" then
			missingAttributes += 1
			continue
		end
		if previousIndex and index <= previousIndex then continuityErrors += 1 end
		if previousEnd and (start - previousEnd).Magnitude > 2 then continuityErrors += 1 end
		if not previousEnd and actualNodes[edge.a] and planarDistance(start, actualNodes[edge.a].Position) > 4 then continuityErrors += 1 end
		previousIndex, previousEnd = index, finish
		local delta = finish - start
		local flat = Vector3.new(delta.X, 0, delta.Z)
		if flat.Magnitude < 0.01 then invalidGeometry += 1; continue end
		local lateral = Vector3.new(-flat.Z, 0, flat.X).Unit
		local top = part.CFrame:PointToWorldSpace(Vector3.new(0, part.Size.Y * 0.5, 0))
		local slope = math.deg(math.acos(math.clamp(part.CFrame.UpVector.Y, -1, 1)))
		pathReport.maxSurfaceSlopeDegrees = math.max(pathReport.maxSurfaceSlopeDegrees, slope)
		if (top - start:Lerp(finish, 0.5)).Magnitude > 1.5
			or math.abs(part.CFrame.LookVector:Dot(delta.Unit)) < 0.99
			or part.Size.Z < delta.Magnitude - 0.25
			or part.Size.X < (if humanOnly then 20 else 71.9)
			or type(segmentWidth) ~= "number"
			or (not humanOnly and math.abs(segmentWidth - 72) > 0.1) then invalidGeometry += 1 end
		local subdivisions = math.max(1, math.ceil(flat.Magnitude / 12))
		local lastGroundByOffset = {}
		for sample = 0, subdivisions do
			local point = start:Lerp(finish, sample / subdivisions)
			local centerGround
			for _, offset in expectedOffsets do
				local testPoint = point + lateral * offset
				local hit = groundRay(testPoint)
				pathReport.samples += 1; groundSampleCount += 1
				if not hit then
					pathReport.missingGround += 1
					if #badGroundExamples < 5 then table.insert(badGroundExamples, position(testPoint)) end
				else
					if hit.Instance == workspace.Terrain then pathReport.terrainHits += 1 else pathReport.roadHits += 1 end
					if offset == 0 then centerGround = hit.Position end
					if math.abs(hit.Position.Y - testPoint.Y) > 3.5 then
						pathReport.groundHeightErrors += 1
						if #badGroundExamples < 5 then table.insert(badGroundExamples, position(hit.Position)) end
					end
					local last = lastGroundByOffset[offset]
					if last then
						local distance = planarDistance(last, hit.Position)
						if distance > 0.1 then
							pathReport.maxGroundSlopeDegrees = math.max(pathReport.maxGroundSlopeDegrees, math.deg(math.atan(math.abs(last.Y - hit.Position.Y) / distance)))
						end
					end
					lastGroundByOffset[offset] = hit.Position
				end
			end
			-- A 40-stud wide, 50-stud tall corridor checks the prototype's
			-- movement space. Only colliding Decor is queried.
			if decor and centerGround and not humanOnly then
				local center = centerGround + Vector3.new(0, 26, 0)
				local bounds = CFrame.lookAt(center, center + flat.Unit)
				local obstacles = workspace:GetPartBoundsInBox(bounds, Vector3.new(40, 50, 3), obstacleParams)
				obstructionQueries += 1
				if #obstacles > 0 then pathReport.obstructionSampleCount += 1 end
				for _, obstacle in obstacles do
					if obstacle.CanCollide then
						obstacleSet[obstacle:GetFullName()] = true
						allDecorObstacles[obstacle:GetFullName()] = true
					end
				end
			end
		end
	end
	if previousEnd and actualNodes[edge.b] and planarDistance(previousEnd, actualNodes[edge.b].Position) > 4 then continuityErrors += 1 end
	check(missingAttributes == 0, "SURFACE_ATTRIBUTES", key .. ": " .. missingAttributes .. " segments missing RouteStart/RouteEnd/SampleIndex")
	check(invalidStates == 0, "SURFACE_PHYSICS", key .. ": " .. invalidStates .. " surfaces need Anchored/CanCollide/CanQuery=true")
	check(invalidGeometry == 0, "SURFACE_GEOMETRY", key .. ": " .. invalidGeometry .. " physical parts do not match their declared centerline/width")
	check(continuityErrors == 0, "PATH_CONTINUITY", key .. ": " .. continuityErrors .. " ordering, gap or endpoint issues")
	check(pathReport.missingGround == 0 and pathReport.groundHeightErrors == 0, "PATH_GROUND", key .. ": " .. pathReport.missingGround .. " holes and " .. pathReport.groundHeightErrors .. " surface-height mismatches")
	check(pathReport.maxSurfaceSlopeDegrees <= 24.1, "PATH_SURFACE_SLOPE", key .. " maximum actual part slope=" .. round(pathReport.maxSurfaceSlopeDegrees) .. " degrees (limit 24)")
	check(pathReport.maxGroundSlopeDegrees <= 25, "PATH_GROUND_SLOPE", key .. " maximum sampled ground slope=" .. round(pathReport.maxGroundSlopeDegrees) .. " degrees (limit 24 plus 1-degree query tolerance)")
	for name in obstacleSet do table.insert(pathReport.decorObstacles, name) end
	table.sort(pathReport.decorObstacles)
	check(#pathReport.decorObstacles == 0, "DECOR_IN_CORRIDOR", key .. ": " .. #pathReport.decorObstacles .. " colliding Decor parts in 40x50-stud center corridor")
	if #badGroundExamples > 0 then pathReport.groundExamples = badGroundExamples end
	pathReport.maxSurfaceSlopeDegrees = round(pathReport.maxSurfaceSlopeDegrees)
	pathReport.maxGroundSlopeDegrees = round(pathReport.maxGroundSlopeDegrees)
	task.wait() -- Yield between routes in Studio's command execution budget.
end
for _, edge in config.Edges do validatePath(edge, false) end
for _, edge in config.HumanPaths do validatePath(edge, true) end
report.counts.mainPaths, report.counts.humanPaths = mainCount, humanCount
report.counts.groundSamples, report.counts.obstructionQueries = groundSampleCount, obstructionQueries
check(mainCount == 13 and humanCount == 2, "PATH_COUNTS", "Expected 13 animal corridors and 2 human corridors")
for _, child in paths:GetChildren() do
	if child:IsA("Model") and not expectedPaths[child.Name] then warnOnly("EXTRA_PATH", child:GetFullName()) end
end

-- Traverse the graph read from actual Models, then test all approved itinerary
-- legs in forward AND reverse order. Config alone cannot make a missing road pass.
local seen, queue, cursor = {A = true}, {"A"}, 1
while cursor <= #queue do
	local id = queue[cursor]; cursor += 1
	for neighbor in adjacency[id] or {} do
		if not seen[neighbor] then seen[neighbor] = true; table.insert(queue, neighbor) end
	end
end
local unreachable = {}
for id in expectedZones do if not seen[id] then table.insert(unreachable, id) end end
table.sort(unreachable)
check(#unreachable == 0, "GRAPH_CONNECTED", "Unreachable from A: " .. table.concat(unreachable, ", "))
local routeCount, reverseCount = 0, 0
for home, routes in config.Routes do
	for index, route in routes do
		routeCount += 1
		local item = {home = home, route = index, forward = true, reverse = true, missingLegs = {}}
		check(route[1] == home and route[#route] == home, "ROUTE_HOME", home .. " route " .. index .. " must begin and end at home")
		for step = 1, #route - 1 do
			local a, b = route[step], route[step + 1]
			if not (adjacency[a] and adjacency[a][b]) then
				item.forward = false; table.insert(item.missingLegs, a .. " -> " .. b)
			end
			if not (adjacency[b] and adjacency[b][a]) then
				item.reverse = false; table.insert(item.missingLegs, b .. " -> " .. a)
			end
		end
		if item.reverse then reverseCount += 1 end
		check(item.forward and item.reverse, "ROUTE_TRAVERSABLE", home .. " route " .. index .. ": " .. table.concat(item.missingLegs, ", "))
		table.insert(report.routes, item)
	end
end
report.counts.routes, report.counts.reverseRoutes = routeCount, reverseCount
check(routeCount == 9 and reverseCount == 9, "ROUTE_COUNTS", "Expected 9 forward and 9 reverse itineraries")

for id, node in actualNodes do
	local hit = groundRay(node.Position)
	check(hit ~= nil, "ZONE_GROUND", id .. " Node has no physical ground")
	if hit and math.abs(hit.Position.Y - node.Position.Y) > 6 then
		warnOnly("ZONE_GROUND_HEIGHT", id .. " Node differs from physical ground by " .. round(hit.Position.Y - node.Position.Y) .. " studs")
	end
end

local dinosaur = workspace:FindFirstChild("Dinosaur01_TRex_Visual")
if check(dinosaur ~= nil and dinosaur:IsA("Model"), "DINOSAUR_MISSING", "Existing dinosaur must remain top-level in Workspace") then
	local dinoReport = {parts = 0, motors = 0, welds = 0, anchoredParts = 0, unboundJoints = 0}
	report.dinosaur = dinoReport
	for _, descendant in dinosaur:GetDescendants() do
		if descendant:IsA("BasePart") then
			dinoReport.parts += 1
			if descendant.Anchored then dinoReport.anchoredParts += 1 end
		elseif descendant:IsA("Motor6D") then
			dinoReport.motors += 1
			if not descendant.Part0 or not descendant.Part1 then dinoReport.unboundJoints += 1 end
		elseif descendant:IsA("WeldConstraint") or descendant:IsA("Weld") then
			dinoReport.welds += 1
			if not descendant.Part0 or not descendant.Part1 then dinoReport.unboundJoints += 1 end
		end
	end
	check(dinoReport.parts == 255 and dinoReport.motors == 7 and dinoReport.welds == 247, "DINOSAUR_PRESERVED", "Expected 255 parts, 7 Motor6Ds and 247 welds; got " .. dinoReport.parts .. "/" .. dinoReport.motors .. "/" .. dinoReport.welds)
	check(dinoReport.anchoredParts == 1 and dinoReport.unboundJoints == 0, "DINOSAUR_RIG", "Expected one anchor and no unbound joints")
	if actualNodes.A then
		local pivot = dinosaur:GetPivot().Position
		dinoReport.position = position(pivot)
		dinoReport.distanceFromA = round(planarDistance(pivot, actualNodes.A.Position))
		if not RunService:IsRunning() then
			check(dinoReport.distanceFromA <= 35, "DINOSAUR_AT_A", "Saved dinosaur pivot is " .. dinoReport.distanceFromA .. " studs from A")
		end
	end
	check(dinosaur:GetAttribute("PreviewWalking") ~= true, "DINOSAUR_PREVIEW_WALK", "Legacy circular preview must remain disabled")
	if root:GetAttribute("RouteAIReady") then
		local runtime = game:GetService("ServerScriptService"):FindFirstChild("HuntingRuntime")
		check(runtime and runtime:FindFirstChild("DinosaurRouteController") ~= nil, "ROUTE_CONTROLLER", "Route controller must be installed")
		local legacy = dinosaur:FindFirstChild("MotionRuntime")
		check(legacy and legacy.Disabled, "LEGACY_MOTION_DISABLED", "Only the hunting route controller may move the root")
		check(dinosaur:GetAttribute("RouteEnabled") == true, "ROUTE_ENABLED", "Prototype route movement should start in Play")
	end
end
local conflictingControls = {}
for _, container in {game:GetService("ServerScriptService"), game:GetService("StarterPlayer"), game:GetService("StarterGui"), workspace} do
	for _, descendant in container:GetDescendants() do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			local name = string.lower(descendant.Name)
			if (name:find("previewbridge", 1, true) or name:find("previewcontrols", 1, true)) and not descendant.Disabled then
				table.insert(conflictingControls, descendant:GetFullName())
			end
		end
	end
end
report.conflictingPreviewScripts = conflictingControls
check(#conflictingControls == 0, "PREVIEW_CONTROLS_DISABLED", table.concat(conflictingControls, ", "))
if RunService:IsRunning() then
	warnOnly("SERVER_SNAPSHOT", "Server report describes this play session; also validate the saved Edit datamodel")
end
report.ok = report.counts.failed == 0
return report
