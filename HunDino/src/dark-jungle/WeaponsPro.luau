local WeaponsBuilder = {}

local c = Color3.fromRGB
local WD    = c(70, 45, 31)     -- Gỗ cán vũ khí
local WD_DK = c(38, 26, 20)     -- Gỗ mun tối
local GD    = c(215, 165, 75)   -- Vàng đồng / Vàng kim
local ST    = c(185, 205, 215)  -- Thép sáng
local ST_DK = c(100, 115, 125)  -- Thép tối

-- Màu năng lượng đặc trưng cho từng vũ khí
local NEON_TEAL   = c(66, 235, 215)  -- Hammer & Glaive
local NEON_CYAN   = c(110, 240, 255) -- Katana
local NEON_GOLD   = c(255, 215, 90)  -- SwordShield
local NEON_PURPLE = c(215, 85, 255)  -- DualDaggers
local NEON_GREEN  = c(115, 255, 140) -- Bow
local NEON_FIRE   = c(255, 110, 40)  -- GreatAxe

local function createModel(name: string)
	local m = Instance.new("Model")
	m.Name = name
	local origin = CFrame.new()
	local handle: BasePart? = nil

	local function add(className: string, pName: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?)
		local p = Instance.new(className) :: BasePart
		p.Name = pName
		p.Size = size
		p.Color = color
		p.Material = mat or Enum.Material.SmoothPlastic
		if shape and p:IsA("Part") then
			p.Shape = shape
		end
		p.Anchored = false
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Massless = true
		p.CFrame = origin * cf
		p.Parent = m

		if not handle then
			handle = p
			m.PrimaryPart = p
		else
			local w = Instance.new("Weld")
			w.Name = "WeaponProWeld"
			w.Part0 = handle
			w.Part1 = p
			w.C0 = cf
			w.Parent = p
		end
		return p
	end

	local function addTrail(pos0: Vector3, pos1: Vector3, col: Color3)
		if not handle then return end
		local a0 = Instance.new("Attachment")
		a0.Name = "Trail0"
		a0.Position = pos0
		a0.Parent = handle

		local a1 = Instance.new("Attachment")
		a1.Name = "Trail1"
		a1.Position = pos1
		a1.Parent = handle

		local tr = Instance.new("Trail")
		tr.Name = "WeaponTrail"
		tr.Attachment0 = a0
		tr.Attachment1 = a1
		tr.Color = ColorSequence.new(col, c(255, 255, 255))
		tr.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.6, 0.45),
			NumberSequenceKeypoint.new(1, 1),
		})
		tr.Lifetime = 0.22
		tr.LightEmission = 1
		tr.FaceCamera = true
		tr.Enabled = false
		tr.Parent = handle

		local pe = Instance.new("ParticleEmitter")
		pe.Name = "WeaponSparks"
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Color = ColorSequence.new(col)
		pe.Size = NumberSequence.new(0.16, 0)
		pe.Transparency = NumberSequence.new(0, 1)
		pe.Lifetime = NumberRange.new(0.2, 0.4)
		pe.Speed = NumberRange.new(3, 8)
		pe.SpreadAngle = Vector2.new(55, 55)
		pe.LightEmission = 1
		pe.Rate = 35
		pe.Enabled = false
		pe.Parent = a1
	end

	return m, add, addTrail
end

-- 1. HAMMER (Búa tạ cổ ngữ)
function WeaponsBuilder.Hammer(parent: Instance)
	local f = Instance.new("Model")
	f.Name = "Hammer"
	local m, add, addTrail = createModel("Main")

	add("Part", "Handle", Vector3.new(0.24, 3.4, 0.24), CFrame.new(0, 0, 0), WD, Enum.Material.Wood)
	add("Part", "Pommel", Vector3.new(0.36, 0.22, 0.36), CFrame.new(0, -1.7, 0), GD, Enum.Material.Metal)
	for _, y in { -0.8, 0, 0.8 } do
		add("Part", "GripRing", Vector3.new(0.28, 0.1, 0.28), CFrame.new(0, y, 0), GD, Enum.Material.Metal)
	end
	-- Đầu búa khổng lồ
	add("Part", "HeadCore", Vector3.new(3.0, 1.65, 1.55), CFrame.new(0, 2.0, 0), ST_DK, Enum.Material.Metal)
	add("Part", "TopSpike", Vector3.new(0.32, 0.45, 0.32), CFrame.new(0, 2.95, 0), GD, Enum.Material.Metal)
	for _, s in { -1, 1 } do
		add("Part", "FaceTrim", Vector3.new(0.24, 1.85, 1.75), CFrame.new(s * 1.35, 2.0, 0), GD, Enum.Material.Metal)
		add("Part", "StrikePlate", Vector3.new(0.14, 1.6, 1.5), CFrame.new(s * 1.5, 2.0, 0), ST, Enum.Material.Metal)
	end
	-- Ngọc cổ ngữ phát sáng 2 mặt
	for _, z in { -0.8, 0.8 } do
		add("Part", "RuneGem", Vector3.new(0.55, 0.75, 0.08), CFrame.new(0, 2.0, z), NEON_TEAL, Enum.Material.Neon)
	end
	addTrail(Vector3.new(-1.5, 2.0, 0), Vector3.new(1.5, 2.0, 0), NEON_TEAL)
	m.Parent = f
	f.Parent = parent
end

-- 2. SWORD & SHIELD (Kiếm & Khiên hiệp sĩ)
function WeaponsBuilder.SwordShield(parent: Instance)
	local f = Instance.new("Model")
	f.Name = "SwordShield"

	-- Kiếm (Main - Tay phải)
	local mR, addR, trailR = createModel("Main")
	addR("Part", "Handle", Vector3.new(0.22, 1.3, 0.22), CFrame.new(0, 0, 0), WD_DK)
	addR("Part", "Pommel", Vector3.new(0.38, 0.28, 0.38), CFrame.new(0, -0.72, 0), GD, Enum.Material.Metal)
	addR("Part", "Guard", Vector3.new(1.45, 0.18, 0.34), CFrame.new(0, 0.7, 0), GD, Enum.Material.Metal)
	addR("Part", "GuardGem", Vector3.new(0.26, 0.26, 0.38), CFrame.new(0, 0.7, 0), NEON_GOLD, Enum.Material.Neon)
	addR("Part", "BladeCore", Vector3.new(0.38, 2.4, 0.12), CFrame.new(0, 2.0, 0), ST, Enum.Material.Metal)
	addR("Part", "BladeEdgeR", Vector3.new(0.08, 2.4, 0.14), CFrame.new(0.22, 2.0, 0), NEON_GOLD, Enum.Material.Neon)
	addR("Part", "BladeEdgeL", Vector3.new(0.08, 2.4, 0.14), CFrame.new(-0.22, 2.0, 0), ST, Enum.Material.Metal)
	addR("WedgePart", "TipR", Vector3.new(0.14, 0.55, 0.26), CFrame.new(0.12, 3.47, 0) * CFrame.Angles(0, math.pi / 2, 0), NEON_GOLD, Enum.Material.Neon)
	addR("WedgePart", "TipL", Vector3.new(0.14, 0.55, 0.26), CFrame.new(-0.12, 3.47, 0) * CFrame.Angles(0, -math.pi / 2, 0), ST, Enum.Material.Metal)
	trailR(Vector3.new(0, 0.8, 0), Vector3.new(0, 3.7, 0), NEON_GOLD)
	mR.Parent = f

	-- Khiên (Offhand - Tay trái)
	local mL, addL = createModel("Offhand")
	addL("Part", "Handle", Vector3.new(0.24, 0.5, 0.24), CFrame.new(0, 0, 0), WD_DK)
	local cylRot = CFrame.Angles(0, 0, math.pi / 2) * CFrame.Angles(0, math.pi / 2, 0)
	addL("Part", "ShieldRim", Vector3.new(0.2, 2.5, 2.5), CFrame.new(0, 0.3, -0.3) * cylRot, GD, Enum.Material.Metal, Enum.PartType.Cylinder)
	addL("Part", "ShieldFace", Vector3.new(0.24, 2.15, 2.15), CFrame.new(0, 0.3, -0.32) * cylRot, ST_DK, Enum.Material.Metal, Enum.PartType.Cylinder)
	addL("Part", "ShieldBoss", Vector3.new(0.55, 0.55, 0.35), CFrame.new(0, 0.3, -0.52), GD, Enum.Material.Metal)
	addL("Part", "ShieldCore", Vector3.new(0.25, 0.75, 0.12), CFrame.new(0, 0.3, -0.66), NEON_GOLD, Enum.Material.Neon)
	mL.Parent = f

	f.Parent = parent
end

-- 3. KATANA (Nhật đao uốn cong)
function WeaponsBuilder.Katana(parent: Instance)
	local f = Instance.new("Model")
	f.Name = "Katana"
	local m, add, addTrail = createModel("Main")

	add("Part", "Handle", Vector3.new(0.2, 1.35, 0.26), CFrame.new(0, 0, 0), WD_DK)
	add("Part", "Kashira", Vector3.new(0.24, 0.12, 0.3), CFrame.new(0, -0.7, 0), GD, Enum.Material.Metal)
	for i = -2, 1 do
		add("Part", "Wrap", Vector3.new(0.23, 0.14, 0.28), CFrame.new(0, i * 0.28 + 0.1, 0) * CFrame.Angles(0.35, 0, 0), c(185, 35, 45), Enum.Material.Fabric)
	end
	add("Part", "Tsuba", Vector3.new(0.85, 0.12, 0.5), CFrame.new(0, 0.72, 0), GD, Enum.Material.Metal)
	add("Part", "Habaki", Vector3.new(0.26, 0.26, 0.18), CFrame.new(0, 0.9, 0), GD, Enum.Material.Metal)
	add("Part", "BladeLower", Vector3.new(0.24, 1.9, 0.08), CFrame.new(0, 1.95, 0), ST, Enum.Material.Metal)
	add("Part", "EdgeLower", Vector3.new(0.05, 1.9, 0.09), CFrame.new(0.13, 1.95, 0), NEON_CYAN, Enum.Material.Neon)

	local upCF = CFrame.new(-0.08, 3.75, 0) * CFrame.Angles(0, 0, 0.08)
	add("Part", "BladeUpper", Vector3.new(0.22, 1.8, 0.075), upCF, ST, Enum.Material.Metal)
	add("Part", "EdgeUpper", Vector3.new(0.05, 1.8, 0.085), upCF * CFrame.new(0.12, 0, 0), NEON_CYAN, Enum.Material.Neon)

	local tipCF = upCF * CFrame.new(0.02, 1.15, 0) * CFrame.Angles(0, math.pi / 2, 0)
	add("WedgePart", "Tip", Vector3.new(0.08, 0.55, 0.24), tipCF, NEON_CYAN, Enum.Material.Neon)

	addTrail(Vector3.new(0.12, 0.9, 0), Vector3.new(-0.15, 4.9, 0), NEON_CYAN)
	m.Parent = f
	f.Parent = parent
end

-- 4. GLAIVE (Thương cán dài Thanh Long)
function WeaponsBuilder.Glaive(parent: Instance)
	local f = Instance.new("Model")
	f.Name = "Glaive"
	local m, add, addTrail = createModel("Main")

	add("Part", "Handle", Vector3.new(0.24, 6.4, 0.24), CFrame.new(0, 0, 0), WD, Enum.Material.Wood)
	add("Part", "ButtSpike", Vector3.new(0.32, 0.45, 0.32), CFrame.new(0, -3.3, 0), GD, Enum.Material.Metal)
	add("Part", "Collar", Vector3.new(0.52, 0.55, 0.42), CFrame.new(0, 3.2, 0), GD, Enum.Material.Metal)
	add("Part", "Tassel", Vector3.new(0.35, 1.6, 0.14), CFrame.new(-0.42, 2.55, 0) * CFrame.Angles(0, 0, 0.2), NEON_TEAL, Enum.Material.Neon)
	-- Lưỡi thương lớn
	add("Part", "BladeBody", Vector3.new(0.65, 2.2, 0.12), CFrame.new(0.22, 4.4, 0), ST, Enum.Material.Metal)
	add("Part", "BladeEdge", Vector3.new(0.1, 2.2, 0.14), CFrame.new(0.58, 4.4, 0), NEON_TEAL, Enum.Material.Neon)
	add("WedgePart", "BladeTip", Vector3.new(0.14, 0.85, 0.75), CFrame.new(0.26, 5.92, 0) * CFrame.Angles(0, math.pi / 2, 0), NEON_TEAL, Enum.Material.Neon)

	addTrail(Vector3.new(0.5, 3.3, 0), Vector3.new(0.4, 6.3, 0), NEON_TEAL)
	m.Parent = f
	f.Parent = parent
end

-- 5. DUAL DAGGERS (Song dao sát thủ)
function WeaponsBuilder.DualDaggers(parent: Instance)
	local f = Instance.new("Model")
	f.Name = "DualDaggers"

	for _, subName in { "Main", "Offhand" } do
		local m, add, addTrail = createModel(subName)
		add("Part", "Handle", Vector3.new(0.22, 1.25, 0.22), CFrame.new(0, 0, 0), WD_DK)
		add("Part", "PommelRing", Vector3.new(0.34, 0.16, 0.34), CFrame.new(0, -0.68, 0), GD, Enum.Material.Metal)
		add("Part", "Guard", Vector3.new(0.88, 0.15, 0.3), CFrame.new(0, 0.55, 0) * CFrame.Angles(0, 0, 0.15), GD, Enum.Material.Metal)
		add("Part", "BladeBody", Vector3.new(0.34, 1.35, 0.1), CFrame.new(0, 1.3, 0), ST_DK, Enum.Material.Metal)
		add("Part", "BladeEdge", Vector3.new(0.08, 1.35, 0.12), CFrame.new(0.18, 1.3, 0), NEON_PURPLE, Enum.Material.Neon)
		add("WedgePart", "Tip", Vector3.new(0.12, 0.5, 0.42), CFrame.new(0.02, 2.22, 0) * CFrame.Angles(0, math.pi / 2, 0), NEON_PURPLE, Enum.Material.Neon)

		addTrail(Vector3.new(0, 0.6, 0), Vector3.new(0, 2.45, 0), NEON_PURPLE)
		m.Parent = f
	end

	f.Parent = parent
end

-- 6. BOW (Cung thần rừng xanh)
function WeaponsBuilder.Bow(parent: Instance)
	local f = Instance.new("Model")
	f.Name = "Bow"
	local m, add, addTrail = createModel("Main")

	add("Part", "Handle", Vector3.new(0.24, 1.3, 0.26), CFrame.new(0, 0, 0), WD)
	add("Part", "SightGem", Vector3.new(0.3, 0.35, 0.32), CFrame.new(0, 0, 0), GD, Enum.Material.Metal)
	for _, s in { -1, 1 } do
		for j = 0, 3 do
			local cf = CFrame.new(0.35 * j, s * (0.7 + j * 0.55), 0) * CFrame.Angles(0, 0, -s * 0.5)
			local col = if j == 3 then GD else WD
			add("Part", "Limb_" .. s .. "_" .. j, Vector3.new(0.24, 0.82, 0.28), cf, col)
		end
	end
	-- Dây cung ánh sáng
	add("Part", "BowString", Vector3.new(0.05, 4.9, 0.05), CFrame.new(1.15, 0, 0), NEON_GREEN, Enum.Material.Neon)
	addTrail(Vector3.new(1.15, -2.2, 0), Vector3.new(1.15, 2.2, 0), NEON_GREEN)

	m.Parent = f
	f.Parent = parent
end

-- 7. GREAT AXE (Rìu đại hai lưỡi dung nham)
function WeaponsBuilder.GreatAxe(parent: Instance)
	local f = Instance.new("Model")
	f.Name = "GreatAxe"
	local m, add, addTrail = createModel("Main")

	add("Part", "Handle", Vector3.new(0.24, 3.4, 0.24), CFrame.new(0, 0, 0), WD_DK)
	add("Part", "CenterHub", Vector3.new(0.52, 1.85, 0.52), CFrame.new(0, 1.8, 0), GD, Enum.Material.Metal)
	add("WedgePart", "TopSpear", Vector3.new(0.2, 0.65, 0.36), CFrame.new(0, 3.05, 0), NEON_FIRE, Enum.Material.Neon)

	for _, s in { -1, 1 } do
		add("Part", "AxeBlade_" .. s, Vector3.new(1.45, 1.45, 0.26), CFrame.new(s * 0.85, 1.8, 0), ST_DK, Enum.Material.Metal)
		add("Part", "AxeEdge_" .. s, Vector3.new(0.22, 1.75, 0.32), CFrame.new(s * 1.6, 1.8, 0), NEON_FIRE, Enum.Material.Neon)
	end
	addTrail(Vector3.new(-1.7, 1.8, 0), Vector3.new(1.7, 1.8, 0), NEON_FIRE)

	m.Parent = f
	f.Parent = parent
end

local ORDER = {"Hammer","SwordShield","Katana","Glaive","DualDaggers","Bow","GreatAxe"}
WeaponsBuilder.Order = ORDER
function WeaponsBuilder.build(id: string)
 assert(table.find(ORDER,id), "Unknown weapon: "..id)
 local container=Instance.new("Folder")
 WeaponsBuilder[id](container)
 local model=container:FindFirstChild(id)
 model.PrimaryPart=model.Main.PrimaryPart
 model.Parent=nil
 container:Destroy()
 return model
end
return WeaponsBuilder

