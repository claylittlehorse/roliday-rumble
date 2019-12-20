local import = require(game.ReplicatedStorage.Lib.Import)

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local StepOrder = import "Data/StepOrder"

local Spring = import "Utils/Spring"
local dealDamageSpring = Spring(0, 40, 0.2)
-- local hurtSpring = Spring.new(0)

local Camera = {}

local lastCf

function Camera.start()
	local cam = Workspace.CurrentCamera
	RunService:BindToRenderStep("Camera", StepOrder.CAMERA, function()
		local cf = cam.CFrame--lastCf and cam.CFrame * lastCf:Inverse() or cam.CFrame
		local rotCf = CFrame.new(0, dealDamageSpring:GetPosition(), 0)
		cam.CFrame = rotCf * cf
		-- lastCf = rotCf
	end)
end

Camera.dealDamageSpring = dealDamageSpring

return Camera
