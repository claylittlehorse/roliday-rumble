local import = require(game.ReplicatedStorage.Lib.Import)

local DamageSolver = import "Client/Systems/DamageSolver"
local CarryRequester = import "Shared/Damages/CarryRequester"

local ClientCarrying = {}

function ClientCarrying.start()
	DamageSolver.addDamage(CarryRequester.new())
end

return ClientCarrying
