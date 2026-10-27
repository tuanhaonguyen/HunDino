-- Held presentation only. Local Y follows the wooden shaft; the steel head
-- spans local X. Handle's origin is the hand grip. The caller attaches and poses
-- this assembly; this module adds no input, animation, damage or tool behavior.
local Pickaxe={Version="MiningPickaxeVisual.1"}
local V=Vector3.new
function Pickaxe.build():Model
	local model=Instance.new("Model");model.Name="MiningPickaxe"
	model:SetAttribute("VisualVersion",Pickaxe.Version)
	local function part(name,size,cf,color,material,className)
		local p=Instance.new(className or "Part")
		p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material
		p.Anchored=false;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
		p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model
		return p
	end
	local wood=Color3.fromRGB(111,73,40)
	local steel=Color3.fromRGB(65,80,83)
	local edge=Color3.fromRGB(164,183,181)
	local handle=part("Handle",V(.18,2.35,.20),CFrame.new(),wood,Enum.Material.Wood)
	model.PrimaryPart=handle
	part("LeatherGrip",V(.225,.66,.245),CFrame.new(0,-.18,0),Color3.fromRGB(55,43,33),Enum.Material.Fabric)
	part("Pommel",V(.235,.16,.25),CFrame.new(0,-1.10,0),steel,Enum.Material.Metal)
	part("HeadSocket",V(.35,.35,.34),CFrame.new(0,.99,0),steel,Enum.Material.Metal)
	part("ForgedHead",V(1.20,.25,.29),CFrame.new(0,1.11,0),steel,Enum.Material.Metal)
	for _,side in {-1,1} do
		part(if side<0 then "PickLeft" else "PickRight",V(.29,.43,.86),
			CFrame.new(side*.87,1.00,0)*CFrame.Angles(0,side*math.pi*.5,0)
				*CFrame.Angles(math.rad(-13),0,0),steel,Enum.Material.Metal,"WedgePart")
		local tip=part(if side<0 then "EdgeLeft" else "EdgeRight",V(.13,.21,.47),
			CFrame.new(side*1.12,.87,0)*CFrame.Angles(0,side*math.pi*.5,0)
				*CFrame.Angles(math.rad(-18),0,0),edge,Enum.Material.Metal,"WedgePart")
		tip.Reflectance=.12
	end
	for _,p in model:GetChildren() do
		if p:IsA("BasePart") and p~=handle then
			local weld=Instance.new("WeldConstraint");weld.Name="Bind"..p.Name
			weld.Part0=handle;weld.Part1=p;weld.Parent=handle
		end
	end
	return model
end
return Pickaxe
