-- A static, real specimen plus surface-bound implants. Only the client moves
-- the two presentation pivots; no character, physics joint or source art changes.
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local Specimen = {}
local TAG = "HunDinoBioSpecimen"
local GREEN = Color3.fromRGB(90, 255, 140)
local STEEL = Color3.fromRGB(83, 105, 108)
local BLACK = Color3.fromRGB(16, 24, 25)
local MAX_RADIUS, MAX_HEIGHT, CENTER_Y, INJECTOR_Y = 3.8, 10.5, 8.7, 14.5

-- These are landmarks of the shipped T-Rex, not a replacement dinosaur.
-- Offset is a fraction of the selected real mesh's aligned half extents.
-- Normal is the direction from the skin toward the cable.
local SOCKETS = {
	{Name = "SkullTop", Part = "head_geom", Offset = Vector3.new(0, 0, .20), Normal = Vector3.yAxis, Width = .13},
	{Name = "Neck_L", Part = "body_geom", Offset = Vector3.new(0, .24, -.48), Normal = -Vector3.xAxis, Width = .12, Fluid = true},
	{Name = "Neck_R", Part = "body_geom", Offset = Vector3.new(0, .24, -.48), Normal = Vector3.xAxis, Width = .12, Fluid = true},
	{Name = "Spine_Upper", Part = "body_geom", Offset = Vector3.new(0, 0, -.34), Normal = Vector3.yAxis, Width = .18},
	{Name = "Spine_Mid", Part = "body_geom", Offset = Vector3.new(0, 0, .04), Normal = Vector3.yAxis, Width = .18},
	{Name = "Spine_Lower", Part = "body_geom", Offset = Vector3.new(0, 0, .40), Normal = Vector3.yAxis, Width = .17},
	{Name = "Shoulder_L", Part = "body_geom", Offset = Vector3.new(0, .22, -.30), Normal = -Vector3.xAxis, Width = .15},
	{Name = "Shoulder_R", Part = "body_geom", Offset = Vector3.new(0, .22, -.30), Normal = Vector3.xAxis, Width = .15},
	{Name = "Sternum", Part = "body_geom", Offset = Vector3.new(0, -.10, 0), Normal = -Vector3.zAxis, Width = .16, Fluid = true},
	{Name = "Rib1_L", Part = "body_geom", Offset = Vector3.new(0, -.06, -.06), Normal = -Vector3.xAxis, Width = .12},
	{Name = "Rib1_R", Part = "body_geom", Offset = Vector3.new(0, -.06, -.06), Normal = Vector3.xAxis, Width = .12},
	{Name = "Rib2_L", Part = "body_geom", Offset = Vector3.new(0, -.21, .28), Normal = -Vector3.xAxis, Width = .11},
	{Name = "Rib2_R", Part = "body_geom", Offset = Vector3.new(0, -.21, .28), Normal = Vector3.xAxis, Width = .11},
	{Name = "Pelvis", Part = "body_geom", Offset = Vector3.new(0, 0, .64), Normal = Vector3.yAxis, Width = .14, Fluid = true},
}

local function eachCorner(part: BasePart, callback)
	local half = part.Size * .5
	for _, x in {-1, 1} do
		for _, y in {-1, 1} do
			for _, z in {-1, 1} do
				callback(part.CFrame:PointToWorldSpace(Vector3.new(half.X * x, half.Y * y, half.Z * z)))
			end
		end
	end
end

local function bounds(parts: {BasePart}, frame: CFrame?): (Vector3, Vector3)
	local low = Vector3.new(math.huge, math.huge, math.huge)
	local high = -low
	for _, part in parts do
		eachCorner(part, function(world)
			local point = if frame then frame:PointToObjectSpace(world) else world
			low = Vector3.new(math.min(low.X, point.X), math.min(low.Y, point.Y), math.min(low.Z, point.Z))
			high = Vector3.new(math.max(high.X, point.X), math.max(high.Y, point.Y), math.max(high.Z, point.Z))
		end)
	end
	return low, high
end

local function realParts(model: Model): {BasePart}
	local parts = {}
	for _, object in model:GetDescendants() do
		if object:IsA("BasePart") then
			object.Anchored = true
			object.CanCollide, object.CanTouch, object.CanQuery = false, false, false
			object.AssemblyLinearVelocity, object.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
			if object.Transparency < 1 then table.insert(parts, object) end
		end
	end
	assert(#parts > 0, "The real specimen visual has no visible geometry")
	return parts
end

local function namedPart(model: Model, name: string): BasePart
	local part = model:FindFirstChild(name, true)
	assert(part and part:IsA("BasePart"), "Missing real specimen anatomy: " .. name)
	return part
end

local function fit(model: Model, origin: CFrame)
	local parts = realParts(model)
	model:PivotTo(CFrame.new())
	-- Imported mesh art faces diagonally relative to its rig root. Derive the
	-- anatomy's forward direction before centering; otherwise a fixed #5 turns away.
	local forward = namedPart(model, "head_geom").Position - namedPart(model, "body_geom").Position
	forward = Vector3.new(forward.X, 0, forward.Z)
	assert(forward.Magnitude > .001, "Cannot determine the specimen's forward direction")
	local heading = CFrame.lookAt(Vector3.zero, forward.Unit)
	model:PivotTo(heading:Inverse() * model:GetPivot())
	local low, high = bounds(parts)
	local center, radius = (low + high) * .5, 0
	for _, part in parts do
		eachCorner(part, function(point)
			local offset = point - center
			radius = math.max(radius, Vector2.new(offset.X, offset.Z).Magnitude)
		end)
	end
	-- Radius of every part corner includes the entire tail at every yaw angle.
	-- Checking only width and depth would clip the glass midway through rotation.
	local factor = math.min(MAX_RADIUS / math.max(radius, .001), MAX_HEIGHT / math.max(high.Y - low.Y, .001))
	model:ScaleTo(model:GetScale() * factor)
	low, high = bounds(parts)
	center = (low + high) * .5
	model:PivotTo(origin * CFrame.new(0, CENTER_Y, 0) * CFrame.new(-center) * model:GetPivot())
	return factor, radius * factor, (high.Y - low.Y)
end

local function axisFrame(position: Vector3, axis: Vector3): CFrame
	local reference = if math.abs(axis:Dot(Vector3.yAxis)) > .95 then Vector3.zAxis else Vector3.yAxis
	local up = (reference - axis * reference:Dot(axis)).Unit
	return CFrame.fromMatrix(position, axis, up, axis:Cross(up))
end

local function cylinder(parent: Instance, name: string, size: Vector3, frame: CFrame, color: Color3, neon: boolean?): Part
	local part = Instance.new("Part")
	part.Name, part.Shape, part.Size, part.CFrame = name, Enum.PartType.Cylinder, size, frame
	part.Color, part.Material = color, if neon then Enum.Material.Neon else Enum.Material.Metal
	part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
	part.CastShadow = false
	part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function surfacePoint(part: BasePart, socket, origin: CFrame): (Vector3, Vector3, boolean)
	local low, high = bounds({part}, origin)
	local center, half = (low + high) * .5, (high - low) * .5
	local offset = socket.Offset
	local target = origin:PointToWorldSpace(center + Vector3.new(half.X * offset.X, half.Y * offset.Y, half.Z * offset.Z))
	local normal = origin:VectorToWorldSpace(socket.Normal).Unit
	local reach = part.Size.Magnitude * 2 + 2
	local parameters = RaycastParams.new()
	parameters.FilterType = Enum.RaycastFilterType.Include
	parameters.FilterDescendantsInstances = {part}
	parameters.IgnoreWater = true
	-- Only this clone is made queryable, only while sampling its actual collision
	-- surface. This never changes the original rig or broadens gameplay queries.
	local previous = part.CanQuery
	part.CanQuery = true
	local ok, hit = pcall(function()
		local result = Workspace:Raycast(target + normal * reach, -normal * reach * 2, parameters)
		if not result then
			result = Workspace:Raycast(part.Position + normal * reach, -normal * reach * 2, parameters)
		end
		return result
	end)
	part.CanQuery = previous
	if ok and hit and hit.Instance == part then return hit.Position, hit.Normal, true end
	-- ServerStorage / isolated inspection has no Workspace collision world. A
	-- genuine part-surface fallback keeps the attachment on the mesh's bounds;
	-- production mounts in Workspace normally use the surface raycast above.
	local localTarget = part.CFrame:PointToObjectSpace(target)
	local localNormal = part.CFrame:VectorToObjectSpace(normal)
	local h = part.Size * .5
	local ratios = {
		{math.abs(localNormal.X), "X"}, {math.abs(localNormal.Y), "Y"}, {math.abs(localNormal.Z), "Z"},
	}
	table.sort(ratios, function(a, b) return a[1] > b[1] end)
	local x, y, z = math.clamp(localTarget.X, -h.X, h.X), math.clamp(localTarget.Y, -h.Y, h.Y), math.clamp(localTarget.Z, -h.Z, h.Z)
	local side = ratios[1][2]
	local n
	if side == "X" then x = h.X * (if localNormal.X >= 0 then 1 else -1); n = Vector3.new(math.sign(x), 0, 0)
	elseif side == "Y" then y = h.Y * (if localNormal.Y >= 0 then 1 else -1); n = Vector3.new(0, math.sign(y), 0)
	else z = h.Z * (if localNormal.Z >= 0 then 1 else -1); n = Vector3.new(0, 0, math.sign(z)) end
	return part.CFrame:PointToWorldSpace(Vector3.new(x, y, z)), part.CFrame:VectorToWorldSpace(n), false
end

function Specimen.mount(tube: Model, template: Model, record: table): Model
	assert(tube and tube:IsA("Model"), "A BioTube model is required")
	assert(template and template:IsA("Model"), "The real TRex specimen visual is required")
	assert(type(record) == "table" and record.SpeciesId == "TRex", "Unsupported specimen species")
	local slot = tube:GetAttribute("DisplaySlot")
	assert(type(slot) == "number" and slot >= 1 and slot <= 5 and slot % 1 == 0, "BioTube requires DisplaySlot 1..5")
	local configuredOrigin = tube:GetAttribute("StaticOrigin")
	local origin = if typeof(configuredOrigin) == "CFrame" then configuredOrigin else tube:GetPivot()
	local previous = tube:FindFirstChild("SpecimenAssembly")
	local assembly = Instance.new("Model")
	assembly.Name = "SpecimenAssembly_Pending"
	assembly.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	assembly:PivotTo(origin)
	assembly.Parent = tube
	local ok, result = xpcall(function()
		local model = template:Clone()
		assert(model, "The sanitized TRex template is not archivable")
		model.Name, model.Parent = "Specimen", assembly
		local factor, radius, height = fit(model, origin)
		local implants = Instance.new("Folder")
		implants.Name, implants.Parent = "ImplantSockets", model
		local rotor = Instance.new("Model")
		rotor.Name, rotor.Parent = "RotatingInjector", assembly
		rotor:PivotTo(origin)
		cylinder(rotor, "InjectorRotaryCollar", Vector3.new(.10, 2.60, 2.60), origin * axisFrame(Vector3.new(0, INJECTOR_Y + .13, 0), Vector3.yAxis), STEEL)
		local cables = Instance.new("Folder")
		cables.Name, cables.Parent = "BioTetherCables", assembly
		local raycastCount = 0
		for index, socket in SOCKETS do
			local part = namedPart(model, socket.Part)
			local point, normal, sampled = surfacePoint(part, socket, origin)
			if sampled then raycastCount += 1 end
			local pierce = Instance.new("Attachment")
			pierce.Name = "Pierce_" .. socket.Name
			pierce.CFrame = part.CFrame:ToObjectSpace(axisFrame(point, normal))
			pierce:SetAttribute("SurfaceSampled", sampled)
			pierce.Parent = part
			local implant = cylinder(implants, "ImplantSocket_" .. socket.Name, Vector3.new(.26, .26, .26), axisFrame(point + normal * .02, normal), STEEL)
			implant:SetAttribute("BodyPartName", part.Name)
			cylinder(implants, "ImplantGlow_" .. socket.Name, Vector3.new(.05, .28, .28), axisFrame(point + normal * .09, normal), GREEN, true)
			local endpoint = Instance.new("Attachment")
			endpoint.Name = "CableEnd_" .. socket.Name
			endpoint.CFrame = implant.CFrame:ToObjectSpace(axisFrame(point + normal * .15, -normal))
			endpoint.Parent = implant
			local angle = (index - 1) * math.pi * 2 / #SOCKETS
			local portRadius = if index % 2 == 0 then .80 else 1.14
			local portPosition = Vector3.new(math.cos(angle) * portRadius, INJECTOR_Y, math.sin(angle) * portRadius)
			local port = cylinder(rotor, "InjectorPort_" .. index, Vector3.new(.23, .24, .24), origin * axisFrame(portPosition, -Vector3.yAxis), STEEL)
			cylinder(rotor, "InjectorPortGlow_" .. index, Vector3.new(.05, .255, .255), origin * axisFrame(portPosition - Vector3.new(0, .07, 0), -Vector3.yAxis), GREEN, true)
			local start = Instance.new("Attachment")
			start.Name = "CableStart_" .. socket.Name
			local radial = Vector3.new(math.cos(angle), 0, math.sin(angle))
			local tangent = (radial * .7 - Vector3.yAxis).Unit
			start.CFrame = port.CFrame:ToObjectSpace(origin * axisFrame(portPosition - Vector3.new(0, .12, 0), tangent))
			start.Parent = port
			local cable = Instance.new("Beam")
			cable.Name = "BioCable_" .. socket.Name
			cable.Attachment0, cable.Attachment1 = start, endpoint
			cable.FaceCamera, cable.Segments = true, 16
			cable.Width0, cable.Width1 = socket.Width, socket.Width * .86
			cable.CurveSize0 = if socket.Name:find("Rib", 1, true) then 2.20 else 1.55
			cable.CurveSize1 = if socket.Normal.Y == 1 then .55 else 1.18
			cable.Color = ColorSequence.new(if socket.Fluid then GREEN else BLACK)
			cable.Transparency = NumberSequence.new(if socket.Fluid then .16 else 0)
			cable.LightEmission = if socket.Fluid then .65 else .04
			cable.LightInfluence = if socket.Fluid then .25 else .75
			cable:SetAttribute("PierceName", pierce.Name)
			cable:SetAttribute("FluidLine", socket.Fluid == true)
			cable.Parent = cables
		end
		assembly:SetAttribute("StaticOrigin", origin)
		assembly:SetAttribute("SpecimenRestPivot", model:GetPivot())
		assembly:SetAttribute("InjectorRestPivot", rotor:GetPivot())
		assembly:SetAttribute("DisplaySlot", slot)
		assembly:SetAttribute("AngularSpeedDegrees", if slot == 5 then 0 else 10)
		assembly:SetAttribute("BobAmplitude", .12)
		assembly:SetAttribute("BobFrequency", .22)
		assembly:SetAttribute("SpecimenId", tostring(record.Id or ""))
		assembly:SetAttribute("SpeciesId", "TRex")
		assembly:SetAttribute("FittedRadius", radius)
		assembly:SetAttribute("FittedHeight", height)
		assembly:SetAttribute("ScaleFactor", factor)
		assembly:SetAttribute("TetherCount", #SOCKETS)
		assembly:SetAttribute("SurfaceRaycastCount", raycastCount)
		assembly:SetAttribute("Ready", true)
		return assembly
	end, function(exception) return debug.traceback(tostring(exception), 2) end)
	if not ok then assembly:Destroy(); error(result, 2) end
	if previous then previous:Destroy() end
	assembly.Name = "SpecimenAssembly"
	CollectionService:AddTag(assembly, TAG)
	return assembly
end

return Specimen
