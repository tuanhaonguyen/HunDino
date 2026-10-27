-- Pure geometry shared by the reticle and server. Only the server owns range,
-- damage and ray hits; a client point is an aim intention, never a claimed hit.
local Bow = {}
Bow.MinRange = 40
Bow.MaxRange = 120
function Bow.range(alpha)
 return Bow.MinRange + (Bow.MaxRange - Bow.MinRange) * math.clamp(alpha or 0, 0, 1)
end
function Bow.origin(rootPosition)
 return rootPosition + Vector3.new(0, .8, 0)
end
function Bow.validTarget(point, origin)
 if typeof(point) ~= 'Vector3' then return false end
 for _, n in {point.X, point.Y, point.Z} do
  if n ~= n or math.abs(n) == math.huge then return false end
 end
 local distance = (point - origin).Magnitude
 return distance > .05 and distance <= 350
end
function Bow.direction(origin, target, fallback)
 if Bow.validTarget(target, origin) then return (target - origin).Unit end
 return fallback.Unit
end
function Bow.followPoint(ownerFrame, aiming)
 return ownerFrame:PointToWorldSpace(if aiming then Vector3.new(-7, 0, 7) else Vector3.new(3, 0, 4))
end
return Bow
