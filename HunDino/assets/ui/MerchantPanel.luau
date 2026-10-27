-- A single shop surface is used by the icon, merchant and owned crafting table.
-- Layer order is assigned before children are created.
local selectedWeapon = player:GetAttribute("WeaponId") or "Hammer"
local selectedTab = "Supplies"
local weaponOrder = {"Hammer", "SwordShield", "Katana", "Glaive", "DualDaggers", "Bow", "GreatAxe"}
local weaponNames = {Hammer="Búa tạ", SwordShield="Kiếm & khiên", Katana="Katana", Glaive="Thương cán dài", DualDaggers="Song dao", Bow="Cung", GreatAxe="Rìu đại"}
local panel = frame("Panel", gui, UDim2.fromOffset(820, 586), UDim2.fromScale(.5, .5), Vector2.new(.5, .5))
panel.ZIndex = 6; panel.Visible = false; panel.Active = true
panel.BackgroundTransparency = .04
local panelScale = Instance.new("UIScale"); panelScale.Parent = panel
local heading = label("Title", panel, "THƯƠNG NHÂN", UDim2.fromOffset(24, 16), UDim2.fromOffset(700, 32), 22)
heading.TextColor3 = C.Gold; heading.Font = Enum.Font.GothamBold
local close = button("Close", panel, "×", UDim2.new(1, -56, 0, 16), UDim2.fromOffset(32, 32))
local coins = label("Coins", panel, "XU  0", UDim2.fromOffset(24, 54), UDim2.fromOffset(350, 30), 19)
coins.TextColor3 = C.Gold
local locationHint = label("LocationHint", panel, "", UDim2.fromOffset(24, 89), UDim2.new(1, -48, 0, 38), 13)
locationHint.TextColor3 = MUTED
local supplyTab = button("SuppliesTab", panel, "VẬT TƯ & CHẾ TẠO", UDim2.fromOffset(24, 139), UDim2.fromOffset(376, 40))
local weaponTab = button("WeaponsTab", panel, "NÂNG CẤP VŨ KHÍ", UDim2.fromOffset(412, 139), UDim2.fromOffset(384, 40))
label("StockTitle", panel, "KHO CỦA BẠN", UDim2.fromOffset(24, 197), UDim2.fromOffset(188, 26), 13).TextColor3 = C.Gold
local stockLabels = {}
local rows = {
 {"Skin", "Da", "Materials"}, {"Tooth", "Răng", "Materials"}, {"Scale", "Vảy", "Materials"},
 {"Bone", "Xương", "Materials"}, {"Iron", "Sắt", "Materials"}, {"RawTrap", "Bẫy thô", "Stored"},
 {"IronTrap", "Bẫy sắt", "Stored"}, {"SleepPotion", "Thuốc ngủ", "Stored"},
}
for index, row in rows do
 stockLabels[row[1]] = label(row[1], panel, row[2].." · 0", UDim2.fromOffset(24, 228+(index-1)*31), UDim2.fromOffset(188, 28), 14)
end
local supplies = Instance.new("Frame")
supplies.Name="Supplies";supplies.BackgroundTransparency=1;supplies.Position=UDim2.fromOffset(236,197)
supplies.Size=UDim2.fromOffset(560,308);supplies.ZIndex=panel.ZIndex+1;supplies.Parent=panel
local function supplyCard(name, title, detail, y)
 local card=frame(name,supplies,UDim2.fromOffset(560,94),UDim2.fromOffset(0,y))
 card.BackgroundColor3=C.Card;card.BackgroundTransparency=.12
 label("Name",card,title,UDim2.fromOffset(16,10),UDim2.fromOffset(310,26),16).TextColor3=C.Gold
 label("Detail",card,detail,UDim2.fromOffset(16,39),UDim2.fromOffset(310,42),12).TextColor3=MUTED
 return card
end
local trapCard=supplyCard("RawTrapCard","BẪY THÔ","Vật tư dùng để chế bẫy sắt. Giá: 10 xu.",0)
local buyTrap=button("MerchantBuyTrap",trapCard,"MUA · 10 XU",UDim2.fromOffset(350,25),UDim2.fromOffset(192,44))
local potionCard=supplyCard("PotionCard","THUỐC NGỦ","Dùng để bắt sống khủng long suy yếu. Giá: 10 xu.",104)
local buyPotion=button("MerchantBuyPotion",potionCard,"MUA · 10 XU",UDim2.fromOffset(350,25),UDim2.fromOffset(192,44))
local ironCard=supplyCard("IronTrapCard","CHẾ BẪY SẮT","",208)
local recipeStatus=ironCard.Detail
local craftTrap=button("CraftIronTrap",ironCard,"CHẾ TẠO",UDim2.fromOffset(350,25),UDim2.fromOffset(192,44))
local weapons=Instance.new("Frame")
weapons.Name="Weapons";weapons.BackgroundTransparency=1;weapons.Position=UDim2.fromOffset(236,197)
weapons.Size=UDim2.fromOffset(560,308);weapons.ZIndex=panel.ZIndex+1;weapons.Parent=panel
local weaponList=Instance.new("ScrollingFrame")
weaponList.Name="WeaponList";weaponList.Position=UDim2.fromOffset(0,0);weaponList.Size=UDim2.fromOffset(224,308)
weaponList.BackgroundTransparency=1;weaponList.BorderSizePixel=0;weaponList.ScrollBarThickness=4
weaponList.ScrollBarImageColor3=C.Gold;weaponList.CanvasSize=UDim2.fromOffset(0,#weaponOrder*43)
weaponList.ZIndex=weapons.ZIndex+1;weaponList.Parent=weapons
local weaponButtons={}
for index,id in weaponOrder do
 local b=button("Select_"..id,weaponList,"",UDim2.fromOffset(0,(index-1)*43),UDim2.fromOffset(212,39))
 b.TextSize=13;weaponButtons[id]=b
end
local weaponDetail=frame("WeaponDetail",weapons,UDim2.fromOffset(320,308),UDim2.fromOffset(240,0))
weaponDetail.BackgroundColor3=C.Card
local weaponTitle=label("WeaponName",weaponDetail,"",UDim2.fromOffset(18,12),UDim2.fromOffset(284,28),19)
weaponTitle.TextColor3=C.Gold
local weaponLevelLabel=label("WeaponLevel",weaponDetail,"",UDim2.fromOffset(18,44),UDim2.fromOffset(284,26),14)
local weaponBonus=label("WeaponBonus",weaponDetail,"",UDim2.fromOffset(18,78),UDim2.fromOffset(284,48),13)
label("RecipeTitle",weaponDetail,"NGUYÊN LIỆU NÂNG CẤP",UDim2.fromOffset(18,132),UDim2.fromOffset(284,22),12).TextColor3=MUTED
local boneProgress=label("BoneProgress",weaponDetail,"",UDim2.fromOffset(18,158),UDim2.fromOffset(284,24),14)
local ironProgress=label("IronProgress",weaponDetail,"",UDim2.fromOffset(18,186),UDim2.fromOffset(284,24),14)
local upgrade=button("UpgradeWeapon",weaponDetail,"NÂNG LÊN CẤP 2",UDim2.fromOffset(18,222),UDim2.fromOffset(284,44))
label("IndependentHint",weaponDetail,"Cấp nâng riêng cho từng loại vũ khí của Người.",UDim2.fromOffset(18,271),UDim2.fromOffset(284,30),11).TextColor3=MUTED
local notice=label("Notice",panel,"",UDim2.fromOffset(24,516),UDim2.new(1,-48,0,44),12)
notice.TextColor3=C.Gold;notice.TextYAlignment=Enum.TextYAlignment.Top
local toast=frame("NoticeToast",gui,UDim2.fromOffset(330,58),UDim2.fromOffset(20,164))
toast.Visible=false
local toastText=label("Message",toast,"",UDim2.fromOffset(12,6),UDim2.new(1,-24,1,-12),12)
toastText.TextColor3=C.Gold
