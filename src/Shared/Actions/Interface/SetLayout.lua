local import = require(game.ReplicatedStorage.Lib.Import)

local Action = import "Action"

return Action(script.Name, function(layoutType)
	return {
		layoutType = layoutType
	}
end)
