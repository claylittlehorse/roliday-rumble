local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

local Animations = import "Client/Systems/Animations"
local AnimationNames = import "Data/AnimationNames"

local GetLocalCharacter = import "Utils/GetLocalCharacter"

-- determine which attach we should be doing, delegate that action

local Stagger = {}
Stagger.movementPriority = 1
Stagger.actionId = ActionIds.STAGGER
Stagger.phaseTimings = {
	[ActionPhases.WINDUP] = 0,
	[ActionPhases.ACTIVE] = 0.5,
	[ActionPhases.COOLDOWN] = 0.25,
}

function Stagger.validate()
	local isNotKnockedDown = not ActionState.hasAction(ActionIds.FALLDOWN)
	if isNotKnockedDown then
		return true
	end

	return false
end

function Stagger.init(initialState)
	local char = GetLocalCharacter()

	ActionState.setActionState(Stagger.actionId, {
		startTime = tick(),
		currentPhase = ActionPhases.WINDUP,
		headColor = char.Head.Color
	})

	char.Head.Color = Color3.fromRGB(255, 0, 0)

	ActionState.stopActionsInMap({
		[ActionIds.PUNCH] = true,
		[ActionIds.END_PUNCH] = true,
	})
	Animations.playAnimation(AnimationNames.CARRYING, function(anim)
		if not anim.isPlaying then
			return true
		end

		if not ActionState.hasAction(Stagger.actionId) then
			anim:Stop()
			return true
		end

		return false
	end)


end

function Stagger.step(state)
	if ActionState.isComplete(Stagger.actionId) then
		local char = GetLocalCharacter()
		char.Head.Color = state.headColor
		ActionState.setActionState(Stagger.actionId, nil)
	end
end

function Stagger.changeSpeed(baseSpeed)
	if ActionState.isActive(Stagger.actionId) then
		return 0
	elseif ActionState.isCooldown(Stagger.actionId) then
		local alhpa = ActionState.getPhaseAlpha(Stagger.actionId)
		return (baseSpeed * alhpa)
	end

	return baseSpeed
end

function Stagger.addVelocity()
	return Vector3.new(0, 0, 0)
end

return Stagger
