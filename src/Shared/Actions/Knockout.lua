local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"

-- local Animations = import "Client/Systems/Animations"
-- local AnimationNames = import "Data/AnimationNames"
local GetLocalCharacter = import "Utils/GetLocalCharacter"

-- determine which attach we should be doing, delegate that action

local Knockout = {}
Knockout.movementPriority = 1
Knockout.actionId = ActionIds.KNOCKOUT

function Knockout.validate()
	local isNotKnockedOut = not ActionState.hasAction(Knockout.actionId)

	return isNotKnockedOut
end

function Knockout.init(initialState)
	local character = GetLocalCharacter()
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and rootPart) then
		return
	end
	humanoid.PlatformStand = true

	local flingVelocity = initialState.velocity + Vector3.new(0, 140, 0)
	local rotVelocity = Vector3.new(0, 1, 0):Cross(flingVelocity.unit)
	rootPart.RotVelocity = rotVelocity * 30
	rootPart.Velocity = flingVelocity.unit * 65

	ActionState.setActionState(Knockout.actionId, {
		startTime = tick(),
	})

	-- Animations.playAnimation(AnimationNames.CARRYING, function(anim)
	-- 	if not anim.isPlaying then
	-- 		return true
	-- 	end

	-- 	if not ActionState.hasAction(Knockout.actionId) then
	-- 		anim:Stop()
	-- 		return true
	-- 	end

	-- 	return false
	-- end)
end

function Knockout.step(state)
	local character = GetLocalCharacter()
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and rootPart) then
		ActionState.setActionState(Knockout.actionId, nil)
		return
	end
end

return Knockout
