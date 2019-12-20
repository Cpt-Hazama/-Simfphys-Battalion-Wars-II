function EFFECT:Init(data)
	local pos = data:GetStart()
	local posStart = self:GetTracerShootPos(pos,data:GetEntity(),data:GetAttachment())
	local ang = data:GetNormal()
	
	local emitter = ParticleEmitter(posStart)
	local particle = emitter:Add("particle/particle_spray",posStart)
	particle:SetVelocity(ang *500)
	particle:SetDieTime(0.7)
	particle:SetStartAlpha(250)
	particle:SetEndAlpha(50)
	particle:SetStartSize(math.random(2,6))
	particle:SetEndSize(math.random(100,110))
	particle:SetRoll(math.random(0,360))
	particle:SetRollDelta(math.random(-1,1))
	particle:SetColor(0,255,0)
	particle:SetCollide(true)
	particle:SetCollideCallback(function(part,pos,ang) part:SetDieTime(0) end)

	local particle = emitter:Add("sprites/heatwave",posStart)
	particle:SetVelocity(ang *500)
	particle:SetDieTime(0.7)
	particle:SetStartAlpha(250)
	particle:SetEndAlpha(200)
	particle:SetStartSize(math.random(4,6))
	particle:SetEndSize(math.random(120,130))
	particle:SetRoll(math.random(0,360))
	particle:SetRollDelta(math.random(-1,1))
	particle:SetColor(255,255,255)
	particle:SetCollide(true)
	particle:SetCollideCallback(function(part,pos,ang) part:SetDieTime(0) end)
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end