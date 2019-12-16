local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionPhases = import "Data/ActionPhases"

local Animations = import "Client/Systems/Animations"
local AnimationNames = import "Data/AnimationNames"

local GetLocalCharacter = import "Utils/GetLocalCharacter"

-- determine which attach we should be doing, delegate that action

local Falldown = {}
Falldown.movementPriority = 1
Falldown.actionId = ActionIds.FALLDOWN
Falldown.phaseTimings = {
	[ActionPhases.WINDUP] = 0,
	[ActionPhases.ACTIVE] = 1.4,
	[ActionPhases.COOLDOWN] = 0.1,
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

	local flingVelocity = initialState.velocity + Vector3.new(0, 40, 0)
	local rotVelocity = Vector3.new(0, 1, 0):Cross(flingVelocity.unit)
	rootPart.RotVelocity = rotVelocity * 20
	rootPart.Velocity = flingVelocity.unit * 60

	ActionState.setActionState(Falldown.actionId, {
		startTime = tick(),
	})

	Animations.playAnimation(AnimationNames.CARRYING, function(anim)
		if not anim.isPlaying then
			return true
		end

		if not ActionState.hasAction(Falldown.actionId) then
			anim:Stop()
			return true
		end

		return false
	end)
end

function Falldown.step(state)
	local character = GetLocalCharacter()
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and rootPart) then
		ActionState.setActionState(Falldown.actionId, nil)
		return
	end

	if ActionState.isCooldown(Falldown.actionId) and not state.targetCF then
		local targetLookVector = (rootPart.CFrame.UpVector * Vector3.new(1, 0, 1)).unit
		if rootPart.CFrame.LookVector.Y > 0 then
			targetLookVector = targetLookVector * -1
		end
		local newPos = rootPart.Position + Vector3.new(0, 2, 0)
		state.targetCF = CFrame.new(newPos, newPos+targetLookVector)
	elseif ActionState.isCooldown(Falldown.actionId) then
		rootPart.CFrame = rootPart.CFrame:Lerp(state.targetCF, 0.5)
	end

	if ActionState.isComplete(Falldown.actionId) then
		rootPart.CFrame = state.targetCF
		humanoid.PlatformStand = false

		ActionState.setActionState(Falldown.actionId, nil)
	end
end

return Falldown
