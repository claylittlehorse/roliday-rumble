local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local t = import "t"

local Mesh = import "../Mesh"
local Point = import "../Point"

local Sphere = Roact.PureComponent:extend("Sphere")

Sphere.defaultProps = {
	visible = true,

	transparency = 0.5,
	lineTransparency = 0,
	color = Color3.fromRGB(255, 255, 255)
}

Sphere.validateProps = t.strictInterface({
	collider = t.table,

	transparency = t.optional(t.number),
	lineTransparency = t.optional(t.number),
	color = t.optional(t.Color3),
})

function Sphere:init()
	self.model = Instance.new("Model")
end

function Sphere:render()
	local props = self.props
	local collider = props.collider

	self.model.Parent = props.target

	local transparency = props.visible and props.transparency or 0

	return Roact.createElement("Model", {}, {
		CapsuleTop = Roact.createElement(Mesh, {
			importPath = "Assets/PhysicsDebug/CapsuleEnd",
			Material = Enum.Material.Neon,

			size = Vector3.new(collider.radius * 2, collider.radius * 2, collider.radius * 2),
			cframe = CFrame.new(collider.center),
			color = props.color,
			transparency = transparency,
		}),
		CapsuleBottom = Roact.createElement(Mesh, {
			importPath = "Assets/PhysicsDebug/CapsuleEnd",

			size = Vector3.new(collider.radius * 2, collider.radius * 2, collider.radius * 2),
			cframe = CFrame.new(collider.center) * CFrame.Angles(0, math.pi, 0),
			color = props.color,
			transparency = transparency,
		}),
		Line = Roact.createElement(Point, {
			transparency = props.visible and props.lineTransparency or 0,
			color = props.color,
			position = collider.center,
		})
	})
end

return Sphere
