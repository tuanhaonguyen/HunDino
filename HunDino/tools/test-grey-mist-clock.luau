-- Studio Edit test. Restores the current scene even if an assertion fails.
local RS=game:GetService("ReplicatedStorage")
local L=game:GetService("Lighting")
local T=workspace.Terrain
local report={ok=false,checks=0,failures={}}
local function check(ok,message)
	report.checks+=1;if not ok then table.insert(report.failures,message) end
end
local before={clock=L.ClockTime,grass=T:GetMaterialColor(Enum.Material.Grass),water=T.WaterColor,
	corrections={}}
for _,effect in L:GetChildren() do
	if effect:IsA("ColorCorrectionEffect") then before.corrections[effect]=effect.Enabled end
end
local root=Instance.new("Folder");root.Parent=game:GetService("ServerStorage")
local clock=require(RS.HuntingEnvironmentClock).new(root,require(RS.HuntingMapConfig))
local success,err=xpcall(function()
	clock.StartedAt=1000;clock.EntryClockHours=14
	check(clock:Step(1000)==14,"Entry should start at 14:00")
	check(clock:Step(1120)==15,"120 real seconds should advance one hour")
	check(clock:Step(3400)==10,"40 real minutes should advance 20 hours and wrap")
	clock.EntryClockHours=0;clock:Step(1000)
	report.midnightBrightness=L.Brightness
	check(L.Brightness>=1.84,"Midnight readability floor")
	for effect in clock.SavedSceneCorrections do check(not effect.Enabled,"Hub grading disabled in hunting") end
	-- A fixed Unix day begins at 07:00 in UTC+7.
	clock:Start(86400);clock:Stop()
	check(math.abs(clock.EntryClockHours-7)<.0001,"Entry uses UTC+7")
end,debug.traceback)
clock:Destroy(true);root:Destroy()
check(success,tostring(err))
check(L.ClockTime==before.clock,"Clock restored")
check(T:GetMaterialColor(Enum.Material.Grass)==before.grass,"Terrain palette restored")
check(T.WaterColor==before.water,"Water palette restored")
for effect,enabled in before.corrections do check(effect.Enabled==enabled,"Scene correction restored") end
report.ok=#report.failures==0
return report
