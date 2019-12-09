local import = require(game.ReplicatedStorage.Lib.Import)

local Actions = import "Shared/Actionss"
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
end

return ActionQueue
