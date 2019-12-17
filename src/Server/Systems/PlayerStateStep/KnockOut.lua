local import = require(game.ReplicatedStorage.Lib.Import)

local KnockOut = {}
local recoverThresholdHeath = 20

function KnockOut.step(playerStates)
	for userId, playerState in pairs(playerStates) do
		local isDead = playerState.health.currentHealth <= 0
		local isNotKnockedOut = playerState.ko.isKnockedOut

		if isDead and isNotKnockedOut then
			playerState.ko.isKnockedOut = true
			playerState.ko.knockedOutTime = tick()

			--TODO: Also check the last time the player was carried so that
			--thrown players do not instantly revive.
		elseif not isNotKnockedOut and playerState.health.currentHealth >= recoverThresholdHeath then
			playerState.ko.isKnockedOut = false
		end
	end
end

return KnockOut
