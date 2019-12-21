-- Entrypoint to game UI

local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local HealthBar = import "UI/Components/HealthBar"
local DamageOverlay = import "UI/Components/DamageOverlay"

local function App()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, {
		HealthBar = Roact.createElement(HealthBar),
		DamageOverlay = Roact.createElement(DamageOverlay),
	})
end

return App
