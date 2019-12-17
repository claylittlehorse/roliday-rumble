local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local StepOrder = import "Data/StepOrder"
local IsValidCharacter = import "GameUtils/IsValidCharacter"
local Health = import "Client/Systems/Health"
local ActionState = import "Client/Systems/ActionState"
local ActionIds = import "Data/ActionIds"

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local Carrying = {}
local _setupCharacter = nil
local pickupRequestTimes = {}
local touchDebounceTimes = {}
local touchConnections = {}

local requestDebounceTime = 2
local touchDebounceTime = 0.25

local function onCharacterTouch(part)
	local character = part.Parent
	if not character:IsA("Model") or not character:FindFirstChild("Humanoid") then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local userId = tostring(player)
	if touchDebounceTimes[userId] and tick() - touchDebounceTimes[userId] < touchDebounceTime then
		return
	end
	touchDebounceTimes[userId] = tick()

	if pickupRequestTimes[userId] and tick() - pickupRequestTimes[userId] < requestDebounceTime then
		return
	end

	local hasAnyAction = ActionState.hasActionInMap({
		[ActionIds.PUNCH] = true,
		[ActionIds.END_PUNCH] = true,
		[ActionIds.STAGGER] = true,
		[ActionIds.FALLDOWN] = true,
	})

	if hasAnyAction or (not Health.isActive()) then
		return
	end

	pickupRequestTimes[userId] = tick()
	Network.FireServer(CombatEvents.REQUEST_CARRY, player)
end

local function setupCarrying(character)
	local leftFoot = character:FindFirstChild("LeftFoot")
	local rightFoot = character:FindFirstChild("RightFoot")

	touchConnections[#touchConnections+1] = leftFoot.Touched:Connect(onCharacterTouch)
	touchConnections[#touchConnections+1] = rightFoot.Touched:Connect(onCharacterTouch)
end

local function reconcileSetupCharacter()
	if _setupCharacter and not (IsValidCharacter(_setupCharacter) and Health.isActive()) then
		_setupCharacter = nil
		pickupRequestTimes = {}
		touchDebounceTimes = {}
		for _, connection in ipairs(touchConnections) do
			connection:Disconnect()
		end
	end

	local playerCharacter = localPlayer.character
	if playerCharacter ~= _setupCharacter and IsValidCharacter(playerCharacter) and Health.isActive() then
		setupCarrying(playerCharacter)
	end
end

function Carrying.start()
	RunService:BindToRenderStep("AnimationUpdate", StepOrder.ANIM, function()
		reconcileSetupCharacter()
		-- doMovement()
	end)
end

return Carrying
