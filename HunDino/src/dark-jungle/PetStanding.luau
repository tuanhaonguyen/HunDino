-- Pet đứng hai chân (bản mẫu). ModuleScript độc lập: chưa gắn vào Training.server.luau.
-- Đơn vị studs, mặt trước là -Z. Gốc mô hình (Root) nằm ở mặt đất.
-- Đặt vào ServerStorage hoặc ReplicatedStorage rồi require thử, xem ví dụ ở cuối file.
local PetStanding = {}

local c = Color3.fromRGB
local TEAL, DARK, CREAM, GOLD = c(73, 150, 124), c(48, 108, 90), c(226, 208, 160), c(232, 183, 95)
local BROWN, WHITE, BLACK, PINK, PLATE = c(123, 83, 46), c(245, 245, 240), c(22, 28, 26), c(160, 86, 80), c(110, 135, 140)

-- Khớp: tên = {cha, vị trí khớp trong hệ toạ độ của cha}
local BONES = {
	{ "Torso", "Root", Vector3.new(0, 2.4, 0) },
	{ "Tail1", "Torso", Vector3.new(0, -0.6, 0.5) },
	{ "Tail2", "Tail1", Vector3.new(0, 0, 1.2) },
	{ "Head", "Torso", Vector3.new(0, 1.15, -0.25) },
	{ "ArmR", "Torso", Vector3.new(0.85, 0.55, -0.1) },
	{ "ForeR", "ArmR", Vector3.new(0, -0.5, 0) },
	{ "GripR", "ForeR", Vector3.new(0, -0.5, -0.05) },
	{ "ArmL", "Torso", Vector3.new(-0.85, 0.55, -0.1) },
	{ "ForeL", "ArmL", Vector3.new(0, -0.5, 0) },
	{ "GripL", "ForeL", Vector3.new(0, -0.5, -0.05) },
	{ "LegR", "Root", Vector3.new(0.5, 1.5, 0) },
	{ "LegL", "Root", Vector3.new(-0.5, 1.5, 0) },
}

-- Khối: {khớp, kích thước, vị trí so với khớp, màu, xoay (rx, ry, rz) hoặc nil, nhóm hoặc nil}
local PARTS = {}
local function add(bone, size, pos, color, rot, slot)
	table.insert(PARTS, { bone, size, pos, color, rot, slot })
end

-- Thân
add("Torso", Vector3.new(1.4, 1.7, 1.1), Vector3.new(0, 0, 0), TEAL)
add("Torso", Vector3.new(1.1, 1.2, 0.2), Vector3.new(0, -0.1, -0.55), CREAM)
for _, y in { 0.35, -0.35 } do
	add("Torso", Vector3.new(1.44, 0.22, 1.14), Vector3.new(0, y, 0), DARK)
end
-- Đuôi
add("Tail1", Vector3.new(0.8, 0.7, 1.2), Vector3.new(0, 0, 0.6), TEAL)
add("Tail1", Vector3.new(0.2, 0.34, 0.26), Vector3.new(0, 0.5, 0.6), GOLD)
add("Tail2", Vector3.new(0.55, 0.5, 1), Vector3.new(0, 0, 0.5), DARK)
add("Tail2", Vector3.new(0.3, 0.3, 0.4), Vector3.new(0, 0, 1.1), GOLD)
-- Đầu
add("Head", Vector3.new(1.3, 1.1, 1.25), Vector3.new(0, 0, 0), TEAL)
add("Head", Vector3.new(1, 0.5, 0.8), Vector3.new(0, -0.2, -0.9), TEAL)
add("Head", Vector3.new(0.9, 0.2, 0.8), Vector3.new(0, -0.5, -0.8), PINK)
add("Head", Vector3.new(0.26, 0.2, 0.26), Vector3.new(0, 0.1, -1.25), GOLD)
for _, x in { -1, 1 } do
	add("Head", Vector3.new(0.1, 0.14, 0.1), Vector3.new(x * 0.3, -0.36, -1.18), CREAM)
	add("Head", Vector3.new(0.1, 0.38, 0.38), Vector3.new(x * 0.66, 0.18, -0.2), WHITE)
	add("Head", Vector3.new(0.09, 0.2, 0.2), Vector3.new(x * 0.7, 0.18, -0.25), BLACK)
	add("Head", Vector3.new(0.2, 0.45, 0.2), Vector3.new(x * 0.4, 0.72, 0.05), CREAM, { -0.25, 0, x * 0.2 }, "Horns")
end
-- Tay
for _, side in { { "R", 1 }, { "L", -1 } } do
	local s, x = side[1], side[2]
	add("Arm" .. s, Vector3.new(0.35, 0.55, 0.4), Vector3.new(0, -0.25, 0), TEAL)
	add("Fore" .. s, Vector3.new(0.3, 0.5, 0.35), Vector3.new(0, -0.22, -0.05), DARK)
	add("Fore" .. s, Vector3.new(0.4, 0.3, 0.4), Vector3.new(0, -0.5, -0.05), CREAM)
	add("Fore" .. s, Vector3.new(0.34, 0.14, 0.12), Vector3.new(0, -0.55, -0.3), GOLD)
	-- Giáp vai
	add("Arm" .. s, Vector3.new(0.75, 0.28, 0.75), Vector3.new(x * 0.1, 0.12, 0), PLATE, nil, "Armor")
	add("Arm" .. s, Vector3.new(0.78, 0.07, 0.78), Vector3.new(x * 0.1, 0.28, 0), GOLD, nil, "Armor")
end
-- Chân
for _, s in { "R", "L" } do
	add("Leg" .. s, Vector3.new(0.55, 0.8, 0.65), Vector3.new(0, -0.3, 0), TEAL)
	add("Leg" .. s, Vector3.new(0.4, 0.6, 0.45), Vector3.new(0, -0.85, 0.1), DARK)
	add("Leg" .. s, Vector3.new(0.55, 0.2, 0.9), Vector3.new(0, -1.4, -0.15), CREAM)
	for _, d in { -0.17, 0, 0.17 } do
		add("Leg" .. s, Vector3.new(0.12, 0.12, 0.18), Vector3.new(d, -1.43, -0.62), GOLD)
	end
end
-- Mũ
add("Head", Vector3.new(1.45, 0.4, 1.4), Vector3.new(0, 0.68, 0), PLATE, nil, "Helmet")
add("Head", Vector3.new(1.5, 0.2, 1.45), Vector3.new(0, 0.45, 0), GOLD, nil, "Helmet")
add("Head", Vector3.new(0.14, 0.5, 0.1), Vector3.new(0, 0.1, -0.68), PLATE, nil, "Helmet")
add("Head", Vector3.new(0.2, 0.5, 1), Vector3.new(0, 1, 0), TEAL, nil, "Helmet")
for _, x in { -1, 1 } do
	add("Head", Vector3.new(0.12, 0.5, 0.5), Vector3.new(x * 0.72, 0.05, -0.05), PLATE, nil, "Helmet")
	add("Head", Vector3.new(0.2, 0.5, 0.2), Vector3.new(x * 0.55, 0.98, -0.05), GOLD, { 0, 0, -x * 0.45 }, "Helmet")
end
-- Giáp thân
add("Torso", Vector3.new(1.5, 1.15, 0.3), Vector3.new(0, 0.25, -0.62), PLATE, nil, "Armor")
for _, y in { 0.82, -0.3 } do
	add("Torso", Vector3.new(1.55, 0.12, 0.34), Vector3.new(0, y, -0.62), GOLD, nil, "Armor")
end
add("Torso", Vector3.new(1.45, 1.1, 0.2), Vector3.new(0, 0.2, 0.6), PLATE, nil, "Armor")
add("Torso", Vector3.new(1.5, 0.2, 1.2), Vector3.new(0, -0.72, 0), BROWN, nil, "Armor")
add("Torso", Vector3.new(0.3, 0.3, 0.1), Vector3.new(0, -0.72, -0.62), GOLD, nil, "Armor")

local function basePart(name, size, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	return p
end

-- Trả về (model, rig). rig.Motors[tên khớp] để sau này đặt Transform làm hoạt ảnh.
function PetStanding.build(parent: Instance?)
	local model = Instance.new("Model")
	model.Name = "PetStanding"

	local bones: { [string]: BasePart } = {}
	local worlds: { [string]: CFrame } = {}
	local motors: { [string]: Motor6D } = {}

	-- Root: khớp gốc cố định, neo; mọi khối khác nối vào nó nên PivotTo cả mô hình vẫn đúng.
	local root = basePart("Root", Vector3.new(0.2, 0.2, 0.2), WHITE)
	root.Transparency = 1
	root.Anchored = true
	root.CFrame = CFrame.new()
	root.Parent = model
	model.PrimaryPart = root
	bones.Root, worlds.Root = root, CFrame.new()

	for _, def in BONES do
		local name, parentName, offset = def[1], def[2], def[3]
		local part = basePart(name, Vector3.new(0.2, 0.2, 0.2), WHITE)
		part.Transparency = 1
		local world = worlds[parentName] * CFrame.new(offset)
		part.CFrame = world
		part.Parent = model
		local motor = Instance.new("Motor6D")
		motor.Name = name
		motor.Part0 = bones[parentName]
		motor.Part1 = part
		motor.C0 = CFrame.new(offset)
		motor.C1 = CFrame.new()
		motor.Parent = bones[parentName]
		bones[name], worlds[name], motors[name] = part, world, motor
	end

	local slots: { [string]: { BasePart } } = { Helmet = {}, Armor = {}, Horns = {} }
	for i, def in PARTS do
		local bone, size, pos, color, rot, slot = def[1], def[2], def[3], def[4], def[5], def[6]
		local part = basePart(bone .. "_" .. i, size, color)
		local offset = CFrame.new(pos)
		if rot then
			offset = offset * CFrame.Angles(rot[1], rot[2], rot[3])
		end
		part.CFrame = worlds[bone] * offset
		local weld = Instance.new("Weld")
		weld.Part0 = bones[bone]
		weld.Part1 = part
		weld.C0 = offset
		weld.Parent = part
		part.Parent = model
		if slot then
			part:SetAttribute("Slot", slot)
			table.insert(slots[slot], part)
		end
	end

	local rig = { Motors = motors, Bones = bones, Slots = slots, Grips = { R = bones.GripR, L = bones.GripL } }
	PetStanding.setHelmet(rig, true)
	PetStanding.setArmor(rig, true)
	if parent then
		model.Parent = parent
	end
	return model, rig
end

-- Resolve the replicated rig without creating another pet on the client.
function PetStanding.bind(model: Model)
	local bones, motors = {}, {}
	local root = model:FindFirstChild("Root")
	if not root or not root:IsA("BasePart") then return nil end
	bones.Root = root
	for _, def in BONES do
		local bone = model:FindFirstChild(def[1])
		local parent = bones[def[2]]
		local motor = parent and parent:FindFirstChild(def[1])
		if not bone or not bone:IsA("BasePart") or not motor or not motor:IsA("Motor6D") then
			return nil
		end
		bones[def[1]], motors[def[1]] = bone, motor
	end
	local slots = { Helmet = {}, Armor = {}, Horns = {} }
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			local slot = part:GetAttribute("Slot")
			if slot and slots[slot] then table.insert(slots[slot], part) end
		end
	end
	return { Motors = motors, Bones = bones, Slots = slots, Grips = { R = bones.GripR, L = bones.GripL } }
end

-- Ẩn bằng Transparency để khớp nối không bị tháo ra.
local function show(parts: { BasePart }, on: boolean)
	for _, p in parts do
		p.Transparency = if on then 0 else 1
	end
end
-- Khi có mũ thì ẩn sừng tự nhiên của pet để khỏi xuyên qua mũ.
function PetStanding.setHelmet(rig, on: boolean)
	show(rig.Slots.Helmet, on)
	show(rig.Slots.Horns, not on)
end
function PetStanding.setArmor(rig, on: boolean)
	show(rig.Slots.Armor, on)
end

return PetStanding

--[[ Thử nhanh trong Studio (thanh lệnh, khi đang không Play):
local mod = require(game.ServerStorage.PetStanding)
local pet, rig = mod.build(workspace)
pet:PivotTo(CFrame.new(0, 0.1, 0) * CFrame.Angles(0, math.pi, 0))
rig.Motors.ArmR.Transform = CFrame.Angles(0.7, 0, 0)  -- thử xoay tay phải
mod.setHelmet(rig, false)                             -- tháo mũ
]]
