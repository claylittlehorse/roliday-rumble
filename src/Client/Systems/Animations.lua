local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local StepOrder = import "Data/StepOrder"
local IsValidCharacter = import "GameUtils/IsValidCharacter"
local AnimationData = import "Data/AnimationData"

local Animations = {}
local _loadedCharacter = nil
local _loadedAnims = {}
local _animCallbacks = {}

local function loadAnimations(character)
	local humanoid = character:FindFirstChild("Humanoid")
	_loadedAnims = {}
	for animName, animInfo in pairs(AnimationData) do
		local loadAnim = humanoid:LoadAnimation(animInfo.anim)
		loadAnim:AdjustWeight(animInfo.weight)
		loadAnim:AdjustSpeed(animInfo.speed or 1)
		loadAnim.Priority = animInfo.priority
		loadAnim.Looped = animInfo.looped

		_loadedAnims[animName] = loadAnim
	end
end

function Animations.playAnimation(animName, animCallback)
	if _loadedCharacter and _loadedAnims[animName] then
		_loadedAnims[animName]:Play()
		if animCallback then
			_animCallbacks[animName] = {
				callback = animCallback,
				animation = _loadedAnims[animName]
			}
		end
	end
end

local function reconcileLoadedCharacter()
	if _loadedCharacter and not IsValidCharacter(_loadedCharacter) then
		_loadedCharacter = nil
		_loadedAnims = {}
	end

	local playerCharacter = localPlayer.character

	if playerCharacter ~= _loadedCharacter and IsValidCharacter(playerCharacter) then
		loadAnimations(playerCharacter)
		_loadedCharacter = playerCharacter
	end
end

local function callAnimCallbacks()
	for animName, callbackInfo in pairs(_animCallbacks) do
		local callback = callbackInfo.callback
		local anim = callbackInfo.animation

		local shldRemove = callback(anim)
		if shldRemove then
			_animCallbacks[animName] = nil
		end
	end
end

function Animations.start()
	RunService:BindToRenderStep("AnimationUpdate", StepOrder.ANIM, function()
		reconcileLoadedCharacter()
		callAnimCallbacks()
	end)
end

return Animations
