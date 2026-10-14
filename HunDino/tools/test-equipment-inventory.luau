local fs=require("@lune/fs")
local luau=require("@lune/luau")
local r=require("@lune/roblox")
for _,path in {"src/dark-jungle/ArmorEquipment.luau","src/dark-jungle/EquipmentInventory.luau","src/dark-jungle/Training.server.luau","src/dark-jungle/Training.client.luau","studio-pet-integration/Training.server.luau","studio-pet-integration/Training.client.luau"} do luau.compile(fs.readFile(path)) end
local armor=luau.load(fs.readFile("src/dark-jungle/ArmorEquipment.luau"),{environment={Color3=r.Color3,Vector3=r.Vector3,CFrame=r.CFrame,Instance=r.Instance,Enum=r.Enum},injectGlobals=true})()
assert(#armor.Slots==5)
for _,target in {"Player","Pet"} do
	for _,id in armor.Order do
		for _,slot in armor.Slots do
			local piece=armor.icon(target,slot,id)
			local parts=0
			for _,v in piece:GetDescendants() do if v:IsA("BasePart") then parts+=1;assert(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery) end end
			assert(parts>0,target..id..slot)
			piece:Destroy()
		end
	end
end
assert(not armor.valid("Unknown","Metal"));assert(not armor.valid("Head","Fake"));assert(armor.valid("Head","None"))
print("PASS inventory/server compilation, five slots, forty player/pet armor previews, collision flags and catalog validation")
if require("@lune/process").args[1]=="--saved" then
	local place=r.deserializePlace(fs.readFile("HunDino_DarkJungle_v2_3.rbxl"))
	local shared=place:GetService("ReplicatedStorage").Shared
	local function norm(s) return s:gsub("\r",""):gsub("%s+$","") end
	for _,name in {"ArmorEquipment","EquipmentInventory"} do assert(norm(shared[name].Source)==norm(fs.readFile("src/dark-jungle/"..name..".luau")),name.." saved source") end
	assert(norm(place:GetService("ServerScriptService").HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.server.luau")),"saved server")
	assert(norm(place:GetService("StarterPlayer").StarterPlayerScripts.HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.client.luau")),"saved client")
	print("PASS saved inventory modules, server and client")
end
