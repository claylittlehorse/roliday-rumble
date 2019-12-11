local import = require(game.ReplicatedStorage.Lib.Import)

local ColliderTypes = import "Data/ColliderTypes"

local SphereColliderModel = import "Data/Models/SphereColliderModel"
local CapsuleColliderModel = import "Data/Models/CapsuleColliderModel"

local ColliderTypeToModel = {
	[ColliderTypes.SPHERE] = SphereColliderModel,
	[ColliderTypes.CAPSULE] = CapsuleColliderModel
}

return ColliderTypeToModel
