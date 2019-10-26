AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include('shared.lua')

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local size = math.random( 16, 48 )

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * size )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:Initialize()	
	self:SetModel( "models/weapons/w_missile_launch.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_NONE )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	local pObj = self:GetPhysicsObject()
	
	if IsValid( pObj ) then
		pObj:EnableMotion( false )  
	end
	
	self.SpawnTime = CurTime()
	self.Vel = self:GetForward() * (self.MuzzleVelocity or 200)
end

function ENT:Think()	
	local curtime = CurTime()
	self:NextThink( curtime )
	
	local Size = self:GetSize() * 0.5
	local FixTick = FrameTime() * 66.666
	
	local trace = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos() + self.Vel * FixTick,
		maxs = Size,
		mins = -Size,
		filter = self.Filter
	} )
	
	if trace.Hit then
		self:SetPos( trace.HitPos )
		
		local shootDirection = self:GetForward()
		
		local bullet = {}
			bullet.Num 			= 1
			bullet.Src 			= self:GetPos() - shootDirection * 10
			bullet.Dir 			= shootDirection
			bullet.Spread 		= Vector(0,0,0)
			bullet.Tracer		= 0
			bullet.TracerName	= "simfphys_tracer"
			bullet.Force		= self.Force
			bullet.Damage		= self.Damage
			bullet.HullSize		= self:GetSize()
			bullet.Attacker 	= self.Attacker
			bullet.Callback = function(att, tr, dmginfo)
				dmginfo:SetDamageType(DMG_AIRBOAT)
				local attackingEnt = IsValid( self.AttackingEnt ) and self.AttackingEnt or self
				util.BlastDamage( attackingEnt, self.Attacker, tr.HitPos,self.BlastRadius,self.BlastDamage)
				
				util.Decal("scorch", tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal)
				
				if tr.Entity ~= Entity(0) then
					if simfphys.IsCar( tr.Entity ) then
						local effectdata = EffectData()
							effectdata:SetOrigin( tr.HitPos + shootDirection * tr.Entity:BoundingRadius() )
							effectdata:SetNormal( shootDirection * 10 )
						util.Effect( "manhacksparks", effectdata, true, true )
					
						sound.Play( Sound( "doors/vent_open"..math.random(1,3)..".wav" ), tr.HitPos, 140)
					end
				end
			end
			
		self:FireBullets( bullet )
		
		
		self:Remove()
	else
		self:SetPos( self:GetPos() + self.Vel * FixTick )
		
		self.Vel = self.Vel - Vector(0,0,0.15) * FixTick
	end	
	return true
end

function ENT:PhysicsCollide( data )
end

function ENT:OnTakeDamage( dmginfo )
	return
end

function ENT:Use( activator, caller )
end