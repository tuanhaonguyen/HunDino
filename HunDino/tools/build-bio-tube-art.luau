-- Read the native baseline without rewriting it. Serialize ONLY the new static
-- art model; Rojo/native Studio are responsible for installing and saving it.
-- Run from HunDino: tools/lune/lune.exe run tools/build-bio-tube-art.luau [baseline.rbxl]
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local serde = require("@lune/serde")

local baselinePath = process.args[1] or "backups/Hub_v24_before_5_specimen_tubes_20261021.rbxl"
local outputPath = "assets/hunting/BioTubeDisplays.rbxm"
local baselineBytes = fs.readFile(baselinePath)
local baseline = roblox.deserializePlace(baselineBytes)
local source = fs.readFile("src/hunting/BioTubeGeometry.luau")
luau.compile(source)
local environment = {}
for _, name in {"Instance", "Vector3", "Vector2", "CFrame", "Color3", "Enum", "UDim2",
	"ColorSequence", "NumberSequence", "NumberSequenceKeypoint", "NumberRange"} do
	environment[name] = roblox[name]
end
local Geometry = luau.load(source, {environment = environment, injectGlobals = true})()
local V, CF = roblox.Vector3, roblox.CFrame
local offsets = {[1] = V.new(-28, 0, -10), [2] = V.new(-15, 0, 0),
	[3] = V.new(15, 0, 0), [4] = V.new(28, 0, -10), [5] = V.new(0, 0, 5)}
local angles = {[1] = 22, [2] = 11, [3] = -11, [4] = -22, [5] = 0}
local world = roblox.Instance.new("Folder")
world.Name = "SpecimenTubeDisplays"
world:SetAttribute("GeometryVersion", Geometry.Version)
world:SetAttribute("LayoutVersion", Geometry.LayoutVersion)
world:SetAttribute("SystemVersion", "P1-F.2")
local bases = assert(baseline:GetService("Workspace"):FindFirstChild("DarkJungle"), "DarkJungle missing"):FindFirstChild("Bases")
assert(bases, "Original DarkJungle.Bases missing")
local partCount, tubeCount = 0, 0
for id = 1, 12 do
	local base = assert(bases:FindFirstChild("Base" .. id), "Missing base " .. id)
	local spawn = assert(base:FindFirstChild("SpawnPad"), "Missing SpawnPad " .. id)
	local shelter = assert(base:FindFirstChild("ShelterFloor"), "Missing ShelterFloor " .. id)
	-- Lune reads the authored CFrame directly; Roblox's computed Position
	-- property is not populated on deserialized instances in this runtime.
	local spawnPosition, shelterPosition = spawn.CFrame.Position, shelter.CFrame.Position
	local layout = Geometry.ClusterLayout[id]
	local origin = Geometry.clusterFrame(spawnPosition, shelterPosition, id)
	local inverseYaw=CF.Angles(0,-math.rad(layout.YawDegrees or 0),0)
	assert((origin:PointToObjectSpace(spawnPosition) - inverseYaw:PointToWorldSpace(V.new(-layout.ShiftX, .3, -layout.Distance))).Magnitude < .003,
		"Cluster front does not face its SpawnPad: base " .. id)
	assert((origin:PointToObjectSpace(shelterPosition) - inverseYaw:PointToWorldSpace(V.new(-layout.ShiftX, 0, 46 - layout.Distance))).Magnitude < .003,
		"Shelter must stay centered behind the tube cluster: base " .. id)
	local cluster = roblox.Instance.new("Model")
	cluster.Name = "Base" .. id
	cluster:SetAttribute("BaseId", id)
	cluster:SetAttribute("ClusterOrigin", origin)
	cluster.Parent = world
	for slot = 1, 5 do
		local frame = origin * CF.new(offsets[slot]) * CF.Angles(0, math.rad(angles[slot]), 0)
		local tube = Geometry.build(cluster, frame, slot)
		tube:SetAttribute("BaseId", id)
		tubeCount += 1
		partCount += tube:GetAttribute("StaticPartCount")
		assert((frame:PointToObjectSpace(tube.SpecimenAnchor.CFrame.Position) - V.new(0, 8.7, 0)).Magnitude < .001,
			"Specimen anchor inherited duplicate base translation")
		assert((frame:PointToObjectSpace(tube.InjectorAnchor.CFrame.Position) - V.new(0, 14.5, 0)).Magnitude < .001,
			"Injector anchor inherited duplicate base translation")
	end
end
assert(tubeCount == 60 and partCount == 12000, "Unexpected static tube budget")

-- Conservative footprint QA: a radius-six, 19.2-high cylinder against each
-- original part's projected bounding box. Zero hits proves the actual part
-- is outside that volume. Thin path trims buried within the 2.35-high plinth
-- are reported separately from structures that could obscure a specimen.
local baselineWorld = baseline:GetService("Workspace")
local previousDisplays=baselineWorld:FindFirstChild("SpecimenTubeDisplays")
local obstacles = {}
local excluded = {Ground = true, SpawnPad = true, TerraceFoundation = true, InlaidRuneRing = true}
for _, object in baselineWorld:GetDescendants() do
	if object:IsA("BasePart") and not object:IsA("Terrain") and object.Transparency < .95 and not excluded[object.Name]
		and not (previousDisplays and object:IsDescendantOf(previousDisplays)) then
		table.insert(obstacles, object)
	end
end
-- These existing crafting props are created by HuntEconomyService at runtime,
-- so include their exact offsets even though the baseline is an Edit save.
for id = 1, 12 do
	local arrival = baselineWorld.HunDinoL0.BaseTransit.Bases["Base" .. id].Arrival.CFrame
	local station = arrival * CF.new(13, -3, 0)
	local container = roblox.Instance.new("Model")
	container.Name = "ExistingRuntimeCraftBase" .. id
	for _, spec in {
		{"Counter", V.new(8, .7, 3.4), V.new(0, 2.2, 0)},
		{"Supplies", V.new(2.2, 1.2, 1.5), V.new(-1.7, 3.1, 0)},
		{"Sign", V.new(8, 2, .35), V.new(0, 5, 1.3)},
	} do
		local object = roblox.Instance.new("Part")
		object.Name, object.Size, object.CFrame = spec[1], spec[2], station * CF.new(spec[3])
		object.Parent = container
		table.insert(obstacles, object)
	end
end
local function vector(value) return {value.X, value.Y, value.Z} end
local function segmentIntersectsPart(object, a, b)
	local point = object.CFrame:PointToObjectSpace(a)
	local delta = object.CFrame:VectorToObjectSpace(b - a)
	local half, low, high = object.Size * .5, 0, 1
	for _, axis in {"X", "Y", "Z"} do
		if math.abs(delta[axis]) < .000001 then
			if math.abs(point[axis]) > half[axis] then return false end
		else
			local first, last = (-half[axis] - point[axis]) / delta[axis], (half[axis] - point[axis]) / delta[axis]
			if first > last then first, last = last, first end
			low, high = math.max(low, first), math.min(high, last)
			if low > high then return false end
		end
	end
	return true
end
local layoutReport = {
	Version = Geometry.Version, Baseline = baselinePath, Validation = "passed", TubeCount = tubeCount,
	StaticPartCount = partCount, StructuralObstructions = 0, BlockedSightlines = 0, SightlinesChecked = 0,
	Method = "Conservative radius6 x height19.2 cylinder against projected part OBB bounds; exact OBB segment sightlines from spawn/front to specimen/cap. Terrain's non-geometric wrapper, foundations and flat rune/floor art excluded. Contacts belowY1.5 are separately recorded within the2.35-high plinth.",
	Bases = {},
}
for id = 1, 12 do
	local base, cluster = bases["Base" .. id], world["Base" .. id]
	local origin, layout = cluster:GetAttribute("ClusterOrigin"), Geometry.ClusterLayout[id]
	local groundFrame = origin * CF.Angles(0,-math.rad(layout.YawDegrees or 0),0) * CF.new(-layout.ShiftX, 0, -layout.Distance)
	local rows = {}
	for _, object in obstacles do
		local center = groundFrame:PointToObjectSpace(object.CFrame.Position)
		local radius = object.Size.Magnitude * .5
		if math.abs(center.X) > 110 + radius or math.abs(center.Z) > 110 + radius or math.abs(center.Y) > 45 + radius then continue end
		local low, high = V.one * math.huge, -V.one * math.huge
		for _, x in {-1, 1} do for _, y in {-1, 1} do for _, z in {-1, 1} do
			local point = groundFrame:PointToObjectSpace(object.CFrame:PointToWorldSpace(object.Size * V.new(x, y, z) * .5))
			low = V.new(math.min(low.X, point.X), math.min(low.Y, point.Y), math.min(low.Z, point.Z))
			high = V.new(math.max(high.X, point.X), math.max(high.Y, point.Y), math.max(high.Z, point.Z))
		end end end
		if high.Y > .05 and low.Y < Geometry.Height then table.insert(rows, {Part = object, Low = low, High = high}) end
	end
	local row = {BaseId = id, Distance = layout.Distance, ShiftX = layout.ShiftX, YawDegrees = layout.YawDegrees or 0,
		Origin = vector(origin.Position), SpawnLocal = vector(origin:PointToObjectSpace(base.SpawnPad.CFrame.Position)),
		ShelterLocal = vector(origin:PointToObjectSpace(base.ShelterFloor.CFrame.Position)),
		StructuralObstructions = {}, LowTrimContacts = {}, BlockedSightlines = {}, TubeCenters = {}}
	local eyes = {groundFrame:PointToWorldSpace(V.new(0, 6, 0)), origin:PointToWorldSpace(V.new(0, 8, -25))}
	for slot = 1, 5 do
		local tubeOrigin = cluster["BioTube_" .. slot]:GetAttribute("StaticOrigin")
		local center = groundFrame:PointToObjectSpace(tubeOrigin.Position)
		table.insert(row.TubeCenters, vector(tubeOrigin.Position))
		for _, obstacle in rows do
			local dx = math.max(obstacle.Low.X - center.X, 0, center.X - obstacle.High.X)
			local dz = math.max(obstacle.Low.Z - center.Z, 0, center.Z - obstacle.High.Z)
			if dx * dx + dz * dz <= 36 then
				local contact = {Slot = slot, Part = obstacle.Part:GetFullName(), MinY = obstacle.Low.Y, MaxY = obstacle.High.Y}
				table.insert(if obstacle.High.Y > 1.5 then row.StructuralObstructions else row.LowTrimContacts, contact)
			end
		end
		for _, eye in eyes do for _, height in {8.7, 17.7} do
			layoutReport.SightlinesChecked += 1
			local target = tubeOrigin:PointToWorldSpace(V.new(0, height, 0))
			for _, obstacle in rows do
				if segmentIntersectsPart(obstacle.Part, eye, target) then
					table.insert(row.BlockedSightlines, {Slot = slot, Height = height, Part = obstacle.Part:GetFullName()})
				end
			end
		end end
	end
	layoutReport.StructuralObstructions += #row.StructuralObstructions
	layoutReport.BlockedSightlines += #row.BlockedSightlines
	table.insert(layoutReport.Bases, row)
end
assert(layoutReport.StructuralObstructions == 0, "Original structures overlap the display volume")
assert(layoutReport.BlockedSightlines == 0, "Original structures block a front sightline")
for _, object in world:GetDescendants() do
	assert(not object:IsA("LuaSourceContainer") and not object:IsA("Camera"), "Asset must contain static tube art only")
	assert(object.Name ~= "SpecimenAssembly", "Authored file must not contain player-owned/runtime specimens")
	if object:IsA("TextLabel") then
		-- Native Roblox converts the legacy Font enum automatically; Lune's
		-- serializer requires the equivalent canonical Font datatype instead.
		object.FontFace = roblox.Font.fromEnum(roblox.Enum.Font.GothamBold)
	end
end
if not fs.isDir("assets/hunting") then fs.writeDir("assets/hunting") end
fs.writeFile("assets/hunting/bio-tubes-layout.json", serde.encode("json", layoutReport, true))
fs.writeFile(outputPath, roblox.serializeModel({world}))
local saved = roblox.deserializeModel(fs.readFile(outputPath))
assert(#saved == 1 and saved[1].Name == "SpecimenTubeDisplays" and #saved[1]:GetChildren() == 12,
	"Authored tube art did not survive model serialization")
assert(saved[1]:GetAttribute("GeometryVersion") == Geometry.Version, "Geometry version missing after serialization")
assert(fs.readFile(baselinePath) == baselineBytes, "Native source place was unexpectedly modified")
print("PASS static bio-tube asset:", outputPath, tubeCount, "tubes,", partCount, "parts; baseline unchanged; version", Geometry.Version)
