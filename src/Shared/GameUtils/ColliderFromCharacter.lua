local import = require(game.ReplicatedStorage.Lib.Import)

local HitboxConstants = import "Data/HitboxConstants"
local ColliderFromCharacter = {}

local CapsuleColliderModel = import "Data/Models/CapsuleColliderModel"
local SphereColliderModel = import "Data/Models/SphereColliderModel"

local CHAR_CAPSULE = CapsuleColliderModel.new(Vector3.new(), Vector3.new(0, HitboxConstants.PLAYER_HEIGHT, 0), HitboxConstants.PLAYER_RADIUS)
local DAMAGE_SPHERE = SphereColliderModel.new(HitboxConstants.ATTACK_OFFSET, HitboxConstants.ATTACK_RADIUS)

local function getFootCF(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	assert(rootPart, "Character does not have root part")
	local humanoid = character:FindFirstChild("Humanoid")
	assert(humanoid, "Character does not have humanoid")

	local footCF = rootPart.CFrame * CFrame.new(0, -rootPart.Size.Y/2, 0) * CFrame.new(0, -humanoid.HipHeight, 0)
	return footCF
end

function ColliderFromCharacter.characterCollider(character)
	local hitBox = CapsuleColliderModel.fromCFrame(CHAR_CAPSULE, getFootCF(character))
	return hitBox
end

function ColliderFromCharacter.damageCollider(character)
	local hitBox = SphereColliderModel.fromCFrame(DAMAGE_SPHERE, getFootCF(character))
	return hitBox
end

return ColliderFromCharacter
