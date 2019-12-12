local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local Network = import "Network"
local PLAY_SOUND = import "Data/NetworkEvents/PLAY_SOUND"

local IS_CLIENT = RunService:IsClient()
local IS_SERVER = RunService:IsServer()

local Sound = {}

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Sounds = import "Assets/Sounds"

local GetLocalCharacter = import "Utils/GetLocalCharacter"

function Sound.playSound(soundName, pos, time, dontReplicate)
	local sound = Sounds:FindFirstChild(soundName)
	assert(sound, "Could not find sound of name", soundName)

	local attachment = Instance.new("Attachment")
	attachment.Position = pos
	attachment.Parent =  Workspace.Terrain
	local copySound = sound:Clone()
	copySound.Parent = attachment
	copySound:Play()
	Debris:AddItem(attachment, time)

	if dontReplicate then
		return
	end

	if IS_SERVER then
		Network.fireAllCleints(PLAY_SOUND, soundName, pos, time)
	elseif IS_CLIENT then
		Network.fireServer(PLAY_SOUND, soundName, pos, time)
	end
end

function Sound.playAtCharacter(soundName, time)
	local character = GetLocalCharacter()
	local isInWorkspace = character:IsDescendantOf(Workspace)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not (isInWorkspace and rootPart) then
		return
	end

	Sound.playSound(soundName, rootPart.Position, time)
end

function Sound.start()
	if IS_CLIENT then
		Network.hooKEvent(PLAY_SOUND, function(soundName, pos, time)
			Sound.playSound(soundName, pos, time, true)
		end)
	end

	if IS_SERVER then
		Network.hooKEvent(PLAY_SOUND, function(player, soundName, pos, time)
			Network.fireOtherClients(PLAY_SOUND, player, soundName, pos, time)
		end)
	end
end

return Sound
