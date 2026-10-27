-- P1-D mission/capture rules. Server runtime owns the clock, player, monster,
-- movement, distance, damage and ground checks. This module never yields and
-- does not finish physical interactions until the runtime explicitly commits.
local Rules = {}

Rules.Config = table.freeze({
	Duration = 2400,
	HarvestSeconds = 120,
	MaxDeaths = 4,
	RespawnDelay = 5,
	TrapPlaceSeconds = 1,
	TrapLifetime = 60,
	TrapHoldSeconds = 13,
	CaptureSeconds = 3,
	WeakRatio = 0.1,
	TrapCount = 3,
	PotionCount = 3,
})
local Config = Rules.Config
local States = {Preparing = true, Hunting = true, Harvest = true, Returning = true, Failed = true, Closed = true}

local function finite(value)
	return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function validTime(value)
	return finite(value) and value >= 0
end

local function integer(value, maximum)
	return finite(value) and value >= 0 and value % 1 == 0 and (maximum == nil or value <= maximum)
end

local function validId(value, maximum)
	return type(value) == "string" and #value > 0 and #value <= (maximum or 128) and not string.find(value, "%c")
end

local function successful(run)
	return run.Result == "Defeated" or run.Result == "Captured"
end

local function validRun(run)
	if type(run) ~= "table" or not validId(run.Id) or not validId(run.MonsterId)
		or not States[run.State] or type(run.Closed) ~= "boolean" or type(run.Returned) ~= "boolean"
		or not validTime(run.CreatedAt) or not validTime(run.StartedAt) or not validTime(run.Deadline)
		or not integer(run.Deaths, Config.MaxDeaths) or not integer(run.Traps, Config.TrapCount)
		or not integer(run.Potions, Config.PotionCount) or not integer(run.TrapSerial)
		or not integer(run.ActionSerial) then return false end
	if run.Result ~= nil and run.Result ~= "Failed" and not successful(run) then return false end
	if run.Closed ~= (run.State == "Closed") then return false end
	if (run.State == "Preparing" or run.State == "Hunting") and run.Result ~= nil then return false end
	if run.State == "Hunting" and (run.StartedAt < run.CreatedAt or run.Deadline < run.StartedAt) then return false end
	if (run.State == "Harvest" or run.State == "Returning")
		and (not successful(run) or not validTime(run.FinishedAt) or not validTime(run.HarvestUntil)) then return false end
	if run.State == "Failed" and run.Result ~= "Failed" then return false end
	local action = run.Action
	if action ~= nil and (type(action) ~= "table" or (action.Kind ~= "Place" and action.Kind ~= "Capture")
		or not validTime(action.StartedAt) or not validTime(action.FinishAt)
		or action.FinishAt < action.StartedAt or not integer(action.Serial)
		or action.Serial ~= run.ActionSerial) then return false end
	local trap = run.ActiveTrap
	if trap ~= nil and (type(trap) ~= "table" or not validId(trap.Id, 160)
		or (trap.State ~= "Waiting" and trap.State ~= "Holding")
		or not validTime(trap.PlacedAt) or not validTime(trap.ExpiresAt)
		or trap.ExpiresAt < trap.PlacedAt
		or (trap.State == "Holding" and (not validTime(trap.TriggeredAt)
			or not validTime(trap.HeldUntil) or trap.TriggeredAt < trap.PlacedAt
			or trap.HeldUntil < trap.TriggeredAt))) then return false end
	return true
end

local function checkTime(run, now)
	if not validRun(run) then return false, "InvalidRun" end
	if not validTime(now) or now < run.CreatedAt
		or (run.State ~= "Preparing" and run.StartedAt > now) then return false, "InvalidTime" end
	if run.Closed then return false, "Closed" end
	return true, nil
end

local function checkHunting(run, now)
	local allowed, reason = checkTime(run, now)
	if not allowed then return false, reason end
	if run.State ~= "Hunting" then return false, "NotHunting" end
	-- A valid completion delivered exactly at the deadline wins. No backdating.
	if now > run.Deadline then return false, "Expired" end
	return true, nil
end

local function clearAction(run)
	if run.Action == nil then return false end
	run.Action = nil
	run.ActionSerial += 1
	return true
end

local function beginAction(run, kind, now, duration)
	run.ActionSerial += 1
	run.Action = {Kind = kind, StartedAt = now, FinishAt = now + duration, Serial = run.ActionSerial}
	return true, nil, run.ActionSerial
end

local function checkAction(run, kind, now, expectedSerial)
	local action = run.Action
	if not action then return false, "NoAction" end
	if expectedSerial ~= nil and (not integer(expectedSerial) or action.Serial ~= expectedSerial) then
		return false, "StaleAction"
	end
	if action.Kind ~= kind then return false, "WrongAction" end
	if now < action.FinishAt then return false, "NotReady" end
	return true, nil
end

local function checkHolding(run, now)
	local trap = run.ActiveTrap
	if not trap then return false, "NoTrap" end
	if trap.State ~= "Holding" then return false, "NotTrapped" end
	if now < trap.TriggeredAt then return false, "InvalidTime" end
	if now > trap.HeldUntil then return false, "TrapEscaped" end
	return true, nil
end

local function checkWeak(hp, maxhp)
	if not finite(hp) or not finite(maxhp) or maxhp <= 0 or hp <= 0 or hp > maxhp then
		return false, "InvalidHealth"
	end
	if hp / maxhp > Config.WeakRatio then return false, "NotWeak" end
	return true, nil
end

function Rules.new(runId, monsterId, now)
	if not validId(runId) or not validId(monsterId) or not validTime(now) then return nil, "InvalidInput" end
	return {
		Id = runId, MonsterId = monsterId, State = "Preparing", Result = nil,
		CreatedAt = now, StartedAt = 0, Deadline = 0, Deaths = 0,
		Traps = Config.TrapCount, Potions = Config.PotionCount, TrapSerial = 0,
		ActionSerial = 0, ActiveTrap = nil, Action = nil, Closed = false, Returned = false,
	}, nil
end

function Rules.start(run, now)
	local allowed = checkTime(run, now)
	if not allowed or run.State ~= "Preparing" then return false end
	run.State = "Hunting"
	run.StartedAt = now
	run.Deadline = now + Config.Duration
	return true
end

function Rules.cancelAction(run)
	if not validRun(run) or run.Closed then return false end
	return clearAction(run)
end

function Rules.finish(run, result, now)
	if result ~= "Defeated" and result ~= "Captured" then return false end
	if not checkHunting(run, now) then return false end
	run.Result = result
	run.State = "Harvest"
	run.FinishedAt = now
	run.HarvestUntil = now + Config.HarvestSeconds
	clearAction(run)
	run.ActiveTrap = nil
	return true
end

function Rules.fail(run, reason, now)
	if not checkTime(run, now) or not validId(reason) or successful(run)
		or run.Result ~= nil or (run.State ~= "Preparing" and run.State ~= "Hunting") then return false end
	run.Result = "Failed"
	run.State = "Failed"
	run.FailureReason = reason
	run.FinishedAt = now
	clearAction(run)
	run.ActiveTrap = nil
	return true
end

function Rules.death(run, now)
	if not checkTime(run, now) then return nil end
	if run.State == "Harvest" then
		clearAction(run)
		return "Camp"
	end
	if run.State ~= "Hunting" then return nil end
	if now > run.Deadline then
		Rules.fail(run, "TimeExpired", now)
		return "Failed"
	end
	run.Deaths += 1
	clearAction(run)
	if run.Deaths >= Config.MaxDeaths then
		Rules.fail(run, "DeathLimit", now)
		return "Failed"
	end
	return "Camp"
end

function Rules.tick(run, now)
	if not checkTime(run, now) then return nil end
	if run.State == "Harvest" then
		if now >= run.HarvestUntil then
			run.State = "Returning"
			return "Returning"
		end
		return nil
	end
	if run.State ~= "Hunting" then return nil end
	if now > run.Deadline then
		Rules.fail(run, "TimeExpired", now)
		return "Failed"
	end
	local trap = run.ActiveTrap
	if trap then
		if trap.State == "Waiting" and now > trap.ExpiresAt then
			run.ActiveTrap = nil
			if run.Action and run.Action.Kind == "Capture" then clearAction(run) end
			return "TrapExpired"
		elseif trap.State == "Holding" and now > trap.HeldUntil then
			run.ActiveTrap = nil
			if run.Action and run.Action.Kind == "Capture" then clearAction(run) end
			return "TrapEscaped"
		end
	end
	-- Runtime revalidates geometry/ownership/HP before the explicit commit calls.
	return nil
end

function Rules.beginPlace(run, now)
	local allowed, reason = checkHunting(run, now)
	if not allowed then return false, reason end
	if run.Action then return false, "Busy" end
	if run.ActiveTrap then return false, "TrapActive" end
	if run.Traps <= 0 then return false, "NoTraps" end
	return beginAction(run, "Place", now, Config.TrapPlaceSeconds)
end

function Rules.commitPlace(run, now, expectedSerial)
	local allowed, reason = checkHunting(run, now)
	if not allowed then return nil, reason end
	allowed, reason = checkAction(run, "Place", now, expectedSerial)
	if not allowed then return nil, reason end
	if run.ActiveTrap then return nil, "TrapActive" end
	if run.Traps <= 0 then return nil, "NoTraps" end
	run.TrapSerial += 1
	local trap = {
		Id = run.Id .. ":trap:" .. tostring(run.TrapSerial), State = "Waiting",
		PlacedAt = now, ExpiresAt = now + Config.TrapLifetime,
	}
	run.Traps -= 1
	run.ActiveTrap = trap
	clearAction(run)
	return trap, nil
end

function Rules.triggerTrap(run, now)
	local allowed, reason = checkHunting(run, now)
	if not allowed then return false, reason end
	local trap = run.ActiveTrap
	if not trap then return false, "NoTrap" end
	if trap.State ~= "Waiting" then return false, "TrapNotWaiting" end
	if now > trap.ExpiresAt then return false, "TrapExpired" end
	if now < trap.PlacedAt then return false, "InvalidTime" end
	trap.State = "Holding"
	trap.TriggeredAt = now
	trap.HeldUntil = now + Config.TrapHoldSeconds
	return true, nil
end

function Rules.beginCapture(run, now, hp, maxhp)
	local allowed, reason = checkHunting(run, now)
	if not allowed then return false, reason end
	if run.Action then return false, "Busy" end
	allowed, reason = checkHolding(run, now)
	if not allowed then return false, reason end
	allowed, reason = checkWeak(hp, maxhp)
	if not allowed then return false, reason end
	if run.Potions <= 0 then return false, "NoPotions" end
	return beginAction(run, "Capture", now, Config.CaptureSeconds)
end

function Rules.commitCapture(run, now, hp, maxhp, expectedSerial)
	local allowed, reason = checkHunting(run, now)
	if not allowed then return false, reason end
	allowed, reason = checkAction(run, "Capture", now, expectedSerial)
	if not allowed then return false, reason end
	allowed, reason = checkHolding(run, now)
	if not allowed then return false, reason end
	allowed, reason = checkWeak(hp, maxhp)
	if not allowed then return false, reason end
	if run.Potions <= 0 then return false, "NoPotions" end
	-- No yields occur between final validation, result lock and item consumption.
	if not Rules.finish(run, "Captured", now) then return false, "NotHunting" end
	run.Potions -= 1
	return true, nil
end

function Rules.close(run)
	if not validRun(run) or run.Closed then return false end
	clearAction(run)
	run.ActiveTrap = nil
	run.State = "Closed"
	run.Closed = true
	run.Returned = true
	return true
end

-- Copies nested records so a consumer cannot accidentally change live rules.
function Rules.snapshot(run, now)
	if not validRun(run) or not validTime(now) or now < run.CreatedAt then return nil end
	return {
		Id = run.Id, MonsterId = run.MonsterId, State = run.State, Result = run.Result,
		CreatedAt = run.CreatedAt, StartedAt = run.StartedAt, Deadline = run.Deadline,
		FinishedAt = run.FinishedAt, HarvestUntil = run.HarvestUntil,
		FailureReason = run.FailureReason, Deaths = run.Deaths, Traps = run.Traps,
		Potions = run.Potions, Closed = run.Closed, Returned = run.Returned,
		Remaining = run.State == "Hunting" and math.max(0, run.Deadline - now) or 0,
		HarvestRemaining = run.State == "Harvest" and math.max(0, run.HarvestUntil - now) or 0,
		Action = run.Action and table.clone(run.Action) or nil,
		ActiveTrap = run.ActiveTrap and table.clone(run.ActiveTrap) or nil,
	}
end

return Rules
