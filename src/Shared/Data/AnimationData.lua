local import = require(game.ReplicatedStorage.Lib.Import)
local AnimationNames = import "Data/AnimationNames"

local AnimationData = {
	[AnimationNames.HEAVY_LEFT] = {
		anim = import "Assets/Animations/HeavyLeft",
		weight = 10,
		priority = Enum.AnimationPriority.Action,
		looped = false,
	},
	[AnimationNames.HEAVY_RIGHT] = {
		anim = import "Assets/Animations/HeavyRight",
		weight = 10,
		priority = Enum.AnimationPriority.Action,
		looped = false,
	},
	[AnimationNames.PUNCH_LEFT] = {
		anim = import "Assets/Animations/PunchLeft",
		weight = 10,
		priority = Enum.AnimationPriority.Action,
		looped = false,
	},
	[AnimationNames.PUNCH_RIGHT] = {
		anim = import "Assets/Animations/PunchRight",
		weight = 10,
		priority = Enum.AnimationPriority.Action,
		looped = false,
	},

	[AnimationNames.CARRYING] = {
		anim = import "Assets/Animations/Carrying",
		weight = 10,
		priority = Enum.AnimationPriority.Action,
		looped = true,
	},
	[AnimationNames.FLAIL] = {
		anim = import "Assets/Animations/Flail",
		weight = 10,
		priority = Enum.AnimationPriority.Action,
		looped = true,
		speed = 2,
	}
}

return AnimationData
