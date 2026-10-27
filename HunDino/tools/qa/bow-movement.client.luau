-- Play-only sampler: hold W for 3.2 seconds after running this chunk.
-- Orbits the camera 0 -> 90 -> 180 degrees while real Roblox controls move.
local p=game.Players.LocalPlayer
local ch=p.Character
local h,root=ch.Humanoid,ch.HumanoidRootPart
ch:SetAttribute('QAMovementResult',nil)
local result={Samples=0,MinMoveDot=1,MinBodyDot=1,Phases=0,ChargedSamples=0}
local start,phase,lastChange,startPos
local run=game:GetService('RunService')
run:BindToRenderStep('BowMovementQA',Enum.RenderPriority.Camera.Value+2,function()
 if not start and h.MoveDirection.Magnitude>.1 then start=os.clock();startPos=root.Position end
 if not start then return end
 local t=os.clock()-start
 local nextPhase=if t<.6 then 1 elseif t<1.4 then 2 else 3
 if nextPhase~=phase then
  phase=nextPhase;lastChange=t;result.Phases+=1
  local forward=({Vector3.new(0,0,-1),Vector3.new(-1,0,0),Vector3.new(0,0,1)})[phase]
  workspace.CurrentCamera.CFrame=CFrame.lookAt(root.Position-forward*10+Vector3.new(0,4,0),root.Position+Vector3.new(0,2,0))
 end
 if t-lastChange>.25 and h.MoveDirection.Magnitude>.1 then
  local cf=workspace.CurrentCamera.CFrame.LookVector;cf=Vector3.new(cf.X,0,cf.Z).Unit
  local move=h.MoveDirection.Unit
  result.Samples+=1
  if p:GetAttribute('Charging')then result.ChargedSamples+=1 end
  result.MinMoveDot=math.min(result.MinMoveDot,move:Dot(cf))
  result.MinBodyDot=math.min(result.MinBodyDot,root.CFrame.LookVector:Dot(move))
 end
 if t>=2.8 then
  run:UnbindFromRenderStep('BowMovementQA')
  result.Distance=(root.Position-startPos).Magnitude;result.AutoRotate=h.AutoRotate
  ch:SetAttribute('QAMovementResult',game:GetService('HttpService'):JSONEncode(result))
 end
end)
return 'Sampler ready for W'
