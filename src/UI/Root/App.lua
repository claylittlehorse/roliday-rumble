-- Entrypoint to game UI

local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"

local LayoutProvider = import "UI/Root/LayoutProvider"

local function App()
	return Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, {
		LayoutProvider = Roact.createElement(LayoutProvider)
	})
end

return App
