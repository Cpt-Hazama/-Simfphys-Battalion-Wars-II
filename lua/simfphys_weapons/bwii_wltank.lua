	-- Variables --
local class = "bwii_wltank"
local icon = "entities/bwii_wltank.png"
local name = "Light Tank"
local TEAM = TEAM_FRONTIER
local driverFPPos = Vector(-65,-30,15)
local driverTPPos = Vector(0,0,90)
local driverFollowerAttachment = true
local crosshairDirection = Vector(0,90,0)
local gunnerFPPos = Vector(0,0,0)
local gunnerTPPos = Vector(0,0,0)
local gunnerFollowerAttachment = false

local groundCheckDistance = 235
local centerVector = Vector(0,0,100)

local fireSound = "cpthazama/bwii/westernfrontier/VW_LTank_Fire.wav"
local fireSoundVolume = 150
local fireSoundPitch = 100

local reloadSoundTime = 2
local reloadSound = "cpthazama/bwii/xylvania/lighttank_eject.wav"
local reloadSoundVolume = 90
local reloadSoundPitch = 100
local reloadTime = BWII_RL_LIGHTTANK

local secondSound = "cpthazama/bwii/westernfrontier/WW_HMG_Fire_2.wav"
local secondSoundVolume = 95
local secondSoundPitch = 100

local ppTurretYaw = "turret_yaw"
local ppTurretPitch = "turret_pitch"
local chasisTurnSpeed = 115
local ppTurretYawAddition = 0
local ppTurretPitchAddition = -5
local reverseChasisYaw = false
local reverseChasisPitch = true

local muzzleEffect = "xltank_muzzle"
local mainForceOnVehicle = 800000
local mainDMG = BWII_DMG_LIGHTTANK
local mainForce = 10000
local mainEffectSize = 7
local mainRadius = 200
local mainRadiusDMG = BWII_DMG_LIGHTTANK /20

local secondaryAttachment = "turret"
local secondaryCooldown = 0.1
local ppSideTurretYaw = "l_yaw"
local ppSideTurretPitch = "l_pitch"

function simfphys.weapon:Initialize( vehicle )
	net.Start( "avx_misc_register_tank_custom" )
		net.WriteEntity( vehicle )
		net.WriteString( class )
	net.Broadcast()
	vehicle:SetNWInt("bwii_icon",icon); vehicle:SetNWInt("bwii_team",TEAM)
	vehicle:SetNWInt("bwii_name",name); vehicle:SetNWFloat("SpecialCam_LoaderTime",reloadTime)
	
	vehicle.LockTarget = NULL
	
	vehicle:ManipulateBoneJiggle(29,1)
	-- vehicle:ManipulateBoneJiggle(30,1)

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), { Direction = crosshairDirection, Type = 4 } )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), driverFPPos, driverTPPos, driverFollowerAttachment, "muzzle" )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	simfphys.RegisterCrosshair( vehicle.pSeat[1] , { Attachment = secondaryAttachment, Type = 1 } )
	simfphys.RegisterCamera( vehicle.pSeat[1], gunnerFPPos, gunnerTPPos, gunnerFollowAttachment, secondaryAttachment )

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
	
	local ID = vehicle:LookupAttachment( "muzzle" )
	local Attachment = vehicle:GetAttachment( ID )
	
	self:AimCannon( ply, vehicle, pod, Attachment )
	
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	
	local fire = ply:KeyDown( IN_ATTACK )

	if fire then
		self:PrimaryAttack( vehicle, ply, shootOrigin, Attachment )
	end
end

local function primary_fire(ply,vehicle,shootOrigin,shootDirection)
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
end

function simfphys.weapon:ControlMachinegun( vehicle, deltapos )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end
	
	local pod = vehicle.pSeat[1]
	
	if not IsValid( pod ) then return end
	
	local ply = pod:GetDriver()
	
	if not IsValid( ply ) then return end
	
	self:AimMachinegun( ply, vehicle, pod )
	
	local ID = vehicle:LookupAttachment( secondaryAttachment )
	local Attachment = vehicle:GetAttachment( ID )

	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()

	local fire = ply:KeyDown( IN_ATTACK )

	if fire then
		self:SecondaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
	end
end

local function secondary_fire(ply,vehicle,shootOrigin,shootDirection)
	vehicle:EmitSound(secondSound, secondSoundVolume, secondSoundPitch)
	
	local projectile = {}
	projectile.filter = vehicle.VehicleData["filter"]
	projectile.shootOrigin = shootOrigin
	projectile.shootDirection = shootDirection
	projectile.attacker = ply
	projectile.Tracer	= 2
	projectile.Spread = Vector(0.01,0.01,0.01)
	projectile.HullSize = 5
	projectile.attackingent = vehicle
	projectile.Damage = BWII_DMG_HMG
	projectile.Force = 12
	simfphys.FireHitScan( projectile )
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
			vehicle.track_snd = CreateSound( vehicle, "cpthazama/bwii/westernfrontier/VW_LTank_Eng.wav" )
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
	
	self:AI_Aim(enemy,vehicle,Attachment)
	
	local shootOrigin = Attachment.Pos + deltapos * engine.TickInterval()
	
	local fire = enemy:Visible(vehicle)

	-- if fire then
		self:PrimaryAttack(vehicle,vehicle,shootOrigin,Attachment)
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
	self:ControlMachinegun( vehicle, deltapos )
	self:ControlTrackSounds( vehicle, handbrake )
	self:ModPhysics( vehicle, handbrake )
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment, HE )
	if not self:CanPrimaryAttack( vehicle ) then return end
	primary_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward() )
	self:SetNextPrimaryFire( vehicle, CurTime() + reloadTime )
end

function simfphys.weapon:SecondaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
	
	if not self:CanSecondaryAttack( vehicle ) then return end
	
	local effectdata = EffectData()
	effectdata:SetOrigin( shootOrigin )
	effectdata:SetAngles( Attachment.Ang )
	effectdata:SetEntity( vehicle )
	effectdata:SetAttachment( ID )
	effectdata:SetScale( 4 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )
	
	secondary_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward() )
	
	self:SetNextSecondaryFire( vehicle, CurTime() + secondaryCooldown )
end

function simfphys.weapon:AimMachinegun( ply, vehicle, pod )
	if not IsValid( pod ) then return end
	local targBone = "lTurret"
	local offset = Vector(0,0,-20)
	local AimRate = 250

	local aimCheck = vehicle:GetPoseParameter(ppTurretYaw)
	local pos,ang = vehicle:GetBonePosition(vehicle:LookupBone(targBone))
	local vAng = vehicle:GetAngles()
	pod:SetPos(vehicle:WorldToLocal(pos) +offset)
	pod:SetAngles(Angle(vAng.p,vAng.y +aimCheck -90,0))
	local Aimang = pod:WorldToLocalAngles(ply:EyeAngles())
	local Angles = vehicle:WorldToLocalAngles(Aimang)
	vehicle.sm_pp_lturret_yaw = vehicle.sm_pp_lturret_yaw && math.ApproachAngle(vehicle.sm_pp_lturret_yaw,Angles.y,AimRate *FrameTime()) or 180
	vehicle.sm_pp_lturret_pitch = vehicle.sm_pp_lturret_pitch && math.ApproachAngle(vehicle.sm_pp_lturret_pitch,Angles.p,AimRate *FrameTime()) or 0
	local TargetAng = Angle(vehicle.sm_pp_lturret_pitch,vehicle.sm_pp_lturret_yaw,0)
	TargetAng:Normalize()
	vehicle.sm_pp_yaw = vehicle.sm_pp_yaw or 180
	vehicle:SetPoseParameter(ppSideTurretYaw,Aimang.y -90)
	vehicle:SetPoseParameter(ppSideTurretPitch,-TargetAng.p)
end

function simfphys.weapon:AimCannon( ply, vehicle, pod, Attachment )
	if not IsValid( pod ) then return end

	local Aimang = pod:WorldToLocalAngles( ply:EyeAngles() )
	
	
	local startPos = vehicle:GetAttachment(1).Pos
	local startAng = vehicle:GetAttachment(1).Ang
	local key = ply:KeyDown(IN_WALK)
	if key then
		if vehicle.LockTarget == NULL then
			local tr = util.TraceLine({
				start = startPos,
				endpos = vehicle:GetPos() +startAng:Forward() *50000,
				filter = {vehicle}
			})
			if tr.Hit && IsValid(tr.Entity) then
				local ent = tr.Entity
				if (ent:IsNPC() || ent:IsPlayer() || (ent:IsVehicle() && ent != vehicle) || ent.LFS) then
					vehicle.LockTarget = ent
				end
			end
		end
	else
		vehicle.LockTarget = NULL
	end
	
	if IsValid(vehicle.LockTarget) then
		local AimRate = chasisTurnSpeed
		local enemy = vehicle.LockTarget
		local selfpos = vehicle:GetPos() +vehicle:OBBCenter()
		local selfang = vehicle:GetAngles()
		local targetang = (enemy:GetPos() -selfpos):Angle()
		local pitch = math.AngleDifference(targetang.p,selfang.p)
		local yaw = math.AngleDifference(targetang.y,selfang.y)
		vehicle:SetPoseParameter(ppTurretPitch,-math.ApproachAngle(vehicle:GetPoseParameter(ppTurretPitch),pitch,AimRate) +ppTurretPitchAddition)
		vehicle:SetPoseParameter(ppTurretYaw,math.ApproachAngle(vehicle:GetPoseParameter(ppTurretYaw),yaw,AimRate))
	else
		local AimRate = chasisTurnSpeed

		local Angles = vehicle:WorldToLocalAngles( Aimang )

		if !IsValid(vehicle.LockTarget) then
			vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, Angles.y + ppTurretYawAddition, AimRate * FrameTime() ) or 0
			vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, Angles.p + ppTurretPitchAddition, AimRate * FrameTime() ) or 0
		else
			local tAng = (vehicle:GetPos() -vehicle.LockTarget:GetPos()):Angle()
			-- local tAng = Aimang -vehicle.LockTarget:GetAngles()
			vehicle.sm_pp_yaw = vehicle.sm_pp_yaw and math.ApproachAngle( vehicle.sm_pp_yaw, tAng.y + ppTurretYawAddition, AimRate * FrameTime() ) or 0
			vehicle.sm_pp_pitch = vehicle.sm_pp_pitch and math.ApproachAngle( vehicle.sm_pp_pitch, tAng.p + ppTurretPitchAddition, AimRate * FrameTime() ) or 0
		end

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
end

function simfphys.weapon:CanPrimaryAttack( vehicle )
	vehicle.NextShoot = vehicle.NextShoot or 0
	return vehicle.NextShoot < CurTime()
end

function simfphys.weapon:CanSecondaryAttack( vehicle )
	vehicle.NextShoot2 = vehicle.NextShoot2 or 0
	return vehicle.NextShoot2 < CurTime()
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
end

function simfphys.weapon:DoWheelSpin( vehicle )
	local spin_r = vehicle.VehicleData[ "spin_4" ] + vehicle.VehicleData[ "spin_6" ] /2
	local spin_l = vehicle.VehicleData[ "spin_3" ] + vehicle.VehicleData[ "spin_5" ] /2
	
	vehicle:SetPoseParameter("rWheels", -spin_r)
	vehicle:SetPoseParameter("lWheels", -spin_l )
	
	net.Start( "simfphys_update_tracks", true )
		net.WriteEntity( vehicle )
		net.WriteFloat( spin_r ) 
		net.WriteFloat( spin_l ) 
	net.Broadcast()
end