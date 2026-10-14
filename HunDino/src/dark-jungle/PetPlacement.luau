-- Feet follow the collision surface rather than the old body's height offset.
local Placement = {}

function Placement.position(character: Model, point: Vector3, pets: Instance?): Vector3
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = if pets then { character, pets } else { character }
	params.RespectCanCollide = true
	local root = character:FindFirstChild("HumanoidRootPart")
	local hum = character:FindFirstChildOfClass("Humanoid")
	local height = if root then root.Position.Y else point.Y
	local result = workspace:Raycast(Vector3.new(point.X, height + 6, point.Z), Vector3.new(0, -128, 0), params)
	local fallback = height - (if hum then hum.HipHeight else 2) - (if root then root.Size.Y / 2 else 1)
	return Vector3.new(point.X, (if result then result.Position.Y else fallback) + 0.03, point.Z)
end

function Placement.place(pet: Model, character: Model, cf: CFrame, pets: Instance?)
	local goal = Placement.position(character, cf:PointToWorldSpace(Vector3.new(3, 0, 3)), pets)
	pet:PivotTo(CFrame.new(goal) * cf.Rotation)
end

return Placement
