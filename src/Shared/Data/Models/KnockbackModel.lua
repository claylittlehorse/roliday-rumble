local KnockbackModel = {}

function KnockbackModel.new(options)
	return {
		direction = options.direction,
		speed = options.speed,
		duration = options.duration,
		startTime = tick(),
		shouldKnockdown = options.shouldKnockdown,
	}
end

function KnockbackModel.applyScalarModifier(knockback, modifierValue)
	return {
		direction = knockback.direction,
		speed = knockback.speed * modifierValue,
		duration = knockback.duration * modifierValue,
		startTime = knockback.startTime,
		shouldKnockdown = knockback.shouldKnockdown,
	}
end

return KnockbackModel
