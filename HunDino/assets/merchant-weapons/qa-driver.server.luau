-- Temporary Studio Play driver, installed only in the isolated TestMemory session.
local Http=game:GetService('HttpService')
local Players=game:GetService('Players')
local E=require(game.ServerScriptService.HuntingRuntime.HuntEconomyRules)
local Service=require(game.ServerScriptService.HuntingRuntime.HuntEconomyService)
local player=Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
assert(player:GetAttribute('ProfileStorageMode')=='TestMemory','QA requires disposable storage')
local service=assert(Service.current(),'Runtime service not ready')
local control=Instance.new('BindableFunction');control.Name='Control';control.Parent=script
local function data()
 local profile=service:Profile(player)
 return {Profile=E.snapshot(profile),CanBuy=service:_context(player,'Merchant'),CanCraft=service:_context(player,'Craft'),
  Offer=service.Offers[player],Multipliers=(function() local values={} for _,id in E.WeaponOrder do values[id]=service:DamageMultiplier(player,id) end return values end)()}
end
control.OnInvoke=function(command,payload)
 if command=='Merchant' then
  local profile=service:Profile(player);profile.Materials.Bone=14;profile.Materials.Iron=15
  local state=service.GetState(player)
  state.Root.CFrame=CFrame.new(service.Stations.Merchant.Position+Vector3.new(0,0,-6));state.Root.AssemblyLinearVelocity=Vector3.zero
  service:Publish(player)
 elseif command=='Craft' then
  local station=service.Stations[player:GetAttribute('BaseId')]
  local state=service.GetState(player)
  state.Root.CFrame=CFrame.new(station.Position+Vector3.new(0,0,-6));state.Root.AssemblyLinearVelocity=Vector3.zero
  service:Publish(player)
 elseif command=='Request' then
  service.LastRequest[player]=-math.huge
  service:Request(player,payload.Action,payload.Payload)
 elseif command=='Snapshot' then
  return data()
 elseif command=='RefreshPurchase' then
  service.LastRequest[player]=-math.huge
  service:Request(player,'RefreshShop')
  local token=service.Offers[player].Token
  local coins=service:Profile(player).Coins
  service:Request(player,'MerchantBuyTrap',token)
  assert(service:Profile(player).Coins==coins-10,'Refresh must not rate-limit a legitimate purchase')
  return {Ok=true,Coins=service:Profile(player).Coins}
 elseif command=='Security' then
  local profile=service:Profile(player)
  local revision,bones,iron=profile.Revision,profile.Materials.Bone,profile.Materials.Iron
  local function request(payload)
   service.LastRequest[player]=-math.huge
   service:Request(player,'UpgradeWeapon',payload)
   assert(profile.Revision==revision and profile.Materials.Bone==bones and profile.Materials.Iron==iron,'Forged request changed data')
  end
  local function payload()
   return {WeaponId='Bow',OperationToken=service.Offers[player].Token,SnapshotVersion=profile.Revision,OperationSerial=profile.OperationSerial+1}
  end
  local v=payload();v.OperationToken='forged';request(v)
  v=payload();v.SnapshotVersion-=1;request(v)
  v=payload();v.OperationSerial+=1;request(v)
  v=payload();v.WeaponId='Unknown';request(v)
  local state=service.GetState(player);local old=state.Root.CFrame
  local other=player:GetAttribute('BaseId')%12+1
  state.Root.CFrame=CFrame.new(service.Stations[other].Position+Vector3.new(0,0,-6))
  request(payload())
  state.Root.CFrame=old
  service:Publish(player)
  return {Ok=true,Rejected=5,Revision=profile.Revision}
 elseif command=='RoundTrip' then
  local schema=require(game.ServerScriptService.AccountData.ProfileSchema).new(E)
  local wrapped=schema.Default(os.time());wrapped.Economy=service:Profile(player)
  local encoded=assert(schema.Encode(wrapped))
  local decoded=assert(schema.Decode(Http:JSONDecode(Http:JSONEncode(encoded))))
  for _,id in E.WeaponOrder do assert(decoded.Economy.WeaponLevels[id]==wrapped.Economy.WeaponLevels[id],id) end
  return {Ok=true,WeaponLevels=decoded.Economy.WeaponLevels,Coins=decoded.Economy.Coins,Revision=decoded.Economy.Revision}
 end
 return data()
end
script:SetAttribute('Ready',true)
