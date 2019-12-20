local light_table = {
	L_HeadLampPos = Vector(128.3,36.37,39.58),
	L_HeadLampAng = Angle(0,0,0),
	R_HeadLampPos = Vector(126.56,-37.04,38.9),
	R_HeadLampAng = Angle(0,0,0),
	
	Headlight_sprites = {
		Vector(128.3,36.37,39.58), -- L
		Vector(125.97,49.28,37.69), -- LSmall
		Vector(126.56,-37.04,38.9), -- R
		Vector(126.31,-49.5,37.29), -- RSmall
	},
	Headlamp_sprites = { 
		Vector(95.68,51.5,63.17), -- LBig
		Vector(94.28,-50.66,62.49), -- RBig
		Vector(128.3,36.37,39.58), -- L
		Vector(125.97,49.28,37.69), -- LSmall
		Vector(126.56,-37.04,38.9), -- R
		Vector(126.31,-49.5,37.29), -- RSmall
	},
	Brakelight_sprites = {
		Vector(-129.19,35.25,65.5),
		Vector(-130.13,-34.71,65.5)
	}
}
list.Set( "simfphys_lights", "bwii_wartillery", light_table)

local V = {
	Name = "Artillery",
	Model = "models/cpthazama/bwii/westernfrontier/artillery.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Battalion Wars II",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = -180,

	Members = {
		Mass = 16500,
		AirFriction = 5,
		-- Inertia = Vector(100000,80000,10000),
		LightsTable = "bwii_wartillery",
		
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
					ent.Gib:SetPoseParameter("turret_pitch", pitch )
				end
			end,
		
		MaxHealth = BWII_HP_ARTILLERY,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 40,
		RearWheelRadius = 40,
		
		EnginePos = Vector(92.51,0.23,71.68),
		
		CustomWheels = true,
		CustomSuspensionTravel = 1,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(86.580032348633,51.419860839844,32.83984375),
		CustomWheelPosFR = Vector(86.579696655273,-51.030120849609,32.8408203125),
		CustomWheelPosML = Vector(3.71004486084,51.420001983643,32.83984375),
		CustomWheelPosMR = Vector(3.709735870361,-51.030059814453,32.8408203125),
		CustomWheelPosRL = Vector(-84.33024597168,51.029689788818,32.08984375),
		CustomWheelPosRR = Vector(-84.33024597168,-51.029689788818,32.08984375),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(-32,-42,87),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
		
		PassengerSeats = {
			{
				pos = Vector(-20,-40.47,50.08),
				ang = Angle(0,180,0)
			},
			{
				pos = Vector(27.52,-57.73,52.27),
				ang = Angle(0,180,0)
			}
		},
		
		FrontHeight = 20,
		FrontConstant = 150000,
		FrontDamping = 1000,
		FrontRelativeDamping = 1000,
		
		RearHeight = 20,
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
		FuelTankSize = 80,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "cpthazama/bwii/angloisles/VA_Artillery_Eng1.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "cpthazama/bwii/angloisles/VA_Artillery_Eng1.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "cpthazama/bwii/angloisles/VA_Artillery_Eng1.wav",
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
list.Set( "simfphys_vehicles", "bwii_wartillery", V )