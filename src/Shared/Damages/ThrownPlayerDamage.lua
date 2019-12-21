local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"
local PlaySound = import "GameUtils/PlaySound"
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
		shouldKnockdown = true,
		lastDamage = 0,
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
	local thrownChar = self.thrownCharacter
	local thrownRoot = thrownChar:FindFirstChild("HumanoidRootPart")

	if not thrownRoot then
		return false
	end

	if thrownRoot.Velocity.Magnitude < 10 then
		return true
	end

	return false
end

function ThrownPlayerDamage:onThingDamaged(thing)
	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local userId = tostring(thing.userId)
		self.damagedThings[userId] = true

		local char = thing.Character
		if char then
			PlaySound.character("Bonk", char)
		end

		local myChar = self.thrownCharacter
		local theirChar = thing.Character

		self.lastDamage = tick()
		if myChar then
			local myVector = myChar.HumanoidRootPart.CFrame.lookVector
			EnemyShake.shakeCharacter(theirChar, myVector, 0.15)
			EnemyShake.shakeCharacter(myChar, myVector, 0.15)
		end
	end
end

function ThrownPlayerDamage:canDamageThing(thing)
	if tick() - self.lastDamage < 0.15 or thing == Players.localPlayer then
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
