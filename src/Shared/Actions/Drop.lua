local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"

local GetLocalCharacter = import "Utils/GetLocalCharacter"
local ThrownPlayerDamage = import "Shared/Damages/ThrownPlayerDamage"
local DamageSolver = import "Client/Systems/DamageSolver"

local Drop = {}
Drop.movementPriority = 0
Drop.actionId = ActionIds.DROP

function Drop.validate()
	return true
end

function Drop.init(initialState)
	local character = GetLocalCharacter()
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local carryingWeld = rootPart and rootPart:FindFirstChild("CarryingWeld")
	local carryingPart = carryingWeld and carryingWeld.Part1
	if carryingWeld then
		carryingWeld:Destroy()
	end

	if carryingPart and initialState.throw then
		carryingPart.Velocity = Vector3.new(0, 30, 0) + rootPart.CFrame.lookVector * 40
		carryingPart.RotVelocity = -rootPart.CFrame.RightVector * 15 + Vector3.new(0, 3, 0)
		local damage = ThrownPlayerDamage.new(carryingPart.Parent)
		DamageSolver.addDamage(damage)
	elseif carryingPart then
		carryingPart.Velocity = Vector3.new(0, 40, 0) + rootPart.CFrame.lookVector * 10
		carryingPart.RotVelocity = -rootPart.CFrame.RightVector * 5 + Vector3.new(0, 20, 0)
	end

	ActionState.setActionState(ActionIds.CARRY, nil)
end

return Drop
