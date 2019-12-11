local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function GetLocalCharacter()
	local character = localPlayer.character
	return character
end

return GetLocalCharacter
