local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local t = import "t"

local Mesh = import "../Mesh"

local Line = Roact.PureComponent:extend("Line")

Line.defaultProps = {
	visible = true,

	transparency = 0.5,
	lineTransparency = 0,
	color = Color3.fromRGB(255, 255, 255),
}

Line.validateProps = t.strictInterface({
	visible = t.optional(t.boolean),

	position = t.Vector3,

	transparency = t.optional(t.number),
	color = t.optional(t.Color3),
})

function Line:init()
	self.model = Instance.new("Model")
end

function Line:render()
	local props = self.props

	self.model.Parent = props.target
	local transparency = props.visible and props.transparency or 0

	return Roact.createElement("Model", {
		[Roact.Ref] = self.modelRef
	}, {
		Point = Roact.createElement(Mesh, {
			importPath = "Assets/PhysicsDebug/LineEnd",
			Material = Enum.Material.Neon,

			size = Vector3.new(0.2, 0.2, 0.2),
			cframe = CFrame.new(props.position),
			color = props.color,
			transparency = transparency,
		}),
	})
end

return Line
