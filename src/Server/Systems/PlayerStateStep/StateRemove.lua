local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local IsValidCharacter = import "GameUtils/IsValidCharacter"

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local StateRemove = {}

function StateRemove.step(playerStates, forceRemoveAll)
	for userId, playerState in pairs(playerStates) do
		local character = playerState.characterModel
		local player = Players:GetPlayerByUserId(userId)
		if forceRemoveAll or not IsValidCharacter(character) then
			playerStates[userId] = nil
			local health = character:FindFirstChild("HealthVal")
			if health then
				health:Destroy()
			end
			local knockedDown = character:FindFirstChild("KnockedDown")
			if knockedDown then
				knockedDown:Destroy()
			end
			Network.fireClient(CombatEvents.REPLICATE_ACTIVE, player, false)
			Network.fireClient(CombatEvents.REPLICATE_HEALTH, player, 0)
		end
		-- elseif playerState.health.currentHealth <= 0 then
		-- 		playerStates[userId].characterModel.Humanoid.Health = 0
		-- 		playerStates[userId] = nil
		-- 		Network.fireClient(CombatEvents.REPLICATE_ACTIVE, player, false)
		-- 	end
		-- end
	end
end

return StateRemove
