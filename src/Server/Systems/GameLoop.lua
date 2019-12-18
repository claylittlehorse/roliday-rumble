local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local PlayerStateManager = import "Server/Systems/PlayerStateManager"
local IsValidCharacter = import "GameUtils/IsValidCharacter"

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local GameLoop = {}

local function countValidCharacters()
    local count = 0

    local players = Players:GetPlayers()
	for _, player in pairs(players) do
        if player.Character and IsValidCharacter(player.Character) then
            count = count + 1
        end
    end

    return count
end

local function getPlayerStatesAsList()
	local playerStates = {}
	for userId, state in pairs(PlayerStateManager.getPlayerStates()) do
		playerStates[#playerStates+1] = {
			userId = userId,
			state = state
		}
	end

	return playerStates
end

-- local gameStartTime = 0
local isGameRunning = false

function GameLoop.start()
	Network.createEvent(CombatEvents.REPLICATE_ACTIVE)

	coroutine.resume(coroutine.create(function()
		while wait(1) do
			if not isGameRunning then
				local charCount = countValidCharacters()
				if charCount >= 2 and charCount == #Players:GetPlayers() then
					isGameRunning = true
					PlayerStateManager.resetPlayerStates()
				end
			else
				local playerStatesList = getPlayerStatesAsList()
				if #playerStatesList <= 1 then
					if playerStatesList[1] then
						print(playerStatesList[1].userId, "wins")
					end

					print("game end")
					isGameRunning = false
				end
			end
		end
    end))
end

return GameLoop
