local fs=require("@lune/fs")
local r=require("@lune/roblox")
local luau=require("@lune/luau")
local place=r.deserializePlace(fs.readFile("HunDino_DarkJungle_v2_3.rbxl"))
local map=place:GetService("Workspace").HunDinoL0
-- The linked build starts from the newer user-edited hub. Its fresh backup
-- preserves the moved welcome sign and edited rocks absent from the older one.
local linked=map:GetAttribute("HuntingLinked")==true
local old=r.deserializePlace(fs.readFile(if linked then "backups/Hub_before_hunting_link_20261016.rbxl" else "backups/HunDino_v2_3_before_base_transit_20261015.rbxl"))
local transit=map.BaseTransit
assert(#transit.Bases:GetChildren()==12)
local function check(m)
	assert(m.ModelStreamingMode==r.Enum.ModelStreamingMode.Persistent)
	assert(m.Pad.Transparency==1 and not m.Pad.CanCollide and not m.Pad.CanQuery)
	local p=m.Pad.TransitPrompt
	assert(p.KeyboardKeyCode==r.Enum.KeyCode.G and math.abs(p.HoldDuration-.6)<1e-5 and p.MaxActivationDistance==10 and not p.RequiresLineOfSight)
	assert(m.Platform.CanCollide and m.Arrival.Transparency==1)
	assert((m.Arrival.CFrame.Position-m.Pad.CFrame.Position).Magnitude<2)
	for _,v in m:GetDescendants() do if v:IsA("BasePart") then assert(v.Anchored and not v.CanTouch) end end
end
check(transit.Center)
for id=1,12 do local m=transit.Bases["Base"..id];check(m);assert(m:GetAttribute("BaseId")==id) end
local function geometry(root,exclude)
	local out={}
	for _,v in root:GetDescendants() do
		local skipped=false
		for _,addition in exclude or {} do if v:IsDescendantOf(addition) then skipped=true;break end end
		if v:IsA("BasePart") and not skipped then
		table.insert(out,table.concat({v:GetFullName(),tostring(v.CFrame),tostring(v.Size),tostring(v.Color),tostring(v.Material),tostring(v.Transparency),tostring(v.Anchored),tostring(v.CanCollide)},"|"))
	end end
	table.sort(out);return table.concat(out,"\n"),#out
end
local additions={transit}
-- New connected hunting scenery has its own validation; compare every original
-- hub/training part while excluding only these explicitly added containers.
for _,addition in {map:FindFirstChild("HuntingTransit"),place:GetService("Workspace"):FindFirstChild("HuntingRainforest"),place:GetService("Workspace"):FindFirstChild("Dinosaur01_TRex_Visual")} do
	if addition then table.insert(additions,addition) end
end
local baselineExclusions=if linked then {old:GetService("Workspace").HunDinoL0.BaseTransit} else {}
local before,count=geometry(old:GetService("Workspace"),baselineExclusions);local after=geometry(place:GetService("Workspace"),additions)
assert(before==after,"existing map geometry changed")
local function norm(s) return s:gsub("\r",""):gsub("%s+$","") end
assert(norm(place:GetService("ReplicatedStorage").Shared.BaseTransitMenu.Source)==norm(fs.readFile("src/dark-jungle/BaseTransitMenu.luau")))
assert(norm(place:GetService("ServerScriptService").HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.server.luau")))
assert(norm(place:GetService("StarterPlayer").StarterPlayerScripts.HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.client.luau")))
for _,path in {"tools/add-base-transit.luau","src/dark-jungle/BaseTransitMenu.luau","src/dark-jungle/Training.server.luau","src/dark-jungle/Training.client.luau"} do luau.compile(fs.readFile(path)) end
print("PASS saved 13 portals/prompts, 12 arrivals, streaming models, collision flags, source integration and",count,"original map parts preserved")
