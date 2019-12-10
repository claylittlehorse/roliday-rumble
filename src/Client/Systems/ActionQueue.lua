local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local Input = import "Client/Systems/Input"
local StepOrder = import "Data/StepOrder"
local Actions = import "Shared/Actions"
local ActionIds = import "Data/ActionIds"
local ActionQueue =  {}

local _queue = {}

function ActionQueue.queueAction(actionId, initialData)
	_queue[#_queue+1] = {
		actionId = actionId,
		initialData = initialData
	}
end

function ActionQueue.step()
	for _, queuedAction in ipairs(_queue) do
		local actionId = queuedAction.actionId
		local initialState = queuedAction.initialState
		local action = Actions[actionId]
		assert(action, "No action found for actionId "..actionId)

		if action.validate(initialState) then
			action.init(initialState)
		end
	end

	_queue = {}
end

function ActionQueue.start()
	Input.bindActionInput("Attack", Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

	RunService:BindToRenderStep("ActionQueue", StepOrder.ACTION_QUEUE, function()

		local _, attackInputState = Input.readBoundAction("Attack")
		if attackInputState == Enum.UserInputState.Begin then
			ActionQueue.queueAction(ActionIds.ATTACK)
		end

		ActionQueue.step()
	end)
end

return ActionQueue
