
local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local HealthRegen = {}

local regenInterval = 1
local regenAmount = 5
local damageTimeout = 7.5

function HealthRegen.step(playerStates)
	for userId, playerState in pairs(playerStates) do
		local wasntDamagedRecently = tick() - playerState.health.lastDamagedTime >= damageTimeout
		local hasntRegenedRecently = tick() - playerState.health.lastRegenedTime >= regenInterval
		local isLessThanMaxHealth = playerState.health.currentHealth < 100

		if wasntDamagedRecently and hasntRegenedRecently and isLessThanMaxHealth then
			playerState.health.lastRegenedTime = tick()
			playerState.health.currentHealth = math.min(playerState.health.currentHealth+regenAmount, 100)
			local player =  Players:GetPlayerByUserId(userId)
			local char = player.Character
			local health = char and char:FindFirstChild("HealthVal")
			if health then
				health.Value = playerState.health.currentHealth
			end
			Network.fireClient(CombatEvents.REPLICATE_HEALTH, player, playerState.health.currentHealth)
		end
	end
end

return HealthRegen
