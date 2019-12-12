local import = require(game.ReplicatedStorage.Lib.Import)

local StateRemove = {}

local IsValidCharacter = import "GameUtils/IsValidCharacter"

function StateRemove.step(playerStates)
	for userId, playerState in pairs(playerStates) do
		local character = playerState.characterModel
		if not IsValidCharacter(character) then
			playerStates[userId] = nil
		else
			if playerState.health.currentHealth <= 0 then
				playerStates[userId].Humanoid.Health = 0
				playerStates[userId] = nil
			end
		end
	end
end

return StateRemove
