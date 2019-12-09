local import = require(game.ReplicatedStorage.Lib.Import)

local Actions = import "Shared/Actions"
local ActionPhases = import "Data/ActionPhases"

local ActionState = {}
local _actionStates = {}

local function getTimedPhase(phaseTimings, startTime)
	local elapsedTime = tick() - startTime

	local windup = phaseTimings[ActionPhases.WINDUP]
	local active = phaseTimings[ActionPhases.ACTIVE] + windup
	local cooldown = phaseTimings[ActionPhases.COOLDOWN] + active

	local currentPhase, alpha do
		if elapsedTime <= windup then
			currentPhase = ActionPhases.WINDUP
			alpha = elapsedTime / phaseTimings[ActionPhases.WINDUP]
		elseif windup < elapsedTime and elapsedTime <= active then
			currentPhase = ActionPhases.ACTIVE
			alpha = (elapsedTime - windup) / phaseTimings[ActionPhases.ACTIVE]
		elseif active < elapsedTime and elapsedTime <= cooldown then
			currentPhase = ActionPhases.COOLDOWN
			alpha = (elapsedTime - active) / phaseTimings[ActionPhases.COOLDOWN]
		else
			currentPhase = ActionPhases.COMPLETE
		end
	end

	return currentPhase, alpha
end

function ActionState.getActionPhase(entity, actionId)
	local actionState = ActionState.getActionState(entity, actionId)
	if not actionState then
		return nil, nil
	end

	local action = Actions[actionId]
	local getPhaseFunc = action.getPhase

	if getPhaseFunc then
		return getPhaseFunc(entity, actionState)
	end

	local phaseTimings = action.phaseTimings

	assert(phaseTimings, ("Action %s does not have phase timings"):format(actionId))
	local startTime = actionState.startTime
	return getTimedPhase(phaseTimings, startTime)
end

function ActionState.hasAction(entity, actionId)
	local data = ActionState.getActionState(entity, actionId)
	return data ~= nil
end

function ActionState.hasActionInMap(entity, idToTypeMap)
	for actionId, _ in pairs(_actionStates) do
		if idToTypeMap[actionId] then
			return true
		end
	end

	return false
end

function ActionState.stopActionsInMap(entity, idToTypeMap)
	for actionId, _ in pairs(_actionStates) do
		if idToTypeMap[actionId] then
			_actionStates[actionId] = nil
		end
	end
end

function ActionState.isWindup(entity, actionId)
	local phase = ActionState.getActionPhase(entity, actionId)
	return phase == ActionPhases.WINDUP
end

function ActionState.isActive(entity, actionId)
	local phase = ActionState.getActionPhase(entity, actionId)
	return phase == ActionPhases.ACTIVE
end

function ActionState.isCooldown(entity, actionId)
	local phase = ActionState.getActionPhase(entity, actionId)
	return phase == ActionPhases.COOLDOWN
end

function ActionState.isComplete(entity, actionId)
	local phase = ActionState.getActionPhase(entity, actionId)
	return phase == ActionPhases.COMPLETE
end

function ActionState.getPhaseAlpha(entity, actionId)
	local _, alpha = ActionState.getActionPhase(entity, actionId)
	return alpha or 0
end

function ActionState.getMovementAction(entity)
	local highestPriority = -math.huge
	local selectedAction do
		for actionId, _ in pairs(_actionStates) do
			local action = Actions[actionId]
			if action.movementPriority > highestPriority then
				highestPriority = action.movementPriority
				selectedAction = action
			end
		end
	end

	return selectedAction
end

function ActionState.stepActions(entity, queueTime)
	for actionId, actionState in pairs(_actionStates) do
		local action = Actions[actionId]
		action.step(entity, actionState, queueTime)
	end
end

return ActionState
