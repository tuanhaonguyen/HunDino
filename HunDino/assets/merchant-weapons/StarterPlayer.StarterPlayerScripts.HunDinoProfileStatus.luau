-- Block only while the account is unavailable. Routine save status lives in Settings.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local Theme=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UITheme"))
local C=Theme.Colors
local connections={}
local function connect(signal,callback)
 local connection=signal:Connect(callback);table.insert(connections,connection);return connection
end
local function screen(name,order)
 local existing=playerGui:FindFirstChild(name);if existing then existing:Destroy() end
 local gui=Instance.new("ScreenGui");gui.Name=name;gui.ResetOnSpawn=false
 gui.DisplayOrder=order;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=playerGui;return gui
end
local oldHud=playerGui:FindFirstChild("HunDinoProfileStatus");if oldHud then oldHud:Destroy() end
local blocker=screen("HunDinoProfileGate",10000)
local function text(parent,name,value,position,size,fontSize)
 local label=Instance.new("TextLabel");label.Name=name;label.Text=value;label.BackgroundTransparency=1
 label.Position=position;label.Size=size;label.Font=Enum.Font.GothamMedium;label.TextSize=fontSize or 13
 label.TextColor3=C.Text;label.TextWrapped=true;label.Parent=parent;return label
end
local function button(parent,name,title,position,size)
 local item=Instance.new("TextButton");item.Name=name;item.Text=title;item.Position=position;item.Size=size
 item.Font=Enum.Font.GothamMedium;item.TextSize=13;item.Parent=parent;Theme.button(item);return item
end
local curtain=Instance.new("TextButton");curtain.Name="LoadingShield";curtain.Text="";curtain.AutoButtonColor=false
curtain.BackgroundColor3=Color3.fromRGB(5,8,13);curtain.BackgroundTransparency=.12
curtain.Size=UDim2.fromScale(1,1);curtain.Active=true;curtain.Modal=true;curtain.Parent=blocker
local panel=Instance.new("Frame");panel.Name="ProfileGate";panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.fromOffset(510,238);panel.Parent=curtain;Theme.panel(panel)
local title=text(panel,"Heading","ĐANG TẢI HỒ SƠ",UDim2.fromOffset(24,22),UDim2.new(1,-48,0,34),21)
title.Font=Enum.Font.GothamBold;title.TextColor3=C.Gold
local detail=text(panel,"Detail","Đang khôi phục trang bị và tiến trình của bạn…",UDim2.fromOffset(26,67),UDim2.new(1,-52,0,92),15)
local retry=button(panel,"RetryLoad","THỬ TẢI LẠI",UDim2.new(.5,-106,1,-62),UDim2.fromOffset(212,40))
local scale=Instance.new("UIScale");scale.Parent=panel
local nextRetryAt=0
local function request(action)
 local remote=ReplicatedStorage:FindFirstChild("HunDinoProfileAction")
 if remote and remote:IsA("RemoteEvent") then remote:FireServer(action);return true end
 return false
end
local failures={Error=true,Unavailable=true,Conflict=true}
local function refresh()
 local ready=player:GetAttribute("ProfileReady")==true
 local state=player:GetAttribute("ProfileSaveState") or "Loading"
 local notice=player:GetAttribute("ProfileStatusText")
 blocker.Enabled=not ready or state=="Conflict"
 local failed=failures[state]==true
 title.Text=if failed then "CHƯA TẢI ĐƯỢC HỒ SƠ" else "ĐANG TẢI HỒ SƠ"
 detail.Text=if type(notice)=="string" and notice~="" then notice elseif failed then "Tiến trình chưa tải được. Thử tải lại để tiếp tục với dữ liệu đã có." else "Đang khôi phục trang bị, vật phẩm và tiến trình của bạn…"
 retry.Visible=failed;retry.Active=failed and os.clock()>=nextRetryAt
 retry.Text=if os.clock()<nextRetryAt then "ĐANG THỬ LẠI…" else "THỬ TẢI LẠI"
 retry.TextTransparency=if retry.Active then 0 else .5
 local camera=workspace.CurrentCamera
 if camera then
  local size=camera.ViewportSize
  scale.Scale=math.min(1,math.max(.25,(size.X-32)/510),math.max(.25,(size.Y-40)/238))
 end
end
connect(retry.Activated,function()
 if not retry.Active then return end
 if request("RetryLoad") then nextRetryAt=os.clock()+5 end
 refresh()
end)
for _,name in {"ProfileReady","ProfileSaveState","ProfileStatusText"} do connect(player:GetAttributeChangedSignal(name),refresh) end
local elapsed=0
connect(RunService.Heartbeat,function(dt)
 if not blocker.Enabled then return end
 elapsed+=dt;if elapsed>=.25 then elapsed=0;refresh() end
end)
script.Destroying:Connect(function()
 for _,connection in connections do connection:Disconnect() end
 blocker:Destroy()
end)
refresh()
