local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local t = import "t"

local Mesh = import "../Mesh"
local Line = import "../Line"

local Capsule = Roact.PureComponent:extend("Capsule")

Capsule.defaultProps = {
	visible = true,


	transparency = 0.5,
	lineTransparency = 0,
	color = Color3.fromRGB(255, 255, 255)
}

Capsule.validateProps = t.strictInterface({
	collider = t.table,

	transparency = t.optional(t.number),
	lineTransparency = t.optional(t.number),
	color = t.optional(t.Color3),
})

function Capsule:init()
	self.model = Instance.new("Model")
end

function Capsule:render()
	local props = self.props
	local collider = props.collider

	local ab = collider.pointA - collider.pointB
	local length = ab.magnitude

	local centerCf = CFrame.new(collider.pointA:Lerp(collider.pointB, 0.5), collider.pointA)
	local orientation = centerCf - centerCf.p

	self.model.Parent = props.target

	local transparency = props.visible and props.transparency or 0

	return Roact.createElement("Model", {}, {
		CapsuleCenter = Roact.createElement(Mesh, {
			importPath = "Assets/PhysicsDebug/CapsuleCenter",

			size = Vector3.new(collider.radius * 2, collider.radius * 2, length),
			cframe = centerCf,
			color = props.color,
			transparency = transparency,
		}),
		CapsuleTop = Roact.createElement(Mesh, {
			importPath = "Assets/PhysicsDebug/CapsuleEnd",
			Material = Enum.Material.Neon,

			size = Vector3.new(collider.radius * 2, collider.radius * 2, collider.radius * 2),
			cframe = CFrame.new(collider.pointA) * orientation,
			color = props.color,
			transparency = transparency,
		}),
		CapsuleBottom = Roact.createElement(Mesh, {
			importPath = "Assets/PhysicsDebug/CapsuleEnd",

			size = Vector3.new(collider.radius * 2, collider.radius * 2, collider.radius * 2),
			cframe = CFrame.new(collider.pointB) * orientation * CFrame.Angles(0, math.pi, 0),
			color = props.color,
			transparency = transparency,
		}),
		Line = Roact.createElement(Line, {
			transparency = props.visible and props.lineTransparency or 0,
			color = props.color,
			pointA = collider.pointA,
			pointB = collider.pointB,
		})
	})
end

return Capsule
