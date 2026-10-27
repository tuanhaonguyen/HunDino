-- Silver iron outcrop art only. The caller owns placement, prompts and mining.
-- Six prismatic shafts and closed-sided tips use native parts: no uploaded mesh,
-- texture, union operation or runtime asset permission is required.
local Ore={Version="IronOreVisual.2",MaximumParts=61}
local V=Vector3.new
local FACE_COLORS={
	Color3.fromRGB(218,227,221),
	Color3.fromRGB(137,157,155),
	Color3.fromRGB(100,122,123),
	Color3.fromRGB(181,199,194),
}
local function variation(index,salt)
	return ((index*137+salt*293)%997)/997
end
local function part(parent,name,size,cf,color,material,className)
	local p=Instance.new(className or "Part")
	p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
	p.Material=material or Enum.Material.Metal
	p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
	p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
	p.CastShadow=true;p.Parent=parent
	return p
end

-- Two thin native wedges fill an arbitrary triangular facet. Keeping the
-- longest side as the base guarantees both wedge lengths remain positive.
local function facet(parent,name,a,b,c,color)
	local ab,ac,bc=b-a,c-a,c-b
	local ab2,ac2,bc2=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
	if ab2>ac2 and ab2>bc2 then c,a=a,c
	elseif ac2>ab2 and ac2>bc2 then a,b=b,a end
	ab,ac,bc=b-a,c-a,c-b
	local right=ac:Cross(ab).Unit
	local up=bc:Cross(right).Unit
	local back=bc.Unit
	local height=math.abs(ab:Dot(up))
	local first=part(parent,name.."A",V(.035,height,math.max(.01,math.abs(ab:Dot(back)))),
		CFrame.fromMatrix((a+b)*.5,right,up,back),color,nil,"WedgePart")
	local second=part(parent,name.."B",V(.035,height,math.max(.01,math.abs(ac:Dot(back)))),
		CFrame.fromMatrix((a+c)*.5,-right,up,-back),color,nil,"WedgePart")
	first.Reflectance=.08;second.Reflectance=.08
end
local function crystal(parent,index,row,seed)
	local model=Instance.new("Model");model.Name=string.format("Crystal%02d",index)
	model:SetAttribute("StrikeGroup",(index-1)%3+1)
	model.Parent=parent
	local scale=.94+variation(seed,index)*.12
	local height,width,depth=row[4]*scale,row[5]*scale,row[6]*scale
	local frame=CFrame.new(row[1],row[2],row[3])
		*CFrame.Angles(math.rad(row[7]),math.rad(row[8]),math.rad(row[9]))
	local shaftHeight=height*.68
	local shaft=part(model,"Shaft",V(width,shaftHeight,depth),frame*CFrame.new(0,shaftHeight*.5,0),
		Color3.fromRGB(181,195,190),Enum.Material.Metal)
	shaft.Reflectance=.12
	local base={V(-width*.5,shaftHeight,-depth*.5),V(width*.5,shaftHeight,-depth*.5),
		V(width*.5,shaftHeight,depth*.5),V(-width*.5,shaftHeight,depth*.5)}
	local apex=frame:PointToWorldSpace(V(width*.08,height,-depth*.06))
	for face=1,4 do
		local color=FACE_COLORS[face]:Lerp(Color3.fromRGB(179,191,185),variation(seed,index+face)*.12)
		facet(model,"Facet"..face,frame:PointToWorldSpace(base[face]),
			frame:PointToWorldSpace(base[face%4+1]),apex,color)
	end
end
function Ore.build(nodeId:string,index:number):Model
	assert(type(nodeId)=="string" and nodeId~="","Iron ore needs a node ID")
	assert(type(index)=="number" and index%1==0 and index>0,"Iron ore needs a positive index")
	local model=Instance.new("Model");model.Name="IronOre_"..nodeId
	model:SetAttribute("MiningNodeId",nodeId);model:SetAttribute("VisualVersion",Ore.Version)
	local root=part(model,"Root",V(1,.35,1),CFrame.new(),Color3.fromRGB(51,50,43),Enum.Material.Slate)
	root.Transparency=1;root.CastShadow=false;model.PrimaryPart=root
	local rock=Instance.new("Folder");rock.Name="Rock";rock.Parent=model
	for n=1,6 do
		local angle=math.rad((n-1)*60+variation(index,n)*18)
		local radius=if n==1 then .15 else 1.65
		local p=part(rock,"Bedrock"..n,V(3.5-variation(index,n)*.5,1.35+variation(index,n+6)*.4,2.8),
			CFrame.new(math.cos(angle)*radius,.43,math.sin(angle)*radius*.66)
				*CFrame.Angles(variation(index,n+12)*.3,angle,variation(index,n+18)*.22),
			Color3.fromRGB(62,58,47):Lerp(Color3.fromRGB(99,92,73),variation(index,n)*.5),Enum.Material.Slate)
		p.Shape=Enum.PartType.Ball
	end
	local crystals=Instance.new("Folder");crystals.Name="Crystals";crystals.Parent=model
	-- Back/center spear, two fans and low foreground splinters form one outcrop.
	local rows={
		{ .15,.73, .45,6.65,2.15,1.65, -3,  8, -3},
		{-1.38,.66, .22,4.95,1.88,1.52, -2,-18, 14},
		{ 1.36,.63, .38,4.72,1.70,1.55,  8, 27,-18},
		{-2.08,.54,-.29,3.45,1.45,1.26,-12, 18, 24},
		{ 1.95,.49,-.53,3.20,1.48,1.16,-18,-23,-27},
		{-.28,.50,-1.03,2.70,1.53,1.12,-19, 15,  5},
	}
	for n,row in rows do crystal(crystals,n,row,index) end
	return model
end
return Ore
