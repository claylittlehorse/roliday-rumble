local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local LavaSystem = import "Server/Systems/LavaSystem"
local Spawns = import "Server/Systems/Spawns"
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

local isGameRunning = false
local areCharactersSpawning = false

function GameLoop.restartGame()
	if not isGameRunning then
		return "Can't restart, game isn't running"
	else
		isGameRunning = false
		return "Restarting game..."
	end
end

function GameLoop.start()
	Network.createEvent(CombatEvents.REPLICATE_ACTIVE)

	coroutine.resume(coroutine.create(function()
		while wait(1) do
			if not isGameRunning and not areCharactersSpawning then
				local charCount = countValidCharacters()
				if charCount >= 2 and charCount == #Players:GetPlayers() then
					areCharactersSpawning = true
					LavaSystem.resetPosition()
					Spawns.spawnPlayers(Players:GetPlayers(), function(spawnedPlayers)
						areCharactersSpawning = false
						isGameRunning = true
						PlayerStateManager.resetPlayerStates(spawnedPlayers)
						LavaSystem.startMoving()
					end)
				end
			elseif isGameRunning then
				local playerStatesList = getPlayerStatesAsList()
				if #playerStatesList <= 1 then
					isGameRunning = false
				end
			end
		end
    end))
end

return GameLoop
