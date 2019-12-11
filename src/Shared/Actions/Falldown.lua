local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

local GetLocalCharacter = import "Utils/GetLocalCharacter"

-- determine which attach we should be doing, delegate that action

local Falldown = {}
Falldown.movementPriority = 1
Falldown.actionId = ActionIds.FALLDOWN
Falldown.phaseTimings = {
	[ActionPhases.WINDUP] = 0,
	[ActionPhases.ACTIVE] = 2,
	[ActionPhases.COOLDOWN] = 0,
}

function Falldown.validate()
	local isNotFallen = not ActionState.hasAction(Falldown.actionId)

	if isNotFallen then
		return true
	end

	return false
end

function Falldown.init(initialState)
	local character = GetLocalCharacter()
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and rootPart) then
		return
	end
	humanoid.PlatformStand = true

	rootPart.Velocity = rootPart.Velocity * 2
	rootPart.RotVelocity = (rootPart.CFrame.RightVector * -5) + (rootPart.CFrame.UpVector * 50)

	ActionState.setActionState(Falldown.actionId, {
		startTime = tick(),
	})
end

function Falldown.step(state)
	if ActionState.isComplete(Falldown.actionId) then
		ActionState.setActionState(Falldown.actionId, nil)

		local character = GetLocalCharacter()
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			return
		end
		humanoid.PlatformStand = false
	end
end

return Falldown
