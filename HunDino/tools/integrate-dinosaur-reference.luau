local meta=game:GetService('HttpService'):JSONDecode([==[{"parts":{"TRex_Skull":{"center":[123.10071563720703,30.069347381591797,-11.583619117736816],"size":[16.184402465820312,13.376136779785156,16.479440689086914],"vertices":2080,"triangles":2562},"TRex_Jaw":{"center":[122.27579498291016,25.20647430419922,-12.463027954101562],"size":[14.644668579101562,7.168033599853516,14.881936073303223],"vertices":929,"triangles":1124},"TRex_Body":{"center":[111.78375244140625,23.162599563598633,-23.53005599975586],"size":[24.63208770751953,19.39297866821289,25.464141845703125],"vertices":2251,"triangles":3188}},"headShift":[0.6183249950408936,-1.600000023841858,0.6539679765701294],"jawAngleDegrees":10,"jawPivot":[119.1336441040039,28.007801055908203,-15.72411823272705],"headCF":[122.12509155273438,30.28000259399414,-12.559682846069336,-0.7266618609428406,0.14268438518047333,-0.6720147728919983,-0.00021091103553771973,0.9781476259231567,0.20791161060333252,0.6869953274726868,0.15122318267822266,-0.7107526659965515],"bodyCF":[110.9988784790039,24.606922149658203,-24.396045684814453,-0.7266618609428406,0.14268438518047333,-0.6720147728919983,-0.00021091103553771973,0.9781476259231567,0.20791161060333252,0.6869953274726868,0.15122318267822266,-0.7107526659965515]}]==])
local m=workspace.TRex_FullBodyReference_Work local scene=assert(workspace:FindFirstChild('Scene'),'Import not ready')
local oldHead=m:FindFirstChild('head_geom',true) local oldBody=m:FindFirstChild('body_geom',true)
local headCF=oldHead.CFrame local shift=Vector3.new(table.unpack(meta.headShift))
local headParent,bodyParent=oldHead.Parent,oldBody.Parent
local parts={}
for name,info in meta.parts do
local p=assert(scene:FindFirstChild(name,true),'Missing '..name)
p.Size=Vector3.new(table.unpack(info.size)) p.CFrame=CFrame.new(Vector3.new(table.unpack(info.center)))*CFrame.Angles(0,math.pi,0)
p.Anchored=true p.CanCollide=false p.Color=Color3.new(1,1,1) p.Material=Enum.Material.Leather
local source=name=='TRex_Body' and oldBody or oldHead p.TextureID=source.TextureID
for _,child in p:GetChildren() do if child:IsA('SurfaceAppearance') then child:Destroy() end end
local sa=source:FindFirstChildOfClass('SurfaceAppearance') if sa then sa:Clone().Parent=p end
parts[name]=p
end
local upper=parts.TRex_Skull upper.Name='head_geom' upper.Parent=headParent
local jawModel=Instance.new('Model') jawModel.Name='LowerJaw' jawModel.Parent=headParent
local lower=parts.TRex_Jaw lower.Name='jaw_geom' lower.Parent=jawModel
local body=parts.TRex_Body body.Name='body_geom' body.Parent=bodyParent
local pivot=headCF*CFrame.new(0,-1.75,5)+shift
lower.PivotOffset=lower.CFrame:ToObjectSpace(pivot) jawModel.PrimaryPart=lower
local upperAttach=Instance.new('Attachment') upperAttach.Name='JawHinge' upperAttach.CFrame=upper.CFrame:ToObjectSpace(pivot) upperAttach.Parent=upper
local lowerAttach=Instance.new('Attachment') lowerAttach.Name='JawHinge' lowerAttach.CFrame=lower.CFrame:ToObjectSpace(pivot) lowerAttach.Parent=lower
local lowTeeth=Instance.new('Folder') lowTeeth.Name='Teeth' lowTeeth.Parent=jawModel
local hinge=headCF*CFrame.new(0,-1.75,5) local rot=hinge*CFrame.Angles(math.rad(meta.jawAngleDegrees),0,0)*hinge:Inverse()
local teeth=m:FindFirstChild('JawTeeth')
if teeth then for _,p in teeth:GetChildren() do if p:IsA('BasePart') then if p.CFrame.XVector:Dot(headCF.UpVector)>0 then p.CFrame=rot*p.CFrame p.Parent=lowTeeth end p.CFrame=p.CFrame+shift end end end
oldHead:Destroy() oldBody:Destroy() scene:Destroy()
m:SetAttribute('ReferenceImage','codex-clipboard-dbaed827-1ef0-42a2-8f61-52cdf7cd4122.png')
m:SetAttribute('JawSeparated',true) m:SetAttribute('ReferenceJawClosureDegrees',10)
local c=m:GetBoundingBox() local f=Vector3.new(-headCF.ZVector.X,0,-headCF.ZVector.Z).Unit local side=Vector3.new(-f.Z,0,f.X)
workspace.CurrentCamera.CFrame=CFrame.lookAt(c.Position+side*70+f*27+Vector3.new(0,11,0),c.Position) workspace.CurrentCamera.Focus=c
return 'Integrated refined skull '..upper.MeshId..'; jaw '..lower.MeshId..'; body '..body.MeshId..'; independent jaw pivot installed'

