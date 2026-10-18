-- Run from HunDino: tools/lune/lune.exe run tools/test-hunting-combat-rules.luau
-- Tests the canonical rules used by the connected lobby/hunt, without Studio.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local config = require("../src/shared/TrainingConfig")
local weapons = require("../studio-pet-integration/Weapons")
local rules = require("../studio-pet-integration/TrainingRules")
local passed = 0
local function test(name, callback)
	callback(); passed += 1; print("PASS", name)
end
local function fresh(id, hunting)
	return {WeaponId = id or "Hammer", Drawn = true, InTraining = not hunting,
		InHunting = hunting == true, BusyUntil = 0, Stamina = config.MaxStamina,
		ComboChain = "", ComboStep = 0, ComboUntil = 0, LastSpend = 0,
		Sprinting = false, Blocking = false}
end

test("Connected combat source compiles", function()
	for _, name in {"Training.server.luau", "Training.client.luau", "TrainingRules.luau", "Weapons.luau"} do
		luau.compile(fs.readFile("studio-pet-integration/" .. name))
	end
	for _, name in {"DinosaurCombat.luau", "DinosaurCombatConfig.luau", "DinosaurRouteController.luau", "HuntingSession.luau"} do
		local path = "src/hunting/" .. name
		assert(fs.isFile(path), "Missing " .. path)
		luau.compile(fs.readFile(path))
	end
	luau.compile(fs.readFile("tools/test-dinosaur-combat.luau"))
end)

test("Hunting and training equipment retain sheathe/action guards", function()
	for _, hunting in {false, true} do
		local state = fresh("Hammer", hunting)
		state.Drawn = false
		assert(rules.canEquip(state, weapons, "Bow", 1), "Cannot equip in active area")
		for _, field in {"Drawn", "Blocking", "Sprinting"} do
			state[field] = true
			assert(not rules.canEquip(state, weapons, "Bow", 1), "Equip during " .. field)
			state[field] = false
		end
		state.BusyUntil = 2
		assert(not rules.canEquip(state, weapons, "Bow", 1), "Equip during recovery")
		state.BusyUntil = 0
		assert(not rules.canEquip(state, weapons, "Order", 1))
		assert(not rules.canEquip(state, weapons, "Unknown", 1))
		assert(not rules.canEquip(state, weapons, {}, 1))
	end
	local state = fresh(); state.Drawn = false; state.InTraining = false; state.InHunting = false
	assert(not rules.canEquip(state, weapons, "Bow", 1), "Equip outside combat areas")
end)

test("All hunting weapons use trusted specs and reject rapid repeat inputs", function()
	for _, id in weapons.Order do
		for _, action in {"Light", "Heavy", "Skill"} do
			local state = fresh(id, true)
			local kind, spec = rules.attack(config, weapons, state, action, 10)
			assert(kind == action and spec == weapons[id].Attacks[action], "Untrusted spec " .. id)
			assert(state.BusyUntil == 10 + spec.Duration)
			assert(math.abs(state.Stamina - (config.MaxStamina - spec.Cost * config.StaminaCostScale)) < 1e-6)
			local stamina, chain = state.Stamina, state.ComboChain
			assert(not rules.attack(config, weapons, state, action, 10.01))
			assert(state.Stamina == stamina and state.ComboChain == chain, "Denied input changes state")
		end
	end
end)

test("Invalid attack, exhausted, guarded, sprinting, sheathed and charging deny", function()
	for _, action in {"Finisher", "Dance", "Unknown", "Damage"} do
		local state = fresh("Hammer", true)
		assert(not rules.attack(config, weapons, state, action, 1))
		assert(state.Stamina == config.MaxStamina)
	end
	for _, change in {
		function(s) s.Stamina = 0 end,
		function(s) s.Blocking = true end,
		function(s) s.Sprinting = true end,
		function(s) s.Drawn = false end,
		function(s) s.Charge = {} end,
	} do
		local state = fresh("Hammer", true); change(state)
		local before = state.Stamina
		assert(not rules.attack(config, weapons, state, "Light", 1))
		assert(before == state.Stamina)
	end
end)

test("Hunting bow release is once only, capped, and leaves immutable weapon specs", function()
	local baseDamage = weapons.Bow.Attacks.Light.Damage
	local last = 0
	for _, duration in {0, .3, .6, 1.2, 10} do
		local state = fresh("Bow", true)
		local charge = assert(rules.beginCharge(config, weapons, state, "Light", 10))
		local stamina = state.Stamina
		assert(not rules.beginCharge(config, weapons, state, "Light", 10.01))
		assert(not rules.attack(config, weapons, state, "Heavy", 10.01))
		local kind, spec, alpha = rules.releaseCharge(config, state, 10 + duration)
		assert(kind == "Light" and spec ~= charge.Spec and spec.Damage >= last)
		assert(alpha >= 0 and alpha <= 1)
		assert(spec.Damage <= math.floor(baseDamage * weapons.Bow.Charge.Multiplier + .5))
		assert(state.Stamina == stamina and not state.Charge)
		assert(not rules.releaseCharge(config, state, 11 + duration), "Duplicate release")
		assert(weapons.Bow.Attacks.Light.Damage == baseDamage, "Charge changed shared damage")
		last = spec.Damage
	end
	local state = fresh("Bow", true)
	assert(rules.beginCharge(config, weapons, state, "Light", 1))
	assert(rules.cancelCharge(state, 1.2))
	assert(not rules.releaseCharge(config, state, 5), "Cancelled shot released")
	assert(not rules.cancelCharge(state, 5))
end)

test("Every existing weapon combo still resolves in hunting", function()
	local actions = {L = "Light", H = "Heavy", S = "Skill"}
	for _, id in weapons.Order do
		for _, combo in weapons[id].Combos do
			local state = fresh(id, true)
			local now, last = 10, nil
			for letter in combo.Input:gmatch(".") do
				if letter == "D" then assert(rules.dodge(config, weapons, state, now))
				elseif id == "Bow" and letter == "L" then
					assert(rules.beginCharge(config, weapons, state, "Light", now))
					last = rules.releaseCharge(config, state, now)
				else last = rules.attack(config, weapons, state, actions[letter], now); assert(last) end
				now = state.BusyUntil + .02
			end
			assert(last == combo.Attack, id .. " combo " .. combo.Input)
		end
	end
end)

print("RESULT", passed, "hunting combat rule groups passed; Studio geometry/runtime tests are separate")
