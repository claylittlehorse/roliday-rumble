local import = require(game.ReplicatedStorage.Lib.Import)

local Collisions = import "Collisions"
local ColliderTypes = import "Data/ColliderTypes"

-- A map of maps!
local collisionCheckMap = {
	[ColliderTypes.CAPSULE] = {
		[ColliderTypes.CAPSULE] = function(capsuleA, capsuleB)
			local pointA, pointB = Collisions.ClosestPointsOf.LineSegments(
				capsuleA.pointA, capsuleA.pointB,
				capsuleB.pointA, capsuleB.pointB
			)

			local distanceVector = pointA-pointB
			local distanceSquared = distanceVector:Dot(distanceVector)

			if distanceSquared < (capsuleA.radius + capsuleB.radius) ^ 2 then
				return true
			end
		end,
		[ColliderTypes.SPHERE] = function(capsuleA, sphereB)
			local distanceSquared = Collisions.DistanceOf.LineSegmentToPointSquared(
				capsuleA.pointA, capsuleA.pointB,
				sphereB.center
			)

			if distanceSquared < (capsuleA.radius + sphereB.radius) ^ 2 then
				return true
			end
		end
	},
	[ColliderTypes.SPHERE] = {
		[ColliderTypes.SPHERE] = function(sphereA, sphereB)
			local distanceVector = sphereA.center - sphereB.center
			local distanceSquared = distanceVector:Dot(distanceVector)

			if distanceSquared < (sphereA.radius + sphereB.radius) ^ 2 then
				return true
			end
		end
	}
}

local function CheckCollision(colliderA, colliderB)
	local typeToCheckMap = collisionCheckMap[colliderA.type]
	local collisionCheckFunction = typeToCheckMap[colliderB.type]

	if not collisionCheckFunction then
		local typeToCheckMap = collisionCheckMap[colliderB.type]
		collisionCheckFunction = typeToCheckMap[colliderA.type]

		assert(collisionCheckFunction ~= nil,
			("Could not compute collisions between %s and %s"):format(colliderA.type, colliderB.type)
		)

		return collisionCheckFunction(colliderB, colliderA)
	end

	return collisionCheckFunction(colliderA, colliderB)
end


return CheckCollision
