local import = require(game.ReplicatedStorage.Lib.Import)
import.setConfig{
	aliasesMap = require(game.ReplicatedStorage.ImportPaths),
	reloadDirectories = require(game.ReplicatedStorage.ReloadDirectories)
}

local loadOrder = {
	"../Systems/Commands",
	-- "../Systems/TestRunner",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system.start()
end
