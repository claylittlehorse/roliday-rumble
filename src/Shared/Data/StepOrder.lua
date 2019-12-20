local Camera = Enum.RenderPriority.Camera.Value

return {
	ANIM = Camera - 5,
	ACTION_QUEUE = Camera - 2,
	ACTION_STATE = Camera - 3,
	MOVEMENT = Camera - 4,
	DAMAGE = Camera - 1,
	CAMERA = Camera + 1,
}
