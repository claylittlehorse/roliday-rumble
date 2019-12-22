local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local StateRemove = import "./StateRemove"
local HealthRegen = import "./HealthRegen"
local KnockOut = import "./KnockOut"
local ReconcileCarry = import "./ReconcileCarry"
local ReconcileOwnership = import "./ReconcileOwnership"
local LavaDamage = import "./LavaDamage"

local PlayerStateManager = import "Server/Systems/PlayerStateManager"

local PlayerStateStep = {}

function PlayerStateStep.start()
	RunService.Heartbeat:Connect(function()
		local playerStates = PlayerStateManager.getPlayerStates()

		ReconcileCarry.step(playerStates)
		ReconcileOwnership.step(playerStates)
		StateRemove.step(playerStates)
		LavaDamage.step(playerStates)
		KnockOut.step(playerStates)
		HealthRegen.step(playerStates)
	end)
end

return PlayerStateStep
