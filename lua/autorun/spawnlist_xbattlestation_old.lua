local V = {
	Name = "Battlestation Mk. I",
	Model = "models/cpthazama/bwii/xylvania/battlestation_classic.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Battalion Wars II",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = -180,

	Members = {
		Mass = 15000,
		AirFriction = 2,
		Inertia = Vector(100000,80000,15000),
		
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
		
		MaxHealth = BWII_HP_BATTLESTATION,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 45,
		RearWheelRadius = 45,
		
		EnginePos = Vector(-93.33,1.18,87.06),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(117.82,72.33,48),
		CustomWheelPosFR = Vector(117.82,-72.33,48),
		CustomWheelPosML = Vector(10.77,71.65,48),
		CustomWheelPosMR = Vector(10.77,-71.65,48),
		CustomWheelPosRL = Vector(-130.95,70.83,48),
		CustomWheelPosRR = Vector(-130.95,-70.83,48),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,10),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(0,0,100),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
			
		ExhaustPositions = {
			{
				pos = Vector(-33.59,2.92,108.24),
				ang = Angle(180,0,0)
			},
			{
				pos = Vector(-33.18,-7.57,108.15),
				ang = Angle(180,60,0)
			}
		},

		
		PassengerSeats = {
			{ -- LCannon
				pos = Vector(3.59,71.41,52.51),
				ang = Angle(0,-90,0)
			},
			{ -- RCannon
				pos = Vector(3.59,-71.41,52.51),
				ang = Angle(0,-90,0)
			},
			{ -- LTurret
				pos = Vector(-100,26,125),
				ang = Angle(0,0,0)
			},
			{ -- RTurret
				pos = Vector(-100,-26,125),
				ang = Angle(0,180,0)
			},
			{ -- CTurret
				pos = Vector(-155,0,125),
				ang = Angle(0,90,0)
			},
		},
		
		FrontHeight = 45,
		FrontConstant = 150000,
		FrontDamping = 1000,
		FrontRelativeDamping = 1000,
		
		RearHeight = 45,
		RearConstant = 150000,
		RearDamping = 1000,
		RearRelativeDamping = 1000,
		
		FastSteeringAngle = 14,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 1.45,
		
		MaxGrip = 1800,
		Efficiency = 2,
		GripOffset = -300,
		BrakePower = 150,
		BulletProofTires = true,
		
		IdleRPM = 300,
		LimitRPM = 4000,
		PeakTorque = 150,
		PowerbandStart = 300,
		PowerbandEnd = 1000,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-103.62,25.82,59.03),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 150,
		
		PowerBias = -0.5,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "cpthazama/bwii/westernfrontier/VW_Batt_Eng2.wav",
		Sound_IdleVolume = 1.3,
		Sound_IdlePitch = 1,
		
		Sound_Mid = "cpthazama/bwii/westernfrontier/VW_HTank_Eng.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1.3,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "cpthazama/bwii/westernfrontier/VW_HTrans_Eng.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 1.5,
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
list.Set( "simfphys_vehicles", "bwii_xbattlestation_old", V )