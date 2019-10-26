local V = {
	Name = "Artillery",
	Model = "models/cpthazama/bwii/xylvania/artillery.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Battalion Wars II",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = -180,

	Members = {
		Mass = 15000,
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
		
		MaxHealth = BWII_HP_ARTILLERY,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 30,
		RearWheelRadius = 30,
		
		EnginePos = Vector(-9.97,-17.44,93.83),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(125.84973144531,48.389747619629,30.290405273438),
		CustomWheelPosFR = Vector(125.84973144531,-48.389747619629,30.290405273438),
		CustomWheelPosML = Vector(11,53.490116119385,30.290405273438),
		CustomWheelPosMR = Vector(11,-53.490116119385,30.290405273438),
		CustomWheelPosRL = Vector(-114.63017272949,51.120929718018,30.289306640625),
		CustomWheelPosRR = Vector(-114.63017272949,-51.120929718018,30.289306640625),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(-110,0,125),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
		
		PassengerSeats = {
			{
				pos = Vector(0,0,0),
				ang = Angle(0,0,0)
			},
		},
		
		FrontHeight = 23,
		FrontConstant = 150000,
		FrontDamping = 1000,
		FrontRelativeDamping = 1000,
		
		RearHeight = 23,
		RearConstant = 150000,
		RearDamping = 1000,
		RearRelativeDamping = 1000,
		
		FastSteeringAngle = 5,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 2,
		
		MaxGrip = 850,
		Efficiency = 0.7,
		GripOffset = -300,
		BrakePower = 150,
		BulletProofTires = true,
		
		IdleRPM = 400,
		LimitRPM = 3000,
		PeakTorque = 140,
		PowerbandStart = 400,
		PowerbandEnd = 2500,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(1.26,-64.49,84.18),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 200,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "cpthazama/bwii/xylvania/VX_HTrans_Eng.wav",
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
list.Set( "simfphys_vehicles", "bwii_xartillery", V )