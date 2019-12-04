-- Entrypoint to game UI

local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"

local LayoutProvider = import "UI/Root/LayoutProvider"

local function App(store)
	return Roact.createElement(RoactRodux.StoreProvider, { store = store }, {
		Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}, {
			LayoutProvider = Roact.createElement(LayoutProvider)
		})
	})
end

return App
