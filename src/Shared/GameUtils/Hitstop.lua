local Hitstop = {}
local lastHitTime = 0

local stoppedTime = 0
local currentStopLength = 0
local freezeTick = 0

function Hitstop.tick()
	if Hitstop.isStopped() then
		return freezeTick
	else
		return tick() - stoppedTime
	end
end

function Hitstop.isStopped()
	return tick() - lastHitTime <= currentStopLength
end

function Hitstop.stop(length)
	if not Hitstop.isStopped() then
		freezeTick = tick() - stoppedTime

		stoppedTime = stoppedTime + length
		currentStopLength = length
		lastHitTime = tick()
	end
end

return Hitstop
