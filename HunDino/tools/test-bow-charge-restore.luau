local fs=require("@lune/fs")
local luau=require("@lune/luau")
local config=require("../src/shared/TrainingConfig")
local weapons=require("../studio-pet-integration/Weapons")
local rules=require("../studio-pet-integration/TrainingRules")
for _,name in {"Training.server.luau","Training.client.luau","TrainingRules.luau","Weapons.luau"} do luau.compile(fs.readFile("studio-pet-integration/"..name)) end
local function fresh() return {WeaponId="Bow",Drawn=true,InTraining=true,BusyUntil=0,Stamina=100,ComboUntil=0,LastSpend=0} end
for _,action in {"Light"} do
	local last=0
	for _,duration in {0,.3,.6,1.2,5} do
		local s=fresh();local charge=assert(rules.beginCharge(config,weapons,s,action,0))
		local paid=s.Stamina
		assert(not rules.attack(config,weapons,s,"Skill",.1))
		assert(not rules.beginCharge(config,weapons,s,action,.1))
		assert(not rules.dodge(config,weapons,s,.1))
		local kind,spec=rules.releaseCharge(config,s,duration)
		assert(kind==action and spec.Damage>=last)
		assert(s.Stamina==paid and not s.Charge)
		assert(not rules.releaseCharge(config,s,duration),"duplicate release")
		assert(spec.Damage<=math.floor(charge.Spec.Damage*charge.Multiplier+.5),"uncapped damage")
		last=spec.Damage
	end
end
local s=fresh();assert(rules.beginCharge(config,weapons,s,"Light",0))
local paid=s.Stamina;assert(rules.cancelCharge(s,.3));assert(s.Stamina==paid)
assert(not rules.releaseCharge(config,s,5));assert(not rules.cancelCharge(s,5))
s=fresh();s.Stamina=0;assert(not rules.beginCharge(config,weapons,s,"Light",0))
s=fresh();s.Drawn=false;assert(not rules.beginCharge(config,weapons,s,"Light",0))
s=fresh();s.WeaponId="Hammer";assert(not rules.beginCharge(config,weapons,s,"Light",0))
s=fresh();assert(not rules.beginCharge(config,weapons,s,"Heavy",0),"Q must not charge")
local kind,spec=rules.attack(config,weapons,s,"Heavy",0)
assert(kind=="Heavy" and spec.Damage==weapons.Bow.Attacks.Heavy.Damage,"Q must remain a heavy strike")
for _,combo in weapons.Bow.Combos do
	local state=fresh();local now,last=0,nil
	for letter in combo.Input:gmatch(".") do
		if letter=="D" then assert(rules.dodge(config,weapons,state,now))
		elseif letter=="L" then
			assert(rules.beginCharge(config,weapons,state,"Light",now))
			last=rules.releaseCharge(config,state,now)
		else last=rules.attack(config,weapons,state,({H="Heavy",S="Skill"})[letter],now);assert(last) end
		now=state.BusyUntil+.02
	end
	assert(last==combo.Attack,"bow combo lost: "..combo.Input)
end
print("PASS restored bow charge scaling/cap, quick tap, once-only stamina/release, interruption and action guards")
if require("@lune/process").args[1]=="--saved" then
	local r=require("@lune/roblox")
	local place=r.deserializePlace(fs.readFile("HunDino_DarkJungle_v2_3.rbxl"))
	local shared=place:GetService("ReplicatedStorage").Shared
	local function norm(s) return s:gsub("\r",""):gsub("%s+$","") end
	for _,name in {"Weapons","TrainingRules"} do assert(norm(shared[name].Source)==norm(fs.readFile("studio-pet-integration/"..name..".luau"))) end
	assert(norm(place:GetService("ServerScriptService").HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.server.luau")))
	assert(norm(place:GetService("StarterPlayer").StarterPlayerScripts.HunDinoTraining.Source)==norm(fs.readFile("studio-pet-integration/Training.client.luau")))
	print("PASS saved Studio bow charge rules, configuration, server and client")
end
