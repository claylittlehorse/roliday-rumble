local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"
local PlayerStateManager = import "Server/Systems/PlayerStateManager"
local Sound = import "Shared/Systems/Sound"

local ActionIds = import "Data/ActionIds"

local DamageReplication = {}

local STAGGER_TIME = 0.5

local function isValidAttacker(attackerState)
	local isAlive = attackerState.health.currentHealth > 0
	local isntKnockedOut = not attackerState.ko.isKnockedOut
	local isntBeingCarried = attackerState.carrying.playerCarryingMe == nil
	local isntCarrying = attackerState.carrying.playerImCarrying == nil
	local hasntJustBeenDamaged = tick() - attackerState.health.lastDamagedTime > STAGGER_TIME

	local isValid = isAlive and isntKnockedOut and isntBeingCarried and isntCarrying and hasntJustBeenDamaged
	return isValid
end

local function isValidVictim(victimState)
	local isAlive = victimState.health.currentHealth > 0
	local isntKnockedOut = not victimState.ko.isKnockedOut
	local isntBeingCarried = victimState.carrying.playerCarryingMe == nil

	local isValid = isAlive and isntKnockedOut and isntBeingCarried
	return isValid
end

function DamageReplication.start()
	Network.createEvent(CombatEvents.REPLICATE_ACTION)
	Network.createEvent(CombatEvents.REPLICATE_HEALTH)
	Network.createEvent(CombatEvents.REPLICATE_KNOCKBACK)

	Network.hookEvent(CombatEvents.REPLICATE_DAMAGE, function(attackerPlayer, victimPlayer, payload)
		local damage = payload.damage
		local knockback = payload.knockback

		local playerStates = PlayerStateManager.getPlayerStates()
		local attackerUserId = tostring(attackerPlayer.UserId)
		local victimUserId = tostring(victimPlayer.UserId)

		local attackerState = playerStates[attackerUserId]
		local victimState = playerStates[victimUserId]

		if attackerState and victimState and isValidAttacker(attackerState) and isValidVictim(victimState) then
			local victimChar = victimState.characterModel
			victimState.health.currentHealth = math.max(victimState.health.currentHealth - damage, 0)
			if victimState.health.currentHealth <= 0 then
				knockback.shouldKnockOut = true
				Sound.playSound("Knockout", victimChar.HumanoidRootPart.Position)
			elseif not knockback.shouldKnockdown then
				Sound.playSound("Hurt", victimState.characterModel.HumanoidRootPart.Position)
				Network.fireClient(CombatEvents.REPLICATE_ACTION, victimPlayer, ActionIds.STAGGER)
			end

			local victimHealth = victimChar and victimChar:FindFirstChild("HealthVal")
			if victimHealth then
				victimHealth.Value = victimState.health.currentHealth
			end

			victimState.health.lastDamagedTime = tick()
			Network.fireClient(CombatEvents.REPLICATE_HEALTH, victimPlayer, victimState.health.currentHealth)
			Network.fireClient(CombatEvents.REPLICATE_KNOCKBACK, victimPlayer, knockback)
		end
	end)
end

return DamageReplication
