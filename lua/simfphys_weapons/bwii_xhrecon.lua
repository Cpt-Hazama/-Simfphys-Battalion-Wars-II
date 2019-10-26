	-- Variables --
local class = "bwii_xhrecon"
local icon = "entities/bwii_xhrecon.png"
local name = "Heavy Recon"
local TEAM = TEAM_XYLVANIA
local driverFPPos = Vector(0,-15,12)
local driverTPPos = Vector(15,0,40)
local driverFollowerAttachment = true
local crosshairDirection = Vector(0,90,0)
local gunnerFPPos = Vector(0,0,2)
local gunnerTPPos = Vector(0,0,0)
local gunnerFollowerAttachment = false

local groundCheckDistance = 170
local centerVector = Vector(0,0,50)

local reloadTime = 0.0825

local ppTurretYaw = "driver_yaw"
local ppTurretPitch = "driver_pitch"
local chasisTurnSpeed = 300
local ppTurretYawAddition = 0
local ppTurretPitchAddition = -5
local reverseChasisYaw = false
local reverseChasisPitch = true

local muzzleEffect = "xltank_muzzle"
local mainForceOnVehicle = 800000
local mainDMG = 500
local mainForce = 10000
local mainEffectSize = 7
local mainRadius = 200
local mainRadiusDMG = 25

local secondaryAttachment = "muzzleTurret"
local secondaryCooldown = 0.1
local ppSideTurretYaw = "turret_yaw"
local ppSideTurretPitch = "turret_pitch"

	-- Code --
local tblSuspensionData = {
	"lwheel",
	"rwheel",
	"lbwheel",
	"rbwheel",
}

function simfphys.weapon:Initialize( vehicle )
	-- net.Start( "avx_misc_register_tank_custom" )
		-- net.WriteEntity( vehicle )
		-- net.WriteString( class )
	-- net.Broadcast()
	vehicle:SetNWInt("bwii_icon",icon)
	vehicle:SetNWInt("bwii_name",name); vehicle:SetNWFloat("SpecialCam_LoaderTime",reloadTime)
	
	-- vehicle:SetNWInt("bwii_hpmax",vehicle:GetMaxHealth())
	-- vehicle:SetNWInt("bwii_hp",vehicle:GetCurHealth())
	
	vehicle.LockTarget = NULL
	vehicle.NextGasTime = CurTime()

	simfphys.RegisterCrosshair( vehicle:GetDriverSeat(), { Direction = crosshairDirection, Type = 3 } )
	simfphys.RegisterCamera( vehicle:GetDriverSeat(), driverFPPos, driverTPPos, driverFollowerAttachment, nil )

	if not istable( vehicle.PassengerSeats ) or not istable( vehicle.pSeat ) then return end

	simfphys.RegisterCrosshair( vehicle.pSeat[1] , { Attachment = secondaryAttachment, Type = 1 } )
	simfphys.RegisterCamera( vehicle.pSeat[1], gunnerFPPos, gunnerTPPos, false, nil )

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
	
	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 9500, shootOrigin )
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
	
	vehicle:GetPhysicsObject():ApplyForceOffset( -shootDirection * 18500, shootOrigin )
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
			vehicle.track_snd = CreateSound( vehicle, "cpthazama/bwii/xylvania/VX_HTrans_Eng.wav" )
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
	
	-- vehicle:SetNWInt("bwii_hp",vehicle:GetCurHealth())
	
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
	-- self:ControlTrackSounds( vehicle, handbrake )
	self:ModPhysics( vehicle, handbrake )
end

function simfphys.weapon:PrimaryAttack( vehicle, ply, shootOrigin, Attachment, HE )
	if not self:CanPrimaryAttack( vehicle ) then return end
	local effectdata = EffectData()
	effectdata:SetOrigin( shootOrigin )
	effectdata:SetAngles( Attachment.Ang )
	effectdata:SetEntity( vehicle )
	effectdata:SetAttachment( 1 )
	effectdata:SetScale( 3 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )
	primary_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward() )
	self:SetNextPrimaryFire( vehicle, CurTime() + reloadTime )
end

function simfphys.weapon:SecondaryAttack( vehicle, ply, shootOrigin, Attachment, ID )
	
	if not self:CanSecondaryAttack( vehicle ) then return end
	
	local effectdata = EffectData()
	effectdata:SetOrigin( shootOrigin )
	effectdata:SetAngles( Attachment.Ang )
	effectdata:SetEntity( vehicle )
	effectdata:SetAttachment( 2 )
	effectdata:SetScale( 3 )
	util.Effect( "CS_MuzzleFlash_X", effectdata, true, true )
	
	secondary_fire( ply, vehicle, shootOrigin, Attachment.Ang:Forward() )
	
	self:SetNextSecondaryFire( vehicle, CurTime() + reloadTime )
end

function simfphys.weapon:AimMachinegun( ply, vehicle, pod )	
	if not IsValid( pod ) then return end

	local EyeAngles = pod:WorldToLocalAngles( ply:EyeAngles() )
	EyeAngles:RotateAroundAxis(EyeAngles:Up(),180)
	local Yaw = math.Clamp(EyeAngles.y,-180,180)
	local Pitch = math.Clamp(EyeAngles.x,-30,90)
	
	-- local ang = pod:GetAngles()
	-- pod:SetAngles(Angle(ang.x,EyeAngles.y,ang.z))
	
	-- pod:SetAngles(Angle(0,Yaw +90,0))

	vehicle:SetPoseParameter(ppSideTurretYaw, Yaw +90 )
	vehicle:SetPoseParameter(ppSideTurretPitch, Pitch )
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
				if (ent:IsNPC() || ent:IsPlayer() || (ent:IsVehicle() && ent != vehicle)) then
					vehicle.LockTarget = ent
				end
			end
		end
	else
		vehicle.LockTarget = NULL
	end

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
	
	for i = 1,#tblSuspensionData do
		local name = tblSuspensionData[i]
		local bone
		if name == "lwheel" then
			bone = 7
		elseif name == "rwheel" then
			bone = 5
		elseif name == "lbwheel" then
			bone = 8
		elseif name == "rbwheel" then
			bone = 6
		end
		local pos,ang = vehicle:GetBonePosition(bone)
		
		local trace = util.TraceHull( {
			start = pos,
			endpos = pos +vehicle:GetUp() *-50,
			maxs = Vector(15,15,0),
			mins = -Vector(15,15,0),
			filter = vehicle.filterEntities,
		} )
		-- local Dist = (pos - trace.HitPos):Length()
		local Dist = pos:Distance(trace.HitPos) /4
		local inAir = false
		local pp = Dist
		
		if trace.Hit then
			vehicle.susOnGround = true
		end
		
		-- vehicle.oldDist[i] = vehicle.oldDist[i] and (vehicle.oldDist[i] + math.Clamp(Dist - vehicle.oldDist[i],-5,5)) or 0

		-- vehicle.oldDist[i] = math.Clamp(vehicle.oldDist[i], -5, math.huge)
		if Dist > 7 then
			inAir = true
		end
		if inAir then
			pp = -Dist
		end
		vehicle:SetPoseParameter(name .. "_sus",math.Clamp(pp,-5,5))
	end
end

function simfphys.weapon:DoWheelSpin( vehicle )
	local spin_r = vehicle.VehicleData[ "spin_4" ] + vehicle.VehicleData[ "spin_6" ] /2
	local spin_l = vehicle.VehicleData[ "spin_3" ] + vehicle.VehicleData[ "spin_5" ] /2
	local turn = vehicle:GetVehicleSteer() -- -1 or 1
	local lwheel = 7
	local rwheel = 5
	-- local turnR = Angle(0,turn *20,0)

	-- vehicle:ManipulateBoneAngles(lwheel,turnR)
	-- vehicle:ManipulateBoneAngles(rwheel,turnR)

	vehicle:SetPoseParameter("rwheel", -spin_r)
	vehicle:SetPoseParameter("rbwheel", -spin_r)
	vehicle:SetPoseParameter("lwheel", -spin_l )
	vehicle:SetPoseParameter("lbwheel", -spin_l )
	
	net.Start( "simfphys_update_tracks", true )
		net.WriteEntity( vehicle )
		net.WriteFloat( spin_r ) 
		net.WriteFloat( spin_l ) 
	net.Broadcast()
end