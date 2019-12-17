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

	local flingVelocity = initialState.velocity + Vector3.new(0, 100, 0)
	local rotVelocity = Vector3.new(0, 1, 0):Cross(flingVelocity.unit) * 15
	rootPart.RotVelocity = rotVelocity
	rootPart.Velocity = flingVelocity.unit * 70

	ActionState.setActionState(Knockout.actionId, {
		startTime = tick(),
		rotVel = rotVelocity,
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

	local elapsed = tick() - state.startTime

	if elapsed < 1 then
		local topSpinVel = (rootPart.CFrame.UpVector * 20)
		rootPart.RotVelocity = state.rotVel + topSpinVel
	end
end

return Knockout
