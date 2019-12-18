local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"
local ActionIds = import "Data/ActionIds"

local KnockOut = {}
local RECOVER_THRESHOLD = 30
local CARRY_TIMEOUT = 6

function KnockOut.step(playerStates)
	for userId, playerState in pairs(playerStates) do
		local isDead = playerState.health.currentHealth <= 0
		local isKnockedOut = playerState.ko.isKnockedOut
		local isntBeingCarried = playerState.carrying.playerCarryingMe == nil
		local wasntJustCarried = tick() - playerState.carrying.lastCarriedTime > CARRY_TIMEOUT
		local isRecovered = playerState.health.currentHealth >= RECOVER_THRESHOLD

		if isDead and not isKnockedOut then
			playerState.ko.isKnockedOut = true
			playerState.ko.knockedOutTime = tick()

		elseif isKnockedOut and isRecovered and isntBeingCarried and wasntJustCarried then
			print("Get up")
			playerState.ko.isKnockedOut = false

			local player = Players:GetPlayerByUserId(userId)
			Network.fireClient(CombatEvents.REPLICATE_ACTION, player, ActionIds.GET_UP)
		end
	end
end

return KnockOut
