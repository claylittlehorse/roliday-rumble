local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"
local ActionIds = import "Data/ActionIds"

local KnockOut = {}
local recoverThresholdHeath = 30

function KnockOut.step(playerStates)
	for userId, playerState in pairs(playerStates) do
		local isDead = playerState.health.currentHealth <= 0
		local isKnockedOut = playerState.ko.isKnockedOut

		if isDead and not isKnockedOut then
			playerState.ko.isKnockedOut = true
			playerState.ko.knockedOutTime = tick()

			--TODO: Also check the last time the player was carried so that
			--thrown players do not instantly revive.
		elseif isKnockedOut and playerState.health.currentHealth >= recoverThresholdHeath then
			playerState.ko.isKnockedOut = false

			local player = Players:GetPlayerByUserId(userId)
			Network.fireClient(CombatEvents.REPLICATE_ACTION, player, ActionIds.GET_UP)
		end
	end
end

return KnockOut
