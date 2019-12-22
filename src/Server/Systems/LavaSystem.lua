local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local Lava = import "Workspace/Lava"
local LavaCutoff = import "Workspace/LavaCutoff"

local startCF = Lava.CFrame
local endCF = CFrame.new(startCF.p.X, LavaCutoff.Position.Y - (Lava.Size.Y/2) , startCF.p.Z)

local isMoving = false
local startTime = 0
local tweenTime = 2.25 * 60

local LavaSystem = {}

function LavaSystem.startMoving()
	startTime = tick()
	isMoving = true
end

function LavaSystem.resetPosition()
	isMoving = false
	Lava.CFrame = startCF
end

function LavaSystem.start()
	RunService.Heartbeat:Connect(function()
		Lava.Texture1.OffsetStudsU = math.sin(tick() / 10) * 27
		Lava.Texture1.OffsetStudsV = math.cos(tick() / 7) * 31

		Lava.Texture2.OffsetStudsU = math.sin(tick() / 16) * -22
		Lava.Texture2.OffsetStudsV = math.cos(tick() / 12) * -30

		if isMoving then
			local elapsedTime = tick() - startTime
			local tweenAlpha = math.min(elapsedTime / tweenTime, 1)

			Lava.CFrame = startCF:Lerp(endCF, tweenAlpha)
		end
	end)
end

local function getCharHeight(playerState)
	local character = playerState.characterModel
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	local rootHeight = rootPart.Position.Y
	local footCF = rootPart.CFrame * CFrame.new(0, -rootPart.Size.Y/2, 0) * CFrame.new(0, -humanoid.HipHeight, 0)
	local footHeight = footCF.p.Y

	return math.min(rootHeight, footHeight)
end

function LavaSystem.isInLava(playerState)
	local charHeight = getCharHeight(playerState)
	local lavaHeight = Lava.Position.Y

	if charHeight < lavaHeight then
		return true
	end
end

return LavaSystem
