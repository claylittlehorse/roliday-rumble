-- FIX ME
local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Camera = import "Client/Systems/Camera"
local Health = import "Client/Systems/Health"

local SIZE_X = 256
local SIZE_Y = 16

local sizeCoef = SIZE_Y/SIZE_X
local SCALE_X = 0.4

local TWEEN_INFO = TweenInfo.new(0.3)

local HealthBar = Roact.PureComponent:extend("HealthBar")

function HealthBar:init()
	self.state = {
		healthAlpha = 1,
	}

	self.barRef = Roact.createRef()
	self.healthClipRef = Roact.createRef()
	self.catchupClipRef = Roact.createRef()
	self.catchupRef = Roact.createRef()
	self.healthRef = Roact.createRef()

	self.lastHealthChange = 0
	self.fullHealthTime = 0
end

local function round(number, increment)
	return math.floor(number/increment + 0.5) * increment
end

function HealthBar:render()
	local yOffset = self.state.yOffset or 0
	return Roact.createElement("ImageLabel", {
		Visible = Health.isActive(),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2924872024",
		ImageColor3 = Color3.fromRGB(80, 80, 80),
		Size = UDim2.new(SCALE_X, 0, sizeCoef*SCALE_X, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0, 70 - yOffset),
		-- Rotation = -yOffset,
		ZIndex = 1,

		[Roact.Ref] = self.barRef
	}, {
		UISizeConstraint = Roact.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(SIZE_X*2, SIZE_Y*2),
			MinSize = Vector2.new(SIZE_X*0.4, SIZE_Y*0.4)
		}),

		HealthClip = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 1, 0),

			[Roact.Ref] = self.healthClipRef,
		}, {
			Health = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Image = "rbxassetid://2924872024",
				ImageColor3 = Color3.fromRGB(34, 159, 36),
				Size = UDim2.new(0, 0, 0, 1),
				ZIndex = 2,

				[Roact.Ref] = self.healthRef
			}),
		}),

		CatchupClip = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 1, 0),

			[Roact.Ref] = self.catchupClipRef,
		}, {
			CatchUp = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Image = "rbxassetid://2924872024",
				ImageColor3 = Color3.fromRGB(255, 47, 47),
				Size = UDim2.new(0, 0, 0, 1),
				ZIndex = 1,

				[Roact.Ref] = self.catchupRef,
			}),
		}),
	})
end

function HealthBar:didUpdate(prevProps, prevState)
	local newHealth = self.state.healthAlpha
	local oldHealth = prevState.healthAlpha

	local catchupRef = self.catchupRef.current
	local catchupClipRef = self.catchupClipRef.current
	local healthClipRef = self.healthClipRef.current

	if not (catchupClipRef and healthClipRef and catchupRef) then
		return
	end

	self.caughtUp = false

	if newHealth > oldHealth then
		self.gainedHealth = true
		catchupRef.ImageColor3 = Color3.fromRGB(83, 214, 53)

		TweenService:Create(catchupClipRef, TWEEN_INFO, {
			Size = UDim2.new(newHealth, 0, 1, 0)
		}):Play()
	elseif newHealth < oldHealth then
		self.gainedHealth = false
		catchupRef.ImageColor3 = Color3.fromRGB(255, 47, 47)

		TweenService:Create(healthClipRef, TWEEN_INFO, {
			Size = UDim2.new(newHealth, 0, 1, 0)
		}):Play()
	end
end

function HealthBar:catchUp()
	local healthAlpha = self.state.healthAlpha

	local catchupClipRef = self.catchupClipRef.current
	local healthClipRef = self.healthClipRef.current

	if not (catchupClipRef and healthClipRef) then
		return
	end

	if self.gainedHealth then
		TweenService:Create(healthClipRef, TWEEN_INFO, {
			Size = UDim2.new(healthAlpha, 0, 1, 0)
		}):Play()
	else
		TweenService:Create(catchupClipRef, TWEEN_INFO, {
			Size = UDim2.new(healthAlpha, 0, 1, 0)
		}):Play()
	end
end

function HealthBar:didMount(prevProps, prevState)
	spawn(function()
		while wait() do
			if tick() - self.lastHealthChange > 0.6 and not self.caughtUp then
				self:catchUp()
			end
		end
	end)

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

		local barRef = self.barRef.current
		local catchupRef = self.catchupRef.current
		local healthRef = self.healthRef.current
		local healthClipRef = self.healthClipRef.current

		if not (barRef and catchupRef and healthRef and healthClipRef) then
			return
		end

		barRef.Visible = Health.isActive()

		local barSizeX = barRef.AbsoluteSize.X
		catchupRef.Size = UDim2.new(0, barSizeX, 1, 0)
		healthRef.Size = UDim2.new(0, barSizeX, 1, 0)

		local percent = healthClipRef.Size.X.Scale

		local hue = percent*120
		local sat = 201
		local value = 160 + (math.min((1-percent) * 2, 1) * 60)
		healthRef.ImageColor3 = Color3.fromHSV(hue / 360, sat / 255, value / 255)

		self:setState({
			yOffset = round(Camera.takeDamageSpring:GetPosition() * 20, 1)
		})
	end)

end

return HealthBar
