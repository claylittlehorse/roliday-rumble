local import = require(game.ReplicatedStorage.Lib.Import)

local SpawnsFolder = import "Workspace/SpawnsFolder"
local IsValidCharacter = import "GameUtils/IsValidCharacter"

local Spawns = {}
local spawnCFrames = {}

local function copyCFrames()
	local cframes = {}
	for _, cf in ipairs(spawnCFrames) do
		cframes[#cframes+1] = cf
	end
	return cframes
end

function Spawns.start()
	for _, spawnPart in pairs(SpawnsFolder:GetChildren()) do
		spawnCFrames[#spawnCFrames+1] = spawnPart.CFrame
		spawnPart:Destroy()
	end
end

function Spawns.spawnPlayers(players, onFinishedSpawning)
	local cframes = copyCFrames()

	local spawnedPlayers = {}

	for _, player in pairs(players) do
		if #cframes == 0 then
			break
		end

		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChild("Humanoid")
		local cfNum = math.random(#cframes)
		local cframe = cframes[cfNum]
		table.remove(cframes, cfNum)

		if rootPart and humanoid then
			rootPart.CFrame = cframe * CFrame.new(0, humanoid.HipHeight +rootPart.Size.Y / 2, 0)
			rootPart.Anchored = true
			spawnedPlayers[#spawnedPlayers + 1] = player
		end
	end

	spawn(function()
		wait(3)
		local fullySpawnedPlayers = {}
		for _, player in pairs(spawnedPlayers) do
			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChild("Humanoid")
			if rootPart and humanoid and IsValidCharacter(character) then
				rootPart.Anchored = false
				fullySpawnedPlayers[#fullySpawnedPlayers+1] = player
			end
		end

		onFinishedSpawning(fullySpawnedPlayers)
	end)
end

return Spawns
