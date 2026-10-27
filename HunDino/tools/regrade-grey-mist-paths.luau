-- EDIT-only maintenance after changing the H2 grading profile.
-- Install fresh config modules first, then rebuild native Terrain/foundations.
assert(not game:GetService("RunService"):IsRunning(),"Edit only")
local RS=game:GetService("ReplicatedStorage")
local C=require(RS.HuntingMapConfig)
local B=require(RS.HuntingBaseConfig)
local root=assert(workspace:FindFirstChild("HuntingRainforest"))
assert(C.Version=="H2.0" and root:GetAttribute("Version")=="H2.0","H2 only")
local count=0
for _,group in {{B.Edges,72},{B.HumanPaths,24}} do
	for _,edge in group[1] do
		local path=assert(root.Paths:FindFirstChild(edge.a.."_"..edge.b))
		for _,p in path:GetChildren() do if p.Name=="WalkSurface" then p:Destroy() end end
		local points=C.samples(edge,16)
		for i=1,#points-1 do
			local a,b=points[i]+Vector3.new(0,.2,0),points[i+1]+Vector3.new(0,.2,0)
			local p=Instance.new("Part");p.Name="WalkSurface"
			p.Size=Vector3.new(group[2],2,(b-a).Magnitude+2)
			p.CFrame=CFrame.lookAt((a+b)/2-Vector3.new(0,1,0),b-Vector3.new(0,1,0))
			p.Anchored=true;p.CanCollide=true;p.CanQuery=true;p.CanTouch=false
			p.Transparency=1;p.CastShadow=false;p.Material=Enum.Material.Ground
			p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
			p:SetAttribute("SampleIndex",i);p:SetAttribute("RouteStart",a);p:SetAttribute("RouteEnd",b)
			p:SetAttribute("WalkWidth",group[2]);p.Parent=path;count+=1
		end
		task.wait()
	end
end
local moved=0
for _,name in {"Forest","Understory","Outcrops"} do
	local folder=root.Decor:FindFirstChild(name)
	if not folder then continue end
	for _,m in folder:GetChildren() do
		local p=m:GetAttribute("GroundPosition")
		if m:IsA("Model") and typeof(p)=="Vector3" then
			local y=C.terrainHeight(p.X,p.Z)
			local delta=Vector3.new(0,y-p.Y,0)
			if math.abs(delta.Y)>.001 then m:PivotTo(m:GetPivot()+delta);moved+=1 end
			m:SetAttribute("GroundPosition",p+delta)
		end
		if moved%100==0 then task.wait() end
	end
end
return {pathSurfaces=count,regroundedModels=moved}
