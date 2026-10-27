-- EDIT builder. Every object is owned by the supplied parent; no Terrain or global edits.
-- Gabled timber structures, walkable interiors and regional stories for Thung Lũng Sương Xám.
local L={}
local P={wood=Color3.fromRGB(112,88,62),old=Color3.fromRGB(99,95,76),dark=Color3.fromRGB(66,57,45),
	roof=Color3.fromRGB(81,104,103),stone=Color3.fromRGB(107,115,111),lightstone=Color3.fromRGB(143,153,150),
	moss=Color3.fromRGB(77,93,63),iron=Color3.fromRGB(65,70,66),glass=Color3.fromRGB(150,185,179),
	cream=Color3.fromRGB(224,216,179),water=Color3.fromRGB(150,202,197),leaf=Color3.fromRGB(122,111,57)}
local made=0
local function group(name,parent)
	local m=Instance.new("Model");m.Name=name;m.Parent=parent;return m
end
local function part(parent,name,size,cf,color,material,collide,className)
	local p=Instance.new(className or "Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or P.wood
	p.Material=material or Enum.Material.WoodPlanks;p.Anchored=true
	p.CanCollide=collide~=false;p.CanQuery=collide~=false;p.CanTouch=false
	p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
	p.CastShadow=collide~=false;p.Parent=parent
	made+=1;if made%120==0 then task.wait() end
	return p
end
local function bar(parent,name,a,b,width,color,material,collide)
	return part(parent,name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,material,collide)
end
local function log(parent,name,a,b,r,color,collide)
	local d=(b-a).Unit;local ref=if math.abs(d.Y)>.9 then Vector3.zAxis else Vector3.yAxis
	local z=d:Cross(ref).Unit;local y=z:Cross(d).Unit
	local p=part(parent,name,Vector3.new((b-a).Magnitude,r*2,r*2),CFrame.fromMatrix((a+b)/2,d,y,z),color or P.dark,Enum.Material.Wood,collide)
	p.Shape=Enum.PartType.Cylinder;return p
end
local function label(board,text,size)
	local gui=Instance.new("SurfaceGui");gui.Name="PaintedLettering";gui.Face=Enum.NormalId.Front
	gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=25;gui.Parent=board
	local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(.94,.88);t.Position=UDim2.fromScale(.03,.06)
	t.BackgroundTransparency=1;t.Font=Enum.Font.GothamMedium;t.Text=text;t.TextScaled=true;t.TextWrapped=true
	t.TextColor3=P.cream;t.TextStrokeTransparency=1;t.Parent=gui
	return gui
end
local function offset(config)
	return config.WorldOffset or Vector3.new(0,0,6500)
end
local function ground(config,x,z)
	local o=offset(config);local wx,wz=x+o.X,z+o.Z
	local height=if config.terrainHeight then config.terrainHeight(wx,wz) else config.height(wx,wz)
	return Vector3.new(wx,height,wz)
end
local function v(base,x,y,z) return base+Vector3.new(x,y,z) end
local function segmentDistance(p,a,b)
	local pa=Vector2.new(p.X-a.X,p.Z-a.Z);local ab=Vector2.new(b.X-a.X,b.Z-a.Z)
	local t=math.clamp(pa:Dot(ab)/math.max(.01,ab:Dot(ab)),0,1)
	return (pa-ab*t).Magnitude
end
-- Large colliders are shifted away from every animal corridor and rest pad.
local function safeSite(config,x,z,radius)
	local origin=Vector2.new(x,z)
	local candidates={Vector2.zero,Vector2.new(-110,0),Vector2.new(110,0),Vector2.new(0,110),Vector2.new(0,-110),
		Vector2.new(-210,100),Vector2.new(210,-100),Vector2.new(-220,-150),Vector2.new(220,150)}
	for radiusStep=300,500,100 do for i=1,12 do
		local angle=i*math.pi/6;table.insert(candidates,Vector2.new(math.cos(angle)*radiusStep,math.sin(angle)*radiusStep))
	end end
	for _,delta in candidates do
		local localX,localZ=origin.X+delta.X,origin.Y+delta.Y
		local p=ground(config,localX,localZ)
		local clear=math.abs(localX)+radius<1950 and math.abs(localZ)+radius<2180
		for _,q in config.Zones do
			if q.id~="Camp" then local at=config.position(q)
				if (Vector2.new(p.X-at.X,p.Z-at.Z)).Magnitude<math.max(170,(q.width or 180)*.5)+radius then clear=false;break end
			end
		end
		if clear and config.samples then
			for _,e in config.Edges do
				local points=config.samples(e,36)
				for i=1,#points-1 do if segmentDistance(p,points[i],points[i+1])<40+radius then clear=false;break end end
				if not clear then break end
			end
		end
		if clear then return p end
	end
	error("No corridor-safe landmark site near "..tostring(origin))
end
local function crate(parent,base,w)
	w=w or 5;local m=group("BracedSupplyCrate",parent)
	part(m,"WeatheredBoards",Vector3.new(w,w,w),CFrame.new(base+Vector3.new(0,w/2,0)),P.old)
	for _,side in {-1,1} do
		bar(m,"CornerBrace",v(base,-w*.42,.4,side*(w*.51)),v(base,w*.42,w-.4,side*w*.51),.48,P.dark)
		for _,xx in {-1,1} do part(m,"EdgeBand",Vector3.new(.5,w,.3),CFrame.new(v(base,xx*w*.43,w/2,side*w*.52)),P.dark) end
	end
	return m
end
local function barrel(parent,base)
	local p=part(parent,"RainBarrel",Vector3.new(5,4.5,4.5),CFrame.new(base+Vector3.new(0,2.5,0))*CFrame.Angles(0,0,math.pi/2),P.old,Enum.Material.Wood)
	p.Shape=Enum.PartType.Cylinder
	for _,yy in {1,4} do local b=part(parent,"BarrelIronHoop",Vector3.new(.25,4.64,4.64),CFrame.new(base+Vector3.new(0,yy,0))*CFrame.Angles(0,0,math.pi/2),P.iron,Enum.Material.Metal);b.Shape=Enum.PartType.Cylinder end
	return p
end
local function fence(parent,base,length,angle)
	local cf=CFrame.new(base)*CFrame.Angles(0,angle or 0,0);local n=math.max(1,math.floor(length/12))
	for i=0,n do part(parent,"UnevenFencePost",Vector3.new(1.1,5.8,1.1),cf*CFrame.new(-length/2+i*length/n,2.9,0),P.old) end
	for _,yy in {2.2,4.5} do part(parent,"FenceRail",Vector3.new(length,.65,.7),cf*CFrame.new(0,yy,0),P.old) end
end
local function light(parent,base,height)
	part(parent,"LampStoneFoot",Vector3.new(3,2,3),CFrame.new(v(base,0,1,0)),P.stone,Enum.Material.Slate)
	part(parent,"LampTimberPost",Vector3.new(1.1,height,1.1),CFrame.new(v(base,0,height/2,0)),P.dark)
	bar(parent,"LampBracket",v(base,0,height,0),v(base,3,height,0),.55,P.iron,Enum.Material.Metal)
	local p=part(parent,"WarmLantern",Vector3.new(1.8,2.5,1.8),CFrame.new(v(base,3,height-1.3,0)),Color3.fromRGB(255,201,122),Enum.Material.Glass,false)
	p.Transparency=.2
	local point=Instance.new("PointLight");point.Color=Color3.fromRGB(255,211,151);point.Brightness=.8;point.Range=34;point.Shadows=false;point.Parent=p
	for _,yy in {height-2.7,height+.1} do part(parent,"LanternCap",Vector3.new(2.4,.4,2.4),CFrame.new(v(base,3,yy,0)),P.iron,Enum.Material.Metal) end
end
local function tableSet(parent,base)
	part(parent,"WorktablePlanks",Vector3.new(14,.8,5),CFrame.new(v(base,0,4.3,0)),P.old)
	for _,x in {-5.5,5.5} do for _,z in {-1.8,1.8} do part(parent,"TableLeg",Vector3.new(.7,4,.7),CFrame.new(v(base,x,2,z)),P.dark) end end
	for _,zz in {-5,5} do
		part(parent,"BenchSeat",Vector3.new(14,.6,2),CFrame.new(v(base,0,2.3,zz)),P.old)
		for _,xx in {-5,5} do part(parent,"BenchSupport",Vector3.new(.8,2,.8),CFrame.new(v(base,xx,1,zz)),P.dark) end
	end
end
local function gable(parent,base,w,d,wallHeight,rise,missing)
	local slope=math.atan(rise/(w/2));local slant=math.sqrt((w/2+3)^2+(rise+1)^2)
	for _,side in {-1,1} do
		if missing and side==1 then
			for _,zz in {-d*.36,d*.36} do
				part(parent,"BrokenRoofSection",Vector3.new(slant,.9,d*.26),CFrame.new(v(base,side*w/4,wallHeight+rise/2,zz))*CFrame.Angles(0,0,-side*slope),P.roof,Enum.Material.Metal)
			end
		else
			part(parent,"FadedRoofSlope",Vector3.new(slant,1,d+7),CFrame.new(v(base,side*w/4,wallHeight+rise/2,0))*CFrame.Angles(0,0,-side*slope),P.roof,Enum.Material.Metal)
		end
		for _,zz in {-d/2,d/2} do
			bar(parent,"RoofRafter",v(base,0,wallHeight+rise,zz),v(base,side*(w/2+2),wallHeight-.6,zz),.95,P.dark)
		end
	end
	part(parent,"RidgeCap",Vector3.new(1.5,1.2,d+8),CFrame.new(v(base,0,wallHeight+rise+.5,0)),P.iron,Enum.Material.Metal)
	-- Front/rear gable boards taper toward ridge; triangular silhouettes remain legible.
	for _,zz in {-d/2,d/2} do
		for i=1,5 do local h=rise/5;local ww=w*(1-(i-.5)/5)
			part(parent,"GableCladding",Vector3.new(ww,h+.1,.8),CFrame.new(v(base,0,wallHeight+(i-.5)*h,zz)),P.wood)
		end
	end
end
local function cabin(parent,name,base,w,d,h,options)
	options=options or {};local m=group(name,parent);m:SetAttribute("WalkableInterior",true)
	m:SetAttribute("GroundBase",base);m:SetAttribute("FoundationFootprint",Vector3.new(w+5,2,d+5))
	part(m,"StoneFoundation",Vector3.new(w+2,2,d+2),CFrame.new(v(base,0,0,0)),P.stone,Enum.Material.Slate)
	local floorY=1.4
	for i=1,math.ceil(d/5) do
		local step=d/math.ceil(d/5);part(m,"InteriorFloorboard",Vector3.new(w,.8,step-.08),CFrame.new(v(base,0,floorY,-d/2+(i-.5)*step)),P.old)
	end
	-- South-facing entrance, back door when requested; no invisible doorway collider.
	for _,zz in {-d/2,d/2} do
		local door=(zz<0 or options.backExit);local opening=door and 10 or 0
		if opening>0 then
			for _,side in {-1,1} do part(m,"DoorFlankingWall",Vector3.new((w-opening)/2,h,.9),CFrame.new(v(base,side*(w+opening)/4,floorY+h/2,zz)),P.wood) end
			part(m,"DoorLintel",Vector3.new(opening,h-10,.9),CFrame.new(v(base,0,floorY+10+(h-10)/2,zz)),P.wood)
		else part(m,"RearTimberWall",Vector3.new(w,h,.9),CFrame.new(v(base,0,floorY+h/2,zz)),P.wood) end
	end
	-- Windows on side walls with open interior space and substantial timber framing.
	for _,side in {-1,1} do
		local xx=side*w/2
		part(m,"WindowSillWall",Vector3.new(.9,5.5,d),CFrame.new(v(base,xx,floorY+2.75,0)),P.wood)
		part(m,"WindowUpperWall",Vector3.new(.9,h-10,d),CFrame.new(v(base,xx,floorY+10+(h-10)/2,0)),P.wood)
		for _,zz in {-d*.38,0,d*.38} do part(m,"WindowWallPier",Vector3.new(1,4.5,d*.2),CFrame.new(v(base,xx,floorY+7.75,zz)),P.wood) end
		for _,zz in {-d*.2,d*.2} do
			local p=part(m,"DustyWindowGlass",Vector3.new(.3,4.4,d*.17),CFrame.new(v(base,xx,floorY+7.75,zz)),P.glass,Enum.Material.Glass,false);p.Transparency=.67
		end
	end
	for _,x in {-w/2,w/2} do for _,z in {-d/2,d/2} do part(m,"CornerBearingPost",Vector3.new(1.8,h+1.5,1.8),CFrame.new(v(base,x,floorY+h/2,z)),P.dark) end end
	for _,side in {-1,1} do part(m,"LongWallTopBeam",Vector3.new(1.7,1.5,d+2),CFrame.new(v(base,side*w/2,floorY+h,0)),P.dark) end
	gable(m,v(base,0,floorY,0),w,d,h,options.rise or 9,options.ruined)
	if options.porch then
		part(m,"PorchDeck",Vector3.new(w+8,.9,13),CFrame.new(v(base,0,1.4,-d/2-6.5)),P.old)
		for _,xx in {-w/2,w/2} do part(m,"PorchRoofSupport",Vector3.new(1.2,h,1.2),CFrame.new(v(base,xx,h/2,-d/2-11)),P.dark) end
		part(m,"PorchLeanRoof",Vector3.new(w+8,.8,15),CFrame.new(v(base,0,h-1,-d/2-7))*CFrame.Angles(math.rad(-8),0,0),P.roof,Enum.Material.Metal)
		for i=1,3 do part(m,"PorchStep",Vector3.new(14,.6,2.4),CFrame.new(v(base,0,1.3-i*.42,-d/2-12-i*1.8)),P.old) end
	end
	return m
end
local function stackedLogs(parent,base,rows,length)
	for row=1,rows do local n=rows+2-row
		for i=1,n do local a=v(base,(i-(n+1)/2)*3.9,1.8+(row-1)*3.3,-length/2)
			log(parent,"StoredTimber",a,a+Vector3.new(0,0,length),1.85,P.dark)
			local endcap=part(parent,"VisibleEndGrain",Vector3.new(.12,3.3,3.3),CFrame.new(a-Vector3.new(0,0,.08))*CFrame.Angles(0,math.pi/2,0),P.wood,Enum.Material.Wood,false);endcap.Shape=Enum.PartType.Cylinder
		end
	end
	for _,zz in {-length*.35,length*.35} do part(parent,"LogStackCradle",Vector3.new((rows+1)*4,1.3,2),CFrame.new(v(base,0,.6,zz)),P.old) end
end
local function notice(parent,base,title,text)
	for _,x in {-5,5} do part(parent,"NoticePost",Vector3.new(1,12,1),CFrame.new(v(base,x,6,0)),P.dark) end
	local board=part(parent,"PaintedMapBoard",Vector3.new(13,8,.8),CFrame.new(v(base,0,8,0)),P.dark)
	label(board,title.."\n"..text)
	part(parent,"NoticeRoof",Vector3.new(16,.8,5),CFrame.new(v(base,0,13,0))*CFrame.Angles(math.rad(-10),0,0),P.roof,Enum.Material.Metal)
	return board
end
function L.camp(parent,config,kit)
	local m=group("01_RangerStation",parent);local at=ground(config,0,-1900)
	m:SetAttribute("Region","Camp");m:SetAttribute("Purpose","Safe arrival and orientation")
	local home=cabin(m,"RangerCabin_65x45",v(at,-91,0,-38),65,45,15,{porch=true,rise=10})
	local plaque=part(home,"StationNamePlaque",Vector3.new(24,3,.5),CFrame.new(v(at,-91,15.8,-61.3)),P.dark)
	label(plaque,"TRẠM KIỂM LÂM")
	-- Credible, sparse interior: desk, stove, shelves and a field table.
	tableSet(home,v(at,-96,2,-33))
	part(home,"CastIronStove",Vector3.new(4,6,4),CFrame.new(v(at,-111,5,-24)),P.iron,Enum.Material.Metal)
	part(home,"StoveFlue",Vector3.new(1.4,24,1.4),CFrame.new(v(at,-111,20,-24)),P.iron,Enum.Material.Metal)
	for i=0,2 do part(home,"ToolShelf",Vector3.new(12,.5,3),CFrame.new(v(at,-72,5+i*3,-25)),P.old) end
	cabin(m,"ToolStore_35x25",v(at,91,0,-43),35,25,11,{rise=6})
	notice(m,v(at,-20,0,34),"THUNG LŨNG SƯƠNG XÁM","BẮC: NÚI ĐÁ  ·  TÂY: RỪNG THÔNG\nĐÔNG: ĐẦM LẦY  ·  HỒ: ĐƯỜNG GIỮA")
	for i=1,3 do crate(m,v(at,63+i*5,1,-26),4.5) end
	barrel(m,v(at,-130,1,-27));barrel(m,v(at,108,1,-30))
	stackedLogs(m,v(at,-133,1,-58),3,13)
	tableSet(m,v(at,46,0,-74))
	fence(m,v(at,-139,0,-100),90,0);fence(m,v(at,110,0,-100),66,0)
	fence(m,v(at,-156,0,-54),65,math.pi/2);fence(m,v(at,146,0,-58),70,math.pi/2)
	light(m,v(at,-38,0,4),17);light(m,v(at,39,0,4),17)
	local fire=group("StoneFirepit",m)
	for i=1,9 do local t=i*math.pi*2/9
		part(fire,"FireRingStone",Vector3.new(2.4,1.5,2),CFrame.new(v(at,22+math.cos(t)*5,.7,-37+math.sin(t)*5))*CFrame.Angles(0,-t,0),P.stone,Enum.Material.Slate)
	end
	for _,a in {-1,1} do log(fire,"Firewood",v(at,19,1.4,-37+a*1.3),v(at,26,1.4,-37-a*1.3),.55,P.dark) end
	local ember=part(fire,"QuietEmberBed",Vector3.new(3,.2,3),CFrame.new(v(at,22,1,-37)),Color3.fromRGB(184,87,35),Enum.Material.Neon,false)
	local warm=Instance.new("PointLight");warm.Color=Color3.fromRGB(255,163,84);warm.Brightness=.45;warm.Range=16;warm.Parent=ember
	return m
end
function L.lake(parent,config,kit)
	local m=group("04_LakeLandmarks",parent);m:SetAttribute("Region","Lake")
	-- Lake center (100,100), southern shore approximately z=-200. Pier points north.
	local at=ground(config,-50,-220);at=Vector3.new(at.X,(config.LakeLevel or 65)+3.7,at.Z)
	local pier=group("OldSouthPier_45",m)
	-- The approach follows the shallow bank until it meets the level deck.
	for i=1,40 do
		local p=v(at,0,0,-121.5+i*3)
		local height=if config.terrainHeight then config.terrainHeight(p.X,p.Z) else config.height(p.X,p.Z)
		p=Vector3.new(p.X,math.max(at.Y,height+.8),p.Z)
		part(pier,"DryShoreApproach",Vector3.new(12,.8,3.1),CFrame.new(p),P.old)
	end
	for i=1,15 do
		part(pier,"UnevenDeckPlank",Vector3.new(12,.8,2.9),CFrame.new(v(at,0,0,(i-.5)*3))*CFrame.Angles(0,0,math.rad((i%3-1)*.45)),P.old)
	end
	for _,xx in {-4.7,4.7} do
		part(pier,"PierStringer",Vector3.new(1.1,1.7,47),CFrame.new(v(at,xx,-1,22)),P.dark)
		for _,zz in {2,18,35,44} do
			log(pier,"WaterBlackenedPile",v(at,xx,-14,zz),v(at,xx,3,zz),.7,P.dark)
		end
	end
	for _,xx in {-4.8,4.8} do part(pier,"ShelterPost",Vector3.new(.9,10,.9),CFrame.new(v(at,xx,5,37)),P.dark) end
	part(pier,"PierShelterRoof",Vector3.new(15,.8,14),CFrame.new(v(at,0,11,38))*CFrame.Angles(0,0,math.rad(7)),P.roof,Enum.Material.Metal)
	bar(pier,"RoofBrace",v(at,-4.8,7,37),v(at,0,11,37),.6,P.old)
	for _,x in {-5,5} do part(pier,"MooringCleat",Vector3.new(2.8,.6,.8),CFrame.new(v(at,x,1,11)),P.iron,Enum.Material.Metal) end
	-- Shallow-bank rowboat; open hull formed from five low boards.
	local boatAt=v(at,18,-1,6);local boat=group("MooredOpenRowboat",m)
	part(boat,"HullBottom",Vector3.new(7,.65,17),CFrame.new(boatAt),P.old)
	for _,s in {-1,1} do part(boat,"HullSide",Vector3.new(.7,3,17),CFrame.new(boatAt+Vector3.new(s*3.6,1.3,0))*CFrame.Angles(0,0,math.rad(-s*8)),P.wood) end
	for _,s in {-1,1} do part(boat,"HullEnd",Vector3.new(7,2.6,.7),CFrame.new(boatAt+Vector3.new(0,1.1,s*8)),P.wood) end
	for _,z in {-4,3} do part(boat,"RowingBench",Vector3.new(7,.5,2),CFrame.new(boatAt+Vector3.new(0,1.4,z)),P.dark) end
	bar(boat,"RestingOar",boatAt+Vector3.new(-4,2,-5),boatAt+Vector3.new(5,2,6),.35,P.dark)
	notice(m,ground(config,-74,-244),"BẾN HỒ CŨ","LỐI NƯỚC NÔNG Ở BỜ ĐÔNG")
	-- Lone oak on its own hill, beyond the R1 animal clearing.
	local oakAt=safeSite(config,-1090,-1180,42);local oak=group("LoneOakHill",m)
	if kit and kit.tree then
		local tree=kit.tree(oak,"oak",oakAt,1.35,"LoneAutumnOak");tree.Name="LoneAutumnOak"
	else
		log(oak,"AncientTwistingTrunk",oakAt,oakAt+Vector3.new(3,47,0),5.8,P.dark)
		for i=1,5 do local t=i*math.pi*2/5;local dir=Vector3.new(math.cos(t),0,math.sin(t))
			bar(oak,"HeavyOakBranch",oakAt+Vector3.new(2,32,0),oakAt+dir*24+Vector3.new(0,55,0),3.6,P.dark,Enum.Material.Wood)
			local p=part(oak,"AsymmetricAutumnCrown",Vector3.new(47,27,43),CFrame.new(oakAt+dir*23+Vector3.new(0,59+(i%2)*7,0)),i%2==0 and P.leaf or Color3.fromRGB(100,113,57),Enum.Material.Grass,false)
			local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p
		end
	end
	fence(oak,oakAt+Vector3.new(-25,0,-30),38,math.rad(-22))
	for i=1,3 do part(oak,"MossyHillStone",Vector3.new(9+i,4,8),CFrame.new(oakAt+Vector3.new(i*9-22,1.5,15))*CFrame.Angles(0,i,0),P.moss,Enum.Material.Slate) end
	return m
end
function L.logging(parent,config,kit)
	local m=group("06_AbandonedLoggingCamp",parent);m:SetAttribute("Region","R3")
	local at=safeSite(config,-938,975,66)
	local mill=cabin(m,"BrokenSawmill_80x55",at,80,55,17,{ruined=true,backExit=true,rise=11})
	local sign=part(mill,"FadedMillName",Vector3.new(28,4,.6),CFrame.new(v(at,0,16,-28.2)),P.old);label(sign,"XƯỞNG GỖ SƯƠNG XÁM")
	part(mill,"SawMachineStonePlinth",Vector3.new(18,3,10),CFrame.new(v(at,15,3,8)),P.stone,Enum.Material.Slate)
	part(mill,"RustedSawTable",Vector3.new(16,.8,7),CFrame.new(v(at,15,5.8,8)),P.iron,Enum.Material.CorrodedMetal)
	local saw=part(mill,"StoppedSawBlade",Vector3.new(.4,6,6),CFrame.new(v(at,15,7.1,8)),Color3.fromRGB(110,104,83),Enum.Material.CorrodedMetal)
	saw.Shape=Enum.PartType.Cylinder
	for i=1,3 do bar(mill,"FallenRoofRafter",v(at,17+i*4,2.4,-6+i*3),v(at,34,9+i,-13+i),1.1,P.dark) end
	for i=1,4 do part(mill,"LooseSplitPlank",Vector3.new(3,.35,12+i),CFrame.new(v(at,-21+i*5,2.2,7))*CFrame.Angles(0,i*.3,0),P.old,false) end
	local bunkAt=safeSite(config,-1020,1110,35)
	local bunk=cabin(m,"WorkersBunkhouse_50x30",bunkAt,50,30,12,{backExit=true,rise=7})
	for _,xx in {-15,15} do
		part(bunk,"OldBunkFrame",Vector3.new(9,1,17),CFrame.new(v(bunkAt,xx,3,0)),P.dark)
		part(bunk,"FadedBedroll",Vector3.new(7,.7,13),CFrame.new(v(bunkAt,xx,3.9,0)),Color3.fromRGB(111,114,89),Enum.Material.Fabric,false)
	end
	local logsAt=safeSite(config,-820,1140,35)
	stackedLogs(m,logsAt,4,34);stackedLogs(m,logsAt+Vector3.new(25,0,-18),2,29)
	for i=1,3 do crate(m,at+Vector3.new(-51+i*4,0,-19),4) end
	bar(m,"CollapsedTimberRack",logsAt+Vector3.new(-17,1,-8),logsAt+Vector3.new(-9,5,19),1.2,P.old)
	local lookoutAt=safeSite(config,-370,920,65)
	local tower=group("OldLoggingLookoutTower",m)
	for _,x in {-9,9} do for _,z in {-9,9} do
		part(tower,"TowerBearingLeg",Vector3.new(2,43,2),CFrame.new(v(lookoutAt,x,21.5,z)),P.dark)
	end end
	for _,z in {-9,9} do
		bar(tower,"TowerDiagonalBrace",v(lookoutAt,-9,3,z),v(lookoutAt,9,35,z),1,P.old)
		bar(tower,"TowerCrossBrace",v(lookoutAt,9,3,z),v(lookoutAt,-9,35,z),1,P.old)
	end
	part(tower,"LookoutPlatform",Vector3.new(24,1.3,24),CFrame.new(v(lookoutAt,0,39,0)),P.old)
	for _,x in {-11,11} do for _,z in {-11,11} do part(tower,"LookoutRoofPost",Vector3.new(1,10,1),CFrame.new(v(lookoutAt,x,44.5,z)),P.dark) end end
	for _,x in {-11,11} do part(tower,"ViewingRail",Vector3.new(.8,1,24),CFrame.new(v(lookoutAt,x,44,0)),P.dark) end
	part(tower,"NorthViewingRail",Vector3.new(24,1,.8),CFrame.new(v(lookoutAt,0,44,11)),P.dark)
	for i=1,26 do part(tower,"WalkableTowerStair",Vector3.new(9,1.5,2),CFrame.new(v(lookoutAt,-5,i*1.5, -56+i*2)),P.old) end
	for _,x in {-9,0} do bar(tower,"StairStringer",v(lookoutAt,x,.3,-56),v(lookoutAt,x,38, -4),.8,P.dark) end
	gable(tower,v(lookoutAt,0,39.5,0),25,25,10,6,false)
	return m
end
function L.pine(parent,config,kit)
	local m=group("03_OldPineRefuges",parent);m:SetAttribute("Region","R2")
	local at=safeSite(config,-1060,290,25)
	cabin(m,"RainShelter_25x20",at,25,20,11,{backExit=true,rise=6})
	part(m,"ShelterBench",Vector3.new(15,.8,3),CFrame.new(v(at,0,3,6)),P.old)
	for _,x in {-6,6} do part(m,"ShelterBenchLeg",Vector3.new(.8,2,.8),CFrame.new(v(at,x,1.7,6)),P.dark) end
	local ancientAt=safeSite(config,-1480,205,30)
	if kit and kit.tree then
		local tree=kit.tree(m,"pine",ancientAt,1.28,"AncientWesternPine");tree.Name="AncientWesternPine"
	end
	-- A quiet natural recess has two real exits beneath exposed roots.
	local denAt=safeSite(config,-1510,-165,30);local den=group("RootDenTwoExits",m)
	part(den,"DryDenFloor",Vector3.new(30,.8,25),CFrame.new(v(denAt,0,.4,10)),P.moss,Enum.Material.Ground)
	for _,s in {-1,1} do
		part(den,"DenSideStone",Vector3.new(7,16,29),CFrame.new(v(denAt,s*18,7,10))*CFrame.Angles(0,0,math.rad(s*7)),P.stone,Enum.Material.Slate)
		part(den,"DenEntranceStone",Vector3.new(10,13,8),CFrame.new(v(denAt,s*11,6,-7)),P.stone,Enum.Material.Slate)
		part(den,"DenBackStone",Vector3.new(9,14,7),CFrame.new(v(denAt,s*12,6,25)),P.stone,Enum.Material.Slate)
		log(den,"RootArch",v(denAt,s*18,0,-10),v(denAt,s*6,14,-6),1.7,P.dark)
	end
	part(den,"DenRoofStone",Vector3.new(36,6,32),CFrame.new(v(denAt,0,17,9))*CFrame.Angles(0,0,math.rad(-4)),P.moss,Enum.Material.Slate)
	log(den,"ScoredFallenTrunk",v(denAt,-28,2,-28),v(denAt,-8,3,-22),2,P.dark)
	for i=1,4 do
		local p=part(den,"TrackInMud",Vector3.new(1.25,.06,2),CFrame.new(v(denAt,i%2==0 and -2 or 2,.9,-12-i*4)),P.dark,Enum.Material.Ground,false)
		p.Transparency=.24
	end
	local burnedAt=safeSite(config,-1680,730,30)
	for i=1,5 do local a=i*math.pi*2/5
		local p=burnedAt+Vector3.new(math.cos(a)*18,0,math.sin(a)*18)
		log(m,"OldFireBlackenedTrunk",p,p+Vector3.new(i%2==0 and 2 or -2,21+i*3,1),1.2,Color3.fromRGB(50,51,43))
		if kit and kit.tree and i%2==0 then kit.tree(m,"pine",p+Vector3.new(8,0,-4),.34,"FireRegrowth"..i) end
	end
	return m
end
function L.swamp(parent,config,kit)
	local m=group("05_SwampBoardwalk",parent);m:SetAttribute("Region","R4")
	-- Two dry ends flank a sheltered bend south-east of the animal rest node.
	local center=safeSite(config,1575,-450,55)
	local points={Vector3.new(-76,0,-45),Vector3.new(-76,0,30),Vector3.new(12,0,30),Vector3.new(88,0,30)}
	local total=0
	for i=1,#points-1 do
		local a,b=center+points[i],center+points[i+1]
		local ay=(if config.terrainHeight then config.terrainHeight(a.X,a.Z) else config.height(a.X,a.Z))+2.3
		local by=(if config.terrainHeight then config.terrainHeight(b.X,b.Z) else config.height(b.X,b.Z))+2.3
		-- Gentle, completely supported plank steps; no broken holes in player surface.
		local n=math.ceil((b-a).Magnitude/3.2)
		for j=1,n do local t=(j-.5)/n;local p=a:Lerp(b,t);p=Vector3.new(p.X,ay+(by-ay)*t,p.Z)
			local cf=CFrame.lookAt(p,p+(b-a).Unit)
			part(m,"SilveredBoardwalkPlank",Vector3.new(10,.7,(b-a).Magnitude/n+.1),cf,P.old)
			if j%4==0 then
				for _,s in {-1,1} do local support=cf*Vector3.new(s*4,-3.5,0)
					part(m,"MudBoardwalkPile",Vector3.new(.8,8,.8),CFrame.new(support),P.dark)
				end
			end
		end
		total+=(b-a).Magnitude
		if i==2 then
			local ap=Vector3.new(a.X,ay+3.6,a.Z)+Vector3.new(0,0,4.8)
			local bp=Vector3.new(b.X,by+3.6,b.Z)+Vector3.new(0,0,4.8)
			bar(m,"SingleDangerSideHandrail",ap,bp,.6,P.dark)
			for j=0,4 do local p=ap:Lerp(bp,j/4)
				part(m,"HandrailPost",Vector3.new(.7,4.3,.7),CFrame.new(p-Vector3.new(0,2,0)),P.dark)
			end
		end
	end
	m:SetAttribute("BoardwalkLength",total)
	local shackAt=ground(config,center.X-offset(config).X+13,center.Z-offset(config).Z+60)
	shackAt+=Vector3.new(0,3,0)
	local shack=cabin(m,"StiltBirdwatchingShack",shackAt,25,20,10,{backExit=true,rise=5})
	for _,x in {-10,10} do for _,z in {-8,8} do part(shack,"ShackStilt",Vector3.new(1.2,8,1.2),CFrame.new(v(shackAt,x,-2,z)),P.dark) end end
	for i=1,5 do part(shack,"ShackApproachStep",Vector3.new(11,.65,2),CFrame.new(v(shackAt,0,1.8-i*.65,-10-i*1.8)),P.old) end
	local boat=group("StrandedPunt",m);local bp=center+Vector3.new(66,1,-24)
	part(boat,"PuntFloor",Vector3.new(6,.65,16),CFrame.new(bp)*CFrame.Angles(0,math.rad(23),math.rad(-8)),P.old)
	for _,s in {-1,1} do part(boat,"PuntSide",Vector3.new(.7,2.4,16),CFrame.new(bp+Vector3.new(s*3,1,0))*CFrame.Angles(0,math.rad(23),math.rad(-8)),P.dark) end
	for _,zz in {-7,7} do part(boat,"PuntBow",Vector3.new(6,2.4,.65),CFrame.new(bp+Vector3.new(0,1,zz))*CFrame.Angles(0,math.rad(23),math.rad(-8)),P.dark) end
	return m
end
function L.gorge(parent,config,kit)
	local m=group("07_SplitStoneGorge",parent);m:SetAttribute("Region","B")
	local at=safeSite(config,760,1180,60)
	-- Optional narrow human discovery route beside the broad dinosaur corridor.
	for _,s in {-1,1} do
		for i=1,3 do
			part(m,"SplitAngularCliff",Vector3.new(24+i*6,55+i*8,37),CFrame.new(v(at,s*(27+i*2),21+i*3,(i-2)*29))*CFrame.Angles(math.rad(s*3),math.rad(s*(7+i*5)),math.rad(s*5)),i%2==0 and P.lightstone or P.stone,Enum.Material.Slate)
		end
	end
	local waterAt=Vector3.new(720,267,910)+offset(config)
	part(m,"WaterfallRockLip",Vector3.new(42,11,22),CFrame.new(waterAt+Vector3.new(0,6,0)),P.stone,Enum.Material.Slate)
	part(m,"EmbeddedWaterfallCliff",Vector3.new(43,60,18),CFrame.new(waterAt+Vector3.new(0,-28.5,8)),P.stone,Enum.Material.Slate)
	for i=1,4 do
		local p=part(m,"FallingWaterVeil",Vector3.new(5.2,55,1.3),CFrame.new(waterAt+Vector3.new((i-2.5)*4.9,-29.5,-12)),P.water,Enum.Material.Glass,false)
		p.Transparency=.4+(i%2)*.1;p.CastShadow=false
	end
	local basin=part(m,"FoamingWaterfallBasin",Vector3.new(43,.25,28),CFrame.new(waterAt+Vector3.new(0,-57,-16)),Color3.fromRGB(179,208,196),Enum.Material.Glass,false);basin.Transparency=.55
	for i=1,5 do part(m,"WaterfallBankRock",Vector3.new(13+i,11,12),CFrame.new(waterAt+Vector3.new(i%2==0 and -25 or 25,-54,(i-3)*11))*CFrame.Angles(0,i*.7,math.rad(i*2)),P.stone,Enum.Material.Slate) end
	-- A low bridge beside the basin has a continuous deck and two exits.
	local bridgeAt=waterAt+Vector3.new(-9,-53,-44)
	for i=1,12 do part(m,"StreamBridgePlank",Vector3.new(11,.7,3),CFrame.new(bridgeAt+Vector3.new(0,0,(i-.5)*3)),P.old) end
	for _,x in {-5,5} do
		part(m,"StreamBridgeStringer",Vector3.new(1.1,1.6,38),CFrame.new(bridgeAt+Vector3.new(x,-.8,18)),P.dark)
		bar(m,"StreamBridgeRail",bridgeAt+Vector3.new(x,4,0),bridgeAt+Vector3.new(x,4,36),.6,P.dark)
		for _,z in {0,18,36} do part(m,"StreamBridgePost",Vector3.new(.7,6,.7),CFrame.new(bridgeAt+Vector3.new(x,1,z)),P.dark) end
	end
	for _,side in {-1,1} do
		for i=1,3 do
			local zz=if side<0 then -i*2.5 else 36+i*2.5
			local p=bridgeAt+Vector3.new(0,0,zz)
			local height=if config.terrainHeight then config.terrainHeight(p.X,p.Z) else config.height(p.X,p.Z)
			p=Vector3.new(p.X,bridgeAt.Y+(height+.5-bridgeAt.Y)*i/3,p.Z)
			part(m,"StreamBridgeLandingStep",Vector3.new(11,.7,2.6),CFrame.new(p),P.old)
		end
	end
	return m
end
function L.cave(parent,config,kit)
	local m=group("08_MountainCave",parent);m:SetAttribute("Region","C");m:SetAttribute("HasMainAndBackExit",true)
	local at=safeSite(config,220,1750,57)
	m:SetAttribute("GroundBase",at)
	m:SetAttribute("TerrainCarveCenter",at+Vector3.new(0,11,8))
	m:SetAttribute("TerrainCarveSize",Vector3.new(44,20,64))
	m:SetAttribute("TerrainApproachFront",at+Vector3.new(0,0,-35))
	m:SetAttribute("TerrainApproachBack",at+Vector3.new(0,0,48))
	-- Surface-built, open-ended rock shelter: playable 18×16 entrance and 45×35 chamber.
	-- Separate slabs create real voids; never a solid rock with a painted doorway.
	part(m,"DryChamberFloor",Vector3.new(45,1.2,35),CFrame.new(v(at,0,1,16)),P.stone,Enum.Material.Slate)
	for _,s in {-1,1} do
		part(m,"ChamberSideWall",Vector3.new(5,23,39),CFrame.new(v(at,s*24,11.5,16))*CFrame.Angles(0,0,math.rad(-s*3)),P.stone,Enum.Material.Slate)
		part(m,"PortalRockPier",Vector3.new(15,21,14),CFrame.new(v(at,s*16.5,10.5,-12))*CFrame.Angles(0,math.rad(s*8),math.rad(-s*3)),P.lightstone,Enum.Material.Slate)
		-- Far wall leaves a clear 12-stud rear escape between the two blocks.
		part(m,"BackExitWall",Vector3.new(16,22,5),CFrame.new(v(at,s*14,11,35)),P.stone,Enum.Material.Slate)
	end
	part(m,"EntranceLintel",Vector3.new(45,7,18),CFrame.new(v(at,0,20,-12))*CFrame.Angles(math.rad(-4),0,0),P.lightstone,Enum.Material.Slate)
	-- Ceiling has a narrow daylight slit along x=0, keeping shapes readable by day.
	for _,s in {-1,1} do part(m,"SplitCaveCeiling",Vector3.new(21,7,40),CFrame.new(v(at,s*12.5,25,16))*CFrame.Angles(0,0,math.rad(s*4)),P.stone,Enum.Material.Slate) end
	for _,s in {-1,1} do
		for i=1,3 do
			local p=part(m,"BrokenOuterCaveFacet",Vector3.new(18,20+i*3,22),CFrame.new(v(at,s*(31-i),9+i*2,-17+i*17))*CFrame.Angles(math.rad(i*6),s*(.4+i*.35),math.rad(s*8)),i%2==0 and P.lightstone or P.stone,Enum.Material.Slate,false,"WedgePart")
			p.CastShadow=true
		end
	end
	part(m,"DryLeafSleepingHollow",Vector3.new(17,.2,12),CFrame.new(v(at,-9,1.8,21)),Color3.fromRGB(118,104,66),Enum.Material.LeafyGrass,false)
	for i=1,4 do part(m,"SmallCaveFloorStone",Vector3.new(2+i,.7,2),CFrame.new(v(at,13-i*2,1.9,4+i*5))*CFrame.Angles(0,i*.7,0),P.moss,Enum.Material.Slate) end
	-- Entry clues are placed on the side, leaving the 18-stud opening clear.
	local scratch=log(m,"ClawedDeadwood",v(at,-29,0,-30),v(at,-26,22,-29),1.7,P.dark)
	for i=1,3 do bar(m,"OldClawScar",v(at,-27.8+i*.5,9,-30.7),v(at,-27.5+i*.5,14,-30.7),.16,P.cream,Enum.Material.Wood,false) end
	for i=1,5 do
		local mark=part(m,"LargeAnimalTrack",Vector3.new(2.2,.07,3.1),CFrame.new(v(at,(i%2==0 and 2 or -2),1.65,-21-i*5))*CFrame.Angles(0,math.rad(-12+i*3),0),P.dark,Enum.Material.Ground,false)
		mark.Transparency=.25
	end
	return m
end
function L.build(parent,config,kit)
	assert(parent and config,"ValleyLandmarks.build requires a generated parent and map config")
	assert(not game:GetService("RunService"):IsRunning(),"Landmarks are built only in Edit")
	local result={}
	for _,name in {"camp","pine","lake","logging","swamp","gorge","cave"} do
		result[name]=L[name](parent,config,kit);task.wait()
	end
	parent:SetAttribute("LandmarkPartCount",made);parent:SetAttribute("LandmarkVersion","GreyMistValley_1")
	return result
end
return L
