-- TEMPORARY Studio Play QA only. Remove this LocalScript mapping before Save.
-- Observes real client presentation after the server fixture's legitimate captures.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local player=Players.LocalPlayer
local report={version="BioTubeClientQA.1",passed=false,checks=0,slots={}}
local function check(condition,message) report.checks+=1;assert(condition,message) end
local function awaitReady()
	local deadline=os.clock()+180
	while player:GetAttribute("BioTubeQAReady")~=true and os.clock()<deadline do task.wait(.25) end
	check(player:GetAttribute("BioTubeQAReady")==true,"Server QA fixture did not finish five captured assignments")
	local root=workspace:WaitForChild("SpecimenTubeDisplays",20)
	check(root~=nil,"Tube display root did not replicate")
	local cluster=root:WaitForChild("Base"..tostring(player:GetAttribute("BaseId")),20)
	check(cluster~=nil,"Assigned base cluster did not replicate")
	for slot=1,5 do
		local tube=cluster:WaitForChild("BioTube_"..slot,20)
		local assembly=tube and tube:WaitForChild("SpecimenAssembly",20)
		check(assembly~=nil,"Assigned specimen assembly missing in slot "..slot)
		local childDeadline=os.clock()+20
		while (assembly:GetAttribute("Ready")~=true or not assembly:FindFirstChild("Specimen") or not assembly:FindFirstChild("RotatingInjector")
			or not assembly:FindFirstChild("BioTetherCables")) and os.clock()<childDeadline do task.wait(.1) end
		check(assembly:GetAttribute("Ready")==true,"Specimen not ready in slot "..slot)
	end
	return cluster
end
local function readSlot(tube)
	local assembly=tube.SpecimenAssembly
	local specimen,injector=assembly.Specimen,assembly.RotatingInjector
	local row={specimen=specimen:GetPivot(),injector=injector:GetPivot(),topYs={}}
	local count=0
	for _,beam in assembly.BioTetherCables:GetChildren() do
		if beam:IsA("Beam") then
			count+=1
			check(beam.Attachment0~=nil and beam.Attachment1~=nil,"A cable has a missing endpoint")
			check(beam.Attachment0:IsDescendantOf(injector),"Cable upper endpoint is detached from rotating injector")
			check(beam.Attachment1:IsDescendantOf(specimen),"Cable lower endpoint is detached from specimen")
			row.topYs[beam.Name]=beam.Attachment0.WorldPosition.Y
		end
	end
	check(count==14,"Expected 14 connected cables in every populated tube")
	return row
end
local function rotationDifference(a,b)
	local _,angle=(a.Rotation:Inverse()*b.Rotation):ToAxisAngle()
	return math.abs(angle)
end
local function main()
	check(RunService:IsStudio(),"Temporary QA script must run only inside Studio")
	local cluster=awaitReady()
	local camera=workspace.CurrentCamera
	local original={Type=camera.CameraType,CFrame=camera.CFrame,FOV=camera.FieldOfView,Subject=camera.CameraSubject}
	local centerOrigin=cluster.BioTube_5:GetAttribute("StaticOrigin")
	check(typeof(centerOrigin)=="CFrame","Center origin missing")
	camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=65
	camera.CFrame=CFrame.lookAt((centerOrigin*CFrame.new(0,11,-40)).Position,(centerOrigin*CFrame.new(0,9,0)).Position)
	-- Enter the production motion script's nearby set and allow at least two frames.
	task.wait(.8);RunService.RenderStepped:Wait()
	local first={}
	for slot=1,5 do first[slot]=readSlot(cluster["BioTube_"..slot]) end
	local began=os.clock()
	task.wait(1.05);RunService.RenderStepped:Wait()
	local elapsed=os.clock()-began
	for slot=1,5 do
		local current=readSlot(cluster["BioTube_"..slot])
		local before=first[slot]
		local rotation=rotationDifference(before.specimen,current.specimen)
		local expected=if slot==5 then 0 else math.rad(10)*elapsed
		check(if slot==5 then rotation<1e-4 else math.abs(rotation-expected)<math.rad(1.1),
			"Wrong client turn rate in slot "..slot..": observed "..math.deg(rotation).."° over "..elapsed.."s")
		local injectorRotation=rotationDifference(before.injector,current.injector)
		check(math.abs(injectorRotation-rotation)<1e-4,"Injector yaw does not follow specimen in slot "..slot)
		check(math.abs(before.injector.Position.Y-current.injector.Position.Y)<1e-4,"Injector bobbed away from tube ceiling")
		for name,y in before.topYs do
			check(math.abs(current.topYs[name]-y)<1e-4,"Cable upper endpoint drifted in Y: "..slot.."/"..name)
		end
		local origin=cluster["BioTube_"..slot].SpecimenAssembly:GetAttribute("StaticOrigin")
		local rest=cluster["BioTube_"..slot].SpecimenAssembly:GetAttribute("SpecimenRestPivot")
		local restHeight=origin:PointToObjectSpace(rest.Position).Y
		local actualHeight=origin:PointToObjectSpace(current.specimen.Position).Y
		check(math.abs(actualHeight-restHeight)<=.1202,"Specimen bob exceeds ±0.12 studs")
		report.slots[tostring(slot)]={rotationDegrees=math.deg(rotation),expectedDegrees=math.deg(expected),elapsedSeconds=elapsed,
			cables=14,fixedCenter=slot==5,injectorHeightConstant=true,bobStuds=actualHeight-restHeight}
	end
	report.passed=true
	player:SetAttribute("BioTubeClientQAPassed",true)
	-- Leave the overview visible for review. The root can request normal camera
	-- control later by setting this local QA attribute, without a gameplay remote.
	local restoreConnection
	restoreConnection=player:GetAttributeChangedSignal("BioTubeQARestoreCamera"):Connect(function()
		if player:GetAttribute("BioTubeQARestoreCamera")~=true then return end
		camera.CameraType=original.Type;camera.CFrame=original.CFrame;camera.FieldOfView=original.FOV;camera.CameraSubject=original.Subject
		restoreConnection:Disconnect()
	end)
end
local ok,err=xpcall(main,debug.traceback)
if not ok then report.error=tostring(err) end
print((if ok then "BIOTUBE_CLIENT_QA_PASS " else "BIOTUBE_CLIENT_QA_FAIL ")..HttpService:JSONEncode({
	version=report.version,passed=report.passed,checks=report.checks,error=report.error}))
for slot=1,5 do
	local data=report.slots[tostring(slot)]
	if data then print("[BioTubeClientQASlot] "..HttpService:JSONEncode({Slot=slot,Data=data})) end
end
