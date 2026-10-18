-- EDIT ONLY: additive vegetation and rock partitions for the hunting map.
-- Rebuilds only Decor.ForestEnhancement; authored terrain, routes and dinosaurs stay intact.
-- Run begin(), ridges(1, #ridgeSpecs), forest(1, 360), understory(1, 150), finish(),
-- or build(). Each stage yields regularly, and tree/plant packets stay below 1,000 descendants.
local E = { Version = "H1.1", TreeTarget = 360, UnderstoryTarget = 150 }
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("HuntingMapConfig"))
local Terrain = workspace.Terrain
local RunService = game:GetService("RunService")
local root, generated, segments, occupied
local colors = {
	wood = Color3.fromRGB(70, 59, 44), root = Color3.fromRGB(82, 68, 47),
	leaf = Color3.fromRGB(44, 79, 48), middle = Color3.fromRGB(59, 98, 53),
	light = Color3.fromRGB(81, 113, 62), rock = Color3.fromRGB(91, 102, 91),
	rockLight = Color3.fromRGB(108, 117, 102), moss = Color3.fromRGB(66, 88, 51),
	fern = Color3.fromRGB(70, 107, 59), vine = Color3.fromRGB(66, 81, 44),
}
-- Irregular ridgelines divide adjacent spaces. Every individual rock is clipped
-- against the full-width route corridors, creating open passages at crossings.
local ridgeSpecs = {
	{name = "A_R2_MossDivide", a = Vector2.new(-735, -70), b = Vector2.new(-355, -75), height = 86},
	{name = "R2_C_AncientSpine", a = Vector2.new(-700, -410), b = Vector2.new(-265, -265), height = 96},
	{name = "C_NorthernWall", a = Vector2.new(-455, -655), b = Vector2.new(365, -650), height = 116},
	{name = "B_R3_StoneDivide", a = Vector2.new(185, -245), b = Vector2.new(715, -170), height = 92},
	{name = "B_R4_MossDivide", a = Vector2.new(290, 220), b = Vector2.new(715, 235), height = 87},
	{name = "R1_R5_StoneGarden", a = Vector2.new(-700, 285), b = Vector2.new(-100, 260), height = 73},
	{name = "R5_R4_SouthernFold", a = Vector2.new(220, 490), b = Vector2.new(655, 555), height = 78},
	{name = "R1_Camp_OuterFold", a = Vector2.new(-635, 650), b = Vector2.new(-165, 695), height = 82},
	{name = "EasternForestSpine", a = Vector2.new(722, -575), b = Vector2.new(725, 590), height = 100},
}
E.RidgeCount = #ridgeSpecs
local groveCenters = {
	Vector2.new(-700,-575), Vector2.new(-555,-565), Vector2.new(-330,-590),
	Vector2.new(160,-625), Vector2.new(535,-555), Vector2.new(660,-470),
	Vector2.new(-700,-340), Vector2.new(-380,-310), Vector2.new(-650,-90),
	Vector2.new(120,-325), Vector2.new(640,-265), Vector2.new(325,-65),
	Vector2.new(-660,100), Vector2.new(-250,170), Vector2.new(320,190),
	Vector2.new(660,95), Vector2.new(-660,375), Vector2.new(-305,255),
	Vector2.new(-95,420), Vector2.new(255,440), Vector2.new(650,380),
	Vector2.new(-570,620), Vector2.new(-320,660), Vector2.new(225,670),
	Vector2.new(465,645), Vector2.new(690,660), Vector2.new(-720,665),
	Vector2.new(-690,-675), Vector2.new(50,-725), Vector2.new(690,-670),
}
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = { Terrain }
rayParams.IgnoreWater = false
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.RespectCanCollide = true
overlapParams.MaxParts = 1
local ridgeOverlapParams = OverlapParams.new()
ridgeOverlapParams.FilterType = Enum.RaycastFilterType.Include
ridgeOverlapParams.RespectCanCollide = true
ridgeOverlapParams.MaxParts = 1

local function folder(name, parent)
	local item = Instance.new("Folder")
	item.Name = name; item.Parent = parent
	return item
end
local function model(name, parent)
	local item = Instance.new("Model")
	item.Name = name; item.Parent = parent
	return item
end
local function part(name, size, cf, color, material, parent, collide)
	local item = Instance.new("Part")
	item.Name = name; item.Size = size; item.CFrame = cf
	item.Color = color; item.Material = material
	item.Anchored = true; item.CanCollide = collide == true
	item.CanTouch = false; item.CanQuery = collide == true
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth; item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end
local function ellipsoid(name, size, cf, color, material, parent, collide)
	local item = part(name, size, cf, color, material, parent, collide)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere; mesh.Parent = item
	return item
end
local function beam(name, a, b, radius, color, parent, collide)
	local direction = (b-a).Unit
	local reference = if math.abs(direction.Y) > .9 then Vector3.zAxis else Vector3.yAxis
	local z = direction:Cross(reference).Unit
	local y = z:Cross(direction).Unit
	local item = part(name, Vector3.new((b-a).Magnitude, radius*2, radius*2),
		CFrame.fromMatrix((a+b)/2, direction, y, z), color, Enum.Material.Wood, parent, collide)
	item.Shape = Enum.PartType.Cylinder
	return item
end
local function ground(x, z)
	local hit = workspace:Raycast(Vector3.new(x, 400, z), Vector3.new(0, -520, 0), rayParams)
	if not hit or hit.Instance ~= Terrain or hit.Material == Enum.Material.Water then return nil end
	if hit.Normal.Y < .72 or hit.Position.Y < Config.LakeLevel + 1 then return nil end
	return hit.Position.Y
end
local function distanceSegment(x, z, a, b)
	local dx, dz = b.X-a.X, b.Z-a.Z
	local t = math.clamp(((x-a.X)*dx+(z-a.Z)*dz)/math.max(1, dx*dx+dz*dz), 0, 1)
	return math.sqrt((x-a.X-dx*t)^2+(z-a.Z-dz*t)^2)
end
local function prepare()
	segments = {}
	for _, group in {{edges=Config.Edges, width=Config.RoadWidth, margin=24}, {edges=Config.HumanPaths, width=24, margin=18}} do
		for _, edge in group.edges do
			local samples = Config.samples(edge, 12)
			for index = 1, #samples-1 do
				table.insert(segments, {a=samples[index], b=samples[index+1], half=group.width/2+group.margin})
			end
		end
	end
	occupied = {}
	-- Reserve existing trunks, avoiding two trunks growing from the same point.
	for _, item in root.Decor:GetDescendants() do
		if item:IsA("BasePart") and item.Name == "Trunk" then
			table.insert(occupied, {x=item.Position.X, z=item.Position.Z, radius=10})
		end
	end
	overlapParams.FilterDescendantsInstances = { root.Decor }
	-- A ridge is a continuous landform. Its neighboring generated pillars may
	-- overlap, while the separate probe still protects the original decorations.
	local authoredDecor = {}
	for _, item in root.Decor:GetChildren() do
		if item ~= generated then table.insert(authoredDecor,item) end
	end
	ridgeOverlapParams.FilterDescendantsInstances = authoredDecor
end
local function safe(x, z, footprint)
	if math.abs(x)+footprint > 775 or math.abs(z)+footprint > 775 then return false end
	-- Maintain the open water and its shoreline sightline.
	if (x/(216+footprint))^2+(z/(228+footprint))^2 < 1 then return false end
	for _, zone in Config.Zones do
		local p = Config.position(zone)
		local radius = zone.width*Config.PlanarScale*.52 + footprint + 12
		if (x-p.X)^2+(z-p.Z)^2 < radius*radius then return false end
	end
	for _, segment in segments do
		if distanceSegment(x, z, segment.a, segment.b) < segment.half+footprint then return false end
	end
	return true
end
local function baseFree(x, y, z, width, depth, params)
	return #workspace:GetPartBoundsInBox(CFrame.new(x,y+10,z), Vector3.new(width,18,depth), params or overlapParams) == 0
end
local function spaced(x, z, minimum)
	for _, item in occupied do
		if (x-item.x)^2+(z-item.z)^2 < (minimum+item.radius)^2 then return false end
	end
	return true
end
local function ready()
	assert(not RunService:IsRunning(), "Forest enhancement is an Edit-only builder")
	root = assert(workspace:FindFirstChild("HuntingRainforest"), "Build the hunting map first")
	generated = assert(root.Decor:FindFirstChild("ForestEnhancement"), "Call begin() first")
	if not segments then prepare() end
end
local function packet(kind, index, size)
	local name = string.format("%s_%03d", kind, math.floor((index-1)/size)+1)
	return generated:FindFirstChild(name) or folder(name, generated)
end
function E.begin()
	assert(not RunService:IsRunning(), "Forest enhancement is an Edit-only builder")
	root = assert(workspace:FindFirstChild("HuntingRainforest"), "Build the hunting map first")
	local old = root.Decor:FindFirstChild("ForestEnhancement")
	if old then old:Destroy() end
	generated = folder("ForestEnhancement", root.Decor)
	generated:SetAttribute("Version", E.Version)
	generated:SetAttribute("Seed", 792130)
	generated:SetAttribute("Stage", "Begin")
	prepare()
	return {stage="Begin", ridgeChains=#ridgeSpecs, trees=E.TreeTarget, understory=E.UnderstoryTarget}
end
function E.ridges(first, count)
	ready()
	local placed = 0
	local chainCounts = {}
	for index = first, math.min(#ridgeSpecs, first+count-1) do
		local spec = ridgeSpecs[index]
		local existing = generated:FindFirstChild(spec.name)
		if existing then existing:Destroy() end
		local chain = model(spec.name, generated)
		chain:SetAttribute("Partition", true)
		local chainPlaced = 0
		local rng = Random.new(792130+index*991)
		local distance = (spec.b-spec.a).Magnitude
		local total = math.ceil(distance/25)
		local direction = (spec.b-spec.a).Unit
		local perpendicular = Vector2.new(-direction.Y,direction.X)
		for step = 0, total do
			local p = spec.a:Lerp(spec.b, step/total)
			local width, depth = rng:NextNumber(28,42), rng:NextNumber(22,34)
			local footprint = math.sqrt(width*width+depth*depth)/2 + 4
			local x,z,y
			-- Let the ridge weave around old trunks and pad edges without reducing
			-- the route clearance. The fallback is perpendicular to the same divide.
			for attempt,offset in {0,14,-14,28,-28,42,-42} do
				local candidate = p+perpendicular*offset+direction*rng:NextNumber(-4,4)
				local cx,cz = candidate.X,candidate.Y
				if safe(cx,cz,footprint) then
					local cy = ground(cx,cz)
					if cy and baseFree(cx,cy,cz,width*.8,depth*.8,ridgeOverlapParams) then
						x,z,y = cx,cz,cy;break
					end
				end
			end
			if y then
					local m = model(string.format("RidgeRock_%02d",step), chain)
					local height = math.clamp(spec.height*rng:NextNumber(.74,1.05),60,106)
					local yaw = rng:NextNumber(-.9,.9)
					local cf = CFrame.new(x,y+height*.32,z)*CFrame.Angles(0,yaw,0)
					local body = ellipsoid("BuriedMossRock",Vector3.new(width,height,depth),cf,
						step%3 == 0 and colors.rockLight or colors.rock, Enum.Material.Rock,m,true)
					-- The spheroidal body starts 18% of its height below the ground.
					local capY = y+height*.765
					ellipsoid("MossCrown",Vector3.new(width*.69,height*.105,depth*.69),
						CFrame.new(x,capY,z)*CFrame.Angles(0,yaw,0),colors.moss,Enum.Material.Grass,m,false)
					local seam = part("WeatheredFace",Vector3.new(width*.24,height*.68,depth*.5),
						cf*CFrame.new(width*.17,-height*.08,0), colors.rockLight,Enum.Material.Slate,m,false)
					seam.Transparency = .15
					if step%3 == 0 then
						for vine = 1, 2 do
							local offset = (vine-.5)*width*.19
							beam("RockVine", Vector3.new(x+offset,capY,z+depth*.26),
								Vector3.new(x+offset+3,y+height*.3,z+depth*.43), .45,colors.vine,m,false)
						end
					end
					m:SetAttribute("FootprintRadius",footprint)
					m.PrimaryPart = body
					placed += 1
					chainPlaced += 1
			end
			if step%8 == 0 then task.wait() end
		end
		chain:SetAttribute("RockPillars",chainPlaced)
		table.insert(chainCounts,{name=spec.name,rockPillars=chainPlaced})
		task.wait()
	end
	generated:SetAttribute("Stage", "Ridges")
	return {stage="Ridges", first=first, count=count, rockPillars=placed, chains=chainCounts}
end
local function makeTree(index, x, y, z, height, rng, parent)
	local item = model(string.format("GroveTree_%03d",index),parent)
	local lean = Vector3.new(rng:NextNumber(-3,3),0,rng:NextNumber(-3,3))
	local radius = height/22
	local base = Vector3.new(x,y-3,z)
	local top = Vector3.new(x,y+height,z)+lean
	local trunk = beam("Trunk",base,top,radius,colors.wood,item,true)
	for j=1,3 do
		local angle = j*math.pi*2/3 + index*.37
		local side = Vector3.new(math.sin(angle),0,math.cos(angle))
		local endpoint = Vector3.new(x,y+height*.82,z)+side*height*.19+lean
		beam("Branch",Vector3.new(x,y+height*.58,z),endpoint,radius*.42,colors.wood,item,false)
	end
	for tier = 1, 3 do
		local factor = tier == 1 and .64 or tier == 2 and .51 or .34
		local offset = Vector3.new(math.sin(index+tier)*height*.08, height*(.66+(tier-1)*.15), math.cos(index+tier)*height*.08)
		ellipsoid("LayeredCanopy",Vector3.new(height*factor,height*.30,height*factor*.92),
			CFrame.new(Vector3.new(x,y,z)+offset+lean*.7)*CFrame.Angles(0,index*.29+tier,0),
			tier == 1 and colors.leaf or tier == 2 and colors.middle or colors.light,Enum.Material.Grass,item,false)
	end
	for j=1,3 do
		local angle = j*math.pi*2/3+index*.5
		local rx,rz = x+math.sin(angle)*radius*2.7,z+math.cos(angle)*radius*2.7
		local ry = ground(rx,rz)
		if ry then
			beam("GroundedRoot",Vector3.new(x,y+radius*1.7,z),Vector3.new(rx,ry-.3,rz),
				radius*.42,colors.root,item,true)
		end
	end
	if index%5 == 0 then
		beam("HangingVine", Vector3.new(x+height*.20,y+height*.76,z),
			Vector3.new(x+height*.20+2,y+height*.33,z+3),.42,colors.vine,item,false)
	end
	item.PrimaryPart = trunk
	item:SetAttribute("GroundHeight",y)
	item:SetAttribute("ForestAddition",true)
	table.insert(occupied,{x=x,z=z,radius=radius+3})
end
function E.forest(first, count)
	ready()
	local placed, failed = 0, 0
	for index = first, first+count-1 do
		local parent = packet("Groves",index,35)
		local name = string.format("GroveTree_%03d",index)
		if not parent:FindFirstChild(name) then
			local rng = Random.new(823711+index*197)
			local height = rng:NextNumber(53,85)
			if index%19 == 0 then height = rng:NextNumber(91,106) end
			-- Includes offset crowns, their rotation, and trunk lean.
			local footprint = height*.47+4
			local center = groveCenters[math.floor((index-1)/9)%#groveCenters+1]
			local found = false
			for attempt = 1, 300 do
				local x,z
				if attempt <= 140 then
					local angle = rng:NextNumber(0,math.pi*2)
					local radius = math.sqrt(rng:NextNumber())*105
					x,z = center.X+math.sin(angle)*radius,center.Y+math.cos(angle)*radius
				else x,z = rng:NextNumber(-735,735),rng:NextNumber(-735,735) end
				if safe(x,z,footprint) and spaced(x,z,7) then
					local y = ground(x,z)
					if y and baseFree(x,y,z,15,15) then
						makeTree(index,x,y,z,height,rng,parent)
						placed+=1;found=true;break
					end
				end
			end
			if not found then failed+=1 end
		end
		if index%8 == 0 then task.wait() end
	end
	generated:SetAttribute("Stage", "Forest")
	return {stage="Forest", first=first, attempted=count, trees=placed, skipped=failed}
end
function E.understory(first,count)
	ready()
	local placed = 0
	for index=first,first+count-1 do
		local parent = packet("Undergrowth",index,60)
		local name = string.format("FernCluster_%03d",index)
		if not parent:FindFirstChild(name) then
			local rng = Random.new(499053+index*211)
			for _=1,130 do
				local x,z = rng:NextNumber(-740,740),rng:NextNumber(-740,740)
				if safe(x,z,11) then
					local y = ground(x,z)
					if y and baseFree(x,y,z,10,10) then
						local item = model(name,parent)
						local scale = rng:NextNumber(.8,1.5)
						for j=1,5 do
							local angle = j*math.pi*2/5+index*.2
							local offset = Vector3.new(math.sin(angle)*5*scale,2.5*scale,math.cos(angle)*5*scale)
							ellipsoid("FernFrond",Vector3.new(3*scale,1.4*scale,15*scale),
								CFrame.new(Vector3.new(x,y,z)+offset)*CFrame.Angles(.25,angle,0),
								j%2 == 0 and colors.fern or colors.middle,Enum.Material.Grass,item,false)
						end
						placed+=1;break
					end
				end
			end
		end
		if index%12 == 0 then task.wait() end
	end
	generated:SetAttribute("Stage", "Understory")
	return {stage="Understory", first=first, attempted=count, clusters=placed}
end
function E.finish()
	ready()
	local trees,rocks,ferns,parts = 0,0,0,0
	for _,item in generated:GetDescendants() do
		if item:IsA("Model") then
			if item.Name:match("^GroveTree_") then trees+=1
			elseif item.Name:match("^RidgeRock_") then rocks+=1
			elseif item.Name:match("^FernCluster_") then ferns+=1 end
		elseif item:IsA("BasePart") then parts+=1 end
	end
	generated:SetAttribute("Stage", "Complete")
	generated:SetAttribute("Trees", trees);generated:SetAttribute("RockPillars", rocks)
	generated:SetAttribute("FernClusters", ferns);generated:SetAttribute("Parts",parts)
	root:SetAttribute("ForestEnhancementVersion",E.Version)
	return {stage="Complete",trees=trees,rockPillars=rocks,fernClusters=ferns,parts=parts,
		pathEdgeClearance=24,terrainUntouched=true}
end
function E.build()
	E.begin()
	for first=1,#ridgeSpecs,2 do E.ridges(first,2) end
	for first=1,E.TreeTarget,30 do E.forest(first,math.min(30,E.TreeTarget-first+1)) end
	for first=1,E.UnderstoryTarget,30 do E.understory(first,math.min(30,E.UnderstoryTarget-first+1)) end
	return E.finish()
end
return E
