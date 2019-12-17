local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"
local PlayerStateManager = import "Server/Systems/PlayerStateManager"
local IsValidCharacter = import "GameUtils/IsValidCharacter"

local Carrying = {}

local function isCarrierValid(carrierState)
	local isAlive = carrierState.health.currentHealth > 0
	local isntKnockedOut = not carrierState.ko.isKnockedOut
	local isntBeingCarried = not carrierState.carrying.isBeingCarried

	local isValid = isAlive and isntKnockedOut and isntBeingCarried
	return isValid
end

local function isCarriedValid(carriedState)
	local isKnockedOut = not carriedState.ko.isKnockedOut
	local isntBeingCarried = not carriedState.carrying.isBeingCarried

	local isValid = isKnockedOut and isntBeingCarried
	return isValid
end

local function setNetworkOwner(carriedState, newOwnerPlayer)
	local descendants = carriedState.characterModel:GetDescendants()
	for _, descendant in pairs(descendants) do
		if descendant:IsA("BasePart") then
			descendant:SetNetworkOwner(newOwnerPlayer)
		end
	end

	carriedState.carrying.networkOwner = newOwnerPlayer
end

local function setCarryingPlayer(carrierPlayer, carrierState, carriedPlayer, carriedState)
	carriedState.carrying.isBeingCarried = true
	carrierState.isCarrying = true

	setNetworkOwner(carriedState, carrierPlayer)

	local carrierCharacter = carrierPlayer.Character
	local carriedCharacter = carriedPlayer.Character

	if not (IsValidCharacter(carrierCharacter) and IsValidCharacter(carriedCharacter)) then
		return
	end

	local carrierRoot = carrierCharacter:FindFirstChild("HumanoidRootPart")
	local carriedRoot = carriedCharacter:FindFirstChild("HumanoidRootPart")
	local baseCF = carrierRoot.CFrame

	local carriedOffsetCF = baseCF * CFrame.new(0, 4, 0) * CFrame.Angles(math.pi, 0, math.pi / 2)
	carriedPlayer:SetPrimaryPartCFrame(carriedOffsetCF)

	carriedRoot.RootPriority = 1
	carrierRoot.RootPriority = 2

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = carrierRoot
	weldConstraint.Part1 = carriedRoot

	carrierState.isCarrying = true
	carrierState.carryingWeld = weldConstraint
end

function Carrying.start()
	Network.hookEvent(CombatEvents.REQUEST_CARRY, function(carrierPlayer, carriedPlayer)
		local playerStates = PlayerStateManager.getPlayerStates()

		local carrierUserId = tostring(carrierPlayer.UserId)
		local carrierState = playerStates[carrierUserId]

		local carriedUserId = tostring(carriedPlayer.UserId)
		local carriedState = playerStates[carriedUserId]

		if not (carrierState and carriedState) then
			return
		end

		if not (isCarrierValid(carrierState) and isCarriedValid(carriedState)) then
			return
		end

		setCarryingPlayer(carrierPlayer, carrierState, carriedPlayer, carriedState)
	end)
end

return Carrying
