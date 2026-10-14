-- Cosmetic training equipment. Each slot is independent for the player and pet.
local Armor={}
Armor.Slots={"Head","Chest","Arms","Waist","Legs"}
Armor.SlotNames={Head="Đầu",Chest="Thân",Arms="Tay",Waist="Eo",Legs="Chân"}
Armor.ItemNames={Head="Mũ",Chest="Giáp thân",Arms="Giáp tay",Waist="Đai giáp",Legs="Giáp chân"}
Armor.Order={"Training","Leather","Metal","Bone"}
Armor.Sets={
	Training={Name="Thợ săn",Color=Color3.fromRGB(92,71,48),Trim=Color3.fromRGB(68,106,98),Material=Enum.Material.SmoothPlastic},
	Leather={Name="Da",Color=Color3.fromRGB(124,79,47),Trim=Color3.fromRGB(221,169,93),Material=Enum.Material.Fabric},
	Metal={Name="Kim loại",Color=Color3.fromRGB(110,135,140),Trim=Color3.fromRGB(232,183,95),Material=Enum.Material.Metal},
	Bone={Name="Xương",Color=Color3.fromRGB(223,209,174),Trim=Color3.fromRGB(123,91,61),Material=Enum.Material.SmoothPlastic},
}
function Armor.valid(slot,id)
	return table.find(Armor.Slots,slot)~=nil and (id=="None" or Armor.Sets[id]~=nil)
end
function Armor.read(player,target)
	local out={}
	for _,slot in Armor.Slots do out[slot]=player:GetAttribute(target.."Armor_"..slot) or (if target=="Pet" then "Metal" else "Training") end
	return out
end
local function find(model,names)
	for _,name in names do local p=model:FindFirstChild(name);if p and p:IsA("BasePart") then return p end end
end

function Armor.slot(model,target,slot,id)
	assert(Armor.valid(slot,id),"Invalid armor selection")
	local group=Instance.new("Model");group.Name="Armor_"..slot
	group:SetAttribute("ArmorSlot",slot);group:SetAttribute("ArmorSet",id)
	if id=="None" then return group end
	local style=Armor.Sets[id]
	local pet=target=="Pet"
	local function add(bone,name,size,offset,trim,class)
		if not bone then return end
		local p=Instance.new(class or "Part");p.Name=name;p.Size=size
		p.Color=if trim then style.Trim else style.Color;p.Material=style.Material
		p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true
		p.CFrame=bone.CFrame*offset;p.Parent=group
		local w=Instance.new("Weld");w.Name="ArmorWeld";w.Part0=bone;w.Part1=p;w.C0=offset;w.Parent=p
		if not group.PrimaryPart then group.PrimaryPart=p end
		return p
	end
	if slot=="Head" then
		local bone=find(model,{"Head"})
		if bone then
			local size=if pet then Vector3.new(1.3,1.1,1.25) else bone.Size
			add(bone,"HelmetCrown",Vector3.new(size.X*1.12,size.Y*.3,size.Z*1.08),CFrame.new(0,size.Y*.52,0))
			add(bone,"HelmetBand",Vector3.new(size.X*1.15,size.Y*.12,size.Z*1.1),CFrame.new(0,size.Y*.35,0),true)
			for _,side in {-1,1} do
				add(bone,"CheekPlate",Vector3.new(size.X*.1,size.Y*.48,size.Z*.52),CFrame.new(side*size.X*.54,0,0))
				if id=="Bone" then add(bone,"Horn",Vector3.new(.15,.36,.18),CFrame.new(side*size.X*.36,size.Y*.78,0)*CFrame.Angles(0,0,-side*.3),true,"WedgePart") end
			end
		end
	elseif slot=="Chest" then
		local bone=find(model,if pet then {"Torso"} else {"UpperTorso","Torso"})
		if bone then
			local size=if pet then Vector3.new(1.4,1.7,1.1) else bone.Size
			for _,side in {-1,1} do add(bone,"BodyPlate",Vector3.new(size.X*1.04,size.Y*.76,.18),CFrame.new(0,0,side*(size.Z*.5+.09))) end
			add(bone,"CollarTrim",Vector3.new(size.X*1.08,.12,.22),CFrame.new(0,size.Y*.32,-size.Z*.5-.1),true)
			add(bone,"HunterBadge",Vector3.new(.27,.36,.1),CFrame.new(0,0,-size.Z*.5-.23),true)
		end
	elseif slot=="Arms" then
		for _,side in {"R","L"} do
			local bone=find(model,if pet then {"Arm"..side} elseif side=="R" then {"RightUpperArm","Right Arm"} else {"LeftUpperArm","Left Arm"})
			if bone then
				local size=if pet then Vector3.new(.6,.65,.6) else bone.Size
				local y=if pet then .12 else size.Y*.32
				add(bone,"ShoulderGuard",Vector3.new(size.X*1.25,.28,size.Z*1.18),CFrame.new(0,y,0))
				add(bone,"ShoulderTrim",Vector3.new(size.X*1.3,.07,size.Z*1.22),CFrame.new(0,y+.17,0),true)
				if id=="Bone" then add(bone,"ShoulderSpike",Vector3.new(.18,.32,.18),CFrame.new(0,y+.32,0),true,"WedgePart") end
			end
		end
	elseif slot=="Waist" then
		local bone=find(model,if pet then {"Torso"} else {"LowerTorso","Torso","HumanoidRootPart"})
		if bone then
			local size=if pet then Vector3.new(1.4,1.7,1.1) else bone.Size
			local y=if pet then -.72 else -size.Y*.38
			add(bone,"Belt",Vector3.new(size.X*1.1,.24,size.Z*1.1),CFrame.new(0,y,0))
			add(bone,"Buckle",Vector3.new(.32,.32,.12),CFrame.new(0,y,-size.Z*.56-.07),true)
			for _,side in {-1,1} do add(bone,"HipPlate",Vector3.new(size.X*.3,.4,.16),CFrame.new(side*size.X*.35,y-.23,-size.Z*.5)) end
		end
	elseif slot=="Legs" then
		for _,side in {"R","L"} do
			local bone=find(model,if pet then {"Leg"..side} elseif side=="R" then {"RightLowerLeg","Right Leg"} else {"LeftLowerLeg","Left Leg"})
			if bone then
				local size=if pet then Vector3.new(.55,.8,.65) else bone.Size
				local y=if pet then -.72 else -size.Y*.04
				add(bone,"ShinPlate",Vector3.new(size.X*.8,if pet then .7 else size.Y*.68,.15),CFrame.new(0,y,-size.Z*.5-.04))
				add(bone,"KneeTrim",Vector3.new(size.X*.88,.2,.2),CFrame.new(0,y+.29,-size.Z*.5-.06),true)
			end
		end
	end
	return group
end

function Armor.apply(model,target,equipment)
	local old=model:FindFirstChild("EquipmentArmor");if old then old:Destroy() end
	local legacy=model:FindFirstChild("TrainingArmor");if legacy then legacy:Destroy() end
	if target=="Pet" then
		for _,p in model:GetChildren() do
			if p:IsA("BasePart") then
				local slot=p:GetAttribute("Slot")
				if slot=="Armor" or slot=="Helmet" then p.Transparency=1
				elseif slot=="Horns" then p.Transparency=if equipment.Head=="None" then 0 else 1 end
			end
		end
	else
		for _,accessory in model:GetChildren() do
			if accessory:IsA("Accessory") and (accessory.AccessoryType==Enum.AccessoryType.Hair or accessory.AccessoryType==Enum.AccessoryType.Hat) then
				for _,part in accessory:GetDescendants() do if part:IsA("BasePart") then
					if part:GetAttribute("ArmorOriginalTransparency")==nil then part:SetAttribute("ArmorOriginalTransparency",part.Transparency) end
					part.Transparency=if equipment.Head=="None" then part:GetAttribute("ArmorOriginalTransparency") else 1
				end end
			end
		end
	end
	local all=Instance.new("Model");all.Name="EquipmentArmor"
	for _,slot in Armor.Slots do Armor.slot(model,target,slot,equipment[slot] or "None").Parent=all end
	all.Parent=model
	return all
end

function Armor.icon(target,slot,id)
	local body=Instance.new("Model")
	local names=if target=="Pet" then {"Head","Torso","ArmR","ArmL","LegR","LegL"} else {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
	for i,name in names do
		local p=Instance.new("Part");p.Name=name;p.Transparency=1;p.Anchored=true
		p.Size=if name=="Head" then Vector3.new(2,1,1) elseif name=="Torso" then Vector3.new(2,2,1) else Vector3.new(1,2,1)
		p.CFrame=CFrame.new(if i==3 or i==5 then -.65 elseif i==4 or i==6 then .65 else 0,0,0);p.Parent=body
	end
	local piece=Armor.slot(body,target,slot,id)
	for _,v in piece:GetDescendants() do if v:IsA("Weld") then v:Destroy() elseif v:IsA("BasePart") then v.Anchored=true end end
	body:Destroy()
	return piece
end

return Armor
