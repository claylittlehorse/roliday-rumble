local function SetCharacterOwnership(carriedState, newOwnerPlayer)
	local descendants = carriedState.characterModel:GetDescendants()
	for _, descendant in pairs(descendants) do
		if descendant:IsA("BasePart") then
			descendant:SetNetworkOwner(newOwnerPlayer)
		end
	end

	carriedState.carrying.networkOwner = newOwnerPlayer
end

return SetCharacterOwnership
