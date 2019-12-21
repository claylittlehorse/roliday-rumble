local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local ActionState = import "Client/Systems/ActionState"
local ActionIds = import "Data/ActionIds"
local GetLocalCharacter = import "Utils/GetLocalCharacter"

local Camera = import "Client/Systems/Camera"

local Health = {}
local currentHealth
local isActive = false

local disabledStates = {
	Enum.HumanoidStateType.Seated,
	Enum.HumanoidStateType.Flying,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.PlatformStanding,
}

function Health.getHealth()
	return currentHealth
end

function Health.isActive()
	return isActive
end

function Health.start()
	Network.hookEvent(CombatEvents.REPLICATE_HEALTH, function(health)
		if currentHealth and currentHealth > health then
			Camera.takeDamageSpring:Accelerate(health == 0 and 50 or 20)
		end
		currentHealth = health
	end)

	Network.hookEvent(CombatEvents.REPLICATE_ACTIVE, function(active)
		isActive = active

		local char = GetLocalCharacter()
		local humanoid = char and char:FindFirstChild("Humanoid")
		if isActive and humanoid then
			for _, humanoidState in pairs(disabledStates) do
				humanoid:SetStateEnabled(humanoidState, false)
			end
		end
	end)

	RunService.Heartbeat:Connect(function()
		local isKnockedDown = ActionState.hasAction(ActionIds.KNOCKOUT) or ActionState.hasAction(ActionIds.FALLDOWN)
		local isGettingUp = ActionState.hasAction(ActionIds.GET_UP)

		local char = GetLocalCharacter()
		local humanoid = char and char:FindFirstChild("Humanoid")
		if not isKnockedDown and not isGettingUp and humanoid then
			if humanoid:GetState() == Enum.HumanoidStateType.Physics then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end)

end

return Health
