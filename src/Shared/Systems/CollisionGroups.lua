local import = require(game.ReplicatedStorage.Lib.Import)

local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

local StepOrder = import "Data/StepOrder"
local ActionState = import "Client/Systems/ActionState"
local ActionIds = import "Data/ActionIds"
local GetLocalCharacter = import "Utils/GetLocalCharacter"

local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

local CollisionGroupIds = {
	PLAYER_NONCOLLIDE = "PlayersNoncollide",
	PLAYER_COLLIDE = "PlayersCollide",
}

local CollisionGroups = {}
CollisionGroups.groupIds = CollisionGroupIds

local COLLIDE_DELAY = 0.2

function CollisionGroups.setCharacterCollisionGroup(character, collisonGroupId)
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, collisonGroupId)
		end
	end
end

function CollisionGroups:start()
	if IS_SERVER then
		for _, groupId in pairs(CollisionGroupIds) do
			PhysicsService:CreateCollisionGroup(groupId)
		end

		PhysicsService:CollisionGroupSetCollidable(
			CollisionGroupIds.PLAYER_COLLIDE,
			CollisionGroupIds.PLAYER_COLLIDE,
			true
		)

		PhysicsService:CollisionGroupSetCollidable(
			CollisionGroupIds.PLAYER_COLLIDE,
			CollisionGroupIds.PLAYER_NONCOLLIDE,
			false
		)
		PhysicsService:CollisionGroupSetCollidable(
			CollisionGroupIds.PLAYER_NONCOLLIDE,
			CollisionGroupIds.PLAYER_NONCOLLIDE,
			false
		)
	end

	if IS_CLIENT then
		local characterCanCollide = true
		local attackEndTime = 0
		local wasAttacking = false
		RunService:BindToRenderStep("Collision", StepOrder.COLLISION_UPDATE, function()
			local character = GetLocalCharacter()
			if not character then
				return
			end

			local isAttacking = ActionState.hasAction(ActionIds.PUNCH) or ActionState.hasAction(ActionIds.END_PUNCH)
			local isKnockedOut = ActionState.hasAction(ActionIds.FALLDOWN) or ActionState.hasAction(ActionIds.KNOCKOUT)
			local attackChanged = isAttacking ~= wasAttacking
			wasAttacking = isAttacking

			if isKnockedOut and characterCanCollide then
				characterCanCollide = false
				CollisionGroups.setCharacterCollisionGroup(
					character,
					CollisionGroupIds.PLAYER_NONCOLLIDE
				)
			end

			if attackChanged and isAttacking and characterCanCollide then
				characterCanCollide = false
				CollisionGroups.setCharacterCollisionGroup(
					character,
					CollisionGroupIds.PLAYER_NONCOLLIDE
				)
				return
			elseif attackChanged and not isAttacking then
				attackEndTime = tick()
				return
			end

			local timeSinceAttackEnded = tick() - attackEndTime
			local canBecomeCollidable = timeSinceAttackEnded > COLLIDE_DELAY
			if canBecomeCollidable and not characterCanCollide and not isAttacking then
				characterCanCollide = true
				CollisionGroups.setCharacterCollisionGroup(
					character,
					CollisionGroupIds.PLAYER_COLLIDE
				)
			end
		end)
	end
end

return CollisionGroups
