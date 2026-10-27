-- Source-only checks, safe before native Studio installation. No place writes.
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local process = require("@lune/process")
local bindings = {
	{"ReplicatedStorage.Shared.EquipmentInventory", "src/dark-jungle/EquipmentInventory.luau"},
	{"ReplicatedStorage.Shared.HubUI", "src/dark-jungle/HubUI.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest", "src/hunting/HuntQuest.client.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoPetCompanion", "src/hunting/PetCompanion.client.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoEconomy", "src/hunting/HuntEconomy.client.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoTraining", "studio-pet-integration/Training.client.luau"},
	{"StarterPlayer.StarterPlayerScripts.ConnectedHuntingViewer", "src/hunting/ConnectedHuntingViewer.client.luau"},
	{nil, "src/dark-jungle/UITheme.luau"},
	{nil, "src/hunting/HoldProgress.client.luau"},
}
local function at(root, path)
	for part in path:gmatch("[^.]+") do root = assert(root:FindFirstChild(part), path) end
	return root
end
-- Tokenize calls so formatting and UI string edits cannot hide a changed
-- remote action/payload. This compares the existing client-server boundary.
local function tokens(source)
	local output, i = {}, 1
	while i <= #source do
		local ch = source:sub(i, i)
		if ch:match("%s") then i += 1; continue end
		if source:sub(i, i + 1) == "--" then
			local long = source:match("^%-%-%[(=*)%[", i)
			if long then
				local _, last = source:find("]" .. long .. "]", i + 4 + #long, true)
				i = if last then last + 1 else #source + 1
			else
				i = (source:find("\n", i + 2, true) or #source) + 1
			end
			continue
		end
		if ch == "\"" or ch == "'" then
			local start, quote = i, ch
			i += 1
			while i <= #source do
				local nextCh = source:sub(i, i)
				if nextCh == "\\" then i += 2
				elseif nextCh == quote then i += 1; break
				else i += 1 end
			end
			-- Normalize quote choice without evaluating the script.
			table.insert(output, "STRING:" .. source:sub(start + 1, i - 2))
			continue
		end
		local long = source:match("^%[(=*)%[", i)
		if long then
			local _, last = source:find("]" .. long .. "]", i + 2 + #long, true)
			local finish = last or #source
			table.insert(output, source:sub(i, finish)); i = finish + 1; continue
		end
		local word = source:match("^[%a_][%w_]*", i) or source:match("^%d[%w_.]*", i)
		if word then table.insert(output, word); i += #word
		else table.insert(output, ch); i += 1 end
	end
	return output
end
local function calls(source)
	local input, result = tokens(source), {}
	for index, token in input do
		if token ~= ":" or (input[index + 1] ~= "FireServer" and input[index + 1] ~= "InvokeServer") or input[index + 2] ~= "(" then continue end
		local depth, call = 0, {}
		for j = index + 2, #input do
			local item = input[j]
			if item == "(" then depth += 1 elseif item == ")" then depth -= 1 end
			table.insert(call, item)
			if depth == 0 then break end
		end
		table.insert(result, input[index + 1] .. table.concat(call, " "))
	end
	table.sort(result)
	return result
end
local saved = roblox.deserializePlace(fs.readFile("backups/Hub_v24_before_ui_modernization_20261020.rbxl"))
local compiled, verifiedCalls = 0, 0
for _, binding in bindings do
	local path, file = binding[1], binding[2]
	local source = fs.readFile(file)
	local ok, err = pcall(luau.compile, source)
	assert(ok, file .. ": " .. tostring(err))
	compiled += 1
	local newCalls = calls(source)
	if path then
		local oldCalls = calls(at(saved, path).Source)
		assert(#oldCalls == #newCalls, file .. " changed remote action count")
		for i, old in oldCalls do
			assert(old == newCalls[i], file .. " changed remote action/payload: " .. old .. " -> " .. tostring(newCalls[i]))
			verifiedCalls += 1
		end
	else
		assert(#newCalls == 0, "New presentation source introduced server requests: " .. file)
	end
end
print(serde.encode("json", {validation = "passed", compiledUISources = compiled, unchangedRemoteCalls = verifiedCalls,
	contract = "Existing FireServer/InvokeServer action and payload tokens preserved; new presentation scripts issue no requests"}, true))
if table.find(process.args, "--package") then
	local function normalized(source)
		return source:gsub("\r\n", "\n"):gsub("^\239\187\191", ""):gsub("%s+$", "")
	end
	local function signature(place)
		local rows = {}
		for _, object in place:GetDescendants() do
			local value = object:GetFullName() .. "|" .. object.ClassName
			if object:IsA("LuaSourceContainer") then value ..= "|" .. serde.hash("sha256", object.Source) end
			if object:IsA("StringValue") then value ..= "|" .. serde.hash("sha256", object.Value) end
			table.insert(rows, value)
		end
		table.sort(rows)
		return serde.hash("sha256", table.concat(rows, "\n"))
	end
	local function installFor(place)
		local packageModel = roblox.deserializeModel(fs.readFile("assets/ui/HunDinoUIModernization.rbxm"))[1]
		packageModel.Parent = place:GetService("ServerStorage")
		local fakeGame = {
			FindFirstChild = function(_, name) return place:FindFirstChild(name) end,
			GetService = function(_, name)
				if name == "RunService" then return {IsStudio = function() return true end, IsRunning = function() return false end} end
				return place:GetService(name)
			end,
		}
		local api = luau.load(packageModel.Install.Source, {environment = {
			game = fakeGame, workspace = place:GetService("Workspace"), script = packageModel.Install, Instance = roblox.Instance,
		}, injectGlobals = true})()
		return api, packageModel
	end
	local api, packageModel = installFor(saved)
	local before = signature(saved)
	local result = api.Install({DryRun = true})
	assert(result.Preflight == "passed" and result.MapWrites == 0 and result.TerrainWrites == 0)
	assert(signature(saved) == before, "DryRun mutated original instances or sources")
	assert(not saved:GetService("ServerStorage"):FindFirstChild("UIBackup_20261020"), "DryRun created backups")
	-- Test actual installation exclusively in an in-memory deserialized model.
	-- The model is deliberately never serialized or saved to an rbxl.
	api.Install()
	assert(packageModel.Parent == nil, "Successful package must remove its staging model")
	local backup = saved:GetService("ServerStorage").UIBackup_20261020
	assert(#backup:GetChildren() == 7, "Expected seven original source backups")
	local baseline = roblox.deserializePlace(fs.readFile("backups/Hub_v24_before_ui_modernization_20261020.rbxl"))
	for _, copy in backup:GetChildren() do
		assert(copy:IsA("StringValue"))
		assert(normalized(copy.Value) == normalized(at(baseline, copy:GetAttribute("OriginalPath")).Source), "Backup lost original source")
	end
	for _, binding in bindings do
		local path, file = binding[1], binding[2]
		if not path then path = if file:find("UITheme", 1, true) then "ReplicatedStorage.Shared.UITheme" else "StarterPlayer.StarterPlayerScripts.HunDinoHoldProgress" end
		assert(normalized(at(saved, path).Source) == normalized(fs.readFile(file)), "Package is stale: " .. file)
	end
	local wrong = roblox.deserializePlace(fs.readFile("HunDino_DarkJungle_v2_3.rbxl"))
	local wrongAPI = installFor(wrong)
	local wrongBefore = signature(wrong)
	local accepted, rejection = pcall(wrongAPI.Install, {DryRun = true})
	assert(not accepted, "Installer accepted historical v2.3")
	assert(signature(wrong) == wrongBefore, "Wrong-place rejection mutated sources/instances")
	print(serde.encode("json", {packageValidation = "passed", baselineDryRun = "passed; no mutations", inMemoryInstall = "passed; 7 originals + 2 new sources",
		wrongVersionRejection = tostring(rejection), nativePlaceWrites = 0}, true))
end
