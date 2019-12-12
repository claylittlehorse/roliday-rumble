local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CheckCollision = import "Utils/CheckCollision"
local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"

local StepOrder = import "Data/StepOrder"

local DamageSolver = {}
local _currentDamage = nil

local function getCharacter(player)
	local character = player.Character
	if not character:IsDescendantOf(Workspace) then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.PlatformStand then
		return
	end

	return character
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

		for _, player in ipairs(getDamageablePlayers()) do
			local character = player.Character
			local characterCollider = ColliderFromCharacter.characterCollider(character)
			if canDamageThing(_currentDamage, player, characterCollider) then
				print("hurting", character.Name)
				_currentDamage:onThingDamaged(player)
			end
		end
	end)
end

return DamageSolver
