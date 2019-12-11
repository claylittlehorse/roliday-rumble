local Players = game:GetService("Players")

local function GetLocalCharacter()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.character
	return character
end

return GetLocalCharacter
