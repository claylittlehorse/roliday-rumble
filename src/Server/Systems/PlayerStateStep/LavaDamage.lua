local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"
local LavaSystem = import "Server/Systems/LavaSystem"
local PlaySound = import "GameUtils/PlaySound"

local LavaDamage = {}
local damageInterval = 0.5
local damageAmount = 2

function LavaDamage.step(playerStates)
	for _, playerState in pairs(playerStates) do
		local wasInLava = playerState.lava.isInLava
		local isInLava = LavaSystem.isInLava(playerState)

		playerState.lava.isInLava = isInLava

		local canBeDamaged = tick() - playerState.lava.lastLavaDamage >= damageInterval

		local character = playerState.characterModel
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		local isInLavaChanged = wasInLava ~= isInLava
		if isInLavaChanged then
			if isInLava then
				PlaySound.character("Light", character)
			end

			local fire = rootPart and rootPart:FindFirstChild("FireParticle")
			if fire then
				fire.Enabled = isInLava
			end
		end

		if isInLava and canBeDamaged then
			local newHealth = math.max(playerState.health.currentHealth - damageAmount, 0)
			playerState.health.currentHealth = newHealth
			playerState.health.lastDamagedTime = tick()
			playerState.lava.lastLavaDamage = tick()
			Network.fireClient(CombatEvents.REPLICATE_HEALTH, playerState.player, newHealth)
			if humanoid and newHealth <= 0 then
				humanoid.Health = 0
				PlaySound.character("Died", character)
				PlaySound.character("Knockout", character)
			else
				PlaySound.character("Hurt", character)
				PlaySound.character("Fizz"..tostring(math.random(3)), character)
			end
		end
	end
end

return LavaDamage
