local import = require(game.ReplicatedStorage.Lib.Import)
local GameLoop = import "Server/Systems/GameLoop"

return function()
	return GameLoop.restartGame()
end
