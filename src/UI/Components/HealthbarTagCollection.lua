local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Roact = import "Roact"
local HealthbarTag = import "UI/Components/HealthbarTag"

local HealthbarTagCollection = Roact.PureComponent:extend("HealthbarTagCollection")

-- local updateInterval = 0.1

function HealthbarTagCollection:init()
	self.lastUpdateTime = 0
end

function HealthbarTagCollection:render()
	local characterInfos = self.state.characterInfos
	if not characterInfos then
		return
	end

	local children = {}

	for i = 1, #characterInfos do
		local characterInfo = characterInfos[i]
		local name = characterInfo.name
		local healthAlpha = characterInfo.healthAlpha
		local rootPart = characterInfo.rootPart

		local worldPosCF = CFrame.new(rootPart.Position + Vector3.new(0, 6, 0))
		children[name] = Roact.createElement(HealthbarTag, {
			adornee = rootPart,
			offset = rootPart.CFrame:ToObjectSpace(worldPosCF).p,
			healthAlpha = healthAlpha,
		})
	end

	return Roact.createElement("Folder", nil, children)
end

function HealthbarTagCollection:didMount()
	RunService.Heartbeat:Connect(function()
		-- if tick() - self.lastUpdateTime < updateInterval then
		-- 	return
		-- end

		self.lastUpdateTime = tick()
		local characterInfos = {}
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= Players.LocalPlayer then
				local character = player.Character
				local healthValue = character and character:FindFirstChild("HealthVal")
				local rootPart = character and character:FindFirstChild("HumanoidRootPart")
				if healthValue and rootPart then
					characterInfos[#characterInfos+1] = {
						rootPart = rootPart,
						healthAlpha = healthValue.Value / 100,
						name = player.Name
					}
				end
			end
		end

		self:setState({
			characterInfos = characterInfos
		})
	end)
end

return HealthbarTagCollection
