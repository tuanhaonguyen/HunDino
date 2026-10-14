-- Read-only verification of the Studio-saved upgrade and scene preservation.
local fs=require("@lune/fs")
local r=require("@lune/roblox")
local luau=require("@lune/luau")
local old=r.deserializePlace(fs.readFile("backups/HunDino_v2_3_before_katana_20261015.rbxl"))
local new=r.deserializePlace(fs.readFile("HunDino_DarkJungle_v2_3.rbxl"))
local function signature(root)
	local parts={}
	local display=root.HunDinoL0.Training.ArmoryHall.Display_Katana
	for _,v in root:GetDescendants() do
		if v:IsA("BasePart") and not v:IsDescendantOf(display) then
			table.insert(parts,table.concat({v:GetFullName(),tostring(v.CFrame),tostring(v.Size),tostring(v.Color),tostring(v.Material),tostring(v.Anchored),tostring(v.CanCollide)},"|"))
		end
	end
	table.sort(parts)
	return table.concat(parts,"\n"),#parts
end
local a,count=signature(old:GetService("Workspace"))
local b=signature(new:GetService("Workspace"))
assert(a==b,"unrelated map geometry changed")
local function normalize(s) return s:gsub("\r", ""):gsub("%s+$", "") end
local shared=new:GetService("ReplicatedStorage").Shared
assert(normalize(shared.KatanaPro.Source)==normalize(fs.readFile("src/dark-jungle/KatanaPro.luau")))
assert(normalize(shared.PetAnimator.Source)==normalize(fs.readFile("src/dark-jungle/PetAnimator.luau")))
assert(normalize(new:GetService("StarterPlayer").StarterPlayerScripts.HunDinoKatanaEffects.Source)==normalize(fs.readFile("src/dark-jungle/KatanaEffects.client.luau")))
assert(normalize(new:GetService("ServerScriptService").HunDinoTraining.Source)==normalize(fs.readFile("studio-pet-integration/Training.server.luau")))
for _,v in new:GetDescendants() do if v:IsA("LuaSourceContainer") then luau.compile(v.Source) end end
local template=new:GetService("ServerStorage").TrainingWeapons.Katana
local parts,welds=0,0
for _,v in template.Main:GetDescendants() do
	if v:IsA("BasePart") then parts+=1; assert(v.Anchored and not v.CanCollide and not v.CanQuery and not v.CanTouch) end
	if v:IsA("Weld") then welds+=1 end
end
assert(parts==16 and welds==15)
assert(template.Main.Handle.SlashTrail.Attachment0==template.Main.Handle.TrailBase)
assert(template.Main.Handle.SlashTrail.Attachment1==template.Main.Handle.TrailTip)
assert(not template.Main.Handle.SlashTrail.Enabled and not template.Main.BladeTip.SlashSparks.Enabled)
assert(template.Sheath.Scabbard.Size==old:GetService("ServerStorage").TrainingWeapons.Katana.Sheath.Scabbard.Size)
for _,name in {"Hammer","SwordShield","Glaive","DualDaggers","Bow","GreatAxe"} do
	local before=old:GetService("ServerStorage").TrainingWeapons[name]
	local after=new:GetService("ServerStorage").TrainingWeapons[name]
	assert(#before:GetDescendants()==#after:GetDescendants(),name.." modified")
end
print("PASS saved katana model/VFX/animation sources, 16 parts/15 welds, sheath, other weapons and",count,"unrelated map parts")
