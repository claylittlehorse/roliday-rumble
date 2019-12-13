local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local REPLICATE_KNOCKBACK = import("Data/NetworkEvents/CombatEvents", {"REPLICATE_KNOCKBACK"})

local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

local Knockback = {}
local _clientKnockbackForces = {}

function Knockback.applyKnockback(knockback, player)
	if IS_SERVER then
		Network.fireClient(REPLICATE_KNOCKBACK, player, knockback)
	else
		Network.fireServer(REPLICATE_KNOCKBACK, knockback, player)
	end
end

function Knockback.getKnockbackVelocity()
	local knockbackVelocity = Vector3.new()
	for i = #_clientKnockbackForces, 1, -1 do
		local force = _clientKnockbackForces[i]
		if tick() - force.startTime < force.duration then
			local alpha = 1 - ((tick() - force.startTime) / force.duration)
			local speed = force.speed * alpha
			knockbackVelocity = knockbackVelocity + (force.direction * speed)
		else
			table.remove(_clientKnockbackForces, i)
		end
	end
	return knockbackVelocity
end

function Knockback.start()
	if IS_SERVER then
		Network.hookEvent(REPLICATE_KNOCKBACK, function(player, knockback, victim)
			--Update tick since the client tick will be wrong on server
			knockback.startTime = tick()
			Knockback.applyKnockback(knockback, victim)
		end)
	end

	if IS_CLIENT then
		Network.hookEvent(REPLICATE_KNOCKBACK, function(knockback)
			knockback.startTime = tick()
			_clientKnockbackForces[#_clientKnockbackForces+1] = knockback
		end)
	end
end

return Knockback
