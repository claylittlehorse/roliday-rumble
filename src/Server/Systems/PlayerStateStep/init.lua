local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local StateRemove = import "./StateRemove"
local HealthRegen = import "./HealthRegen"

local PlayerStateManager = import "Server/Systems/PlayerStateManager"

local PlayerStateStep = {}

function PlayerStateStep.start()
	RunService.Heartbeat:Connect(function()
		local playerStates = PlayerStateManager.getPlayerStates()

		StateRemove.step(playerStates)
		HealthRegen.step(playerStates)
	end)
end

return PlayerStateStep
