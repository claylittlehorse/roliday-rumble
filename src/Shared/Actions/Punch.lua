local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

local AttackDamage = import "Shared/Damages/AttackDamage"
local DamageSolver = import "Client/Systems/DamageSolver"
local Sound = import "Shared/Systems/Sound"

local Animations = import "Client/Systems/Animations"
local AnimationNames = import "Data/AnimationNames"

-- determine which attach we should be doing, delegate that action

local Punch = {}
Punch.movementPriority = 1
Punch.actionId = ActionIds.PUNCH
Punch.phaseTimings = {
	[ActionPhases.WINDUP] = 0.1,
	[ActionPhases.ACTIVE] = 0.3,
	[ActionPhases.COOLDOWN] = 0.2,
}

function Punch.validate()
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

function Punch.init(initialState)
	ActionState.setActionState(Punch.actionId, {
		startTime = tick(),
		currentPhase = ActionPhases.WINDUP
	})

	Sound.playAtCharacter("Windup")
	Animations.playAnimation(AnimationNames.ATTACK, function(anim)
		if not anim.isPlaying then
			return true
		end

		if not ActionState.hasAction(Punch.actionId) then
			anim:Stop()
			return true
		end

		return false
	end)
end

function Punch.step(state)
	local newPhase = ActionState.getActionPhase(Punch.actionId)
	local phaseChanged = state.currentPhase ~= newPhase
	state.currentPhase = newPhase

	if phaseChanged and ActionState.isActive(Punch.actionId) then
		Sound.playAtCharacter("Swing")
		local damage = AttackDamage.new(Punch.actionId)
		DamageSolver.setCurrentDamage(damage)
	end

	if ActionState.isComplete(Punch.actionId) then
		ActionState.setActionState(Punch.actionId, nil)
	end
end

function Punch.changeSpeed(baseSpeed)
	if ActionState.isActive(Punch.actionId) then
		return baseSpeed / 5
	elseif ActionState.isCooldown(Punch.actionId) then
		return baseSpeed / 2
	end

	return baseSpeed
end

function Punch.addVelocity()
	if ActionState.isActive(Punch.actionId) then
		local alpha = 1 - ActionState.getPhaseAlpha(Punch.actionId)
		return Vector3.new(0, 0, alpha * -20)
	end

	return Vector3.new(0, 0, 0)
end

return Punch
