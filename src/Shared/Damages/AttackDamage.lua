local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"
local GetLocalCharacter = import "Utils/GetLocalCharacter"
local ActionState = import "Client/Systems/ActionState"

local Camera = import "Client/Systems/Camera"
local Sound = import "Shared/Systems/Sound"
local CombatState = import "Client/Systems/CombatState"

local AttackDamage = {}
AttackDamage.__index = AttackDamage

function AttackDamage.new(actionId, shouldKnockdown)
    local self = {
		actionId = actionId,
		damageAmount = 10,
		isActive = true,
		damagedThings = {},
		shouldKnockdown = shouldKnockdown
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
	if not ActionState.isActive(self.actionId) then
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
	end
end

function AttackDamage:canDamageThing(thing)
	if thing == Players.localPlayer then
		return false
	end

	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local character = thing.Character
		local health = character and character:FindFirstChild("HealthVal")
		local humanoid = character and character:FindFirstChild("Humanoid")
		if not health or health.Value == 0 or not humanoid or humanoid.PlatformStand then
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
