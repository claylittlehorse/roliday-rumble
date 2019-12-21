-- FIX ME
local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Roact = import "Roact"
local FullscreenViewport = import "../FullscreenViewport"
local HitboxState = import "Client/Systems/HitboxState"
local DamageSolver = import "Client/Systems/DamageSolver"
local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"
local ColliderTypes = import "Data/ColliderTypes"
local typeToComponentMap = {
	[ColliderTypes.CAPSULE] = import "../Capsule",
	[ColliderTypes.SPHERE] = import "../Sphere"
}

local HitboxDisplay = Roact.PureComponent:extend("HitboxDisplay")

function HitboxDisplay:render(props)
	local hitboxes = self.state.hitboxes
	if not hitboxes then
		return
	end

	local renderedHitboxes = {}
	for i, hitboxInfo in ipairs(hitboxes) do
		local component = typeToComponentMap[hitboxInfo.collider.type]

		renderedHitboxes[i] = Roact.createElement(component, {
			collider = hitboxInfo.collider,
			color = hitboxInfo.color
		})
	end

	return Roact.createElement(FullscreenViewport, {},
		renderedHitboxes
	)
end

function HitboxDisplay:didMount()
	RunService.Heartbeat:Connect(function()
		local hitboxes = {}

		if not HitboxState.visible then
			self:setState({
				hitboxes = Roact.None
			})
			return
		end

		for _, player in pairs(Players:GetPlayers()) do
			local character = player.Character
			local healthValue = character and character:FindFirstChild("HealthVal")
			if healthValue then
				hitboxes[#hitboxes+1] = {
					collider = ColliderFromCharacter.characterCollider(character),
					color = Color3.fromRGB(107, 255, 248)
				}
			end
		end

		for _, damage in pairs(DamageSolver.getDamages()) do
			if damage.damageAmount then
				hitboxes[#hitboxes+1] = {
					collider = damage:getCollider(),
					color = Color3.fromRGB(255, 0, 0)
				}
			end
		end

		self:setState({
			hitboxes = hitboxes
		})
	end)
end

return HitboxDisplay
