local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CheckCollision = import "Utils/CheckCollision"
local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"
local IsValidCharacter = import "GameUtils/IsValidCharacter"

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local StepOrder = import "Data/StepOrder"

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
		if not _currentDamage then
			return
		end

		if _currentDamage:shouldCleanup() then
			_currentDamage = nil
			return
		end

		for _, victimPlayer in ipairs(getDamageablePlayers()) do
			local character = victimPlayer.Character
			local characterCollider = ColliderFromCharacter.characterCollider(character)
			if canDamageThing(_currentDamage, victimPlayer, characterCollider) then
				Network.fireServer(CombatEvents.REPLICATE_DAMAGE, victimPlayer, 20)
				_currentDamage:onThingDamaged(victimPlayer)
			end
		end
	end)
end

return DamageSolver
