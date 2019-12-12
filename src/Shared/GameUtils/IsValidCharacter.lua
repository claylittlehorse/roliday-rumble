local Workspace = game:GetService("Workspace")

local function IsValidCharacter(character)
	local isInWorkspace = character:IsDescendantOf(Workspace)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not (isInWorkspace and humanoid and rootPart) then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	return true
end

return IsValidCharacter
