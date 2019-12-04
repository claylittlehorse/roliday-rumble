local import = require(game.ReplicatedStorage.Lib.Import)

local Action = import "Action"
local t = import "t"

local check = t.tuple(t.string, t.boolean)
return Action(script.Name, function(uiId, enabled)
	assert(check(uiId, enabled))

	return {
		uiId = uiId,
		enabled = enabled
	}
end)
