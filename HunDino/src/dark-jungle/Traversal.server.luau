-- Map safety only: shallow decorative water and cliff falls return to sanctuary.
-- No PvP, loot, paid actions or persistent data are introduced here.
local Players=game:GetService('Players')
local PetPlacement=require(game:GetService('ReplicatedStorage'):WaitForChild('Shared'):WaitForChild('PetPlacement'))
local root=workspace:WaitForChild('HunDinoL0')
local arrival=root.Lobby:WaitForChild('Arrival')
local active=true
script.Destroying:Connect(function() active=false end)
while active do
 task.wait(.5)
 for _,player in Players:GetPlayers() do
  local character=player.Character
  local hrp=character and character:FindFirstChild('HumanoidRootPart')
  local hum=character and character:FindFirstChildOfClass('Humanoid')
  if hrp and hum and hum.Health>0 and player:GetAttribute('InHunting')~=true and hrp.Position.Y < -16 then
   character:PivotTo(arrival.CFrame)
   hrp.AssemblyLinearVelocity=Vector3.zero
   local petFolder=workspace:FindFirstChild('TrainingPets')
   local pet=petFolder and petFolder:FindFirstChild('Pet_'..player.UserId)
   if pet then pet:SetAttribute('PetAttackStarted', -1); PetPlacement.place(pet,character,arrival.CFrame,petFolder) end
  end
 end
end
