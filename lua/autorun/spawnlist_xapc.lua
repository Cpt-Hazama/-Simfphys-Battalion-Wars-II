local light_table = {
	L_HeadLampPos = Vector(52.64,31.71,48.82),
	L_HeadLampAng = Angle(0,0,0),
	R_HeadLampPos = Vector(52.64,-35.71,48.82),
	R_HeadLampAng = Angle(0,0,0),
	
	Headlight_sprites = { 
		Vector(52.64,31.71,48.82), -- L
		Vector(52.64,-35.71,48.82), -- R
		Vector(48.64,40.71,48.82), -- L
		Vector(48.64,-44.71,48.82), -- R
	},
	Headlamp_sprites = { 
		Vector(52.64,31.71,48.82), -- L
		Vector(52.64,-35.71,48.82), -- R
	},
}
list.Set( "simfphys_lights", "bwii_xapc", light_table)

local V = {
	Name = "APC",
	Model = "models/cpthazama/bwii/xylvania/apc.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Battalion Wars II",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = -180,

	Members = {
		Mass = 3000,
		AirFriction = 5,
		-- Inertia = Vector(25000,95000,2500),
		LightsTable = "bwii_xapc",
		
		OnSpawn = function(ent) ent:SetNWBool( "simfphys_NoRacingHud", true ) ent.OnTakeDamage = AVX.TankTakeDamage end,
		
		OnDestroyed = 
			function(ent)
				if IsValid( ent.Gib ) then
					local yaw = ent.sm_pp_yaw or 0
					local pitch = ent.sm_pp_pitch or 0
					ent.Gib:SetPoseParameter("turret_yaw", yaw )
					ent.Gib:SetPoseParameter("turret_pitch", pitch )
				end
			end,
		
		MaxHealth = BWII_HP_APC,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 25,
		RearWheelRadius = 25,
		
		EnginePos = Vector(-68.41,6.34,51.55),
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(37.6,32.06,36.5),
		CustomWheelPosFR = Vector(37.6,-32.06,36.5),
		CustomWheelPosRL = Vector(-42.55,31.9,36.5),
		CustomWheelPosRR = Vector(-42.55,-31.9,36.5),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 30,
		
		SeatOffset = Vector(20,-10,65),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
		
		PassengerSeats = {
			{
				pos = Vector(-5,-22,65),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-20,15,45),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-70.96,-1.82,55.9),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-92.33,-1.82,45.9),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(-49.31,21.26,55.9),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-49.31,-23.26,55.9),
				ang = Angle(0,180,0)
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
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 1,
		
		MaxGrip = 3900,
		Efficiency = 1,
		GripOffset = -300,
		BrakePower = 50,
		BulletProofTires = true,
		
		IdleRPM = 800,
		LimitRPM = 6000,
		PeakTorque = 100,
		PowerbandStart = 1500,
		PowerbandEnd = 6000,
		Turbocharged = false,
		Supercharged = false,
		DoNotStall = true,
		
		FuelFillPos = Vector(-73.19,6.55,44.65),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 100,
		
		PowerBias = -0.3,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "cpthazama/bwii/xylvania/VX_HTrans_Eng.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "cpthazama/bwii/xylvania/VX_HTrans_Eng.wav",
		Sound_MidPitch = 1.1,
		Sound_MidVolume = 2,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "cpthazama/bwii/xylvania/VX_HTrans_Eng.wav",
		Sound_HighPitch = 1.5,
		Sound_HighVolume = 2.5,
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
-- list.Set( "simfphys_vehicles", "bwii_xapc", V )