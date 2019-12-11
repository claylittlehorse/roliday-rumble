local import = require(game.ReplicatedStorage.Lib.Import)

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Sounds = import "Assets/Sounds"

local GetLocalCharacter = import "Utils/GetLocalCharacter"

local function PlaySound(soundName, time)
	local sound = Sounds:FindFirstChild(soundName)
	assert(sound, "Could not find sound of name", soundName)

	local character = GetLocalCharacter()
	local isInWorkspace = character:IsDescendantOf(Workspace)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not (isInWorkspace and rootPart) then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Position = rootPart.Position
	attachment.Parent =  Workspace.Terrain
	local copySound = sound:Clone()
	copySound.Parent = attachment
	copySound:Play()
	Debris:AddItem(attachment, time)
end

return PlaySound
