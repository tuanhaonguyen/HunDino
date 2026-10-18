-- Edit-time rig for the existing segmented mesh; preserves its rest silhouette.
local model = workspace.Dinosaur01_TRex_Visual
assert(not model:FindFirstChild("LocomotionRig"), "Walk rig already exists")
local root = model.body.body_geom
local skull = model.head.head_geom
local jaw = model.head.LowerJaw.jaw_geom
local direction = -skull.JawHinge.WorldCFrame.ZVector
local forward = Vector3.new(direction.X, 0, direction.Z).Unit
local rig = Instance.new("Folder") rig.Name = "LocomotionRig" rig.Parent = model
local geometry, samples, core = {}, {}, {}
for _,name in {"body_geom", "head_geom", "left leg_geom", "right leg_geom", "left arm_geom", "right arm_geom", "tail_geom"} do
	local part = assert(model:FindFirstChild(name, true))
	core[name] = part
	local mesh = game:GetService("AssetService"):CreateEditableMeshAsync(part.MeshContent)
	local center, scale = mesh:GetCenter(), part.Size / mesh:GetSize()
	local points, reduced = {}, {}
	local low, high = math.huge, -math.huge
	for i, id in mesh:GetVertices() do
		local point = part.CFrame:PointToWorldSpace((mesh:GetPosition(id) - center) * scale)
		table.insert(points, point)
		if i % 5 == 0 then table.insert(reduced, point) end
		low, high = math.min(low, point.Y), math.max(high, point.Y)
	end
	geometry[part] = { points = points, low = low, high = high }
	samples[part] = reduced
	mesh:Destroy()
	task.wait()
end
local function upperPoint(part, depth)
	local data, sum, count = geometry[part], Vector3.zero, 0
	for _,p in data.points do
		if p.Y > data.high - depth then sum += p count += 1 end
	end
	return sum / count
end
local function motor(name, part, position)
	local frame = CFrame.lookAt(position, position + forward)
	local joint = Instance.new("Motor6D")
	joint.Name = name joint.Part0 = root joint.Part1 = part
	joint.C0 = root.CFrame:ToObjectSpace(frame)
	joint.C1 = part.CFrame:ToObjectSpace(frame)
	joint:SetAttribute("RestC0", joint.C0)
	joint.Parent = rig
	return joint, frame
end
for name, key in {LeftHip="left leg_geom", RightHip="right leg_geom"} do
	local part = core[key]
	local joint, pivot = motor(name, part, upperPoint(part, 2.5))
	local foot = {}
	for _,p in geometry[part].points do
		if p.Y < geometry[part].low + 1.4 then
			local localPoint = pivot:PointToObjectSpace(p)
			table.insert(foot, {localPoint.X, localPoint.Y, localPoint.Z})
		end
	end
	joint:SetAttribute("FootSamples", game:GetService("HttpService"):JSONEncode(foot))
end
motor("LeftShoulder", core["left arm_geom"], upperPoint(core["left arm_geom"], 1.4))
motor("RightShoulder", core["right arm_geom"], upperPoint(core["right arm_geom"], 1.4))
local tail = core.tail_geom
local maximum = -math.huge
for _,p in geometry[tail].points do maximum = math.max(maximum, p:Dot(forward)) end
local sum, count = Vector3.zero, 0
for _,p in geometry[tail].points do
	if p:Dot(forward) > maximum - 1.4 then sum += p count += 1 end
end
motor("Tail", tail, sum / count)
motor("Neck", skull, skull.JawHinge.WorldPosition - forward * 4 - Vector3.new(0, 3, 0))

local coreSet = {[jaw] = true}
for _,part in core do coreSet[part] = true end
for _,part in model.head.LowerJaw.Teeth:GetChildren() do
	if part:IsA("BasePart") then coreSet[part] = true end
end
local function closestSkin(point)
	local best, distance = root, math.huge
	for part, points in samples do
		for _,p in points do
			local delta = p - point
			local d = delta:Dot(delta)
			if d < distance then best, distance = part, d end
		end
	end
	return best
end
local welded, n = {}, 0
for _,part in model:GetDescendants() do
	if part:IsA("BasePart") then
		part.CanCollide = false part.CanTouch = false part.Massless = part ~= root
		if not coreSet[part] then
			local parentPart
			if part:IsDescendantOf(model.head) or part:IsDescendantOf(model.JawTeeth) or part.Name:find("Crest") then
				parentPart = skull
			elseif part.Name == "TailUndercoat" then parentPart = tail
			elseif part:IsDescendantOf(model.DorsalPlumage) then parentPart = root
			else parentPart = closestSkin(part.Position) end
			local weld = Instance.new("WeldConstraint")
			weld.Name = "RigDetailWeld" weld.Part0 = parentPart weld.Part1 = part weld.Parent = part
			welded[parentPart.Name] = (welded[parentPart.Name] or 0) + 1
		end
		part.Anchored = part == root
		n += 1
		if n % 50 == 0 then task.wait() end
	end
end
model.PrimaryPart = root
model:SetAttribute("ForwardInRoot", root.CFrame:VectorToObjectSpace(forward))
model:SetAttribute("WalkSpeed", 6)
model:SetAttribute("PreviewWalking", false)
model:SetAttribute("MovementReady", true)
model:SetAttribute("MovementStage", "SlowWalkPrototype_SegmentedLimbs")
model:SetAttribute("Stage", "HeadCleaned_WalkAndBitePreview")
model:SetAttribute("BitePreviewEnabled", false)
for _,name in {"WalkRequest", "ResetMotionRequest"} do
	local event = Instance.new("BindableEvent") event.Name = name event.Parent = model
end
return {root = root:GetFullName(), walkingJoints = 6, detailWelds = welded, parts = n}
