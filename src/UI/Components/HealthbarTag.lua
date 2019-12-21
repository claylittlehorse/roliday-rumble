local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local HealthbarTag = Roact.PureComponent:extend("HealthbarTag")

local SIZE_X = 256
local SIZE_Y = 32

local sizeCoef = SIZE_Y/SIZE_X

local SCALE_X = 10
local SCALE_Y = SCALE_X * sizeCoef

local BORDER_SIZE = 5.5
local BORDER_SIZE_X = BORDER_SIZE / SIZE_X
local BORDER_SIZE_Y = BORDER_SIZE / SIZE_Y

local TWEEN_INFO = TweenInfo.new(0.3)

local HEIGHT_OFFSET_Y = 6

function HealthbarTag:init()
	self.state = {
		health = 1,
	}

	self.bgRef = Roact.createRef()
	self.barRef = Roact.createRef()
	self.healthClipRef = Roact.createRef()
	self.catchupClipRef = Roact.createRef()
	self.catchupRef = Roact.createRef()
	self.healthRef = Roact.createRef()

	self.lastHealthChange = 0
	self.fullHealthTime = 0
end

function HealthbarTag:getSize(size, ref)
	local uiObj = ref:getValue()
	if not uiObj then
		return size
	end

	return uiObj.Size
end

function HealthbarTag:getVisible()
	local bgUi = self.bgRef:getValue()
	if not bgUi then
		return false
	end

	return bgUi.Visible
end

function HealthbarTag:render()
	local adornee = self.props.adornee
	local offset = self.props.offset

	return Roact.createElement("BillboardGui", {
		Adornee = adornee,
		StudsOffsetWorldSpace = offset,
		LightInfluence = 0,
		Size = UDim2.new(SCALE_X, 0, SCALE_Y, 0),
		MaxDistance = 175,
	}, {
		Background = Roact.createElement("ImageLabel", {
			Visible = self:getVisible(),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2924872024",
			ImageColor3 = Color3.fromRGB(240, 240, 240),
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 0,

			[Roact.Ref] = self.bgRef
		}, {
			Bar = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Image = "rbxassetid://2924872024",
				ImageColor3 = Color3.fromRGB(80, 80, 80),
				Size = self:getSize(UDim2.new(1 - BORDER_SIZE_X, 0, 1 - BORDER_SIZE_Y, 0), self.barRef),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				ZIndex = 1,

				[Roact.Ref] = self.barRef
			}, {
				HealthClip = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Size = self:getSize(UDim2.new(1, 0, 1, 0), self.healthClipRef),

					[Roact.Ref] = self.healthClipRef,
				}, {
					Health = Roact.createElement("ImageLabel", {
						BackgroundTransparency = 1,
						Image = "rbxassetid://2924872024",
						ImageColor3 = Color3.fromRGB(34, 159, 36),
						Size = self:getSize(UDim2.new(0, 0, 0, 1), self.healthRef),
						ZIndex = 2,

						[Roact.Ref] = self.healthRef
					}),
				}),

				CatchupClip = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Size = self:getSize(UDim2.new(1, 0, 1, 0), self.catchupClipRef),

					[Roact.Ref] = self.catchupClipRef,
				}, {
					CatchUp = Roact.createElement("ImageLabel", {
						BackgroundTransparency = 1,
						Image = "rbxassetid://2924872024",
						ImageColor3 = Color3.fromRGB(255, 47, 47),
						Size = self:getSize(UDim2.new(0, 0, 0, 1), self.catchupRef),
						ZIndex = 1,

						[Roact.Ref] = self.catchupRef,
					}),
				}),
			}),
		})
	})
end

function HealthbarTag:didUpdate(prevProps, prevState)
	local newHealth = self.props.healthAlpha
	local oldHealth = prevProps.healthAlpha

	if newHealth ~= oldHealth then
		if newHealth == 1 then
			self.fullHealthTime = tick()
		else
			self.fullHealthTime = nil
		end
		self.lastHealthChange = tick()

		local catchupRef = self.catchupRef:getValue()
		local catchupClipRef = self.catchupClipRef:getValue()
		local healthClipRef = self.healthClipRef:getValue()
		local bgRef = self.bgRef:getValue()

		if not (catchupClipRef and healthClipRef and catchupRef and bgRef) then
			return
		end

		bgRef.Visible = true
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
end

function HealthbarTag:catchUp()
	local health = self.props.health

	local catchupClipRef = self.catchupClipRef.current
	local healthClipRef = self.healthClipRef.current

	if not (catchupClipRef and healthClipRef) then
		return
	end

	if self.gainedHealth then
		TweenService:Create(healthClipRef, TWEEN_INFO, {
			Size = UDim2.new(health, 0, 1, 0)
		}):Play()
	else
		TweenService:Create(catchupClipRef, TWEEN_INFO, {
			Size = UDim2.new(health, 0, 1, 0)
		}):Play()
	end
end

function HealthbarTag:didMount(prevProps, prevState)
	spawn(function()
		while wait() do
			if self.stop then
				break
			elseif tick() - self.lastHealthChange > 0.5 and not self.caughtUp then
				self:catchUp()
			end
		end
	end)

	self.beatUpdate = RunService.Heartbeat:connect(function()
		local bgRef = self.bgRef:getValue()
		local barRef = self.barRef:getValue()
		local catchupRef = self.catchupRef:getValue()
		local healthRef = self.healthRef:getValue()
		local healthClipRef = self.healthClipRef:getValue()

		if not (bgRef and barRef and catchupRef and healthRef and healthClipRef) then
			return
		end

		local barSizeX = barRef.AbsoluteSize.X

		catchupRef.Size = UDim2.new(0, barSizeX, 1, 0)
		healthRef.Size = UDim2.new(0, barSizeX, 1, 0)

		local percent = healthClipRef.Size.X.Scale

		local hue = percent*120
		local sat = 201
		local value = 160 + (math.min((1-percent) * 2, 1) * 60)
		healthRef.ImageColor3 = Color3.fromHSV(hue / 360, sat / 255, value / 255)

		if self.fullHealthTime and tick() - self.fullHealthTime > 3 then
			bgRef.Visible = false
		end
	end)
end

function HealthbarTag:willUnmount()
	self.beatUpdate:Disconnect()
	self.stop = true
end

return HealthbarTag
