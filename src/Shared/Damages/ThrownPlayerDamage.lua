local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"
local Sound = import "Shared/Systems/Sound"
local EnemyShake = import "Client/Systems/EnemyShake"

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
	if tick() - self.startTime > 1.25 then
		return true
	end

	return false
end

function ThrownPlayerDamage:onThingDamaged(thing)
	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local userId = tostring(thing.userId)
		self.damagedThings[userId] = true

		local char = thing.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			Sound.playSound("Bonk", root.Position)
		end

		local myChar = self.thrownCharacter
		local theirChar = thing.Character
		if myChar then
			local myVector = myChar.HumanoidRootPart.CFrame.lookVector
			EnemyShake.shakeCharacter(theirChar, myVector, 0.1)
			EnemyShake.shakeCharacter(myChar, myVector, 0.1)
		end
	end
end

function ThrownPlayerDamage:canDamageThing(thing)
	if thing == Players.localPlayer then
		return false
	end

	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local character = thing.Character
		if thing.character == self.thrownCharacter then
			return false
		end
		local health = character and character:FindFirstChild("HealthVal")
		local knockedDown = character and character:FindFirstChild("KnockedDown")
		local isKnockedDown = knockedDown == nil or knockedDown.Value
		local isDead = health == nil or health.Value == 0
		if isKnockedDown or isDead then
			return false
		end

		local userId = tostring(thing.userId)
		if not self.damagedThings[userId] then
			return true
		end

		return false
	end

	return false
end

return ThrownPlayerDamage
