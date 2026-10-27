-- Temporary Play driver; may only run against explicitly disposable storage.
local Players=game:GetService('Players')
local Http=game:GetService('HttpService')
local api=require(game.ServerScriptService.HuntingRuntime.HuntEconomyService)
local p=Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
assert(p:GetAttribute('ProfileStorageMode')=='TestMemory','QA cannot touch a real account')
local service=assert(api.current())
local transit=workspace.HunDinoL0.BaseTransit
local initialBase=p:GetAttribute('BaseId')
local report={Version='BaseClearancePlay.1',Cases={},Storage='TestMemory',RealAccountDataTouched=false}
local control=Instance.new('BindableFunction');control.Name='Control';control.Parent=script
local function snapshot(id)
 local s=service.GetState(p)
 local query=OverlapParams.new();query.FilterType=Enum.RaycastFilterType.Include
 query.FilterDescendantsInstances={workspace.SpecimenTubeDisplays};query.RespectCanCollide=true
 local hits=workspace:GetPartBoundsInBox(CFrame.new(s.Root.Position+Vector3.new(0,1,0)),Vector3.new(4,5,4),query)
 return {Base=id,Root={s.Root.Position.X,s.Root.Position.Y,s.Root.Position.Z},TubeBlockers=#hits,
  DistanceFromArrival=(s.Root.Position-transit.Bases['Base'..id].Arrival.Position).Magnitude,
  DistanceFromCenter=(s.Root.Position-transit.Center.Arrival.Position).Magnitude,
  Area=p:GetAttribute('Area'),BaseOwnershipPreserved=p:GetAttribute('BaseId')==initialBase,
  ProfileReady=p:GetAttribute('ProfileReady')}
end
control.OnInvoke=function(command,id,details)
 local s=service.GetState(p)
 if command=='Prepare' then
  assert(not s.Drawn and not s.InHunting and not s.InTraining,'Actor should be in quiet lobby')
  s.Character:PivotTo(transit.Center.Arrival.CFrame)
  s.Root.AssemblyLinearVelocity=Vector3.zero;s.Root.AssemblyAngularVelocity=Vector3.zero
  s.BusyUntil=0;s.BaseTransitUntil=nil
  return {AtCenter=true,Position=tostring(s.Root.Position)}
 elseif command=='Snapshot' then return snapshot(id)
 elseif command=='Record' then
  local row=snapshot(id);row.Arrived=details.Arrived;row.WalkDistance=details.WalkDistance
  row.ReturnedViaG=details.ReturnedViaG
  assert(row.BaseOwnershipPreserved,'Visiting another base changed ownership')
  assert(row.DistanceFromCenter<10,'G did not return to central lobby')
  assert(row.Arrived and row.WalkDistance>=8 and row.ReturnedViaG,'Transit/walking case failed')
  table.insert(report.Cases,row)
  return row
 elseif command=='Finish' then
  assert(#report.Cases==12,'Must exercise all twelve bases')
  report.Ok=true;report.BaseCount=#report.Cases
  Http:PostAsync('http://127.0.0.1:18770/qa',Http:JSONEncode(report),Enum.HttpContentType.ApplicationJson)
  return report
 end
end
