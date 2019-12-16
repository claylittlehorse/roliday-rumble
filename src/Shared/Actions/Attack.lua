local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"

local CombatState = import "Client/Systems/CombatState"

local Punch = import "Shared/Actions/Punch"
local EndPunch = import "Shared/Actions/EndPunch"
local Health = import "Client/Systems/Health"

-- determine which attach we should be doing, delegate that action

local Attack = {}
Attack.movementPriority = 0
Attack.actionId = ActionIds.ATTACK

local COMBO_LENGTH = 3
local COMBO_TIMEOUT = 3

function Attack.validate()
	if not Health.isActive() then
		return false
	end

	local isNotAttacking = not ActionState.hasActionInMap({
		[ActionIds.PUNCH] = true,
		[ActionIds.END_PUNCH] = true,
	})

	local isNotKnockedDown = not ActionState.hasAction(ActionIds.FALLDOWN)
	if isNotAttacking and isNotKnockedDown then
		return true
	end

	return false
end

function Attack.init(initialState)
	local elapsedTime = tick() - CombatState.lastAttackTime
	CombatState.lastAttackTime = tick()
	if elapsedTime > COMBO_TIMEOUT then
		CombatState.comboCount = 1
	else
		CombatState.comboCount = CombatState.comboCount + 1
	end

	if CombatState.comboCount >= COMBO_LENGTH then
		CombatState.comboCount = 0
		EndPunch.init()
	else
		Punch.init()
	end
end


return Attack
