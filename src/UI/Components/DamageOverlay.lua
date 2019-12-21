-- FIX ME
local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local Roact = import "Roact"
local Health = import "Client/Systems/Health"
local Spring = import "Utils/Spring"

local MIN_SIZE = 1
local MAX_SIZE = 3.5
local ADD_SIZE = MAX_SIZE - MIN_SIZE

local DamageOverlay = Roact.PureComponent:extend("DamageOverlay")

function DamageOverlay:init()
	self.state = {
		healthAlpha = 1,
	}

	self.spring = Spring(1, 5, 0.9)
	self.healthSpring = Spring(1, 5, 0.9)
end

function DamageOverlay:render()
	local springPos = self.state.springPos or 1
	local alphaPos = self.state.alphaPos or 1

	local transparency = 0.5 * (1 - springPos)

	local currentAddSize = (alphaPos * ADD_SIZE)
	local size = MIN_SIZE + (springPos * currentAddSize)
	return Roact.createElement("ImageLabel", {
		Visible = Health.isActive(),
		BackgroundTransparency = 1,
		Image = "rbxassetid://34854607",
		ImageColor3 = Color3.new(1, 1, 1),
		ImageTransparency = transparency,
		Size = UDim2.fromScale(size, size),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),

		ZIndex = 1,
	})
end

function DamageOverlay:didUpdate(prevProps, prevState)
	local newHealth = self.state.healthAlpha
	local oldHealth = prevState.healthAlpha

	if newHealth < oldHealth then
		self.spring:SetPosition(0)
		self.healthSpring:SetPosition(newHealth)
	end

	self.spring:SetTarget(newHealth)
end

function DamageOverlay:didMount(prevProps, prevState)
	RunService.Heartbeat:connect(function()
		if Health.isActive() then
			local currentHealthAlpha = self.state.healthAlpha
			local health = Health.getHealth() or 0
			local newHealthAlpha = health / 100

			if newHealthAlpha ~= currentHealthAlpha then
				self:setState({
					healthAlpha = newHealthAlpha
				})

				self.lastHealthChange = tick()
			end
		end

		self:setState({
			springPos = self.spring:GetPosition()
		})
	end)

end

return DamageOverlay
