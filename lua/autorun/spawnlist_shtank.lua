local light_table = {
	L_HeadLampPos = Vector(17.85,-30.01,112.17),
	L_HeadLampAng = Angle(0,0,0),
	R_HeadLampPos = Vector(21.42,-20.26,111.43),
	R_HeadLampAng = Angle(0,0,0),
	
	Headlight_sprites = { 
		Vector(17.85,-30.01,112.17),
		Vector(21.42,-20.26,111.43),
	},
	Headlamp_sprites = { 
		Vector(17.85,-30.01,112.17),
		Vector(21.42,-20.26,111.43),
	},
	-- Rearlight_sprites = {
		-- Vector(-65.91,-31.77,39.61),
		-- Vector(-65.91,-31.77,39.61)
	-- },
	-- Brakelight_sprites = {
		-- Vector(-65.91,-36.09,39.61),
		-- Vector(-65.91,-36.09,39.61)
	-- }
}
list.Set( "simfphys_lights", "bwii_shtank", light_table)

local V = {
	Name = "Heavy Tank",
	Model = "models/cpthazama/bwii/solarempire/heavytank.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Battalion Wars II",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = -180,

	Members = {
		Mass = 18000,
		AirFriction = 20,
		-- Inertia = Vector(100000,80000,10000),
		-- LightsTable = "bwii_shtank",
		
		OnSpawn = function(ent)
			ent:SetNWBool("TurretSafeMode",false)
			ent:SetNWBool("SpecialCam_Loader",true)
			ent:SetNWBool("simfphys_NoRacingHud",true)
			ent.OnTakeDamage = AVX.TankTakeDamage
		end,
				
		OnDestroyed = 
			function(ent)
				if IsValid( ent.Gib ) then
					local yaw = ent.sm_pp_yaw or 0
					local pitch = ent.sm_pp_pitch or 0
					ent.Gib:SetPoseParameter("turret_yaw", yaw )
					ent.Gib:SetPoseParameter("turret_pitch", pitch )
				end
			end,
		
		MaxHealth = BWII_HP_HEAVYTANK,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 45,
		RearWheelRadius = 45,
		
		EnginePos = Vector(-83.62,0,47.19),
		
		CustomWheels = true,
		CustomSuspensionTravel = 0,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(115,55,38),
		CustomWheelPosFR = Vector(115,-55,38),
		CustomWheelPosML = Vector(5,75,38),
		CustomWheelPosMR = Vector(5,-75,38),
		CustomWheelPosRL = Vector(-110,75,38),
		CustomWheelPosRR = Vector(-110,-75,38),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(-25.74,0,75.92),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},

		
		-- PassengerSeats = {
			-- {
				-- pos = Vector(-13.81,101.62,66.21),
				-- ang = Angle(0,0,0)
			-- },
			-- {
				-- pos = Vector(-14.3,-101.83,66.21),
				-- ang = Angle(0,0,0)
			-- },
		-- },
		
		FrontHeight = 23,
		FrontConstant = 150000,
		FrontDamping = 1000,
		FrontRelativeDamping = 1000,
		
		RearHeight = 23,
		RearConstant = 150000,
		RearDamping = 1000,
		RearRelativeDamping = 1000,
		
		FastSteeringAngle = 14,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 6,
		
		MaxGrip = 850,
		Efficiency = 0.7,
		GripOffset = -300,
		BrakePower = 150,
		BulletProofTires = true,
		
		IdleRPM = 600,
		LimitRPM = 6000,
		PeakTorque = 240,
		PowerbandStart = 600,
		PowerbandEnd = 5500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(1.26,-64.49,84.18),
		FuelType = FUELTYPE_ELECTRIC,
		FuelTankSize = 500,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "cpthazama/bwii/solarempire/VS_HTank_Eng2.wav",
		Sound_IdlePitch = 1,
		Sound_IdleVolume = 1.2,
		
		Sound_Mid = "cpthazama/bwii/solarempire/VS_HTank_Eng1.wav",
		Sound_MidPitch = 0.8,
		Sound_MidVolume = 1.3,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "cpthazama/bwii/solarempire/VS_HTank_Eng1.wav",
		Sound_HighPitch = 0.8,
		Sound_HighVolume = 1.4,
		Sound_HighFadeInRPMpercent = 40,
		Sound_HighFadeInRate = 0.19,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		
		ForceTransmission = 1,
		
		DifferentialGear = 0.21,
		Gears = {-0.1,0,0.05,0.07,0.09,0.11,0.13}
	}
}
list.Set( "simfphys_vehicles", "bwii_shtank", V )