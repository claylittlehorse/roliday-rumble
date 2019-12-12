local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"
local PlayerStateManager = import "Server/Systems/PlayerStateManager"
local Sound = import "Shared/Systems/Sound"

local DamageReplication = {}

function DamageReplication.start()
	Network.hookEvent(CombatEvents.REPLICATE_DAMAGE, function(attackerPlayer, victimPlayer, damage)
		local playerStates = PlayerStateManager.getPlayerStates()
		local attackerUserId = tostring(attackerPlayer.UserId)
		local victimUserId = tostring(victimPlayer.UserId)

		local attackerState = playerStates[attackerUserId]
		local victimState = playerStates[victimUserId]

		if attackerState and victimState then
			Sound.playSound("Hurt", victimState.characterModel.HumanoidRootPart.Position)
			victimState.health.currentHealth = math.max(victimState.health.currentHealth - damage, 0)
			victimState.health.lastDamagedTime = tick()
		end
	end)
end

return DamageReplication
