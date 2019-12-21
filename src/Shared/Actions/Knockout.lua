local import = require(game.ReplicatedStorage.Lib.Import)

local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"

-- local Animations = import "Client/Systems/Animations"
-- local AnimationNames = import "Data/AnimationNames"
local GetLocalCharacter = import "Utils/GetLocalCharacter"

local Drop = import "Shared/Actions/Drop"

-- determine which attach we should be doing, delegate that action

local Knockout = {}
Knockout.movementPriority = 1
Knockout.actionId = ActionIds.KNOCKOUT

function Knockout.validate()
	local isNotKnockedOut = not ActionState.hasAction(Knockout.actionId)
	return isNotKnockedOut
end

function Knockout.init(initialState)
	if ActionState.hasAction(ActionIds.CARRY) then
		Drop.init()
	end

	local character = GetLocalCharacter()
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and rootPart) then
		return
	end
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	local flingVelocity = initialState.velocity + Vector3.new(0, 60, 0)
	local rotVelocity = Vector3.new(0, 1, 0):Cross(flingVelocity.unit) * 10
	rootPart.RotVelocity = rotVelocity
	rootPart.Velocity = flingVelocity.unit * 90

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

function Knockout.step(state, character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	local elapsed = tick() - state.startTime

	humanoid.PlatformStand = true

	if elapsed < 1 then
		local topSpinVel = (rootPart.CFrame.UpVector * 20)
		rootPart.RotVelocity = state.rotVel + topSpinVel
	end
end

return Knockout
