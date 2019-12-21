local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"
local PlayerStateManager = import "Server/Systems/PlayerStateManager"

local GetUpReplicator = {}

local KNOCKDOWN_TIME = 0.3

function GetUpReplicator.start()
	Network.createEvent(CombatEvents.REQUEST_GETUP)

	Network.hookEvent(CombatEvents.REQUEST_GETUP, function(player)
		local userId = tostring(player.UserId)
		local playerStates = PlayerStateManager.getPlayerStates()
		local playerState = playerStates[userId]

		local character = player.Character
		local knockedDown = character and character:FindFirstChild("KnockedDown")

		if playerState and knockedDown then
			local timeSinceKnockdown = tick() - playerState.ko.knockedDownTime
			if timeSinceKnockdown > KNOCKDOWN_TIME then
				knockedDown.Value = false
			end

			playerState.ko.knockedDown = false
		end
	end)
end

return GetUpReplicator
