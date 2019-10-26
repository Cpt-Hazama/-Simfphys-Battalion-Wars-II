	-- Variables --
local class = "bwii_xbattlestation_old"
local icon = "entities/bwii_xbattlestation_old.png"
local name = "Battlestation"
local TEAM = TEAM_XYLVANIA
local driverFPPos = Vector(115,83.5,0)
local driverTPPos = Vector(0,0,120)
local driverFollowerAttachment = true
local crosshairDirection = Vector(0,90,0)
local lCannonFPPos = Vector(0,0,0)
local lCannonFPPos = Vector(0,0,0)
local rCannonFPPos = Vector(0,0,0)
local rCannonFPPos = Vector(0,0,0)

local groundCheckDistance = 350
local centerVector = Vector(0,0,100)

-- local fireSound = "cpthazama/bwii/tundra/VT_Batt_Fire.wav"
local fireSound = "cpthazama/bwii/westernfrontier/VW_Batt_Fire.wav"
local fireSoundVolume = 150
local fireSoundPitch = 100

local reloadSoundTime = 5
local reloadSound = "cpthazama/bwii/V_Eject_Heavy.wav"
local reloadSoundVolume = 105
local reloadSoundPitch = 100
local reloadTime = BWII_RL_BATTLESTATION

local secondSound = "cpthazama/bwii/xylvania/lighttank_fire.wav"
local secondSoundVolume = 150
local secondSoundPitch = 100

local ppTurretYaw = "turret_yaw"
local ppTurretPitch = "turret_pitch"
local chasisTurnSpeed = 70
local ppTurretYawAddition = 0
local ppTurretPitchAddition = -5
local reverseChasisYaw = false
local reverseChasisPitch = true

local muzzleEffect = "xltank_muzzle"
local mainForceOnVehicle = 999000
local mainDMG = BWII_DMG_BATTLESTATION
local mainForce = 10000
local mainEffectSize = 25
local mainRadius = 950
local mainRadiusDMG = BWII_DMG_BATTLESTATION /20

local cannonForceOnVehicle = 800000
local cannonDMG = BWII_DMG_LIGHTTANK
local cannonForce = 10000
local cannonEffectSize = 7
local cannonRadius = 200
local cannonRadiusDMG = BWII_DMG_LIGHTTANK /20

local secondaryAttachment = "acidgun"
local secondaryCooldown = 3
local ppSideTurretYaw = "lcannon_yaw"
local ppSideTurretPitch = "lcannon_pitch"

	-- Code --
local tblSuspensionData = {} -- Currently unused
for i = 1,5 do
	tblSuspensionData[i] = { 
		attachment = "vehicle_suspension_l_"..i,
		poseparameter = "suspension_left_"..i,
	}
	
	local ir = i + 5
	tblSuspensionData[ir] = { 
		attachment = "vehicle_suspension_r_"..i,
		poseparameter = "suspension_right_"..i,
	}
end

function simfphys.weapon:Initialize( vehicle )
	net.Start( "avx_misc_register_tank_custom" )
		net.WriteEntity( vehicle )
		net.WriteString( class )
	net.Broadcast()
	vehicle:SetNWInt("bwii_icon",icon)
	vehicle:SetNWInt("bwii_name",name); vehicle:SetNWFloat("SpecialCam_LoaderTime",reloadTime)
	
	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), { Attachment = "lMain", Direction = crosshairDirection, Type = 4 } )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), driverFPPos, driverTPPos, driverFollowerAttachment, "muzzle" )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	simfphys.RegisterCrosshair( vehicle.pSeat[1] , { Attachment = "lCannon", Type = 3 } )
	simfphys.RegisterCamera( vehicle.pSeat[1], lCannonFPPos, lCannonTPPos, false, "lCannon" )

	simfphys.RegisterCrosshair( vehicle.pSeat[2] , { Attachment = "rCannon", Type = 3 } )
	simfphys.RegisterCamera( vehicle.pSeat[2], rCannonFPPos, rCannonTPPos, false, "rCannon" )

	simfphys.RegisterCrosshair( vehicle.pSeat[3] , { Attachment = "lTurret", Type = 1 } )
	simfphys.RegisterCamera( vehicle.pSeat[3], Vector(0,0,0), Vector(0,0,15), false, "lTurret" )

	simfphys.RegisterCrosshair( vehicle.pSeat[4] , { Attachment = "rTurret", Type = 1 } )
	simfphys.RegisterCamera( vehicle.pSeat[4], Vector(0,0,0), Vector(0,0,15), false, "rTurret" )

	simfphys.RegisterCrosshair( vehicle.pSeat[5] , { Attachment = "cTurret", Type = 1 } )
	simfphys.RegisterCamera( vehicle.pSeat[5], Vector(0,0,0), Vector(0,0,15), false, "cTurret" )

	timer.Simple( 1, function()
		if not IsValid( vehicle ) then return end
		if not vehicle.VehicleData["filter"] then print("[simfphys Armed Vehicle Pack] ERROR:TRACE FILTER IS INVALID. PLEASE UPDATE SIMFPHYS BASE") return end
		
		vehicle.WheelOnGround = function( ent )
			ent.FrontWheelPowered = ent:GetPowerDistribution() ~= 1
			ent.RearWheelPowered = ent:GetPowerDistribution() ~= -1
			
			for i = 1, table.Count( ent.Wheels ) do
				local Wheel = ent.Wheels[i]		
				if IsValid( Wheel ) then
					local dmgMul = Wheel:GetDamaged() and 0.5 or 1
					local surfacemul = simfphys.TractionData[Wheel:GetSurfaceMaterial():lower()]
					
					ent.VehicleData[ "SurfaceMul_" .. i ] = (surfacemul and math.max(surfacemul,0.001) or 1) * dmgMul
					
					local WheelPos = ent:LogicWheelPos( i )
					
					local WheelRadius = WheelPos.IsFrontWheel and ent.FrontWheelRadius or ent.RearWheelRadius
					local startpos = Wheel:GetPos()
					local dir = -ent.Up
					local len = WheelRadius + math.Clamp(-ent.Vel.z / 50,2.5,6)
					local HullSize = Vector(WheelRadius,WheelRadius,0)
					local tr = util.TraceHull( {
						start = startpos,
						endpos = startpos + dir * len,
						maxs = HullSize,
						mins = -HullSize,
						filter = ent.VehicleData["filter"]
					} )
					
					local onground = self:IsOnGround( vehicle ) and 1 or 0
					Wheel:SetOnGround( onground )
					ent.VehicleData[ "onGround_" .. i ] = onground
					
					if tr.Hit then
						Wheel:SetSpeed( Wheel.FX )
						Wheel:SetSkidSound( Wheel.skid )
						Wheel:SetSurfaceMaterial( util.GetSurfacePropName( tr.SurfaceProps ) )
					end
				end
			end
			
			local FrontOnGround = math.max(ent.VehicleData[ "onGround_1" ],ent.VehicleData[ "onGround_2" ])
			local RearOnGround = math.max(ent.VehicleData[ "onGround_3" ],ent.VehicleData[ "onGround_4" ])
			
			ent.DriveWheelsOnGround = math.max(ent.FrontWheelPowered and FrontOnGround or 0,ent.RearWheelPowered and RearOnGround or 0)
		end
	end)
end

function simfphys.weapon:ControlTurret( vehicle, deltapos )
	local pod = vehicle:GetDriverSeat()
	
	if not IsValid( pod ) then return end
	
	local ply = pod:GetDriver()
	
	if not IsValid( ply ) then return end
	
	local ID = vehicle:LookupAttachment( "lMain" )
	local Attachment = vehicle:GetAttachment( ID )
	
	local ID2 = vehicle:LookupAttachment( "rMain" )
	local Attachment2 = vehicle:GetAttachment( ID2 )
	
	self:AimCannon( ply, vehicle, pod, Attachment )
	
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	local shootOrigin2 = Attachment2.Pos + deltapos * engine.TickInterval()
	
	local fire = ply:KeyDown( IN_ATTACK )

	if fire then
		self:PrimaryAttack( vehicle, ply, shootOrigin, Attachment, shootOrigin2, Attachment2 )
	end
end

local function primary_fire(ply,vehicle,shootOrigin,shootDirection,shootOrigin2,shootDirection2)
	vehicle:EmitSound(fireSound, fireSoundVolume, fireSoundPitch)
	timer.Simple(reloadTime -1,function()
		if IsValid(vehicle) then
			vehicle:EmitSound(reloadSound, reloadSoundVolume, reloadSoundPitch)
		end
	end)

	local effectdata = EffectData()
	effectdata:SetEntity( vehicle )
	util.Effect( muzzleEffect, effectdata, true, true )

	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * mainForceOnVehicle, shootOrigin )
	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection2 * mainForceOnVehicle, shootOrigin )
	
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
	projectile.MuzzleVelocity = 150
	
	AVX.FirePhysProjectile_Return(projectile)

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
	projectile.MuzzleVelocity = 150
	
	AVX.FirePhysProjectile_Return(projectile)
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
	if IsValid(cTurret) && IsValid(cTurret:GetDriver()) then
		local EyeAngles = cTurret:WorldToLocalAngles( ply:EyeAngles() )
		EyeAngles:RotateAroundAxis(EyeAngles:Up(),270)
		local Yaw = EyeAngles.y
		local Pitch = math.Clamp(EyeAngles.p,-90,90)

		vehicle:SetPoseParameter("cMG_yaw", math.Clamp(Yaw,-90,90))
		vehicle:SetPoseParameter("cMG_pitch", Pitch )
	end
end

function simfphys.weapon:FireTurrets( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
	
	local lTurret = vehicle.pSeat[3]
	local rTurret = vehicle.pSeat[4]
	local cTurret = vehicle.pSeat[5]
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
	if IsValid( cTurret ) then
		local ply = cTurret:GetDriver()
		if IsValid( ply ) then
		
			self:ControlTurrets( ply, vehicle, cTurret )
			
			local ID = vehicle:LookupAttachment("cTurret")
			local Attachment = vehicle:GetAttachment( ID )

			local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

			local fire = ply:KeyDown( IN_ATTACK )

			if fire then
				self:TurretAttack( vehicle, ply, shootOrigin, Attachment, ID )
			end
		end
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
	projectile.Damage = BWII_DMG_HMG
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
	-- return (vehicle.susOnGround == true)
	-- return true
	local startPos = vehicle:GetPos() +centerVector
	local tr = util.TraceLine({
		start = startPos,
		endpos = startPos +vehicle:GetUp() *-groundCheckDistance,
		filter = {vehicle}
	})
	if tr.Hit && tr.HitWorld && tr.HitPos:Distance(startPos) <= groundCheckDistance then
		return true
	end
	return false
end

function simfphys.weapon:ModPhysics( vehicle, wheelslocked )
	if wheelslocked and self:IsOnGround( vehicle ) then
		local phys = vehicle:GetPhysicsObject()
		phys:ApplyForceCenter( -vehicle:GetVelocity() * phys:GetMass() * 0.04 )
	end
end

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
	local ID = vehicle:LookupAttachment( "lMain" )
	local Attachment = vehicle:GetAttachment( ID )
	local ID2 = vehicle:LookupAttachment( "rMain" )
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
	local deltapos = vehicle:GetPos() - vehicle.wOldPos
	vehicle.wOldPos = vehicle:GetPos()

	if self:HasAI(vehicle) then
		self:AI(vehicle,deltapos)
	end
	
	local handbrake = vehicle:GetHandBrakeEnabled()
	
	self:UpdateSuspension( vehicle )
	self:DoWheelSpin( vehicle )
	self:ControlTurret( vehicle, deltapos )
	self:FireLeftCannon( vehicle, deltapos )
	self:FireRightCannon( vehicle, deltapos )
	self:FireTurrets( vehicle, deltapos )
	self:ControlTrackSounds( vehicle, handbrake )
	self:ModPhysics( vehicle, handbrake )
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment, shootOrigin2, Attachment2 )
	if not self:CanPrimaryAttack( vehicle ) then return end
	primary_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward(), shootOrigin2, Attachment2.Ang:Forward() )
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

function simfphys.weapon:SetNextTurretFire( vehicle, time )
	vehicle.NextShoot3 = time
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
	local spin_r = vehicle.VehicleData[ "spin_4" ] + vehicle.VehicleData[ "spin_6" ] /2
	local spin_l = vehicle.VehicleData[ "spin_3" ] + vehicle.VehicleData[ "spin_5" ] /2
	
	vehicle:SetPoseParameter("spin_wheels_right", spin_r)
	vehicle:SetPoseParameter("spin_wheels_left", spin_l )
	
	net.Start( "simfphys_update_tracks", true )
		net.WriteEntity( vehicle )
		net.WriteFloat( spin_r ) 
		net.WriteFloat( spin_l ) 
	net.Broadcast()
end