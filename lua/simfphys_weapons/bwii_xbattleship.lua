	-- Variables --
local class = "bwii_xbattleship"
local icon = "entities/bwii_xbattleship.png"
local name = "Battleship"
local TEAM = TEAM_XYLVANIA
local driverFPPos = Vector(0,-20,0)
local driverTPPos = Vector(0,100,120)
local driverFollowerAttachment = true
local crosshairDirection = Vector(0,90,0)
local lCannonFPPos = Vector(0,0,0)
local lCannonFPPos = Vector(0,0,0)
local rCannonFPPos = Vector(0,0,0)
local rCannonFPPos = Vector(0,0,0)

local groundCheckDistance = 350
local centerVector = Vector(0,0,100)

local fireSound = "cpthazama/bwii/westernfrontier/VW_Art_Fire.wav"
local fireSoundVolume = 150
local fireSoundPitch = 100

local reloadSoundTime = 5
local reloadSound = "cpthazama/bwii/V_Eject_Heavy.wav"
local reloadSoundVolume = 105
local reloadSoundPitch = 100
local reloadTime = BWII_RL_BATTLESHIP

local secondSound = "cpthazama/bwii/xylvania/lighttank_fire.wav"
local secondSoundVolume = 150
local secondSoundPitch = 100

local ppTurretYaw = "turret_yaw"
local ppTurretPitch = "turret_pitch"
local chasisTurnSpeed = 40
local ppTurretYawAddition = 0
local ppTurretPitchAddition = -5
local reverseChasisYaw = false
local reverseChasisPitch = true

local muzzleEffect = "xltank_muzzle"
local mainForceOnVehicle = 100000
local mainDMG = BWII_DMG_BATTLESHIP
local mainForce = 2500
local mainEffectSize = 35
local mainRadius = 950
local mainRadiusDMG = BWII_DMG_BATTLESHIP /20
local mainWeight = 70

local cannonForceOnVehicle = 2500
local cannonDMG = 500
local cannonForce = 2500
local cannonEffectSize = 7
local cannonRadius = 200
local cannonRadiusDMG = 25

function simfphys.weapon:Initialize( vehicle )
	-- net.Start( "avx_misc_register_tank_custom" )
		-- net.WriteEntity( vehicle )
		-- net.WriteString( class )
	-- net.Broadcast()

	local tr = util.TraceLine({
		start = vehicle:GetPos() +vehicle:GetUp() *25000,
		endpos = vehicle:GetPos(),
		filter = vehicle,
		mask = MASK_WATER
	})
	vehicle:SetPos(tr.HitPos +Vector(0,0,-80))
	if IsValid(vehicle:GetPhysicsObject()) then vehicle:GetPhysicsObject():SetBuoyancyRatio(0.02) end
	
	vehicle:SetNWInt("bwii_icon",icon)
	vehicle:SetNWInt("bwii_name",name); vehicle:SetNWFloat("SpecialCam_LoaderTime",reloadTime)
	
	
	vehicle:SetNWBool("bwii_AI",false)
	
	vehicle.OriginEntity = ents.Create("prop_dynamic")
	vehicle.OriginEntity:SetModel("models/error.mdl")
	vehicle.OriginEntity:SetPos(vehicle:GetPos())
	vehicle.OriginEntity:SetAngles(vehicle:GetAngles())
	vehicle.OriginEntity:Spawn()
	vehicle.OriginEntity:SetNoDraw(true)
	vehicle.OriginEntity:DrawShadow(false)
	-- vehicle.OriginEntity:SetParent(vehicle)
	vehicle:DeleteOnRemove(vehicle.OriginEntity)
	
	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), { Attachment = "muzzle", Direction = crosshairDirection, Type = 4 } )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), driverFPPos, driverTPPos, true, nil )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	simfphys.RegisterCrosshair( vehicle.pSeat[1] , { Attachment = "lCannon", Type = 3 } )
	simfphys.RegisterCamera( vehicle.pSeat[1], lCannonFPPos, lCannonTPPos, true, "lCannon" )

	simfphys.RegisterCrosshair( vehicle.pSeat[2] , { Attachment = "rCannon", Type = 3 } )
	simfphys.RegisterCamera( vehicle.pSeat[2], rCannonFPPos, rCannonTPPos, true, "rCannon" )

	simfphys.RegisterCrosshair( vehicle.pSeat[3] , { Attachment = "lTurret", Type = 1 } )
	simfphys.RegisterCamera( vehicle.pSeat[3], Vector(0,0,0), Vector(0,0,15), true, "lTurret" )

	simfphys.RegisterCrosshair( vehicle.pSeat[4] , { Attachment = "rTurret", Type = 1 } )
	simfphys.RegisterCamera( vehicle.pSeat[4], Vector(0,0,0), Vector(0,0,15), true, "rTurret" )

	simfphys.RegisterCrosshair( vehicle.pSeat[5] , { Attachment = "antiair", Type = 3 } )
	simfphys.RegisterCamera( vehicle.pSeat[5], Vector(0,0,0), Vector(0,0,15), true, "antiair" )
end

function simfphys.weapon:ControlTurret( vehicle, deltapos )
	local pod = vehicle:GetDriverSeat()
	
	if not IsValid( pod ) then return end
	
	local ply = pod:GetDriver()
	
	if not IsValid( ply ) then return end
	
	local ID = vehicle:LookupAttachment( "muzzle1" )
	local Attachment = vehicle:GetAttachment( ID )
	
	local ID2 = vehicle:LookupAttachment( "muzzle2" )
	local Attachment2 = vehicle:GetAttachment( ID2 )
	
	self:AimCannon( ply, vehicle, pod, Attachment )
	
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	local shootOrigin2 = Attachment2.Pos + deltapos * engine.TickInterval()
	
	local fire = ply:KeyDown( IN_ATTACK )

	if fire then
		self:PrimaryAttack( vehicle, ply, shootOrigin, Attachment, shootOrigin2, Attachment2, deltapos )
	end
end

local function primary_fire(ply,vehicle,shootOrigin,shootDirection,shootOrigin2,shootDirection2)
	vehicle:EmitSound(fireSound, fireSoundVolume, fireSoundPitch)
	if !shootOrigin2 then
		timer.Simple(reloadTime -1,function()
			if IsValid(vehicle) then
				vehicle:EmitSound(reloadSound, reloadSoundVolume, reloadSoundPitch)
			end
		end)
	end

	local effectdata = EffectData()
	effectdata:SetEntity( vehicle )
	util.Effect( muzzleEffect, effectdata, true, true )

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * mainForceOnVehicle, shootOrigin )
	if shootOrigin2 then vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection2 * mainForceOnVehicle, shootOrigin2 ) end
	
	if !shootOrigin2 then
		local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = shootDirection
		projectile.attacker = ply
		projectile.attackingent = vehicle
		projectile.Damage = mainDMG
		projectile.Force = mainForce
		projectile.Size = mainEffectSize
		projectile.BlastRadius = mainRadius
		projectile.BlastDamage = mainRadiusDMG
		projectile.BlastEffect = "simfphys_tankweapon_explosion"
		projectile.MuzzleVelocity = mainWeight
		
		AVX.FirePhysProjectile_Return(projectile)
	else
		local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin2
		projectile.shootDirection = shootDirection2
		projectile.attacker = ply
		projectile.attackingent = vehicle
		projectile.Damage = mainDMG
		projectile.Force = mainForce
		projectile.Size = mainEffectSize
		projectile.BlastRadius = mainRadius
		projectile.BlastDamage = mainRadiusDMG
		projectile.BlastEffect = "simfphys_tankweapon_explosion"
		projectile.MuzzleVelocity = mainWeight
		
		AVX.FirePhysProjectile_Return(projectile)
	end
end

function simfphys.weapon:FireLeftCannon( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
	
	local lCannon = vehicle.pSeat[1]
	if IsValid( lCannon ) then
		local ply = lCannon:GetDriver()
		
		if not IsValid( ply ) then return end
		
		self:ControlLeftCannon( ply, vehicle, lCannon )
		
		local ID = vehicle:LookupAttachment("lCannon")
		local Attachment = vehicle:GetAttachment( ID )

		local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

		local fire = ply:KeyDown( IN_ATTACK )

		if fire then
			self:SecondaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
		end
	end
end

function simfphys.weapon:FireRightCannon( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
	
	local rCannon = vehicle.pSeat[2]
	if IsValid( rCannon ) then
		local ply = rCannon:GetDriver()
		
		if not IsValid( ply ) then return end
		
		self:ControlRightCannon( ply, vehicle, rCannon )
		
		local ID = vehicle:LookupAttachment("rCannon")
		local Attachment = vehicle:GetAttachment( ID )

		local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

		local fire = ply:KeyDown( IN_ATTACK )

		if fire then
			self:SecondaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
		end
	end
end

function simfphys.weapon:ControlTurrets( ply, vehicle, pod )
	if not IsValid( pod ) then return end
	local lTurret = vehicle.pSeat[3]
	local rTurret = vehicle.pSeat[4]
	local cTurret = vehicle.pSeat[5]
	if IsValid(lTurret) && IsValid(lTurret:GetDriver()) then
		local EyeAngles = lTurret:WorldToLocalAngles( ply:EyeAngles() )
		EyeAngles:RotateAroundAxis(EyeAngles:Up(),270)
		local Yaw = EyeAngles.y
		local Pitch = math.Clamp(EyeAngles.p,-90,90)

		vehicle:SetPoseParameter("lMG_yaw", math.Clamp(Yaw,-90,90))
		vehicle:SetPoseParameter("lMG_pitch", Pitch )
	end
	if IsValid(rTurret) && IsValid(rTurret:GetDriver()) then
		local EyeAngles = rTurret:WorldToLocalAngles( ply:EyeAngles() )
		EyeAngles:RotateAroundAxis(EyeAngles:Up(),270)
		local Yaw = EyeAngles.y
		local Pitch = math.Clamp(EyeAngles.p,-90,90)

		vehicle:SetPoseParameter("rMG_yaw", math.Clamp(Yaw,-90,90))
		vehicle:SetPoseParameter("rMG_pitch", Pitch )
	end
end

function simfphys.weapon:FireTurrets( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
	
	local lTurret = vehicle.pSeat[3]
	local rTurret = vehicle.pSeat[4]
	if IsValid( lTurret ) then
		local ply = lTurret:GetDriver()
		if IsValid( ply ) then
		
			self:ControlTurrets( ply, vehicle, lTurret )
			
			local ID = vehicle:LookupAttachment("lTurret")
			local Attachment = vehicle:GetAttachment( ID )

			local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

			local fire = ply:KeyDown( IN_ATTACK )

			if fire then
				self:TurretAttack( vehicle, ply, shootOrigin, Attachment, ID )
			end
		end
	end
	if IsValid( rTurret ) then
		local ply = rTurret:GetDriver()
		if IsValid( ply ) then
		
			self:ControlTurrets( ply, vehicle, rTurret )
			
			local ID = vehicle:LookupAttachment("rTurret")
			local Attachment = vehicle:GetAttachment( ID )

			local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

			local fire = ply:KeyDown( IN_ATTACK )

			if fire then
				self:TurretAttack( vehicle, ply, shootOrigin, Attachment, ID )
			end
		end
	end
end

function simfphys.weapon:FireAntiAir( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	local pod = vehicle.pSeat[5]
	if IsValid( pod ) then
		local ply = pod:GetDriver()
		if IsValid( ply ) then
			self:ControlAntiAir( ply, vehicle, pod )
			
			local ID = vehicle:LookupAttachment("antiair")
			local Attachment = vehicle:GetAttachment( ID )

			local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

			local fire = ply:KeyDown( IN_ATTACK )

			if fire then
				self:AntiAirAttack( vehicle, ply, shootOrigin, Attachment, ID, deltapos )
			end
		end
	end
end

function simfphys.weapon:AntiAirAttack( vehicle, ply, shootOrigin, Attachment, ID, deltapos )
	
	if not self:CanAntiAirAttack( vehicle ) then return end

	for i = 1,4 do
		local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( Attachment.Ang )
		effectdata:SetEntity( vehicle )
		effectdata:SetAttachment(9 +i)
		effectdata:SetScale( 2 )
		util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )
	end

	vehicle:EmitSound("cpthazama/bwii/xylvania/machinegun_fire.wav", 95, 100)
	-- for i = 1,4 do
		-- local Attachment = vehicle:GetAttachment(vehicle:LookupAttachment("antiair"..i))
		local Attachment = vehicle:GetAttachment(vehicle:LookupAttachment("antiair"))
		local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
		local projectile = {}
		projectile.filter = vehicle.VehicleData["filter"]
		projectile.shootOrigin = shootOrigin
		projectile.shootDirection = Attachment.Ang:Forward()
		projectile.attacker = ply
		projectile.Tracer	= 0
		projectile.Spread = Vector(0.04,0.04,0.04)
		projectile.HullSize = 5
		projectile.attackingent = vehicle
		projectile.Damage = BWII_DMG_HMG
		projectile.Force = 12
		-- simfphys.FireHitScan( projectile )
		
		self:antiairfire(projectile)
	
		vehicle:GetPhysicsObject():ApplyForceOffset( -Attachment.Ang:Forward() * projectile.Force, shootOrigin )
	-- end
	
	self:SetNextAAFire( vehicle, CurTime() + 0.1 )
end

function simfphys.weapon:antiairfire(data)
	if not data then return end
	if not istable( data.filter ) then return end
	if not isvector( data.shootOrigin ) then return end
	if not isvector( data.shootDirection ) then return end
	if not IsValid( data.attacker ) then return end
	if not IsValid( data.attackingent ) then return end
	
	data.Spread = data.Spread or Vector(0,0,0)
	data.Tracer = data.Tracer or 0
	data.HullSize = data.HullSize or 1
	
	local trace = util.TraceHull( {
		start = data.shootOrigin,
		endpos = data.shootOrigin + (data.shootDirection + Vector(math.Rand(-data.Spread.x,data.Spread.x),math.Rand(-data.Spread.y,data.Spread.y),math.Rand(-data.Spread.x,data.Spread.x)) )* 50000,
		filter = data.filter,
		maxs = data.HullSize,
		mins = -data.HullSize
	} )
	
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= trace.HitPos - data.shootDirection * 5
	bullet.Dir 			= data.shootDirection
	bullet.Spread 		= Vector(0,0,0)
	bullet.Tracer		= 0
	bullet.Force		= (data.Force and data.Force or 1)
	bullet.Damage		= (data.Damage and data.Damage or 1)
	bullet.HullSize		= data.HullSize
	bullet.Attacker 		= data.attacker
	bullet.Callback = function(att, tr, dmginfo)
		if tr.Entity ~= Entity(0) then
			local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos + VectorRand() *400 )
			util.Effect( "Explosion", effectdata, true, true )
		end
	end
	data.attackingent:FireBullets( bullet )
	
	data.attackingent.hScanTracer = data.attackingent.hScanTracer and (data.attackingent.hScanTracer + 1) or 0
	
	if data.Tracer > 0 then
		if data.attackingent.hScanTracer >= data.Tracer then 
			data.attackingent.hScanTracer = 0
			
			local effectdata = EffectData()
			effectdata:SetStart( data.shootOrigin ) 
			effectdata:SetOrigin( trace.HitPos )
			util.Effect( "simfphys_tracer", effectdata )
		end
	end
end

function simfphys.weapon:ControlAntiAir( ply, vehicle, pod )
	if not IsValid( pod ) then return end
	local pod = vehicle.pSeat[5]
	if IsValid(pod) && IsValid(pod:GetDriver()) then
		local EyeAngles = pod:WorldToLocalAngles( ply:EyeAngles() )
		-- EyeAngles:RotateAroundAxis(EyeAngles:Right(),180)
		local Yaw = EyeAngles.y
		local Pitch = math.Clamp(EyeAngles.p,-90,90)

		vehicle:SetPoseParameter("antiair_yaw", math.Clamp(Yaw,-90,90))
		vehicle:SetPoseParameter("antiair_pitch", -Pitch )
	end
end

local function turret_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("cpthazama/bwii/xylvania/machinegun_fire.wav", 95, 100)
	local projectile = {}
	projectile.filter = vehicle.VehicleData["filter"]
	projectile.shootOrigin = shootOrigin
	projectile.shootDirection = shootDirection
	projectile.attacker = ply
	projectile.Tracer	= 1
	projectile.Spread = Vector(0.04,0.04,0.04)
	projectile.HullSize = 5
	projectile.attackingent = vehicle
	projectile.Damage = BWII_DMG_AA
	projectile.Force = 12
	simfphys.FireHitScan( projectile )
	
	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * projectile.Force, shootOrigin )
end

local function secondary_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound("cpthazama/bwii/westernfrontier/VW_LTank_Fire.wav",150,100)
	timer.Simple(2,function()
		if IsValid(vehicle) then
			vehicle:EmitSound("cpthazama/bwii/xylvania/lighttank_eject.wav",90,100)
		end
	end)

	local effectdata = EffectData()
	effectdata:SetEntity( vehicle )
	util.Effect( muzzleEffect, effectdata, true, true )

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * cannonForceOnVehicle, shootOrigin )
	
	local projectile = {}
	projectile.filter = vehicle.VehicleData["filter"]
	projectile.shootOrigin = shootOrigin
	projectile.shootDirection = shootDirection
	projectile.attacker = ply
	projectile.attackingent = vehicle
	projectile.Damage = cannonDMG
	projectile.Force = cannonForce
	projectile.Size = cannonEffectSize
	projectile.BlastRadius = cannonRadius
	projectile.BlastDamage = cannonRadiusDMG
	projectile.BlastEffect = "simfphys_tankweapon_explosion"
	projectile.MuzzleVelocity = 150
	
	AVX.FirePhysProjectile_Return(projectile)
end

function simfphys.weapon:ValidClasses()
	
	local classes = {
		class
	}
	
	return classes
end

function simfphys.weapon:GetForwardSpeed( vehicle )
	return vehicle.ForwardSpeed
end

function simfphys.weapon:IsOnGround( vehicle )
	return false
end

-- function simfphys.weapon:ModPhysics( vehicle, wheelslocked )
	-- if wheelslocked and self:IsOnGround( vehicle ) then
		-- local phys = vehicle:GetPhysicsObject()
		-- phys:ApplyForceCenter( -vehicle:GetVelocity() * phys:GetMass() * 0.04 )
	-- end
-- end

function simfphys.weapon:ControlTrackSounds( vehicle, wheelslocked ) 
	local speed = math.abs( self:GetForwardSpeed( vehicle ) )
	local fastenuf = speed > 20 and not wheelslocked and self:IsOnGround( vehicle )
	
	if fastenuf ~= vehicle.fastenuf then
		vehicle.fastenuf = fastenuf
		
		if fastenuf then
			vehicle.track_snd = CreateSound( vehicle, "simulated_vehicles/sherman/tracks.wav" )
			vehicle.track_snd:PlayEx(0,0)
			vehicle:CallOnRemove( "stopmesounds", function( vehicle )
				if vehicle.track_snd then
					vehicle.track_snd:Stop()
				end
			end)
		else
			if vehicle.track_snd then
				vehicle.track_snd:Stop()
				vehicle.track_snd = nil
			end
		end
	end
	
	if vehicle.track_snd then
		vehicle.track_snd:ChangePitch( math.Clamp(60 + speed / 80,0,150) ) 
		vehicle.track_snd:ChangeVolume( math.min( math.max(speed - 20,0) / 600,1) ) 
	end
end

	//--------------- AI Stuff ---------------\\

function simfphys.weapon:HasAI(vehicle)
	return vehicle:GetNWBool("bwii_AI")
end

function simfphys.weapon:SetEnemy(ent,vehicle)
	-- vehicle.Enemy = ent
	vehicle:SetNWEntity("bwii_ent",ent)
end

function simfphys.weapon:GetEnemy(vehicle)
	-- if vehicle.Enemy == NULL || vehicle.Enemy == nil then
		-- for _,v in ipairs(ents.GetAll()) do
			-- if v:IsPlayer() or v:IsVehicle() then
				-- if v == self then return end
				-- if (v:IsVehicle() && v:GetNWInt("bwii_team") == TEAM) then return end
				-- if (v:IsPlayer() && v:lfsGetAITeam() == TEAM) then return end
				-- if v:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1 then return end
				-- if v:IsVehicle() && !IsValid(v.Simfphys_AI) then return end
				-- veh:SetEnemy(v)
			-- end
		-- end
	-- end
	-- return vehicle.Enemy
	return vehicle:GetNWEntity("bwii_ent")
end

function simfphys.weapon:AI(vehicle,deltapos)
	if IsValid(self:GetEnemy(vehicle)) then
		-- if self:GetEnemy(vehicle):lfsGetAITeam() == TEAM then return end
		self:AI_Turret(vehicle,deltapos,self:GetEnemy(vehicle))
	end
end

function simfphys.weapon:AI_Aim(enemy,vehicle,Attachment)
	local AimRate = chasisTurnSpeed
	local selfpos = vehicle:GetPos() +vehicle:OBBCenter()
	local selfang = vehicle:GetAngles()
	local targetang = (enemy:GetPos() -selfpos):Angle()
	local pitch = math.AngleDifference(targetang.p,selfang.p)
	local yaw = math.AngleDifference(targetang.y,selfang.y)
	vehicle:SetPoseParameter(ppTurretPitch,-math.ApproachAngle(vehicle:GetPoseParameter(ppTurretPitch),pitch,AimRate) +ppTurretPitchAddition)
	vehicle:SetPoseParameter(ppTurretYaw,math.ApproachAngle(vehicle:GetPoseParameter(ppTurretYaw),yaw,AimRate))
end

function simfphys.weapon:AI_Turret(vehicle,deltapos,enemy)
	local ID = vehicle:LookupAttachment( "muzzle" )
	local Attachment = vehicle:GetAttachment( ID )
	local ID2 = vehicle:LookupAttachment( "muzzle" )
	local Attachment2 = vehicle:GetAttachment( ID2 )
	
	self:AI_Aim(enemy,vehicle,Attachment)
	
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	local shootOrigin2 = Attachment2.Pos + deltapos * engine.TickInterval()
	
	local fire = enemy:Visible(vehicle)

	-- if fire then
		self:PrimaryAttack(vehicle,vehicle,shootOrigin,Attachment,shootOrigin2,Attachment2)
	-- end
end

	//--------------- AI Stuff End ---------------\\

function simfphys.weapon:Think( vehicle )
	if not IsValid( vehicle ) or not vehicle:IsInitialized() then return end

	vehicle.wOldPos = vehicle.wOldPos or Vector(0,0,0)
	local deltapos = vehicle:GetPos() -vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()
	
	-- if vehicle:GetCurHealth() <= vehicle:GetMaxHealth() *0.1 then
		-- vehicle:GetPhysicsObject():SetBuoyancyRatio(0.01)
	-- end

	local waterLevel = vehicle:WaterLevel()
	if waterLevel > 0 then
		local throttle = vehicle:GetThrottle()
		local gear = vehicle:GetGear()
		if gear == 1 then throttle = throttle*(-1) end

		local physObj = vehicle:GetPhysicsObject()
		for i = 1, table.Count(vehicle.Wheels) do
			local Wheel = vehicle.Wheels[i]
			if IsValid(Wheel) then
				local physWObj = Wheel:GetPhysicsObject()
				if waterLevel > 0 then
					physWObj:AddVelocity(Vector(0,0,250))
				end
			end
		end

		local direction = vehicle.OriginEntity:GetForward() *1
		local back = false
		local pod = vehicle:GetDriverSeat()
		if IsValid(pod) then
			local ply = pod:GetDriver()
			if IsValid(ply) then
				back = ply:KeyDown(IN_BACK)
			end
		end

		if IsValid(vehicle.OriginEntity) then
			vehicle.OriginEntity:SetPos(vehicle:GetPos() +vehicle:OBBCenter())
			vehicle.OriginEntity:SetAngles(Angle(0,vehicle:GetAngles().y,0))
			if throttle > 0 then
				physObj:AddVelocity(direction *throttle*(vehicle:GetRPM()/5000)*(vehicle:GetMaxTorque()/100)*(vehicle:GetEfficiency()))
			elseif back then
				physObj:AddVelocity(-(direction *throttle*(vehicle:GetRPM()/2000)*(vehicle:GetMaxTorque()/100)*(vehicle:GetEfficiency())))
			elseif throttle == 0 && vehicle:GetVelocity():Length() != 0 then
				physObj:AddVelocity(-vehicle:GetVelocity() /95)
			end
		end

		local steer = vehicle:GetVehicleSteer()
		local speed = vehicle:GetVelocity():Length()
		local kmh = math.Round(speed *0.09144,0)
		if steer < 0 then
			if kmh >= 8 then
				physObj:AddAngleVelocity(Vector(0,0,vehicle:GetSteerSpeed()-0.8))
			elseif kmh < 8 and kmh != 0 then
				physObj:AddAngleVelocity(Vector(0,0,vehicle:GetSteerSpeed()-0.9))
			end
		elseif steer > 0 and kmh >= 2 then
			if kmh >= 8 then
				physObj:AddAngleVelocity(Vector(0,0,(vehicle:GetSteerSpeed()-0.8)*(-1)))
			elseif kmh < 8 and kmh != 0 then
				physObj:AddAngleVelocity(Vector(0,0,(vehicle:GetSteerSpeed()-0.9)*(-1)))
			end
		end
	end
	
	local handbrake = vehicle:GetHandBrakeEnabled()
	
	if self:HasAI(vehicle) then
		self:AI(vehicle,deltapos)
	end
	
	self:DoWheelSpin( vehicle )
	self:ControlTurret( vehicle, deltapos )
	self:FireLeftCannon( vehicle, deltapos )
	self:FireRightCannon( vehicle, deltapos )
	self:FireTurrets( vehicle, deltapos )
	self:FireAntiAir( vehicle, deltapos )
	-- self:ControlTrackSounds( vehicle, handbrake )
	-- self:ModPhysics( vehicle, handbrake )
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment, shootOrigin2, Attachment2 , deltapos)
	if not self:CanPrimaryAttack( vehicle ) then return end
	primary_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward())
	timer.Simple(0.6,function()
		if IsValid(vehicle) then
		local ID2 = vehicle:LookupAttachment( "muzzle2" )
		local Attachment2 = vehicle:GetAttachment( ID2 )
		local shootOrigin2 = Attachment2.Pos + deltapos * engine.TickInterval()
			primary_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward(), shootOrigin2, Attachment2.Ang:Forward() )
		end
	end)
	self:SetNextPrimaryFire( vehicle, CurTime() + reloadTime )
end

function simfphys.weapon:TurretAttack( vehicle, ply, shootOrigin, Attachment, ID )
	
	if not self:CanTurretAttack( vehicle ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( shootOrigin )
	effectdata:SetAngles( Attachment.Ang )
	effectdata:SetEntity( vehicle )
	effectdata:SetAttachment( ID )
	effectdata:SetScale( 4 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )
	
	turret_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward() )
	
	self:SetNextTurretFire( vehicle, CurTime() + 0.08 )
end

function simfphys.weapon:SecondaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
	
	if not self:CanSecondaryAttack( vehicle ) then return end
	
	secondary_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward() )
	
	self:SetNextSecondaryFire( vehicle, CurTime() + secondaryCooldown )
end

function simfphys.weapon:ControlLeftCannon( ply, vehicle, pod )
	if not IsValid( pod ) then return end
	
	local lCannon = vehicle.pSeat[1]
	
	if IsValid(lCannon) then
		local EyeAngles = lCannon:WorldToLocalAngles( ply:EyeAngles() )
		EyeAngles:RotateAroundAxis(EyeAngles:Up(),270)
		local Yaw = EyeAngles.y
		local Pitch = math.Clamp(EyeAngles.p,-90,90)

		vehicle:SetPoseParameter("lcannon_yaw", math.Clamp(-Yaw,-90,0))
		vehicle:SetPoseParameter("lcannon_pitch", Pitch )
	end
end

function simfphys.weapon:ControlRightCannon( ply, vehicle, pod )
	if not IsValid( pod ) then return end
	
	local rCannon = vehicle.pSeat[2]
	if IsValid(rCannon) then
		local EyeAngles = rCannon:WorldToLocalAngles( ply:EyeAngles() )
		EyeAngles:RotateAroundAxis(EyeAngles:Up(),270)
		local Yaw = EyeAngles.y
		local Pitch = math.Clamp(EyeAngles.p,-90,0)

		vehicle:SetPoseParameter("rcannon_yaw", math.Clamp(Yaw,-90,0))
		vehicle:SetPoseParameter("rcannon_pitch", Pitch )
	end
end

function simfphys.weapon:AimCannon( ply, vehicle, pod, Attachment )
	if not IsValid( pod ) then return end

	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )

	local AimRate = chasisTurnSpeed

	local Angles = vehicle:WorldToLocalAngles( Aimang )

	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y + ppTurretYawAddition, AimRate * FrameTime() ) or 0
	vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p + ppTurretPitchAddition, AimRate * FrameTime() ) or 0

	local TargetAng = Angle(vehicle.sm_pp_pitch,vehicle.sm_pp_yaw,0)
	TargetAng:Normalize()

	if reverseChasisYaw then
		vehicle:SetPoseParameter(ppTurretYaw, -TargetAng.y )
	else
		vehicle:SetPoseParameter(ppTurretYaw, TargetAng.y )
	end
	if reverseChasisPitch then
		vehicle:SetPoseParameter(ppTurretPitch, -TargetAng.p )
	else
		vehicle:SetPoseParameter(ppTurretPitch, TargetAng.p )
	end
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:CanSecondaryAttack( vehicle )
	vehicle.NextShoot2 = vehicle.NextShoot2 or 0
	return vehicle.NextShoot2 < CurTime()
end

function simfphys.weapon:CanTurretAttack( vehicle )
	vehicle.NextShoot3 = vehicle.NextShoot3 or 0
	return vehicle.NextShoot3 < CurTime()
end

function simfphys.weapon:CanAntiAirAttack( vehicle )
	vehicle.NextShootAA = vehicle.NextShootAA or 0
	return vehicle.NextShootAA < CurTime()
end

function simfphys.weapon:SetNextTurretFire( vehicle, time )
	vehicle.NextShoot3 = time
end

function simfphys.weapon:SetNextAAFire( vehicle, time )
	vehicle.NextShootAA = time
end

function simfphys.weapon:SetNextPrimaryFire( vehicle, time )
	vehicle.NextShoot = time; vehicle:SetNWFloat("SpecialCam_LoaderNext",time)
end

function simfphys.weapon:SetNextSecondaryFire( vehicle, time )
	vehicle.NextShoot2 = time
end

function simfphys.weapon:UpdateSuspension( vehicle )
	if not vehicle.filterEntities then
		vehicle.filterEntities = player.GetAll()
		table.insert(vehicle.filterEntities, vehicle)
		
		for i, wheel in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_wheel" ) ) do
			table.insert(vehicle.filterEntities, wheel)
		end
	end
	
	vehicle.oldDist = istable( vehicle.oldDist ) and vehicle.oldDist or {}
	
	vehicle.susOnGround = false
	
	-- for i, v in pairs( tblSuspensionData ) do
		-- local pos = vehicle:GetAttachment( vehicle:LookupAttachment( tblSuspensionData[i].attachment ) ).Pos
		
		-- local trace = util.TraceHull( {
			-- start = pos,
			-- endpos = pos + vehicle:GetUp() * - 100,
			-- maxs = Vector(15,15,0),
			-- mins = -Vector(15,15,0),
			-- filter = vehicle.filterEntities,
		-- } )
		-- local Dist = (pos - trace.HitPos):Length() - 42
		
		-- if trace.Hit then
			-- vehicle.susOnGround = true
		-- end
		
		-- vehicle.oldDist[i] = vehicle.oldDist[i] and (vehicle.oldDist[i] + math.Clamp(Dist - vehicle.oldDist[i],-10,1)) or 0

		-- vehicle.oldDist[i] = math.Clamp(vehicle.oldDist[i], 6, math.huge)
		
		-- vehicle:SetPoseParameter(tblSuspensionData[i].poseparameter, vehicle.oldDist[i] )
	-- end
end

function simfphys.weapon:DoWheelSpin( vehicle )
	-- local spin_r = vehicle.VehicleData[ "spin_4" ] + vehicle.VehicleData[ "spin_6" ] /2
	-- local spin_l = vehicle.VehicleData[ "spin_3" ] + vehicle.VehicleData[ "spin_5" ] /2
	
	vehicle.SplashT = vehicle.SplashT or CurTime()
	local throttle = vehicle:GetThrottle()
	local multi = 4
	self.lWheel = self.lWheel or 0
	self.rWheel = self.rWheel or 0
	self.lWheel = self.lWheel +throttle *multi
	self.rWheel = self.rWheel +throttle *multi
	vehicle:SetPoseParameter("rwheel",-self.rWheel)
	vehicle:SetPoseParameter("lwheel",-self.lWheel)
	if throttle > 0 && vehicle:WaterLevel() > 0 then
		local effectdata = EffectData()
		effectdata:SetOrigin(vehicle:LocalToWorld(Vector(275.13,2.96,80.63)))
		effectdata:SetScale(18)
		util.Effect("waterripple",effectdata)
		local effectdata = EffectData()
		effectdata:SetOrigin(vehicle:LocalToWorld(Vector(275.13,2.96,90.63)))
		effectdata:SetScale(18)
		util.Effect("waterripple",effectdata)
		local effectdata = EffectData()
		effectdata:SetOrigin(vehicle:LocalToWorld(Vector(-75.65,102,77.33)))
		effectdata:SetScale(7)
		util.Effect("waterripple",effectdata)
		local effectdata = EffectData()
		effectdata:SetOrigin(vehicle:LocalToWorld(Vector(-75.31,-96.37,76.86)))
		effectdata:SetScale(7)
		util.Effect("waterripple",effectdata)
		if CurTime() > vehicle.SplashT then
			local effectdata = EffectData()
			effectdata:SetOrigin(vehicle:LocalToWorld(Vector(-75.65,102,77.33)))
			effectdata:SetScale(7)
			util.Effect("watersplash",effectdata)
			local effectdata = EffectData()
			effectdata:SetOrigin(vehicle:LocalToWorld(Vector(-75.31,-96.37,76.86)))
			effectdata:SetScale(7)
			util.Effect("watersplash",effectdata)
			local a = 0.5
			if throttle > 0.5 then
				a = 0.25
			end
			vehicle.SplashT = CurTime() +a
		end
	end
end