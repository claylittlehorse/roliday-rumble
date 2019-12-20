local Camera = Enum.RenderPriority.Camera.Value

return {
	ANIM = Camera -6,
	ACTION_QUEUE = Camera - 5,
	ACTION_STATE = Camera - 4,
	MOVEMENT = Camera - 3,
	DAMAGE = Camera - 2,
	SHAKE = Camera - 1,
	CAMERA = Camera + 1,
}
