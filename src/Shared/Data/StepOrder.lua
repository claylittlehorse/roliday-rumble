local Camera = Enum.RenderPriority.Camera.Value

return {
	ANIM = Camera - 7,
	ACTION_QUEUE = Camera - 6,
	ACTION_STATE = Camera - 5,
	COLLISION_UPDATE = Camera - 4,
	MOVEMENT = Camera - 3,
	DAMAGE = Camera - 2,
	SHAKE = Camera - 1,
	CAMERA = Camera + 1,
}
