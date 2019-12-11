local import = require(game.ReplicatedStorage.Lib.Import)
local ColliderTypes = import "Data/ColliderTypes"

local CapsuleColliderModel = {}

function CapsuleColliderModel.new(pointA, pointB, radius)
	return {
		pointA = pointA,
		pointB = pointB,
		radius = radius,
		type = ColliderTypes.CAPSULE
	}
end

function CapsuleColliderModel.fromCFrame(capsuleModel, cframe)
	local pointA = cframe * capsuleModel.pointA
	local pointB = cframe * capsuleModel.pointB
	local radius = capsuleModel.radius
	return CapsuleColliderModel.new(pointA, pointB, radius)
end

return CapsuleColliderModel
