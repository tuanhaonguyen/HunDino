-- Studio Edit/Server harness. The real dinosaur is read only; the module cache,
-- synthetic runtime helpers and generated static models are all disposable.
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local runtime = assert(game:GetService("ServerScriptService"):FindFirstChild("HuntingRuntime"), "HuntingRuntime missing")
local moduleSource = assert(runtime:FindFirstChild("SpecimenPreviewModel"), "SpecimenPreviewModel missing")
local dinosaur = assert(workspace:FindFirstChild("Dinosaur01_TRex_Visual"), "Dinosaur visual missing")
local originalModuleSource = moduleSource.Source
local report = {version = "SpecimenPreviewIntegration.2", ok = false, checks = 0, passed = 0, failures = {}, protectedAttributes = {},
	boundary = "Installed preview builder, real original dinosaur and disposable runtime-helper clone; no original source, geometry, attributes, tags or Terrain mutation."}
local function check(condition, message)
	report.checks += 1
	if condition then report.passed += 1 else table.insert(report.failures, message) end
end
local function equal(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for key, value in a do if not equal(value, b[key]) then return false end end
	for key in b do if a[key] == nil then return false end end
	return true
end
local function near(a, b, tolerance)
	return type(a) == "number" and type(b) == "number" and math.abs(a - b) <= (tolerance or .00001)
end
local function nearFrame(a, b)
	local left, right = {a:GetComponents()}, {b:GetComponents()}
	for index, value in left do if not near(value, right[index], .003) then return false end end
	return true
end
local function read(object, key)
	local ok, value = pcall(function() return object[key] end)
	return if ok then value else nil
end
local PROPERTIES = {"Archivable", "Source", "Disabled", "CFrame", "Size", "Color", "Material", "MaterialVariant", "Transparency", "Reflectance", "Anchored",
	"CanCollide", "CanTouch", "CanQuery", "CastShadow", "Massless", "CollisionGroup", "PrimaryPart", "WorldPivot", "Part0", "Part1", "C0", "C1",
	"Texture", "TextureID", "MeshId", "Scale", "Offset", "VertexColor", "MeshType", "ColorMap", "NormalMap", "MetalnessMap", "RoughnessMap"}
local function snapshot(root)
	local output, objects = {}, root:GetDescendants()
	table.insert(objects, root)
	for _, object in objects do
		local tags = CollectionService:GetTags(object); table.sort(tags)
		local row = {Parent = object.Parent, Name = object.Name, ClassName = object.ClassName, Attributes = object:GetAttributes(), Tags = tags, Properties = {}}
		for _, property in PROPERTIES do row.Properties[property] = read(object, property) end
		output[object] = row
	end
	return output
end
local function compareUnchanged(root, before, label)
	local after, count = snapshot(root), 0
	for object, row in before do
		count += 1
		check(after[object] ~= nil and equal(row, after[object]), label .. " unchanged: " .. row.ClassName .. " / " .. row.Name)
	end
	local afterCount = 0; for _ in after do afterCount += 1 end
	check(afterCount == count, label .. " descendant count unchanged")
end
local ASSET_PROPERTIES = {"MeshId", "TextureId", "TextureID", "MeshType", "Scale", "Offset", "VertexColor", "ColorMap", "NormalMap", "MetalnessMap", "RoughnessMap",
	"AlphaMode", "Color", "Color3", "Texture", "Face", "Transparency", "StudsPerTileU", "StudsPerTileV", "OffsetStudsU", "OffsetStudsV", "ZIndex"}
local function appearances(part)
	local rows = {}
	for _, object in part:GetDescendants() do
		if object:IsA("DataModelMesh") or object:IsA("SurfaceAppearance") or object:IsA("Decal") then
			local row = {object.ClassName, object.Name}
			for _, property in ASSET_PROPERTIES do table.insert(row, property .. "=" .. tostring(read(object, property))) end
			table.insert(rows, table.concat(row, "|"))
		end
	end
	table.sort(rows)
	return table.concat(rows, "\n")
end
local function visibleParts(root)
	local parts = {}
	local helpers = root:FindFirstChild("CombatHitboxes")
	for _, object in root:GetDescendants() do
		if object:IsA("BasePart") and (not helpers or not object:IsDescendantOf(helpers)) then table.insert(parts, object) end
	end
	return parts
end
local function matchesAppearance(left, right)
	if left.Name ~= right.Name or left.ClassName ~= right.ClassName or left.Size ~= right.Size
		or left.Color ~= right.Color or left.Material ~= right.Material or left.MaterialVariant ~= right.MaterialVariant
		or left.Transparency ~= right.Transparency or left.Reflectance ~= right.Reflectance or left.CastShadow ~= right.CastShadow then return false end
	for _, property in {"Shape", "MeshId", "TextureID", "DoubleSided", "RenderFidelity"} do
		if read(left, property) ~= read(right, property) then return false end
	end
	return appearances(left) == appearances(right)
end
local rootAttributes = {SpeciesId = true, TemplateScale = true, SpecimenPreviewVersion = true}
local protectedAttributes = {}
local function sanitizedAttributes(object, isRoot, label)
	local publicCount = 0
	for key in object:GetAttributes() do
		if isRoot and rootAttributes[key] then
			publicCount += 1
		else
			-- Roblox may clone engine-owned provenance such as
			-- RBX_AI_GENERATION_TYPE. Only an actual CoreScript permission
			-- rejection can exempt a retained attribute; ordinary gameplay
			-- ownership data must already have been removed by the builder.
			local removable, exception = pcall(function() object:SetAttribute(key, nil) end)
			local protected = not removable and tostring(exception):find("CoreScript permission required", 1, true) ~= nil
			check(protected, label .. " removes public gameplay attribute: " .. key)
			if protected then protectedAttributes[key] = true end
		end
	end
	return publicCount
end
local function verifyPreview(source, model, label)
	check(typeof(model) == "Instance" and model:IsA("Model") and model ~= source and model.Parent == nil, label .. " returns a separate unparented model")
	if typeof(model) ~= "Instance" or not model:IsA("Model") then return end
	check(model.Name == "TRex", label .. " template name is TRex")
	check(model:GetAttribute("SpeciesId") == "TRex" and model:GetAttribute("SpecimenPreviewVersion") == 1, label .. " has fixed preview metadata")
	check(near(model:GetAttribute("TemplateScale"), source:GetScale()) and near(model:GetScale(), source:GetScale()), label .. " preserves the original model scale")
	check(nearFrame(model:GetPivot(), CFrame.new()), label .. " is centered at a stable local origin")
	local sourceParts, parts, meshes = visibleParts(source), {}, 0
	for _, object in model:GetDescendants() do
		if object:IsA("BasePart") then table.insert(parts, object); if object:IsA("MeshPart") then meshes += 1 end end
		local allowed = object:IsA("Model") or object:IsA("Folder") or object:IsA("BasePart") or object:IsA("DataModelMesh")
			or object:IsA("SurfaceAppearance") or object:IsA("Decal") or object:IsA("Texture") or object:IsA("Bone")
		check(allowed, label .. " strips behavior or UI: " .. object.ClassName .. " / " .. object.Name)
		sanitizedAttributes(object, false, label .. " / " .. object.Name)
		check(#CollectionService:GetTags(object) == 0, label .. " strips descendant gameplay tags: " .. object.Name)
		if object:IsA("BasePart") then
			check(object.Anchored and not object.CanCollide and not object.CanTouch and not object.CanQuery, label .. " part is static and excluded from gameplay queries: " .. object.Name)
			check(object.AssemblyLinearVelocity == Vector3.zero and object.AssemblyAngularVelocity == Vector3.zero, label .. " part has no velocity: " .. object.Name)
		end
	end
	check(#parts == 255 and #sourceParts == 255 and meshes == 21, label .. " retains exactly 255 original parts and 21 MeshParts")
	check(model:FindFirstChild("CombatHitboxes") == nil, label .. " has no runtime hurtbox folder")
	local metadataCount = sanitizedAttributes(model, true, label .. " root")
	check(metadataCount == 3 and #CollectionService:GetTags(model) == 0, label .. " has only three public root attributes, protected engine metadata and no tags")
	local used, sourcePivot, previewPivot = {}, source:GetPivot(), model:GetPivot()
	for _, original in sourceParts do
		local matching
		local relative = sourcePivot:ToObjectSpace(original.CFrame)
		for _, candidate in parts do
			if not used[candidate] and nearFrame(relative, previewPivot:ToObjectSpace(candidate.CFrame)) and matchesAppearance(original, candidate) then matching = candidate; break end
		end
		check(matching ~= nil, label .. " preserves relative geometry and appearance: " .. original.Name)
		if matching then used[matching] = true end
	end
	return #parts, meshes
end
local container = Instance.new("Folder"); container.Name = "SpecimenPreviewIntegration_" .. HttpService:GenerateGUID(false)
container.Parent = game:GetService("ServerStorage")
local clone = moduleSource:Clone(); clone.Parent = container
local generated = {}
local original = snapshot(dinosaur)
local originalScale, originalPivot = dinosaur:GetScale(), dinosaur:GetPivot()
local ok, exception = xpcall(function()
	local Preview = require(clone)
	local model = Preview.build(dinosaur); table.insert(generated, model)
	report.parts, report.meshes = verifyPreview(dinosaur, model, "Real dinosaur")
	compareUnchanged(dinosaur, original, "Original dinosaur")
	check(near(dinosaur:GetScale(), originalScale) and dinosaur:GetPivot() == originalPivot, "Original scale and pivot are unchanged")
	-- Exercise the startup case after Combat.new has attached runtime helpers.
	-- This raw copy stays in ServerStorage so copied scripts can never run.
	local raw = dinosaur:Clone(); assert(raw, "Could not clone disposable raw source"); raw.Name = "RuntimeDinosaurCopy"; raw.Parent = container
	raw:SetAttribute("QuestOwnerUserId", -4321); raw:SetAttribute("Captured", true); CollectionService:AddTag(raw, "SpecimenTestOwner")
	local helpers = Instance.new("Folder"); helpers.Name = "CombatHitboxes"; helpers.Parent = raw
	for index = 1, 5 do
		local helper = Instance.new("Part"); helper.Name = "RuntimeHitbox" .. index; helper.Transparency = 1; helper.Parent = helpers
	end
	local visual = assert(visibleParts(raw)[1]); visual:SetAttribute("RuntimeOwner", -4321); CollectionService:AddTag(visual, "SpecimenTestOwner")
	local ui = Instance.new("BillboardGui"); ui.Name = "DinosaurHealthbar"; ui.Parent = raw
	local highlight = Instance.new("Highlight"); highlight.Name = "CombatWarning"; highlight.Parent = raw
	local prompt = Instance.new("ProximityPrompt"); prompt.Name = "RuntimePrompt"; prompt.Parent = visual
	local behavior = Instance.new("Script"); behavior.Name = "RuntimeBehavior"; behavior.Disabled = true; behavior.Source = "return"; behavior.Parent = raw
	local joint = Instance.new("WeldConstraint"); joint.Name = "RuntimeJoint"; joint.Part0 = visual; joint.Part1 = visual; joint.Parent = visual
	local sound = Instance.new("Sound"); sound.Name = "RuntimeSound"; sound.Parent = visual
	local decal = Instance.new("Decal"); decal.Name = "SpecimenTransparencyProbe"; decal.Transparency = .37; decal.Face = Enum.NormalId.Back; decal.Parent = visual
	local rawBefore = snapshot(raw)
	local withHelpers = Preview.build(raw); table.insert(generated, withHelpers)
	verifyPreview(raw, withHelpers, "Runtime source")
	local clonedProbe = withHelpers:FindFirstChild("SpecimenTransparencyProbe", true)
	check(clonedProbe and clonedProbe:IsA("Decal") and near(clonedProbe.Transparency, .37), "Sanitization preserves visible Decal transparency")
	check(withHelpers:FindFirstChild("RuntimeBehavior", true) == nil and withHelpers:FindFirstChild("RuntimePrompt", true) == nil
		and withHelpers:FindFirstChild("CombatWarning", true) == nil and withHelpers:FindFirstChild("DinosaurHealthbar", true) == nil
		and withHelpers:FindFirstChild("RuntimeSound", true) == nil and withHelpers:FindFirstChild("RuntimeJoint", true) == nil, "Runtime behavior, UI, audio, interaction and joints are absent")
	compareUnchanged(raw, rawBefore, "Disposable source")
	compareUnchanged(dinosaur, original, "Original after helper test")
	check(moduleSource.Source == originalModuleSource, "Installed production module source unchanged")
end, function(value) return debug.traceback(tostring(value), 2) end)
if not ok then table.insert(report.failures, "Harness exception: " .. tostring(exception)) end
for _, model in generated do if typeof(model) == "Instance" then model:Destroy() end end
container:Destroy()
check(container.Parent == nil, "All disposable sources, helpers and module clones removed")
compareUnchanged(dinosaur, original, "Original after cleanup")
for key in protectedAttributes do table.insert(report.protectedAttributes, key) end
table.sort(report.protectedAttributes)
report.ok = ok and #report.failures == 0
return report
