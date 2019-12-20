local import = require(game.ReplicatedStorage.Lib.Import)

local Animations = import "Client/Systems/Animations"
local AnimationNames = import "Data/AnimationNames"
local ActionIds = import "Data/ActionIds"
local ActionState = import "Client/Systems/ActionState"

local Hitstop = import "GameUtils/Hitstop"

local PlayPunchAnim = {}
local _left = true

local function animCallback(anim, actionId)
	if not anim.isPlaying then
		return true
	end

	if Hitstop.isStopped() and anim.Speed ~= 0 then
		anim:AdjustSpeed(0)
	elseif not Hitstop.isStopped() and anim.Speed == 0 then
		anim:AdjustSpeed(1)
	end

	if not ActionState.hasAction(actionId) or ActionState.hasAction(ActionIds.STAGGER) then
		anim:Stop()
		return true
	end

	return false
end

function PlayPunchAnim.heavy(actionId)
	local animName = _left and AnimationNames.HEAVY_LEFT or AnimationNames.HEAVY_RIGHT
	_left = not _left

	Animations.playAnimation(animName, function(anim)
		return animCallback(anim, actionId)
	end)
end

function PlayPunchAnim.light(actionId)
	local animName = _left and AnimationNames.PUNCH_LEFT or AnimationNames.PUNCH_RIGHT
	_left = not _left

	Animations.playAnimation(animName, function(anim)
		return animCallback(anim, actionId)
	end)
end

return PlayPunchAnim
