-- Approved concept mapped to playable dimensions; planar scale accommodates the 50-stud prototype.
local C = {Version="H1.1", PlanarScale=1.5, MapSize=1620, RoadWidth=72,
	TimezoneOffsetMinutes=420, TimeScale=30, ClockLatitude=-8,
	TerrainMin=-48, TerrainMax=128, TerrainHalf=816, LakeLevel=4}
C.Zones={
	{id="A",kind="Main",name="Ven hồ",x=-265,z=90,width=180,y=13},
	{id="B",kind="Main",name="Rừng đá",x=280,z=35,width=170,y=27},
	{id="C",kind="Main",name="Tổ trên cao",x=-35,z=-305,width=200,y=62},
	{id="R1",kind="Rest",name="Gốc cổ thụ",x=-300,z=285,width=110,y=14},
	{id="R2",kind="Rest",name="Hõm đá rêu",x=-350,z=-125,width=110,y=34},
	{id="R3",kind="Rest",name="Phế tích",x=280,z=-275,width=110,y=42},
	{id="R4",kind="Rest",name="Bờ suối",x=310,z=250,width=110,y=20},
	{id="R5",kind="Rest",name="Lùm dương xỉ",x=50,z=220,width=110,y=14},
	{id="Camp",kind="Camp",name="Trại săn",x=0,z=365,width=120,y=12},
}
C.Edges={
	{a="A",b="R1",via={{-290,190}}}, {a="R1",b="R5",via={{-160,260}}},
	{a="R5",b="R4",via={{190,270}}}, {a="R4",b="B",via={{340,140}}},
	{a="B",b="R3",via={{320,-110}}}, {a="R3",b="C",via={{130,-325}}},
	{a="C",b="R2",via={{-210,-290}}}, {a="R2",b="A",via={{-325,-30}}},
	{a="A",b="R5",via={{-120,200}}}, {a="R5",b="B",via={{190,160}}},
	{a="B",b="R1",via={{105,132},{-70,195},{-195,240}}},
	{a="C",b="B",via={{140,-235},{210,-120}}},
	{a="C",b="R5",via={{-165,-205},{-180,-30},{-125,155}}},
}
C.HumanPaths={
	{a="Camp",b="R1",via={{-165,345}}},
	{a="Camp",b="R4",via={{150,350}}},
}
C.Routes={
	A={{"A","R2","C","R3","B","R4","R5","R1","A"},{"A","R1","R5","R4","B","R1","A"},{"A","R5","C","B","R1","A"}},
	B={{"B","R4","R5","R1","A","R2","C","R3","B"},{"B","R1","A","R5","R4","B"},{"B","C","R2","A","R1","R5","B"}},
	C={{"C","R3","B","R4","R5","R1","A","R2","C"},{"C","R5","R1","A","R2","C"},{"C","B","R1","R5","C"}},
}
function C.zone(id)
	for _,q in C.Zones do if q.id==id then return q end end
	error("Unknown hunting zone "..tostring(id))
end
function C.position(q)
	return Vector3.new(q.x*C.PlanarScale,q.y,q.z*C.PlanarScale)
end
local function smooth(a,b,x)
	local t=math.clamp((x-a)/(b-a),0,1)
	return t*t*(3-2*t)
end
-- Broad terrain transitions keep the 50-stud prototype's corridors gentle.
-- Stop each blend before a neighboring zone's center so every authored pad
-- retains its exact height; compute once rather than per Terrain voxel.
local zoneBlendWidths={}
for _,q in C.Zones do
	local width=160
	for _,other in C.Zones do
		if other~=q then
			local dx,dz=q.x-other.x,q.z-other.z
			width=math.min(width,math.sqrt(dx*dx+dz*dz)-q.width*.54)
		end
	end
	zoneBlendWidths[q.id]=math.max(1,width)
end
function C.height(wx,wz)
	local x,z=wx/C.PlanarScale,wz/C.PlanarScale
	local h=13+6*math.sin(x/130)*math.cos(z/100)+4*math.sin(z/73)
	h+=28*(1-smooth(-450,-130,z))
	local lake=math.sqrt((x/144)^2+(z/144)^2)
	h=-12+(h+12)*smooth(.82,1.22,lake)
	for _,q in C.Zones do
		local d=math.sqrt((x-q.x)^2+(z-q.z)^2)
		local t=smooth(q.width*.54,q.width*.54+zoneBlendWidths[q.id],d)
		h=q.y+(h-q.y)*t
	end
	return h
end
function C.controlPoints(edge)
	local points={C.position(C.zone(edge.a))}
	for _,p in edge.via or {} do
		local x,z=p[1]*C.PlanarScale,p[2]*C.PlanarScale
		table.insert(points,Vector3.new(x,C.height(x,z),z))
	end
	table.insert(points,C.position(C.zone(edge.b)))
	return points
end
-- Rounded quadratic corners stay inside each surveyed turn and avoid overlapping
-- steep, wide slabs at abrupt bends. Endpoints remain the authored zone nodes.
function C.samples(edge,spacing)
	local controls=C.controlPoints(edge)
	local samples={controls[1]};local last=controls[1];local step=spacing or 12
	local function append(p) table.insert(samples,Vector3.new(p.X,C.height(p.X,p.Z),p.Z));last=p end
	local function lineTo(p)
		local a=last;local n=math.max(1,math.ceil((p-a).Magnitude/step))
		for j=1,n do append(a:Lerp(p,j/n)) end
	end
	for i=2,#controls-1 do
		local prev,corner,nextPoint=controls[i-1],controls[i],controls[i+1]
		local incoming=Vector3.new(corner.X-prev.X,0,corner.Z-prev.Z)
		local outgoing=Vector3.new(nextPoint.X-corner.X,0,nextPoint.Z-corner.Z)
		local radius=math.min(70,incoming.Magnitude*.22,outgoing.Magnitude*.22)
		if radius<1 then lineTo(corner) else
			local entry=corner-incoming.Unit*radius;local exit=corner+outgoing.Unit*radius
			lineTo(entry)
			local n=math.max(3,math.ceil(radius*2/step))
			for j=1,n do local t=j/n;append(entry:Lerp(corner,t):Lerp(corner:Lerp(exit,t),t)) end
		end
	end
	lineTo(controls[#controls])
	return samples
end
-- Grade the full width of each corridor, not only its centerline. This keeps
-- voxel terrain from forming cross-slope lips across a dinosaur's feet.
local gradingSegments={}
for _,group in {{edges=C.Edges,width=C.RoadWidth},{edges=C.HumanPaths,width=24}} do
	for _,edge in group.edges do
		local points=C.samples(edge,24)
		for i=1,#points-1 do table.insert(gradingSegments,{a=points[i],b=points[i+1],width=group.width}) end
	end
end
function C.terrainHeight(x,z)
	local best,chosen,tBest=math.huge,nil,0
	for _,segment in gradingSegments do
		local a,b=segment.a,segment.b;local dx,dz=b.X-a.X,b.Z-a.Z
		local t=math.clamp(((x-a.X)*dx+(z-a.Z)*dz)/math.max(1,dx*dx+dz*dz),0,1)
		local d=math.sqrt((x-a.X-dx*t)^2+(z-a.Z-dz*t)^2)
		local distance=d-segment.width/2
		if distance<best then best,chosen,tBest=distance,segment,t end
	end
	local original=C.height(x,z)
	if chosen and best<16 then
		local p=chosen.a:Lerp(chosen.b,tBest)
		local center=C.height(p.X,p.Z)
		local weight=1-smooth(0,16,best)
		return original+(center-original)*weight,best<=0
	end
	return original,false
end
return C
