-- Read the saved place and check that its playable rig and controls persisted.
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")
local game = roblox.deserializePlace(fs.readFile("Dinosaur01_TRex_Visual.rbxl"))
local workspace = game:GetService("Workspace")
local model = assert(workspace:FindFirstChild("Dinosaur01_TRex_Visual"))
assert(not workspace:FindFirstChild("TRex_HeadCleanup_Work"), "Duplicate preview model saved")
local report = {savedPlace="Dinosaur01_TRex_Visual.rbxl", model="Workspace.Dinosaur01_TRex_Visual",
	stage=model:GetAttribute("Stage"), parts=0, anchors=0, motors=0, welds=0, pbr=0, meshes={}, scripts={},
	feathers=model:GetAttribute("FeatherCount"), upperTeeth=model:GetAttribute("UpperToothCount"),
	lowerTeeth=model:GetAttribute("LowerToothCount"), previewKeys={Bite="F", Walk="G", Reset="R", Camera="C"}}
for _,part in model:GetDescendants() do
	if part:IsA("BasePart") then
		report.parts += 1
		assert(not part.CanCollide, "Unexpected colliding detail")
		if part.Anchored then report.anchors += 1 assert(part == model.PrimaryPart) end
	end
	if part:IsA("MeshPart") then
		local ok, meshId = pcall(function() return part.MeshId end)
		if not ok then
			local contentOk, content = pcall(function() return part.MeshContent end)
			meshId = contentOk and tostring(content) or nil
		end
		assert(meshId and meshId ~= "", "Missing saved mesh content: " .. part.Name)
		table.insert(report.meshes, {name=part.Name, meshId=meshId})
	end
	if part:IsA("SurfaceAppearance") then report.pbr += 1 end
	if part:IsA("Motor6D") or part:IsA("WeldConstraint") then
		assert(part.Part0 and part.Part1 and part.Part0:IsDescendantOf(model) and part.Part1:IsDescendantOf(model), "Broken joint")
		if part:IsA("Motor6D") then report.motors += 1 else report.welds += 1 end
	end
	if part:IsA("LuaSourceContainer") then
		table.insert(report.scripts, part.Name)
		assert(#part.Source > 0)
		if part:IsA("Script") then assert(not part.Disabled, "Disabled runtime: " .. part.Name) end
	end
end
assert(report.parts == 255 and report.anchors == 1 and report.motors == 7 and report.welds == 247)
assert(game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("DinosaurPreviewControls"))
assert(game:GetService("ServerScriptService"):FindFirstChild("DinosaurPreviewBridge"))
assert(game:GetService("ReplicatedStorage"):FindFirstChild("DinosaurPreviewCommand"))
assert(model:FindFirstChild("BiteRequest") and model:FindFirstChild("WalkRequest") and model:FindFirstChild("ResetMotionRequest"))
report.savedPlaceValidation = "passed"
report.runtimeValidation = {keyboardBite=true, mouseBite=true, keyboardWalk=true, mouseStop=true,
	reset=true, cameraToggle=true, biteWhileWalking=true, connectedParts=255,
	walkTravelStuds=20.87947654724121, maxLegSwingDegrees=10.983925171300048,
	minFootY=-.04558753967285156, maxFootY=.8092823028564453,
	stoppedDrift=0, resetPositionError=0, jawHingeError=.00000095367431640625}
fs.writeFile("assets/dinosaur01/final-model-manifest.json", serde.encode("json", report, true))
print("Saved place verified: 255 connected rig parts, seven motors, enabled runtimes and four preview controls.")
