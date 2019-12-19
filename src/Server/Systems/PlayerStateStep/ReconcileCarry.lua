local import = require(game.ReplicatedStorage.Lib.Import)

local Workspace = game:GetService("Workspace")
local IsValidCharacter = import "GameUtils/IsValidCharacter"

local RecoverConstants = import "Data/RecoverConstants"

local ReconcileCarry = {}

local function cleanupWeld(carrying)
	if carrying.carryingWeld then
		carrying.carryingWeld:Destroy()
		carrying.carryingWeld = nil
	end
end

local function clearCarrierState(carrierState)
	if not carrierState then
		return
	end

	carrierState.carrying.playerImCarrying = nil
	cleanupWeld(carrierState.carrying)
end

local function clearCarriedState(carriedState)
	if not carriedState then
		return
	end

	carriedState.carrying.playerCarryingMe = nil
	cleanupWeld(carriedState.carrying)
end

local function isInvalid(player, playerStates)
	local userId = tostring(player.UserId)
	local playerState = playerStates[userId]
	local character = playerState and playerState.characterModel
	return not (character and IsValidCharacter(character)), playerState
end

function ReconcileCarry.step(playerStates)
	for _, playerState in pairs(playerStates) do
		local isBeingCarried = playerState.carrying.playerCarryingMe ~= nil
		local isCarrying = playerState.carrying.playerImCarrying ~= nil

		if isBeingCarried then
			playerState.carrying.lastCarriedTime = tick()

			local isFullyRecovered = playerState.health.currentHealth >= RecoverConstants.FULL_RECOVER_THRESHOLD

			local carryingWeld = playerState.carrying.carryingWeld
			local carrierInvalid, carrierState = isInvalid(playerState.carrying.playerCarryingMe, playerStates)
			if not carryingWeld or not carryingWeld:IsDescendantOf(Workspace) or carrierInvalid or isFullyRecovered then
				clearCarriedState(playerState)
				clearCarrierState(carrierState)
			end
		elseif isCarrying then
			local carryingWeld = playerState.carrying.carryingWeld
			local carriedInvalid, carriedState = isInvalid(playerState.carrying.playerImCarrying, playerStates)

			if not carryingWeld or not carryingWeld:IsDescendantOf(Workspace) or carriedInvalid then
				clearCarriedState(playerState)
				clearCarrierState(carriedState)
			end
		end
	end
end

return ReconcileCarry
