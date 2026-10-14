-- Client-only weapon cosmetics. No collision, hitboxes or damage.
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local VFX={}
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

local function fxPart(size: Vector3, cf: CFrame, col: Color3, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = "WeaponSkillVFX"
	p.Size = size
	p.CFrame = cf
	p.Color = col
	p.Material = Enum.Material.Neon
	if shape then
		p.Shape = shape
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Parent = workspace
	return p
end

function VFX.trigger(weaponId: string, baseCF: CFrame, markIndex: number)

	if weaponId == "Hammer" then
		-- Vòng xung kích đập đất (Shockwave Ring)
		local impactCF = baseCF * CFrame.new(0, 0.15, -3.2) * CFrame.Angles(0, 0, math.pi / 2)
		local ring = fxPart(Vector3.new(0.25, 1.2, 1.2), impactCF, NEON_TEAL, Enum.PartType.Cylinder)
		TweenService:Create(ring, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.05, 9.5, 9.5),
			Transparency = 1,
		}):Play()
		Debris:AddItem(ring, 0.5)

	elseif weaponId == "SwordShield" then
		-- Sóng kiếm vàng hiệp sĩ
		local slashCF = baseCF * CFrame.new(0, 2.2, -1.8) * CFrame.Angles(0, 0, math.rad(-15))
		local wave = fxPart(Vector3.new(0.2, 3.2, 0.8), slashCF, NEON_GOLD)
		TweenService:Create(wave, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = slashCF * CFrame.new(0, 0, -11),
			Size = Vector3.new(0.05, 4.5, 1.2),
			Transparency = 1,
		}):Play()
		Debris:AddItem(wave, 0.4)

	elseif weaponId == "Katana" then
		-- Kiếm khí bán nguyệt xanh băng
		local slashCF = baseCF * CFrame.new(0, 2.3, -1.8) * CFrame.Angles(0, 0, math.rad(-28))
		local wave = fxPart(Vector3.new(0.16, 3.8, 1.0), slashCF, NEON_CYAN)
		TweenService:Create(wave, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = slashCF * CFrame.new(0, 0, -14),
			Size = Vector3.new(0.04, 5.4, 1.5),
			Transparency = 1,
		}):Play()
		Debris:AddItem(wave, 0.35)

	elseif weaponId == "Glaive" then
		-- Mũi thương xung kích đâm thẳng (Sonic Thrust)
		local thrustCF = baseCF * CFrame.new(0, 2.3, -2.5)
		local spear = fxPart(Vector3.new(0.45, 0.45, 3.5), thrustCF, NEON_TEAL)
		TweenService:Create(spear, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			CFrame = thrustCF * CFrame.new(0, 0, -12),
			Size = Vector3.new(0.05, 0.05, 7.0),
			Transparency = 1,
		}):Play()
		Debris:AddItem(spear, 0.32)

	elseif weaponId == "DualDaggers" then
		-- Chém chéo chữ X tím (Nhịp 1 chéo phải, Nhịp 2 chéo trái)
		local angle = if markIndex == 1 then 40 else -40
		local slashCF = baseCF * CFrame.new(0, 2.2, -2.0) * CFrame.Angles(0, 0, math.rad(angle))
		local claw = fxPart(Vector3.new(0.14, 2.8, 0.45), slashCF, NEON_PURPLE)
		TweenService:Create(claw, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = slashCF * CFrame.new(0, 0, -7),
			Size = Vector3.new(0.04, 3.8, 0.8),
			Transparency = 1,
		}):Play()
		Debris:AddItem(claw, 0.3)

	elseif weaponId == "Bow" then
		-- Bắn mũi tên ánh sáng xanh lá bay vút đi
		local arrowCF = baseCF * CFrame.new(0, 2.4, -1.8)
		local arrow = fxPart(Vector3.new(0.18, 0.18, 2.6), arrowCF, NEON_GREEN)
		TweenService:Create(arrow, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
			CFrame = arrowCF * CFrame.new(0, 0, -24),
			Transparency = 1,
		}):Play()
		Debris:AddItem(arrow, 0.42)

	elseif weaponId == "GreatAxe" then
		-- Vết nứt dung nham bốc lửa dưới đất
		local crackCF = baseCF * CFrame.new(0, 0.2, -3.5)
		local crack = fxPart(Vector3.new(0.8, 0.4, 2.5), crackCF, NEON_FIRE)
		TweenService:Create(crack, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = crackCF * CFrame.new(0, 0.3, -3.5),
			Size = Vector3.new(2.2, 1.2, 8.5),
			Transparency = 1,
		}):Play()
		Debris:AddItem(crack, 0.5)
	end
end


function VFX.effects(root: Instance)
 local out={}
 for _,d in root:GetDescendants() do
  if (d:IsA("Trail") and d.Name=="WeaponTrail") or (d:IsA("ParticleEmitter") and d.Name=="WeaponSparks") then table.insert(out,d) end
 end
 return out
end
function VFX.set(effects,enabled: boolean)
 for _,d in effects do if d.Parent then d.Enabled=enabled end end
end
function VFX.burst(effects)
 for _,d in effects do if d.Parent and d:IsA("ParticleEmitter") then d:Emit(10) end end
end
return VFX

