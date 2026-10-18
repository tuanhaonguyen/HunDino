-- Standalone hunting map: environment clock and prototype patrol; mission/hub integration follows.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Config=require(ReplicatedStorage:WaitForChild("HuntingMapConfig"))
local root=workspace:WaitForChild("HuntingRainforest")
local Clock=require(script.Parent:WaitForChild("EnvironmentClock"))
local Routes=require(script.Parent:WaitForChild("DinosaurRouteController"))
local clock=Clock.new(root,Config)
clock:Start()
local patrol
local remote=Instance.new("RemoteEvent");remote.Name="HuntingMapPreviewJump";remote.Parent=ReplicatedStorage
local cooldown={}
local function moveTo(player,id)
	local zone
	for _,q in Config.Zones do if q.id==id then zone=q;break end end
	if not zone then return end
	local character=player.Character;local hum=character and character:FindFirstChildOfClass("Humanoid")
	local hrp=character and character:FindFirstChild("HumanoidRootPart")
	if not hrp or not hum or hum.Health<=0 then return end
	local p=Config.position(zone)
	-- Land beside the prototype's footprint rather than inside its body.
	local offset=if id=="A" then Vector3.new(65,6,35) else Vector3.new(0,6,26)
	character:PivotTo(CFrame.lookAt(p+offset,p+Vector3.new(0,6,0)))
	hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero
end
remote.OnServerEvent:Connect(function(player,id)
	if not RunService:IsStudio() or type(id)~="string" then return end
	local now=os.clock();if now-(cooldown[player] or -math.huge)<.35 then return end
	cooldown[player]=now;moveTo(player,id)
end)
Players.PlayerRemoving:Connect(function(player) cooldown[player]=nil end)
local active=true
script.Destroying:Connect(function()
	active=false
	if patrol then patrol:Destroy(true) end
	clock:Destroy();remote:Destroy()
end)
local prototype=workspace:WaitForChild("Dinosaur01_TRex_Visual")
patrol=Routes.new(prototype,root,Config)
patrol:Start()
task.spawn(function()
	while active do
		task.wait(.75)
		for _,player in Players:GetPlayers() do
			local c=player.Character;local p=c and c:FindFirstChild("HumanoidRootPart")
			if p and (p.Position.Y<Config.TerrainMin-20 or math.abs(p.Position.X)>920 or math.abs(p.Position.Z)>920) then moveTo(player,"Camp") end
		end
	end
end)
