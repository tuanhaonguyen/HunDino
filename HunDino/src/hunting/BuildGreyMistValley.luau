-- EDIT-only staged expansion. Terrain writes are bounded to the hunting rectangle.
-- Existing lobby/base geometry and Terrain outside that rectangle are untouched.
local V = {Version = "H2.0", TreeTarget = 2400, PlantTarget = 1500, RockTarget = 220}
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local Config = require(RS:WaitForChild("HuntingMapConfig"))
local Base = require(RS:WaitForChild("HuntingBaseConfig"))
local Kit = require(script.Parent:WaitForChild("ValleyArtKit"))
local Landmarks = require(script.Parent:WaitForChild("ValleyLandmarks"))
local Terrain = workspace.Terrain
local O = Config.WorldOffset
local root, occupied = nil, {}
local landmarkParams=OverlapParams.new()
landmarkParams.FilterType=Enum.RaycastFilterType.Include
landmarkParams.RespectCanCollide=true
landmarkParams.MaxParts=1
local function folder(name, parent)
	local f = Instance.new("Folder"); f.Name = name; f.Parent = parent; return f
end
local function model(name, parent)
	local m = Instance.new("Model"); m.Name = name; m.Parent = parent; return m
end
local function part(name, size, cf, material, parent, collide)
	local p = Instance.new("Part"); p.Name = name; p.Size = size; p.CFrame = cf
	p.Material = material; p.Color = Color3.fromRGB(105, 96, 72)
	p.Anchored = true; p.CanCollide = collide == true; p.CanQuery = collide == true
	p.CanTouch = false; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent; return p
end
local function current()
	assert(not game:GetService("RunService"):IsRunning(), "Build only in Edit")
	root = root or workspace:FindFirstChild("HuntingRainforest")
	assert(root and root:GetAttribute("Version") == V.Version, "Start the H2 expansion first")
	return root
end
local function world(x, y, z) return Vector3.new(x, y, z) + O end
local segments, bins = {}, {}
local function key(x, z) return math.floor(x / 128) .. ":" .. math.floor(z / 128) end
local function prepare()
	if next(bins) then return end
	for _, group in {{Base.Edges,72},{Base.HumanPaths,24}} do
		for _, edge in group[1] do
			local points = Base.samples(edge, 24)
			for i=1,#points-1 do
				local item = {a=points[i], b=points[i+1], half=group[2]/2}
				table.insert(segments,item)
				for gx=math.floor((math.min(item.a.X,item.b.X)-100)/128),math.floor((math.max(item.a.X,item.b.X)+100)/128) do
					for gz=math.floor((math.min(item.a.Z,item.b.Z)-100)/128),math.floor((math.max(item.a.Z,item.b.Z)+100)/128) do
						local k=gx..":"..gz;bins[k]=bins[k] or {};table.insert(bins[k],item)
					end
				end
			end
		end
	end
end
local function distance(x,z,a,b)
	local dx,dz=b.X-a.X,b.Z-a.Z
	local t=math.clamp(((x-a.X)*dx+(z-a.Z)*dz)/math.max(1,dx*dx+dz*dz),0,1)
	return math.sqrt((x-a.X-dx*t)^2+(z-a.Z-dz*t)^2)
end
local function safe(x,z,radius)
	prepare()
	if math.abs(x)>1930-radius or math.abs(z)>2170-radius then return false end
	for _, q in Base.Zones do
		if Vector2.new(x-q.x,z-q.z).Magnitude < q.width*.5+radius+18 then return false end
	end
	for _, s in bins[key(x,z)] or {} do if distance(x,z,s.a,s.b)<s.half+radius+12 then return false end end
	local lake=((x-100)/490)^2+((z-100)/345)^2
	if lake<1.05 then return false end
	-- Reserve camera reveals, the lumber mill, cave apron, and stream-side vistas.
	for _, p in {{-720,1070,150},{-50,1875,120},{740,1150,120},{1260,-360,120},{0,-1900,270}} do
		if Vector2.new(x-p[1],z-p[2]).Magnitude < p[3]+radius then return false end
	end
	local landmarks=root and root.Decor:FindFirstChild("Landmarks")
	if landmarks then
		landmarkParams.FilterDescendantsInstances={landmarks}
		local y=Base.terrainHeight(x,z)
		if #workspace:GetPartBoundsInBox(CFrame.new(world(x,y+45,z)),Vector3.new(radius*2+12,110,radius*2+12),landmarkParams)>0 then return false end
	end
	return true
end
function V.begin()
	assert(not game:GetService("RunService"):IsRunning(), "Build only in Edit")
	assert(Base.MapWidth == 4000 and Base.MapDepth == 4500, "Expansion config must be installed first")
	local old = assert(workspace:FindFirstChild("HuntingRainforest"))
	assert(old:GetAttribute("Version") ~= V.Version, "Expansion already exists")
	local backup = SS:FindFirstChild("GreyMistValleyBackup_20261019") or folder("GreyMistValleyBackup_20261019",SS)
	old.Name = "HuntingRainforest_H131"; old.Parent = backup
	root = model("HuntingRainforest", workspace)
	for _, n in {"Zones","Paths","Decor","Camp","Boundaries","Network"} do folder(n,root) end
	for _, pair in {{"Version",V.Version},{"WorldOffset",O},{"MapWidth",4000},{"MapDepth",4500},
		{"MapSize",4500},{"PlanarScale",1},{"HubConnected",true},{"AnimalZoneCount",8},
		{"PrototypeDinosaurCount",1},{"NorthIsPositiveZ",true},{"DinosaurCombatEnabled",true}} do root:SetAttribute(pair[1],pair[2]) end
	root:SetAttribute("BuildStage","Terrain");root:SetAttribute("DisplayName","Thung Lũng Sương Xám")
	local camp = old.Camp
	for _, name in {"CampArrival","CampSpawn","ReturnToLobby"} do
		local original = camp:FindFirstChild(name)
		if original then original:Clone().Parent=root.Camp end
	end
	-- The rectangle is wholly separated from the hub at Z < 4,248.
	assert(O.Z-2252>4000 and O.X==0 and O.Y==0, "Unsafe hunting Terrain bounds")
	Terrain:FillBlock(CFrame.new(O+Vector3.new(0,40,0)),Vector3.new(1632,176,1632),Enum.Material.Air)
	root:SetAttribute("TerrainWriteBoundsMin",world(-2000,-64,-2252))
	root:SetAttribute("TerrainWriteBoundsMax",world(2000,704,2252))
	return {stage="Begin",backup=backup:GetFullName(),map={4000,4500}}
end
-- One tile is 128 x 128 studs, at native 4-stud resolution. Empty space above
-- the local maximum is omitted; this avoids huge full-height voxel tables.
function V.terrain(firstTile, count)
	current()
	local nx,nz=math.ceil(4000/128),math.ceil(4504/128)
	local finish=math.min(firstTile+count-1,nx*nz)
	for index=firstTile,finish do
		local ix,iz=math.floor((index-1)/nz),(index-1)%nz
		local x0,z0=-2000+ix*128,-2252+iz*128
		local x1,z1=math.min(x0+128,2000),math.min(z0+128,2252)
		local xs,zs=(x1-x0)/4,(z1-z0)/4
		local columns,maxY={},-64
		for x=1,xs do columns[x]={};for z=1,zs do
			local wx,wz=x0+(x-.5)*4,z0+(z-.5)*4
			local h,graded,roadDistance=Base.terrainHeight(wx,wz)
			local waterHeight,waterKind=Base.waterLevel(wx,wz,h)
			if waterKind=="Stream" then waterHeight=math.min(waterHeight,h+3) end
			local wet=waterHeight~=nil
			local shape=Base.lakeRadius(wx,wz)^2
			local material=Enum.Material.LeafyGrass
			if h>430 then material=Enum.Material.Rock
			elseif h>310 then material=Enum.Material.Slate
			elseif wx>970 and wz>-900 and wz<550 then material=Enum.Material.Mud
			elseif wz< -650 then material=Enum.Material.Grass end
			if graded and (roadDistance or 0)<12 then material=Enum.Material.Ground end
			if shape<1.23 and h>Base.LakeLevel-4 and h<Base.LakeLevel+12 then material=Enum.Material.Sandstone end
			columns[x][z]={h=h,water=if wet then waterHeight else nil,material=material}
			maxY=math.max(maxY,h,if wet then waterHeight else h)
		end end
		local top=math.min(704,math.ceil((maxY+4)/4)*4);local ys=(top+64)/4
		local materials,occupancy={},{}
		for x=1,xs do materials[x]={};occupancy[x]={};for y=1,ys do
			local bottom=-64+(y-1)*4;materials[x][y]={};occupancy[x][y]={}
			for z=1,zs do
				local col=columns[x][z];local solidTop=col.h-2
				local fill=math.clamp((solidTop-bottom)/4,0,1)
				if fill>0 then
					-- Keep the surface material through the interpolation band; a single
					-- thin voxel layer blends back into brown subsoil on broad slopes.
					materials[x][y][z]=if bottom<solidTop-32 then Enum.Material.Rock elseif bottom<solidTop-16 then Enum.Material.Ground else col.material
					occupancy[x][y][z]=fill
				elseif col.water and bottom<col.water then
					materials[x][y][z]=Enum.Material.Water;occupancy[x][y][z]=math.clamp((col.water-bottom)/4,0,1)
				else materials[x][y][z]=Enum.Material.Air;occupancy[x][y][z]=0 end
			end
		end end
		-- A later grading pass can lower a tile. Clear its old upper volume too,
		-- otherwise the earlier surface survives above the new write region.
		if top<704 then
			Terrain:FillBlock(CFrame.new(world((x0+x1)/2,(top+704)/2,(z0+z1)/2)),Vector3.new(x1-x0,704-top,z1-z0),Enum.Material.Air)
		end
		Terrain:WriteVoxels(Region3.new(world(x0,-64,z0),world(x1,top,z1)),4,materials,occupancy)
		root:SetAttribute("TerrainTilesComplete",math.max(index,root:GetAttribute("TerrainTilesComplete") or 0))
		if index%2==0 then task.wait() end
	end
	return {stage="Terrain",complete=finish,total=nx*nz}
end
function V.paths()
	current();assert(#root.Paths:GetChildren()==0,"Paths already installed")
	for _, q in Base.Zones do
		local zone=model(q.id,root.Zones);zone:SetAttribute("Kind",q.kind);zone:SetAttribute("Width",q.width)
		zone:SetAttribute("DisplayName",q.name)
		local p=Config.position(q)
		local node=part("Node",Vector3.one,CFrame.new(p),Enum.Material.Ground,zone,false)
		node.Transparency=1;node:SetAttribute("ZoneId",q.id);zone.PrimaryPart=node
		local pad=part("Clearing",Vector3.new(1,q.width,q.width),CFrame.new(p-Vector3.new(0,.35,0))*CFrame.Angles(0,0,math.pi/2),Enum.Material.Ground,zone,true)
		pad.Shape=Enum.PartType.Cylinder;pad.Transparency=1;pad.CastShadow=false
		pad:SetAttribute("CombatSpace",q.kind=="Main")
	end
	for _, group in {{Base.Edges,72,false},{Base.HumanPaths,24,true}} do
		for _, edge in group[1] do
			local path=model(edge.a.."_"..edge.b,root.Paths)
			path:SetAttribute("FromZone",edge.a);path:SetAttribute("ToZone",edge.b);path:SetAttribute("Bidirectional",true)
			path:SetAttribute("HumanOnly",group[3]);path:SetAttribute("WalkWidth",group[2])
			local pts=Config.samples(edge,16)
			for i=1,#pts-1 do
				local a,b=pts[i]+Vector3.new(0,.2,0),pts[i+1]+Vector3.new(0,.2,0)
				local p=part("WalkSurface",Vector3.new(group[2],2,(b-a).Magnitude+2),CFrame.lookAt((a+b)/2-Vector3.new(0,1,0),b-Vector3.new(0,1,0)),Enum.Material.Ground,path,true)
				p.Transparency=1;p.CastShadow=false;p:SetAttribute("SampleIndex",i);p:SetAttribute("RouteStart",a);p:SetAttribute("RouteEnd",b);p:SetAttribute("WalkWidth",group[2])
			end
			task.wait()
		end
	end
	local camp=Config.position(Base.zone("Camp"))
	root.Camp.CampArrival.CFrame=CFrame.lookAt(camp+Vector3.new(0,5,50),camp+Vector3.new(0,5,200))
	root.Camp.CampSpawn.Enabled=false;root.Camp.CampSpawn.CFrame=CFrame.new(camp+Vector3.new(0,1,50))
	root.Camp.ReturnToLobby:PivotTo(CFrame.new(camp+Vector3.new(-100,4,45)))
	root:SetAttribute("BuildStage","Landmarks")
	return {stage="Paths",zones=#root.Zones:GetChildren(),paths=#root.Paths:GetChildren()}
end
local function gradeFoundation(base,size)
	local blend=20
	local low=base-Vector3.new(size.X/2+blend,40,size.Z/2+blend)
	local high=base+Vector3.new(size.X/2+blend,40,size.Z/2+blend)
	local region=Region3.new(low,high):ExpandToGrid(4)
	local corner=region.CFrame.Position-region.Size/2
	local n=region.Size/4
	local materials,occupancy={},{}
	for x=1,n.X do materials[x]={};occupancy[x]={}
		local columns={}
		for z=1,n.Z do
			local wx,wz=corner.X+(x-.5)*4,corner.Z+(z-.5)*4
			local old=Base.terrainHeight(wx-O.X,wz-O.Z)
			local delta=math.max(math.abs(wx-base.X)-size.X/2,math.abs(wz-base.Z)-size.Z/2,0)
			local t=math.clamp(delta/blend,0,1);t=t*t*(3-2*t)
			columns[z]=base.Y+(old-base.Y)*t
		end
		for y=1,n.Y do materials[x][y]={};occupancy[x][y]={}
			local bottom=corner.Y+(y-1)*4
			for z=1,n.Z do
				local fill=math.clamp((columns[z]-2-bottom)/4,0,1)
				materials[x][y][z]=if fill>0 then Enum.Material.Ground else Enum.Material.Air
				occupancy[x][y][z]=fill
			end
		end
	end
	Terrain:WriteVoxels(region,4,materials,occupancy)
end
function V.landmark(stage)
	current();local places=root.Decor:FindFirstChild("Landmarks") or folder("Landmarks",root.Decor)
	assert(type(Landmarks[stage])=="function","Unknown landmark stage")
	local m=Landmarks[stage](places,Config,Kit)
	for _,item in m:GetDescendants() do
		local base,size=item:GetAttribute("GroundBase"),item:GetAttribute("FoundationFootprint")
		if typeof(base)=="Vector3" and typeof(size)=="Vector3" then gradeFoundation(base,size);task.wait() end
	end
	local carve,size=m:GetAttribute("TerrainCarveCenter"),m:GetAttribute("TerrainCarveSize")
	if typeof(carve)=="Vector3" then
		gradeFoundation(m:GetAttribute("GroundBase"),Vector3.new(48,2,106))
		Terrain:FillBlock(CFrame.new(carve),size,Enum.Material.Air)
	end
	return {stage=stage,landmark=m.Name,parts=#m:GetDescendants()}
end
function V.foundations()
	current();local count=0
	for _,item in root.Decor.Landmarks:GetDescendants() do
		local base,size=item:GetAttribute("GroundBase"),item:GetAttribute("FoundationFootprint")
		if typeof(base)=="Vector3" and typeof(size)=="Vector3" then gradeFoundation(base,size);count+=1 end
		local carve,volume=item:GetAttribute("TerrainCarveCenter"),item:GetAttribute("TerrainCarveSize")
		if typeof(carve)=="Vector3" then
			gradeFoundation(item:GetAttribute("GroundBase"),Vector3.new(48,2,106))
			Terrain:FillBlock(CFrame.new(carve),volume,Enum.Material.Air);count+=1
		end
	end
	return {foundations=count}
end
function V.forest(first,count,region)
	current();local trees=root.Decor:FindFirstChild("Forest") or folder("Forest",root.Decor)
	local placed=0
	for i=first,first+count-1 do
		local rng=Random.new(80819+i*179);local x,z
		for _=1,36 do
			local a=rng:NextNumber(if region then region.minX else -1910,if region then region.maxX else 1910)
			local b=rng:NextNumber(if region then region.minZ else -2130,if region then region.maxZ else 2130)
			local density=if b< -700 then .4 elseif a>950 and b<500 then .55 else 1
			if rng:NextNumber()<density and safe(a,b,20) then x,z=a,b;break end
		end
		if x then
			local y=Base.terrainHeight(x,z)
			local kind=if x>1000 and z>-900 and z<450 then "willow"
				elseif z< -700 then (if i%4==0 then "oak" else "birch")
				elseif x< -550 or z>650 then "pine" else (if i%5==0 then "oak" else "pine")
			local scale=rng:NextNumber(.73,1.25)*(if y>400 then .65 else 1)
			local m=Kit.tree(trees,kind,world(x,y,z),scale,i*97)
			m.Name=string.format("%s_%04d",kind,i);m:SetAttribute("EnvironmentRegion",if z< -650 then "SouthernMeadows" elseif x>950 then "EasternWetland" elseif z>1350 then "NorthernSlopes" else "OldForest")
			placed+=1
		end
		if i%25==0 then task.wait() end
	end
	root:SetAttribute("TreesPlaced",#trees:GetChildren())
	return {stage="Forest",batch=first,placed=placed,total=#trees:GetChildren()}
end
function V.plants(first,count)
	current();local plants=root.Decor:FindFirstChild("Understory") or folder("Understory",root.Decor)
	local placed=0
	for i=first,first+count-1 do
		local rng=Random.new(27273+i*59);local x,z
		-- Concentrate detail at explored routes instead of uniformly filling wilderness.
		local s=segments[(i*37)%#segments+1]
		for _=1,15 do
			local t=rng:NextNumber();local p=s.a:Lerp(s.b,t);local d=Vector3.new(-(s.b-s.a).Z,0,(s.b-s.a).X).Unit
			p+=d*(s.half+rng:NextNumber(8,100))*(if i%2==0 then -1 else 1)
			if safe(p.X,p.Z,3) then x,z=p.X,p.Z;break end
		end
		if x then
			local y=Base.terrainHeight(x,z)
			local kind=if x>950 and z>-900 and z<500 then "reed" elseif z< -600 then "grass" else "fern"
			local m=Kit.plant(plants,kind,world(x,y,z),rng:NextNumber(.7,1.5),i*21);m.Name=kind.."_"..i
			placed+=1
		end
		if i%50==0 then task.wait() end
	end
	return {stage="Plants",batch=first,placed=placed,total=#plants:GetChildren()}
end
function V.rocks(first,count)
	current();local rocks=root.Decor:FindFirstChild("Outcrops") or folder("Outcrops",root.Decor)
	local placed=0
	for i=first,first+count-1 do
		local rng=Random.new(9531+i*83);local x,z
		for _=1,30 do
			local a,b=rng:NextNumber(-1930,1930),rng:NextNumber(-2100,2150)
			if safe(a,b,36) then x,z=a,b;break end
		end
		if x then
			local y=Base.terrainHeight(x,z);local scale=rng:NextNumber(.8,2.3)
			local m=Kit.rock(rocks,world(x,y,z),scale,i*13);m.Name="Outcrop_"..i;placed+=1
			if i%9==0 then Kit.log(rocks,world(x+12,y,z+10),rng:NextNumber(30,65),rng:NextNumber(0,6.28),i*31) end
		end
		if i%25==0 then task.wait() end
	end
	return {stage="Rocks",batch=first,placed=placed}
end
function V.finish()
	current()
	local a=Config.position(Base.zone("A"));local d=workspace.Dinosaur01_TRex_Visual
	-- Keep the rig/scale/rotation. Translate its authored foot anchor to A's new pad.
	local support=d.PrimaryPart.CFrame:PointToWorldSpace(Vector3.new(4.6155128,-23.162859,5.200428))
	local shift=Vector3.new(a.X,a.Y+.23,a.Z)-support
	d:PivotTo(d:GetPivot()+shift);d:SetAttribute("HuntingZone","A")
	for _,spec in {{world(-2000,320,0),Vector3.new(4,900,4500)},{world(2000,320,0),Vector3.new(4,900,4500)},
		{world(0,320,-2250),Vector3.new(4000,900,4)},{world(0,320,2250),Vector3.new(4000,900,4)}} do
		local wall=part("Boundary",spec[2],CFrame.new(spec[1]),Enum.Material.Rock,root.Boundaries,true);wall.Transparency=1;wall.CastShadow=false
	end
	root:SetAttribute("BuildStage","Complete");root:SetAttribute("RouteAIReady",true)
	root:SetAttribute("TerrainTilesComplete",32*36);root:SetAttribute("LandscapeVersion","GreyMistValley.1")
	workspace.CurrentCamera.CFrame=CFrame.lookAt(world(2600,1750,-2800),world(0,120,0))
	return {stage="Complete",trees=root:GetAttribute("TreesPlaced"),paths=#root.Paths:GetChildren(),zones=#root.Zones:GetChildren()}
end
return V
