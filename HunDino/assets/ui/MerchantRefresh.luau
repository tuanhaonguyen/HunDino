local function updatePanel()
 coins.Text=string.format("XU  %d",count(snapshot.Coins))
 for _,row in rows do
  local stock=snapshot[row[3]]
  stockLabels[row[1]].Text=string.format("%s · %d",row[2],count(type(stock)=="table" and stock[row[1]]))
 end
 heading.Text=if context=="Craft" then "BÀN CHẾ TẠO · NÂNG VŨ KHÍ" else "THƯƠNG NHÂN"
 locationHint.Text=if selectedTab=="Weapons" then
  (if snapshot.CanCraft then "Bàn chế tạo đã sẵn sàng · Chọn đúng vũ khí để nâng cấp riêng."
  else "Xem cấp vũ khí tại đây. Đến bàn chế tạo ở base của bạn, cất vũ khí để nâng cấp.")
  else (if snapshot.CanBuy then "Đang ở quầy tiếp tế · Mua vật tư vào kho của bạn."
  elseif snapshot.CanCraft then "Đang ở bàn chế tạo · Có thể ghép bẫy sắt. Mua vật tư tại thương nhân."
  else "Mua tại thương nhân ở sảnh · Chế tạo và nâng cấp tại bàn ở base của bạn.")
 supplies.Visible=selectedTab=="Supplies";weapons.Visible=selectedTab=="Weapons"
 supplyTab.TextColor3=if supplies.Visible then C.Gold else MUTED
 weaponTab.TextColor3=if weapons.Visible then C.Gold else MUTED
 local now=workspace:GetServerTimeNow()
 local state=player:GetAttribute("ProfileSaveState")
 local ready=player:GetAttribute("ProfileReady")==true and state~="Error" and state~="Saving" and state~="Conflict" and state~="Closing"
  and availableToken()~=nil and now>=nextMutationAt
  and not (pendingToken==availableToken() and pendingUntil and now<pendingUntil)
 local materials=if type(snapshot.Materials)=="table" then snapshot.Materials else {}
 local stored=if type(snapshot.Stored)=="table" then snapshot.Stored else {}
 local bone,iron=count(materials.Bone),count(materials.Iron)
 recipeStatus.Text=string.format("Bẫy thô %d/1 · Sắt %d/1\nGhép tại bàn chế tạo ở base của bạn.",count(stored.RawTrap),iron)
 recipeStatus.TextColor3=if count(stored.RawTrap)>=1 and iron>=1 then GREEN else C.Warning
 enabled(buyTrap,ready and snapshot.CanBuy==true and count(snapshot.Coins)>=10)
 enabled(buyPotion,ready and snapshot.CanBuy==true and count(snapshot.Coins)>=10)
 enabled(craftTrap,ready and snapshot.CanCraft==true and count(stored.RawTrap)>=1 and iron>=1)
 local levels=if type(snapshot.WeaponLevels)=="table" then snapshot.WeaponLevels else {}
 for _,id in weaponOrder do
  local level=count(levels[id],if id=="Hammer" then snapshot.HammerLevel or 1 else 1)
  local b=weaponButtons[id]
  b.Text=string.format("%s · Cấp %d",weaponNames[id],level)
  b.TextColor3=if selectedWeapon==id then C.Gold else CREAM
  b.BackgroundColor3=if selectedWeapon==id then Color3.fromRGB(53,49,39) else C.Card
 end
 local level=count(levels[selectedWeapon],if selectedWeapon=="Hammer" then snapshot.HammerLevel or 1 else 1)
 weaponTitle.Text=weaponNames[selectedWeapon]
 weaponLevelLabel.Text=string.format("CẤP %d%s",level,if player:GetAttribute("WeaponId")==selectedWeapon then " · ĐANG TRANG BỊ" else "")
 weaponBonus.Text=if level>=2 then "+15% sát thương cho vũ khí này.\nCác vũ khí khác giữ cấp riêng." else "Cấp 1 → Cấp 2\nTăng 15% sát thương cho vũ khí này."
 weaponBonus.TextColor3=if level>=2 then GREEN else CREAM
 boneProgress.Text=string.format("Xương  %d / 2",bone);boneProgress.TextColor3=if bone>=2 then GREEN else C.Warning
 ironProgress.Text=string.format("Sắt        %d / 2",iron);ironProgress.TextColor3=if iron>=2 then GREEN else C.Warning
 upgrade.Text=if level>=2 then "ĐÃ ĐẠT CẤP 2" elseif not snapshot.CanCraft then "NÂNG TẠI BASE CỦA BẠN" else "NÂNG LÊN CẤP 2 · +15%"
 enabled(upgrade,ready and snapshot.CanCraft==true and level<2 and bone>=2 and iron>=2)
end
