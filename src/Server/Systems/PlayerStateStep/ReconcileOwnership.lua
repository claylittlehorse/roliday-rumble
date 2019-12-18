local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")
local ReconcileOwnership = {}

local SetCharacterOwnership = import "GameUtils/SetCharacterOwnership"

local CARRY_TIMEOUT = 4

function ReconcileOwnership.step(playerStates)
	for userId, playerState in pairs(playerStates) do
		local player = Players:GetPlayerByUserId(userId)

		local doesntHaveOwnership = playerState.carrying.networkOwner ~= player
		local wasntJustCarried = tick() - playerState.carrying.lastCarriedTime > CARRY_TIMEOUT

		-- if isntKnockedOut and doesntHaveOwnership then

		-- elseif doesntHaveOwnership then

		-- end
		if doesntHaveOwnership and wasntJustCarried then
			print("changedt.")
			SetCharacterOwnership(playerState, player)
		end
	end
end

return ReconcileOwnership
