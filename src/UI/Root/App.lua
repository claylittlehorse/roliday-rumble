-- Entrypoint to game UI

local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local HealthBar = import "UI/Components/HealthBar"

local function App()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, {
		HealthBar = Roact.createElement(HealthBar),
	})
end

return App
