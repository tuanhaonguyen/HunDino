-- Locate earlier tube placement fixes by reading saved files, never serializing.
local fs=require('@lune/fs')
local r=require('@lune/roblox')
local serde=require('@lune/serde')
local files={}
for _,file in fs.readDir('.') do if file:match('%.rbxl$') and file:match('HunDino') then table.insert(files,file) end end
for _,file in {'backups/bow-pet-20261026/SaveGame_AutoRecovery_20261022.rbxl','backups/Hub_v24_before_5_specimen_tubes_20261021.rbxl'} do if fs.isFile(file) then table.insert(files,file) end end
table.sort(files)
local report={}
local function at(o,path)for name in path:gmatch('[^.]+') do o=o and o:FindFirstChild(name) end return o end
for _,file in files do
 local root=r.deserializePlace(fs.readFile(file))
 local tubes=at(root,'Workspace.SpecimenTubeDisplays')
 local row={File=file,HasTubes=tubes~=nil}
 if tubes then
  row.Version=tubes:GetAttribute('GeometryVersion');row.Bases={};row.ArrivalsWithinTubeRadius={}
  for id=1,12 do
   local a=at(root,'Workspace.HunDinoL0.BaseTransit.Bases.Base'..id..'.Arrival')
   local c=tubes:FindFirstChild('Base'..id)
   if a and c then
    local nearest,slot=math.huge,0
    for _,tube in c:GetChildren() do
     local origin=tube:GetAttribute('StaticOrigin')
     if typeof(origin)=='CFrame' then local delta=origin.Position-a.CFrame.Position;local distance=r.Vector3.new(delta.X,0,delta.Z).Magnitude
      if distance<nearest then nearest=distance;slot=tube:GetAttribute('DisplaySlot') end
     end
    end
    table.insert(row.Bases,{Id=id,NearestTube=slot,Distance=nearest,Cluster=tostring(c:GetAttribute('ClusterOrigin')),Arrival=tostring(a.CFrame)})
    if nearest<8 then table.insert(row.ArrivalsWithinTubeRadius,id) end
   end
  end
 end
 table.insert(report,row)
 print(file,'tubes='..tostring(row.HasTubes),row.ArrivalsWithinTubeRadius)
 root:Destroy()
end
fs.writeFile('assets/hunting/base-tube-history.json',serde.encode('json',report,true))
