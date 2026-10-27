-- Run from HunDino: tools/lune/lune.exe run tools/test-hunt-quest-rules.luau
-- Time here is synthetic; live gameplay keeps the full design durations.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local Rules = require("../src/hunting/HuntQuestRules")
local checks = 0
local groups = 0

local function check(condition, message)
	checks += 1
	assert(condition, message)
end

local function test(name, callback)
	callback()
	groups += 1
	print("PASS", name)
end

local function clone(value)
	if type(value) ~= "table" then return value end
	local result = {}
	for key, item in value do result[key] = clone(item) end
	return result
end

local function equal(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for key, value in a do if not equal(value, b[key]) then return false end end
	for key, value in b do if not equal(value, a[key]) then return false end end
	return true
end

local function fresh(now)
	local run = assert(Rules.new("quest:123", "monster:456", now or 10))
	check(Rules.start(run, now or 10), "Fresh run starts")
	return run
end

local function waiting(now)
	local run = fresh(now)
	check(Rules.beginPlace(run, now or 10), "Start trap placement")
	local trap = assert(Rules.commitPlace(run, (now or 10) + 1))
	return run, trap
end

local function holding(now)
	local run, trap = waiting(now)
	check(Rules.triggerTrap(run, (now or 10) + 2), "Trigger waiting trap")
	return run, trap
end

test("Canonical source compiles and design timing remains unchanged", function()
	luau.compile(fs.readFile("src/hunting/HuntQuestRules.luau"))
	local config = Rules.Config
	check(config.Duration == 2400 and config.HarvestSeconds == 120, "40-minute hunt and two-minute harvest")
	check(config.MaxDeaths == 4 and config.RespawnDelay == 5, "Fourth death fails; respawn delay five seconds")
	check(config.TrapPlaceSeconds == 1 and config.TrapLifetime == 60, "Placement one second; trap waits sixty seconds")
	check(config.TrapHoldSeconds == 13 and config.CaptureSeconds == 3, "Trap holds thirteen seconds; potion interaction three")
	check(config.WeakRatio == .1 and config.TrapCount == 3 and config.PotionCount == 3, "Solo trial capacity and weakness")
end)

test("Preparation, ready timestamp, deadline and start idempotency", function()
	local run = assert(Rules.new("q", "m", 5))
	check(run.State == "Preparing" and run.Result == nil and not run.Closed and not run.Returned, "Run begins preparing")
	check(run.StartedAt == 0 and run.Deadline == 0 and run.Deaths == 0, "Preparation does not start the mission clock")
	check(not Rules.start(run, 4.999), "Cannot backdate readiness before preparation")
	check(Rules.tick(run, 999999) == nil and run.State == "Preparing", "Waiting to load never times out an unstarted hunt")
	check(Rules.start(run, 100), "Ready player begins hunting")
	check(run.StartedAt == 100 and run.Deadline == 2500, "Clock begins only when runtime declares ready")
	local before = clone(run)
	check(not Rules.start(run, 200), "Duplicate start rejected")
	check(equal(run, before), "Duplicate start cannot grant extra time or reset supplies")
end)

test("Mission timeout equality, late completion and once-only failure", function()
	local exact = fresh(0)
	check(Rules.tick(exact, 2400) == nil and exact.State == "Hunting", "Tick at deadline preserves valid same-timestamp completion")
	check(Rules.finish(exact, "Defeated", 2400), "Defeat exactly at deadline succeeds")
	check(exact.HarvestUntil == 2520, "Success receives full harvest independent of mission deadline")
	local late = fresh(0)
	check(not Rules.finish(late, "Defeated", 2400.001), "Late completion cannot win by claiming an earlier start")
	check(Rules.tick(late, 2400.001) == "Failed", "First late tick fails mission")
	check(late.Result == "Failed" and late.FailureReason == "TimeExpired", "Failure reports timeout")
	local after = clone(late)
	check(Rules.tick(late, 5000) == nil and not Rules.finish(late, "Captured", 2000), "Late duplicate events cannot reopen failed mission")
	check(not Rules.fail(late, "Other", 5001) and equal(late, after), "Failure is immutable and emitted once")
end)

test("Fourth death fails; ordinary death cancels actions without refunding spent traps", function()
	local run, trap = holding(10)
	check(Rules.beginCapture(run, 13, 100, 1200), "Can begin drinking while weak")
	check(Rules.death(run, 14) == "Camp" and run.Deaths == 1, "First death returns to camp")
	check(run.Action == nil and run.ActiveTrap == trap and run.Traps == 2 and run.Potions == 3, "Death cancels potion, keeps active trap timing and spent trap")
	check(Rules.death(run, 15) == "Camp" and run.Deaths == 2, "Second death continues")
	check(Rules.death(run, 16) == "Camp" and run.Deaths == 3, "Third death continues")
	check(Rules.death(run, 17) == "Failed" and run.Deaths == 4, "Fourth death fails")
	check(run.Result == "Failed" and run.FailureReason == "DeathLimit" and run.ActiveTrap == nil, "Final failure removes outstanding trap")
	check(Rules.death(run, 18) == nil and run.Deaths == 4, "Duplicate death after failed state cannot increment count")
	local expired = fresh(0)
	check(Rules.death(expired, 2400.01) == "Failed" and expired.Deaths == 0
		and expired.FailureReason == "TimeExpired", "Expired mission fails before counting another death")
end)

test("Locked success keeps outcome during harvest and returns after exactly 120 seconds", function()
	local run = fresh(10)
	check(Rules.finish(run, "Defeated", 20), "Main target defeat locks success")
	check(run.Result == "Defeated" and run.State == "Harvest" and run.HarvestUntil == 140, "Defeat opens harvest")
	check(not Rules.finish(run, "Captured", 20) and not Rules.fail(run, "DeathLimit", 21), "Capture/failure cannot overwrite defeat")
	for stamp = 21, 26 do check(Rules.death(run, stamp) == "Camp", "Harvest death returns to camp") end
	check(run.Deaths == 0 and run.Result == "Defeated", "Deaths after success cannot change mission death budget or outcome")
	check(Rules.tick(run, 139.999) == nil and run.State == "Harvest", "No early return")
	check(Rules.tick(run, 140) == "Returning" and not run.Closed, "Exact harvest expiry requests return without closing accounting")
	check(Rules.tick(run, 5000) == nil and run.Result == "Defeated", "Old forty-minute deadline no longer affects success")
	check(Rules.close(run) and run.Closed and run.Returned and run.State == "Closed", "Runtime can finish return exactly once")
	local before = clone(run)
	check(not Rules.close(run) and equal(run, before), "Duplicate close has no effects")
	check(not Rules.start(run, 6000) and not Rules.finish(run, "Captured", 6000), "Closed mission never restarts")
end)

test("Trap placement needs explicit commit and consumes one item only at completion", function()
	local run = fresh(10)
	local ok, reason, serial = Rules.beginPlace(run, 10)
	check(ok and reason == nil and serial == run.Action.Serial, "Begin returns action serial")
	check(run.Action.Kind == "Place" and run.Action.FinishAt == 11 and run.Traps == 3, "Beginning placement consumes nothing")
	check(Rules.tick(run, 10.5) == nil and run.Traps == 3 and run.ActiveTrap == nil, "Tick cannot create trap")
	check(Rules.commitPlace(run, 10.999) == nil and run.Traps == 3, "Cannot place early")
	check(Rules.tick(run, 11) == nil and run.ActiveTrap == nil, "Even completed duration requires runtime validation and commit")
	local trap = assert(Rules.commitPlace(run, 11, serial))
	check(run.Traps == 2 and run.Action == nil and run.ActiveTrap == trap, "One completed placement consumes exactly one trap")
	check(trap.Id == run.Id .. ":trap:1" and trap.State == "Waiting" and trap.ExpiresAt == 71, "Trap uses stable per-run ID and independent sixty-second timer")
	check(Rules.commitPlace(run, 11, serial) == nil and run.Traps == 2, "Duplicate completion cannot consume or create another trap")
	check(not Rules.beginPlace(run, 12) and run.Traps == 2, "Waiting trap blocks placing overlapping traps")
	check(Rules.tick(run, 71) == nil and run.ActiveTrap == trap, "Waiting trap can still trigger at exact expiry")
	check(Rules.tick(run, 71.001) == "TrapExpired" and run.ActiveTrap == nil, "Untriggered trap expires without refund")
	check(run.Traps == 2 and Rules.tick(run, 72) == nil, "Expiry is emitted only once")
end)

test("Cancellation and stale action tokens cannot consume new placement", function()
	local run = fresh(10)
	local _, _, first = Rules.beginPlace(run, 10)
	check(not Rules.beginPlace(run, 10.5), "Concurrent placement denied")
	check(Rules.cancelAction(run) and run.Action == nil and run.Traps == 3, "Canceling placement returns unchanged inventory")
	check(not Rules.cancelAction(run), "Repeated cancellation is harmless")
	local _, _, second = Rules.beginPlace(run, 12)
	check(second ~= first, "Retry has distinct serial")
	local trap, reason = Rules.commitPlace(run, 13, first)
	check(trap == nil and reason == "StaleAction" and run.Traps == 3, "Old completion callback cannot commit later attempt")
	check(Rules.commitPlace(run, 13, second) ~= nil and run.Traps == 2, "Current validated callback completes")
	local expired = fresh(0)
	check(Rules.beginPlace(expired, 2399.5), "Can start before mission deadline")
	check(not Rules.commitPlace(expired, 2400.5) and expired.Traps == 3, "Placement completing after mission deadline spends nothing")
end)

test("Traps trigger once and use thirteen seconds from activation", function()
	local run, trap = waiting(10)
	check(Rules.triggerTrap(run, 70), "Trap may trigger late in waiting lifetime")
	check(trap.State == "Holding" and trap.HeldUntil == 83, "Hold uses activation timestamp, not placement timestamp")
	check(not Rules.triggerTrap(run, 71) and trap.HeldUntil == 83, "Repeat trigger cannot extend hold")
	check(Rules.tick(run, 72) == nil and run.ActiveTrap == trap, "Waiting lifetime no longer ends triggered trap")
	check(not Rules.beginCapture(run, 72, 121, 1200), "Above ten percent cannot drink although trap holds")
	check(trap.State == "Holding", "High HP never cancels valid trap")
	check(Rules.tick(run, 83) == nil and run.ActiveTrap == trap, "Completion at exact hold endpoint can still be accepted")
	check(Rules.tick(run, 83.0001) == "TrapEscaped" and run.ActiveTrap == nil, "After endpoint target escapes and item remains spent")
	check(run.Traps == 2 and run.Potions == 3, "Trap escape does not consume potion")
	local late = waiting(0)
	local ok, reason = Rules.triggerTrap(late, 61.001)
	check(not ok and reason == "TrapExpired", "Late trigger denied even before next tick")
end)

test("Capture checks live health at both begin and commit, including exact ten percent", function()
	local run = holding(10)
	for _, hp in {0, -1, math.huge, 0/0, 120.00001, 1201} do
		check(not Rules.beginCapture(run, 13, hp, 1200) and run.Potions == 3, "Invalid or above-threshold HP denied")
	end
	for _, maximum in {0, -1, math.huge, 0/0} do
		check(not Rules.beginCapture(run, 13, 1, maximum), "Invalid maximum HP denied")
	end
	local ok, reason, serial = Rules.beginCapture(run, 13, 120, 1200)
	check(ok and reason == nil and run.Action.Kind == "Capture" and run.Action.FinishAt == 16, "Exactly ten percent starts three-second capture")
	check(not Rules.commitCapture(run, 15.999, 120, 1200, serial) and run.Potions == 3, "Premature drink cannot finish")
	check(Rules.tick(run, 16) == nil and run.State == "Hunting", "Tick never bypasses final health/physics checks")
	check(not Rules.commitCapture(run, 16, 120.001, 1200, serial), "Healing above threshold before finish blocks capture")
	check(not Rules.commitCapture(run, 16, 0, 1200, serial) and run.Potions == 3, "Dead target cannot be captured or consume potion")
	check(Rules.commitCapture(run, 16, 120, 1200, serial), "Alive exactly-ten-percent target captured after full interaction")
	check(run.Result == "Captured" and run.State == "Harvest" and run.Potions == 2, "Capture atomically locks outcome and consumes one potion")
	check(run.ActiveTrap == nil and run.Action == nil, "Final capture invalidates trap and interaction")
	check(not Rules.commitCapture(run, 16, 120, 1200, serial) and run.Potions == 2, "Duplicate commit cannot consume second potion")
	check(not Rules.finish(run, "Defeated", 16), "Later damage event cannot also defeat captured target")
end)

test("Interrupted potion retries require full duration and never restart trap clock", function()
	local run, trap = holding(10)
	local _, _, first = Rules.beginCapture(run, 13, 1, 1200)
	check(Rules.cancelAction(run) and run.Potions == 3, "Damage/range/weapon interruption consumes no potion")
	check(trap.HeldUntil == 25 and run.ActiveTrap == trap, "Cancellation keeps original trap deadline")
	local _, _, second = Rules.beginCapture(run, 15, 1, 1200)
	check(not Rules.commitCapture(run, 16, 1, 1200, first), "Old completion callback cannot apply to retry")
	check(not Rules.commitCapture(run, 17.999, 1, 1200, second), "New interaction requires full three seconds")
	check(Rules.commitCapture(run, 18, 1, 1200, second) and run.Potions == 2, "Current interaction completes and consumes once")
	local escaped, active = holding(0)
	check(Rules.beginCapture(escaped, 13, 1, 1200), "Late interaction may begin with little hold time remaining")
	check(active.HeldUntil == 15, "Trap's original deadline stays fixed")
	check(not Rules.commitCapture(escaped, 16, 1, 1200) and escaped.Potions == 3, "Hold ending before full drink never consumes potion")
	check(Rules.tick(escaped, 16) == "TrapEscaped" and escaped.Action == nil, "Escape cancels outstanding drink")
end)

test("Capture exact hold and mission endpoints; timeout prevents late potion consumption", function()
	local exact, trap = holding(0)
	check(Rules.beginCapture(exact, trap.HeldUntil - 3, 10, 100), "Three full seconds fit at hold endpoint")
	check(Rules.commitCapture(exact, trap.HeldUntil, 10, 100), "Capture at exact hold endpoint accepted")
	local mission = fresh(0)
	check(Rules.beginPlace(mission, 2394), "Placement near deadline begins")
	assert(Rules.commitPlace(mission, 2395))
	check(Rules.triggerTrap(mission, 2396), "Trap begins before deadline")
	check(Rules.beginCapture(mission, 2397, 1, 100), "Potion begins before deadline")
	check(Rules.commitCapture(mission, 2400, 1, 100) and mission.Result == "Captured", "Capture at exact mission endpoint accepted")
	local late = fresh(0)
	check(Rules.beginPlace(late, 2394), "Late test placement begins")
	assert(Rules.commitPlace(late, 2395))
	check(Rules.triggerTrap(late, 2396) and Rules.beginCapture(late, 2398, 1, 100), "Interaction begins in time")
	check(not Rules.commitCapture(late, 2401, 1, 100) and late.Potions == 3, "Starting in time does not permit late completion")
	check(Rules.tick(late, 2401) == "Failed" and late.Result == "Failed", "Expiry cancels drink and ends mission")
end)

test("Exhausted inventory does not end normal hunt and final active trap remains usable", function()
	local run = fresh(0)
	local clock = 0
	for index = 1, 3 do
		check(Rules.beginPlace(run, clock), "Each available trap can begin placement")
		local trap = assert(Rules.commitPlace(run, clock + 1))
		check(trap.Id == run.Id .. ":trap:" .. index and run.Traps == 3 - index, "Every trap has unique monotonically numbered ID")
		if index < 3 then
			check(Rules.tick(run, clock + 62) == "TrapExpired", "Unused traps expire")
			clock += 63
		end
	end
	check(run.Traps == 0 and run.State == "Hunting" and run.Result == nil, "No traps in bag does not fail normal hunt")
	check(Rules.triggerTrap(run, clock + 2) and Rules.beginCapture(run, clock + 3, 1, 100), "Last deployed trap still supports capture with empty bag")
	check(Rules.commitCapture(run, clock + 6, 1, 100) and run.Result == "Captured", "Last active trap can win normal hunt")
	local dry = fresh(0)
	dry.Traps = 0
	dry.Potions = 0
	check(not Rules.beginPlace(dry, 1), "No trap cannot place")
	check(Rules.tick(dry, 2) == nil and dry.State == "Hunting", "No supplies does not cause failure")
	check(Rules.finish(dry, "Defeated", 3), "Normal hunt can still finish by defeat")
	local noPotion = holding(0)
	noPotion.Potions = 0
	check(not Rules.beginCapture(noPotion, 3, 1, 100) and noPotion.State == "Hunting", "No potion denies capture without failing hunt")
end)

test("Competing defeat/capture outcomes grant only the first valid final transition", function()
	local defeated = holding(0)
	check(Rules.beginCapture(defeated, 3, 10, 100), "Pending capture starts")
	check(Rules.finish(defeated, "Defeated", 5), "Lethal hit during interaction wins first")
	check(not Rules.commitCapture(defeated, 6, 0, 100) and defeated.Potions == 3, "Pending capture cannot overwrite defeat or consume potion")
	local captured = holding(0)
	check(Rules.beginCapture(captured, 3, 1, 100) and Rules.commitCapture(captured, 6, 1, 100), "Capture first can finish")
	check(not Rules.finish(captured, "Defeated", 6) and captured.Result == "Captured", "Defeat callback afterward cannot produce a second result")
end)

test("Invalid input, non-finite clocks and unknown states cannot mutate missions", function()
	for _, bad in {"", string.rep("x", 129), "line\nfeed", false, {}, 1} do
		check(Rules.new(bad, "m", 0) == nil and Rules.new("q", bad, 0) == nil, "IDs must be bounded nonempty strings without control characters")
	end
	for _, bad in {-1, math.huge, -math.huge, 0/0, false, "1", {}} do
		check(Rules.new("q", "m", bad) == nil, "Constructor rejects invalid time")
		local run = fresh(10)
		local before = clone(run)
		check(not Rules.beginPlace(run, bad) and Rules.tick(run, bad) == nil, "Invalid timer cannot begin interaction or tick")
		check(not Rules.finish(run, "Defeated", bad) and not Rules.fail(run, "Other", bad)
			and Rules.death(run, bad) == nil and equal(run, before), "Invalid timer cannot end/count death or mutate mission")
	end
	for _, bad in {false, "mission", {}, {State = "MadeUp"}} do
		check(not Rules.start(bad, 0) and Rules.tick(bad, 0) == nil and not Rules.close(bad), "Malformed run safely ignored")
		check(not Rules.beginPlace(bad, 0) and not Rules.beginCapture(bad, 0, 1, 100)
			and not Rules.commitCapture(bad, 0, 1, 100), "Malformed run cannot use items")
	end
	check(not Rules.start(nil, 0) and Rules.new("q", "m", nil) == nil, "Nil inputs safe")
	local unknown = fresh(10)
	unknown.State = "Cheat"
	local before = clone(unknown)
	check(Rules.tick(unknown, 10000) == nil and not Rules.close(unknown) and equal(unknown, before), "Unknown state ignored without mutation")
	local longId = assert(Rules.new(string.rep("q", 128), string.rep("m", 128), 0))
	check(Rules.start(longId, 0) and Rules.beginPlace(longId, 0), "Maximum valid IDs can start and place")
	check(Rules.commitPlace(longId, 1) ~= nil and Rules.tick(longId, 2) == nil, "Generated trap suffix stays within separately bounded trap ID")
end)

test("Snapshots are detached and timers never become negative", function()
	local run, trap = holding(10)
	check(Rules.beginCapture(run, 13, 10, 100), "Snapshot test has active interaction")
	local view = assert(Rules.snapshot(run, 14))
	check(view.Id == run.Id and view.MonsterId == run.MonsterId and view.Remaining == 2396, "Snapshot reports trusted identity and remaining mission time")
	view.Action.FinishAt = 99999
	view.ActiveTrap.HeldUntil = 99999
	view.Traps = 999
	check(run.Action.FinishAt == 16 and trap.HeldUntil == 25 and run.Traps == 2, "Snapshot consumers cannot change live nested records")
	check(Rules.snapshot(run, 10000).Remaining == 0, "Remaining timer clamps at zero before timeout tick")
	check(Rules.snapshot(run, -1) == nil and Rules.snapshot(run, 9) == nil, "Invalid/backdated snapshot ignored")
	check(Rules.finish(run, "Defeated", 15), "Snapshot test locks success")
	check(Rules.snapshot(run, 16).HarvestRemaining == 119 and Rules.snapshot(run, 99999).HarvestRemaining == 0, "Harvest timer clamps independently")
end)

print(string.format("HuntQuestRules: %d checks across %d groups passed", checks, groups))
