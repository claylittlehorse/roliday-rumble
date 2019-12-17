local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")

local Network = import "Network"
local REPLICATE_KNOCKBACK = import("Data/NetworkEvents/CombatEvents", {"REPLICATE_KNOCKBACK"})

local ActionQueue = import "Client/Systems/ActionQueue"
local ActionIds = import "Data/ActionIds"

local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

local Knockback = {}
local _clientKnockbackForces = {}

function Knockback.applyKnockback(knockback, player, shouldKnockdown)
	if IS_SERVER then
		Network.fireClient(REPLICATE_KNOCKBACK, player, knockback, shouldKnockdown)
	else
		Network.fireServer(REPLICATE_KNOCKBACK, knockback, player, shouldKnockdown)
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
	Network.hookEvent(REPLICATE_KNOCKBACK, function(knockback)
		if knockback.shouldKnockOut then
			ActionQueue.queueAction(ActionIds.KNOCKOUT, {
				velocity = knockback.speed * knockback.direction
			})
			return
		elseif knockback.shouldKnockDown then
			ActionQueue.queueAction(ActionIds.FALLDOWN, {
				velocity = knockback.speed * knockback.direction
			})
			return
		end

		knockback.startTime = tick()
		_clientKnockbackForces[#_clientKnockbackForces+1] = knockback
	end)
end

return Knockback
