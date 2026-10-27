-- Server-private, temporary map inspection permissions and command parsing.
-- Disable Enabled or remove the AdminFly runtime to retire this tool.
-- There is deliberately no Studio-wide permission: every user is checked.
local Policy = {
	Enabled = true,
	AdminUserIds = {[11605296816] = true},
	AllowExperienceOwner = true,
	Speeds = {80, 160, 260},
	DefaultSpeed = 160,
	BoostMultiplier = 2,
	MaxAltitude = 1800,
	MaxHorizontal = 12000,
}

local function positiveInteger(value)
	return type(value) == "number" and value == value and value > 0
		and value < math.huge and value % 1 == 0
end

-- creatorTypeString must be game.CreatorType.Name ("User" or "Group").
-- Group ownership never grants its numeric group ID permission as a user ID.
function Policy.Allowed(userId, creatorId, creatorTypeString)
	if Policy.Enabled ~= true or not positiveInteger(userId) then return false end
	if Policy.AdminUserIds[userId] == true then return true end
	return Policy.AllowExperienceOwner == true and creatorTypeString == "User"
		and positiveInteger(creatorId) and userId == creatorId
end

function Policy.ValidateSpeed(speed)
	return positiveInteger(speed) and (speed == 80 or speed == 160 or speed == 260)
end

-- Returns ("Toggle", nil), ("SetEnabled", boolean), ("SetSpeed", number),
-- or (nil, nil). SetSpeed is a fly command with the selected base speed.
-- Only complete commands match; /flyer and additional arguments are ignored.
function Policy.ParseChat(message)
	if type(message) ~= "string" then return nil, nil end
	local command = message:lower():match("^%s*(.-)%s*$"):gsub("%s+", " ")
	if command == "/fly" then return "Toggle", nil end
	if command == "/fly on" then return "SetEnabled", true end
	if command == "/fly off" or command == "/unfly" then return "SetEnabled", false end
	for _, speed in Policy.Speeds do
		if Policy.ValidateSpeed(speed) and (command == "/fly" .. speed or command == "/fly " .. speed) then
			return "SetSpeed", speed
		end
	end
	return nil, nil
end

return Policy
