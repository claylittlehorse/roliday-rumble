local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

-- local Animations = import "Client/Systems/Animations"
-- local AnimationNames = import "Data/AnimationNames"
local GetLocalCharacter = import "Utils/GetLocalCharacter"

-- determine which attach we should be doing, delegate that action

local GetUp = {}
GetUp.movementPriority = 1
GetUp.actionId = ActionIds.GET_UP
GetUp.phaseTimings = {
	[ActionPhases.WINDUP] = 0,
	[ActionPhases.ACTIVE] = 0.15,
	[ActionPhases.COOLDOWN] = 0,
}

function GetUp.validate()
	local isKnockedOut = ActionState.hasAction(ActionIds.KNOCKDOWN)
	local isFallenDown = ActionState.hasAction(ActionIds.FALLDOWN)

	return isKnockedOut or isFallenDown
end

function GetUp.init(initialState)
	ActionState.stopActionsInMap({
		[ActionIds.KNOCKOUT] = true,
		[ActionIds.FALLDOWN] = true,
	})

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
	local targetCF = CFrame.new(newPos, newPos+targetLookVector)

	ActionState.setActionState(GetUp.actionId, {
		startTime = tick(),
		targetCF = targetCF,
	})
end

function GetUp.step(state)
	local character = GetLocalCharacter()
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and rootPart) then
		ActionState.setActionState(GetUp.actionId, nil)
		return
	end

	rootPart.CFrame = rootPart.CFrame:Lerp(state.targetCF, 0.5)

	if ActionState.isComplete(GetUp.actionId) then
		rootPart.CFrame = state.targetCF
		humanoid.PlatformStand = false
		ActionState.setActionState(GetUp.actionId, nil)
	end
end

return GetUp
