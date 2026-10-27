-- Native geometry survey only. Does not move or rebuild the map.
local Planner={}
local V=Vector3.new
local offsets={V(-28,0,-10),V(-15,0,0),V(15,0,0),V(28,0,-10),V(0,0,5)}
local excluded={Ground=true,SpawnPad=true,TerraceFoundation=true,InlaidRuneRing=true}
local function distanceToSegment(p,a,b)
 local d=b-a;local t=if d:Dot(d)>.0001 then math.clamp((p-a):Dot(d)/d:Dot(d),0,1) else 0
 return (p-a-d*t).Magnitude
end
function Planner.run()
 local world=workspace.SpecimenTubeDisplays
 local all={}
 for _,p in workspace:GetDescendants() do
  if p:IsA('BasePart') and not p:IsA('Terrain') and not p:IsDescendantOf(world) and p.Transparency<.95 and not excluded[p.Name] then table.insert(all,p) end
 end
 local report={Bases={},Version='BaseClearance.1',TubeRadius=6.3,WalkCorridorRadius=9.5}
 for id=1,12 do
  local base=workspace.DarkJungle.Bases['Base'..id]
  local transit=workspace.HunDinoL0.BaseTransit.Bases['Base'..id]
  local spawn=base.SpawnPad.Position
  local back=base.ShelterFloor.Position-spawn;back=V(back.X,0,back.Z).Unit
  local ground=CFrame.fromMatrix(V(spawn.X,spawn.Y-.3,spawn.Z),Vector3.yAxis:Cross(back),Vector3.yAxis,back)
  local arrival=ground:PointToObjectSpace(transit.Arrival.Position);arrival=V(arrival.X,0,arrival.Z)
  local entry=arrival.Unit*66 -- Keep the route to/from the central camp open too.
  local corridorEnd=V(0,0,0)
  local obstacles={}
  local function add(cf,size,name)
   local low,high=Vector3.one*math.huge,-Vector3.one*math.huge
   for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
    local at=ground:PointToObjectSpace(cf:PointToWorldSpace(size*V(x,y,z)*.5))
    low=V(math.min(low.X,at.X),math.min(low.Y,at.Y),math.min(low.Z,at.Z))
    high=V(math.max(high.X,at.X),math.max(high.Y,at.Y),math.max(high.Z,at.Z))
   end end end
   if high.Y>1.5 and low.Y<19.2 then table.insert(obstacles,{Low=low,High=high,Name=name}) end
  end
  for _,p in all do if (p.Position-spawn).Magnitude<110+p.Size.Magnitude*.5 then add(p.CFrame,p.Size,p:GetFullName()) end end
  local station=transit.Arrival.CFrame*CFrame.new(13,-3,0)
  add(station*CFrame.new(0,2.2,0),V(8,.7,3.4),'RuntimeCraftCounter')
  add(station*CFrame.new(-1.7,3.1,0),V(2.2,1.2,1.5),'RuntimeCraftSupplies')
  add(station*CFrame.new(0,5,1.3),V(8,2,.35),'RuntimeCraftSign')
  local groundRay=RaycastParams.new();groundRay.FilterType=Enum.RaycastFilterType.Include;groundRay.FilterDescendantsInstances={base.Ground,base.SpawnPad}
  local function valid(origin)
   local minCorridor=math.huge
   for _,offset in offsets do
    local center=ground:PointToObjectSpace(origin:PointToWorldSpace(offset));center=V(center.X,0,center.Z)
    local clearance=distanceToSegment(center,entry,corridorEnd)
    minCorridor=math.min(minCorridor,clearance)
    if clearance<report.WalkCorridorRadius then return false,'Transit corridor' end
    for _,o in obstacles do
     local dx=math.max(o.Low.X-center.X,0,center.X-o.High.X)
     local dz=math.max(o.Low.Z-center.Z,0,center.Z-o.High.Z)
     if dx*dx+dz*dz<report.TubeRadius^2 then return false,o.Name end
    end
    for _,d in {Vector3.zero,V(5,0,0),V(-5,0,0),V(0,0,5),V(0,0,-5)} do
     local point=origin:PointToWorldSpace(offset+d)
     local hit=workspace:Raycast(point+V(0,3,0),V(0,-6,0),groundRay)
     if not hit then return false,'Unsupported tube' end
    end
   end
   return true,minCorridor
  end
  local cluster=world['Base'..id]
  local first=cluster.BioTube_1
  local actualFrame=first.TubeRoot.CFrame*CFrame.new(0,-.025,0)*first:GetAttribute('StaticOrigin'):Inverse()*cluster:GetAttribute('ClusterOrigin')
  -- Remove tiny inherited serialization scale before deriving rigid poses.
  actualFrame=CFrame.lookAt(actualFrame.Position,actualFrame.Position+actualFrame.LookVector,Vector3.yAxis)
  local old=ground:ToObjectSpace(actualFrame)
  local oldYaw=select(2,old:ToOrientation())
  local oldValid,oldReason=valid(actualFrame)
  local best,bestScore,bestClear
  if oldValid then best,bestScore,bestClear=actualFrame,0,oldReason else
   for distance=2,34,2 do for shift=-28,28,2 do
    if math.abs(shift)>distance then continue end
    local frame=ground*CFrame.new(shift,0,distance)
    local ok,clear=valid(frame)
    local score=(shift-old.Position.X)^2+(distance-old.Position.Z)^2
    if ok and (not bestScore or score<bestScore) then best,bestScore,bestClear=frame,score,clear end
   end end
   if not best then
    for distance=-60,60,4 do for shift=-60,60,4 do
     local center=V(shift,0,distance)
     if center.Magnitude<28 or center.Magnitude>66 then continue end
     local localFrame=CFrame.lookAt(center,Vector3.zero,Vector3.yAxis)
     local frame=ground*localFrame
     local ok,clear=valid(frame)
     local score=(shift-old.Position.X)^2+(distance-old.Position.Z)^2
     if ok and (not bestScore or score<bestScore) then best,bestScore,bestClear=frame,score,clear end
    end end
   end
  end
  local row={Id=id,BeforeValid=oldValid,BeforeReason=if oldValid then nil else oldReason,
   OldFrame={actualFrame:GetComponents()},ObstacleCount=#obstacles}
  if best then
   local relative=ground:ToObjectSpace(best)
   row.Distance=relative.Position.Z;row.ShiftX=relative.Position.X;row.YawDegrees=math.deg(select(2,relative:ToOrientation()))
   row.Frame={best:GetComponents()};row.MoveDistance=(best.Position-actualFrame.Position).Magnitude;row.MinCorridorDistance=bestClear
  else row.Error='No valid placement' end
  table.insert(report.Bases,row)
  task.wait()
 end
 return report
end
return Planner
