local V = {
	Name = "Anti-Air",
	Model = "models/cpthazama/bwii/xylvania/antiair.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Battalion Wars II",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = -180,

	Members = {
		Mass = 10000,
		AirFriction = 5,
		Inertia = Vector(100000,80000,10000),
		
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
		
		MaxHealth = BWII_HP_ANTIAIRVEH,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,50),
		
		FrontWheelRadius = 20,
		RearWheelRadius = 20,
		
		EnginePos = Vector(-37.95,6.61,49.41),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(90,55.77,20.66),
		CustomWheelPosFR = Vector(90,-55.77,20.66),
		CustomWheelPosML = Vector(13.53,55.77,20.66),
		CustomWheelPosMR = Vector(13.53,-55.77,20.66),
		CustomWheelPosRL = Vector(-40.72,55.77,23.66),
		CustomWheelPosRR = Vector(-40.72,-55.77,23.66),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(0,0,60),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
			
		ExhaustPositions = {
			{
				pos = Vector(-35,2.92,55),
				ang = Angle(180,0,0)
			},
		},

		
		PassengerSeats = {
			{
				pos = Vector(28,-7.5,50),
				ang = Angle(0,-90,-8)
			},
		},
		
		FrontHeight = 25,
		FrontConstant = 150000,
		FrontDamping = 1000,
		FrontRelativeDamping = 1000,
		
		RearHeight = 25,
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
		
		IdleRPM = 800,
		LimitRPM = 5000,
		PeakTorque = 300,
		PowerbandStart = 900,
		PowerbandEnd = 3500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-42.1,-3.44,44.09),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 150,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "cpthazama/bwii/xylvania/VX_LTank_Eng.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "cpthazama/bwii/xylvania/lighttank_eng1.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "cpthazama/bwii/xylvania/lighttank_eng2.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 1,
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
list.Set( "simfphys_vehicles", "bwii_xantiair", V )