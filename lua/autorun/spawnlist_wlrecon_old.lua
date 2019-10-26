local light_table = {
	L_HeadLampPos = Vector(55.35,12.11,35.89),
	L_HeadLampAng = Angle(0,0,0),
	R_HeadLampPos = Vector(55.13,-12.02,35.94),
	R_HeadLampAng = Angle(0,0,0),
	
	Headlight_sprites = { 
		Vector(55.13,12.02,35.94),
		Vector(55.13,-12.02,35.94)
	},
	Headlamp_sprites = { 
		Vector(55.13,12.02,35.94),
		Vector(55.13,-12.02,35.94)
	},
	Rearlight_sprites = {
		Vector(51.59,17.44,34.7),
		Vector(51.59,-17.44,34.7),
		Vector(-31.68,22.06,36.07),
		Vector(-31.68,-22.06,36.07)
	},
	Brakelight_sprites = {
		Vector(-31.68,22.06,36.07),
		Vector(-31.68,-22.06,36.07)
	}
}
list.Set( "simfphys_lights", "wlrecon_old", light_table)

local V = {
	Name = "Light Recon Mk I",
	Model = "models/cpthazama/bwii/westernfrontier/lightrecon.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Battalion Wars II",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = -180,

	Members = {
		Mass = 2250,
		AirFriction = 5,
		-- Inertia = Vector(25000,95000,2500),
		LightsTable = "wlrecon_old",
		
		OnSpawn = function(ent) ent:SetNWBool( "simfphys_NoRacingHud", true ) ent.OnTakeDamage = AVX.TankTakeDamage end,
		
		OnDestroyed = 
			function(ent)
				if IsValid( ent.Gib ) then
					local yaw = ent.sm_pp_yaw or 0
					local pitch = ent.sm_pp_pitch or 0
					ent.Gib:SetPoseParameter("driver_yaw", yaw )
					ent.Gib:SetPoseParameter("driver_pitch", pitch )
				end
			end,
		
		MaxHealth = BWII_HP_LIGHTRECON,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 25,
		RearWheelRadius = 25,
		
		EnginePos = Vector(41.35,0,38.19),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(37.6,32.06,37.5),
		CustomWheelPosFR = Vector(37.6,-32.06,37.5),
		CustomWheelPosRL = Vector(-42.55,31.9,37.5),
		CustomWheelPosRR = Vector(-42.55,-31.9,37.5),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 30,
		
		SeatOffset = Vector(4,0,53),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
			
		ExhaustPositions = {
			{
				pos = Vector(-32.85,21.59,49.56),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-32.85,21.59,49.56),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-32.85,21.59,49.56),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-32.85,-21.59,49.56),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-32.85,-21.59,49.56),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-32.85,-21.59,49.56),
				ang = Angle(0,0,0)
			},
		},

		PassengerSeats = {
			{
				pos = Vector(-22,0,27),
				ang = Angle(0,90,0)
			},
		},
		
		FrontHeight = 25,
		FrontConstant = 50000,
		FrontDamping = 3000,
		FrontRelativeDamping = 3000,
		
		RearHeight = 25,
		RearConstant = 50000,
		RearDamping = 3000,
		RearRelativeDamping = 3000,
		
		FastSteeringAngle = 9,
		SteeringFadeFastSpeed = 200,
		
		TurnSpeed = 15,
		
		MaxGrip = 7500,
		Efficiency = 1,
		GripOffset = -500,
		BrakePower = 50,
		BulletProofTires = true,
		
		IdleRPM = 800,
		LimitRPM = 7500,
		PeakTorque = 70,
		PowerbandStart = 1500,
		PowerbandEnd = 7500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-73.19,6.55,44.65),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 75,
		
		PowerBias = -0.3,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "common/null.wav",
		Sound_IdlePitch = 1.4,
		Sound_IdleVolume = 0.9,
		
		Sound_Mid = "cpthazama/bwii/westernfrontier/VW_Recon_Eng.wav",
		Sound_MidPitch = 1.1,
		Sound_MidVolume = 2,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "cpthazama/bwii/westernfrontier/VW_Recon_Eng.wav",
		Sound_HighPitch = 1.5,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 58,
		Sound_HighFadeInRate = 0.19,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.3,
		Gears = {-0.1,0,0.1,0.2,0.3}
	}
}
list.Set( "simfphys_vehicles", "bwii_wlrecon_old", V )