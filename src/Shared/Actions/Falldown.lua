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
	[ActionPhases.ACTIVE] = 1.5,
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

	local flingVelocity = initialState.velocity + Vector3.new(0, 50, 0)
	local rotVelocity = Vector3.new(0, 1, 0):Cross(flingVelocity.unit)
	rootPart.RotVelocity = rotVelocity * 10
	rootPart.Velocity = flingVelocity.unit * 50

	ActionState.setActionState(Falldown.actionId, {
		startTime = tick(),
	})
end

function Falldown.step(state)
	if ActionState.isComplete(Falldown.actionId) then
		ActionState.setActionState(Falldown.actionId, nil)

		local character = GetLocalCharacter()
		local humanoid = character:FindFirstChild("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not (humanoid and rootPart) then
			return
		end

		local targetLookVector = (rootPart.CFrame.UpVector * Vector3.new(1, 0, 1)).unit
		if rootPart.CFrame.LookVector.Y > 0 then
			targetLookVector = targetLookVector * -1
		end
		local newPos = rootPart.Position + Vector3.new(0, 2, 0)
		rootPart.CFrame = CFrame.new(newPos, newPos+targetLookVector)
		humanoid.PlatformStand = false
	end
end

return Falldown
