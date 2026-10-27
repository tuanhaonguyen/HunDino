-- Read-only H2 Studio validation. Run in Edit or Server through execute_luau.
-- Never moves Instances, starts controllers, changes Terrain, or changes script state.
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local report={version="GreyMistValleyValidation.1",context=if RunService:IsRunning() then "Server" else "Edit",
	ok=false,checks=0,passed=0,failures={},metrics={raycasts=0,overlapQueries=0},zones={},paths={},water={},blockers={}}
local function number(n) return math.floor(n*1000+.5)/1000 end
local function point(v) return {x=number(v.X),y=number(v.Y),z=number(v.Z)} end
local function near(a,b,t) return typeof(a)=="Vector3" and typeof(b)=="Vector3" and (a-b).Magnitude<=(t or .1) end
local function check(ok,code,detail)
	report.checks+=1
	if ok then report.passed+=1 else table.insert(report.failures,{code=code,detail=detail}) end
	return ok
end
local operations=0
local function yieldQuery()
	operations+=1;if operations%150==0 then task.wait() end
end
local function section(name,callback)
	local ok,err=xpcall(callback,debug.traceback)
	if not ok then check(false,"SECTION_ERROR",{section=name,error=tostring(err)}) end
end
local forest=workspace:FindFirstChild("HuntingRainforest")
if not check(forest~=nil,"FOREST_PRESENT","Workspace.HuntingRainforest") then return report end
local okConfig,config=pcall(function() return require(RS:FindFirstChild("HuntingMapConfig")) end)
local okBase,base=pcall(function() return require(RS:FindFirstChild("HuntingBaseConfig")) end)
if not check(okConfig and okBase and type(config)=="table" and type(base)=="table","CONFIGS_REQUIRE",{adapter=tostring(config),base=tostring(base)}) then return report end
local offset=config.WorldOffset or Vector3.new(0,0,6500)
local function world(x,y,z) return offset+Vector3.new(x,y,z) end
local terrainParams=RaycastParams.new();terrainParams.FilterType=Enum.RaycastFilterType.Include
terrainParams.FilterDescendantsInstances={workspace.Terrain};terrainParams.RespectCanCollide=true;terrainParams.IgnoreWater=true
local wetParams=RaycastParams.new();wetParams.FilterType=Enum.RaycastFilterType.Include
wetParams.FilterDescendantsInstances={workspace.Terrain};wetParams.RespectCanCollide=false;wetParams.IgnoreWater=false
local walkingParams=RaycastParams.new();walkingParams.FilterType=Enum.RaycastFilterType.Include
walkingParams.FilterDescendantsInstances={workspace.Terrain,forest:FindFirstChild("Paths"),forest:FindFirstChild("Zones")}
walkingParams.RespectCanCollide=true;walkingParams.IgnoreWater=true
local function ray(p,params)
	report.metrics.raycasts+=1;yieldQuery()
	return workspace:Raycast(Vector3.new(p.X,offset.Y+780,p.Z),Vector3.new(0,-880,0),params or terrainParams)
end
local function within(p,margin)
	local q=p-offset;return math.abs(q.X)<=2000+(margin or 0) and math.abs(q.Z)<=2250+(margin or 0)
end
section("Dimensions",function()
	check(config.MapWidth==4000 and config.MapDepth==4500,"CONFIG_DIMENSIONS",{width=config.MapWidth,depth=config.MapDepth})
	check(near(offset,Vector3.new(0,0,6500),.01),"WORLD_OFFSET",point(offset))
	check(forest:GetAttribute("Version")=="H2.0","H2_VERSION",tostring(forest:GetAttribute("Version")))
	check(forest:GetAttribute("MapWidth")==4000 and forest:GetAttribute("MapDepth")==4500,"ROOT_DIMENSIONS","4000 × 4500")
	check(near(forest:GetAttribute("WorldOffset"),offset,.01),"ROOT_OFFSET",tostring(forest:GetAttribute("WorldOffset")))
	check(forest:GetAttribute("BuildStage")=="Complete","BUILD_COMPLETE",tostring(forest:GetAttribute("BuildStage")))
	check(forest:GetAttribute("TerrainTilesComplete")==1152,"TERRAIN_TILES",forest:GetAttribute("TerrainTilesComplete"))
	check(near(forest:GetAttribute("TerrainWriteBoundsMin"),world(-2000,-64,-2252),.1),"TERRAIN_WRITE_MIN","Bounded hunting rectangle")
	check(near(forest:GetAttribute("TerrainWriteBoundsMax"),world(2000,704,2252),.1),"TERRAIN_WRITE_MAX","Bounded hunting rectangle")
	check(offset.Z-2252>4000,"HUB_SEPARATION",{huntingMinimumZ=offset.Z-2252})
	local boundary=forest:FindFirstChild("Boundaries");local n=0
	for _,p in boundary and boundary:GetChildren() or {} do
		if p:IsA("BasePart") then n+=1;check(p.CanCollide and p.Transparency==1,"BOUNDARY_PHYSICS",p:GetFullName()) end
	end
	check(n==4,"BOUNDARY_COUNT",n)
end)
section("Nodes",function()
	local zones=forest:FindFirstChild("Zones");check(zones and #zones:GetChildren()==9,"NINE_NODES",zones and #zones:GetChildren() or 0)
	local animals,camps=0,0
	for _,q in config.Zones do
		if q.kind=="Camp" then camps+=1 else animals+=1 end
		local m=zones and zones:FindFirstChild(q.id);local node=m and m:FindFirstChild("Node")
		local expected=config.position(q);local row={id=q.id,expected=point(expected)};table.insert(report.zones,row)
		if check(node and node:IsA("BasePart"),"NODE_PRESENT",q.id) then
			row.actual=point(node.Position);check(near(node.Position,expected,.1),"NODE_LOCATION",row)
			check(within(node.Position),"NODE_BOUNDS",row)
			check(m:GetAttribute("Width")==q.width,"NODE_WIDTH",{id=q.id,actual=m:GetAttribute("Width"),expected=q.width})
			local clearing=m:FindFirstChild("Clearing")
			check(clearing and clearing.CanCollide and clearing.Transparency==1,"INVISIBLE_CLEARING",q.id)
			local native=ray(expected);local physical=ray(expected,walkingParams)
			row.terrainY=native and number(native.Position.Y);row.walkingY=physical and number(physical.Position.Y)
			check(native and math.abs(native.Position.Y-expected.Y)<=4,"NODE_NATIVE_TERRAIN",row)
			check(physical and math.abs(physical.Position.Y-(expected.Y+.15))<=.6,"NODE_PHYSICAL_GROUND",row)
		end
		if q.kind=="Main" then check(q.width>=280,"MAIN_CLEARING_WIDTH",{id=q.id,width=q.width}) end
		if q.kind=="Rest" then check(q.width>=200,"REST_CLEARING_WIDTH",{id=q.id,width=q.width}) end
	end
	check(animals==8 and camps==1,"ANIMAL_AND_CAMP_COUNTS",{animals=animals,camps=camps})
end)
local allRoads={}
section("Paths",function()
	local paths=forest:FindFirstChild("Paths");check(paths and #paths:GetChildren()==16,"SIXTEEN_CORRIDORS",paths and #paths:GetChildren() or 0)
	local animal,human,surfaces,maxSlope=0,0,0,0
	for _,group in {{edges=config.Edges,human=false,width=72},{edges=config.HumanPaths,human=true,width=24}} do
		for _,edge in group.edges do
			local name=edge.a.."_"..edge.b;local path=paths and paths:FindFirstChild(name)
			local row={name=name,humanOnly=group.human,segments=0,groundProbes=0,maxSlope=0};table.insert(report.paths,row)
			if not check(path and path:IsA("Model"),"PATH_PRESENT",name) then continue end
			if group.human then human+=1 else animal+=1 end
			check(path:GetAttribute("FromZone")==edge.a and path:GetAttribute("ToZone")==edge.b and path:GetAttribute("Bidirectional")==true,"PATH_TWO_WAY",name)
			check(path:GetAttribute("HumanOnly")==group.human and path:GetAttribute("WalkWidth")==group.width,"PATH_KIND_AND_WIDTH",name)
			local samples=config.samples(edge,16);local pieces={}
			for _,p in path:GetChildren() do if p:IsA("BasePart") and p.Name=="WalkSurface" then table.insert(pieces,p) end end
			table.sort(pieces,function(a,b) return (a:GetAttribute("SampleIndex") or 0)<(b:GetAttribute("SampleIndex") or 0) end)
			row.segments=#pieces;check(#pieces==#samples-1,"PATH_SEGMENT_COUNT",{path=name,actual=#pieces,expected=#samples-1})
			local points={};local previous
			for i,p in pieces do
				surfaces+=1
				local a,b=p:GetAttribute("RouteStart"),p:GetAttribute("RouteEnd")
				if not check(typeof(a)=="Vector3" and typeof(b)=="Vector3","PATH_ENDPOINT_ATTRIBUTES",{path=name,index=i}) then continue end
				if #points==0 then table.insert(points,a) end;table.insert(points,b)
				check(not previous or near(previous,a,.05),"PATH_CONTINUITY",{path=name,index=i,previous=previous and point(previous),start=point(a)})
				previous=b
				check(p.CanCollide and p.Transparency==1 and p.Size.X==group.width,"INVISIBLE_WALK_SURFACE",{path=name,index=i})
				-- Intersect the upper plane vertically at the slab's middle XZ.
				-- A local +Y face-center shifts sideways when the slab pitches,
				-- so comparing that point to the route center falsely flags slopes.
				local middle=a:Lerp(b,.5);local upY=p.CFrame.UpVector.Y
				local top=Vector3.new(p.Position.X,p.Position.Y+p.Size.Y*.5/math.max(.001,upY),p.Position.Z)
				local centerXZError=Vector2.new(p.Position.X-middle.X,p.Position.Z-middle.Z).Magnitude
				check(upY>.9 and centerXZError<=.01 and math.abs(top.Y-middle.Y)<=.08,"SURFACE_TOP_GEOMETRY",{path=name,index=i,top=point(top),expected=point(middle),centerXZError=number(centerXZError)})
				check(samples[i] and samples[i+1] and near(a,samples[i]+Vector3.new(0,.2,0),.08) and near(b,samples[i+1]+Vector3.new(0,.2,0),.08),"PATH_CONFIG_SAMPLES",{path=name,index=i})
				local horizontal=Vector2.new(b.X-a.X,b.Z-a.Z).Magnitude
				local slope=math.deg(math.atan2(math.abs(b.Y-a.Y),math.max(.001,horizontal)))
				row.maxSlope=math.max(row.maxSlope,slope);maxSlope=math.max(maxSlope,slope)
				check(slope<=18,"PATH_SLOPE",{path=name,index=i,degrees=number(slope)})
				check(within(a) and within(b),"PATH_BOUNDS",{path=name,index=i})
				if i==1 or i%6==0 or i==#pieces then
					local center=a:Lerp(b,.5);local side=Vector3.new(-(b-a).Z,0,(b-a).X).Unit
					-- Human flank probes also use ±28: they audit nearby Terrain, not a 72-wide human road.
					for _,shift in {0,-28,28} do
						local at=center+side*shift;local expected=config.terrainHeight(at.X,at.Z);local hit=ray(at)
						row.groundProbes+=1
						check(hit and math.abs(hit.Position.Y-expected)<=4,"NATIVE_ROUTE_GROUND",{path=name,index=i,flank=shift,at=point(at),expectedY=number(expected),actualY=hit and number(hit.Position.Y)})
						if shift==0 then
							local physical=ray(at,walkingParams)
							check(physical and math.abs(physical.Position.Y-center.Y)<=1,"WALKING_ROUTE_GROUND",{path=name,index=i,expectedY=number(center.Y),actualY=physical and number(physical.Position.Y)})
						end
					end
				end
			end
			row.maxSlope=number(row.maxSlope)
			table.insert(allRoads,{name=name,points=points,human=group.human});task.wait()
		end
	end
	report.metrics.pathSurfaces=surfaces;report.metrics.maxRoadSlopeDegrees=number(maxSlope)
	check(animal==13 and human==3,"CORRIDOR_COUNTS",{animal=animal,human=human})
end)
section("Network",function()
	local module=game:GetService("ServerScriptService"):FindFirstChild("DinosaurRouteController",true)
		or game:GetService("ServerStorage"):FindFirstChild("DinosaurRouteController",true)
	if check(module and module:IsA("ModuleScript"),"ROUTE_MODULE","DinosaurRouteController") then
		local network=require(module).ValidateNetwork(forest,config);report.network=network
		check(network.ok==true,"NETWORK_VALID",network.errors)
		check(network.paths==13 and network.routes==9,"NETWORK_13_PATHS_9_ROUTES",{paths=network.paths,routes=network.routes})
	end
	for home,routes in config.Routes do for i,route in routes do
		check(route[1]==home and route[#route]==home,"ROUTE_RETURNS_HOME",{home=home,index=i})
		for j=1,#route-1 do
			local a,b=route[j],route[j+1];local found=false
			for _,e in config.Edges do if (e.a==a and e.b==b) or (e.a==b and e.b==a) then found=true;break end end
			check(found,"ROUTE_EDGE_PRESENT",{home=home,index=i,from=a,to=b})
		end
	end end
end)
section("NativeWaterAndRelief",function()
	for _,item in {{name="Lake",x=-80,z=100,y=65},{name="Island",x=120,z=100,y=84},{name="Summit",x=120,z=2160,y=650.587}} do
		local at=world(item.x,0,item.z);local hit=ray(at,item.name=="Lake" and wetParams or terrainParams)
		local row={name=item.name,position=point(at),actualY=hit and number(hit.Position.Y),material=hit and hit.Material.Name}
		table.insert(report.water,row)
		check(hit and math.abs(hit.Position.Y-item.y-offset.Y)<=4,"NATIVE_"..item.name:upper(),row)
		if item.name=="Lake" then check(hit and hit.Material==Enum.Material.Water,"NATIVE_LAKE_WATER",row) end
		if item.name=="Island" then check(hit and hit.Material~=Enum.Material.Water,"DRY_LAKE_ISLAND",row) end
	end
	local expectedWet,actualWet=0,0
	for _,x in {1150,1250,1400,1500,1600} do for _,z in {-550,-400,-50,100,200} do
		local h=base.terrainHeight(x,z);local water,kind=base.waterLevel(x,z,h)
		if kind=="Swamp" and water-h>1 and expectedWet<6 then
			expectedWet+=1;local at=world(x,0,z);local hit=ray(at,wetParams)
			local row={name="Swamp",position=point(at),actualY=hit and number(hit.Position.Y),expectedY=water+offset.Y,material=hit and hit.Material.Name}
			table.insert(report.water,row)
			if hit and hit.Material==Enum.Material.Water and math.abs(hit.Position.Y-water-offset.Y)<=4 then actualWet+=1 end
			check(hit and hit.Material==Enum.Material.Water,"NATIVE_SWAMP_WATER",row)
		end
	end end
	check(expectedWet>=3 and actualWet>=3,"SWAMP_WET_POCKETS",{expectedWet=expectedWet,actualWet=actualWet})
	report.metrics.swampWaterProbes=actualWet
end)
section("EnvironmentAndPortals",function()
	local decor=forest:FindFirstChild("Decor");local trees=decor and decor:FindFirstChild("Forest")
	report.metrics.trees=trees and #trees:GetChildren() or 0
	check(report.metrics.trees>=1700,"FOREST_DENSITY",{actual=report.metrics.trees,target=1800,minimum=1700})
	local landmarks=decor and decor:FindFirstChild("Landmarks")
	for _,name in {"01_RangerStation","03_OldPineRefuges","04_LakeLandmarks","06_AbandonedLoggingCamp","05_SwampBoardwalk","07_SplitStoneGorge","08_MountainCave"} do
		check(landmarks and landmarks:FindFirstChild(name),"LANDMARK_REGION",name)
	end
	-- Authored public mesh variants are accepted only through the reviewed,
	-- script-stripped template libraries. Matching exact MeshId strings also
	-- catches accidental asset substitutions in generated environment clones.
	local allowedMeshes={};local templateProof={};local templateCount=0;local templateMeshCount=0
	local storage=game:GetService("ServerStorage")
	local function inheritedAttribute(item,name,stop)
		local at=item
		while at do
			local value=at:GetAttribute(name)
			if value~=nil then return value end
			if at==stop then break end
			at=at.Parent
		end
		return nil
	end
	local function inspectLibrary(name,expected)
		local library=storage:FindFirstChild(name);local count=0;local meshes=0;local scripts=0
		if not check(library~=nil,"MESH_TEMPLATE_LIBRARY",name) then return end
		for _,item in library:GetDescendants() do
			if item:IsA("LuaSourceContainer") then scripts+=1;check(false,"NO_TEMPLATE_SCRIPTS",item:GetFullName()) end
			if item:IsA("Model") and (item.Parent==library or item.Parent:IsA("Folder")) then
				count+=1;templateCount+=1
				local source=inheritedAttribute(item,"SourceAssetId",library)
				local creator=inheritedAttribute(item,"SourceCreator",library)
				local proof={template=item:GetFullName(),sourceAssetId=source and tostring(source) or nil,sourceCreator=creator and tostring(creator) or nil,meshIds={}}
				check(source~=nil and tostring(source)~="" and creator~=nil and tostring(creator)~="","TEMPLATE_SOURCE_PROOF",proof)
				local seen={}
				for _,p in item:GetDescendants() do if p:IsA("MeshPart") then
					local id=tostring(p.MeshId);check(id~="","TEMPLATE_MESH_ID",p:GetFullName())
					if not seen[id] then table.insert(proof.meshIds,id);seen[id]=true end
					allowedMeshes[id]=allowedMeshes[id] or {};table.insert(allowedMeshes[id],proof.template)
				end end
				table.sort(proof.meshIds);table.insert(templateProof,proof)
			end
			if item:IsA("MeshPart") then meshes+=1;templateMeshCount+=1;check(item.Anchored,"TEMPLATE_ANCHORED",item:GetFullName()) end
		end
		check(count==expected,"MESH_TEMPLATE_COUNT",{library=name,actual=count,expected=expected})
		check(scripts==0 and meshes>0,"CLEAN_MESH_LIBRARY",{library=name,scripts=scripts,meshes=meshes})
	end
	inspectLibrary("ValleyTreeTemplates",25);inspectLibrary("ValleyRockTemplates",1)
	local whitelistCount=0;for _ in allowedMeshes do whitelistCount+=1 end
	report.meshSources=templateProof
	report.metrics.meshTemplates=templateCount;report.metrics.templateMeshParts=templateMeshCount
	report.metrics.allowedMeshIds=whitelistCount
	local scripts,meshes,parts,approvedMeshes=0,0,0,0
	for _,p in decor and decor:GetDescendants() or {} do
		if p:IsA("LuaSourceContainer") then scripts+=1;check(false,"NO_ENVIRONMENT_SCRIPTS",p:GetFullName()) end
		if p:IsA("MeshPart") then
			meshes+=1;local id=tostring(p.MeshId);local approved=allowedMeshes[id]~=nil
			if approved then approvedMeshes+=1 end
			check(approved,"APPROVED_ENVIRONMENT_MESH",{part=p:GetFullName(),meshId=id})
		end
		if p:IsA("BasePart") then parts+=1;check(p.Anchored,"ENVIRONMENT_ANCHORED",p:GetFullName()) end
	end
	check(scripts==0 and approvedMeshes==meshes,"CLEAN_APPROVED_ENVIRONMENT",{scripts=scripts,meshParts=meshes,approvedMeshes=approvedMeshes})
	report.metrics.environmentParts=parts
	report.metrics.environmentMeshParts=meshes;report.metrics.approvedEnvironmentMeshParts=approvedMeshes
	local camp=forest:FindFirstChild("Camp");local arrival=camp and camp:FindFirstChild("CampArrival")
	local at=config.position(config.zone("Camp"));local expected=at+Vector3.new(0,5,50)
	check(arrival and arrival:IsA("BasePart") and near(arrival.Position,expected,.1),"CAMP_ARRIVAL",{expected=point(expected),actual=arrival and point(arrival.Position)})
	check(arrival and within(arrival.Position) and (arrival.Position-at).Magnitude<=250,"CAMP_SAFE_ARRIVAL","Arrival inside 250-stud sanctuary")
	local portal=camp and camp:FindFirstChild("ReturnToLobby");local prompt=portal and portal:FindFirstChildWhichIsA("ProximityPrompt",true)
	check(prompt and prompt.Enabled and prompt.KeyboardKeyCode==Enum.KeyCode.G,"RETURN_PROMPT","Enabled G return portal")
	local anchor=prompt and (if prompt.Parent:IsA("BasePart") then prompt.Parent else prompt.Parent:FindFirstAncestorWhichIsA("BasePart"))
	check(anchor and within(anchor.Position) and (anchor.Position-at).Magnitude<=250,"RETURN_PORTAL_LOCATION",anchor and point(anchor.Position) or "Missing anchor")
	local spawn=camp and camp:FindFirstChild("CampSpawn");check(spawn and spawn:IsA("SpawnLocation") and not spawn.Enabled,"CAMP_SPAWN_DISABLED","Respawn remains at lobby")
end)
section("DinosaurAnatomyClearance",function()
	local dino=workspace:FindFirstChild("Dinosaur01_TRex_Visual");local root=dino and dino.PrimaryPart
	if not check(root~=nil,"DINOSAUR_ROOT","Preserved prototype PrimaryPart") then return end
	local forwardLocal=dino:GetAttribute("ForwardInRoot")
	if not check(typeof(forwardLocal)=="Vector3","DINOSAUR_FORWARD","ForwardInRoot") then return end
	local forward=root.CFrame:VectorToWorldSpace(forwardLocal);forward=Vector3.new(forward.X,0,forward.Z).Unit
	local footSum,footCount,footLow=Vector3.zero,0,math.huge
	for _,name in {"LeftHip","RightHip"} do
		local motor=dino:FindFirstChild(name,true)
		if not check(motor and motor:GetAttribute("FootSamples") and typeof(motor:GetAttribute("RestC0"))=="CFrame","FOOT_GEOMETRY",name) then return end
		for _,s in HttpService:JSONDecode(motor:GetAttribute("FootSamples")) do
			local p=motor:GetAttribute("RestC0"):PointToWorldSpace(Vector3.new(s[1],s[2],s[3]))
			footSum+=p;footCount+=1;footLow=math.min(footLow,p.Y)
		end
	end
	local support=root.CFrame:PointToWorldSpace(Vector3.new(footSum.X/footCount,footLow,footSum.Z/footCount))
	local anatomy=CFrame.lookAt(support,support+forward)
	local low,high=Vector3.new(math.huge,math.huge,math.huge),Vector3.new(-math.huge,-math.huge,-math.huge)
	for _,p in dino:GetDescendants() do
		if p:IsA("BasePart") and p:GetAttribute("CombatHitbox")~=true and not p:FindFirstAncestor("CombatHitboxes") then
			for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
				local corner=anatomy:PointToObjectSpace(p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)*.5));low=low:Min(corner);high=high:Max(corner)
			end end end
		end
	end
	local size=high-low+Vector3.new(2,1,2);local center=(high+low)*.5
	report.metrics.dinosaurBounds=point(size);report.metrics.dinosaurBoundsCenter=point(center)
	local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
	overlap.FilterDescendantsInstances={forest.Decor};overlap.RespectCanCollide=true;overlap.MaxParts=0
	local blockerMap={};local samples=0
	local function probe(road,p,direction)
		local hit=ray(p,walkingParams)
		if not check(hit~=nil,"DINO_SUPPORT_GROUND",{path=road,at=point(p)}) then return end
		for _,sign in {-1,1} do
			local cf=CFrame.lookAt(hit.Position,hit.Position+direction*sign)*CFrame.new(center+Vector3.new(0,.25,0))
			report.metrics.overlapQueries+=1;yieldQuery()
			local found=workspace:GetPartBoundsInBox(cf,size,overlap);samples+=1
			if #found>0 then
				local names={}
				for _,part in found do
					local name=part:GetFullName();table.insert(names,name)
					local item=blockerMap[name]
					if not item then item={name=name,position=point(part.Position),size=point(part.Size),samples={}};blockerMap[name]=item;table.insert(report.blockers,item) end
					table.insert(item.samples,{path=road,at=point(hit.Position),direction=sign})
				end
				check(false,"DINO_DECOR_OBSTRUCTION",{path=road,at=point(hit.Position),direction=sign,boxCenter=point(cf.Position),blockers=names})
			else check(true,"DINO_DECOR_CLEAR",road) end
		end
	end
	for _,road in allRoads do
		if road.human then continue end
		local travelled=80
		for i=1,#road.points-1 do
			local a,b=road.points[i],road.points[i+1];local delta=Vector3.new(b.X-a.X,0,b.Z-a.Z)
			if delta.Magnitude<.01 then continue end
			travelled+=delta.Magnitude
			if travelled>=80 or i==#road.points-1 then probe(road.name,a,delta.Unit);travelled=0 end
		end
		task.wait()
	end
	report.metrics.dinosaurClearanceSamples=samples;report.metrics.uniqueDecorBlockers=#report.blockers
	check(samples>=150,"FULL_ROUTE_CLEARANCE_COVERAGE",samples)
end)
report.ok=#report.failures==0
return report
