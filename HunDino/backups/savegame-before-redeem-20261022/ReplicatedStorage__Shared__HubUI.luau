-- Quick-access UI. Account preferences are validated and acknowledged by the server.
local Hub={}
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Theme=require(script.Parent:WaitForChild("UITheme"))
local C=Theme.Colors
local icons={Shop="rbxassetid://101717469378295",Settings="rbxassetid://119955450343925",Play="rbxassetid://115198627543926",Inventory="rbxassetid://82181506096525"}
function Hub.create(player,gui,callbacks)
 local root=Instance.new("Frame"); root.Name="QuickAccess"; root.BackgroundTransparency=1
 root.Size=UDim2.fromOffset(144,148); root.Position=UDim2.new(1,-164,0,14); root.Parent=gui
 local rootScale=Instance.new("UIScale"); rootScale.Parent=root
 local shield=Instance.new("TextButton"); shield.Name="HubShield"; shield.Size=UDim2.fromScale(1,1); shield.BackgroundColor3=Color3.fromRGB(5,8,13); shield.BackgroundTransparency=.38; shield.Text=""; shield.AutoButtonColor=false; shield.Visible=false; shield.ZIndex=29; shield.Parent=gui
 local overlay=Instance.new("Frame"); overlay.Name="HubPanel"; overlay.AnchorPoint=Vector2.new(.5,.5)
 overlay.Position=UDim2.fromScale(.5,.5); overlay.Size=UDim2.fromOffset(620,480); overlay.BackgroundColor3=Color3.fromRGB(18,34,31)
 overlay.Visible=false; overlay.ZIndex=30; overlay.Parent=gui
 Theme.panel(overlay)
 local scale=Instance.new("UIScale"); scale.Parent=overlay
 local oldOrder
 local function resize()
  local camera=workspace.CurrentCamera; if not camera then return end
  local size=camera.ViewportSize
  scale.Scale=math.min(1,(size.X-32)/620,(size.Y-70)/480)
  rootScale.Scale=if size.X<760 or size.Y<650 then .78 else 1
  root.Position=UDim2.new(1,-20-144*rootScale.Scale,0,14)
 end
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize); resize()
 local function label(parent,name,value,x,y,w,h,size)
  local t=Instance.new("TextLabel"); t.Name=name; t.Text=value; t.Font=Enum.Font.GothamMedium; t.TextSize=size or 16
  t.TextWrapped=true; t.TextColor3=C.Text; t.BackgroundTransparency=1; t.ZIndex=parent.ZIndex+1
  t.Position=UDim2.fromOffset(x,y); t.Size=UDim2.fromOffset(w,h); t.Parent=parent; return t
 end
 local heading=label(overlay,"Heading","",24,20,530,40,24)
 heading.TextXAlignment=Enum.TextXAlignment.Left; heading.TextColor3=C.Gold; heading.Font=Enum.Font.GothamBold
 local body=Instance.new("Frame"); body.Name="Body"; body.Position=UDim2.fromOffset(24,76); body.Size=UDim2.fromOffset(572,380); body.BackgroundTransparency=1; body.Parent=overlay
 local function button(parent,name,value,x,y,w,h,onClick)
  local b=Instance.new("TextButton"); b.Name=name; b.Text=value; b.TextWrapped=true; b.Font=Enum.Font.GothamMedium; b.TextSize=16
  b.TextColor3=C.Text; b.BackgroundColor3=C.Card; b.ZIndex=parent.ZIndex+1
  b.Size=UDim2.fromOffset(w,h); b.Position=UDim2.fromOffset(x,y); b.Parent=parent
  Theme.button(b); b.Activated:Connect(onClick); return b
 end
 local api={}
 local bodyConnections={}
 local function watchAttribute(name,callback)
  table.insert(bodyConnections,player:GetAttributeChangedSignal(name):Connect(callback))
 end
 local function accountStatus()
  if player:GetAttribute("ProfileStorageMode")=="TestMemory" then return "CHẾ ĐỘ THỬ: dữ liệu chỉ trong phiên, chưa lưu tài khoản." end
  if player:GetAttribute("ProfileReady")~=true then return player:GetAttribute("ProfileStatusText") or "Đang tải hồ sơ tài khoản…" end
  local state=player:GetAttribute("ProfileSaveState")
  if state=="Dirty" then return "Hồ sơ đã thay đổi; đang chờ tự động lưu." end
  if state=="Saving" or state=="Closing" then return "Đang lưu hồ sơ tài khoản…" end
  if state=="Error" or state=="Unavailable" or state=="Conflict" then return player:GetAttribute("ProfileStatusText") or "Chưa lưu được hồ sơ. Xem trạng thái lưu phía trên." end
  local saved=player:GetAttribute("ProfileSavedAt")
  if type(saved)=="number" and saved>0 then return (if player:GetAttribute("ProfileStorageMode")=="LocalFile" then "Đã lưu trên máy lúc " else "Đã lưu tài khoản lúc ")..os.date("!%H:%M:%S",saved+7*3600).." (UTC+7)." end
  return player:GetAttribute("ProfileStatusText") or "Đã tải hồ sơ tài khoản; thay đổi được tự động lưu."
 end
 local function watchAccount(callback)
  for _,name in {"ProfileReady","ProfileSaveState","ProfileStatusText","ProfileSavedAt","ProfileStorageMode"} do watchAttribute(name,callback) end
  callback()
 end
 local function preference(key,value)
  if player:GetAttribute("ProfileReady")~=true then return end
  local remote=ReplicatedStorage:FindFirstChild("HunDinoProfileAction")
  if remote and remote:IsA("RemoteEvent") then remote:FireServer("Preference",key,value) end
 end
 function api:IsOpen() return overlay.Visible end
 function api:Close()
  overlay.Visible=false; shield.Visible=false
  if oldOrder~=nil then gui.DisplayOrder=oldOrder;oldOrder=nil end
  callbacks.Preferences()
 end
 shield.Activated:Connect(function() api:Close() end)
 button(overlay,"Close","×",566,18,34,34,function() api:Close() end)
 local function show(id)
  for _,connection in bodyConnections do connection:Disconnect() end;table.clear(bodyConnections)
  callbacks.BeforeOpen(); body:ClearAllChildren(); overlay.Visible=true; shield.Visible=true
  if oldOrder==nil then oldOrder=gui.DisplayOrder end; gui.DisplayOrder=math.max(gui.DisplayOrder,60); callbacks.Preferences()
  heading.Text=({Shop="THƯƠNG NHÂN",Settings="CÀI ĐẶT",Play="BẮT ĐẦU HÀNH TRÌNH"})[id]
  if id=="Play" then
   label(body,"Intro","Trại thợ săn • 12 base\nNhận nhiệm vụ T-REX hoặc khám phá thung lũng tự do.",0,0,572,64)
   local hunting=player:GetAttribute("InHunting")==true
   button(body,"Quest","NHIỆM VỤ · HẠ HOẶC BẮT T-REX",36,66,500,48,function()
    api:Close(); game.ReplicatedStorage.HunDinoTrainingAction:FireServer("QuestBoard")
   end)
   button(body,"Hunting",if hunting then "ĐANG Ở THUNG LŨNG SƯƠNG XÁM" else "THÁM HIỂM · THUNG LŨNG SƯƠNG XÁM",36,124,500,48,function()
    api:Close(); if not player:GetAttribute("InHunting") then callbacks.Travel("Hunting") end
   end)
   button(body,"Training","VÀO BÃI LUYỆN TẬP",36,182,500,48,function() api:Close(); callbacks.Travel("Training") end)
   button(body,"Lobby","VỀ SẢNH TRUNG TÂM",36,240,500,48,function() api:Close(); callbacks.Travel("Lobby") end)
   label(body,"Hunts","Săn solo 40 phút, 3 lần hồi sinh. Hạ hoặc bắt nhận thưởng; vật tư và tiến trình xem trong Túi đồ.",20,301,532,64)
  elseif id=="Shop" then
   label(body,"Intro","TIẾP TẾ · CHẾ TẠO",0,0,572,44,18)
   label(body,"Stock","Trap: 10 xu · Thuốc ngủ: 10 xu\nĐến quầy tiếp tế ở sảnh để mua.\n1 Trap + 1 sắt → 1 bẫy sắt tại base của bạn.\nBúa cấp 2: 2 xương + 2 sắt · sát thương +15%.",20,60,532,150,17)
   button(body,"OpenMerchant","MỞ QUẦY TIẾP TẾ KHI Ở GẦN",36,224,500,48,function()
    api:Close();game:GetService("ReplicatedStorage"):WaitForChild("HunDinoEconomyAction"):FireServer("OpenMerchant")
   end)
   local status=label(body,"Status","",12,290,548,64,15)
   watchAccount(function() status.Text=accountStatus().."\nVũ khí luyện tập vẫn chọn trong Túi đồ." end)
  else
   local intro=label(body,"Intro","",0,0,572,40,14)
   watchAccount(function() intro.Text=accountStatus() end)
   local options={{"ShowComboGuide","Hướng dẫn combo"},{"ShowDamage","Số sát thương"},{"ShowComboFX","Hiệu ứng đòn kết thúc"}}
   for i,option in options do
    local key,title=option[1],option[2]
    local b
    local function update()
     b.Text=title.."  •  "..(if player:GetAttribute(key)~=false then "BẬT" else "TẮT")
     b.Active=player:GetAttribute("ProfileReady")==true;b.TextTransparency=if b.Active then 0 else .45
     callbacks.Preferences()
    end
    b=button(body,key,"",12,50+(i-1)*65,548,52,function() preference(key,player:GetAttribute(key)==false) end)
    watchAttribute(key,update);watchAttribute("ProfileReady",update);update()
   end
   local b
   local function update()
    local sensitivity=player:GetAttribute("AimSensitivity") or 1
    b.Text="Độ nhạy khi ngắm cung  •  "..math.floor(sensitivity*100).."%"
    b.Active=player:GetAttribute("ProfileReady")==true;b.TextTransparency=if b.Active then 0 else .45
   end
   b=button(body,"Sensitivity","",12,255,548,52,function()
    local current=player:GetAttribute("AimSensitivity") or 1
    preference("AimSensitivity",if current==1 then .75 elseif current==.75 then .5 else 1)
   end)
   watchAttribute("AimSensitivity",update);watchAttribute("ProfileReady",update);update()
   label(body,"Hint","Phím: Trái / Q / E đánh • Space lướt • V nhảy\nR rút/cất • I túi đồ • F giữ khiên",0,320,572,52,14)
  end
 end
 root.Destroying:Connect(function() for _,connection in bodyConnections do connection:Disconnect() end;table.clear(bodyConnections) end)
 for i,id in {"Shop","Settings","Play","Inventory"} do
  local b=Instance.new("ImageButton"); b.Name=id; b.Image=icons[id]; b.ScaleType=Enum.ScaleType.Fit
  b.Size=UDim2.fromOffset(58,52); b.Position=UDim2.fromOffset(((i-1)%2)*78,math.floor((i-1)/2)*78)
  b.BackgroundColor3=C.Card; b.BackgroundTransparency=.12; b.Parent=root; Theme.button(b)
  local padding=Instance.new("UIPadding"); padding.PaddingTop=UDim.new(0,5);padding.PaddingBottom=UDim.new(0,5);padding.PaddingLeft=UDim.new(0,5);padding.PaddingRight=UDim.new(0,5);padding.Parent=b
  local caption=label(b,"Caption",({Shop="Cửa hàng",Settings="Cài đặt",Play="Chơi",Inventory="Túi đồ"})[id],-8,50,74,20,11)
  caption.TextColor3=C.Muted
  b.Activated:Connect(function()
   if id=="Inventory" then api:Close(); callbacks.Inventory() else show(id) end
  end)
 end
 return api
end
return Hub
