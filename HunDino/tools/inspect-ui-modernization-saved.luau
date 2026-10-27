-- Run from HunDino. READ ONLY: never serialize/write the place or decode Terrain.
-- --baseline compares the untouched v2.4 save and reports local binding drift.
-- Default mode verifies the native Studio save, canonical sources and UI backups.
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local process = require("@lune/process")
local baselineMode = table.find(process.args, "--baseline") ~= nil
local placePath = "HunDino_DarkJungle_v2_4.rbxl"
local baselinePath = "backups/Hub_v24_before_ui_modernization_20261020.rbxl"
local backupPath = "ServerStorage.UIBackup_20261020"
local report = {
	version = "UIModernizationSavedValidation.1",
	mode = if baselineMode then "baseline" else "native-save",
	savedPlace = placePath,
	baseline = baselinePath,
	terrainPolicy = "Opaque Terrain property bytes are hashed only; no place serialization or Terrain decoding",
}
local checks = 0
local function check(condition, message)
	assert(condition, message)
	checks += 1
end
local function normalized(source)
	return source:gsub("\r\n", "\n"):gsub("^\239\187\191", ""):gsub("%s+$", "")
end
local shortHashes = {}
local function hash(value)
	if #value > 1024 then return serde.hash("sha256", value) end
	local result = shortHashes[value]
	if not result then result = serde.hash("sha256", value); shortHashes[value] = result end
	return result
end
local function pathOf(instance)
	local parts = {}
	while instance and not instance:IsA("DataModel") do
		table.insert(parts, 1, instance.Name)
		instance = instance.Parent
	end
	return table.concat(parts, ".")
end
local function at(root, path)
	for name in path:gmatch("[^.]+") do
		root = root and root:FindFirstChild(name)
	end
	return root
end
local function stable(value)
	if type(value) ~= "table" then return serde.encode("json", value) end
	local keys, output = {}, {}
	for key in value do table.insert(keys, key) end
	table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
	for _, key in keys do table.insert(output, stable(key) .. ":" .. stable(value[key])) end
	return "{" .. table.concat(output, ",") .. "}"
end
local function valueOf(value)
	local kind = typeof(value)
	if value == nil then return {kind = "nil"} end
	if kind == "Instance" then return {kind = kind, path = pathOf(value), className = value.ClassName} end
	if kind == "string" then return {kind = kind, bytes = #value, sha256 = hash(value)} end
	if kind == "number" then return {kind = kind, value = string.format("%.17g", value)} end
	if kind == "boolean" then return value end
	if kind == "table" then
		local output = {}
		for key, item in value do output[tostring(key)] = valueOf(item) end
		return output
	end
	if kind == "Vector3" then return {kind = kind, value = {value.X, value.Y, value.Z}} end
	if kind == "Vector2" then return {kind = kind, value = {value.X, value.Y}} end
	if kind == "Color3" then return {kind = kind, value = {value.R, value.G, value.B}} end
	if kind == "CFrame" then return {kind = kind, value = {value:GetComponents()}} end
	if kind == "PhysicalProperties" then
		return {kind = kind, value = {value.Density, value.Friction, value.Elasticity, value.FrictionWeight, value.ElasticityWeight}}
	end
	return {kind = kind, value = tostring(value)}
end
local canonical = {
	{"ReplicatedStorage.Shared.EquipmentInventory", "src/dark-jungle/EquipmentInventory.luau", true},
	{"ReplicatedStorage.Shared.HubUI", "src/dark-jungle/HubUI.luau", true},
	{"StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest", "src/hunting/HuntQuest.client.luau", true},
	{"StarterPlayer.StarterPlayerScripts.HunDinoPetCompanion", "src/hunting/PetCompanion.client.luau", true},
	{"StarterPlayer.StarterPlayerScripts.HunDinoEconomy", "src/hunting/HuntEconomy.client.luau", true},
	{"StarterPlayer.StarterPlayerScripts.HunDinoTraining", "studio-pet-integration/Training.client.luau", true},
	{"StarterPlayer.StarterPlayerScripts.ConnectedHuntingViewer", "src/hunting/ConnectedHuntingViewer.client.luau", true},
	{"ReplicatedStorage.Shared.UITheme", "src/dark-jungle/UITheme.luau", false},
	{"StarterPlayer.StarterPlayerScripts.HunDinoHoldProgress", "src/hunting/HoldProgress.client.luau", false},
}
local allowedSourceChanges, expectedNewSources = {}, {}
for _, binding in canonical do
	if binding[3] then allowedSourceChanges[binding[1]] = true else expectedNewSources[binding[1]] = true end
end
local reflection = roblox.getReflectionDatabase()
local propertyCache = {}
local unreadableProperties = {}
local function properties(className)
	if propertyCache[className] then return propertyCache[className] end
	local names, seen = {}, {}
	local class = reflection:GetClass(className)
	while class do
		for name in class.Properties do
			-- HistoryId is native Studio edit history, not gameplay or map data.
			if not seen[name] and name ~= "Parent" and name ~= "HistoryId" then
				table.insert(names, name)
				seen[name] = true
			end
		end
		class = if class.Superclass then reflection:GetClass(class.Superclass) else nil
	end
	table.sort(names)
	propertyCache[className] = names
	return names
end
local function isBackup(path)
	return path == backupPath or path:sub(1, #backupPath + 1) == backupPath .. "."
end
local function record(instance, maskSources, terrainRows)
	local path = pathOf(instance)
	local tags = instance:GetTags()
	table.sort(tags)
	local row = {path = path, className = instance.ClassName, attributes = valueOf(instance:GetAttributes()), tags = tags, properties = {}}
	for _, name in properties(instance.ClassName) do
		if maskSources and allowedSourceChanges[path] and name == "Source" then continue end
		local ok, value = pcall(function() return instance[name] end)
		if ok then
			if name == "Source" and type(value) == "string" then value = normalized(value) end
			row.properties[name] = valueOf(value)
		else
			unreadableProperties[instance.ClassName .. "." .. name] = true
		end
	end
	if instance:IsA("Terrain") then table.insert(terrainRows, row) end
	return row
end
local function records(root, maskSources, countOnly)
	local output, terrainRows = {}, {}
	local counts = {instances = 0, parts = 0, joints = 0, workspaceParts = 0, workspaceJoints = 0, sources = 0}
	local workspace = root:GetService("Workspace")
	for _, object in root:GetDescendants() do
		local path = pathOf(object)
		if isBackup(path) or (not baselineMode and expectedNewSources[path]) then continue end
		if not countOnly then
			local row = record(object, maskSources, terrainRows)
			table.insert(output, {key = path .. "|" .. object.ClassName, signature = hash(stable(row)), object = object})
		end
		counts.instances += 1
		if object:IsA("LuaSourceContainer") then counts.sources += 1 end
		if object:IsA("BasePart") and not object:IsA("Terrain") then
			counts.parts += 1
			if object:IsDescendantOf(workspace) then counts.workspaceParts += 1 end
		end
		if object:IsA("JointInstance") or object:IsA("WeldConstraint") then
			counts.joints += 1
			if object:IsDescendantOf(workspace) then counts.workspaceJoints += 1 end
		end
	end
	table.sort(output, function(a, b)
		return if a.key == b.key then a.signature < b.signature else a.key < b.key
	end)
	return output, counts, terrainRows
end
local function collect(root)
	local buckets, selection = {}, {}
	local counts = {instances = 0, parts = 0, joints = 0, workspaceParts = 0, workspaceJoints = 0, sources = 0}
	local world = root:GetService("Workspace")
	for _, object in root:GetDescendants() do
		local path = pathOf(object)
		if object.Parent == root and object.Name == "FilteredSelection" and object.ClassName == "Instance" then
			-- Native Studio owns these root selection records. Explicitly report
			-- their churn only after proving they contain no game descendants,
			-- attributes or tags. No other object receives this exception.
			check(#object:GetDescendants() == 0 and next(object:GetAttributes()) == nil and #object:GetTags() == 0,
				"FilteredSelection contains game data")
			check(object.Archivable and object.SourceAssetId == -1, "Unexpected native selection metadata")
			table.insert(selection, {uniqueId = tostring(object.UniqueId), descendants = 0, attributes = 0, tags = 0,
				archivable = object.Archivable, sourceAssetId = object.SourceAssetId})
			continue
		end
		if isBackup(path) or (not baselineMode and expectedNewSources[path]) then continue end
		local key = path .. "|" .. object.ClassName
		buckets[key] = buckets[key] or {}
		table.insert(buckets[key], object)
		counts.instances += 1
		if object:IsA("LuaSourceContainer") then counts.sources += 1 end
		if object:IsA("BasePart") and not object:IsA("Terrain") then
			counts.parts += 1
			if object:IsDescendantOf(world) then counts.workspaceParts += 1 end
		end
		if object:IsA("JointInstance") or object:IsA("WeldConstraint") then
			counts.joints += 1
			if object:IsDescendantOf(world) then counts.workspaceJoints += 1 end
		end
	end
	return buckets, counts, selection
end
local cachedPaths = {}
local function referencePath(object)
	if not cachedPaths[object] then cachedPaths[object] = pathOf(object) end
	return cachedPaths[object]
end
local function equivalent(a, b)
	-- Direct typed equality is exact for scalars and Roblox value types and
	-- avoids constructing/encoding millions of identical temporary records.
	if a == b then return true end
	if typeof(a) ~= typeof(b) then return false end
	if typeof(a) == "Instance" then return a.ClassName == b.ClassName and referencePath(a) == referencePath(b) end
	if type(a) == "string" or type(a) == "boolean" then return false end
	return stable(valueOf(a)) == stable(valueOf(b))
end
local function compareProperties(oldBuckets, buckets)
	local keys, differences, compared, reads = {}, {}, 0, 0
	local uniqueIds = {}
	local function uniqueId(object)
		if uniqueIds[object] then return uniqueIds[object] end
		local ok, value = pcall(function() return object.UniqueId end)
		if ok then uniqueIds[object] = tostring(value) end
		return uniqueIds[object]
	end
	local totalDifferences = 0
	local function difference(key, property, before, after)
		totalDifferences += 1
		if #differences < 100 then table.insert(differences, {instance = key, property = property, before = valueOf(before), saved = valueOf(after)}) end
	end
	for key in oldBuckets do table.insert(keys, key) end
	table.sort(keys)
	for key in buckets do if not oldBuckets[key] then difference(key, "InstanceCount", 0, #buckets[key]) end end
	for _, key in keys do
		local old, current = oldBuckets[key], buckets[key] or {}
		if #old ~= #current then difference(key, "InstanceCount", #old, #current) end
		local used = {}
		for _, object in old do
			local match = nil
			if #old == 1 and #current == 1 then match = 1 else
				-- Native UniqueIds disambiguate same-name siblings. If absent or
				-- changed, exact complete signatures preserve multiset matching.
				local id = uniqueId(object)
				for i, candidate in current do
					if not used[i] and id ~= nil and uniqueId(candidate) == id then match = i; break end
				end
				if not match then
					local signature = stable(record(object, not baselineMode, {}))
					for i, candidate in current do
						if not used[i] and stable(record(candidate, not baselineMode, {})) == signature then match = i; break end
					end
				end
				if not match then for i in current do if not used[i] then match = i; break end end end
			end
			if not match then continue end
			used[match] = true
			local candidate = current[match]
			local oldTags, tags = object:GetTags(), candidate:GetTags()
			table.sort(oldTags); table.sort(tags)
			if stable(oldTags) ~= stable(tags) then difference(key, "Tags", oldTags, tags) end
			local oldAttributes, attributes = object:GetAttributes(), candidate:GetAttributes()
			for name, value in oldAttributes do
				if not equivalent(value, attributes[name]) then difference(key, "Attribute:" .. name, value, attributes[name]) end
			end
			for name, value in attributes do
				if oldAttributes[name] == nil then difference(key, "Attribute:" .. name, nil, value) end
			end
			local allowSource = not baselineMode and allowedSourceChanges[referencePath(object)]
			for _, name in properties(object.ClassName) do
				if allowSource and name == "Source" then continue end
				local oldOk, a = pcall(function() return object[name] end)
				local ok, b = pcall(function() return candidate[name] end)
				reads += 1
				if not oldOk or not ok then
					unreadableProperties[object.ClassName .. "." .. name] = true
					if oldOk ~= ok then difference(key, name .. ":Readability", oldOk, ok) end
					continue
				end
				if name == "Source" then a, b = normalized(a), normalized(b) end
				if not equivalent(a, b) then difference(key, name, a, b) end
			end
			compared += 1
			if compared % 10000 == 0 then print("Strict property comparison:", compared, "instances,", reads, "properties") end
		end
	end
	report.comparedInstances, report.comparedProperties = compared, reads
	report.instancePropertyDifferences, report.totalInstancePropertyDifferences = differences, totalDifferences
	check(totalDifferences == 0, "Existing instance property/attribute/tag differences: " .. totalDifferences)
end
-- Only unwrap the rbxl container's compression. The payloads of native
-- Terrain properties remain opaque bytes, including value types Lune omits.
local function uncompressBlock(data, length)
	local input, output = buffer.fromstring(data), buffer.create(length)
	local i, written = 0, 0
	while i < #data do
		local token = buffer.readu8(input, i); i += 1
		local literals = bit32.rshift(token, 4)
		if literals == 15 then
			repeat local n = buffer.readu8(input, i); i += 1; literals += n until n ~= 255
		end
		check(i + literals <= #data and written + literals <= length, "Invalid native chunk literal length")
		buffer.copy(output, written, input, i, literals); i += literals; written += literals
		if i == #data then break end
		local offset = buffer.readu16(input, i); i += 2
		check(offset > 0 and offset <= written, "Invalid native chunk match offset")
		local match = bit32.band(token, 15) + 4
		if bit32.band(token, 15) == 15 then
			repeat local n = buffer.readu8(input, i); i += 1; match += n until n ~= 255
		end
		check(written + match <= length, "Invalid native chunk match length")
		while match > 0 do
			local copy = math.min(offset, match)
			buffer.copy(output, written, output, written - offset, copy)
			written += copy; match -= copy
		end
	end
	check(written == length, "Native chunk expanded length differs")
	return buffer.tostring(output)
end
local function opaqueTerrain(bytes)
	local input, cursor, terrainClass, properties = buffer.fromstring(bytes), 32, nil, {}
	check(bytes:sub(1, 8) == "<roblox!", "Expected binary native rbxl")
	while cursor + 16 <= #bytes do
		local kind = buffer.readstring(input, cursor, 4)
		local compressed, expanded = buffer.readu32(input, cursor + 4), buffer.readu32(input, cursor + 8)
		local size = if compressed == 0 then expanded else compressed
		check(cursor + 16 + size <= #bytes, "Native chunk exceeds file length")
		if kind == "INST" or kind == "PROP" then
			local payload = buffer.readstring(input, cursor + 16, size)
			if compressed > 0 then
				if payload:sub(1, 4) == "\40\181\47\253" then
					payload = serde.decompress("zstd", payload)
					check(#payload == expanded, "Native Zstd chunk expanded length differs")
				else payload = uncompressBlock(payload, expanded) end
			end
			local data = buffer.fromstring(payload)
			local class = buffer.readu32(data, 0)
			local nameLength = buffer.readu32(data, 4)
			local name = buffer.readstring(data, 8, nameLength)
			if kind == "INST" and name == "Terrain" then terrainClass = class end
			if kind == "PROP" and class == terrainClass then
				-- Skip class index: native save may reorder class indices.
				properties[name] = {bytes = #payload - 4, sha256 = hash(payload:sub(5))}
			end
		end
		cursor += 16 + size
		if kind == "END\0" then break end
	end
	check(terrainClass ~= nil and next(properties) ~= nil, "Opaque native Terrain properties missing")
	return properties
end
local function sourceBindings(saved, before)
	local rows, mismatches = {}, {}
	for _, binding in canonical do
		local path, file, existing = binding[1], binding[2], binding[3]
		local object, original = at(saved, path), at(before, path)
		local localSource = if fs.isFile(file) then normalized(fs.readFile(file)) else nil
		local source = if object and object:IsA("LuaSourceContainer") then normalized(object.Source) else nil
		local row = {
			saved = path, source = file, existing = existing,
			savedHash = if source then hash(source) else nil,
			baselineHash = if original and original:IsA("LuaSourceContainer") then hash(normalized(original.Source)) else nil,
			localHash = if localSource then hash(localSource) else nil,
			matchesLocal = source ~= nil and source == localSource,
			attributes = if object then valueOf(object:GetAttributes()) else nil,
		}
		table.insert(rows, row)
		if not row.matchesLocal then table.insert(mismatches, file) end
		if not baselineMode then
			check(row.matchesLocal, "Saved source differs/missing: " .. path .. " <- " .. file)
			check(object.ClassName == (if file:find(".client.luau", 1, true) then "LocalScript" else "ModuleScript"), "Wrong source class: " .. path)
		end
	end
	report.canonicalSources, report.localSourceMismatches = rows, mismatches
	local savedTraining = at(saved, "StarterPlayer.StarterPlayerScripts.HunDinoTraining")
	report.trainingCandidates = {}
	for _, file in {"src/dark-jungle/Training.client.luau", "src/client/Training.client.luau", "studio-pet-integration/Training.client.luau"} do
		local source = normalized(fs.readFile(file))
		table.insert(report.trainingCandidates, {file = file, sha256 = hash(source), matchesSaved = source == normalized(savedTraining.Source)})
	end
end
local function verifyBackups(saved, before)
	local folder = at(saved, backupPath)
	check(folder and folder:IsA("Folder"), "Missing UI source backup folder: " .. backupPath)
	local remaining = {}
	for path in allowedSourceChanges do remaining[path] = hash(normalized(assert(at(before, path)).Source)) end
	local count = 0
	for _, object in folder:GetDescendants() do
		check(object:IsA("StringValue"), "UI backup must contain only source StringValues")
		local sourceHash, matched = hash(normalized(object.Value)), nil
		for path, expectedHash in remaining do
			if sourceHash == expectedHash then matched = path; break end
		end
		check(matched ~= nil, "Unexpected/duplicate UI source backup: " .. object.Name)
		remaining[matched] = nil
		count += 1
	end
	check(next(remaining) == nil, "Missing original UI source backups")
	report.verifiedSourceBackups = count
end
local function main()
	local bytes, beforeBytes = fs.readFile(placePath), fs.readFile(baselinePath)
	report.savedBytes, report.baselineBytes = #bytes, #beforeBytes
	report.savedSha256, report.baselineSha256 = hash(bytes), hash(beforeBytes)
	local oldOpaque, opaque = opaqueTerrain(beforeBytes), opaqueTerrain(bytes)
	check(stable(oldOpaque) == stable(opaque), "Native opaque Terrain property bytes changed")
	report.opaqueTerrainProperties = opaque
	local saved, before = roblox.deserializePlace(bytes), roblox.deserializePlace(beforeBytes)
	sourceBindings(saved, before)
	local compiled, originals = 0, 0
	for _, object in saved:GetDescendants() do
		if not object:IsA("LuaSourceContainer") then continue end
		local ok, err = pcall(luau.compile, object.Source)
		check(ok, "Compile failure: " .. pathOf(object) .. ": " .. tostring(err))
		compiled += 1
	end
	for _, object in before:GetDescendants() do if object:IsA("LuaSourceContainer") then originals += 1 end end
	report.compiledScripts, report.baselineScripts = compiled, originals
	-- Identical native byte streams already prove every serialized property equal.
	local byteIdentical = bytes == beforeBytes
	local oldBuckets, oldCounts, oldSelection = collect(before)
	local buckets, counts, selection = collect(saved)
	report.preserved, report.baselineCounts = counts, oldCounts
	report.nativeSelectionMetadata = {path = "<DataModel>.FilteredSelection|Instance", baselineCount = #oldSelection,
		savedCount = #selection, baseline = oldSelection, saved = selection,
		reason = "Native Studio root selection metadata only; verified empty descendants, attributes and tags"}
	compareProperties(oldBuckets, buckets)
	check(counts.instances == oldCounts.instances, "Existing instance count changed: " .. oldCounts.instances .. " -> " .. counts.instances)
	report.nativeBytesUnchanged = byteIdentical
	local unreadable = {}
	for name in unreadableProperties do table.insert(unreadable, name) end
	table.sort(unreadable)
	report.unreadableReflectionProperties = unreadable
	check(counts.parts == 43775 and counts.joints == 845, "Unexpected v2.4 saved Part/Joint totals")
	check(counts.workspaceParts == 35064 and counts.workspaceJoints == 723, "Unexpected v2.4 Workspace Part/Joint totals")
	if not baselineMode then verifyBackups(saved, before) end
	local forest = assert(saved:GetService("Workspace"):FindFirstChild("HuntingRainforest"))
	report.mapAttributes = valueOf(forest:GetAttributes())
	check(forest:GetAttribute("Version") == "H2.0" and forest:GetAttribute("TreesPlaced") == 2400, "H2.0 forest metadata changed")
end
local ok, err = xpcall(main, debug.traceback)
report.validation = if ok then "passed" else "failed"
report.checksPassed = checks
if not ok then report.error = tostring(err) end
-- The optional JSON report is the only file this inspector can write.
if table.find(process.args, "--report") then
	fs.writeFile("assets/hunting/ui-modernization-saved.json", serde.encode("json", report, true))
end
print(serde.encode("json", report, true))
assert(ok, "UI modernization saved inspection failed: " .. tostring(err))
