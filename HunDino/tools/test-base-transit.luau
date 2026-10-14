local fs=require("@lune/fs")
local r=require("@lune/roblox")
local luau=require("@lune/luau")
local place=r.deserializePlace(fs.readFile("HunDino_DarkJungle_v2_3.rbxl"))
local old=r.deserializePlace(fs.readFile("backups/HunDino_v2_3_before_base_transit_20261015.rbxl"))
local map=place:GetService("Workspace").HunDinoL0
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
	for _,v in root:GetDescendants() do if v:IsA("BasePart") and not (exclude and v:IsDescendantOf(exclude)) then
		table.insert(out,table.concat({v:GetFullName(),tostring(v.CFrame),tostring(v.Size),tostring(v.Color),tostring(v.Material),tostring(v.Transparency),tostring(v.Anchored),tostring(v.CanCollide)},"|"))
	end end
	table.sort(out);return table.concat(out,"\n"),#out
end
local before,count=geometry(old:GetService("Workspace"));local after=geometry(place:GetService("Workspace"),transit)
assert(before==after,"existing map geometry changed")
local function norm(s) return s:gsub("\r",""):gsub("%s+$","") end
assert(norm(place:GetService("ReplicatedStorage").Shared.BaseTransitMenu.Source)==norm(fs.readFile("src/dark-jungle/BaseTransitMenu.luau")))
assert(norm(place:GetService("ServerScriptService").HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.server.luau")))
assert(norm(place:GetService("StarterPlayer").StarterPlayerScripts.HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.client.luau")))
for _,path in {"tools/add-base-transit.luau","src/dark-jungle/BaseTransitMenu.luau","src/dark-jungle/Training.server.luau","src/dark-jungle/Training.client.luau"} do luau.compile(fs.readFile(path)) end
print("PASS saved 13 portals/prompts, 12 arrivals, streaming models, collision flags, source integration and",count,"original map parts preserved")
