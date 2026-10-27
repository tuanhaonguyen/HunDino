	label(craftPage,"Title","CHẾ TẠO",24,16,974,36,24).TextColor3=gold
	label(craftPage,"Subtitle","Ghép nguyên liệu trong kho thành vật tư cho chuyến săn.",24,54,974,26,14).TextColor3=muted
	local recipe=frame(craftPage,"IronTrapRecipe",24,96,974,306,cardColor);line(recipe,bronze)
	local recipePreview=viewport(recipe,"ResultPreview",20,20,222,208);line(recipePreview)
	for _,item in itemCatalog do if item.Id=="IronTrap" then show(recipePreview,itemModel(item),false);break end end
	label(recipe,"RecipeName","BẪY SẮT ×1",266,20,680,32,22).TextColor3=gold
	label(recipe,"Formula","1 bẫy thô + 1 sắt → 1 bẫy sắt",266,60,680,32,18).TextXAlignment=Enum.TextXAlignment.Left
	local rawRequirement=label(recipe,"RawTrapRequirement","Bẫy thô: … / 1",266,116,310,38,17)
	local ironRequirement=label(recipe,"IronRequirement","Sắt: … / 1",600,116,348,38,17)
	local rawTrack=frame(recipe,"RawTrapTrack",276,162,290,5,dark)
	local ironTrack=frame(recipe,"IronTrack",610,162,318,5,dark)
	local rawFill=frame(rawTrack,"Fill",0,0,0,5,readyColor)
	local ironFill=frame(ironTrack,"Fill",0,0,0,5,readyColor)
	local craftButton=button(recipe,"InventoryCraftIronTrap","CHẾ TẠO 1 BẪY SẮT",266,202,680,48)
	craftButton.Font=Enum.Font.GothamBold
	local craftedStock=label(recipe,"ResultStock","",20,238,222,42,14);craftedStock.TextColor3=gold
	local craftFeedback=label(craftPage,"CraftFeedback","",28,416,966,48,14)
	craftFeedback.TextXAlignment=Enum.TextXAlignment.Left
	local craftPendingToken,craftPendingUntil
	local craftNotice=""
	local nextCraftAt,nextCraftRefresh=0,0
	local function refreshCraft()
		local now=os.clock()
		local stored=itemSnapshot and (itemSnapshot.Stored or itemSnapshot.StoredConsumables) or {}
		local materials=itemSnapshot and itemSnapshot.Materials or {}
		local raw,iron=count(stored.RawTrap),count(materials.Iron)
		rawRequirement.Text=string.format("Bẫy thô: %d / 1",raw)
		ironRequirement.Text=string.format("Sắt: %d / 1",iron)
		rawRequirement.TextColor3=if raw>=1 then readyColor else Theme.Colors.Warning
		ironRequirement.TextColor3=if iron>=1 then readyColor else Theme.Colors.Warning
		rawFill.Size=UDim2.new(if raw>=1 then 1 else 0,0,1,0)
		ironFill.Size=UDim2.new(if iron>=1 then 1 else 0,0,1,0)
		craftedStock.Text="Trong kho: "..count(stored.IronTrap).." bẫy sắt"
		local pending=craftPendingToken~=nil and craftPendingUntil~=nil and now<craftPendingUntil
		local state=player:GetAttribute("ProfileSaveState")
		local ready=player:GetAttribute("ProfileReady")==true and state~="Saving" and state~="Closing" and state~="Error" and state~="Unavailable" and state~="Conflict"
		local token=itemSnapshot and itemSnapshot.OperationToken
		craftButton.Active=ready and not pending and now>=nextCraftAt and itemSnapshot~=nil
			and itemSnapshot.CanCraft==true and type(token)=="string" and token~="" and raw>=1 and iron>=1
		craftButton.Selectable=craftButton.Active
		craftButton.Text=if pending then "ĐANG CHẾ TẠO…" else "CHẾ TẠO 1 BẪY SẮT"
		craftButton.TextColor3=if craftButton.Active then gold else muted
		craftFeedback.TextColor3=muted
		craftFeedback.Text=if pending then "Đang chờ kết quả chế tạo…"
			elseif not itemSnapshot then "Đang cập nhật nguyên liệu trong kho…"
			elseif craftNotice~="" then craftNotice
			elseif not ready then "Hồ sơ chưa sẵn sàng, hãy chờ rồi thử lại."
			elseif itemSnapshot.CanCraft~=true then "Đến gần bàn chế tạo tại base của bạn và cất vũ khí bằng R để chế tạo."
			elseif raw<1 or iron<1 then "Cần đủ 1 bẫy thô và 1 sắt trong kho để chế tạo."
			else "Đủ nguyên liệu · Mỗi lần chế tạo nhận 1 bẫy sắt vào kho."
	end
	craftButton.Activated:Connect(function()
		refreshCraft()
		if not panel.Visible or api.Section~="Crafting" or not craftButton.Active then return end
		local token=itemSnapshot.OperationToken
		nextCraftAt=os.clock()+.35;craftPendingToken=token;craftPendingUntil=os.clock()+8;craftNotice=""
		refreshCraft()
		economyRemote:FireServer("InventoryCraftIronTrap",{OperationToken=token,SnapshotVersion=itemSnapshot.Revision,
			OperationSerial=count(itemSnapshot.OperationSerial)+1})
	end)
	local craftElapsed=0
	table.insert(connections,RunService.Heartbeat:Connect(function(dt)
		if not panel.Visible or api.Section~="Crafting" then return end
		craftElapsed+=dt;if craftElapsed<.2 then return end;craftElapsed=0
		refreshCraft()
		if os.clock()>=nextCraftRefresh then nextCraftRefresh=os.clock()+.7;economyRemote:FireServer("RefreshShop") end
	end))
