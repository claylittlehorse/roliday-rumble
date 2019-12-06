local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local Input = {}
local _boundActions = {}

local BINDING_PRIORITY = Enum.ContextActionPriority.High.Value + 1

local MOVEMENT_INPUT = {
	Enum.KeyCode.W,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.A
}

local INPUT_TO_VECTOR_MAP = {
	[MOVEMENT_INPUT[1]] = Vector3.new(0, 0, -1),
	[MOVEMENT_INPUT[2]] = Vector3.new(0, 0, 1),
	[MOVEMENT_INPUT[3]] = Vector3.new(1, 0, 0),
	[MOVEMENT_INPUT[4]] = Vector3.new(-1, 0, 0),
}

local gamepadStatesDict = {} do
	local gamepadConnected = UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1)
	local gamepadStatesArray = gamepadConnected and UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
	if gamepadStatesArray then
		for _,state in ipairs(gamepadStatesArray) do
			gamepadStatesDict[state.KeyCode] = state
		end
	end
end

function Input.getMovementVector()
	local thumbstick1State = gamepadStatesDict[Enum.KeyCode.Thumbstick1]
	local stickPos = thumbstick1State and thumbstick1State.Position or Vector3.new()

	local totalVector
	local isGamepad = false
	if stickPos.magnitude > 0.15 then
		totalVector = Vector3.new(stickPos.X, 0, -stickPos.Y)
		isGamepad = true
	else
		totalVector = Vector3.new()

		for _, input in pairs(MOVEMENT_INPUT) do
			if UserInputService:IsKeyDown(input) then
				totalVector = totalVector + INPUT_TO_VECTOR_MAP[input]
			end
		end
	end

	local nonZero = totalVector.Magnitude > 0.1

	if nonZero then
		return isGamepad and totalVector or totalVector.unit
	else
		return Vector3.new()
	end
end

function Input.bindActionInput(actionName, ...)
	local ourAction = {
		inputKeys = {...},
		wasUpdated = false,
	}

	local function updateActionPressed(_, inputState, input)
		ourAction.wasUpdated = true
		ourAction.inputState = inputState
		return Enum.ContextActionResult.Pass
	end

	ContextActionService:BindActionAtPriority(
		actionName,
		updateActionPressed,
		false, BINDING_PRIORITY,
		...
	)

	_boundActions[actionName] = ourAction
end

function Input.readBoundAction(actionName)
	local boundAction = _boundActions[actionName]
	if not boundAction then
		return
	end

	local wasUpdated = boundAction.wasUpdated --or UserInputService:IsKeyDown(boundAction.inputKey)
	boundAction.wasUpdated = false
	local inputState = boundAction.inputState
	return wasUpdated, inputState
end

return Input
