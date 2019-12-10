local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

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
	local hasIt = ActionState.hasAction(Attack.actionId)
	if not hasIt then
		return true
	end

	return false
end

function Attack.init(initialState)
	ActionState.setActionState(Attack.actionId, {
		startTime = tick()
	})
end

function Attack.step()
	if ActionState.isComplete(Attack.actionId) then
		ActionState.setActionState(Attack.actionId, nil)
	end
end

return Attack
