
local HealthRegen = {}

local regenInterval = 1
local regenAmount = 5
local damageTimeout = 1

function HealthRegen.step(playerStates)
	for userId, playerState in pairs(playerStates) do
		local wasntDamagedRecently = tick() - playerState.health.lastDamagedTime >= damageTimeout
		local hasntRegenedRecently = tick() - playerState.health.lastRegenedTime >= regenInterval
		local isLessThanMaxHealth = playerState.health.currentHealth < 100

		if wasntDamagedRecently and hasntRegenedRecently and isLessThanMaxHealth then
			playerState.health.lastRegenedTime = tick()
			playerState.health.currentHealth = math.min(playerState.health.currentHealth+regenAmount, 100)
			print("regened", userId, "to", playerState.health.currentHealth)
		end
	end
end

return HealthRegen
