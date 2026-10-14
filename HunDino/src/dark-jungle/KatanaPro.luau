-- Katana model and cosmetic effects adapted from the user's 15/10/2026 reference.

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

--------------------------------------------------------------------
-- PHẦN 1: MODULE TẠO MODEL KATANA CHI TIẾT & HIỆU ỨNG TRÊN KIẾM
--------------------------------------------------------------------
local KatanaPro = {}

local c = Color3.fromRGB
local WD_DARK   = c(35, 25, 22)    -- Gỗ mun đen (Cán kiếm)
local WRAP_RED  = c(185, 35, 45)   -- Dây quấn cán đỏ (Tsuka-maki)
local GOLD      = c(232, 183, 95)  -- Vàng kim (Tsuba, Habaki, Kashira)
local STEEL     = c(195, 210, 220) -- Thép sáng (Sống kiếm)
local EDGE_NEON = c(120, 245, 255) -- Ánh sáng xanh ngọc (Lưỡi kiếm & Hiệu ứng)

local function makePart(className: string, name: string, size: Vector3, color: Color3, mat: Enum.Material?): BasePart
	local p = Instance.new(className) :: BasePart
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	return p
end

function KatanaPro.buildMain(parent: Instance?): Model
	local model = Instance.new("Model")
	model.Name = "Main"

	local origin = CFrame.new()

	-- 1. Cán kiếm gốc (PrimaryPart)
	local handle = makePart("Part", "Handle", Vector3.new(0.2, 1.35, 0.26), WD_DARK)
	handle.CFrame = origin
	handle.Parent = model
	model.PrimaryPart = handle

	local function addPart(className: string, name: string, size: Vector3, offset: CFrame, color: Color3, mat: Enum.Material?)
		local p = makePart(className, name, size, color, mat)
		p.CFrame = origin * offset
		p.Parent = model
		local w = Instance.new("Weld")
		w.Part0 = handle
		w.Part1 = p
		w.C0 = offset
		w.Name = "KatanaWeld"
		w.Parent = p
		return p
	end

	-- 2. Đế cán kiếm (Kashira) & Vòng cổ cán (Fuchi)
	addPart("Part", "Kashira", Vector3.new(0.24, 0.12, 0.3), CFrame.new(0, -0.7, 0), GOLD, Enum.Material.Metal)
	addPart("Part", "Fuchi", Vector3.new(0.24, 0.1, 0.29), CFrame.new(0, 0.65, 0), GOLD, Enum.Material.Metal)

	-- 3. Dây quấn cán kiếm hình thoi (Tsuka-maki - 4 vòng đan chéo)
	for i = -2, 1 do
		local yPos = i * 0.28 + 0.1
		addPart("Part", "Wrap_" .. i, Vector3.new(0.23, 0.14, 0.28), CFrame.new(0, yPos, 0) * CFrame.Angles(0.35, 0, 0), WRAP_RED, Enum.Material.Fabric)
	end

	-- 4. Chắn tay (Tsuba) 2 lớp sang trọng + Khâu kiếm (Habaki)
	addPart("Part", "TsubaCore", Vector3.new(0.75, 0.1, 0.45), CFrame.new(0, 0.74, 0), WD_DARK, Enum.Material.Metal)
	addPart("Part", "TsubaRim", Vector3.new(0.85, 0.06, 0.52), CFrame.new(0, 0.74, 0), GOLD, Enum.Material.Metal)
	addPart("Part", "Habaki", Vector3.new(0.26, 0.28, 0.18), CFrame.new(0, 0.92, 0), GOLD, Enum.Material.Metal)

	-- 5. Thân lưỡi kiếm dưới (Thẳng từ chắn tay lên)
	addPart("Part", "BladeLower", Vector3.new(0.24, 1.9, 0.08), CFrame.new(0, 1.95, 0), STEEL, Enum.Material.Metal)
	addPart("Part", "EdgeLower", Vector3.new(0.05, 1.9, 0.09), CFrame.new(0.13, 1.95, 0), EDGE_NEON, Enum.Material.Neon)

	-- 6. Thân lưỡi kiếm trên (Hơi uốn cong về phía lưng kiếm -X để tạo dáng Katana)
	local upperOffset = CFrame.new(-0.08, 3.75, 0) * CFrame.Angles(0, 0, 0.08)
	addPart("Part", "BladeUpper", Vector3.new(0.22, 1.8, 0.075), upperOffset, STEEL, Enum.Material.Metal)
	addPart("Part", "EdgeUpper", Vector3.new(0.05, 1.8, 0.085), upperOffset * CFrame.new(0.12, 0, 0), EDGE_NEON, Enum.Material.Neon)

	-- 7. Mũi kiếm vát nhọn (Kissaki dùng WedgePart)
	local tipOffset = upperOffset * CFrame.new(0.01, 1.15, 0) * CFrame.Angles(0, math.pi / 2, 0)
	local tip = addPart("WedgePart", "BladeTip", Vector3.new(0.075, 0.55, 0.24), tipOffset, STEEL, Enum.Material.Metal)
	addPart("WedgePart", "EdgeTip", Vector3.new(0.085, 0.55, 0.06), tipOffset * CFrame.new(0, 0, -0.11), EDGE_NEON, Enum.Material.Neon)

	-- 8. Gắn Trail (Vệt sáng khi vung kiếm) & Particle (Tia sáng)
	local attBase = Instance.new("Attachment")
	attBase.Name = "TrailBase"
	attBase.Position = Vector3.new(0.12, 0.9, 0)
	attBase.Parent = handle

	local attTip = Instance.new("Attachment")
	attTip.Name = "TrailTip"
	attTip.Position = Vector3.new(-0.15, 4.9, 0)
	attTip.Parent = handle

	local trail = Instance.new("Trail")
	trail.Name = "SlashTrail"
	trail.Attachment0 = attBase
	trail.Attachment1 = attTip
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, EDGE_NEON),
		ColorSequenceKeypoint.new(0.6, c(40, 160, 255)),
		ColorSequenceKeypoint.new(1, c(255, 255, 255)),
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Lifetime = 0.22
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Enabled = false -- Chỉ bật khi bắt đầu chém
	trail.Parent = handle

	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "SlashSparks"
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new(EDGE_NEON, GOLD)
	sparks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.18),
		NumberSequenceKeypoint.new(1, 0),
	})
	sparks.Transparency = NumberSequence.new(0, 1)
	sparks.Lifetime = NumberRange.new(0.2, 0.45)
	sparks.Speed = NumberRange.new(4, 10)
	sparks.SpreadAngle = Vector2.new(60, 60)
	sparks.LightEmission = 1
	sparks.Rate = 45
	sparks.Enabled = false
	sparks.Parent = tip

	if parent then
		model.Parent = parent
	end
	return model
end


-- Cosmetic only: no hitbox, damage, physics or remote requests.
function KatanaPro.spawnSlashWave(rootCF: CFrame, height: number?)
	local waveModel = Instance.new("Model")
	waveModel.Name = "KatanaSlashWave"
	local startCF = rootCF * CFrame.new(0, height or 2.3, -1.8) * CFrame.Angles(0, 0, math.rad(-25))
	local core = makePart("Part", "WaveCore", Vector3.new(0.18, 3.6, 0.9), EDGE_NEON, Enum.Material.Neon)
	core.Anchored = true
	core.CFrame = startCF
	core.Parent = waveModel
	local light = Instance.new("PointLight")
	light.Color, light.Brightness, light.Range = EDGE_NEON, 3, 10
	light.Parent = core
	waveModel.Parent = workspace
	local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(core, tweenInfo, {
		CFrame = startCF * CFrame.new(0, 0, -14),
		Size = Vector3.new(0.05, 5.2, 1.4),
		Transparency = 1,
	}):Play()
	TweenService:Create(light, tweenInfo, {Brightness = 0}):Play()
	Debris:AddItem(waveModel, 0.4)
	return waveModel
end

function KatanaPro.effects(weapon: Instance)
	local out = {}
	for _,item in weapon:GetDescendants() do
		if (item:IsA("Trail") and item.Name == "SlashTrail")
			or (item:IsA("ParticleEmitter") and item.Name == "SlashSparks") then
			table.insert(out, item)
		end
	end
	return out
end

function KatanaPro.setEffects(effects, enabled: boolean)
	for _,effect in effects do
		if effect.Parent then effect.Enabled = enabled end
	end
end

function KatanaPro.burst(effects)
	for _,effect in effects do
		if effect.Parent and effect:IsA("ParticleEmitter") then effect:Emit(10) end
	end
end

return KatanaPro

