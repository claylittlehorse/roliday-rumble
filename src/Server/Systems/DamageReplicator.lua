local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"
local PlayerStateManager = import "Server/Systems/PlayerStateManager"
local Sound = import "Shared/Systems/Sound"

local ActionIds = import "Data/ActionIds"

local DamageReplication = {}

local STAGGER_TIME = 0.5

function DamageReplication.start()
	Network.createEvent(CombatEvents.REPLICATE_ACTION)
	Network.createEvent(CombatEvents.REPLICATE_HEALTH)

	Network.hookEvent(CombatEvents.REPLICATE_DAMAGE, function(attackerPlayer, victimPlayer, damage)
		local playerStates = PlayerStateManager.getPlayerStates()
		local attackerUserId = tostring(attackerPlayer.UserId)
		local victimUserId = tostring(victimPlayer.UserId)

		local attackerState = playerStates[attackerUserId]
		local victimState = playerStates[victimUserId]

		if attackerState and victimState then
			if tick() - attackerState.health.lastDamagedTime < STAGGER_TIME then
				return
			end

			Sound.playSound("Hurt", victimState.characterModel.HumanoidRootPart.Position)
			victimState.health.currentHealth = math.max(victimState.health.currentHealth - damage, 0)
			victimState.health.lastDamagedTime = tick()
			Network.fireClient(CombatEvents.REPLICATE_ACTION, victimPlayer, ActionIds.STAGGER)
			Network.fireClient(CombatEvents.REPLICATE_HEALTH, victimPlayer, victimState.health.currentHealth)
		end
	end)
end

return DamageReplication
