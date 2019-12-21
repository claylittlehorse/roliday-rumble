local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"
local GetLocalCharacter = import "Utils/GetLocalCharacter"
local ActionState = import "Client/Systems/ActionState"

local Camera = import "Client/Systems/Camera"
local Sound = import "Shared/Systems/Sound"
local CombatState = import "Client/Systems/CombatState"

local Hitstop = import "GameUtils/Hitstop"
local EnemyShake = import "Client/Systems/EnemyShake"

local AttackDamage = {}
AttackDamage.__index = AttackDamage

function AttackDamage.new(actionId, shouldKnockdown, stopLength)
    local self = {
		actionId = actionId,
		damageAmount = 10,
		isActive = true,
		damagedThings = {},
		shouldKnockdown = shouldKnockdown,
		stopLength = stopLength or 0.1
	}
    return setmetatable(self, AttackDamage)
end

function AttackDamage:getCollider()
	local character = GetLocalCharacter()
	local hitbox = ColliderFromCharacter.characterCollider(character)
	return hitbox
end

function AttackDamage:setActive(active)
	self.isActive = active
end

function AttackDamage:shouldCleanup()
	if not ActionState.isActive(self.actionId, Hitstop.tick()) then
		return true
	end

	return false
end

function AttackDamage:onThingDamaged(thing)
	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local userId = tostring(thing.userId)
		self.damagedThings[userId] = true

		Camera.dealDamageSpring:Accelerate(10)
		Sound.playAtCharacter("Hit"..CombatState.comboCount)

		local myChar = GetLocalCharacter()
		local theirChar = thing.Character
		if myChar then
			local myVector = myChar.HumanoidRootPart.CFrame.lookVector
			EnemyShake.shakeCharacter(theirChar, myVector, 0.05)
		end
		Hitstop.stop(self.stopLength)
	end
end

function AttackDamage:canDamageThing(thing)
	if Hitstop.isStopped() or thing == Players.localPlayer then
		return false
	end

	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local character = thing.Character
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

return AttackDamage
