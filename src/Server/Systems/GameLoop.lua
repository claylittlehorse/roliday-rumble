local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local PlayerStateManager = import "Server/Systems/PlayerStateManager"

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local GameLoop = {}

function GameLoop.start()
	Network.createEvent(CombatEvents.REPLICATE_ACTIVE)

	coroutine.resume(coroutine.create(function()
		while wait(1) do
			local players = Players:GetPlayers()
			for _, player in pairs(players) do
				local rank = player:GetRankInGroup(4590888)
				local shouldActivate = rank > 0

				PlayerStateManager.resetPlayerState(player, shouldActivate)
			end
		end
    end))
end

return GameLoop
