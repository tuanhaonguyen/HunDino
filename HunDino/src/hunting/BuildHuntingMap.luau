-- EDIT ONLY. Builds the approved hunting layout into a NEW saved place.
-- No Terrain:Clear, no L0 rebuild, no modification of the source dinosaur file.
local B={}
local Config=require(game:GetService("ReplicatedStorage"):WaitForChild("HuntingMapConfig"))
local Terrain=workspace.Terrain
local root
local colors={earth=Color3.fromRGB(112,104,73),grass=Color3.fromRGB(75,100,64),
	moss=Color3.fromRGB(65,91,60),rock=Color3.fromRGB(94,103,99),wood=Color3.fromRGB(75,59,43),
	leaf=Color3.fromRGB(46,83,53),leaf2=Color3.fromRGB(71,110,62),canvas=Color3.fromRGB(131,112,77),
	water=Color3.fromRGB(51,100,104),glow=Color3.fromRGB(110,226,193)}
local allSamples={}
local function model(name,parent)
	local o=Instance.new("Model");o.Name=name;o.Parent=parent;return o
end
local function folder(name,parent)
	local o=Instance.new("Folder");o.Name=name;o.Parent=parent;return o
end
local function part(name,size,cf,color,material,parent,collide)
	local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
	p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true
	p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
	p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=collide==true
	p.CastShadow=collide==true;p.Parent=parent;return p
end
local function ball(name,size,position,color,parent,collide)
	local p=part(name,size,CFrame.new(position),color,Enum.Material.Grass,parent,collide)
	local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p;return p
end
local function beam(name,a,b,r,color,material,parent,collide)
	local x=(b-a).Unit
	local reference=if math.abs(x.Y)>.9 then Vector3.zAxis else Vector3.yAxis
	local z=x:Cross(reference).Unit;local y=z:Cross(x).Unit
	local cf=CFrame.fromMatrix((a+b)/2,x,y,z)
	local p=part(name,Vector3.new((b-a).Magnitude,r*2,r*2),cf,color,material,parent,collide)
	p.Shape=Enum.PartType.Cylinder;return p
end
local function sign(text,pos,parent,small)
	local anchor=part("SignAnchor",Vector3.one,CFrame.new(pos),colors.wood,Enum.Material.Wood,parent,false)
	anchor.Transparency=1
	local gui=Instance.new("BillboardGui");gui.Name="ZoneSign";gui.Size=UDim2.fromOffset(small and 110 or 220,small and 35 or 50)
	gui.AlwaysOnTop=false;gui.MaxDistance=small and 350 or 950;gui.StudsOffsetWorldSpace=Vector3.new(0,7,0);gui.Parent=anchor
	local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1
	label.Text=text;label.TextColor3=Color3.fromRGB(230,235,209);label.TextStrokeColor3=Color3.fromRGB(30,44,35)
	label.TextStrokeTransparency=.25;label.Font=Enum.Font.GothamMedium;label.TextSize=small and 13 or 16;label.Parent=gui
	return anchor
end
local function rootNow()
	root=assert(workspace:FindFirstChild("HuntingRainforest"),"Begin hunting map first")
	return root
end
local function distanceSegment(x,z,a,b)
	local dx,dz=b.X-a.X,b.Z-a.Z
	local t=math.clamp(((x-a.X)*dx+(z-a.Z)*dz)/math.max(1,dx*dx+dz*dz),0,1)
	return math.sqrt((x-a.X-dx*t)^2+(z-a.Z-dz*t)^2)
end
local function prepareSamples()
	if #allSamples>0 then return end
	for _,e in Config.Edges do table.insert(allSamples,Config.samples(e,24)) end
	for _,e in Config.HumanPaths do table.insert(allSamples,Config.samples(e,24)) end
end
local function safe(x,z,margin)
	local s=Config.PlanarScale
	if math.sqrt((x/(155*s))^2+(z/(160*s))^2)<1 then return false end
	for _,q in Config.Zones do
		local p=Config.position(q)
		if (Vector2.new(x-p.X,z-p.Z)).Magnitude<q.width*s*.55+margin then return false end
	end
	prepareSamples()
	for _,samples in allSamples do
		for i=1,#samples-1 do
			if distanceSegment(x,z,samples[i],samples[i+1])<Config.RoadWidth/2+margin then return false end
		end
	end
	return true
end
function B.begin()
	assert(not game:GetService("RunService"):IsRunning(),"Build only in Studio Edit")
	assert(not workspace:FindFirstChild("HuntingRainforest"),"Map already exists; inspect it before replacing anything")
	assert(workspace:FindFirstChild("Dinosaur01_TRex_Visual"),"Keep the existing dinosaur prototype")
	root=model("HuntingRainforest",workspace);root:SetAttribute("Version",Config.Version)
	root:SetAttribute("PlanarScale",Config.PlanarScale);root:SetAttribute("MapSize",Config.MapSize)
	root:SetAttribute("BuildStage","Begin");root:SetAttribute("RouteAIReady",false)
	for _,name in {"Zones","Paths","Decor","Camp","Boundaries","Network"} do folder(name,root) end
	local backup=folder("HuntingSourceBackup",game:GetService("ServerStorage"))
	workspace.Dinosaur01_TRex_Visual:Clone().Parent=backup
	local plate=workspace:FindFirstChild("Baseplate");if plate then plate.Parent=backup end
	for _,pair in {{game:GetService("StarterPlayer").StarterPlayerScripts,"DinosaurPreviewControls"},
		{game:GetService("ServerScriptService"),"DinosaurPreviewBridge"}} do
		local o=pair[1]:FindFirstChild(pair[2]);if o then o.Disabled=true;o.Parent=backup end
	end
	local command=game:GetService("ReplicatedStorage"):FindFirstChild("DinosaurPreviewCommand")
	if command then command.Parent=backup end
	Terrain.WaterColor=colors.water;Terrain.WaterTransparency=.38;Terrain.WaterReflectance=.18
	Terrain.WaterWaveSize=.14;Terrain.WaterWaveSpeed=4
	Terrain:SetMaterialColor(Enum.Material.Grass,colors.grass)
	Terrain:SetMaterialColor(Enum.Material.LeafyGrass,Color3.fromRGB(68,92,57))
	Terrain:SetMaterialColor(Enum.Material.Ground,colors.earth)
	Terrain:SetMaterialColor(Enum.Material.Rock,colors.rock)
	return {stage="Begin",savedSource=backup:GetFullName(),mapSize=Config.MapSize}
end
function B.terrain(firstColumn,columnCount)
	rootNow();local half=Config.TerrainHalf;local total=half*2/4
	local y0,y1=Config.TerrainMin,Config.TerrainMax;local ny=(y1-y0)/4
	local ending=math.min(total,firstColumn+columnCount)
	for start=firstColumn,ending-1,12 do
		local nx=math.min(12,ending-start);local materials,occupancy={},{}
		local heights={};local wet={};local roads={}
		for ix=1,nx do
			materials[ix]={};occupancy[ix]={};heights[ix]={};wet[ix]={};roads[ix]={}
			local x=-half+(start+ix-.5)*4
			for iz=1,total do
				local z=-half+(iz-.5)*4
				heights[ix][iz],roads[ix][iz]=Config.terrainHeight(x,z)
				wet[ix][iz]=(x/(132*Config.PlanarScale))^2+(z/(138*Config.PlanarScale))^2<1
			end
			for iy=1,ny do
				materials[ix][iy]=table.create(total);occupancy[ix][iy]=table.create(total)
				local bottom=y0+(iy-1)*4
				for iz=1,total do
					local h=heights[ix][iz];local solid=math.clamp((h-bottom)/4,0,1)
					if solid>0 then
						materials[ix][iy][iz]=if bottom<h-13 then Enum.Material.Rock elseif bottom<h-4 or roads[ix][iz] then Enum.Material.Ground else Enum.Material.LeafyGrass
						occupancy[ix][iy][iz]=solid
					elseif wet[ix][iz] and bottom<Config.LakeLevel then
						materials[ix][iy][iz]=Enum.Material.Water;occupancy[ix][iy][iz]=math.clamp((Config.LakeLevel-bottom)/4,0,1)
					else materials[ix][iy][iz]=Enum.Material.Air;occupancy[ix][iy][iz]=0 end
				end
			end
		end
		local region=Region3.new(Vector3.new(-half+start*4,y0,-half),Vector3.new(-half+(start+nx)*4,y1,half))
		Terrain:WriteVoxels(region,4,materials,occupancy)
		root:SetAttribute("TerrainColumnsComplete",start+nx)
		task.wait()
	end
	return {stage="Terrain",columnsComplete=ending,total=total}
end
function B.paths()
	rootNow();assert(#root.Zones:GetChildren()==0,"Paths were already installed")
	for _,q in Config.Zones do
		local zone=model(q.id,root.Zones);zone:SetAttribute("Kind",q.kind);zone:SetAttribute("Width",q.width*Config.PlanarScale)
		zone:SetAttribute("DisplayName",q.name)
		local pos=Config.position(q)
		local node=part("Node",Vector3.one,CFrame.new(pos),colors.grass,Enum.Material.Grass,zone,false)
		node.Transparency=1;node:SetAttribute("ZoneId",q.id);zone.PrimaryPart=node
		local disc=part("Clearing",Vector3.new(2,q.width*Config.PlanarScale,q.width*Config.PlanarScale),
			CFrame.new(pos-Vector3.new(0,.3,0))*CFrame.Angles(0,0,math.pi/2),colors.earth,Enum.Material.Ground,zone,true)
		disc.Shape=Enum.PartType.Cylinder;disc:SetAttribute("CombatSpace",q.kind=="Main")
		sign(q.id.." · "..q.name,pos+Vector3.new(0,q.kind=="Main" and 21 or 12,0),zone,false)
	end
	local edges={};for _,e in Config.Edges do table.insert(edges,{edge=e,width=Config.RoadWidth}) end
	for _,e in Config.HumanPaths do table.insert(edges,{edge=e,width=24,human=true}) end
	for _,item in edges do
		local e=item.edge;local path=model(e.a.."_"..e.b,nil)
		path:SetAttribute("FromZone",e.a);path:SetAttribute("ToZone",e.b)
		path:SetAttribute("Bidirectional",true);path:SetAttribute("HumanOnly",item.human==true)
		path:SetAttribute("WalkWidth",item.width)
		local samples=Config.samples(e,12)
		for i=1,#samples-1 do
			local a,b=samples[i]+Vector3.new(0,2.2,0),samples[i+1]+Vector3.new(0,2.2,0)
			local p=part("WalkSurface",Vector3.new(item.width,3,(b-a).Magnitude+2),
				CFrame.lookAt((a+b)/2-Vector3.new(0,1.5,0),b-Vector3.new(0,1.5,0)),colors.earth,Enum.Material.Ground,path,true)
			p:SetAttribute("SampleIndex",i);p:SetAttribute("RouteStart",a);p:SetAttribute("RouteEnd",b);p:SetAttribute("WalkWidth",item.width)
			if i%6==0 then
				local node=part(string.format("W%03d",i),Vector3.one,CFrame.new(a),colors.glow,Enum.Material.SmoothPlastic,path,false)
				node.Transparency=1;node:SetAttribute("Waypoint",true)
			end
		end
		path.Parent=root.Paths;task.wait()
	end
	root:SetAttribute("BuildStage","Paths");return {zones=#root.Zones:GetChildren(),paths=#root.Paths:GetChildren()}
end
local function tree(x,z,scale,giant,index)
	local m=model((giant and "AncientTree_" or "Tree_")..index,nil)
	local y=Config.height(x,z);local h=(giant and 112 or 58)*scale;local radius=(giant and 7 or 3.3)*scale
	local variation=if type(index)=="number" then index else 0
	beam("Trunk",Vector3.new(x,y-2,z),Vector3.new(x,y+h,z),radius,colors.wood,Enum.Material.Wood,m,true)
	for j=1,3 do
		local a=j*2.094+variation;local offset=Vector3.new(math.sin(a),0,math.cos(a))
		beam("Branch",Vector3.new(x,y+h*.62,z),Vector3.new(x,y+h*.9,z)+offset*h*.28,radius*.5,colors.wood,Enum.Material.Wood,m,false)
		local crown=ball("Canopy",Vector3.new(h*.8,h*.36,h*.73),Vector3.new(x,y+h,z)+offset*h*.23,j%2==0 and colors.leaf or colors.leaf2,m,false)
		crown.CastShadow=true
	end
	if giant then
		for j=1,4 do
			local a=j*math.pi/2
			beam("ButtressRoot",Vector3.new(x,y+20,z),Vector3.new(x+math.sin(a)*33,y+1,z+math.cos(a)*33),3.5,colors.wood,Enum.Material.Wood,m,true)
			local vx,vz=x+math.sin(a)*24,z+math.cos(a)*24
			beam("HangingVine",Vector3.new(vx,y+h*.95,vz),Vector3.new(vx+3,y+35,vz+2),.65,colors.moss,Enum.Material.Grass,m,false)
		end
	end
	m.Parent=root.Decor;return m
end
function B.forest(first,count)
	rootNow();prepareSamples();local placed=0
	for index=first,first+count-1 do
		local rng=Random.new(31983+index*79);local x,z
		local giant=index%19==0
		for _=1,140 do
			local cx,cz=rng:NextNumber(-680,680),rng:NextNumber(-680,680)
			if safe(cx,cz,giant and 55 or 24) then x,z=cx,cz;break end
		end
		if x then tree(x,z,rng:NextNumber(.8,1.3),giant,index);placed+=1 end
		if index%25==0 then task.wait() end
	end
	return {stage="Forest",batch=first,trees=placed}
end
function B.rocks()
	rootNow();prepareSamples();local rng=Random.new(90123);local count=0
	for index=1,65 do
		local angle=index/65*math.pi*2;local x,z=math.sin(angle)*790,math.cos(angle)*790
		local radius=rng:NextNumber(46,72)
		if not (z>650 and math.abs(x)<210) and safe(x,z,radius+25) then
			local m=model("BoundaryCliff_"..index,nil)
			local y=Config.height(x,z)
			local p=ball("Stone",Vector3.new(radius*2,radius*3.7,radius*1.8),Vector3.new(x,y+radius*.8,z),colors.rock,m,true)
			p.Material=Enum.Material.Rock;p.CFrame*=CFrame.Angles(.15,angle,.12)
			ball("MossCap",Vector3.new(radius*1.7,radius*.38,radius*1.4),p.Position+Vector3.new(0,radius*1.5,0),colors.moss,m,false)
			m.Parent=root.Decor;count+=1
		end
		if index%12==0 then task.wait() end
	end
	for i=1,65 do
		local x,z=rng:NextNumber(-740,740),rng:NextNumber(-740,740)
		if safe(x,z,28) then
			local m=model("MossRock_"..i,nil);local r=rng:NextNumber(8,16)
			local p=ball("Stone",Vector3.new(r*2,r*1.4,r*1.8),Vector3.new(x,Config.height(x,z)+r*.3,z),colors.rock,m,true)
			p.Material=Enum.Material.Rock
			ball("Moss",Vector3.new(r*1.8,2,r*1.4),p.Position+Vector3.new(0,r*.58,0),colors.moss,m,false)
			m.Parent=root.Decor
		end
	end
	local half=Config.MapSize/2
	for _,spec in {{Vector3.new(-half,85,0),Vector3.new(4,270,Config.MapSize)},
		{Vector3.new(half,85,0),Vector3.new(4,270,Config.MapSize)},
		{Vector3.new(0,85,-half),Vector3.new(Config.MapSize,270,4)},
		{Vector3.new(0,85,half),Vector3.new(Config.MapSize,270,4)}} do
		local wall=part("Boundary",spec[2],CFrame.new(spec[1]),colors.rock,Enum.Material.Rock,root.Boundaries,true)
		wall.Transparency=1;wall.CastShadow=false
	end
	return {stage="Cliffs",cliffs=count}
end
function B.undergrowth()
	rootNow();prepareSamples();local rng=Random.new(77123)
	for i=1,155 do
		local x,z=rng:NextNumber(-720,720),rng:NextNumber(-720,720)
		if safe(x,z,9) then
			local m=model("Fern_"..i,nil);local y=Config.height(x,z)
			for j=1,5 do
				local angle=j*1.2566;local delta=Vector3.new(math.sin(angle)*6,3,math.cos(angle)*6)
				local leaf=ball("Frond",Vector3.new(4,1,17),Vector3.new(x,y+3,z)+delta,colors.leaf2,m,false)
				leaf.CFrame*=CFrame.Angles(.28,angle,0)
			end
			m.Parent=root.Decor
		end
		if i%40==0 then task.wait() end
	end
	for i=1,95 do
		local samples=allSamples[rng:NextInteger(1,#allSamples)];local k=rng:NextInteger(2,#samples-1)
		local p=samples[k];local t=(samples[k+1]-samples[k-1]).Unit
		local side=i%2==0 and 1 or -1;local pos=p+Vector3.new(-t.Z,0,t.X)*(Config.RoadWidth*.5+9)*side
		if math.sqrt(pos.X^2+pos.Z^2)>Config.PlanarScale*145 then
			local m=model("GlowMushroom_"..i,nil);local y=Config.height(pos.X,pos.Z)
			beam("Stem",Vector3.new(pos.X,y,pos.Z),Vector3.new(pos.X,y+3.5,pos.Z),.7,colors.canvas,Enum.Material.Wood,m,false)
			local cap=ball("Cap",Vector3.new(6,2.3,6),Vector3.new(pos.X,y+4,pos.Z),colors.glow,m,false)
			cap.Material=Enum.Material.Neon
			if i%8==0 then local light=Instance.new("PointLight");light.Color=colors.glow;light.Range=18;light.Brightness=.8;light.Shadows=false;light.Parent=cap end
			m.Parent=root.Decor
		end
	end
	return {stage="Plants",decorModels=#root.Decor:GetChildren()}
end
function B.landmarks()
	rootNow();local q=Config.zone("Camp");local p=Config.position(q);local camp=root.Camp
	local tent=model("CanvasTent",camp)
	for _,side in {-1,1} do
		local roof=part("Canvas",Vector3.new(38,1.1,46),CFrame.new(p+Vector3.new(side*14,16,-20))*CFrame.Angles(0,0,-side*math.rad(42)),colors.canvas,Enum.Material.Fabric,tent,false)
		roof.CanQuery=false
		beam("TentPole",p+Vector3.new(side*29,0,-41),p+Vector3.new(0,30,-41),1.1,colors.wood,Enum.Material.Wood,tent,false)
		beam("TentPole",p+Vector3.new(side*29,0,3),p+Vector3.new(0,30,3),1.1,colors.wood,Enum.Material.Wood,tent,false)
	end
	for i=1,4 do part("SupplyCrate",Vector3.new(9,8,9),CFrame.new(p+Vector3.new(44,4,-32+i*12)),colors.wood,Enum.Material.WoodPlanks,camp,true) end
	for _,side in {-1,1} do
		local base=p+Vector3.new(side*57,0,27)
		beam("LanternPost",base,base+Vector3.new(0,17,0),1,colors.wood,Enum.Material.Wood,camp,true)
		local lamp=ball("Lantern",Vector3.new(3,4,3),base+Vector3.new(0,18,0),Color3.fromRGB(255,191,111),camp,false)
		lamp.Material=Enum.Material.Neon
		local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,193,118);light.Range=45;light.Brightness=1.4;light.Parent=lamp
	end
	local spawn=assert(workspace:FindFirstChildOfClass("SpawnLocation"),"Keep the original player SpawnLocation")
	spawn.Name="CampSpawn";spawn.CFrame=CFrame.new(p+Vector3.new(0,1.3,43));spawn.Size=Vector3.new(12,1,12)
	spawn.Transparency=1;spawn.CanCollide=false;spawn.CanTouch=false;spawn.Duration=0;spawn.Neutral=true;spawn.Parent=camp
	local arrival=part("CampArrival",Vector3.one,CFrame.new(p+Vector3.new(0,5,43)),colors.grass,Enum.Material.Grass,camp,false)
	arrival.Transparency=1
	local r1=Config.position(Config.zone("R1"));tree(r1.X-119,r1.Z+35,1.15,true,"RestR1")
	local r2=Config.position(Config.zone("R2"))
	for _,side in {-1,1} do
		local rock=ball("RestR2Stone",Vector3.new(43,54,46),r2+Vector3.new(-116,18,side*49),colors.rock,root.Decor,true)
		rock.Material=Enum.Material.Rock
	end
	local ruin=model("R3Ruins",root.Decor);local r3=Config.position(Config.zone("R3"))+Vector3.new(0,0,125)
	for _,side in {-1,1} do
		part("AncientPillar",Vector3.new(13,57,15),CFrame.new(r3+Vector3.new(side*104,28,-25)),colors.rock,Enum.Material.Slate,ruin,true)
		ball("Moss",Vector3.new(19,5,19),r3+Vector3.new(side*104,56,-25),colors.moss,ruin,false)
	end
	part("Lintel",Vector3.new(223,9,19),CFrame.new(r3+Vector3.new(0,60,-25)),colors.rock,Enum.Material.Slate,ruin,true)
	for i=1,12 do beam("RuinVine",r3+Vector3.new(-97+i*15,64,-14),r3+Vector3.new(-95+i*15,30+i%4*5,-11),.75,colors.moss,Enum.Material.Grass,ruin,false) end
	local r4=Config.position(Config.zone("R4"))
	local pool=part("R4ShallowWater",Vector3.new(1,35,43),CFrame.new(r4+Vector3.new(49,.85,33))*CFrame.Angles(0,0,math.pi/2),colors.water,Enum.Material.Glass,root.Decor,false)
	pool.Shape=Enum.PartType.Cylinder;pool.Transparency=.28;pool.Reflectance=.15
	local r5=Config.position(Config.zone("R5"))
	for i=1,8 do
		local a=i*math.pi/4;local pos=r5+Vector3.new(math.sin(a)*90,3,math.cos(a)*90)
		local leaf=ball("RestR5Fern",Vector3.new(17,5,22),pos,colors.leaf2,root.Decor,false);leaf.CFrame*=CFrame.Angles(0,a,.12)
	end
	root:SetAttribute("BuildStage","Landmarks");return {stage="Landmarks",campArrival=tostring(arrival.Position)}
end
function B.finish()
	rootNow();local d=workspace.Dinosaur01_TRex_Visual;local cf,size=d:GetBoundingBox();local a=Config.position(Config.zone("A"))
	local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances={Terrain,root.Paths,root.Zones};params.IgnoreWater=true;params.RespectCanCollide=true
	local hit=workspace:Raycast(a+Vector3.new(0,100,0),Vector3.new(0,-180,0),params)
	local target=Vector3.new(a.X,hit and hit.Position.Y+.08 or a.Y+2.3,a.Z)
	local shift=Vector3.new(target.X-cf.X,target.Y-(cf.Y-size.Y/2),target.Z-cf.Z)
	d:PivotTo(d:GetPivot()+shift);d:SetAttribute("HuntingZone","A");d:SetAttribute("PreviewWalking",false)
	d:SetAttribute("BitePreviewEnabled",false);d:SetAttribute("MapRole","ExistingPrototype_NoRouteAI")
	root:SetAttribute("BuildStage","Complete");root:SetAttribute("AnimalZoneCount",8)
	root:SetAttribute("PrototypeDinosaurCount",1);root:SetAttribute("MissionSystemReady",false)
	local camera=workspace.CurrentCamera
	camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(Vector3.new(1300,1240,1570),Vector3.new(0,25,0));camera.FieldOfView=55
	return {stage="Complete",zones=8,camp=true,paths=#root.Paths:GetChildren(),decor=#root.Decor:GetChildren(),dinosaurSize=tostring(size)}
end
return B
