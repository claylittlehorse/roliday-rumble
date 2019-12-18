local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"

local ThrownPlayerDamage = {}
ThrownPlayerDamage.__index = ThrownPlayerDamage

function ThrownPlayerDamage.new(thrownCharacter)
    local self = {
		startTime = tick(),
		thrownCharacter = thrownCharacter,
		damageAmount = 5,
		isActive = true,
		damagedThings = {},
		shouldKnockdown = true
	}
    return setmetatable(self, ThrownPlayerDamage)
end

function ThrownPlayerDamage:getCollider()
	local thrownCharacter = self.thrownCharacter
	local hitbox = ColliderFromCharacter.thrownCharacterCollider(thrownCharacter)
	return hitbox
end

function ThrownPlayerDamage:setActive(active)
	self.isActive = active
end

function ThrownPlayerDamage:shouldCleanup()
	if tick() - self.startTime > 1.5 then
		return true
	end

	return false
end

function ThrownPlayerDamage:onThingDamaged(thing)
	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local userId = tostring(thing.userId)
		self.damagedThings[userId] = true
	end
end

function ThrownPlayerDamage:canDamageThing(thing)
	if thing == Players.localPlayer then
		return false
	end

	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local userId = tostring(thing.userId)
		if not self.damagedThings[userId] then
			return true
		end

		return false
	end

	return false
end

return ThrownPlayerDamage
