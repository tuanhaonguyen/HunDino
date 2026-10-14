local fs=require("@lune/fs")
local luau=require("@lune/luau")
local r=require("@lune/roblox")
local env={Color3=r.Color3,Vector3=r.Vector3,CFrame=r.CFrame,Instance=r.Instance,Enum=r.Enum}
local armor=luau.load(fs.readFile("src/dark-jungle/ArmorEquipment.luau"),{environment=env,injectGlobals=true})()
local standing=luau.load(fs.readFile("src/dark-jungle/PetStanding.luau"),{environment=env,injectGlobals=true})()
local counts={Training={6,5,6,4,4},Leather={5,6,8,5,4},Metal={8,7,9,5,6},Bone={11,11,8,6,4}}
local model,rig=standing.build()
for _,id in armor.Order do
	local equipment={};for _,slot in armor.Slots do equipment[slot]=id end
	local all=armor.apply(model,"Pet",equipment)
	assert(#all:GetChildren()==5)
	for i,slot in armor.Slots do
		local group=all["Armor_"..slot];local defs=armor.petSet(id).slots[slot]
		assert(#group:GetChildren()==counts[id][i] and #defs==counts[id][i],id..slot.." part count")
		for j,def in defs do
			local p=group[string.format("%s_%s_%d",if id=="Training" then "Hunter" else id,slot,j)];local weld=p.ArmorWeld
			assert(p.ClassName==(def[7] or "Part"),id..slot.." class")
			-- Lune stores Part sizes with a small fixed-point rounding error.
			assert((p.Size-def[2]).Magnitude<1e-4,id..slot..j.." size")
			assert(math.abs(p.Color.R-def[4].R)+math.abs(p.Color.G-def[4].G)+math.abs(p.Color.B-def[4].B)<1e-5,id..slot.." color")
			assert(p.Material==def[6],id..slot.." material")
			assert(not p.Anchored and p.Massless and not p.CanCollide and not p.CanQuery and not p.CanTouch)
			assert(weld.Part0==rig.Bones[def[1]] and weld.Part1==p,id..slot.." bone")
			local expected=r.CFrame.new(def[3]);if def[5] then expected*=r.CFrame.Angles(table.unpack(def[5])) end
			local actualComponents={weld.C0:GetComponents()};local expectedComponents={expected:GetComponents()}
			for k,value in expectedComponents do assert(math.abs(actualComponents[k]-value)<1e-5,id..slot.." offset") end
		end
	end
	for _,horn in rig.Slots.Horns do assert(horn.Transparency==(if armor.petSet(id).hideNaturalHorns then 1 else 0)) end
	for _,slot in {"Helmet","Armor"} do for _,p in rig.Slots[slot] do assert(p.Transparency==1) end end
end
local mixed={Head="Training",Chest="Bone",Arms="Metal",Waist="Bone",Legs="Leather"}
local all=armor.apply(model,"Pet",mixed)
for _,slot in armor.Slots do assert(all["Armor_"..slot]:GetAttribute("ArmorSet")==mixed[slot]) end
mixed.Head="None";all=armor.apply(model,"Pet",mixed)
assert(#all.Armor_Head:GetChildren()==0)
for _,horn in rig.Slots.Horns do assert(horn.Transparency==0) end
local n=0;for _,v in model:GetChildren() do if v.Name=="EquipmentArmor" then n+=1 end end;assert(n==1)
model:Destroy()
print("PASS 4 pet sets x 5 slots: 128 reference parts, offsets/materials, correct bone welds, horns, mixed equipment and removal")
