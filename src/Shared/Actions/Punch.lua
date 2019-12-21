local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

local AttackDamage = import "Shared/Damages/AttackDamage"
local DamageSolver = import "Client/Systems/DamageSolver"
local Sound = import "Shared/Systems/Sound"

local Hitstop = import "GameUtils/Hitstop"

local PlayPunchAnim = import "GameUtils/PlayPunchAnim"

local Punch = {}
Punch.movementPriority = 1
Punch.actionId = ActionIds.PUNCH
Punch.phaseTimings = {
	[ActionPhases.WINDUP] = 0.1,
	[ActionPhases.ACTIVE] = 0.2,
	[ActionPhases.COOLDOWN] = 0.1,
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
		startTime = Hitstop.tick(),
		currentPhase = ActionPhases.WINDUP
	})

	Sound.playAtCharacter("Windup")
	PlayPunchAnim.light(Punch.actionId)
end

function Punch.step(state)
	local newPhase = ActionState.getActionPhase(Punch.actionId, Hitstop.tick())
	local phaseChanged = state.currentPhase ~= newPhase
	state.currentPhase = newPhase

	if phaseChanged and ActionState.isActive(Punch.actionId, Hitstop.tick()) then
		Sound.playAtCharacter("Swing")
		local damage = AttackDamage.new(Punch.actionId)
		DamageSolver.addDamage(damage)
	end

	if ActionState.isComplete(Punch.actionId, Hitstop.tick()) then
		ActionState.setActionState(Punch.actionId, nil)
	end
end

function Punch.changeSpeed(baseSpeed)
	-- if ActionState.isActive(Punch.actionId) then
	-- 	return baseSpeed / 5
	-- elseif ActionState.isCooldown(Punch.actionId) then
	-- 	return baseSpeed / 2
	-- end

	return baseSpeed
end

function Punch.addVelocity()
	if ActionState.isActive(Punch.actionId, Hitstop.tick()) then
		local alpha = 1 - ActionState.getPhaseAlpha(Punch.actionId, Hitstop.tick())
		return Vector3.new(0, 0, alpha * -12)
	end

	return Vector3.new(0, 0, 0)
end

return Punch
