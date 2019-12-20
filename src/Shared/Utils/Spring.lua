local e   = 2.718281828459045
local cos = math.cos
local sin = math.sin

local spring = {
	["Accelerate"] = function(self, velocity)
		self.Velocity = self.Velocity + velocity
	end;

	["Update"] = function(self, time_)
		local time  = time_ or tick()
		local start = self.Time
		self.Time   = time

		local s = self.Speed
		local d = self.Damping
		local v = self.Velocity
		local p = self.Position
		local t = self.Target

		if p == t and v*0 == v then return t end
		if d < 0 then d = 0 end

		local ip = p - t
		local dt = time - start

		local p1, v1 do
			if d > 1 then
				local za = -s*d
				local zb = s*(d*d-1)^.5
				local z1 = za - zb
				local z2 = za + zb
				local ex1 = e^(z1*dt)
				local ex2 = e^(z2*dt)

				local c1 = (v - ip*z2)/(-2*zb)
				local c2 = ip - c1

				p1 = t + c1*ex1 + c2*ex2
				v1 = c1*z1*ex1 + c2*z2*ex2
			elseif d == 1 then
				local ex = e^(-s*dt)
				local c1 = v + s*ip
				local c2 = ip
				local c3 = (c1*dt + c2)*ex

				p1 = t + c3
				v1 = (c1*ex) - (c3*s)
			elseif d < 1 then
				local zeta = s * d
				local alpha = s * (1 - d*d)^.5
				local ex = e^(-zeta * dt)
				local co = cos(alpha * dt)
				local si = sin(alpha * dt)

				local c1 = ip
				local c2 = (v + zeta*c1)/alpha

				p1 = t + ex*(c1*co + c2*si)
				v1 = -ex*((c1*zeta - c2*alpha)*co + (c1*alpha + c2*zeta)*si)
			end
		end

		self.Position = p1
		self.Velocity = v1
	end;

	["GetPosition"] = function(self, time)
		if (time or tick()) - self.Time > .001 then
			self:Update()
		end

		return self.Position
	end;

	["GetVelocity"] = function(self, time)
		if (time or tick()) - self.Time > .001 then
			self:Update()
		end

		return self.Velocity
	end;

	["SetPosition"] = function(self, position)
		self.Position = position
		self.Time     = tick()
	end;

	["SetVelocity"] = function(self, velocity)
		self.Velocity = velocity
		self.Time     = tick()
	end;

	["SetTarget"] = function(self, target)
		self.Target = target
		self.Time   = tick()
	end,

	["SetSpeed"] = function(self, speed)
		self.Speed = speed
	end,

	["SetDamping"] = function(self, damping)
		self.Damping = damping
	end
}

spring.__index = spring

return function(p, s, d)
	local this = {
		["Position"] = 0;
		["Velocity"] = 0;
		["Target"]   = 0;
		["Speed"]    = 5;
		["Damping"]  = .5;
		["Time"]     = nil;
	}

	local pos = p and p*0 or 0
	this.Position = pos
	this.Velocity = pos
	this.Target   = pos
	this.Speed    = s or 5
	this.Damping  = d or 0.5
	this.Time     = tick()

	return setmetatable(this, spring)
end;
