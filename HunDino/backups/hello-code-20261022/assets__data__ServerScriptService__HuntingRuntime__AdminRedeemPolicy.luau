-- Server-only test grant. Eligibility never comes from a client attribute.
local Policy = {}
local CODE = "HUNDINO-ADMIN-500"
local USER_ID = 11605296816
local CODE_ID = "AdminTest20261021"

function Policy.Resolve(userId, rawCode)
	if userId ~= USER_ID then return nil, "NotEligible" end
	if type(rawCode) ~= "string" or #rawCode > 64 then return nil, "InvalidCode" end
	local code = rawCode:match("^%s*(.-)%s*$"):upper()
	if code ~= CODE then return nil, "InvalidCode" end
	-- A fresh request prevents any caller from changing the configured reward.
	return {Op="RedeemCode", CodeId=CODE_ID, Coins=500,
		Materials={Skin=10, Tooth=10, Scale=10, Bone=10, Iron=10}}
end

return Policy
