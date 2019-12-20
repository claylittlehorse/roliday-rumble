local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local StepOrder = import "Data/StepOrder"
local IsValidCharacter = import "GameUtils/IsValidCharacter"
local ActionState = import "Client/Systems/ActionState"
local Knockback = import "Client/Systems/Knockback"

local Hitstop = import "GameUtils/Hitstop"

local Movement = {}
local _setupCharacter = nil
local _bodyVel = nil

local SPEED = 16

local function setupMovement(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	_bodyVel = Instance.new("BodyVelocity", rootPart)
	_bodyVel.MaxForce = Vector3.new(0, 0, 0)
	_setupCharacter = character
end

local function reconcileSetupCharacter()
	if _setupCharacter and not IsValidCharacter(_setupCharacter) then
		_setupCharacter = nil
		_bodyVel = nil
	end

	local playerCharacter = localPlayer.character

	if playerCharacter ~= _setupCharacter and IsValidCharacter(playerCharacter) then
		setupMovement(playerCharacter)
	end
end

local function getSpeed()
	local movementAction = ActionState.getMovementAction()
	if movementAction and movementAction.changeSpeed then
		return movementAction.changeSpeed(SPEED)
	end

	return SPEED
end

local function getVelocity()
	local rootPart = _setupCharacter:FindFirstChild("HumanoidRootPart")
	local knockbackVel = Knockback.getKnockbackVelocity()

	local movementAction = ActionState.getMovementAction()
	if movementAction and movementAction.addVelocity then
		local velocity = movementAction.addVelocity()
		local velocityRelativeToRoot = ((rootPart.CFrame - rootPart.CFrame.p) * CFrame.new(velocity)).p
		return velocityRelativeToRoot + knockbackVel
	end

	return knockbackVel
end

local function doMovement()
	if not (_setupCharacter and _bodyVel) then
		return
	end

	local humanoid = _setupCharacter:FindFirstChild("Humanoid")
	if not humanoid then
		_setupCharacter = nil
		_bodyVel = nil
		return
	end

	local speed = getSpeed()
	local moveDirection = humanoid.MoveDirection

	local moveVel = getVelocity()
	if Hitstop.isStopped() then
		_bodyVel.MaxForce = Vector3.new(400000, 400000, 400000)
		_bodyVel.Velocity = Vector3.new(0, 0, 0)
	elseif moveVel.magnitude > 0.5 then
		_bodyVel.MaxForce = Vector3.new(400000, 0, 400000)
		_bodyVel.Velocity = moveVel + (moveDirection * speed)
		return
	else
		_bodyVel.MaxForce = Vector3.new()
		_bodyVel.Velocity = Vector3.new()
	end

	humanoid.WalkSpeed = speed
end


function Movement.start()
	RunService:BindToRenderStep("AnimationUpdate", StepOrder.ANIM, function()
		reconcileSetupCharacter()
		doMovement()
	end)
end

return Movement
