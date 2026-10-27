-- Studio-only disk backend. The companion helper performs atomic compare-and-swap.
-- Published Roblox servers always use DataStoreService in ProfileService.
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalStore = {}

function LocalStore.new()
	assert(RunService:IsStudio(), "Local saves are only available in Studio")
	local base = "http://127.0.0.1:18764"
	local function request(method, path, body)
		local response = HttpService:RequestAsync({
			Url = base .. path, Method = method,
			Headers = {["Content-Type"] = "application/json", ["X-HunDino-Local"] = "v1"},
			Body = if body then HttpService:JSONEncode(body) else nil,
		})
		if response.StatusCode == 409 then return nil, "Retry" end
		assert(response.Success, "Local save helper failed: " .. tostring(response.StatusCode))
		return HttpService:JSONDecode(response.Body)
	end
	local health = request("GET", "/health")
	assert(health and health.service == "HunDinoLocalSaveV1", "Wrong local save helper")
	local backend = {}
	function backend:UpdateAsync(key, transform)
		local path = "/profile/" .. HttpService:UrlEncode(key)
		for _ = 1, 8 do
			local current = request("GET", path)
			local nextValue = transform(if current.exists then current.value else nil)
			-- A nil callback result cancels the write, just like DataStore UpdateAsync.
			if nextValue == nil then return nil end
			local result, reason = request("POST", path, {version = current.version, value = nextValue})
			if reason ~= "Retry" then return result.value end
			task.wait(.05)
		end
		error("Local save has too many concurrent updates")
	end
	return backend
end

return LocalStore
