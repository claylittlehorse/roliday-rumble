local import = require(game.ReplicatedStorage.Lib.Import)

local GetLocalCharacter = import "Utils/GetLocalCharacter"
local PlaySound = {}

function PlaySound.character(soundName, character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local sound = rootPart and rootPart:FindFirstChild(soundName)

	if sound then
		sound:Play()
	end
end

function PlaySound.localCharacter(soundName)
	local character = GetLocalCharacter()
	PlaySound.character(soundName, character)
end

return PlaySound
