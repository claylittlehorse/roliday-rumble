local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

local AttackDamage = import "Shared/Damages/AttackDamage"
local DamageSolver = import "Client/Systems/DamageSolver"
local Sound = import "Shared/Systems/Sound"

local PlayPunchAnim = import "GameUtils/PlayPunchAnim"
-- determine which attach we should be doing, delegate that action

local EndPunch = {}
EndPunch.movementPriority = 1
EndPunch.actionId = ActionIds.END_PUNCH
EndPunch.phaseTimings = {
	[ActionPhases.WINDUP] = 0.1,
	[ActionPhases.ACTIVE] = 0.3,
	[ActionPhases.COOLDOWN] = 0.5,
}

function EndPunch.validate()
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

function EndPunch.init(initialState)
	ActionState.setActionState(EndPunch.actionId, {
		startTime = tick(),
		currentPhase = ActionPhases.WINDUP
	})

	Sound.playAtCharacter("Windup")
end

function EndPunch.step(state)
	local newPhase = ActionState.getActionPhase(EndPunch.actionId)
	local phaseChanged = state.currentPhase ~= newPhase
	state.currentPhase = newPhase

	if phaseChanged and ActionState.isActive(EndPunch.actionId) then
		Sound.playAtCharacter("LoudSwing")

		PlayPunchAnim.light(EndPunch.actionId)
		local damage = AttackDamage.new(EndPunch.actionId, true)
		DamageSolver.addDamage(damage)
	end

	if ActionState.isComplete(EndPunch.actionId) then
		ActionState.setActionState(EndPunch.actionId, nil)
	end
end

function EndPunch.changeSpeed(baseSpeed)
	return baseSpeed * 1.2
end

function EndPunch.addVelocity()
	if ActionState.isActive(EndPunch.actionId) then
		local alpha = 1 - ActionState.getPhaseAlpha(EndPunch.actionId)
		return Vector3.new(0, 0, alpha * -40)
	end

	return Vector3.new(0, 0, 0)
end

return EndPunch
