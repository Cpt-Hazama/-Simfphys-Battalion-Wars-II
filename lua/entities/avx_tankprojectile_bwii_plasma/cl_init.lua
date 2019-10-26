include("shared.lua")

function ENT:Initialize()	
	self.PixVis = util.GetPixelVisibleHandle()
	self:SetNWInt("Effect",0)
	self.EffectType = self:GetNWInt("Effect")
	
	self.Materials = {
		"particle/smokesprites_0001",
		"particle/smokesprites_0002",
		"particle/smokesprites_0003",
		"particle/smokesprites_0004",
		"particle/smokesprites_0005",
		"particle/smokesprites_0006",
		"particle/smokesprites_0007",
		"particle/smokesprites_0008",
		"particle/smokesprites_0009",
		"particle/smokesprites_0010",
		"particle/smokesprites_0011",
		"particle/smokesprites_0012",
		"particle/smokesprites_0013",
		"particle/smokesprites_0014",
		"particle/smokesprites_0015",
		"particle/smokesprites_0016"
	}
	
	self.OldPos = self:GetPos()
	
	self.emitter = ParticleEmitter(self.OldPos, false )
end

local mat = Material("sprites/light_glow02_add")
function ENT:Draw()
end

function ENT:Think()
	self.EffectType = self:GetNWInt("Effect")
	local curtime = CurTime()
	local pos = self:GetPos()
	
	if pos ~= self.OldPos then
		self:doFX( pos, self.OldPos )
		self.OldPos = pos
	end
	
	return true
end

function ENT:doFX( newpos, oldpos )
	if not self.emitter then return end
	
	local Sub = (newpos - oldpos)
	local Dir = Sub:GetNormalized()
	local Len = Sub:Length()
	for i = 1, Len, 25 do
		local pos = oldpos + Dir * i
	
		local particle = self.emitter:Add( self.Materials[math.random(1, table.Count(self.Materials) )], pos )
		
		if particle then
			particle:SetGravity(Vector(0,0,100) +VectorRand() *50) // Smoke
			particle:SetVelocity(-self:GetForward() *500)
			particle:SetAirResistance(600) 
			particle:SetDieTime(math.Rand(0.1,0.5))
			particle:SetStartAlpha(10)
			particle:SetStartSize((math.Rand(6,12) / 20) *self:GetSize() *3.25)
			particle:SetEndSize((math.Rand(20,30) / 20) *self:GetSize() *3.25)
			particle:SetRoll(math.Rand(-1,1))
			-- particle:SetColor(130,130,130)
			particle:SetColor(0,161,255)
			particle:SetCollide(false)
		end

		for i = 1, 10 do
			local particle = self.emitter:Add( Material("effects/ar2_altfire2"), pos ) // Glow
			if particle then
				particle:SetVelocity( -self:GetForward() *300 +self:GetUp() *math.Rand(-800,800) +self:GetRight() *math.Rand(-800,800) +self:GetVelocity())
				particle:SetDieTime( 0.1 )
				particle:SetAirResistance( 0 ) 
				particle:SetStartAlpha( 255 )
				particle:SetStartSize( self:GetSize() *2.5 )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(-1,1) )
				particle:SetColor(0,161,255)
				particle:SetGravity( Vector( 0, 0, 0 ) )
				particle:SetCollide( false )
			end
		end

		-- local particle = self.emitter:Add( Material("effects/strider_muzzle"), pos ) // Glow
		-- if particle then
			-- particle:SetVelocity( -self:GetForward() *300 +self:GetUp() *math.Rand(-500,500) +self:GetRight() *math.Rand(-500,500) +self:GetVelocity())
			-- particle:SetDieTime( 0.1 )
			-- particle:SetAirResistance( 0 ) 
			-- particle:SetStartAlpha( 255 )
			-- particle:SetStartSize( self:GetSize() *1.4 )
			-- particle:SetEndSize( 0 )
			-- particle:SetRoll( math.Rand(-1,1) )
			-- particle:SetColor(0,161,255)
			-- particle:SetGravity( Vector( 0, 0, 0 ) )
			-- particle:SetCollide( false )
		-- end
	
		local particle = self.emitter:Add(Material("effects/strider_muzzle"), pos ) // Glow
		if particle then
			particle:SetVelocity( -self:GetForward() * 300 + self:GetVelocity())
			particle:SetDieTime( 0.1 )
			particle:SetAirResistance( 0 ) 
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( self:GetSize() *3.25 )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor(0,161,255)
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetCollide( false )
		end
	end
end

function ENT:OnRemove()
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
	util.Effect( self:GetBlastEffect(), effectdata )
	
	if self.emitter then
		self.emitter:Finish()
	end
end

function ENT:Explosion( pos )
	if not self.emitter then return end
	
	for i = 0,60 do
		local particle = self.emitter:Add( self.Materials[math.random(1,table.Count( self.Materials ))], pos )
		
		if particle then
			particle:SetVelocity(  VectorRand() * 600 )
			particle:SetDieTime( math.Rand(4,6) )
			particle:SetAirResistance( math.Rand(200,600) ) 
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( math.Rand(10,30) )
			particle:SetEndSize( math.Rand(80,120) )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor( 130,130,130 )
			particle:SetGravity( Vector( 0, 0, 100 ) )
			particle:SetCollide( false )
		end
	end
	
	for i = 0,60 do
		local particle = self.emitter:Add("sprites/glow06", pos )
		
		if particle then
			particle:SetVelocity(  VectorRand() * 600 )
			particle:SetDieTime(10)
			particle:SetAirResistance( math.Rand(200,600) ) 
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( math.Rand(10,30) )
			particle:SetEndSize( math.Rand(80,120) )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor( 50,50,50 )
			particle:SetGravity( Vector( 0, 0, 100 ) )
			particle:SetCollide( false )
		end
	end
	
	for i = 0, 40 do
		local particle = self.emitter:Add( "sprites/flamelet"..math.random(1,5), pos )
		
		if particle then
			particle:SetVelocity( VectorRand() * 500 )
			particle:SetDieTime( 0.14 )
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( 10 )
			particle:SetEndSize( math.Rand(30,60) )
			particle:SetEndAlpha( 100 )
			particle:SetRoll( math.Rand( -1, 1 ) )
			particle:SetColor(255,191,0)
			particle:SetCollide( false )
		end
	end
	
	local dlight = DynamicLight( math.random(0,9999) )
	if dlight then
		dlight.pos = pos
		dlight.r = 255
		dlight.g = 191
		dlight.b = 40
		dlight.brightness = 8
		dlight.Decay = 2000
		dlight.Size = 200
		dlight.DieTime = CurTime() + 0.1
	end
end