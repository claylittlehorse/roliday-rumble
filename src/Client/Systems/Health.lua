local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local Health = {}
local currentHealth
local isActive = false

function Health.getHealth()
	return currentHealth
end

function Health.isActive()
	return isActive
end

function Health.start()
	Network.hookEvent(CombatEvents.REPLICATE_HEALTH, function(health)
		currentHealth = health
	end)

	Network.hookEvent(CombatEvents.REPLICATE_ACTIVE, function(active)
		isActive = active
	end)
end

return Health
