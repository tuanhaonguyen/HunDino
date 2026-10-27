-- Connected-place adapter. The standalone H1.1 layout remains unchanged.
local Base = require(game:GetService("ReplicatedStorage"):WaitForChild("HuntingBaseConfig"))
local C = table.clone(Base)
local offset = Vector3.new(0, 0, 6500)
C.WorldOffset = offset
C.ConnectedToHub = true
C.Version = "H2.0"
C.EnvironmentStyle = "GreyMist"
C.RestSeconds = 60 -- Real seconds at A/B/C and R1-R5, including initial spawn.
C.TerrainMin = Base.TerrainMin + offset.Y
C.TerrainMax = Base.TerrainMax + offset.Y
C.LakeLevel = Base.LakeLevel + offset.Y

function C.position(zone)
	return Base.position(zone) + offset
end

function C.height(x, z)
	return Base.height(x - offset.X, z - offset.Z) + offset.Y
end

function C.terrainHeight(x, z)
	local height, graded, distance = Base.terrainHeight(x - offset.X, z - offset.Z)
	return height + offset.Y, graded, distance
end

function C.waterLevel(x, z, ground)
	local level, kind = Base.waterLevel(x-offset.X,z-offset.Z,ground and ground-offset.Y)
	return level and level+offset.Y, kind
end

function C.biome(x,z) return Base.biome(x-offset.X,z-offset.Z) end

local function translated(points)
	local result = table.create(#points)
	for index, point in points do result[index] = point + offset end
	return result
end

function C.controlPoints(edge)
	return translated(Base.controlPoints(edge))
end

function C.samples(edge, spacing)
	return translated(Base.samples(edge, spacing))
end

return C
