-- P1-C prototype numbers. Runtime ownership, distance and line-of-sight checks
-- belong to the server controller; this module has no Roblox dependencies.
local Rules = {}

Rules.Config = table.freeze({
	MaxHealth = 100,
	AttackDamage = 12,
	AttackInterval = 10,
	AttackRange = 6,
	StunSeconds = 30,
	HealFraction = 0.7,
	HealCooldown = 119,
	HealCastSeconds = 0.8,
	HealRange = 3.8,
	MoveSpeed = 18,
	SelfHealDelay = 5,
	SelfHealPerSecond = 10,
	RetreatRatio = .25,
	RecoverySafeRange = 40,
})
local Config = Rules.Config

local function finite(value)
	return type(value) == "number" and value == value
		and value > -math.huge and value < math.huge
end

local function validTime(value)
	return finite(value) and value >= 0
end

local function validMemory(memory)
	return type(memory) == "table" and finite(memory.Health)
		and memory.Health >= 1 and memory.Health <= Config.MaxHealth
		and validTime(memory.StunnedUntil) and validTime(memory.HealReadyAt)
		and validTime(memory.NextAttackAt)
end

local function validOwnerHealth(currentHealth, maxHealth)
	return finite(currentHealth) and finite(maxHealth) and maxHealth > 0
		and currentHealth > 0 and currentHealth <= maxHealth
end

-- Initial timers are ready immediately. An optional clock argument lets callers
-- construct memory alongside their other timed state without starting cooldowns.
function Rules.new(_now)
	return {
		Health = Config.MaxHealth,
		StunnedUntil = 0,
		HealReadyAt = 0,
		NextAttackAt = 0,
		LastDamageAt = 0,
	}
end

function Rules.tick(memory, now, regenerate)
	if not validMemory(memory) or not validTime(now) then return false end
	local previous = memory.RegenUpdatedAt or now
	memory.RegenUpdatedAt = now
	if memory.StunnedUntil > 0 and now >= memory.StunnedUntil then
		memory.Health = Config.MaxHealth
		memory.StunnedUntil = 0
		return true
	end
	if regenerate and memory.StunnedUntil <= now and memory.Health < Config.MaxHealth then
		local since = math.max(previous, (memory.LastDamageAt or now) + Config.SelfHealDelay)
		local dt = math.clamp(now - since, 0, .5)
		if dt > 0 then
			memory.Health = math.min(Config.MaxHealth, memory.Health + Config.SelfHealPerSecond * dt)
			return true
		end
	end
	return false
end

function Rules.rest(memory, now)
	if not validMemory(memory) or not validTime(now) then return false end
	memory.Health, memory.StunnedUntil, memory.NextAttackAt = Config.MaxHealth, 0, 0
	memory.LastDamageAt, memory.RegenUpdatedAt = now, now
	-- Resting must never refresh the owner's separate healing skill.
	return true
end

function Rules.damage(memory, amount, now)
	if not validMemory(memory) or not validTime(now)
		or not finite(amount) or amount <= 0 then return 0, false end
	Rules.tick(memory, now)
	if memory.StunnedUntil > now then return 0, false end
	local previous = memory.Health
	memory.Health = math.max(1, previous - amount)
	memory.LastDamageAt, memory.RegenUpdatedAt = now, now
	local enteredStun = memory.Health <= 1
	if enteredStun then memory.StunnedUntil = now + Config.StunSeconds end
	return previous - memory.Health, enteredStun
end

function Rules.canHeal(memory, now, currentHealth, maxHealth)
	if not validMemory(memory) then return false, "InvalidMemory" end
	if not validTime(now) then return false, "InvalidTime" end
	if not validOwnerHealth(currentHealth, maxHealth) then return false, "InvalidHealth" end
	if memory.StunnedUntil > now then return false, "Stunned" end
	if now < memory.HealReadyAt then return false, "Cooldown" end
	if currentHealth >= maxHealth then return false, "FullHealth" end
	return true, nil
end

-- Returns the amount for the controller to apply to the owner's Humanoid.
-- A cancelled cast never calls this method, so it consumes no cooldown.
function Rules.commitHeal(memory, now, currentHealth, maxHealth)
	local allowed, reason = Rules.canHeal(memory, now, currentHealth, maxHealth)
	if not allowed then return 0, reason end
	Rules.tick(memory, now)
	local applied = math.min(maxHealth - currentHealth, maxHealth * Config.HealFraction)
	if applied <= 0 then return 0, "FullHealth" end
	memory.HealReadyAt = now + Config.HealCooldown
	return applied, nil
end

function Rules.canAttack(memory, now)
	return validMemory(memory) and validTime(now)
		and memory.StunnedUntil <= now and now >= memory.NextAttackAt
end

function Rules.beginAttack(memory, now)
	if not Rules.canAttack(memory, now) then return false end
	Rules.tick(memory, now)
	memory.NextAttackAt = now + Config.AttackInterval
	return true
end

return Rules
