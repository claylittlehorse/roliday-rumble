local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

local AttackDamage = import "Shared/Damages/AttackDamage"
local DamageSolver = import "Client/Systems/DamageSolver"
local PlaySoundAtCharacter = import "GameUtils/PlaySoundAtCharacter"

local Animations = import "Client/Systems/Animations"
local AnimationNames = import "Data/AnimationNames"

-- determine which attach we should be doing, delegate that action

local Attack = {}
Attack.movementPriority = 1
Attack.actionId = ActionIds.ATTACK
Attack.phaseTimings = {
	[ActionPhases.WINDUP] = 0.1,
	[ActionPhases.ACTIVE] = 0.3,
	[ActionPhases.COOLDOWN] = 0.2,
}

function Attack.validate()
	local isNotAttacking = not ActionState.hasAction(Attack.actionId)

	if isNotAttacking then
		return true
	end

	return false
end

function Attack.init(initialState)
	ActionState.setActionState(Attack.actionId, {
		startTime = tick(),
		currentPhase = ActionPhases.WINDUP
	})

	PlaySoundAtCharacter("Windup")
	Animations.playAnimation(AnimationNames.ATTACK, function(anim)
		if not anim.isPlaying then
			return true
		end

		if not ActionState.hasAction(Attack.actionId) then
			anim:Stop()
			return true
		end

		return false
	end)
end

function Attack.step(state)
	local newPhase = ActionState.getActionPhase(Attack.actionId)
	local phaseChanged = state.currentPhase ~= newPhase
	state.currentPhase = newPhase

	if phaseChanged and ActionState.isActive(Attack.actionId) then
		PlaySoundAtCharacter("Swing")
		local damage = AttackDamage.new(Attack.actionId)
		DamageSolver.setCurrentDamage(damage)
	end

	if ActionState.isComplete(Attack.actionId) then
		ActionState.setActionState(Attack.actionId, nil)
	end
end

return Attack
