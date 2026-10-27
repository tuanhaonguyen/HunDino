-- Static, reusable Bio-Containment art. The caller owns placement, ownership,
-- specimen display and interaction events; this builder never changes the map.
local Geometry = { Version = "BioTubeGeometry.5", Height = 19.2, Diameter = 12 }

local V = Vector3.new
local TAU = math.pi * 2
-- Native-surveyed placement keeps existing buildings, transit pads and crafting
-- furniture untouched. Every base retains an open arrival-to-spawn/camp corridor.
-- Base 11 keeps its previously authored safe placement, now reproducible in code.
Geometry.LayoutVersion = "TransitClearance.1"
Geometry.ClusterLayout = {
	[1] = {Distance = 10, ShiftX = 0, YawDegrees = 0},
	[2] = {Distance = 10, ShiftX = 8, YawDegrees = 0},
	[3] = {Distance = 20, ShiftX = 20, YawDegrees = 0},
	[4] = {Distance = -20, ShiftX = 20, YawDegrees = 135},
	[5] = {Distance = -20, ShiftX = 20, YawDegrees = 135},
	[6] = {Distance = -20, ShiftX = 20, YawDegrees = 135},
	[7] = {Distance = -20, ShiftX = 20, YawDegrees = 135},
	[8] = {Distance = 10, ShiftX = 0, YawDegrees = 0},
	[9] = {Distance = -4, ShiftX = -28, YawDegrees = -98.1301},
	[10] = {Distance = 20, ShiftX = 20, YawDegrees = 0},
	[11] = {Distance = -45.369904, ShiftX = -31.933586, YawDegrees = -143},
	[12] = {Distance = -8, ShiftX = -28, YawDegrees = -105.94539},
}

local C = {
	iron = Color3.fromRGB(25, 32, 37),
	steel = Color3.fromRGB(59, 73, 78),
	edge = Color3.fromRGB(95, 111, 116),
	black = Color3.fromRGB(13, 22, 25),
	green = Color3.fromRGB(65, 235, 115),
	glow = Color3.fromRGB(110, 255, 150),
	glass = Color3.fromRGB(90, 220, 130),
}

-- Shared native/offline placement contract. Local -Z faces back toward spawn;
-- offsets within the five-tube V are applied after this collision-aware frame.
function Geometry.clusterFrame(spawnPosition: Vector3, shelterPosition: Vector3, baseId: number): CFrame
	assert(typeof(spawnPosition) == "Vector3" and typeof(shelterPosition) == "Vector3", "Base positions must be Vector3")
	local layout = assert(Geometry.ClusterLayout[baseId], "Unknown bio-tube base")
	local difference = shelterPosition - spawnPosition
	local back = V(difference.X, 0, difference.Z)
	assert(back.Magnitude > .001, "Base has no valid shelter-facing direction")
	back = back.Unit
	local ground = V(spawnPosition.X, spawnPosition.Y - .3, spawnPosition.Z)
	return CFrame.fromMatrix(ground, Vector3.yAxis:Cross(back), Vector3.yAxis, back)
		* CFrame.new(layout.ShiftX, 0, layout.Distance)
		* CFrame.Angles(0, math.rad(layout.YawDegrees or 0), 0)
end

local function group(parent, name)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function part(parent, origin, name, size, localFrame, color, material, collide, className)
	local object = Instance.new(className or "Part")
	object.Name = name
	object.Size = size
	object.CFrame = origin * localFrame
	object.Color = color
	object.Material = material or Enum.Material.Metal
	object.Anchored = true
	object.CanCollide = collide == true
	object.CanQuery = collide == true
	object.CanTouch = false
	object.CastShadow = material ~= Enum.Material.Neon and material ~= Enum.Material.Glass
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent
	return object
end

local function cylinder(parent, origin, name, diameter, height, localFrame, color, material, collide)
	local object = part(parent, origin, name, V(height, diameter, diameter),
		localFrame * CFrame.Angles(0, 0, math.pi / 2), color, material, collide)
	object.Shape = Enum.PartType.Cylinder
	return object
end

local function beam(parent, origin, name, a, b, width, color, material)
	local delta = b - a
	local direction = delta.Unit
	local reference = if math.abs(direction.Y) > .95 then Vector3.zAxis else Vector3.yAxis
	local z = direction:Cross(reference).Unit
	local y = z:Cross(direction).Unit
	local object = part(parent, origin, name, V(delta.Magnitude, width, width),
		CFrame.fromMatrix((a + b) * .5, direction, y, z), color, material, false)
	object.Shape = Enum.PartType.Cylinder
	return object
end

-- Explicit orthonormal basis gives identical results in native Studio and
-- the offline authoring runtime, including headings in the southern half.
local function aimFrame(position, target)
	local back = (position - target).Unit
	local reference = if math.abs(back.Y) > .95 then Vector3.zAxis else Vector3.yAxis
	local right = reference:Cross(back).Unit
	return CFrame.fromMatrix(position, right, back:Cross(right).Unit, back)
end

-- A real eight-sided prism: three rectangular slabs and four horizontal
-- triangular wedges. No overlapping rotated squares or solid round proxy.
local function octagon(parent, origin, name, diameter, height, y, color)
	local shell = group(parent, name)
	local radius = diameter * .5
	local a, b = radius * math.cos(math.pi / 8), radius * math.sin(math.pi / 8)
	part(shell, origin, "CentralSlab", V(a * 2, height, b * 2), CFrame.new(0, y, 0), color, nil, true)
	for _, side in {-1, 1} do
		part(shell, origin, "Wing_" .. side, V(b * 2, height, a - b),
			CFrame.new(0, y, side * (a + b) * .5), color, nil, true)
	end
	for index = 1, 4 do
		local corner = CFrame.Angles(0, (index - 1) * math.pi / 2, 0)
		local horizontalWedge = CFrame.fromMatrix(V((a + b) * .5, y, (a + b) * .5),
			Vector3.yAxis, Vector3.xAxis, -Vector3.zAxis)
		part(shell, origin, "BeveledCorner_" .. index, V(height, a - b, a - b),
			corner * horizontalWedge, color, nil, true, "WedgePart")
	end
	return shell
end

local function ring(parent, origin, name, radius, y, height, thickness, segments, color, material)
	local assembly = group(parent, name)
	local length = 2 * radius * math.tan(math.pi / segments) + .015
	for index = 1, segments do
		local angle = TAU * (index - 1) / segments
		part(assembly, origin, "Segment_" .. index, V(length, height, thickness),
			CFrame.new(math.sin(angle) * radius, y, math.cos(angle) * radius)
				* CFrame.Angles(0, angle, 0), color, material, false)
	end
	return assembly
end

local function marker(parent, origin, name, position)
	local object = part(parent, origin, name, V(.05, .05, .05), CFrame.new(position), C.black,
		Enum.Material.SmoothPlastic, false)
	object.Transparency = 1
	object.CastShadow = false
	return object
end

local function label(panel, slot)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "TubeIdentification"
	surface.Face = Enum.NormalId.Front
	surface.CanvasSize = Vector2.new(600, 300)
	surface.LightInfluence = .3
	surface.MaxDistance = 80
	surface.Parent = panel
	local title = Instance.new("TextLabel")
	title.Name = "SlotLabel"
	title.Size = UDim2.fromScale(1, .55)
	title.Position = UDim2.fromScale(0, .06)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = string.format("BIO / 0%d", slot)
	title.TextScaled = true
	title.TextColor3 = C.glow
	title.Parent = surface
	local subtitle = title:Clone()
	subtitle.Name = "RoleLabel"
	subtitle.Size = UDim2.fromScale(.94, .22)
	subtitle.Position = UDim2.fromScale(.03, .68)
	subtitle.Text = if slot == 5 then "TRUNG TÂM" else "LƯU TRỮ SINH HỌC"
	subtitle.TextColor3 = Color3.fromRGB(191, 220, 205)
	subtitle.Parent = surface
end

-- Build one 19.2-stud tube; tubeCFrame is the ground origin and local -Z is
-- its front. Markers are direct children and never inherit a second offset.
-- Public contract: PrimaryPart/StaticOrigin, DisplaySlot, SpecimenAnchor (8.7),
-- InjectorAnchor (14.5), Interaction.SpecimenTubePrompt (G).
function Geometry.build(parent: Instance, tubeCFrame: CFrame, slot: number): Model
	assert(parent and typeof(tubeCFrame) == "CFrame", "BioTube requires a parent and ground CFrame")
	assert(slot % 1 == 0 and slot >= 1 and slot <= 5, "BioTube slot must be 1..5")
	local tube = Instance.new("Model")
	tube.Name = "BioTube_" .. slot
	tube:SetAttribute("DisplaySlot", slot)
	tube:SetAttribute("StaticOrigin", tubeCFrame)
	tube:SetAttribute("BioTubeGeometryVersion", Geometry.Version)
	tube:SetAttribute("VisualHeight", Geometry.Height)
	tube:SetAttribute("VisualDiameter", Geometry.Diameter)
	tube:SetAttribute("IdleBubbleRate", 14)
	tube.Parent = parent
	local root = marker(tube, tubeCFrame, "TubeRoot", V(0, .025, 0))
	root.PivotOffset = CFrame.new(0, -.025, 0)
	tube.PrimaryPart = root
	local lower = group(tube, "LowerMechanicalAssembly")
	octagon(lower, tubeCFrame, "OctagonBase_Low", 12, 1.1, .55, C.iron)
	octagon(lower, tubeCFrame, "BevelBase_Upper", 10.4, .9, 1.55, C.steel)
	octagon(lower, tubeCFrame, "BottomLockCollar", 10.2, .35, 2.175, C.edge)
	for index = 1, 8 do
		local angle = (index - 1) * TAU / 8
		local radial = V(math.sin(angle), 0, math.cos(angle))
		local a, b = radial * 5.46 + V(0, .65, 0), radial * 4.82 + V(0, 3.25, 0)
		local delta = b - a
		part(lower, tubeCFrame, "MechanicalButtress_" .. index, V(.6, .72, delta.Magnitude),
			aimFrame((a + b) * .5, b), C.steel, nil, false)
		part(lower, tubeCFrame, "ButtressFoot_" .. index, V(.9, .3, .72),
			CFrame.new(radial * 5.33 + V(0, .25, 0)) * CFrame.Angles(0, angle, 0), C.iron, nil, false)
		if index % 2 == 0 then
			part(lower, tubeCFrame, "LowerStatusLight_" .. index, V(.52, .13, .13),
				CFrame.new(radial * 5.67 + V(0, .85, 0)) * CFrame.Angles(0, angle, 0), C.glow, Enum.Material.Neon, false)
		end
	end
	-- Six straight sections per pipe follow a curved return path; they are
	-- intentionally kept behind the side braces, away from the front specimen.
	for _, side in {-1, 1} do
		local pipeName = if side < 0 then "CoolantPipe_L" else "CoolantPipe_R"
		local path = {V(side * 3.6, 1.1, 3.0), V(side * 4.5, 1.65, 3.0),
			V(side * 5.2, 2.4, 2.7), V(side * 5.35, 3.15, 2.1),
			V(side * 5.1, 3.75, 1.4), V(side * 4.7, 3.95, .9), V(side * 4.4, 3.8, .6)}
		for index = 1, #path - 1 do
			beam(lower, tubeCFrame, pipeName .. "_" .. index, path[index], path[index + 1], .28, C.black, Enum.Material.SmoothPlastic)
		end
		for _, index in {1, #path - 1} do
			local a, b = path[index], path[index + 1]
			local center = a:Lerp(b, .5)
			local direction = (b - a).Unit
			beam(lower, tubeCFrame, pipeName .. "_Coupling_" .. index, center - direction * .16,
				center + direction * .16, .4, C.edge, Enum.Material.Metal)
		end
	end

	local chamber = group(tube, "ContainmentChamber")
	local bottomDisc = cylinder(chamber, tubeCFrame, "BottomGlowDisc", 9, .18,
		CFrame.new(0, 2.36, 0), Color3.fromRGB(185, 255, 205), Enum.Material.Neon, false)
	-- A hollow wall keeps the body visible without the two broad flat caps of
	-- a transparent solid cylinder. It is also the physical containment shell.
	local glass = ring(chamber, tubeCFrame, "GlassOuterWall", 4.84, 8.7, 13, .08, 24, C.glass, Enum.Material.Glass)
	for _, pane in glass:GetChildren() do
		pane.Transparency = .62
		pane.Reflectance = .03
		pane.CanCollide = true
		pane.CanQuery = true
	end
	local fluid = cylinder(chamber, tubeCFrame, "BioFluidColumn", 9.2, 12.7,
		CFrame.new(0, 8.65, 0), C.green, Enum.Material.Neon, false)
	fluid.Transparency = .84 -- Preserve the actual specimen silhouette through both layers.
	for index = 1, 4 do
		local angle = math.pi / 4 + (index - 1) * math.pi / 2
		part(chamber, tubeCFrame, "GlassSeamRail_" .. index, V(.12, 12.6, .12),
			CFrame.new(math.sin(angle) * 4.94, 8.7, math.cos(angle) * 4.94), C.steel, nil, false)
	end
	local emitterAttachment = Instance.new("Attachment")
	emitterAttachment.Name = "BioBubblesOrigin"
	-- BottomGlowDisc is rotated; this converts the world-up emitter frame into
	-- that disc's local frame, preventing sidewards bubbles on rotated bases.
	emitterAttachment.CFrame = bottomDisc.CFrame:ToObjectSpace(tubeCFrame * CFrame.new(0, 2.5, 0))
	emitterAttachment.Parent = bottomDisc
	local bubbles = Instance.new("ParticleEmitter")
	bubbles.Name = "BioBubbles"
	bubbles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	bubbles.Color = ColorSequence.new(C.glow)
	bubbles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, .1), NumberSequenceKeypoint.new(.8, .17), NumberSequenceKeypoint.new(1, .11)})
	bubbles.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, .75), NumberSequenceKeypoint.new(.85, .83), NumberSequenceKeypoint.new(1, 1)})
	bubbles.Speed = NumberRange.new(1.4, 2.6)
	bubbles.Lifetime = NumberRange.new(4.2, 5.2)
	bubbles.Rate = 14
	bubbles.EmissionDirection = Enum.NormalId.Top
	bubbles.SpreadAngle = Vector2.new(14, 14)
	bubbles.LightEmission = .65
	bubbles.LightInfluence = 0
	bubbles.LockedToPart = true
	bubbles.Parent = emitterAttachment
	local light = Instance.new("PointLight")
	light.Name = "ContainmentGlow"
	light.Color = C.green
	light.Brightness = .35
	light.Range = 11
	light.Shadows = false
	light.Parent = bottomDisc

	local head = group(tube, "MultiTieredMechanicalDome")
	ring(head, tubeCFrame, "OuterRecessedShroud", 5.43, 16.4, 1.6, .7, 16, C.iron, Enum.Material.Metal)
	ring(head, tubeCFrame, "CeilingNeonRing_Outer", 4.8, 15.55, .13, .15, 16, C.glow, Enum.Material.Neon)
	ring(head, tubeCFrame, "CeilingNeonRing_Inner", 3.6, 15.55, .13, .13, 16, C.glow, Enum.Material.Neon)
	cylinder(head, tubeCFrame, "RibbedCoolingCore", 6.8, 1.1, CFrame.new(0, 15.35, 0), C.steel, nil, false)
	for index = 1, 24 do
		local angle = (index - 1) * TAU / 24
		part(head, tubeCFrame, "CoolingFin_" .. index, V(.12, .95, .45),
			CFrame.new(math.sin(angle) * 3.48, 15.35, math.cos(angle) * 3.48) * CFrame.Angles(0, angle, 0),
			C.edge, nil, false)
	end
	for index = 1, 4 do
		local angle = math.pi / 4 + (index - 1) * math.pi / 2
		local radial = V(math.sin(angle), 0, math.cos(angle))
		local a, b = radial * 5.2 + V(0, 15.85, 0), radial * 2.7 + V(0, 15.1, 0)
		local frame = aimFrame((a + b) * .5, b)
		local length = (b - a).Magnitude
		part(head, tubeCFrame, "AngledMechanicalStrut_" .. index, V(.45, .22, length), frame, C.steel, nil, false)
		for _, side in {-1, 1} do
			part(head, tubeCFrame, "StrutChannel_" .. index .. "_" .. side, V(.1, .55, length),
				frame * CFrame.new(side * .225, .1, 0), C.iron, nil, false)
		end
	end
	-- The specimen supplies a rotary collar at Y14.58..14.68 and its cable
	-- ports at Y14.385..14.615. Leave that whole central sweep unobstructed.
	-- Eight stationary feed valves are outboard of the rotating port envelope.
	cylinder(head, tubeCFrame, "CentralInjectorHub", 3.8, .4, CFrame.new(0, 14.925, 0), C.steel, nil, false)
	cylinder(head, tubeCFrame, "InjectorHubLowerCollar", 3.0, .1, CFrame.new(0, 14.75, 0), C.iron, nil, false)
	for index = 1, 8 do
		local angle = (index - 1) * TAU / 8
		local x, z = math.sin(angle) * 1.55, math.cos(angle) * 1.55
		cylinder(head, tubeCFrame, "InjectorValveStem_" .. index, .1, .55,
			CFrame.new(x, 14.525, z), C.steel, nil, false)
		cylinder(head, tubeCFrame, "InjectorNozzle_" .. index, .2, .3,
			CFrame.new(x, 14.1, z), C.glow, Enum.Material.Neon, false)
	end
	-- These five upper tiers close the shroud from above and make the complete
	-- authored silhouette reach Y=19.2, rather than ending at the old 17.2 cap.
	for _, tier in {
		{"UpperArmorDeck", 10.8, .7, 17.55, C.iron},
		{"RaisedBevelPlate", 9.6, .3, 18.05, C.steel},
		{"UpperLockRing", 7.7, .3, 18.35, C.edge},
		{"PowerCrown", 5.4, .4, 18.7, C.iron},
		{"CrownCap", 4.3, .3, 19.05, C.steel},
	} do
		cylinder(head, tubeCFrame, tier[1], tier[2], tier[3], CFrame.new(0, tier[4], 0), tier[5], nil, false)
	end

	local panel = part(lower, tubeCFrame, "TubeControlPanel", V(2.3, 1.3, .25),
		CFrame.new(0, 2.95, -5.23), C.black, Enum.Material.SmoothPlastic, false)
	label(panel, slot)
	marker(tube, tubeCFrame, "SpecimenAnchor", V(0, 8.7, 0))
	marker(tube, tubeCFrame, "InjectorAnchor", V(0, 14.5, 0))
	local interaction = marker(tube, tubeCFrame, "Interaction", V(0, 3.1, -6.8))
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "SpecimenTubePrompt"
	prompt.KeyboardKeyCode = Enum.KeyCode.G
	prompt.ActionText = "Chọn khủng long"
	prompt.ObjectText = if slot == 5 then "Ống #5 · Trung tâm" else "Ống #" .. slot
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0
	prompt:SetAttribute("DisplaySlot", slot)
	prompt.Parent = interaction
	local partCount = 0
	for _, object in tube:GetDescendants() do
		if object:IsA("BasePart") then partCount += 1 end
	end
	tube:SetAttribute("StaticPartCount", partCount)
	return tube
end

return Geometry
