-- Quick-access UI for the training build. Preferences last for this session.
local Hub={}
local icons={Shop="rbxassetid://101717469378295",Settings="rbxassetid://119955450343925",Play="rbxassetid://115198627543926",Inventory="rbxassetid://82181506096525"}
function Hub.create(player,gui,callbacks)
 local root=Instance.new("Frame"); root.Name="QuickAccess"; root.BackgroundTransparency=1
 root.Size=UDim2.fromOffset(168,198); root.Position=UDim2.new(1,-188,0,90); root.Parent=gui
 local overlay=Instance.new("Frame"); overlay.Name="HubPanel"; overlay.AnchorPoint=Vector2.new(.5,.5)
 overlay.Position=UDim2.fromScale(.5,.5); overlay.Size=UDim2.fromOffset(620,480); overlay.BackgroundColor3=Color3.fromRGB(18,34,31)
 overlay.Visible=false; overlay.ZIndex=30; overlay.Parent=gui
 local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,12); c.Parent=overlay
 local scale=Instance.new("UIScale"); scale.Parent=overlay
 local function resize()
  local size=workspace.CurrentCamera.ViewportSize
  scale.Scale=math.min(1,(size.X-32)/620,(size.Y-70)/480)
 end
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize); resize()
 local function label(parent,name,value,x,y,w,h,size)
  local t=Instance.new("TextLabel"); t.Name=name; t.Text=value; t.Font=Enum.Font.GothamMedium; t.TextSize=size or 16
  t.TextWrapped=true; t.TextColor3=Color3.fromRGB(237,228,201); t.BackgroundTransparency=1
  t.Position=UDim2.fromOffset(x,y); t.Size=UDim2.fromOffset(w,h); t.Parent=parent; return t
 end
 local heading=label(overlay,"Heading","",24,20,530,40,24)
 local body=Instance.new("Frame"); body.Name="Body"; body.Position=UDim2.fromOffset(24,76); body.Size=UDim2.fromOffset(572,380); body.BackgroundTransparency=1; body.Parent=overlay
 local function button(parent,name,value,x,y,w,h,onClick)
  local b=Instance.new("TextButton"); b.Name=name; b.Text=value; b.TextWrapped=true; b.Font=Enum.Font.GothamMedium; b.TextSize=16
  b.TextColor3=Color3.fromRGB(235,229,207); b.BackgroundColor3=Color3.fromRGB(39,74,60)
  b.Size=UDim2.fromOffset(w,h); b.Position=UDim2.fromOffset(x,y); b.Parent=parent
  local round=Instance.new("UICorner"); round.CornerRadius=UDim.new(0,7); round.Parent=b; b.Activated:Connect(onClick); return b
 end
 local api={}
 function api:IsOpen() return overlay.Visible end
 function api:Close() overlay.Visible=false; callbacks.Preferences() end
 button(overlay,"Close","×",566,18,34,34,function() api:Close() end)
 local function show(id)
  callbacks.BeforeOpen(); body:ClearAllChildren(); overlay.Visible=true; callbacks.Preferences()
  heading.Text=({Shop="THƯƠNG NHÂN",Settings="CÀI ĐẶT",Play="BẮT ĐẦU HÀNH TRÌNH"})[id]
  if id=="Play" then
   label(body,"Intro","Trại thợ săn • 12 base\nLuyện vũ khí, thử combo và đồng hành cùng pet.",0,0,572,64)
   button(body,"Training","VÀO BÃI LUYỆN TẬP",36,96,500,60,function() api:Close(); callbacks.Travel("Training") end)
   button(body,"Lobby","VỀ TRẠI THỢ SĂN",36,174,500,60,function() api:Close(); callbacks.Travel("Lobby") end)
   label(body,"Hunts","Nhiệm vụ săn khủng long — chưa mở ở bản luyện tập.",20,263,532,64)
  elseif id=="Shop" then
   label(body,"Intro","Đồ tiếp tế cho những chuyến săn sắp tới",0,0,572,44,18)
   local items={"Bình hồi máu","Bộ bẫy cơ bản","Thuốc ru ngủ"}
   for i,name in items do
    local row=Instance.new("Frame"); row.Name="Item"..i; row.BackgroundColor3=Color3.fromRGB(30,49,41)
    row.Position=UDim2.fromOffset(8,48+(i-1)*75); row.Size=UDim2.fromOffset(556,64); row.Parent=body
    label(row,"Name",name,16,8,335,48,18); label(row,"Status","SẮP MỞ",370,8,170,48,15)
   end
   label(body,"Status","Cửa hàng chưa giao dịch trong bản luyện tập.\nVũ khí thử được chọn miễn phí trong Túi đồ.",12,290,548,64,15)
  else
   label(body,"Intro","Tùy chỉnh cho phiên chơi hiện tại",0,0,572,40)
   local options={{"ShowComboGuide","Hướng dẫn combo"},{"ShowDamage","Số sát thương"},{"ShowComboFX","Hiệu ứng đòn kết thúc"}}
   for i,option in options do
    local key,title=option[1],option[2]; if player:GetAttribute(key)==nil then player:SetAttribute(key,true) end
    local b
    local function update() b.Text=title.."  •  "..(if player:GetAttribute(key) then "BẬT" else "TẮT") end
    b=button(body,key,"",12,50+(i-1)*65,548,52,function() player:SetAttribute(key,not player:GetAttribute(key)); update(); callbacks.Preferences() end); update()
   end
   local sensitivity=player:GetAttribute("AimSensitivity") or 1
   local b
   local function update() b.Text="Độ nhạy khi ngắm cung  •  "..math.floor(sensitivity*100).."%" end
   b=button(body,"Sensitivity","",12,255,548,52,function()
    sensitivity=if sensitivity==1 then .75 elseif sensitivity==.75 then .5 else 1
    player:SetAttribute("AimSensitivity",sensitivity); update()
   end); update()
   label(body,"Hint","Phím: Trái / Q / E đánh • Space lướt • V nhảy\nR rút/cất • I túi đồ • F giữ khiên",0,320,572,52,14)
  end
 end
 for i,id in {"Shop","Settings","Play","Inventory"} do
  local b=Instance.new("ImageButton"); b.Name=id; b.Image=icons[id]; b.ScaleType=Enum.ScaleType.Fit
  b.Size=UDim2.fromOffset(76,76); b.Position=UDim2.fromOffset(((i-1)%2)*88,math.floor((i-1)/2)*100)
  b.BackgroundColor3=Color3.fromRGB(24,43,35); b.BackgroundTransparency=.08; b.Parent=root
  local round=Instance.new("UICorner"); round.CornerRadius=UDim.new(0,10); round.Parent=b
  local caption=label(b,"Caption",({Shop="Cửa hàng",Settings="Cài đặt",Play="Chơi",Inventory="Túi đồ"})[id],-4,76,84,20,12)
  b.Activated:Connect(function()
   if id=="Inventory" then api:Close(); callbacks.Inventory() else show(id) end
  end)
 end
 return api
end
return Hub
