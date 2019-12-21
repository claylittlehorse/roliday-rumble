local import = require(game.ReplicatedStorage.Lib.Import)

local IsValidCharacter = import "GameUtils/IsValidCharacter"
local Players = game:GetService("Players")

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"
local CollisionGroups = import "Shared/Systems/CollisionGroups"

local Sounds = import "Assets/Sounds"

local PlayerStateManager = {}
local playerStates = {}

local MAX_HEALTH = 100

local disabledStates = {
	Enum.HumanoidStateType.Seated,
	Enum.HumanoidStateType.Flying,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.PlatformStanding,
}

local function setupCharacter(player)
	local health = Instance.new("NumberValue")
	health.Name = "HealthVal"
	health.Value = MAX_HEALTH
	health.Parent = player.Character

	local knockedDown = Instance.new("BoolValue")
	knockedDown.Name = "KnockedDown"
	knockedDown.Value = false
	knockedDown.Parent = player.Character

	for _, part in pairs(player.Character:GetChildren()) do
		if part:IsA("BasePart") then
			part.CustomPhysicalProperties = PhysicalProperties.new(10, 3, 0, 5, 5)
		end
	end

	for _, humanoidState in pairs(disabledStates) do
		player.Character.Humanoid:SetStateEnabled(humanoidState, false)
	end

	if not player.Character.HumanoidRootPart:FindFirstChild("Sounds") then
		local soundClone = Sounds:Clone()
		soundClone.Parent = player.Character.HumanoidRootPart
		for _, sound in pairs(soundClone:GetChildren()) do
			sound.Parent = soundClone.Parent
		end
	end

	CollisionGroups.setCharacterCollisionGroup(player.Character, CollisionGroups.groupIds.PLAYER_COLLIDE)
end

local function getInitialState(player)
	return {
		characterModel = player.Character,
		player = player,
		health = {
			currentHealth = MAX_HEALTH,
			lastDamagedTime = 0,
			lastRegenedTime = 0,
		},
		ko = {
			knockedOutTime = 0,
			isKnockedOut = false,

			isKnockedDown = false,
			knockedDownTime = 0,
		},
		carrying = {
			playerImCarrying = nil,
			playerCarryingMe = nil,
			lastCarriedTime = 0,
			networkOwner = player,
			carryingWeld = nil,
		}
	}
end

function PlayerStateManager.getPlayerStates()
	return playerStates
end

function PlayerStateManager.resetPlayerState(player, shouldActivate)
	local userId = tostring(player.UserId)
	local character = player.character
	if IsValidCharacter(character) and not playerStates[userId] then
		print("resetting", player, shouldActivate)
		local state = getInitialState(player)
		setupCharacter(player)
		playerStates[userId] = state

		Network.fireClient(CombatEvents.REPLICATE_ACTIVE, player, shouldActivate, true)
		if shouldActivate then
			Network.fireClient(CombatEvents.REPLICATE_HEALTH, player, state.health.currentHealth)
		end
	end
end

function PlayerStateManager.resetPlayerStates()
	playerStates = {}
	local players = Players:GetPlayers()
	for _, player in pairs(players) do
		PlayerStateManager.resetPlayerState(player, true)
	end
end

return PlayerStateManager
