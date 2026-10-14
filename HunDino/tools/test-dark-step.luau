local fs=require("@lune/fs")
local luau=require("@lune/luau")
local r=require("@lune/roblox")
local config=require("../studio-pet-integration/TrainingConfig")
local rules=require("../studio-pet-integration/TrainingRules")
local weapons=require("../studio-pet-integration/Weapons")
local before=r.deserializePlace(fs.readFile("backups/HunDino_v2_3_before_dark_step_20261015.rbxl"))
local old=luau.load(before:GetService("ReplicatedStorage").Shared.TrainingConfig.Source)()
assert(config.DodgeTime==old.DodgeTime and config.DodgeCost==old.DodgeCost and config.StaminaCostScale==old.StaminaCostScale)
local function distance(c) return c.DodgeTime*(c.WalkSpeed+(c.DodgeSpeed-c.WalkSpeed)/3) end
local ratio=distance(config)/distance(old);assert(ratio>1.08 and ratio<1.2,"range change must stay modest")
local s={WeaponId="Hammer",Drawn=false,InTraining=false,BusyUntil=0,Stamina=100,ComboUntil=0,LastSpend=0}
assert(rules.dodge(config,weapons,s,0));assert(s.Stamina==94 and s.DodgingUntil==.4)
assert(not rules.dodge(config,weapons,s,.1) and s.Stamina==94,"duplicate dodge")
s.BusyUntil=0;s.Stamina=0;assert(not rules.dodge(config,weapons,s,1),"no stamina")
for _,path in {"src/dark-jungle/DarkStep.client.luau","studio-pet-integration/Training.server.luau","src/dark-jungle/Training.server.luau","src/shared/TrainingConfig.luau"} do luau.compile(fs.readFile(path)) end
if require("@lune/process").args[1]=="--saved" then
	local place=r.deserializePlace(fs.readFile("HunDino_DarkJungle_v2_3.rbxl"))
	local function norm(s) return s:gsub("\r",""):gsub("%s+$","") end
	assert(norm(place:GetService("ReplicatedStorage").Shared.TrainingConfig.Source)==norm(fs.readFile("studio-pet-integration/TrainingConfig.luau")))
	assert(norm(place:GetService("StarterPlayer").StarterPlayerScripts.HunDinoDarkStep.Source)==norm(fs.readFile("src/dark-jungle/DarkStep.client.luau")))
	assert(norm(place:GetService("ServerScriptService").HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.server.luau")))
	print("PASS saved dark-step client, server signals and live configuration")
end
print("PASS modest dash range increase, unchanged duration/stamina, busy/empty-stamina guards and compilation")
