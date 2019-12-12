local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local HealthQueue = import "./HealthQueue"
local StateRemove = import "./StateRemove"
local Carrying = import "./Carrying"

local PlayerStateManager = import "Server/Systems/PlayerStateManager"

local PlayerStateStep = {}

function PlayerStateStep.start()
	RunService.Heartbeat:Connect(function()
		local playerStates = PlayerStateManager.getPlayerStates()

		-- HealthQueue.step(playerStates)
		-- Carrying.step(playerStates)
		StateRemove.step(playerStates)
	end)
end

return PlayerStateStep
