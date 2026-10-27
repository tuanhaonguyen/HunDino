"""Prepare narrow source changes; never serialize or rebuild a Roblox place."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parent.parent
BACKUP = ROOT / 'backups/merchant-weapons-20261026'
def once(s, old, new):
    assert s.count(old) == 1, ('Expected one source match', old[:160], s.count(old))
    return s.replace(old, new, 1)

def rules(s):
    s = once(s, 'local C = Rules.Config', '''Rules.WeaponOrder = table.freeze({"Hammer", "SwordShield", "Katana", "Glaive", "DualDaggers", "Bow", "GreatAxe"})
local WeaponIds = {}
for _, weaponId in Rules.WeaponOrder do WeaponIds[weaponId] = true end
local function initialWeaponLevels(hammerLevel)
 local levels = {}
 for _, weaponId in Rules.WeaponOrder do levels[weaponId] = if weaponId == "Hammer" then hammerLevel else 1 end
 return levels
end
local function validWeaponLevels(profile)
 if type(profile.WeaponLevels) ~= "table" then return false end
 for weaponId, level in profile.WeaponLevels do
  if not WeaponIds[weaponId] or (level ~= 1 and level ~= 2) then return false end
 end
 for _, weaponId in Rules.WeaponOrder do if profile.WeaponLevels[weaponId] == nil then return false end end
 return profile.WeaponLevels.Hammer == profile.HammerLevel
end
local C = Rules.Config''')
    s = once(s, 'if not validBaseProfile(profile, 2) or type(profile.OwnedSpecimens)', 'if not validBaseProfile(profile, 2) or not validWeaponLevels(profile) or type(profile.OwnedSpecimens)')
    s = once(s, 'migrated.DisplaySlots = {}', '''migrated.DisplaySlots = {}
            migrated.WeaponLevels = initialWeaponLevels(migrated.HammerLevel)''')
    s = once(s, 'if normalized.RedeemedCodes == nil then normalized.RedeemedCodes = {} end', '''if normalized.RedeemedCodes == nil then normalized.RedeemedCodes = {} end
        -- Only absent legacy data migrates. Invalid existing levels fail loading.
        if normalized.WeaponLevels == nil then normalized.WeaponLevels = initialWeaponLevels(normalized.HammerLevel) end
        -- Older servers can still complete the legacy hammer-only upgrade.
        if type(normalized.WeaponLevels)=="table" and normalized.HammerLevel==2 and normalized.WeaponLevels.Hammer==1 then
            normalized.WeaponLevels.Hammer=2
        end''')
    s = once(s, 'Coins = C.StarterCoins, HammerLevel = 1,', 'Coins = C.StarterCoins, HammerLevel = 1, WeaponLevels = initialWeaponLevels(1),')
    start = s.index('\telseif request.Op == "UpgradeHammer" then')
    end = s.index('\telseif request.Op == "SetDisplaySlot" then', start)
    s = s[:start] + '''\telseif request.Op == "UpgradeWeapon" or request.Op == "UpgradeHammer" then
        local weaponId = if request.Op == "UpgradeHammer" then "Hammer" else request.WeaponId
        if type(weaponId) ~= "string" or not WeaponIds[weaponId] then return rejected("InvalidWeapon") end
        if profile.WeaponLevels[weaponId] ~= 1 then return rejected("MaximumLevel") end
        if profile.Materials.Bone < C.UpgradeBones or profile.Materials.Iron < C.UpgradeIron then return rejected("InsufficientMaterials") end
        nextProfile.Materials.Bone -= C.UpgradeBones
        nextProfile.Materials.Iron -= C.UpgradeIron
        nextProfile.WeaponLevels[weaponId] = 2
        if weaponId == "Hammer" then nextProfile.HammerLevel = 2 end
        receipt = accepted("Upgraded", {WeaponId = weaponId, WeaponLevel = 2,
            HammerLevel = if weaponId == "Hammer" then 2 else nil, DamageMultiplier = C.HammerMultiplier})
''' + s[end:]
    s = once(s, 'if request.Op == "Buy" or request.Op == "CraftTrap" or request.Op == "UpgradeHammer" or request.Op == "SetDisplaySlot" then', 'if request.Op == "Buy" or request.Op == "CraftTrap" or request.Op == "UpgradeHammer" or request.Op == "UpgradeWeapon" or request.Op == "SetDisplaySlot" then')
    s = once(s, 'StoredConsumables = clone(profile.StoredConsumables), HammerLevel = profile.HammerLevel,', 'StoredConsumables = clone(profile.StoredConsumables), HammerLevel = profile.HammerLevel, WeaponLevels = clone(profile.WeaponLevels),')
    s = once(s, '''function Rules.damageMultiplier(profile)
\tif not validProfile(profile) then return nil end
\treturn if profile.HammerLevel == 2 then C.HammerMultiplier else 1
end''', '''function Rules.damageMultiplier(profile, weaponId)
 if not validProfile(profile) then return nil end
 weaponId = weaponId or "Hammer" -- Legacy hammer-only callers retain their meaning.
 if type(weaponId) ~= "string" or not WeaponIds[weaponId] then return nil end
 return if profile.WeaponLevels[weaponId] == 2 then C.HammerMultiplier else 1
end''')
    return s

def service(s):
    s = s.replace('MaximumLevel="Búa đã đạt cấp 2 trong bản thử."', 'MaximumLevel="Vũ khí này đã đạt cấp 2.", InvalidWeapon="Vũ khí không hợp lệ."')
    s = once(s, 'set(player,"HammerDamageMultiplier",Economy.damageMultiplier(p))', '''set(player,"HammerDamageMultiplier",Economy.damageMultiplier(p,"Hammer"))
 for _, weaponId in Economy.WeaponOrder do set(player,"WeaponLevel_"..weaponId,p.WeaponLevels[weaponId]) end''')
    s = once(s, 'data.SaveState=player:GetAttribute("ProfileSaveState")', '''data.SaveState=player:GetAttribute("ProfileSaveState")
 data.CanBuy=self:_context(player,"Merchant")
 data.CanCraft=self:_context(player,"Craft")''')
    s = once(s, 'if context~="Inventory" and not self:_context(player,context) then', 'if context~="Inventory" and context~="Shop" and not self:_context(player,context) then')
    s = once(s, 'if context=="Inventory" and not actor(self.GetState(player)) then return false end', 'if (context=="Inventory" or context=="Shop") and not actor(self.GetState(player)) then return false end')
    s = once(s, 'if action=="GetInventory" then', '''if action=="OpenShop" then self:Open(player,"Shop");return end
 if action=="GetInventory" then''')
    s = once(s,'if not self:Profile(player) then return end','''if not self:Profile(player) then return end
 if action=="RefreshShop" then
  self.LastShopRefresh=self.LastShopRefresh or {}
  local now=os.clock()
  if now-(self.LastShopRefresh[player] or -math.huge)<.5 then return end
  self.LastShopRefresh[player]=now
  if actor(self.GetState(player)) then self:Publish(player) end
  return
 end''')
    s = once(s,'self.LastCodeRequest[player]=nil','self.LastCodeRequest[player]=nil\n if self.LastShopRefresh then self.LastShopRefresh[player]=nil end')
    start=s.index('\tlocal operations={MerchantBuyTrap=')
    end=s.index('\nend\nfunction Service:_runRequest', start)
    s=s[:start]+''' local operations={MerchantBuyTrap={"Merchant","Buy","RawTrap"},MerchantBuyPotion={"Merchant","Buy","SleepPotion"},
  CraftIronTrap={"Craft","CraftTrap"},UpgradeHammer={"Craft","UpgradeHammer"},UpgradeWeapon={"Craft","UpgradeWeapon"}}
 local op=operations[action];if not op then return end
 if not self:IsReady(player) then self:_notice(player,"Đang xử lý giao dịch, hãy thử lại sau.");return end
 local profile=self:Profile(player);local offer=self.Offers[player]
 local payload=if action=="UpgradeWeapon" and type(token)=="table" then token else nil
 local operationToken=if payload then payload.OperationToken else token
 if type(operationToken)~="string" or #operationToken>64 or not offer or operationToken~=offer.Token or offer.Revision~=profile.Revision
  or (payload and (payload.SnapshotVersion~=profile.Revision or payload.OperationSerial~=profile.OperationSerial+1)) then
  self:Publish(player,"Kho vừa thay đổi. Hãy thử lại thao tác.");return
 end
 if (offer.Context~="Shop" and offer.Context~="Merchant" and offer.Context~="Craft") or not self:_context(player,op[1]) then
  self:Publish(player,if op[1]=="Craft" then "Đến bàn chế tạo ở base của bạn, cất vũ khí để nâng cấp." else "Đến gần thương nhân và cất vũ khí để mua.");return
 end
 local receipt=self:_apply(player,{Op=op[2],Item=op[3],WeaponId=payload and payload.WeaponId,OperationSerial=profile.OperationSerial+1})
 local names={Hammer="Búa tạ",SwordShield="Kiếm & khiên",Katana="Katana",Glaive="Thương cán dài",DualDaggers="Song dao",Bow="Cung",GreatAxe="Rìu đại"}
 local upgraded=op[2]=="UpgradeWeapon" or op[2]=="UpgradeHammer"
 local text=if receipt.Ok then (if upgraded then (names[receipt.WeaponId or "Hammer"] or "Vũ khí").." đạt cấp 2 · +15% sát thương."
  elseif op[2]=="CraftTrap" then "Đã chế tạo 1 bẫy sắt." else "Đã mua 1 vật dụng tiếp tế.")
  else (ERRORS[receipt.Code] or "Chưa thể giao dịch: "..tostring(receipt.Code))
 self:Publish(player,text);self:_notice(player,text)''' + s[end:]
    s = once(s, '''function Service:DamageMultiplier(player)
 local profile=self:Profile(player);return if profile then Economy.damageMultiplier(profile) else 1
end''', '''function Service:DamageMultiplier(player, weaponId)
 local profile=self:Profile(player)
 return if profile then (Economy.damageMultiplier(profile,weaponId) or 1) else 1
end''')
    s = s.replace('"Chế tạo / Nâng búa"', '"Chế tạo / Nâng vũ khí"').replace('Bẫy sắt · Búa cấp 2', 'Bẫy sắt · Nâng vũ khí').replace('Trap · Thuốc ngủ: 10 xu', 'Bẫy thô · Thuốc ngủ: 10 xu')
    return s

def hub(s):
    s = once(s, 'body.BackgroundTransparency=1; body.Parent=overlay', 'body.BackgroundTransparency=1; body.ZIndex=overlay.ZIndex+1; body.Parent=overlay')
    s = once(s, 'show=function(id)\n', '''show=function(id)
  if id=="Shop" then
   api:Close();callbacks.BeforeOpen()
   if economyRemote then economyRemote:FireServer("OpenShop") end
   return
  end
''')
    start=s.index('  elseif id=="Shop" then')
    end=s.index('  elseif id=="Redeem" then',start)
    s=s[:start]+s[end:]
    return s

def inventory(s):
    s = once(s, 'itemSummary.Text=if ready then "XU  "..count(itemSnapshot.Coins).."      /      BÚA CẤP "..math.max(1,count(itemSnapshot.HammerLevel)) else "Đang cập nhật vật phẩm…"', 'itemSummary.Text=if ready then "XU  "..count(itemSnapshot.Coins).."      /      CẤP VŨ KHÍ XEM TẠI TAB NGƯỜI" else "Đang cập nhật vật phẩm…"')
    start=s.index('\tlocal function hammerLevel()')
    end=s.index('\tlocal function equippedWeapon()',start)
    s=s[:start]+''' local function weaponLevel(id)
  if api.Target=="Pet" then return 1 end
  if not itemSnapshot then return nil end
  local levels=itemSnapshot.WeaponLevels
  return if type(levels)=="table" then math.max(1,count(levels[id])) elseif id=="Hammer" then math.max(1,count(itemSnapshot.HammerLevel)) else 1
 end
'''+s[end:]
    s=s.replace('if id=="Hammer" and self.Target=="Player" then hammerLevel() else 1', 'weaponLevel(id)')
    s=s.replace('if selection.Id=="Hammer" and self.Target=="Player" then hammerLevel() else 1', 'weaponLevel(selection.Id)')
    s=s.replace('id=="Hammer" and self.Target=="Player" and level>=2', 'self.Target=="Player" and level>=2')
    s=s.replace('selection.Id=="Hammer" and self.Target=="Player" and level and level>=2', 'self.Target=="Player" and level and level>=2')
    return s

def training(s):
    return once(s, '(if s.WeaponId=="Hammer" and economy then economy:DamageMultiplier(s.Player) else 1)', '(if economy then economy:DamageMultiplier(s.Player,s.WeaponId) else 1)')

def client(s):
    start=s.index('-- Existing weapon/quest menu guards')
    end=s.index('local harvest = frame(',start)
    s=s[:start]+(ROOT/'assets/ui/MerchantPanel.luau').read_text(encoding='utf-8')+'\n\n'+s[end:]
    s=once(s,'gui.DisplayOrder = 14','gui.DisplayOrder = 80')
    s=once(s,'if (action == "MerchantBuyTrap" or action == "MerchantBuyPotion") and context ~= "Merchant" then return end\n\tif (action == "CraftIronTrap" or action == "UpgradeHammer") and context ~= "Craft" then return end','''if (action == "MerchantBuyTrap" or action == "MerchantBuyPotion") and snapshot.CanBuy ~= true then return end
 if (action == "CraftIronTrap" or action == "UpgradeWeapon") and snapshot.CanCraft ~= true then return end''')
    s=once(s,'pendingUntil = now + 2','pendingUntil = now + 8')
    s=once(s,'remote:FireServer(action, token) -- A receipt token is issued/rotated only by the server.', '''if action=="UpgradeWeapon" then
  remote:FireServer(action,{OperationToken=token,WeaponId=selectedWeapon,SnapshotVersion=snapshot.Revision,OperationSerial=snapshot.OperationSerial+1})
 else remote:FireServer(action,token) end''')
    start=s.index('local function updatePanel()')
    end=s.index('local function applySnapshot(dto)',start)
    s=s[:start]+(ROOT/'assets/ui/MerchantRefresh.luau').read_text(encoding='utf-8')+'\n'+s[end:]
    s=once(s,'{"Coins", "Materials", "Stored", "HammerLevel", "ActiveRun", "OperationToken"}', '{"Coins", "Materials", "Stored", "HammerLevel", "WeaponLevels", "CanBuy", "CanCraft", "OperationSerial", "ActiveRun", "OperationToken"}')
    s=once(s,'local function refresh()','local nextShopRefresh=0\nlocal function refresh()')
    s=once(s,'if panel.Visible then updatePanel() end','''if panel.Visible then
  updatePanel()
  if now>=nextShopRefresh then nextShopRefresh=now+.7;remote:FireServer("RefreshShop") end
 end''')
    s=once(s,'math.min(1, math.max(.45, (size.X - 32) / 580), math.max(.45, (size.Y - 48) / 460))','math.min(1, (size.X - 24) / 820, (size.Y - 32) / 586)')
    s=once(s,'connect(shade.Activated, hidePanel)', '''connect(shade.Activated,function(input)
 local inset=if gui.IgnoreGuiInset then Vector2.zero else GuiService:GetGuiInset()
 local point=Vector2.new(input.Position.X,input.Position.Y)-inset
 local pos,size=panel.AbsolutePosition,panel.AbsoluteSize
 if point.X>=pos.X and point.X<=pos.X+size.X and point.Y>=pos.Y and point.Y<=pos.Y+size.Y then return end
 hidePanel()
end)
connect(supplyTab.Activated,function() selectedTab="Supplies";updatePanel() end)
connect(weaponTab.Activated,function() selectedTab="Weapons";updatePanel() end)
for id,b in weaponButtons do connect(b.Activated,function() selectedWeapon=id;updatePanel() end) end''')
    s=once(s,'if dto.Context ~= "Merchant" and dto.Context ~= "Craft" then return end','if dto.Context ~= "Merchant" and dto.Context ~= "Craft" and dto.Context ~= "Shop" then return end')
    s=once(s,'cancelHold(); context = dto.Context; applySnapshot(dto)','''cancelHold(); context = dto.Context
  selectedTab=if context=="Craft" then "Weapons" else "Supplies"
  selectedWeapon=player:GetAttribute("WeaponId") or "Hammer"
  notice.Text="";applySnapshot(dto)''')
    return s

if __name__=='__main__':
    files={'src/hunting/HuntEconomyRules.luau':rules,'src/hunting/HuntEconomyService.luau':service,
      'src/dark-jungle/HubUI.luau':hub,'src/dark-jungle/EquipmentInventory.luau':inventory}
    for name,patch in files.items():
        path=ROOT/name
        original=path.read_text(encoding='utf-8-sig')
        out=patch(original)
        backup=BACKUP/name.replace('/','__')
        assert not backup.exists(), 'Preparation already ran; do not patch twice'
        backup.write_text(original,encoding='utf-8')
        path.write_text(out,encoding='utf-8')
    print('Prepared rules, server adapter, shared shop entry and inventory levels. Native place unchanged.')
