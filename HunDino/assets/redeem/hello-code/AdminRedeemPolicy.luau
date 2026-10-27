-- Server-owned public and admin rewards. Clients submit only a code string.
local Policy = {}
local CODE = "HUNDINO-ADMIN-500"
local USER_ID = 11605296816
local CODE_ID = "AdminTest20261021"

function Policy.Resolve(userId, rawCode)
	if type(rawCode) ~= "string" or #rawCode > 64 then return nil, "InvalidCode" end
	local code = rawCode:match("^%s*(.-)%s*$"):upper()
	if code == "HELLOHUNDINO" then
		return {Op="RedeemCode", CodeId="HelloHunDino", Coins=50,
			Consumables={RawTrap=2, IronTrap=2, SleepPotion=2}}
	end
	if code ~= CODE then return nil, "InvalidCode" end
	if userId ~= USER_ID then return nil, "NotEligible" end
	-- A fresh request prevents any caller from changing the configured reward.
	return {Op="RedeemCode", CodeId=CODE_ID, Coins=500,
		Materials={Skin=10, Tooth=10, Scale=10, Bone=10, Iron=10}}
end

return Policy
