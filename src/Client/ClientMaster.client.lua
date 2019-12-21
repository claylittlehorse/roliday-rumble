local import = require(game.ReplicatedStorage.Lib.Import)
import.setConfig{
	aliasesMap = require(game.ReplicatedStorage.ImportPaths),
	reloadDirectories = require(game.ReplicatedStorage.ReloadDirectories),
}

import.setChangeListenersActive(true)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Wait for local player to actually exist
local localPlayer = Players.LocalPlayer
if RunService:IsStudio() then
	while localPlayer.UserId == 0 do
		localPlayer.Changed:Wait()
	end
end

local loadOrder = {
	"Client/Systems/ClientCommands",
	"Client/Systems/UI",

	"Client/Systems/ActionQueue",
	"Client/Systems/ActionState",
	"Client/Systems/DamageSolver",
	"Client/Systems/Animations",
	"Client/Systems/Knockback",
	"Client/Systems/Movement",
	"Client/Systems/Health",
	"Client/Systems/ClientCarrying",
	"Client/Systems/Camera",
	"Client/Systems/EnemyShake",
	"Shared/Systems/CollisionGroups"
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system.start()
end

import.setConfig{
	autoReload = true,
}
