-- Run in Studio Edit (Command Bar/MCP), never in Play or with the old map builder.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before repairing the saved map")
local route=workspace.DarkJungle.Paths.TempleApproach
local surfaces={}
for _,p in route:GetChildren() do
 if p.Name=="WalkSurface" then
  assert(p:IsA("BasePart") and typeof(p:GetAttribute("RouteStart"))=="Vector3" and typeof(p:GetAttribute("RouteEnd"))=="Vector3","Missing route endpoints")
  table.insert(surfaces,p)
 end
end
assert(#surfaces==10,"Unexpected TempleApproach layout; inspect before changing")
local first=surfaces[1]
local a,b=first:GetAttribute("RouteStart"),first:GetAttribute("RouteEnd")
local oldScale=route:GetScale()
-- Restore the whole model, including eight moss borders, before exact slab alignment.
route:ScaleTo(1)
route:PivotTo(CFrame.lookAt((a+b)/2,b)*first.CFrame:Inverse()*route:GetPivot())
for _,p in surfaces do
 local u,v=p:GetAttribute("RouteStart"),p:GetAttribute("RouteEnd")
 p.CFrame=CFrame.lookAt((u+v)/2,v)
 p.Size=Vector3.new(p:GetAttribute("WalkWidth") or 20,2,(v-u).Magnitude+1.2)
 p.Anchored=true; p.CanCollide=true
end
return {surfaces=#surfaces,previousScale=oldScale,scale=route:GetScale()}
