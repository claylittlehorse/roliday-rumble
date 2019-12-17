local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"
local ActionQueue = import "Client/Systems/ActionQueue"
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

function Falldown.step(state, character)
	if ActionState.isComplete(Falldown.actionId) then
		ActionQueue.queueAction(ActionIds.GET_UP)
	end
end

return Falldown
