local Workspace = game:GetService("Workspace")

local function SetCharacterOwnership(carriedState, newOwnerPlayer)
	if not carriedState.characterModel:IsDescendantOf(Workspace) then
		return
	end

	local descendants = carriedState.characterModel:GetDescendants()
	for _, descendant in pairs(descendants) do
		if descendant:IsA("BasePart") then
			descendant:SetNetworkOwner(newOwnerPlayer)
		end
	end

	carriedState.carrying.networkOwner = newOwnerPlayer
end

return SetCharacterOwnership
