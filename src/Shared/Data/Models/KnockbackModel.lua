local KnockbackModel = {}

function KnockbackModel.new(direction, speed, duration)
	return {
		direction = direction,
		speed = speed,
		duration = duration,
		startTime = tick(),
	}
end

function KnockbackModel.applyScalarModifier(knockback, modifierValue)
	return {
		direction = knockback.direction,
		speed = knockback.speed * modifierValue,
		duration = knockback.duration * modifierValue,
		startTime = knockback.startTime,
	}
end

return KnockbackModel
