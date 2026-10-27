-- Disposable native geometry + real PetStanding/Animator/Controller. The target
-- sink is fixed so two attack cycles can be measured without patrol randomness.
local shared=game.ReplicatedStorage.Shared
local runtime=game.ServerScriptService.HuntingRuntime
local folder=Instance.new('Folder');folder.Name='PetSortieQA';folder.Parent=workspace
local report={Checks=0,Failures={},Hits={},HomeSamples=0}
local function check(ok,label)report.Checks+=1;if not ok then table.insert(report.Failures,label)end end
local animator,controller
local ok,err=xpcall(function()
 local base=Vector3.new(27000,500,27000)
 local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(180,2,180);floor.Position=base-Vector3.yAxis;floor.Parent=folder
 local char=Instance.new('Model');char.Parent=folder
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CanCollide=false;root.Position=base+Vector3.new(0,2.03,15);root.Parent=char;char.PrimaryPart=root
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=char
 local attrs={InHunting=true}
 local player={Parent=folder,UserId=-2644}
 function player:GetAttribute(k)return attrs[k]end
 function player:SetAttribute(k,v)attrs[k]=v end
 local pets=Instance.new('Folder');pets.Parent=folder
 local pet,rig=require(shared.PetStanding).build(pets)
 pet:PivotTo(CFrame.new(base+Vector3.new(0,.03,-8)))
 animator=require(shared.PetAnimator).new(pet,rig,game.ServerStorage.TrainingWeapons)
 animator.RenderPose=false;animator:SetWeapon('DualDaggers')
 local now=1000
 local hp=1200
 local target=base+Vector3.new(0,2.03,-10)
 local combat={}
 function combat:GetSnapshot()return {Health=hp,MaxHealth=1200,Captured=false}end
 function combat:GetClosestHitPoint(origin,range)return if (origin-target).Magnitude<=range then target else nil end
 function combat:Damage(_,amount,point,token,source)
  table.insert(report.Hits,{At=now,Amount=amount,Token=token,Source=source})
  return amount
 end
 local rulesClone=runtime.PetCombatRules:Clone();rulesClone.Parent=folder
 local controllerClone=runtime.PetCompanionController:Clone();controllerClone.Parent=folder
 local rules=require(rulesClone)
 local memory=rules.new()
 controller=require(controllerClone).new({Player=player,Character=char,Root=root,Humanoid=h,
  Pet=pet,PetFolder=pets,Animator=animator,Rules=rules,Memory=memory,Combat=combat,
  CanAct=function()return true end,IsEngaged=function()return true end})
 controller._now=function()return now end
 local home=root.CFrame:PointToWorldSpace(Vector3.new(3,0,4))
 for i=1,520 do
  now=1000+i*.05
  controller:Step(now,.05);animator:Update(.05)
  if now>1003 and now<1009.8 then
   report.HomeSamples+=1
   check(Vector3.new(pet.PrimaryPart.Position.X-home.X,0,pet.PrimaryPart.Position.Z-home.Z).Magnitude<1.5,'Pet waited beside dinosaur instead of returning home')
  end
  if #report.Hits>=2 then hp=120 end
  if i%40==0 then task.wait()end
 end
 check(#report.Hits==2,'Expected two single strikes, then no damage on weak target')
 if #report.Hits>=2 then
  check(report.Hits[2].At-report.Hits[1].At>=10,'Second strike occurred before ten-second interval')
  check(report.Hits[1].Amount==12 and report.Hits[2].Amount==12,'Dagger animation dealt several strikes per visit')
 end
 check(animator:GetHitCount()==2,'Fixture did not exercise a multi-marker weapon')
 hp=1200
 memory.HealReadyAt=now+119
 local healDeadline=memory.HealReadyAt
 controller:Damage(80,now)
 local retreatStart=now
 for i=1,340 do
  now=retreatStart+i*.05
  controller:Step(now,.05);animator:Update(.05)
  if i==60 then
   report.RetreatDistance=(pet.PrimaryPart.Position+Vector3.new(0,2,0)-target).Magnitude
   check(report.RetreatDistance>=rules.Config.RecoverySafeRange,'Low-health pet did not leave the bite area')
  end
  if i%40==0 then task.wait()end
 end
 report.RecoveredHealth=memory.Health
 check(memory.Health==100,'Pet did not automatically recover after reaching safety')
 check(memory.HealReadyAt==healDeadline,'Self recovery refreshed owner healing skill')
 memory.HealReadyAt=now+119
 controller:Damage(999,now)
 controller:ResetForArea(now)
 check(memory.Health==100 and memory.StunnedUntil==0,'Area reset failed to restore full health')
 check(memory.HealReadyAt==now+119,'Area reset refreshed owner healing skill')
end,debug.traceback)
if controller then controller:Destroy()end
if animator then animator:Destroy()end
folder:Destroy()
if not ok then table.insert(report.Failures,tostring(err))end
report.Ok=#report.Failures==0
return report
