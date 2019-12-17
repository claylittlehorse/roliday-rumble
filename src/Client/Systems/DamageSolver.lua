local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CheckCollision = import "Utils/CheckCollision"
local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"
local IsValidCharacter = import "GameUtils/IsValidCharacter"
local GetLocalCharacter = import "Utils/GetLocalCharacter"

-- local Knockback = import "Shared/Systems/Knockback"
local KnockbackModel = import "Data/Models/KnockbackModel"

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local StepOrder = import "Data/StepOrder"

local KNOCKBACK_SPEED = 30
local KNOCKBACK_LENGTH = 0.3

local DamageSolver = {}
local _currentDamage = nil

local function getCharacter(player)
	local character = player.Character
	return (character and IsValidCharacter(character)) and character
end

local function getDamageablePlayers()
	local players = Players:GetPlayers()
	local damageablePlayers = {}

	for _, player in pairs(players) do
		local character = getCharacter(player)
		if character then
			damageablePlayers[#damageablePlayers+1] = player
		end
	end

	return damageablePlayers
end

local function canDamageThing(damage, thing, thingCollider)
	if not damage:canDamageThing(thing) then
		return false
	end

	local collider = damage:getCollider()
	if CheckCollision(collider, thingCollider) then
		return true
	end

	return false
end

function DamageSolver.setCurrentDamage(damage)
	_currentDamage = damage
end

function DamageSolver.start()
	RunService:BindToRenderStep("DamageStep", StepOrder.DAMAGE, function()
		local character = GetLocalCharacter()
		if not (character and IsValidCharacter(character)) or not _currentDamage then
			return
		end

		if _currentDamage:shouldCleanup() then
			_currentDamage = nil
			return
		end

		for _, victimPlayer in ipairs(getDamageablePlayers()) do
			local victimCollider = ColliderFromCharacter.characterCollider(victimPlayer.Character)
			if canDamageThing(_currentDamage, victimPlayer, victimCollider) then
				local rootPart = character:FindFirstChild("HumanoidRootPart")

				local knockbackModel = KnockbackModel.new({
					direction = rootPart.CFrame.LookVector,
					speed = KNOCKBACK_SPEED,
					length = KNOCKBACK_LENGTH,
					shouldKnockdown = _currentDamage.shouldKnockdown
				})
				Network.fireServer(CombatEvents.REPLICATE_DAMAGE, victimPlayer, {
					damage = _currentDamage.damageAmount,
					knockback = knockbackModel
				})
				_currentDamage:onThingDamaged(victimPlayer)
			end
		end
	end)
end

return DamageSolver
