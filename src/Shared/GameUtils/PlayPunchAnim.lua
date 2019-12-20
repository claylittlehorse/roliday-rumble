local import = require(game.ReplicatedStorage.Lib.Import)

local Animations = import "Client/Systems/Animations"
local AnimationNames = import "Data/AnimationNames"
local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"

local PlayPunchAnim = {}
local _left = true

function PlayPunchAnim.heavy(actionId)
	local animName = _left and AnimationNames.HEAVY_LEFT or AnimationNames.HEAVY_RIGHT
	_left = not _left

	Animations.playAnimation(animName, function(anim)
		if not anim.isPlaying then
			return true
		end

		if not ActionState.hasAction(actionId) or ActionState.hasAction(ActionIds.STAGGER) then
			anim:Stop()
			return true
		end

		return false
	end)
end

function PlayPunchAnim.light(actionId)
	local animName = _left and AnimationNames.PUNCH_LEFT or AnimationNames.PUNCH_RIGHT
	_left = not _left

	Animations.playAnimation(animName, function(anim)
		if not anim.isPlaying then
			return true
		end

		if not ActionState.hasAction(actionId) or ActionState.hasAction(ActionIds.STAGGER) then
			anim:Stop()
			return true
		end

		return false
	end)
end

return PlayPunchAnim
