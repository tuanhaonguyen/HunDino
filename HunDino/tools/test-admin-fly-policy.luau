-- Run from HunDino: tools/lune/lune.exe run tools/test-admin-fly-policy.luau
-- Pure permission/parser checks: no Studio or Roblox instances are required.
local Policy = require("../src/admin/AdminFlyPolicy")
local checks = 0
local function check(condition, name)
	checks += 1
	assert(condition, name)
end
local function command(message, expectedAction, expectedValue)
	local action, value = Policy.ParseChat(message)
	check(action == expectedAction and value == expectedValue, "Unexpected command result: " .. tostring(message))
end

local adminId = 11605296816
check(Policy.Enabled == true, "Temporary fly tool is enabled")
check(Policy.Allowed(adminId, 0, "User"), "Allowlisted administrator")
check(Policy.Allowed(adminId, 80, "Group"), "Administrator permission does not depend on ownership")
check(not Policy.Allowed(123, 456, "User"), "Ordinary player denied")
check(not Policy.Allowed(1, 0, "User"), "Studio test player gets no automatic permission")
check(not Policy.Allowed(123, 123, "Group"), "A group ID cannot authorize the same numeric player ID")
check(Policy.Allowed(123, 123, "User"), "Individual experience owner allowed")
check(not Policy.Allowed(123, 123, "user"), "Creator type is explicit")
check(not Policy.Allowed(123, 123, nil), "Unknown creator type denied")

local invalidIds = {0, -1, 1.5, math.huge, -math.huge, 0 / 0, "11605296816", true, {}}
for _, userId in invalidIds do
	check(not Policy.Allowed(userId, userId, "User"), "Invalid user ID denied: " .. tostring(userId))
end
check(not Policy.Allowed(nil, nil, "User"), "Missing user ID denied")
for _, creatorId in invalidIds do
	check(not Policy.Allowed(123, creatorId, "User"), "Invalid owner ID denied: " .. tostring(creatorId))
end
Policy.AllowExperienceOwner = false
check(not Policy.Allowed(123, 123, "User"), "Owner permission can be disabled")
check(Policy.Allowed(adminId, 0, "User"), "Disabling owner permission preserves explicit administrators")
Policy.AllowExperienceOwner = true
Policy.Enabled = false
check(not Policy.Allowed(adminId, adminId, "User"), "Global switch denies administrator and owner")
check(not Policy.Allowed(123, 123, "User"), "Global switch denies owner")
Policy.Enabled = true

check(Policy.DefaultSpeed == 160 and Policy.BoostMultiplier == 2, "Default speed and boost")
check(Policy.MaxAltitude == 1800 and Policy.MaxHorizontal == 12000, "Finite preview bounds")
for _, speed in {80, 160, 260} do
	check(Policy.ValidateSpeed(speed), "Predefined speed accepted")
	command("/fly" .. speed, "SetSpeed", speed)
	command("/fly " .. speed, "SetSpeed", speed)
end
for _, speed in {0, -80, 1, 81, 160.5, 520, 1e9, math.huge, -math.huge, 0 / 0, "80", false, {}} do
	check(not Policy.ValidateSpeed(speed), "Untrusted speed denied: " .. tostring(speed))
end
check(not Policy.ValidateSpeed(nil), "Missing speed denied")

command("/fly", "Toggle", nil)
command("  /FlY  ", "Toggle", nil)
command("/fly on", "SetEnabled", true)
command("\t/FLY\t ON\n", "SetEnabled", true)
command("/fly off", "SetEnabled", false)
command("/UNFLY", "SetEnabled", false)
command(" /fly   160 ", "SetSpeed", 160)
for _, message in {"", "fly", "/flyer", "/fly260x", "/fly80 off", "/fly off now", "/unfly now", "/fly 0", "/fly -80", "/fly 1e9", "/fly 8e1", "/fly 80.0", "/fly 080", "/fly inf", "/fly nan", "/fly true", "/fly toggle", false, 80, {}} do
	command(message, nil, nil)
end
command(nil, nil, nil)
print(string.format("AdminFlyPolicy: %d checks passed", checks))
