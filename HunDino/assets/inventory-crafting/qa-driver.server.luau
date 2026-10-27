-- Installed in disposable Play only; never saved into the main place.
local Players=game:GetService('Players')
local E=require(game.ServerScriptService.HuntingRuntime.HuntEconomyRules)
local api=require(game.ServerScriptService.HuntingRuntime.HuntEconomyService)
local p=Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
assert(p:GetAttribute('ProfileStorageMode')=='TestMemory','Never seed real progress')
local service=assert(api.current())
local control=Instance.new('BindableFunction');control.Name='Control';control.Parent=script
control.OnInvoke=function(command)
 local profile=service:Profile(p)
 local state=service.GetState(p)
 if command=='Setup' then
  profile.StoredConsumables.RawTrap=2;profile.Materials.Iron=2
  state.Root.CFrame=CFrame.new(service.Stations[p:GetAttribute('BaseId')].Position+Vector3.new(0,0,-6))
  state.Root.AssemblyLinearVelocity=Vector3.zero
  service:Publish(p)
 elseif command=='Away' then
  state.Root.CFrame=CFrame.new(service.Stations[p:GetAttribute('BaseId')].Position+Vector3.new(30,0,0))
  service:Publish(p)
 elseif command=='OneMissing' then
  profile.StoredConsumables.RawTrap=1;profile.Materials.Iron=0;service:Publish(p)
 end
 return E.snapshot(profile)
end
