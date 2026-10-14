local fs=require("@lune/fs")
local r=require("@lune/roblox")
local luau=require("@lune/luau")
local env={Instance=r.Instance,Vector3=r.Vector3,Vector2=r.Vector2,CFrame=r.CFrame,Color3=r.Color3,Enum=r.Enum,
	ColorSequence=r.ColorSequence,ColorSequenceKeypoint=r.ColorSequenceKeypoint,NumberSequence=r.NumberSequence,
	NumberSequenceKeypoint=r.NumberSequenceKeypoint,NumberRange=r.NumberRange}
local builder=luau.load(fs.readFile("src/dark-jungle/WeaponsPro.luau"),{environment=env,injectGlobals=true})()
for _,id in builder.Order do
	local weapon=builder.build(id)
	assert(weapon:IsA("Model") and weapon.PrimaryPart)
	local fx=0
	for _,assembly in weapon:GetChildren() do
		local parts,welds=0,0
		for _,v in assembly:GetDescendants() do
			if v:IsA("BasePart") then parts+=1;assert(not v.CanCollide and not v.CanTouch and not v.CanQuery) end
			if v:IsA("Weld") then welds+=1;assert(v.Part0 and v.Part1) end
			if v:IsA("Trail") then fx+=1;assert(not v.Enabled and v.Attachment0 and v.Attachment1) end
		end
		assert(welds==parts-1,id.." joints")
	end
	assert(fx==(if id=="DualDaggers" then 2 else 1),id.." trails")
	weapon:Destroy()
end
local old=r.deserializePlace(fs.readFile("backups/HunDino_v2_3_before_weapons_pro_20261015.rbxl"))
local new=r.deserializePlace(fs.readFile("HunDino_DarkJungle_v2_3.rbxl"))
local function scene(root)
	local rows={}
	local hall=root.HunDinoL0.Training.ArmoryHall
	for _,v in root:GetDescendants() do
		if v:IsA("BasePart") then
			local excluded=false
			for _,id in builder.Order do if v:IsDescendantOf(hall["Display_"..id]) then excluded=true;break end end
			if not excluded then table.insert(rows,table.concat({v:GetFullName(),tostring(v.CFrame),tostring(v.Size),tostring(v.Color),tostring(v.Material),tostring(v.Anchored),tostring(v.CanCollide)},"|")) end
		end
	end
	table.sort(rows)
	return table.concat(rows,"\n"),#rows
end
local a,count=scene(old:GetService("Workspace"));local b=scene(new:GetService("Workspace"))
assert(a==b,"unrelated scene modified")
local function norm(s) return s:gsub("\r",""):gsub("%s+$","") end
local shared=new:GetService("ReplicatedStorage").Shared
for _,name in {"WeaponsPro","WeaponVFX","PetAnimator"} do assert(norm(shared[name].Source)==norm(fs.readFile("src/dark-jungle/"..name..".luau"))) end
local scripts=new:GetService("StarterPlayer").StarterPlayerScripts
assert(scripts:FindFirstChild("HunDinoWeaponEffects") and not scripts:FindFirstChild("HunDinoKatanaEffects"))
assert(norm(scripts.HunDinoWeaponEffects.Source)==norm(fs.readFile("src/dark-jungle/WeaponEffects.client.luau")))
assert(norm(scripts.HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.client.luau")))
assert(norm(new:GetService("ServerScriptService").HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.server.luau")))
for _,v in new:GetDescendants() do if v:IsA("LuaSourceContainer") then luau.compile(v.Source) end end
local templates=new:GetService("ServerStorage").TrainingWeapons
for _,id in builder.Order do
	local weapon=templates[id]
	assert(weapon:IsA("Model") and weapon.Main.PrimaryPart)
	local fx=0
	for _,v in weapon:GetDescendants() do
		if v:IsA("BasePart") then assert(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery) end
		if v:IsA("Trail") or v:IsA("ParticleEmitter") then fx+=1;assert(not v.Enabled) end
	end
	assert(fx==(if id=="DualDaggers" then 4 else 2),id.." stored FX")
end
assert(templates.Katana:FindFirstChild("Sheath"))
print("PASS seven weapon builders, saved templates/sources, joints/trails, sheath and",count,"unrelated map parts")
