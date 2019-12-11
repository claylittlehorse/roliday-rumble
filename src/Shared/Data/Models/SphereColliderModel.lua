local import = require(game.ReplicatedStorage.Lib.Import)
local ColliderTypes = import "Data/ColliderTypes"

local SphereColliderModel = {}

function SphereColliderModel.new(centerPoint, radius)
	return {
		center = centerPoint,
		radius = radius,
		type = ColliderTypes.SPHERE
	}
end

function SphereColliderModel.fromCFrame(sphereCollider, cframe)
	local center = cframe * sphereCollider.center
	local radius = sphereCollider.radius
	return SphereColliderModel.new(center, radius)
end

return SphereColliderModel
