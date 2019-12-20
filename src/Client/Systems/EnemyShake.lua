local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local StepOrder = import "Data/StepOrder"

local EnemyShake = {}
local shakes = {}

function EnemyShake.shakeCharacter(char, vector, timeLength)
	local baseCf = char.HumanoidRootPart.CFrame
	shakes[#shakes+1] = {
		baseCf = baseCf,
		char = char,
		vector = vector,
		timeLength = timeLength,
		startTime = tick(),

		lastShakeTime = 0,
	}
end

function EnemyShake.start()
	RunService:BindToRenderStep("Shake", StepOrder.SHAKE, function()
		for i, shakeInfo in ipairs(shakes) do
			local elapsed = tick() - shakeInfo.startTime

			if elapsed > shakeInfo.timeLength then
				table.remove(shakes, i)
			-- elseif elapsed < hitLength then
			-- 	local cf = shakeInfo.baseCf + (shakeInfo.vector * (1 + math.sin(elapsed * 20))) * 0.5
			-- 	shakeInfo.char:SetPrimaryPartCFrame(cf)
			else
				shakeInfo.char:SetPrimaryPartCFrame(shakeInfo.baseCf)
			end
		end
	end)
end

return EnemyShake
