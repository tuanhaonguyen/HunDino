-- Cosmetic training equipment. Each slot is independent for the player and pet.
local Armor={}
Armor.Slots={"Head","Chest","Arms","Waist","Legs"}
Armor.SlotNames={Head="Đầu",Chest="Thân",Arms="Tay",Waist="Eo",Legs="Chân"}
Armor.ItemNames={Head="Mũ",Chest="Giáp thân",Arms="Giáp tay",Waist="Đai giáp",Legs="Giáp chân"}
Armor.Order={"Training","Leather","Metal","Bone"}
Armor.Sets={
	Training={Name="Thợ săn",Color=Color3.fromRGB(92,71,48),Trim=Color3.fromRGB(68,106,98),Material=Enum.Material.SmoothPlastic},
	Leather={Name="Da",Color=Color3.fromRGB(124,79,47),Trim=Color3.fromRGB(221,169,93),Material=Enum.Material.Fabric},
	Metal={Name="Kim loại",Color=Color3.fromRGB(110,135,140),Trim=Color3.fromRGB(232,183,95),Material=Enum.Material.Metal},
	Bone={Name="Xương",Color=Color3.fromRGB(223,209,174),Trim=Color3.fromRGB(123,91,61),Material=Enum.Material.SmoothPlastic},
}
function Armor.valid(slot,id)
	return table.find(Armor.Slots,slot)~=nil and (id=="None" or Armor.Sets[id]~=nil)
end
function Armor.read(player,target)
	local out={}
	for _,slot in Armor.Slots do out[slot]=player:GetAttribute(target.."Armor_"..slot) or (if target=="Pet" then "Metal" else "Training") end
	return out
end
local function find(model,names)
	for _,name in names do local p=model:FindFirstChild(name);if p and p:IsA("BasePart") then return p end end
end

local c = Color3.fromRGB

-- 1. Bảng màu Giáp Thợ săn (Hunter)
local HNT_BRN   = c(86, 62, 44)
local HNT_DARK  = c(54, 38, 28)
local HNT_TEAL  = c(68, 148, 126)
local HNT_GOLD  = c(195, 155, 78)

-- 2. Bảng màu Giáp Da / Xích nhẹ (Leather / Chainmail)
local CHN_SILV  = c(145, 155, 165)
local LTH_MAIN  = c(128, 82, 45)
local LTH_DARK  = c(78, 48, 26)
local LTH_TAN   = c(205, 165, 105)

-- 3. Bảng màu Giáp Kim loại Hiệp sĩ (Metal / KnightPlate)
local MTL_LIGHT = c(195, 205, 212)
local MTL_DARK  = c(115, 132, 140)
local MTL_GOLD  = c(225, 180, 88)
local MTL_RED   = c(135, 32, 36)

-- 4. Bảng màu Giáp Xương Khủng Long (Bone / DinoBone)
local BNE_IVORY = c(236, 228, 202)
local BNE_AGED  = c(195, 180, 145)
local BNE_FANG  = c(250, 248, 242)
local BNE_ROPE  = c(115, 75, 52)
local BNE_GLOW  = c(255, 130, 45)

-- Cấu trúc mỗi mảnh: {khớp_xương, kích_thước, vị_trí, màu, xoay_rad, vật_liệu, className}
Armor.PetSets = {
	----------------------------------------------------------------
	-- BỘ 1: GIÁP THỢ SĂN (Hunter)
	----------------------------------------------------------------
	Hunter = {
		displayName = "Giáp Thợ săn",
		hideNaturalHorns = false,
		slots = {
			-- ĐẦU (Mũ thợ săn rừng sâu mở mặt, viền xanh ngọc)
			Head = {
				{ "Head", Vector3.new(1.44, 0.36, 1.38), Vector3.new(0, 0.64, 0.02), HNT_BRN, nil, Enum.Material.Leather },
				{ "Head", Vector3.new(1.48, 0.14, 1.42), Vector3.new(0, 0.44, 0.02), HNT_TEAL, nil, Enum.Material.Fabric },
				{ "Head", Vector3.new(0.24, 0.42, 1.15), Vector3.new(0, 0.90, 0.08), HNT_TEAL, nil, Enum.Material.Fabric },
				{ "Head", Vector3.new(0.14, 0.52, 0.48), Vector3.new(0.70, 0.08, 0.12), HNT_BRN, nil, Enum.Material.Leather },
				{ "Head", Vector3.new(0.14, 0.52, 0.48), Vector3.new(-0.70, 0.08, 0.12), HNT_BRN, nil, Enum.Material.Leather },
				{ "Head", Vector3.new(1.34, 0.48, 0.18), Vector3.new(0, 0.12, 0.60), HNT_DARK, nil, Enum.Material.Fabric },
			},
			-- THÂN (Giáp ngực da cứng kèm huy hiệu ngọc thợ săn)
			Chest = {
				{ "Torso", Vector3.new(1.50, 1.15, 0.28), Vector3.new(0, 0.24, -0.58), HNT_BRN, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(1.54, 0.12, 0.32), Vector3.new(0, 0.80, -0.58), HNT_TEAL, nil, Enum.Material.Fabric },
				{ "Torso", Vector3.new(0.32, 0.44, 0.14), Vector3.new(0, 0.22, -0.68), HNT_TEAL, nil, Enum.Material.Neon },
				{ "Torso", Vector3.new(1.46, 1.12, 0.22), Vector3.new(0, 0.22, 0.56), HNT_DARK, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.26, 1.35, 1.22), Vector3.new(-0.35, 0.20, 0), HNT_TEAL, { 0, 0, -0.35 }, Enum.Material.Fabric },
			},
			-- TAY (Giáp vai thợ săn viền ngọc + Băng cổ tay)
			Arms = {
				{ "ArmR", Vector3.new(0.74, 0.26, 0.74), Vector3.new(0.12, 0.12, 0), HNT_BRN, { 0, 0, -0.15 }, Enum.Material.Leather },
				{ "ArmR", Vector3.new(0.78, 0.08, 0.78), Vector3.new(0.12, 0.27, 0), HNT_TEAL, { 0, 0, -0.15 }, Enum.Material.Fabric },
				{ "ForeR", Vector3.new(0.38, 0.36, 0.42), Vector3.new(0, -0.22, -0.05), HNT_DARK, nil, Enum.Material.Leather },

				{ "ArmL", Vector3.new(0.74, 0.26, 0.74), Vector3.new(-0.12, 0.12, 0), HNT_BRN, { 0, 0, 0.15 }, Enum.Material.Leather },
				{ "ArmL", Vector3.new(0.78, 0.08, 0.78), Vector3.new(-0.12, 0.27, 0), HNT_TEAL, { 0, 0, 0.15 }, Enum.Material.Fabric },
				{ "ForeL", Vector3.new(0.38, 0.36, 0.42), Vector3.new(0, -0.22, -0.05), HNT_DARK, nil, Enum.Material.Leather },
			},
			-- EO (Đai lưng thợ săn + 2 tấm chắn hông đúng như icon cột Eo)
			Waist = {
				{ "Torso", Vector3.new(1.52, 0.22, 1.20), Vector3.new(0, -0.62, 0), HNT_DARK, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.34, 0.34, 0.14), Vector3.new(0, -0.62, -0.62), HNT_TEAL, nil, Enum.Material.Metal },
				{ "Torso", Vector3.new(0.54, 0.42, 0.16), Vector3.new(0.42, -0.78, -0.58), HNT_BRN, { -0.12, 0, 0 }, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.54, 0.42, 0.16), Vector3.new(-0.42, -0.78, -0.58), HNT_BRN, { -0.12, 0, 0 }, Enum.Material.Leather },
			},
			-- CHÂN (Giáp ống chân + Đệm gối ngọc đúng như icon cột Chân)
			Legs = {
				{ "LegR", Vector3.new(0.48, 0.52, 0.52), Vector3.new(0, -0.86, 0.08), HNT_BRN, nil, Enum.Material.Leather },
				{ "LegR", Vector3.new(0.50, 0.16, 0.22), Vector3.new(0, -0.60, -0.28), HNT_TEAL, nil, Enum.Material.Metal },
				{ "LegL", Vector3.new(0.48, 0.52, 0.52), Vector3.new(0, -0.86, 0.08), HNT_BRN, nil, Enum.Material.Leather },
				{ "LegL", Vector3.new(0.50, 0.16, 0.22), Vector3.new(0, -0.60, -0.28), HNT_TEAL, nil, Enum.Material.Metal },
			},
		},
	},

	----------------------------------------------------------------
	-- BỘ 2: GIÁP DA & XÍCH NHẸ (Leather / Chainmail)
	----------------------------------------------------------------
	Leather = {
		displayName = "Giáp Da",
		hideNaturalHorns = false,
		slots = {
			-- ĐẦU (Mũ trùm xích kết hợp mũ da thuộc viền vàng cát)
			Head = {
				{ "Head", Vector3.new(1.42, 0.34, 1.36), Vector3.new(0, 0.62, 0.02), LTH_MAIN, nil, Enum.Material.Leather },
				{ "Head", Vector3.new(1.46, 0.14, 1.40), Vector3.new(0, 0.44, 0.02), LTH_TAN, nil, Enum.Material.Leather },
				{ "Head", Vector3.new(1.36, 0.58, 0.24), Vector3.new(0, 0.08, 0.58), CHN_SILV, nil, Enum.Material.Cobblestone },
				{ "Head", Vector3.new(0.14, 0.52, 0.48), Vector3.new(0.68, 0.08, 0.15), LTH_MAIN, nil, Enum.Material.Leather },
				{ "Head", Vector3.new(0.14, 0.52, 0.48), Vector3.new(-0.68, 0.08, 0.15), LTH_MAIN, nil, Enum.Material.Leather },
			},
			-- THÂN (Áo lót lưới xích + Giáp ngực da thuộc đóng khóa đồng)
			Chest = {
				{ "Torso", Vector3.new(1.46, 1.32, 1.16), Vector3.new(0, 0.18, 0), CHN_SILV, nil, Enum.Material.Cobblestone },
				{ "Torso", Vector3.new(1.50, 1.12, 0.28), Vector3.new(0, 0.24, -0.58), LTH_MAIN, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(1.54, 0.12, 0.32), Vector3.new(0, 0.78, -0.58), LTH_TAN, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.32, 0.42, 0.14), Vector3.new(0, 0.22, -0.68), LTH_TAN, nil, Enum.Material.Metal },
				{ "Torso", Vector3.new(1.46, 1.10, 0.22), Vector3.new(0, 0.22, 0.56), LTH_MAIN, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.22, 1.45, 1.24), Vector3.new(0, 0.18, 0), LTH_DARK, { 0, 0, 0.48 }, Enum.Material.Leather },
			},
			-- TAY (Đệm vai xích bọc da + Băng bảo vệ cổ tay)
			Arms = {
				{ "ArmR", Vector3.new(0.46, 0.40, 0.48), Vector3.new(0, -0.10, 0), CHN_SILV, nil, Enum.Material.Cobblestone },
				{ "ArmR", Vector3.new(0.74, 0.26, 0.74), Vector3.new(0.12, 0.12, 0), LTH_MAIN, { 0, 0, -0.15 }, Enum.Material.Leather },
				{ "ArmR", Vector3.new(0.78, 0.08, 0.78), Vector3.new(0.12, 0.27, 0), LTH_TAN, { 0, 0, -0.15 }, Enum.Material.Leather },
				{ "ForeR", Vector3.new(0.38, 0.36, 0.42), Vector3.new(0, -0.22, -0.05), LTH_DARK, nil, Enum.Material.Leather },

				{ "ArmL", Vector3.new(0.46, 0.40, 0.48), Vector3.new(0, -0.10, 0), CHN_SILV, nil, Enum.Material.Cobblestone },
				{ "ArmL", Vector3.new(0.74, 0.26, 0.74), Vector3.new(-0.12, 0.12, 0), LTH_MAIN, { 0, 0, 0.15 }, Enum.Material.Leather },
				{ "ArmL", Vector3.new(0.78, 0.08, 0.78), Vector3.new(-0.12, 0.27, 0), LTH_TAN, { 0, 0, 0.15 }, Enum.Material.Leather },
				{ "ForeL", Vector3.new(0.38, 0.36, 0.42), Vector3.new(0, -0.22, -0.05), LTH_DARK, nil, Enum.Material.Leather },
			},
			-- EO (Thắt lưng da kèm túi hông + 2 tà da chắn đùi)
			Waist = {
				{ "Torso", Vector3.new(1.52, 0.22, 1.22), Vector3.new(0, -0.62, 0), LTH_DARK, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.34, 0.34, 0.14), Vector3.new(0, -0.62, -0.62), LTH_TAN, nil, Enum.Material.Metal },
				{ "Torso", Vector3.new(0.54, 0.42, 0.16), Vector3.new(0.42, -0.78, -0.58), LTH_MAIN, { -0.12, 0, 0 }, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.54, 0.42, 0.16), Vector3.new(-0.42, -0.78, -0.58), LTH_MAIN, { -0.12, 0, 0 }, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.20, 0.34, 0.36), Vector3.new(0.80, -0.62, -0.08), LTH_MAIN, nil, Enum.Material.Leather },
			},
			-- CHÂN (Giáp ống chân da thuộc + Đệm gối vàng cát)
			Legs = {
				{ "LegR", Vector3.new(0.48, 0.52, 0.52), Vector3.new(0, -0.86, 0.08), LTH_MAIN, nil, Enum.Material.Leather },
				{ "LegR", Vector3.new(0.50, 0.16, 0.22), Vector3.new(0, -0.60, -0.28), LTH_TAN, nil, Enum.Material.Leather },
				{ "LegL", Vector3.new(0.48, 0.52, 0.52), Vector3.new(0, -0.86, 0.08), LTH_MAIN, nil, Enum.Material.Leather },
				{ "LegL", Vector3.new(0.50, 0.16, 0.22), Vector3.new(0, -0.60, -0.28), LTH_TAN, nil, Enum.Material.Leather },
			},
		},
	},

	----------------------------------------------------------------
	-- BỘ 3: GIÁP KIM LOẠI HIỆP SĨ (Metal / KnightPlate - Theo Ảnh 1 & Ảnh UI)
	----------------------------------------------------------------
	Metal = {
		displayName = "Giáp Kim loại",
		hideNaturalHorns = true,
		slots = {
			-- ĐẦU (Mũ Hiệp Sĩ có sống mũ cao Crest + Visor lật mở trên trán + Ốp má, không che mặt)
			Head = {
				{ "Head", Vector3.new(1.46, 0.42, 1.40), Vector3.new(0, 0.66, 0.02), MTL_DARK, nil, Enum.Material.Metal },
				{ "Head", Vector3.new(1.50, 0.16, 1.44), Vector3.new(0, 0.45, 0.02), MTL_GOLD, nil, Enum.Material.Metal },
				{ "Head", Vector3.new(0.18, 0.44, 1.25), Vector3.new(0, 0.96, 0.05), MTL_LIGHT, nil, Enum.Material.Metal },
				{ "Head", Vector3.new(0.20, 0.10, 1.28), Vector3.new(0, 1.16, 0.05), MTL_GOLD, nil, Enum.Material.Metal },
				-- Kính che mặt lật lên trán + 2 tấm ốp má giống hệt hình xem trước "Mũ - Kim loại"
				{ "Head", Vector3.new(1.42, 0.22, 0.32), Vector3.new(0, 0.64, -0.62), MTL_LIGHT, { -0.42, 0, 0 }, Enum.Material.Metal },
				{ "Head", Vector3.new(0.14, 0.54, 0.52), Vector3.new(0.71, 0.06, 0.08), MTL_DARK, nil, Enum.Material.Metal },
				{ "Head", Vector3.new(0.14, 0.54, 0.52), Vector3.new(-0.71, 0.06, 0.08), MTL_DARK, nil, Enum.Material.Metal },
				{ "Head", Vector3.new(1.36, 0.52, 0.22), Vector3.new(0, 0.12, 0.60), MTL_DARK, { 0.12, 0, 0 }, Enum.Material.Metal },
			},
			-- THÂN (Giáp ngực hiệp sĩ sống nổi chữ V Peascod + Huy hiệu vàng giữa ngực)
			Chest = {
				{ "Torso", Vector3.new(1.32, 0.22, 1.16), Vector3.new(0, 0.82, 0), MTL_LIGHT, nil, Enum.Material.Metal },
				{ "Torso", Vector3.new(1.52, 1.15, 0.28), Vector3.new(0, 0.24, -0.58), MTL_DARK, nil, Enum.Material.Metal },
				{ "Torso", Vector3.new(1.56, 0.12, 0.32), Vector3.new(0, 0.80, -0.58), MTL_GOLD, nil, Enum.Material.Metal },
				-- Hai mặt vát chéo tạo khối ngực hiệp sĩ Châu Âu (Ảnh 1)
				{ "Torso", Vector3.new(0.76, 1.10, 0.22), Vector3.new(0.32, 0.24, -0.64), MTL_LIGHT, { 0, 0.24, 0 }, Enum.Material.Metal },
				{ "Torso", Vector3.new(0.76, 1.10, 0.22), Vector3.new(-0.32, 0.24, -0.64), MTL_LIGHT, { 0, -0.24, 0 }, Enum.Material.Metal },
				{ "Torso", Vector3.new(0.32, 0.44, 0.16), Vector3.new(0, 0.22, -0.72), MTL_GOLD, nil, Enum.Material.Metal },
				{ "Torso", Vector3.new(1.48, 1.12, 0.22), Vector3.new(0, 0.22, 0.58), MTL_DARK, nil, Enum.Material.Metal },
			},
			-- TAY (Cầu vai Pauldrons xếp tầng viền vàng + Chắn nách trái kỵ sĩ + Giáp cẳng tay)
			Arms = {
				{ "ArmR", Vector3.new(0.75, 0.28, 0.75), Vector3.new(0.12, 0.12, 0), MTL_DARK, { 0, 0, -0.18 }, Enum.Material.Metal },
				{ "ArmR", Vector3.new(0.78, 0.08, 0.78), Vector3.new(0.12, 0.28, 0), MTL_GOLD, { 0, 0, -0.18 }, Enum.Material.Metal },
				{ "ArmR", Vector3.new(0.66, 0.20, 0.66), Vector3.new(0.15, -0.10, 0), MTL_LIGHT, { 0, 0, -0.12 }, Enum.Material.Metal },
				{ "ForeR", Vector3.new(0.40, 0.40, 0.44), Vector3.new(0, -0.22, -0.05), MTL_DARK, nil, Enum.Material.Metal },

				{ "ArmL", Vector3.new(0.75, 0.28, 0.75), Vector3.new(-0.12, 0.12, 0), MTL_DARK, { 0, 0, 0.18 }, Enum.Material.Metal },
				{ "ArmL", Vector3.new(0.78, 0.08, 0.78), Vector3.new(-0.12, 0.28, 0), MTL_GOLD, { 0, 0, 0.18 }, Enum.Material.Metal },
				{ "ArmL", Vector3.new(0.66, 0.20, 0.66), Vector3.new(-0.15, -0.10, 0), MTL_LIGHT, { 0, 0, 0.12 }, Enum.Material.Metal },
				-- Tấm khiên nhỏ chắn vai trái (Besagew trong Ảnh 1)
				{ "ArmL", Vector3.new(0.50, 0.52, 0.12), Vector3.new(-0.18, 0.04, -0.38), MTL_LIGHT, { 0, 0.22, 0 }, Enum.Material.Metal },
				{ "ForeL", Vector3.new(0.40, 0.40, 0.44), Vector3.new(0, -0.22, -0.05), MTL_DARK, nil, Enum.Material.Metal },
			},
			-- EO (Đai thép hiệp sĩ + Tấm giáp hông Tassets xếp lớp như Ảnh 1 & Ảnh UI)
			Waist = {
				{ "Torso", Vector3.new(1.54, 0.22, 1.22), Vector3.new(0, -0.62, 0), MTL_DARK, nil, Enum.Material.Metal },
				{ "Torso", Vector3.new(0.34, 0.36, 0.16), Vector3.new(0, -0.62, -0.64), MTL_GOLD, nil, Enum.Material.Metal },
				{ "Torso", Vector3.new(0.56, 0.44, 0.18), Vector3.new(0.42, -0.78, -0.58), MTL_DARK, { -0.15, 0, -0.06 }, Enum.Material.Metal },
				{ "Torso", Vector3.new(0.56, 0.44, 0.18), Vector3.new(-0.42, -0.78, -0.58), MTL_DARK, { -0.15, 0, 0.06 }, Enum.Material.Metal },
				{ "Tail1", Vector3.new(0.84, 0.20, 1.05), Vector3.new(0, 0.32, 0.58), MTL_DARK, nil, Enum.Material.Metal },
			},
			-- CHÂN (Giáp ống đồng Greaves + Bọc đầu gối Poleyn mạ vàng đúng chuẩn UI)
			Legs = {
				{ "LegR", Vector3.new(0.60, 0.48, 0.68), Vector3.new(0, -0.32, -0.02), MTL_LIGHT, nil, Enum.Material.Metal },
				{ "LegR", Vector3.new(0.52, 0.18, 0.24), Vector3.new(0, -0.60, -0.30), MTL_GOLD, nil, Enum.Material.Metal },
				{ "LegR", Vector3.new(0.48, 0.54, 0.52), Vector3.new(0, -0.88, 0.08), MTL_DARK, nil, Enum.Material.Metal },

				{ "LegL", Vector3.new(0.60, 0.48, 0.68), Vector3.new(0, -0.32, -0.02), MTL_LIGHT, nil, Enum.Material.Metal },
				{ "LegL", Vector3.new(0.52, 0.18, 0.24), Vector3.new(0, -0.60, -0.30), MTL_GOLD, nil, Enum.Material.Metal },
				{ "LegL", Vector3.new(0.48, 0.54, 0.52), Vector3.new(0, -0.88, 0.08), MTL_DARK, nil, Enum.Material.Metal },
			},
		},
	},

	----------------------------------------------------------------
	-- BỘ 4: GIÁP XƯƠNG KHỦNG LONG (Bone / DinoBone)
	----------------------------------------------------------------
	Bone = {
		displayName = "Giáp Xương",
		hideNaturalHorns = true,
		slots = {
			-- ĐẦU (Mũ sọ khủng long hóa thạch + Răng nanh vành trán + Cặp đại sừng cổ đại)
			Head = {
				{ "Head", Vector3.new(1.44, 0.38, 1.38), Vector3.new(0, 0.65, 0.02), BNE_IVORY, nil, Enum.Material.Limestone },
				{ "Head", Vector3.new(1.48, 0.14, 1.42), Vector3.new(0, 0.44, 0.02), BNE_ROPE, nil, Enum.Material.Leather },
				{ "Head", Vector3.new(1.02, 0.26, 0.80), Vector3.new(0, 0.58, -0.72), BNE_AGED, { 0.12, 0, 0 }, Enum.Material.Limestone },
				-- 4 chiếc răng nanh xương cắm dọc vành trán (Không che mắt Pet)
				{ "Head", Vector3.new(0.12, 0.24, 0.12), Vector3.new(-0.36, 0.38, -0.92), BNE_FANG, nil, Enum.Material.SmoothPlastic, "WedgePart" },
				{ "Head", Vector3.new(0.12, 0.22, 0.12), Vector3.new(-0.12, 0.40, -1.00), BNE_FANG, nil, Enum.Material.SmoothPlastic, "WedgePart" },
				{ "Head", Vector3.new(0.12, 0.22, 0.12), Vector3.new(0.12, 0.40, -1.00), BNE_FANG, nil, Enum.Material.SmoothPlastic, "WedgePart" },
				{ "Head", Vector3.new(0.12, 0.24, 0.12), Vector3.new(0.36, 0.38, -0.92), BNE_FANG, nil, Enum.Material.SmoothPlastic, "WedgePart" },
				-- 2 tấm xương hàm ốp hai bên má + Cặp sừng xương lớn trên đỉnh đầu
				{ "Head", Vector3.new(0.14, 0.52, 0.50), Vector3.new(0.70, 0.06, 0.10), BNE_IVORY, nil, Enum.Material.Limestone },
				{ "Head", Vector3.new(0.14, 0.52, 0.50), Vector3.new(-0.70, 0.06, 0.10), BNE_IVORY, nil, Enum.Material.Limestone },
				{ "Head", Vector3.new(0.24, 0.75, 0.24), Vector3.new(0.58, 0.95, 0.08), BNE_AGED, { -0.35, 0, -0.45 }, Enum.Material.Limestone, "WedgePart" },
				{ "Head", Vector3.new(0.24, 0.75, 0.24), Vector3.new(-0.58, 0.95, 0.08), BNE_AGED, { -0.35, 0, 0.45 }, Enum.Material.Limestone, "WedgePart" },
			},
			-- THÂN (Giáp bản xương ức kết hợp 3 cặp xương sườn ôm ngực + Gai sống lưng)
			Chest = {
				{ "Torso", Vector3.new(1.50, 1.14, 0.26), Vector3.new(0, 0.24, -0.58), BNE_IVORY, nil, Enum.Material.Limestone },
				{ "Torso", Vector3.new(1.54, 0.12, 0.30), Vector3.new(0, 0.80, -0.58), BNE_ROPE, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.32, 0.44, 0.14), Vector3.new(0, 0.22, -0.68), BNE_ROPE, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.18, 0.28, 0.16), Vector3.new(0, 0.22, -0.70), BNE_GLOW, nil, Enum.Material.Neon },
				-- Các dải xương sườn nổi trên bề mặt giáp ngực
				{ "Torso", Vector3.new(0.65, 0.16, 0.12), Vector3.new(0.42, 0.52, -0.68), BNE_AGED, { 0, 0, -0.12 }, Enum.Material.Limestone },
				{ "Torso", Vector3.new(0.65, 0.16, 0.12), Vector3.new(-0.42, 0.52, -0.68), BNE_AGED, { 0, 0, 0.12 }, Enum.Material.Limestone },
				{ "Torso", Vector3.new(0.62, 0.16, 0.12), Vector3.new(0.40, -0.05, -0.68), BNE_AGED, { 0, 0, -0.06 }, Enum.Material.Limestone },
				{ "Torso", Vector3.new(0.62, 0.16, 0.12), Vector3.new(-0.40, -0.05, -0.68), BNE_AGED, { 0, 0, 0.06 }, Enum.Material.Limestone },
				-- Giáp lưng xương + Gai cột sống
				{ "Torso", Vector3.new(1.46, 1.10, 0.22), Vector3.new(0, 0.22, 0.56), BNE_IVORY, nil, Enum.Material.Limestone },
				{ "Torso", Vector3.new(0.18, 0.42, 0.36), Vector3.new(0, 0.52, 0.74), BNE_FANG, { -0.4, 0, 0 }, Enum.Material.Limestone, "WedgePart" },
				{ "Torso", Vector3.new(0.18, 0.42, 0.36), Vector3.new(0, 0.02, 0.74), BNE_FANG, { -0.4, 0, 0 }, Enum.Material.Limestone, "WedgePart" },
			},
			-- TAY (Bả vai xương cắm gai nhọn đúng như icon cột Tay + Ống tay xương)
			Arms = {
				{ "ArmR", Vector3.new(0.74, 0.26, 0.74), Vector3.new(0.12, 0.12, 0), BNE_IVORY, { 0, 0, -0.15 }, Enum.Material.Limestone },
				{ "ArmR", Vector3.new(0.78, 0.08, 0.78), Vector3.new(0.12, 0.26, 0), BNE_ROPE, { 0, 0, -0.15 }, Enum.Material.Leather },
				{ "ArmR", Vector3.new(0.20, 0.48, 0.20), Vector3.new(0.30, 0.44, 0), BNE_FANG, { 0, 0, -0.50 }, Enum.Material.Limestone, "WedgePart" },
				{ "ForeR", Vector3.new(0.38, 0.38, 0.42), Vector3.new(0, -0.22, -0.05), BNE_AGED, nil, Enum.Material.Limestone },

				{ "ArmL", Vector3.new(0.74, 0.26, 0.74), Vector3.new(-0.12, 0.12, 0), BNE_IVORY, { 0, 0, 0.15 }, Enum.Material.Limestone },
				{ "ArmL", Vector3.new(0.78, 0.08, 0.78), Vector3.new(-0.12, 0.26, 0), BNE_ROPE, { 0, 0, 0.15 }, Enum.Material.Leather },
				{ "ArmL", Vector3.new(0.20, 0.48, 0.20), Vector3.new(-0.30, 0.44, 0), BNE_FANG, { 0, 0, 0.50 }, Enum.Material.Limestone, "WedgePart" },
				{ "ForeL", Vector3.new(0.38, 0.38, 0.42), Vector3.new(0, -0.22, -0.05), BNE_AGED, nil, Enum.Material.Limestone },
			},
			-- EO (Đai eo dây thừng da thú + 2 mảnh xương chắn đùi + Gai xương sống đuôi)
			Waist = {
				{ "Torso", Vector3.new(1.52, 0.22, 1.22), Vector3.new(0, -0.62, 0), BNE_ROPE, nil, Enum.Material.Leather },
				{ "Torso", Vector3.new(0.36, 0.36, 0.16), Vector3.new(0, -0.62, -0.62), BNE_IVORY, nil, Enum.Material.Limestone },
				{ "Torso", Vector3.new(0.54, 0.44, 0.16), Vector3.new(0.42, -0.78, -0.58), BNE_IVORY, { -0.14, 0, 0 }, Enum.Material.Limestone },
				{ "Torso", Vector3.new(0.54, 0.44, 0.16), Vector3.new(-0.42, -0.78, -0.58), BNE_IVORY, { -0.14, 0, 0 }, Enum.Material.Limestone },
				{ "Tail1", Vector3.new(0.18, 0.46, 0.34), Vector3.new(0, 0.54, 0.48), BNE_FANG, { -0.35, 0, 0 }, Enum.Material.Limestone, "WedgePart" },
				{ "Tail2", Vector3.new(0.16, 0.42, 0.30), Vector3.new(0, 0.40, 0.65), BNE_FANG, { -0.35, 0, 0 }, Enum.Material.Limestone, "WedgePart" },
			},
			-- CHÂN (Giáp ống chân xương hóa thạch + Đệm gối da thú)
			Legs = {
				{ "LegR", Vector3.new(0.48, 0.52, 0.52), Vector3.new(0, -0.86, 0.08), BNE_IVORY, nil, Enum.Material.Limestone },
				{ "LegR", Vector3.new(0.50, 0.16, 0.22), Vector3.new(0, -0.60, -0.28), BNE_ROPE, nil, Enum.Material.Leather },
				{ "LegL", Vector3.new(0.48, 0.52, 0.52), Vector3.new(0, -0.86, 0.08), BNE_IVORY, nil, Enum.Material.Limestone },
				{ "LegL", Vector3.new(0.50, 0.16, 0.22), Vector3.new(0, -0.60, -0.28), BNE_ROPE, nil, Enum.Material.Leather },
			},
		},
	},
}

-- Keep the existing inventory ID Training as the Hunter set alias.
function Armor.petSet(id)
	return Armor.PetSets[if id=="Training" then "Hunter" else id]
end
local function petSlot(model,slot,id,group)
	local set=assert(Armor.petSet(id),"Invalid pet armor set")
	for i,def in set.slots[slot] do
		local bone=assert(find(model,{def[1]}),"Missing pet armor bone: "..def[1])
		local offset=CFrame.new(def[3]);local rot=def[5]
		if rot then offset*=CFrame.Angles(rot[1],rot[2],rot[3]) end
		local p=Instance.new(def[7] or "Part");p.Name=string.format("%s_%s_%d",if id=="Training" then "Hunter" else id,slot,i)
		p.Size=def[2];p.Color=def[4];p.Material=def[6] or Enum.Material.SmoothPlastic
		p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true
		p.CFrame=bone.CFrame*offset;p:SetAttribute("ArmorSet",id);p:SetAttribute("ArmorSlot",slot);p:SetAttribute("ArmorBone",def[1]);p.Parent=group
		local w=Instance.new("Weld");w.Name="ArmorWeld";w.Part0=bone;w.Part1=p;w.C0=offset;w.Parent=p
		if not group.PrimaryPart then group.PrimaryPart=p end
	end
	return group
end

function Armor.slot(model,target,slot,id)
	assert(Armor.valid(slot,id),"Invalid armor selection")
	local group=Instance.new("Model");group.Name="Armor_"..slot
	group:SetAttribute("ArmorSlot",slot);group:SetAttribute("ArmorSet",id)
	if id=="None" then return group end
	if target=="Pet" then return petSlot(model,slot,id,group) end
	local style=Armor.Sets[id]
	local pet=target=="Pet"
	local function add(bone,name,size,offset,trim,class)
		if not bone then return end
		local p=Instance.new(class or "Part");p.Name=name;p.Size=size
		p.Color=if trim then style.Trim else style.Color;p.Material=style.Material
		p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true
		p.CFrame=bone.CFrame*offset;p.Parent=group
		local w=Instance.new("Weld");w.Name="ArmorWeld";w.Part0=bone;w.Part1=p;w.C0=offset;w.Parent=p
		if not group.PrimaryPart then group.PrimaryPart=p end
		return p
	end
	if slot=="Head" then
		local bone=find(model,{"Head"})
		if bone then
			local size=if pet then Vector3.new(1.3,1.1,1.25) else bone.Size
			add(bone,"HelmetCrown",Vector3.new(size.X*1.12,size.Y*.3,size.Z*1.08),CFrame.new(0,size.Y*.52,0))
			add(bone,"HelmetBand",Vector3.new(size.X*1.15,size.Y*.12,size.Z*1.1),CFrame.new(0,size.Y*.35,0),true)
			for _,side in {-1,1} do
				add(bone,"CheekPlate",Vector3.new(size.X*.1,size.Y*.48,size.Z*.52),CFrame.new(side*size.X*.54,0,0))
				if id=="Bone" then add(bone,"Horn",Vector3.new(.15,.36,.18),CFrame.new(side*size.X*.36,size.Y*.78,0)*CFrame.Angles(0,0,-side*.3),true,"WedgePart") end
			end
		end
	elseif slot=="Chest" then
		local bone=find(model,if pet then {"Torso"} else {"UpperTorso","Torso"})
		if bone then
			local size=if pet then Vector3.new(1.4,1.7,1.1) else bone.Size
			for _,side in {-1,1} do add(bone,"BodyPlate",Vector3.new(size.X*1.04,size.Y*.76,.18),CFrame.new(0,0,side*(size.Z*.5+.09))) end
			add(bone,"CollarTrim",Vector3.new(size.X*1.08,.12,.22),CFrame.new(0,size.Y*.32,-size.Z*.5-.1),true)
			add(bone,"HunterBadge",Vector3.new(.27,.36,.1),CFrame.new(0,0,-size.Z*.5-.23),true)
		end
	elseif slot=="Arms" then
		for _,side in {"R","L"} do
			local bone=find(model,if pet then {"Arm"..side} elseif side=="R" then {"RightUpperArm","Right Arm"} else {"LeftUpperArm","Left Arm"})
			if bone then
				local size=if pet then Vector3.new(.6,.65,.6) else bone.Size
				local y=if pet then .12 else size.Y*.32
				add(bone,"ShoulderGuard",Vector3.new(size.X*1.25,.28,size.Z*1.18),CFrame.new(0,y,0))
				add(bone,"ShoulderTrim",Vector3.new(size.X*1.3,.07,size.Z*1.22),CFrame.new(0,y+.17,0),true)
				if id=="Bone" then add(bone,"ShoulderSpike",Vector3.new(.18,.32,.18),CFrame.new(0,y+.32,0),true,"WedgePart") end
			end
		end
	elseif slot=="Waist" then
		local bone=find(model,if pet then {"Torso"} else {"LowerTorso","Torso","HumanoidRootPart"})
		if bone then
			local size=if pet then Vector3.new(1.4,1.7,1.1) else bone.Size
			local y=if pet then -.72 else -size.Y*.38
			add(bone,"Belt",Vector3.new(size.X*1.1,.24,size.Z*1.1),CFrame.new(0,y,0))
			add(bone,"Buckle",Vector3.new(.32,.32,.12),CFrame.new(0,y,-size.Z*.56-.07),true)
			for _,side in {-1,1} do add(bone,"HipPlate",Vector3.new(size.X*.3,.4,.16),CFrame.new(side*size.X*.35,y-.23,-size.Z*.5)) end
		end
	elseif slot=="Legs" then
		for _,side in {"R","L"} do
			local bone=find(model,if pet then {"Leg"..side} elseif side=="R" then {"RightLowerLeg","Right Leg"} else {"LeftLowerLeg","Left Leg"})
			if bone then
				local size=if pet then Vector3.new(.55,.8,.65) else bone.Size
				local y=if pet then -.72 else -size.Y*.04
				add(bone,"ShinPlate",Vector3.new(size.X*.8,if pet then .7 else size.Y*.68,.15),CFrame.new(0,y,-size.Z*.5-.04))
				add(bone,"KneeTrim",Vector3.new(size.X*.88,.2,.2),CFrame.new(0,y+.29,-size.Z*.5-.06),true)
			end
		end
	end
	return group
end

function Armor.apply(model,target,equipment)
	local old=model:FindFirstChild("EquipmentArmor");if old then old:Destroy() end
	local legacy=model:FindFirstChild("TrainingArmor");if legacy then legacy:Destroy() end
	if target=="Pet" then
		for _,p in model:GetChildren() do
			if p:IsA("BasePart") then
				local slot=p:GetAttribute("Slot")
				if slot=="Armor" or slot=="Helmet" then p.Transparency=1
				elseif slot=="Horns" then
					local set=Armor.petSet(equipment.Head)
					p.Transparency=if set and set.hideNaturalHorns then 1 else 0
				end
			end
		end
	else
		for _,accessory in model:GetChildren() do
			if accessory:IsA("Accessory") and (accessory.AccessoryType==Enum.AccessoryType.Hair or accessory.AccessoryType==Enum.AccessoryType.Hat) then
				for _,part in accessory:GetDescendants() do if part:IsA("BasePart") then
					if part:GetAttribute("ArmorOriginalTransparency")==nil then part:SetAttribute("ArmorOriginalTransparency",part.Transparency) end
					part.Transparency=if equipment.Head=="None" then part:GetAttribute("ArmorOriginalTransparency") else 1
				end end
			end
		end
	end
	local all=Instance.new("Model");all.Name="EquipmentArmor"
	for _,slot in Armor.Slots do Armor.slot(model,target,slot,equipment[slot] or "None").Parent=all end
	all.Parent=model
	return all
end

function Armor.icon(target,slot,id)
	if target=="Pet" then
		local body=Instance.new("Model")
		local origins={Head=CFrame.new(),Torso=CFrame.new(),ArmR=CFrame.new(.85,0,0),ForeR=CFrame.new(.85,-.5,0),ArmL=CFrame.new(-.85,0,0),ForeL=CFrame.new(-.85,-.5,0),LegR=CFrame.new(.5,0,0),LegL=CFrame.new(-.5,0,0),Tail1=CFrame.new(0,-.6,.5),Tail2=CFrame.new(0,-.6,1.7)}
		for name,cf in origins do local bone=Instance.new("Part");bone.Name=name;bone.CFrame=cf;bone.Parent=body end
		local piece=Armor.slot(body,target,slot,id)
		for _,v in piece:GetDescendants() do if v:IsA("Weld") then v:Destroy() elseif v:IsA("BasePart") then v.Anchored=true end end
		body:Destroy();return piece
	end
	local body=Instance.new("Model")
	local names=if target=="Pet" then {"Head","Torso","ArmR","ArmL","LegR","LegL"} else {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
	for i,name in names do
		local p=Instance.new("Part");p.Name=name;p.Transparency=1;p.Anchored=true
		p.Size=if name=="Head" then Vector3.new(2,1,1) elseif name=="Torso" then Vector3.new(2,2,1) else Vector3.new(1,2,1)
		p.CFrame=CFrame.new(if i==3 or i==5 then -.65 elseif i==4 or i==6 then .65 else 0,0,0);p.Parent=body
	end
	local piece=Armor.slot(body,target,slot,id)
	for _,v in piece:GetDescendants() do if v:IsA("Weld") then v:Destroy() elseif v:IsA("BasePart") then v.Anchored=true end end
	body:Destroy()
	return piece
end

return Armor
