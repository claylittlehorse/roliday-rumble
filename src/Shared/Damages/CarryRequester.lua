local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")

local GetLocalCharacter = import "Utils/GetLocalCharacter"
local ColliderFromCharacter = import "GameUtils/ColliderFromCharacter"

local Network = import "Network"
local CombatEvents = import "Data/NetworkEvents/CombatEvents"

local ActionState = import "Client/Systems/ActionState"
local ActionIds = import "Data/ActionIds"

local CarryRequester = {}
CarryRequester.__index = CarryRequester

local PICKUP_DEBOUNCE = 0.25

function CarryRequester.new(thrownCharacter)
    local self = {
		lastDbCleanup = tick(),
		pickupDbs = {},
	}
    return setmetatable(self, CarryRequester)
end

function CarryRequester:getCollider()
	local character = GetLocalCharacter()
	local hitbox = ColliderFromCharacter.characterCollider(character)
	return hitbox
end

function CarryRequester:shouldCleanup()
	-- Every 30 seconds, set old debounces to nil for GC. Prevents slight
	-- memory leak
	if tick() - self.lastDbCleanup > 30 then
		for userId, dbTime in pairs(self.pickupDbs) do
			if tick() - dbTime >= PICKUP_DEBOUNCE then
				self.pickupDbs[userId] = nil
			end
		end
		self.lastDbCleanup = tick()
	end

	return false
end

function CarryRequester:onThingDamaged(thing)
	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local userId = tostring(thing.userId)
		self.pickupDbs[userId] = tick()
		Network.fireServer(CombatEvents.REQUEST_CARRY, thing)
	end
end

function CarryRequester:canDamageThing(thing)
	if ActionState.hasAction(ActionIds.FALLDOWN) or ActionState.hasAction(ActionIds.KNOCKOUT) then
		return false
	end

	if thing == Players.localPlayer then
		return false
	end

	if typeof(thing) == "Instance" and thing:IsA("Player") then
		local userId = tostring(thing.userId)
		local pickupDb = self.pickupDbs[userId]
		if not pickupDb or tick() - pickupDb >= PICKUP_DEBOUNCE then
			self.pickupDbs[userId] = nil
			return true
		end

		return false
	end

	return false
end

return CarryRequester
