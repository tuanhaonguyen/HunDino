local fs=require("@lune/fs")
local luau=require("@lune/luau")
local r=require("@lune/roblox")
local config=require("../studio-pet-integration/TrainingConfig")
local rules=require("../studio-pet-integration/TrainingRules")
local weapons=require("../studio-pet-integration/Weapons")
local before=r.deserializePlace(fs.readFile("backups/Hub_before_combat_pacing_20261017.rbxl"))
local old=luau.load(before:GetService("ReplicatedStorage").Shared.TrainingConfig.Source)()
assert(config.DodgeTime==.5 and config.DodgeTime>old.DodgeTime,"longer dodge duration must be half a second")
assert(config.DodgeCost==old.DodgeCost and config.StaminaCostScale==old.StaminaCostScale,"dodge stamina cost changed")
local function distance(c) return c.DodgeTime*(c.WalkSpeed+(c.DodgeSpeed-c.WalkSpeed)/3) end
local ratio=distance(config)/distance(old);assert(ratio>1.6 and ratio<1.9,"dodge should travel substantially farther")
assert(distance(config)>16,"sideways dodge must clear the dinosaur bite's half-width plus player margin")
local s={WeaponId="Hammer",Drawn=false,InTraining=false,BusyUntil=0,Stamina=100,ComboUntil=0,LastSpend=0}
assert(rules.dodge(config,weapons,s,0));assert(s.Stamina==94 and s.DodgingUntil==config.DodgeTime)
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
print(string.format("PASS longer dodge %.2f -> %.2f studs (%.2fx), half-second duration, unchanged stamina, busy/empty-stamina guards and compilation",distance(old),distance(config),ratio))
