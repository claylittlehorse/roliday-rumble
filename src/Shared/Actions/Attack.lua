local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

local AttackDamage = import "Shared/Damages/AttackDamage"
local DamageSolver = import "Client/Systems/DamageSolver"

-- determine which attach we should be doing, delegate that action

local Attack = {}
Attack.movementPriority = 1
Attack.actionId = ActionIds.ATTACK
Attack.phaseTimings = {
	[ActionPhases.WINDUP] = 0,
	[ActionPhases.ACTIVE] = 1,
	[ActionPhases.COOLDOWN] = 0,
}

function Attack.validate()
	local isNotAttacking = not ActionState.hasAction(Attack.actionId)

	if isNotAttacking then
		return true
	end

	return false
end

function Attack.init(initialState)
	print("INIT")
	ActionState.setActionState(Attack.actionId, {
		startTime = tick(),
		currentPhase = ActionPhases.WINDUP
	})
end

function Attack.step(state)
	local newPhase = ActionState.getActionPhase(Attack.actionId)
	local phaseChanged = state.currentPhase ~= newPhase
	state.currentPhase = newPhase

	if phaseChanged and ActionState.isActive(Attack.actionId) then
		print("damage!!!")
		local damage = AttackDamage.new(Attack.actionId)
		DamageSolver.setCurrentDamage(damage)
	end

	if ActionState.isComplete(Attack.actionId) then
		print("klenup")
		ActionState.setActionState(Attack.actionId, nil)
	end
end

return Attack
