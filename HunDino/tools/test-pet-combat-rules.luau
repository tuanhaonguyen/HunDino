-- Run from HunDino: tools/lune/lune.exe run tools/test-pet-combat-rules.luau
-- Pure timing and arithmetic checks. Ownership, movement, animation and network
-- validation require separate controller/Studio tests.
local Rules = require("../src/hunting/PetCombatRules")
local checks = 0
local function check(condition, message)
	checks += 1
	assert(condition, message)
end
local function unchanged(memory, before, message)
	check(memory.Health == before.Health and memory.StunnedUntil == before.StunnedUntil
		and memory.HealReadyAt == before.HealReadyAt and memory.NextAttackAt == before.NextAttackAt, message)
end
local function copy(memory)
	return table.clone(memory)
end
local function close(actual, expected)
	return math.abs(actual - expected) < 0.000001
end

local memory = Rules.new(1000)
check(memory.Health == 100 and memory.StunnedUntil == 0
	and memory.HealReadyAt == 0 and memory.NextAttackAt == 0, "Spawn has full HP and no artificial cooldown")
check(Rules.canAttack(memory, 1000), "New pet may attack immediately")
check(Rules.beginAttack(memory, 1000), "First attack accepted")
check(not Rules.beginAttack(memory, 1000), "Duplicate attack cannot restart attack timing")
check(Rules.Config.AttackInterval == 10, "Requested ten-second attack interval")
check(not Rules.canAttack(memory, 1009.999), "Attack unavailable immediately before ten seconds")
check(Rules.beginAttack(memory, 1010), "Attack accepted at the exact ten-second boundary")
check(memory.NextAttackAt == 1020, "Second attack begins a fresh interval")

local applied, enteredStun = Rules.damage(memory, 24, 1005)
check(applied == 24 and not enteredStun and memory.Health == 76, "Ordinary bite reduces pet health")
applied, enteredStun = Rules.damage(memory, 100000, 1006)
check(applied == 75 and enteredStun and memory.Health == 1, "Lethal overkill stops at one HP")
check(memory.StunnedUntil == 1036, "Stun lasts thirty real seconds")
check(not Rules.canAttack(memory, 1035.999), "Pet cannot attack before stun expiry even when attack cooldown is ready")
local stunned = copy(memory)
for _, stamp in {1006, 1010, 1035.999} do
	applied, enteredStun = Rules.damage(memory, 999, stamp)
	check(applied == 0 and not enteredStun, "Further hits do not damage a stunned pet")
	unchanged(memory, stunned, "Further hits do not extend stun or change cooldowns")
end
check(not Rules.tick(memory, 1035.999), "Recovery does not happen early")
check(Rules.tick(memory, 1036) and memory.Health == 100 and memory.StunnedUntil == 0, "Exact expiry recovers full health")
check(not Rules.tick(memory, 1037), "Recovery occurs only once")
check(memory.NextAttackAt == 1020, "Stun does not reset the independent attack clock")

local healing = Rules.new()
local allowed, reason = Rules.canHeal(healing, 2000, 20, 100)
check(allowed and reason == nil, "Living injured owner can request healing")
applied, reason = Rules.commitHeal(healing, 2000, 20, 100)
check(applied == 70 and reason == nil, "Healing uses seventy percent of maximum health")
check(healing.HealReadyAt == 2119, "Cooldown starts only when healing is applied")
local afterHeal = copy(healing)
applied, reason = Rules.commitHeal(healing, 2000, 20, 100)
check(applied == 0 and reason == "Cooldown", "Repeated commit cannot grant healing twice")
unchanged(healing, afterHeal, "Duplicate commit cannot extend the existing cooldown")
allowed, reason = Rules.canHeal(healing, 2118.999, 20, 100)
check(not allowed and reason == "Cooldown", "Healing unavailable immediately before cooldown expiry")
applied, reason = Rules.commitHeal(healing, 2119, 60, 100)
check(applied == 40 and reason == nil, "Healing caps at missing health at exact cooldown expiry")
check(healing.HealReadyAt == 2238, "A real second heal starts its own cooldown")

local scaled = Rules.new()
applied = Rules.commitHeal(scaled, 10, 20, 250)
check(applied == 175, "Healing scales with max health rather than fixed seventy HP")
local fraction = Rules.new()
applied = Rules.commitHeal(fraction, 10, 15.25, 30.5)
check(close(applied, 15.25), "Fractional health is capped without creating overheal")
local full = Rules.new()
applied, reason = Rules.commitHeal(full, 20, 100, 100)
check(applied == 0 and reason == "FullHealth" and full.HealReadyAt == 0, "Full health consumes no cooldown")

-- Stun and skill cooldown are independent, including a clock long enough to
-- represent an owner dying, travelling and receiving a replacement pet model.
local persistent = Rules.new()
check(Rules.commitHeal(persistent, 3000, 1, 100) == 70, "Initial persistent heal")
Rules.damage(persistent, 999, 3001)
allowed, reason = Rules.canHeal(persistent, 3002, 1, 100)
check(not allowed and reason == "Stunned", "Stun takes priority over the heal cooldown message")
check(Rules.tick(persistent, 3031), "Persistent memory recovers after model replacement time")
check(persistent.HealReadyAt == 3119, "Full recovery preserves the original heal cooldown")
check(not Rules.canHeal(persistent, 3118.999, 1, 100), "Recovery cannot bypass the cooldown")
check(Rules.canHeal(persistent, 3119, 1, 100), "Original cooldown eventually expires")

local exact = Rules.new()
Rules.damage(exact, 999, 0)
applied, enteredStun = Rules.damage(exact, 5, 30)
check(applied == 5 and not enteredStun and exact.Health == 95, "Damage at stun expiry applies after full recovery")
Rules.damage(exact, 94, 31)
check(exact.Health == 1 and exact.StunnedUntil == 61, "An exact hit down to one HP starts another stun")
check(Rules.beginAttack(exact, 61) and exact.Health == 100, "Attack at stun expiry recovers the pet before starting")

local invalidNumbers = {0 / 0, math.huge, -math.huge, -1, "10", true, {}}
for _, invalid in invalidNumbers do
	local pet = Rules.new()
	local before = copy(pet)
	applied, enteredStun = Rules.damage(pet, invalid, 10)
	check(applied == 0 and not enteredStun, "Invalid damage rejected: " .. tostring(invalid))
	unchanged(pet, before, "Invalid damage leaves state unchanged")
	check(not Rules.canAttack(pet, invalid) and not Rules.beginAttack(pet, invalid), "Invalid attack clock rejected")
	check(not Rules.tick(pet, invalid), "Invalid tick clock cannot recover health")
	check(Rules.damage(pet, 24, invalid) == 0, "Invalid damage clock is rejected")
	applied, reason = Rules.commitHeal(pet, invalid, 50, 100)
	check(applied == 0 and reason == "InvalidTime", "Invalid heal clock rejected")
	unchanged(pet, before, "Invalid timestamp leaves all clocks unchanged")
end
for _, invalid in {0, -10, 0 / 0, math.huge, -math.huge, "50", false, {}} do
	local pet = Rules.new()
	local before = copy(pet)
	applied, reason = Rules.commitHeal(pet, 10, invalid, 100)
	check(applied == 0 and reason == "InvalidHealth", "Invalid/dead owner HP rejected")
	applied, reason = Rules.commitHeal(pet, 10, 20, invalid)
	check(applied == 0 and reason == "InvalidHealth", "Invalid owner maximum HP rejected")
	unchanged(pet, before, "Invalid owner health consumes no cooldown")
end
for _, pair in {{101, 100}, {1, 0.5}} do
	check(Rules.commitHeal(Rules.new(), 10, pair[1], pair[2]) == 0, "Owner HP above maximum is rejected")
end
for _, invalid in {nil, false, "memory", 12, {}, {Health = 0, StunnedUntil = 0, HealReadyAt = 0, NextAttackAt = 0}} do
	check(not Rules.canAttack(invalid, 10), "Malformed memory cannot attack")
	applied, reason = Rules.commitHeal(invalid, 10, 50, 100)
	check(applied == 0 and reason == "InvalidMemory", "Malformed memory cannot heal")
	check(not Rules.tick(invalid, 10), "Malformed memory cannot recover")
end
for _, field in {"Health", "StunnedUntil", "HealReadyAt", "NextAttackAt"} do
	local broken = Rules.new()
	broken[field] = 0 / 0
	check(Rules.damage(broken, 24, 10) == 0, "Corrupt memory cannot receive damage: " .. field)
	check(not Rules.beginAttack(broken, 10), "Corrupt memory cannot begin attack: " .. field)
	applied, reason = Rules.commitHeal(broken, 10, 50, 100)
	check(applied == 0 and reason == "InvalidMemory", "Corrupt memory cannot heal: " .. field)
end
check(not Rules.tick(nil, 10) and not Rules.canAttack(nil, 10), "Missing memory is rejected")
applied, reason = Rules.commitHeal(nil, 10, 50, 100)
check(applied == 0 and reason == "InvalidMemory", "Missing memory cannot heal")
check(Rules.damage(Rules.new(), 0, 10) == 0, "Zero damage does not create a stun")
check(Rules.damage(Rules.new(), nil, 10) == 0, "Missing damage is rejected")
check(Rules.commitHeal(Rules.new(), nil, 50, 100) == 0, "Missing time is rejected")
check(Rules.commitHeal(Rules.new(), 10, nil, 100) == 0, "Missing owner health is rejected")
check(not Rules.canAttack(Rules.new(), nil), "Missing attack time is rejected")

local regen=Rules.new()
regen.HealReadyAt=9999
Rules.damage(regen,50,100)
Rules.tick(regen,104.999,true)
check(regen.Health==50,"No self heal before five safe seconds")
Rules.tick(regen,105,true)
check(regen.Health==50,"No instant heal burst at delay boundary")
Rules.tick(regen,105.5,true)
check(regen.Health==55,"Ten HP per second safe regeneration")
Rules.tick(regen,106,false)
check(regen.Health==55,"Danger suppresses regeneration")
Rules.damage(regen,10,106)
Rules.tick(regen,110.99,true)
check(regen.Health==45,"Being hit restarts self-heal delay")
for i=1,24 do Rules.tick(regen,111+i*.5,true) end
check(regen.Health==100 and regen.HealReadyAt==9999,"Recovery caps at full and never refreshes owner heal")
Rules.damage(regen,999,124)
check(Rules.rest(regen,125) and regen.Health==100 and regen.StunnedUntil==0,"Lobby/new hunt restores pet")
check(regen.HealReadyAt==9999,"Travel health reset preserves owner healing cooldown")
print(string.format("PetCombatRules: %d checks passed", checks))
