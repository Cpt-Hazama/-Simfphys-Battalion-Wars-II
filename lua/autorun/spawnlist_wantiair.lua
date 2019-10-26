local V = {
	Name = "Anti-Air",
	Model = "models/cpthazama/bwii/westernfrontier/antiair.mdl",
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
					ent.Gib:SetPoseParameter("driver_yaw", yaw )
					ent.Gib:SetPoseParameter("driver_pitch", pitch )
				end
			end,
		
		MaxHealth = BWII_HP_ANTIAIRVEH,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 20,
		RearWheelRadius = 20,
		
		EnginePos = Vector(-45.45,0,65.65),
		
		CustomWheels = true,
		CustomSuspensionTravel = 1,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(52.29,48.93,28),
		CustomWheelPosFR = Vector(52.29,-48.93,28),
		CustomWheelPosML = Vector(1.9,48.93,28),
		CustomWheelPosMR = Vector(1.9,-48.93,28),
		CustomWheelPosRL = Vector(-48.23,48.93,28),
		CustomWheelPosRR = Vector(-48.23,-48.93,28),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(-2,0,92.3),
		SeatPitch = 25,
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
				pos = Vector(44.82,40.44,82.86),
				ang = Angle(0,-90,0)
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
		
		Sound_Idle = "common/null.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "cpthazama/bwii/westernfrontier/VW_LTank_Eng.wav",
		Sound_MidPitch = 1.1,
		Sound_MidVolume = 2,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "cpthazama/bwii/westernfrontier/VW_LTank_Eng.wav",
		Sound_HighPitch = 1.5,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 58,
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
list.Set( "simfphys_vehicles", "bwii_wantiair", V )