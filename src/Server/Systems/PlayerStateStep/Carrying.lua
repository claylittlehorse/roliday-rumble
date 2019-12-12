local import = require(game.ReplicatedStorage.Lib.Import)

local Carrying = {}

function setModelOwner(model, owner)
	local descendants = model:GetDescendants()
	for _, descendant in pairs(descendants) do
		if descendant:IsA("BasePart") then
			descendant:SetNetworkOwner(owner)
		end
	end
end

local function setCarriedObject(player, carriedObject)

end

function Carrying.start()

end

return Carrying
