-- EDIT-only final polish. Creates only Decor.FinalDressing; existing scenery,
-- Terrain, Lighting, scripts, mesh sources and template credits are preserved.
local D={Version="GreyMistDressing.1"}
local V=Vector3.new
local STONE=Color3.fromRGB(119,128,122)
local function model(parent,name)
	local m=Instance.new("Model");m.Name=name;m.Parent=parent;return m
end
local function baseParts(object)
	local n=if object:IsA("BasePart") then 1 else 0
	for _,p in object:GetDescendants() do if p:IsA("BasePart") then n+=1 end end
	return n
end
local function segmentDistance(x,z,a,b)
	local dx,dz=b.X-a.X,b.Z-a.Z
	local t=math.clamp(((x-a.X)*dx+(z-a.Z)*dz)/math.max(.001,dx*dx+dz*dz),0,1)
	return Vector2.new(x-a.X-dx*t,z-a.Z-dz*t).Magnitude
end
function D.build(root,C)
	assert(not game:GetService("RunService"):IsRunning(),"ValleyDressing builds only in Studio Edit")
	assert(root and C and root:FindFirstChild("Decor"),"Supply H2 hunting root and map config")
	assert(not root.Decor:FindFirstChild("FinalDressing"),"FinalDressing already exists; inspect before rebuilding")
	local storage=game:GetService("ServerStorage")
	local kitModule=assert(storage:FindFirstChild("GreyMistBuild"),"GreyMistBuild missing"):FindFirstChild("ValleyArtKit")
	assert(kitModule and kitModule:IsA("ModuleScript"),"GreyMistBuild.ValleyArtKit missing")
	local Kit=require(kitModule)
	local adapted=typeof(C.WorldOffset)=="Vector3"
	local offset=C.WorldOffset or root:GetAttribute("WorldOffset") or V(0,0,6500)
	local function ground(x,z)
		local h=if adapted then C.terrainHeight(x+offset.X,z+offset.Z)-offset.Y else C.terrainHeight(x,z)
		return V(x+offset.X,h+offset.Y,z+offset.Z)
	end
	local function world(x,y,z) return V(x,y,z)+offset end
	local function toLocal(p) return p-offset end
	local out=model(root.Decor,"FinalDressing");out:SetAttribute("Version",D.Version)
	local stats={version=D.Version,parts=0,budget=1900,islandTrees=0,islandPlants=0,campTrees=0,campPlants=0,
		forestFloorClusters=0,caveRockOverlays=0,shoreStones=0,walkwayPieces=0,rampPieces=0,skippedForBudget=0}
	local function adopt(object)
		local n=baseParts(object)
		if stats.parts+n>stats.budget then object:Destroy();stats.skippedForBudget+=1;return nil end
		stats.parts+=n;return object
	end
	local function part(parent,name,size,cf,color,collide)
		assert(stats.parts<stats.budget,"Dressing part budget exhausted")
		local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or STONE;p.Material=Enum.Material.Slate
		p.Anchored=true;p.CanCollide=collide==true;p.CanQuery=collide==true;p.CanTouch=false
		p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
		p.CastShadow=collide~=false;p.Parent=parent;stats.parts+=1;return p
	end
	local function noCollision(object)
		for _,p in object:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=false;p.CanQuery=false;p.CanTouch=false end end
	end
	-- Reserve both dinosaur corridors and all three human approaches.
	local segments={}
	for _,group in {{C.Edges,72},{C.HumanPaths,24}} do
		for _,edge in group[1] do
			local points=C.samples(edge,24)
			for i=1,#points-1 do
				local a,b=points[i],points[i+1]
				if adapted then a,b=toLocal(a),toLocal(b) end
				table.insert(segments,{a=a,b=b,half=group[2]/2})
			end
		end
	end
	local function clearRoute(x,z,radius)
		for _,s in segments do if segmentDistance(x,z,s.a,s.b)<s.half+radius+5 then return false end end
		return true
	end
	local landmarks=root.Decor:FindFirstChild("Landmarks")
	local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.RespectCanCollide=true;overlap.MaxParts=1
	overlap.FilterDescendantsInstances={landmarks,root:FindFirstChild("Camp")}
	local function clearBuildings(at,radius)
		return #workspace:GetPartBoundsInBox(CFrame.new(at+V(0,20,0)),V(radius*2,48,radius*2),overlap)==0
	end
	local function tree(parent,kind,at,scale,seed)
		local m=adopt(Kit.tree(parent,kind,at,scale,seed));if m then m:SetAttribute("DressingPurpose","Canopy and regional silhouette") end
		return m
	end
	local function plant(parent,kind,at,scale,seed)
		local m=adopt(Kit.plant(parent,kind,at,scale,seed))
		if m then noCollision(m) end;return m
	end
	local function visualRock(parent,at,scale,seed)
		local m=adopt(Kit.rock(parent,at,scale,seed));if m then noCollision(m) end;return m
	end
	local function walkSegment(parent,name,a,b,width)
		local direction=b-a;if direction.Magnitude<.01 then return end
		local cf=CFrame.lookAt((a+b)/2,b)
		local p=part(parent,name,V(width,1,direction.Magnitude+.25),cf-cf.UpVector*.5,STONE,true)
		p.Transparency=1;p.CastShadow=false;p:SetAttribute("WalkSurface",true)
		p:SetAttribute("SurfaceStart",a);p:SetAttribute("SurfaceEnd",b)
		stats.walkwayPieces+=1;return p
	end
	local function guideStone(parent,at,width,length,seed)
		local yaw=math.rad((seed*19)%37-18)
		local p=part(parent,"FlatStoneWaymark",V(.9,width,length),CFrame.new(at-V(0,.45,0))*CFrame.Angles(0,yaw,math.pi/2),STONE,false)
		p.Shape=Enum.PartType.Cylinder;p.CastShadow=true;stats.shoreStones+=1;return p
	end
	local lake=model(out,"LakeIslandAndShallowPassage")
	lake:SetAttribute("Purpose","Reachable island with continuous wading floor and a gradual stone approach")
	-- Adult silhouettes are deliberately reduced for this 110 × 75 island.
	for i,p in {{102,108,.53},{129,121,.47},{134,85,.44}} do
		if tree(lake,"pine",ground(p[1],p[2]),p[3],71380+i) then stats.islandTrees+=1 end
	end
	for i=1,9 do
		local angle=i*2.399963;local x,z=118+math.cos(angle)*23,102+math.sin(angle)*17
		if plant(lake,"fern",ground(x,z),.7+(i%3)*.1,9120+i) then stats.islandPlants+=1 end
	end
	local level=(if adapted then C.LakeLevel-offset.Y else C.LakeLevel) or 65
	local wadingY=level-.3
	-- The surveyed east bank is around x=600; extend onto dry land so the
	-- route never begins in swimming depth. No stepping-stone gaps hide holes.
	local shoreStart=650
	for i=1,75 do
		local xa=shoreStart-(i-1)*5.4;local xb=shoreStart-i*5.4
		local ga,gb=ground(xa,100),ground(xb,100)
		local ya=math.max(wadingY+offset.Y,ga.Y+.25)
		local yb=math.max(wadingY+offset.Y,gb.Y+.25)
		walkSegment(lake,"ContinuousWadingSupport",V(ga.X,ya,ga.Z),V(gb.X,yb,gb.Z),12)
		if i%4==0 then guideStone(lake,V(gb.X,yb+.38,gb.Z),9,11,800+i) end
	end
	-- The 19.6-stud ascent uses a 76-stud incline, then joins native island
	-- ground at x=151. Its upper stones remain continuous and walkable.
	local rampStart,rampEnd=245,151
	local rampTop=(ground(151,100).Y-offset.Y)+.3
	local function islandRampY(x)
		local t=math.clamp((245-x)/76,0,1)
		return offset.Y+wadingY+(rampTop-wadingY)*t
	end
	for i=1,32 do
		local xa=rampStart+(rampEnd-rampStart)*(i-1)/32
		local xb=rampStart+(rampEnd-rampStart)*i/32
		local a,b=world(xa,0,100),world(xb,0,100);a=V(a.X,islandRampY(xa),a.Z);b=V(b.X,islandRampY(xb),b.Z)
		walkSegment(lake,"GentleIslandRamp",a,b,12);stats.rampPieces+=1
		-- Closely packed, flat stone crowns read as a natural rising shelf.
		guideStone(lake,a:Lerp(b,.5)+V(0,.06,0),12.2,3.4,1000+i)
	end
	for i=1,6 do
		local x=230-i*10;local side=if i%2==0 then -1 else 1
		local rock=visualRock(lake,world(x,math.max(level-3,islandRampY(x)-offset.Y-9),100+side*14),.7+(i%2)*.13,31800+i)
		if rock then
			local cf,size=rock:GetBoundingBox()
			local halfZ=(math.abs(cf.RightVector.Z)*size.X+math.abs(cf.UpVector.Z)*size.Y+math.abs(cf.LookVector.Z)*size.Z)*.5
			local shift=if side>0 then math.max(0,world(0,0,107.5).Z-(cf.Position.Z-halfZ)) else math.min(0,world(0,0,92.5).Z-(cf.Position.Z+halfZ))
			if shift~=0 then rock:PivotTo(rock:GetPivot()+V(0,0,shift)) end
		end
	end
	lake:SetAttribute("WadingFloorTop",wadingY+offset.Y);lake:SetAttribute("WadingWidth",12)
	lake:SetAttribute("IslandRampRise",rampTop-wadingY)
	lake:SetAttribute("IslandRampSlopeDegrees",math.deg(math.atan((rampTop-wadingY)/76)))
	lake:SetAttribute("IslandLanding",world(151,rampTop,100))
	task.wait()
	-- Soft yard edge, preserving the central arrival, doors and path mouths.
	local yard=model(out,"RangerYardEdges")
	for i=1,28 do
		local angle=i*2.399963;local radius=208+(i%4)*11
		local x,z=math.cos(angle)*radius,-1900+math.sin(angle)*radius
		local at=ground(x,z)
		if clearRoute(x,z,24) and clearBuildings(at,22) then
			if tree(yard,i%4==0 and "oak" or "birch",at,.58+(i%3)*.06,22200+i) then stats.campTrees+=1 end
			if stats.campTrees>=14 then break end
		end
	end
	for i=1,62 do
		local angle=i*2.399963;local radius=170+(i%5)*14
		local x,z=math.cos(angle)*radius,-1900+math.sin(angle)*radius
		local at=ground(x,z)
		if clearRoute(x,z,4) and clearBuildings(at,4) then
			if plant(yard,i%3==0 and "fern" or "grass",at,.85+(i%3)*.12,52600+i) then stats.campPlants+=1 end
			if stats.campPlants>=42 then break end
		end
	end
	task.wait()
	-- Retain the authored 18 × 16 opening; imported stone is a visual shell
	-- outside the passage, while the existing simple walls provide collision.
	local cave=landmarks and landmarks:FindFirstChild("08_MountainCave")
	local caveBase=cave and cave:GetAttribute("GroundBase")
	if typeof(caveBase)=="Vector3" then
		local blend=model(out,"MountainCaveRockBlend")
		local caveGroundParams=RaycastParams.new();caveGroundParams.FilterType=Enum.RaycastFilterType.Include
		caveGroundParams.FilterDescendantsInstances={workspace.Terrain};caveGroundParams.IgnoreWater=true
		local samples={{-34,0,-9,1.05},{34,0,-7,.95},{-35,0,15,1.15},{35,0,18,1.08},
			{-29,0,34,.9},{29,0,36,.94},{-14,25,17,.82},{13,25,19,.87},
			{-34,5,-22,.78},{34,4,-21,.83}}
		local function intrudesPassage(m)
			local cf,size=m:GetBoundingBox();local low,high=V(math.huge,math.huge,math.huge),V(-math.huge,-math.huge,-math.huge)
			for _,sx in {-1,1} do for _,sy in {-1,1} do for _,sz in {-1,1} do
				local p=cf:PointToWorldSpace(size*V(sx,sy,sz)*.5)-caveBase;low=low:Min(p);high=high:Max(p)
			end end end
			local front=low.X<11 and high.X> -11 and low.Z< -1 and high.Z> -28 and low.Y<19 and high.Y>0
			local chamber=low.X<21 and high.X> -21 and low.Z<29 and high.Z> -1 and low.Y<22 and high.Y>0
			local back=low.X<8 and high.X> -8 and low.Z<48 and high.Z>29 and low.Y<21 and high.Y>0
			return front or chamber or back
		end
		for i,s in samples do
			local at=caveBase+V(s[1],s[2],s[3])
			if s[2]<20 then
				local hit=workspace:Raycast(at+V(0,80,0),V(0,-160,0),caveGroundParams)
				if hit then at=V(at.X,hit.Position.Y+s[2]-.7,at.Z) end
			end
			local m=visualRock(blend,at,s[4],62800+i)
			if m then
				for _=1,3 do
					if not intrudesPassage(m) then break end
					m:PivotTo(m:GetPivot()+V(s[1]<0 and -10 or 10,0,0))
				end
				if intrudesPassage(m) then stats.parts-=baseParts(m);m:Destroy() else stats.caveRockOverlays+=1 end
			end
		end
		blend:SetAttribute("MainEntranceClearWidth",22);blend:SetAttribute("MainEntranceClearHeight",19)
	end
	-- Concentrated understory at existing canopy roots avoids uniform scatter.
	local floor=model(out,"ForestFloorClusters")
	local forest=root.Decor:FindFirstChild("Forest");local existing=forest and forest:GetChildren() or {}
	table.sort(existing,function(a,b) return a.Name<b.Name end)
	for i=1,math.min(230,#existing) do
		local original=existing[(i*37)%#existing+1]
		local anchor=original:GetAttribute("GroundPosition")
		if typeof(anchor)=="Vector3" then
			local localBase=toLocal(anchor);local angle=i*2.399963
			local x,z=localBase.X+math.cos(angle)*(8+i%6),localBase.Z+math.sin(angle)*(8+i%6)
			if clearRoute(x,z,3) then
				local kind=if z< -700 then "grass" else "fern"
				if plant(floor,kind,ground(x,z),.8+(i%5)*.1,79900+i) then stats.forestFloorClusters+=1 end
				if stats.forestFloorClusters>=150 then break end
			end
		end
		if i%30==0 then task.wait() end
	end
	out:SetAttribute("PartCount",stats.parts);out:SetAttribute("ForestFloorClusters",stats.forestFloorClusters)
	out:SetAttribute("IslandAccessReady",true);out:SetAttribute("NoRuntimeScripts",true)
	stats.path=out:GetFullName();return stats
end
return D
