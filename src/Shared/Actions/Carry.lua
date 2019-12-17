local import = require(game.ReplicatedStorage.Lib.Import)

local Workspace = game:GetService("Workspace")

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"

local Carry = {}
Carry.movementPriority = 0
Carry.actionId = ActionIds.CARRY

function Carry.validate()
	return true
end

function Carry.init(initialState)
	ActionState.setActionState(Carry.actionId, {
		weldConstraint = initialState.weld
	})
end

function Carry.step(state)
	local weldConstraint = state.weldConstraint

	if not weldConstraint:IsDescendantOf(Workspace) then
		ActionState.setActionState(Carry.actionId, false)
	end

	if weldConstraint.Part1 == nil or not weldConstraint.Part1:IsDescendantOf(Workspace) then
		ActionState.setActionState(Carry.actionId, false)
	end
end


return Carry
