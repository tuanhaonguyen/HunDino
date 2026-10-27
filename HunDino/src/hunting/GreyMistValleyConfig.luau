-- Thung Lung Suong Xam: local coordinates; ConnectedHuntingConfig applies WorldOffset.
-- North is positive Z. Patrol topology and the nine approved routes remain unchanged.
local C = {
	Version = "H2.0", Name = "Thung Lũng Sương Xám", PlanarScale = 1,
	MapWidth = 4000, MapDepth = 4500, MapSize = 4500, RoadWidth = 72,
	TerrainMin = -64, TerrainMax = 704, TerrainHalfX = 2000, TerrainHalfZ = 2252,
	TerrainHalf = 2252, LakeLevel = 65, North = Vector3.new(0, 0, 1),
	TimezoneOffsetMinutes = 420, TimeScale = 30, ClockLatitude = 39,
	RestSeconds = 60, CampSafeRadius = 250, RecommendedMaximumRoadSlopeDegrees = 15,
}
C.Zones = {
	{id="A", kind="Main", name="Bờ Hồ Sương", x=-520, z=-80, width=280, y=90, biome="Lake"},
	{id="B", kind="Main", name="Khe Đá Chẻ", x=450, z=1050, width=280, y=260, biome="StoneValley"},
	{id="C", kind="Main", name="Tổ Trên Núi", x=-100, z=1775, width=320, y=430, biome="Mountains"},
	{id="R1", kind="Rest", name="Đồi Sồi Đơn Độc", x=-850, z=-1100, width=200, y=75, biome="Meadow"},
	{id="R2", kind="Rest", name="Rừng Thông Già", x=-1250, z=50, width=200, y=150, biome="PineForest"},
	{id="R3", kind="Rest", name="Xưởng Gỗ Bỏ Hoang", x=-650, z=950, width=220, y=210, biome="LoggingCamp"},
	{id="R4", kind="Rest", name="Gò Liễu Đầm Lầy", x=1350, z=-200, width=200, y=62, biome="Swamp"},
	{id="R5", kind="Rest", name="Đồng Cỏ Thu", x=250, z=-1100, width=200, y=48, biome="Meadow"},
	{id="Camp", kind="Camp", name="Trạm Kiểm Lâm", x=0, z=-1900, width=350, y=20, biome="RangerStation"},
}
C.Edges = {
	{a="A",b="R1",via={{-650,-600}}},
	{a="R1",b="R5",via={{-350,-1200}}},
	{a="R5",b="R4",via={{800,-1050},{1450,-650}}},
	{a="R4",b="B",via={{1500,250},{1050,1050}}},
	{a="B",b="R3",via={{0,1050}}},
	{a="R3",b="C",via={{-850,1350},{-350,1650}}},
	{a="C",b="R2",via={{-1050,1750},{-1650,1000},{-1500,400}}},
	{a="R2",b="A",via={{-1150,-200},{-800,-250}}},
	{a="A",b="R5",via={{-500,-550},{-200,-850}}},
	{a="R5",b="B",via={{600,-950},{900,-550},{950,250},{700,650}}},
	{a="B",b="R1",via={{0,1050},{-650,650},{-750,0},{-700,-700}}},
	{a="C",b="B",via={{400,1750},{850,1450},{700,1200}}},
	{a="C",b="R5",via={{-800,1600},{-1100,950},{-900,400},{-850,-400},{-350,-850}}},
}
C.HumanPaths = {
	{a="Camp",b="R1",via={{-500,-1650}},width=24},
	{a="Camp",b="R4",via={{850,-1700},{1450,-1000}},width=24},
	{a="Camp",b="R5",via={{160,-1550}},width=24},
}
C.Routes = {
	A={{"A","R2","C","R3","B","R4","R5","R1","A"},{"A","R1","R5","R4","B","R1","A"},{"A","R5","C","B","R1","A"}},
	B={{"B","R4","R5","R1","A","R2","C","R3","B"},{"B","R1","A","R5","R4","B"},{"B","C","R2","A","R1","R5","B"}},
	C={{"C","R3","B","R4","R5","R1","A","R2","C"},{"C","R5","R1","A","R2","C"},{"C","B","R1","R5","C"}},
}
C.Lake = {center=Vector2.new(100,100),radii=Vector2.new(450,300),level=65,
	islandCenter=Vector2.new(120,100),islandRadii=Vector2.new(55,37.5),islandTop=84}
C.Swamp = {center=Vector2.new(1350,-200),radii=Vector2.new(425,620),level=62}
C.Stream = {
	{position=Vector3.new(620,267,1140),width=24},
	{position=Vector3.new(720,267,910),width=28},
	{position=Vector3.new(720,210,898),width=28},
	{position=Vector3.new(720,210,850),width=28},
	{position=Vector3.new(700,205,750),width=26},
	{position=Vector3.new(550,120,500),width=32},
	{position=Vector3.new(400,65,350),width=38},
}
C.Biomes = {
	{id="RangerStation",name="Trạm kiểm lâm và bìa rừng",center=Vector2.new(0,-1900),size=Vector2.new(700,550)},
	{id="Meadow",name="Đồng cỏ và rừng thưa",center=Vector2.new(-150,-1100),size=Vector2.new(2500,1000)},
	{id="PineForest",name="Rừng thông già phía Tây",center=Vector2.new(-1250,0),size=Vector2.new(1200,1900)},
	{id="Lake",name="Hồ trung tâm",center=Vector2.new(100,100),size=Vector2.new(1100,850)},
	{id="Swamp",name="Đầm lầy phía Đông",center=Vector2.new(1350,-200),size=Vector2.new(1000,1400)},
	{id="LoggingCamp",name="Khu khai thác gỗ bỏ hoang",center=Vector2.new(-650,950),size=Vector2.new(800,650)},
	{id="StoneValley",name="Thung lũng đá và suối",center=Vector2.new(450,1050),size=Vector2.new(1400,900)},
	{id="Mountains",name="Dãy núi và hang phía Bắc",center=Vector2.new(0,1850),size=Vector2.new(3500,750)},
}
C.Landmarks = {
	{id="RangerHouse",biome="RangerStation",x=-70,z=-1940,size=Vector3.new(65,35,45)},
	{id="ToolStore",biome="RangerStation",x=70,z=-1950,size=Vector3.new(35,25,25)},
	{id="LoneOak",biome="Meadow",x=-1010,z=-1130},
	{id="LakeJetty",biome="Lake",x=-220,z=-270,length=45},
	{id="LakeIsland",biome="Lake",x=120,z=100},
	{id="AncientPine",biome="PineForest",x=-1450,z=180},
	{id="RainShelter",biome="PineForest",x=-1080,z=280,size=Vector3.new(25,18,20)},
	{id="LumberWorkshop",biome="LoggingCamp",x=-850,z=1050,size=Vector3.new(80,42,55)},
	{id="WorkersCabin",biome="LoggingCamp",x=-850,z=900,size=Vector3.new(50,28,30)},
	{id="SplitRock",biome="StoneValley",x=740,z=1100},
	{id="Waterfall",biome="StoneValley",x=720,z=900,height=57},
	{id="SwampBoardwalk",biome="Swamp",x=1530,z=-450,width=10,length=250},
	{id="BirdHide",biome="Swamp",x=1550,z=-100},
	{id="MountainCave",biome="Mountains",x=-350,z=1980,size=Vector3.new(45,20,35)},
	{id="LookoutTower",biome="Mountains",x=650,z=1550,height=90},
	{id="PaleSummit",biome="Mountains",x=120,z=2160,height=645},
}
local zoneIndex = {}
for _,q in C.Zones do zoneIndex[q.id] = q end
function C.zone(id)
	return assert(zoneIndex[id], "Unknown valley zone "..tostring(id))
end
function C.position(q) return Vector3.new(q.x,q.y,q.z) end
local function smooth(a,b,x)
	local t=math.clamp((x-a)/(b-a),0,1)
	return t*t*(3-2*t)
end
local function gaussian(x,z,cx,cz,rx,rz)
	local dx,dz=(x-cx)/rx,(z-cz)/rz
	return math.exp(-dx*dx-dz*dz)
end
local function ellipse(x,z,center,radii)
	local dx,dz=(x-center.X)/radii.X,(z-center.Y)/radii.Y
	return math.sqrt(dx*dx+dz*dz)
end
function C.lakeRadius(x,z)
	local dx,dz=(x-C.Lake.center.X)/450,(z-C.Lake.center.Y)/300
	local angle=math.atan2(dz,dx)
	return math.sqrt(dx*dx+dz*dz)/(1+.055*math.sin(angle*3+.4)+.035*math.cos(angle*5))
end
local function streamProbe(x,z)
	local best,level,width=math.huge,nil,nil
	for i=1,#C.Stream-1 do
		local a,b=C.Stream[i],C.Stream[i+1]
		local dx,dz=b.position.X-a.position.X,b.position.Z-a.position.Z
		local t=math.clamp(((x-a.position.X)*dx+(z-a.position.Z)*dz)/(dx*dx+dz*dz),0,1)
		local px,pz=a.position.X+dx*t,a.position.Z+dz*t
		local d=math.sqrt((x-px)^2+(z-pz)^2)
		if d<best then best=d;level=a.position.Y+(b.position.Y-a.position.Y)*t;width=a.width+(b.width-a.width)*t end
	end
	return best,level,width
end
function C.height(x,z)
	local h=22+82*smooth(-1850,-150,z)+160*smooth(250,1650,z)+150*smooth(1400,2200,z)
	h+=232*gaussian(x,z,120,2160,580,430)+68*gaussian(x,z,-1550,1550,650,650)
	h+=48*gaussian(x,z,-1300,50,620,900)+62*gaussian(x,z,580,1050,700,500)
	h+=5*math.sin(x/195)*math.cos(z/170)+3*math.sin((x+z)/115)
	-- Low enclosing ridges hide the rectangular south/east/west Terrain edge.
	-- The north already has the tall mountain backdrop and is not raised here.
	local edgeDistance=math.min(2000-math.abs(x),2250+z)
	h+=130*(1-smooth(0,180,edgeDistance))
	local r=C.lakeRadius(x,z)
	if r<1.30 then
		local floor=53-43*(1-math.clamp(r,0,1))^.65
		h=floor+(h-floor)*smooth(.95,1.30,r)
		local island=ellipse(x,z,C.Lake.islandCenter,C.Lake.islandRadii)
		if island<1.5 then h=h+(C.Lake.islandTop-h)*(1-smooth(.7,1.5,island)) end
	end
	local swamp=ellipse(x,z,C.Swamp.center,C.Swamp.radii)
	if swamp<1.32 then
		local wet=59+2.2*math.sin(x/67)*math.cos(z/83)+1.4*math.sin(z/39)
		h=wet+(h-wet)*smooth(.62,1.32,swamp)
	end
	if x>300 and x<850 and z>300 and z<1200 then
		local d,level,width=streamProbe(x,z)
		local bed=math.min(h,level-3)
		h=bed+(h-bed)*smooth(width*.5,width*.5+65,d)
	end
	-- Flatten the clearings, then blend generously into the surrounding hills.
	for _,q in C.Zones do
		local dx,dz=x-q.x,z-q.z
		local radius=if q.kind=="Camp" then C.CampSafeRadius else q.width*.52
		local outer=radius+260
		if math.abs(dx)<outer and math.abs(dz)<outer then
			local d=math.sqrt(dx*dx+dz*dz)
			if d<outer then h=q.y+(h-q.y)*smooth(radius,outer,d) end
		end
	end
	-- A narrow rock lip above the 57-stud waterfall and a readable receiving
	-- basin below it. Apply after the nearby B clearing's broad terrain blend.
	local fallsX=math.abs(x-720)
	if fallsX<48 and z>850 and z<990 then
		local side=1-smooth(24,48,fallsX)
		local lower=side*smooth(850,860,z)*(1-smooth(900,910,z))
		h=h+(math.min(h,207)-h)*lower
		local upper=side*smooth(900,910,z)*(1-smooth(965,990,z))
		h=h+(math.max(h,264)-h)*upper
	end
	return h
end
function C.controlPoints(edge)
	local points={C.position(C.zone(edge.a))}
	for _,p in edge.via or {} do table.insert(points,Vector3.new(p[1],C.height(p[1],p[2]),p[2])) end
	table.insert(points,C.position(C.zone(edge.b)))
	return points
end
C.RoadJunctions = {
	-- Broad, shared grades at the western trail crossings prevent either
	-- crossing branch from becoming a bridge or a step above the other.
	{center=Vector2.new(-685,-550),height=102,inner=100,radius=300},
	{center=Vector2.new(-795,-225),height=90,inner=100,radius=300},
	{center=Vector2.new(1408,-665),height=62,inner=60,radius=220},
	{center=Vector2.new(-60,1030),height=228,inner=160,radius=360},
}
local function junctionGrade(p)
	local y=p.Y
	for _,j in C.RoadJunctions do
		local dx,dz=p.X-j.center.X,p.Z-j.center.Y
		local d=math.sqrt(dx*dx+dz*dz)
		if d<j.radius then y=j.height+(y-j.height)*smooth(j.inner,j.radius,d) end
	end
	for _,q in C.Zones do
		local dx,dz=p.X-q.x,p.Z-q.z
		local inner=if q.kind=="Camp" then C.CampSafeRadius+36 else q.width*.5+64
		local outer=inner+360
		if math.abs(dx)<outer and math.abs(dz)<outer then
			local d=math.sqrt(dx*dx+dz*dz)
			if d<outer then y=q.y+(y-q.y)*smooth(inner,outer,d) end
		end
	end
	-- A distant node's broad blend must not give the two sides of an authored
	-- shared fork different heights. These small inner plateaux lie outside
	-- every node's protected clearing and therefore retain their common grade.
	for _,j in C.RoadJunctions do
		local dx,dz=p.X-j.center.X,p.Z-j.center.Y
		local d=math.sqrt(dx*dx+dz*dz)
		if d<j.inner+120 then y=j.height+(y-j.height)*smooth(j.inner,j.inner+120,d) end
	end
	return Vector3.new(p.X,y,p.Z)
end
C.applyRoadJunctionGrade=junctionGrade
local function rawSamples(edge,spacing)
	local controls=C.controlPoints(edge)
	local samples={controls[1]};local last=controls[1];local step=spacing or 20
	local function append(p)
		table.insert(samples,p);last=p
	end
	local function lineTo(p)
		local a=last
		local distance=Vector2.new(p.X-a.X,p.Z-a.Z).Magnitude
		for j=1,math.max(1,math.ceil(distance/step)) do append(a:Lerp(p,j/math.max(1,math.ceil(distance/step)))) end
	end
	for i=2,#controls-1 do
		local prev,corner,nextPoint=controls[i-1],controls[i],controls[i+1]
		local incoming=Vector3.new(corner.X-prev.X,0,corner.Z-prev.Z)
		local outgoing=Vector3.new(nextPoint.X-corner.X,0,nextPoint.Z-corner.Z)
		local radius=math.min(100,incoming.Magnitude*.22,outgoing.Magnitude*.22)
		if radius<1 then lineTo(corner) else
			local entry=corner-(corner-prev)*(radius/incoming.Magnitude)
			local exit=corner+(nextPoint-corner)*(radius/outgoing.Magnitude)
			lineTo(entry)
			local n=math.max(3,math.ceil(radius*2/step))
			for j=1,n do local t=j/n;append(entry:Lerp(corner,t):Lerp(corner:Lerp(exit,t),t)) end
		end
	end
	lineTo(controls[#controls])
	for i,p in samples do samples[i]=junctionGrade(p) end
	return samples
end
-- One dense height profile per corridor is shared by every requested spacing.
-- Node pads and common forks are fixed anchors; grade limits are applied only
-- between them, so callers at 8/16/24 studs cannot create conflicting roads.
local profileCache={}
local gradeLimit=math.tan(math.rad(17.4))
local function fixedGrade(p)
	for _,q in C.Zones do
		local inner=if q.kind=="Camp" then C.CampSafeRadius+36 else q.width*.5+64
		if (p.X-q.x)^2+(p.Z-q.z)^2<=inner*inner then return true end
	end
	for _,j in C.RoadJunctions do
		if (p.X-j.center.X)^2+(p.Z-j.center.Y)^2<=j.inner*j.inner then return true end
	end
	return false
end
local function profile(edge)
	if profileCache[edge] then return profileCache[edge] end
	local points=rawSamples(edge,8)
	local arc={0};local fixed={}
	for i,p in points do
		if i>1 then
			local a=points[i-1]
			arc[i]=arc[i-1]+Vector2.new(p.X-a.X,p.Z-a.Z).Magnitude
		end
		fixed[i]=i==1 or i==#points or fixedGrade(p)
	end
	local left=1
	while left<#points do
		local right=left+1
		while right<#points and not fixed[right] do right+=1 end
		local a,b=points[left],points[right]
		local length=arc[right]-arc[left]
		-- Fixed fork/clearing anchors define the corridor. For a very short
		-- numerical interval, retaining that anchor is safer than moving a pad.
		if length>0 and math.abs(b.Y-a.Y)<=gradeLimit*length+.001 then
			for i=left+1,right-1 do
				local fromLeft,fromRight=arc[i]-arc[left],arc[right]-arc[i]
				local low=math.max(a.Y-gradeLimit*fromLeft,b.Y-gradeLimit*fromRight)
				local high=math.min(a.Y+gradeLimit*fromLeft,b.Y+gradeLimit*fromRight)
				local p=points[i];points[i]=Vector3.new(p.X,math.clamp(p.Y,low,high),p.Z)
			end
			for i=left+1,right-1 do
				local p,prev=points[i],points[i-1]
				local allowance=gradeLimit*(arc[i]-arc[i-1])
				points[i]=Vector3.new(p.X,math.clamp(p.Y,prev.Y-allowance,prev.Y+allowance),p.Z)
			end
		end
		left=right
	end
	profileCache[edge]={points=points,arc=arc,length=arc[#arc]}
	return profileCache[edge]
end
function C.samples(edge,spacing)
	local data=profile(edge)
	local result={data.points[1]}
	local step=math.max(1,spacing or 20)
	local segment=1
	for distance=step,data.length-.001,step do
		while segment<#data.points-1 and data.arc[segment+1]<distance do segment+=1 end
		local a,b=data.points[segment],data.points[segment+1]
		local t=(distance-data.arc[segment])/math.max(.001,data.arc[segment+1]-data.arc[segment])
		table.insert(result,a:Lerp(b,t))
	end
	table.insert(result,data.points[#data.points])
	return result
end
-- Spatially index short grading segments. A terrain query inspects only its
-- 128-stud cell, rather than every segment in the entire 18-million-stud map.
local CELL=128
local cells={}
local gradingSegments={}
local function key(x,z) return math.floor(x/CELL)*10000+math.floor(z/CELL) end
for _,group in {{edges=C.Edges,width=72},{edges=C.HumanPaths,width=24}} do
	for _,edge in group.edges do
		local points=C.samples(edge,24)
		local width=edge.width or group.width
		for i=1,#points-1 do
			local a,b=points[i],points[i+1]
			local dx,dz=b.X-a.X,b.Z-a.Z
			local segment={a=a,b=b,dx=dx,dz=dz,inv=1/math.max(1,dx*dx+dz*dz),half=width*.5}
			table.insert(gradingSegments,segment)
			local margin=segment.half+32
			for ix=math.floor((math.min(a.X,b.X)-margin)/CELL),math.floor((math.max(a.X,b.X)+margin)/CELL) do
				for iz=math.floor((math.min(a.Z,b.Z)-margin)/CELL),math.floor((math.max(a.Z,b.Z)+margin)/CELL) do
					local cellKey=ix*10000+iz
					local list=cells[cellKey]
					if not list then list={};cells[cellKey]=list end
					table.insert(list,segment)
				end
			end
		end
	end
end
C.GradingSegmentCount=#gradingSegments
function C.terrainHeight(x,z)
	local h=C.height(x,z)
	local list=cells[key(x,z)]
	if not list then return h,false,math.huge end
	local best,chosen,bestT=math.huge,nil,0
	local nearestLine=math.huge
	for _,s in list do
		local t=math.clamp(((x-s.a.X)*s.dx+(z-s.a.Z)*s.dz)*s.inv,0,1)
		local dx,dz=x-s.a.X-s.dx*t,z-s.a.Z-s.dz*t
		local centerDistance=math.sqrt(dx*dx+dz*dz)
		if centerDistance<nearestLine then nearestLine=centerDistance end
		local d=centerDistance-s.half
		if d<best then best,chosen,bestT=d,s,t end
	end
	if chosen and best<32 then
		local center=chosen.a.Y+(chosen.b.Y-chosen.a.Y)*bestT
		return h+(center-h)*(1-smooth(0,32,best)),best<=0,nearestLine
	end
	return h,false,nearestLine
end
function C.waterLevel(x,z,groundHeight)
	local h=groundHeight or C.height(x,z)
	if C.lakeRadius(x,z)<1.2 and h<C.LakeLevel then return C.LakeLevel,"Lake" end
	if ellipse(x,z,C.Swamp.center,C.Swamp.radii)<1.05 and C.Swamp.level-h>=3 then return C.Swamp.level,"Swamp" end
	if x>300 and x<850 and z>300 and z<1200 then
		local d,level,width=streamProbe(x,z)
		if d<width*.48 and h<level then return level,"Stream" end
	end
	return nil,nil
end
function C.biome(x,z)
	if z< -1570 and math.abs(x)<700 then return "RangerStation" end
	if z>1450 then return "Mountains" end
	if x>900 and z> -1000 and z<650 then return "Swamp" end
	if z>650 and x< -250 and x> -1150 then return "LoggingCamp" end
	if z>650 and x>= -250 then return "StoneValley" end
	if x< -850 and z> -650 then return "PineForest" end
	if C.lakeRadius(x,z)<1.75 then return "Lake" end
	return "Meadow"
end
function C.materialHint(x,z,height,onRoad)
	height=height or C.height(x,z)
	local biome=C.biome(x,z)
	if onRoad then return "Ground",biome end
	if biome=="Mountains" and height>420 then return "Slate",biome end
	if biome=="StoneValley" then return "Rock",biome end
	if biome=="Swamp" then return "Mud",biome end
	if biome=="PineForest" or biome=="LoggingCamp" then return "Ground",biome end
	if C.lakeRadius(x,z)<1.30 then return "Sand",biome end
	return "LeafyGrass",biome
end
return C
