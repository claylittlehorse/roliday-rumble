local import = require(game.ReplicatedStorage.Lib.Import)
local Cmdr = import "Cmdr"
local CommandsFolder = import "Server/CommandsFolder"
local CommandHooks = import "Server/CommandHooks"

local Commands = {}

function Commands.start()
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(CommandsFolder)
	Cmdr:RegisterHooksIn(CommandHooks)
end

return Commands
