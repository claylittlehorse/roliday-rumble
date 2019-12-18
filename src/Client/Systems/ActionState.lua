local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local Actions = import "Shared/Actions"
local ActionPhases = import "Data/ActionPhases"
local StepOrder = import "Data/StepOrder"

local GetLocalCharacter = import "Utils/GetLocalCharacter"
local IsValidCharacter = import "GameUtils/IsValidCharacter"

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

function ActionState.setActionState(actionId, state)
	_actionStates[actionId] = state
end

function ActionState.getActionState(actionId, state)
	return _actionStates[actionId]
end

function ActionState.getActionPhase(actionId)
	local actionState = ActionState.getActionState(actionId)
	if not actionState then
		return nil, nil
	end

	local action = Actions[actionId]
	local getPhaseFunc = action.getPhase

	if getPhaseFunc then
		return getPhaseFunc(actionState)
	end

	local phaseTimings = action.phaseTimings

	assert(phaseTimings, ("Action %s does not have phase timings"):format(actionId))
	local startTime = actionState.startTime
	return getTimedPhase(phaseTimings, startTime)
end

function ActionState.hasAction(actionId)
	local data = ActionState.getActionState(actionId)
	return data ~= nil
end

function ActionState.hasActionInMap(idToTypeMap)
	for actionId, _ in pairs(_actionStates) do
		if idToTypeMap[actionId] then
			return true
		end
	end

	return false
end

function ActionState.stopActionsInMap(idToTypeMap)
	for actionId, _ in pairs(_actionStates) do
		if idToTypeMap[actionId] then
			_actionStates[actionId] = nil
		end
	end
end

function ActionState.isWindup(actionId)
	local phase = ActionState.getActionPhase(actionId)
	return phase == ActionPhases.WINDUP
end

function ActionState.isActive(actionId)
	local phase = ActionState.getActionPhase(actionId)
	return phase == ActionPhases.ACTIVE
end

function ActionState.isCooldown(actionId)
	local phase = ActionState.getActionPhase(actionId)
	return phase == ActionPhases.COOLDOWN
end

function ActionState.isComplete(actionId)
	local phase = ActionState.getActionPhase(actionId)
	return phase == ActionPhases.COMPLETE
end

function ActionState.getPhaseAlpha(actionId)
	local _, alpha = ActionState.getActionPhase(actionId)
	return alpha or 0
end

function ActionState.getMovementAction()
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

function ActionState.start()
	RunService:BindToRenderStep("ActionState", StepOrder.ACTION_STATE, function()
		local character = GetLocalCharacter()
		if not IsValidCharacter(character) then
			_actionStates = {}
		end

		for actionId, actionState in pairs(_actionStates) do
			local action = Actions[actionId]
			action.step(actionState, character)
		end
	end)
end

return ActionState
