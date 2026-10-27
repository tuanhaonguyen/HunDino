-- EDIT construction kit for Grey Mist Valley. No runtime work, asset downloads,
-- Terrain writes or lighting changes. Coordinates are the asset's ground base.
-- Optional authored meshes live under ServerStorage.ValleyTreeTemplates/<kind>.
-- Tree scale is relative to an adult tree; rock/plant scale may also be Vector3.
local K = { Version = "GreyMistArt1" }

K.Palette = {
	bark = Color3.fromRGB(69, 59, 48), barkLight = Color3.fromRGB(93, 77, 57),
	root = Color3.fromRGB(85, 73, 53), birch = Color3.fromRGB(203, 202, 177),
	birchScar = Color3.fromRGB(77, 78, 67), pine = Color3.fromRGB(39, 63, 49),
	pineLight = Color3.fromRGB(61, 80, 54), pineShade = Color3.fromRGB(29, 51, 44),
	oak = Color3.fromRGB(91, 104, 57), oakShade = Color3.fromRGB(66, 83, 49),
	oakGold = Color3.fromRGB(139, 125, 64), birchLeaf = Color3.fromRGB(136, 142, 76),
	birchGold = Color3.fromRGB(170, 143, 75), willow = Color3.fromRGB(84, 111, 79),
	willowLight = Color3.fromRGB(111, 129, 86), stone = Color3.fromRGB(103, 113, 111),
	stoneDark = Color3.fromRGB(77, 90, 90), stoneLight = Color3.fromRGB(125, 133, 126),
	moss = Color3.fromRGB(77, 95, 58), fern = Color3.fromRGB(76, 102, 62),
	grass = Color3.fromRGB(111, 121, 73), straw = Color3.fromRGB(149, 136, 83),
	reed = Color3.fromRGB(108, 113, 70), cattail = Color3.fromRGB(80, 62, 44),
	deadWood = Color3.fromRGB(112, 101, 79), endGrain = Color3.fromRGB(150, 129, 91),
}
local C = K.Palette
local V = Vector3.new
local TAU = math.pi * 2

local function seedNumber(seed)
	if type(seed) == "number" then return math.floor(seed) end
	local value = 17
	for i = 1, #tostring(seed or "Valley") do value = (value * 31 + string.byte(tostring(seed or "Valley"), i)) % 2147483647 end
	return value
end
local function scaleVector(scale)
	if typeof(scale) == "Vector3" then return scale end
	return V(scale or 1, scale or 1, scale or 1)
end
local function shade(color, rng, amount)
	local offset = rng:NextNumber(-amount, amount)
	return Color3.new(math.clamp(color.R + offset, 0, 1), math.clamp(color.G + offset, 0, 1), math.clamp(color.B + offset, 0, 1))
end
local function model(parent, name, position, seed)
	local m = Instance.new("Model")
	m.Name = name
	m:SetAttribute("ValleyArtKit", K.Version)
	m:SetAttribute("ArtSeed", seedNumber(seed))
	m:SetAttribute("GroundPosition", position)
	m.WorldPivot = CFrame.new(position)
	m.Parent = parent
	return m
end

-- Public helpers keep landmark materials and physics consistent with the kit.
function K.part(parent, name, size, cf, color, material, collide, className)
	local p = Instance.new(className or "Part")
	p.Name = name
	p.Size = V(math.max(.05, size.X), math.max(.05, size.Y), math.max(.05, size.Z))
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Slate
	p.Anchored = true
	p.CanCollide = collide == true
	p.CanQuery = collide == true
	p.CanTouch = false
	p.CastShadow = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
function K.beam(parent, name, a, b, radius, color, collide, material)
	local delta = b - a
	local x = if delta.Magnitude > .001 then delta.Unit else Vector3.yAxis
	local reference = if math.abs(x.Y) > .92 then Vector3.zAxis else Vector3.yAxis
	local z = x:Cross(reference).Unit
	local y = z:Cross(x).Unit
	local p = K.part(parent, name, V(math.max(.05, delta.Magnitude), radius * 2, radius * 2),
		CFrame.fromMatrix((a + b) * .5, x, y, z), color, material or Enum.Material.Wood, collide)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local function leaf(parent, name, size, cf, color)
	local p = K.part(parent, name, size, cf, color, Enum.Material.Grass, false)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end
local function wedge(parent, name, size, cf, color, material, collide)
	return K.part(parent, name, size, cf, color, material or Enum.Material.Grass, collide, "WedgePart")
end
local function transform(position, yaw, scale)
	local cf = CFrame.new(position) * CFrame.Angles(0, yaw, 0)
	local s = scaleVector(scale)
	return function(x, y, z) return cf:PointToWorldSpace(V(x, y, z) * s) end, cf, s
end
local function rootPair(m, point, size, rng)
	for i = 1, 2 do
		local a = rng:NextNumber(0, TAU) + i * math.pi
		local tip = V(math.cos(a) * 8 * size, .2, math.sin(a) * 8 * size)
		local p = K.beam(m, "ExposedRoot", point(0, 2.5, 0), point(tip.X / size, .2, tip.Z / size), 1.0 * size, C.root, false)
		p.CastShadow = false
	end
end

local function pine(parent, position, scale, seed)
	local rng = Random.new(seedNumber(seed))
	local m = model(parent, "OldGrowthPine", position, seed)
	local point, cf, s = transform(position, rng:NextNumber(0, TAU), scale)
	local uniform = s.Y
	local h = rng:NextNumber(84, 132)
	local leanX, leanZ = rng:NextNumber(-3.5, 3.5), rng:NextNumber(-3.5, 3.5)
	m.PrimaryPart = K.beam(m, "PineTrunk", point(0, 0, 0), point(leanX * .5, h * .49, leanZ * .5), 2.0 * uniform, shade(C.bark, rng, .025), true)
	K.beam(m, "LeaningUpperTrunk", point(leanX * .5, h * .49, leanZ * .5), point(leanX, h * .93, leanZ), 1.1 * uniform, C.barkLight, false)
	rootPair(m, point, uniform, rng)
	-- Paired wedges make four genuinely pointed, uneven needle skirts. Successive
	-- tiers rotate; this avoids a stack of round balls or identical flat cones.
	for layer = 1, 4 do
		local t = (layer - 1) / 3
		local width = (45 - 28 * t) * rng:NextNumber(.9, 1.12)
		local depth = width * rng:NextNumber(.72, .9)
		local height = h * (.29 - .075 * t)
		local baseY = h * (.29 + .166 * (layer - 1))
		local angle = rng:NextNumber(-.45, .45) + layer * .88
		local center = cf * CFrame.new(V(leanX * t, baseY + height * .5, leanZ * t) * s) * CFrame.Angles(0, angle, 0)
		local color = shade(if layer == 1 then C.pineShade elseif layer == 4 then C.pineLight else C.pine, rng, .025)
		for side = -1, 1, 2 do
			-- A WedgePart's tall edge is its local +Z side: turn each tall edge
			-- toward the centre to form a ridge rather than a hollow V.
			local skirt = center * CFrame.new(0, 0, side * depth * s.Z / 4) * CFrame.Angles(0, if side == 1 then math.pi else 0, 0)
			wedge(m, "NeedleTier" .. layer, V(width * s.X, height * s.Y, depth * .5 * s.Z), skirt, color)
		end
	end
	m:SetAttribute("ArtKind", "pine")
	m:SetAttribute("ApproxHeight", h * uniform)
	return m
end

local function birch(parent, position, scale, seed)
	local rng = Random.new(seedNumber(seed))
	local m = model(parent, "AutumnBirch", position, seed)
	local point, cf, s = transform(position, rng:NextNumber(0, TAU), scale)
	local h = rng:NextNumber(48, 70)
	local lean = rng:NextNumber(3, 7)
	m.PrimaryPart = K.beam(m, "WhiteBarkTrunk", point(0, 0, 0), point(1.7, h * .53, 0), 1.35 * s.Y, shade(C.birch, rng, .025), true)
	K.beam(m, "WhiteBarkFork", point(1.7, h * .53, 0), point(lean, h * .94, 1), .82 * s.Y, C.birch, false)
	K.beam(m, "BirchBranch", point(1.4, h * .47, 0), point(-8, h * .75, 3), .55 * s.Y, C.birch, false)
	-- Dark broken strips stay flush to the bark rather than thick decorative rings.
	for i = 1, 4 do
		local y = h * (.1 + i * .105)
		local angle = rng:NextNumber(0, TAU)
		local scar = cf * CFrame.new(V(1.7 * y / (h * .53), y, 0) * s) * CFrame.Angles(0, angle, -.07)
		K.part(m, "BirchBarkScar", V(1.8 * s.X, .42 * s.Y, .14 * s.Z), scar * CFrame.new(0, 0, 1.31 * s.Z), C.birchScar, Enum.Material.Wood, false)
	end
	for i, spec in {{-7, .73, 1, 21, 20, 18}, {7, .87, -2, 23, 22, 19}, {1, .65, 7, 27, 19, 20}, {10, .7, -6, 21, 17, 18}} do
		local color = if i == 2 or rng:NextNumber() < .24 then C.birchGold else C.birchLeaf
		leaf(m, "LooseAutumnCrown", V(spec[4], spec[5], spec[6]) * s,
			cf * CFrame.new(V(spec[1], h * spec[2], spec[3]) * s) * CFrame.Angles(.1, i, -.15), shade(color, rng, .035))
	end
	m:SetAttribute("ArtKind", "birch")
	return m
end

local function oak(parent, position, scale, seed)
	local rng = Random.new(seedNumber(seed))
	local m = model(parent, "CrookedValleyOak", position, seed)
	local point, cf, s = transform(position, rng:NextNumber(0, TAU), scale)
	local h = rng:NextNumber(54, 76)
	local bend = rng:NextNumber(3, 7)
	m.PrimaryPart = K.beam(m, "OakTrunk", point(0, 0, 0), point(-3, h * .29, 1), 3.8 * s.Y, shade(C.bark, rng, .03), true)
	K.beam(m, "CrookedOakTrunk", point(-3, h * .29, 1), point(bend, h * .56, 0), 2.8 * s.Y, C.bark, false)
	rootPair(m, point, s.Y * 1.4, rng)
	local branches = {{-23, .64, 5}, {23, .72, -6}, {3, .82, 14}, {-7, .75, -17}}
	for i, b in branches do
		K.beam(m, "SpreadingOakLimb", point(bend, h * .47, 0), point(b[1], h * b[2], b[3]), (1.8 - i * .17) * s.Y, C.barkLight, false)
	end
	for i, crown in {{-22, .68, 4, 41, 25, 36}, {24, .75, -4, 40, 25, 35}, {1, .86, 12, 40, 27, 35}, {-7, .78, -16, 43, 25, 38}, {2, .67, -1, 47, 25, 41}, {-31, .6, -10, 28, 20, 25}} do
		local color = if rng:NextNumber() < .16 then C.oakGold elseif i % 3 == 0 then C.oakShade else C.oak
		leaf(m, "BroadOakCanopy", V(crown[4], crown[5], crown[6]) * s,
			cf * CFrame.new(V(crown[1], h * crown[2], crown[3]) * s) * CFrame.Angles(rng:NextNumber(-.2, .2), i * .7, rng:NextNumber(-.15, .15)), shade(color, rng, .025))
	end
	m:SetAttribute("ArtKind", "oak")
	return m
end

local function willow(parent, position, scale, seed)
	local rng = Random.new(seedNumber(seed))
	local m = model(parent, "LakesideWeepingWillow", position, seed)
	local point, cf, s = transform(position, rng:NextNumber(0, TAU), scale)
	local h = rng:NextNumber(44, 62)
	m.PrimaryPart = K.beam(m, "WillowTrunk", point(0, 0, 0), point(-5, h * .45, 1), 3.1 * s.Y, C.bark, true)
	K.beam(m, "BentWillowCrownTrunk", point(-5, h * .45, 1), point(4, h * .7, 0), 2.0 * s.Y, C.barkLight, false)
	rootPair(m, point, s.Y * 1.2, rng)
	for i = 1, 3 do
		local angle = i * TAU / 3
		K.beam(m, "ArchedWillowLimb", point(-3, h * .43, 0), point(math.cos(angle) * 23, h * .66, math.sin(angle) * 21), 1.25 * s.Y, C.barkLight, false)
	end
	for i = 1, 4 do
		local angle = i * TAU / 4
		leaf(m, "WillowUmbrella", V(39, 20, 35) * s,
			cf * CFrame.new(V(math.cos(angle) * 14, h * .72, math.sin(angle) * 13) * s) * CFrame.Angles(.08, angle, -.1), shade(C.willow, rng, .025))
	end
	for i = 1, 6 do
		local angle = i * TAU / 6 + .25
		local length = rng:NextNumber(22, 35)
		local center = cf * CFrame.new(V(math.cos(angle) * 28, h * .68 - length * .36, math.sin(angle) * 25) * s)
			* CFrame.Angles(.12, -angle, .1 * math.sin(angle))
		wedge(m, "TrailingWillowLeaves", V(13, length, 7) * s, center, shade(if i % 2 == 0 then C.willowLight else C.willow, rng, .02))
	end
	m:SetAttribute("ArtKind", "willow")
	return m
end

local function templateTree(parent, kind, position, scale, seed)
	local library = game:GetService("ServerStorage"):FindFirstChild("ValleyTreeTemplates")
	local variants = library and library:FindFirstChild(kind)
	if not variants then return nil end
	local templates = {}
	for _, child in variants:GetChildren() do
		if child:IsA("Model") then table.insert(templates, child) end
	end
	if #templates == 0 then return nil end
	table.sort(templates, function(a, b) return a.Name < b.Name end)
	local rng = Random.new(seedNumber(seed))
	local template = templates[rng:NextInteger(1, #templates)]
	local factor = if typeof(scale) == "Vector3" then scale.Y else (scale or 1)
	assert(type(factor) == "number" and factor > 0 and factor < math.huge, "Tree scale must be positive and finite")
	local m = template:Clone()
	-- Imported variants are already upright with an identity ground-base pivot.
	-- GetScale is absolute, so multiplying the authored scale preserves adult size.
	m:ScaleTo(template:GetScale() * factor)
	local height = m:GetExtentsSize().Y
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			if p:IsA("MeshPart") then p.RenderFidelity = Enum.RenderFidelity.Automatic end
		end
	end
	m:PivotTo(CFrame.new(position) * CFrame.Angles(0, rng:NextNumber(0, TAU), 0))
	m:SetAttribute("ValleyArtKit", K.Version)
	m:SetAttribute("ArtKind", kind)
	m:SetAttribute("ArtSeed", seedNumber(seed))
	m:SetAttribute("GroundPosition", position)
	m:SetAttribute("ApproxHeight", height)
	m:SetAttribute("TemplateVariant", template.Name)
	-- A single inexpensive cylinder is the only collidable/queryable tree shape.
	-- Foliage therefore neither traps movement nor swallows arrows or melee rays.
	local collider = K.beam(m, "TrunkCollider", position, position + V(0, height * .65, 0),
		math.clamp(height * .025, 1.5, 3), C.bark, true)
	collider.Transparency = 1
	collider.CastShadow = false
	m.Parent = parent
	return m
end

function K.tree(parent, kind, position, scale, seed)
	kind = string.lower(kind or "pine")
	local imported = templateTree(parent, kind, position, scale, seed)
	if imported then return imported end
	if kind == "birch" then return birch(parent, position, scale or 1, seed) end
	if kind == "oak" then return oak(parent, position, scale or 1, seed) end
	if kind == "willow" then return willow(parent, position, scale or 1, seed) end
	return pine(parent, position, scale or 1, seed)
end

local function templateRock(parent, position, scale, seed)
	local library = game:GetService("ServerStorage"):FindFirstChild("ValleyRockTemplates")
	if not library then return nil end
	local templates = {}
	for _, child in library:GetChildren() do
		if child:IsA("Model") then table.insert(templates, child) end
	end
	if #templates == 0 then return nil end
	table.sort(templates, function(a, b) return a.Name < b.Name end)
	local rng = Random.new(seedNumber(seed))
	local template = templates[rng:NextInteger(1, #templates)]
	local factor = if typeof(scale) == "Vector3" then scale.Y else (scale or 1)
	assert(type(factor) == "number" and factor > 0 and factor < math.huge, "Rock scale must be positive and finite")
	local m = template:Clone()
	m:ScaleTo(template:GetScale() * factor)
	local height = m:GetExtentsSize().Y
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = true
			p.CanQuery = true
			p.CanTouch = false
			if p:IsA("MeshPart") then
				p.CollisionFidelity = Enum.CollisionFidelity.Hull
				p.RenderFidelity = Enum.RenderFidelity.Automatic
			end
		end
	end
	m:PivotTo(CFrame.new(position) * CFrame.Angles(0, rng:NextNumber(0, TAU), 0))
	m:SetAttribute("ValleyArtKit", K.Version)
	m:SetAttribute("ArtKind", "rock")
	m:SetAttribute("ArtSeed", seedNumber(seed))
	m:SetAttribute("GroundPosition", position)
	m:SetAttribute("ApproxHeight", height)
	m:SetAttribute("TemplateVariant", template.Name)
	m.Parent = parent
	return m
end

function K.rock(parent, position, scale, seed)
	local imported = templateRock(parent, position, scale, seed)
	if imported then return imported end
	local rng = Random.new(seedNumber(seed))
	local m = model(parent, "FracturedMossOutcrop", position, seed)
	local _, cf, s = transform(position, rng:NextNumber(0, TAU), scale or 1)
	-- The lower slabs meet beneath the ground. The upper wedge faces have distinct
	-- fracture planes and broad ledges, so large rocks read as geology at distance.
	m.PrimaryPart = K.part(m, "BuriedStoneCore", V(24, 15, 21) * s,
		cf * CFrame.new(V(0, 5.5, 0) * s) * CFrame.Angles(.04, .18, -.12), C.stoneDark, Enum.Material.Slate, true)
	for i, slab in {{-7, 13, 0, 18, 24, 23, -.25}, {7, 15, 0, 20, 30, 20, .3}, {0, 8, 9, 25, 16, 18, -.1}, {-6, 5, -12, 18, 12, 15, .13}} do
		wedge(m, "FracturedStoneFace", V(slab[4], slab[5], slab[6]) * s,
			cf * CFrame.new(V(slab[1], slab[2], slab[3]) * s) * CFrame.Angles(slab[7], i * 1.61, rng:NextNumber(-.12, .12)),
			shade(if i % 2 == 0 then C.stoneLight else C.stone, rng, .025), Enum.Material.Slate, true)
	end
	wedge(m, "MossShelf", V(17, .6, 12) * s,
		cf * CFrame.new(V(-2, 16.3, 7) * s) * CFrame.Angles(.14, .2, -.07), C.moss, Enum.Material.Grass, false)
	m:SetAttribute("ArtKind", "rock")
	return m
end

function K.plant(parent, kind, position, scale, seed)
	local rng = Random.new(seedNumber(seed))
	kind = string.lower(kind or "grass")
	local m = model(parent, if kind == "fern" then "ForestFern" elseif kind == "reed" then "MarshReeds" elseif kind == "stump" then "WeatheredStump" else "MeadowTuft", position, seed)
	local point, cf, s = transform(position, rng:NextNumber(0, TAU), scale or 1)
	if kind == "fern" then
		K.beam(m, "FernHeart", point(0, 0, 0), point(.1, 3.8, 0), .12 * s.Y, C.fern, false)
		for i = 1, 6 do
			local angle = i * TAU / 6
			local length = rng:NextNumber(4.8, 7.8)
			local center = cf * CFrame.new(V(math.cos(angle) * length * .35, 2.25, math.sin(angle) * length * .35) * s)
				* CFrame.Angles(0, -angle + math.pi / 2, -.34)
			wedge(m, "TaperedFernFrond", V(1.5, .48, length) * s, center, shade(C.fern, rng, .04))
		end
	elseif kind == "reed" or kind == "reeds" then
		for i = 1, 3 do
			local x, z = rng:NextNumber(-1.6, 1.6), rng:NextNumber(-1.6, 1.6)
			local h = rng:NextNumber(7, 12)
			K.beam(m, "ReedStem", point(x, 0, z), point(x + .5, h, z), .12 * s.Y, C.reed, false)
			K.beam(m, "VelvetCattail", point(x + .5, h - .4, z), point(x + .58, h + 1.6, z), .3 * s.Y, C.cattail, false)
		end
	elseif kind == "stump" then
		local top = point(.4, 5.5, .2)
		m.PrimaryPart = K.beam(m, "OldStump", point(0, -.3, 0), top, 3.0 * s.Y, C.deadWood, true)
		K.beam(m, "ExposedEndGrain", top, point(.4, 5.63, .2), 2.66 * s.Y, C.endGrain, false)
		for i = 1, 2 do
			local angle = i * 2.2
			K.beam(m, "StumpRoot", point(0, 1.2, 0), point(math.cos(angle) * 6, .1, math.sin(angle) * 6), .85 * s.Y, C.root, false)
		end
	else
		for i = 1, 4 do
			local angle = i * 2.4 + rng:NextNumber(-.3, .3)
			local h = rng:NextNumber(2.4, 4.7)
			wedge(m, "MeadowBladeFan", V(.22, h, 1.4) * s,
				cf * CFrame.new(V(math.cos(angle) * .5, h * .46, math.sin(angle) * .5) * s) * CFrame.Angles(.22, angle, .18),
				shade(if i % 3 == 0 then C.straw else C.grass, rng, .03))
		end
	end
	for _, p in m:GetDescendants() do if p:IsA("BasePart") then p.CastShadow = false end end
	m:SetAttribute("ArtKind", kind)
	return m
end

function K.log(parent, position, length, yaw, seed)
	local rng = Random.new(seedNumber(seed))
	local m = model(parent, "FallenWeatheredTrunk", position, seed)
	length = length or 36
	local radius = math.clamp(length * .07, 1.5, 4.5)
	local point = transform(position, yaw or rng:NextNumber(0, TAU), 1)
	local a, b = point(-length * .5, radius, 0), point(length * .5, radius + .8, 0)
	local axis = (b - a).Unit
	m.PrimaryPart = K.beam(m, "FallenBarkTrunk", a, b, radius, C.deadWood, true)
	K.beam(m, "BrokenEndGrain", a - axis * .08, a + axis * .08, radius * .87, C.endGrain, false)
	K.beam(m, "OldBranchSnag", point(length * .1, radius, 0), point(length * .15, radius + 5, 3), radius * .32, C.barkLight, false)
	K.beam(m, "MossStrip", point(-length * .32, radius * 1.9, .2), point(length * .29, radius * 1.9 + .6, .2), radius * .35, C.moss, false, Enum.Material.Grass)
	m:SetAttribute("ArtKind", "log")
	return m
end

return K
