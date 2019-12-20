local light_table = {
	L_HeadLampPos = Vector(-20.69,27.14,376.64),
	L_HeadLampAng = Angle(0,0,0),
	R_HeadLampPos = Vector(-19.64,-20.51,376.95),
	R_HeadLampAng = Angle(0,0,0),
	
	Headlight_sprites = { 
		Vector(-20.69,27.14,376.64),
		Vector(-19.64,-20.51,376.95),
		Vector(-17.67,30.01,365.65),
		Vector(-19.29,-23.98,365.63),
	},
	Headlamp_sprites = { 
		Vector(-20.69,27.14,376.64),
		Vector(-19.64,-20.51,376.95),
		Vector(-17.67,30.01,365.65),
		Vector(-19.29,-23.98,365.63),
	},
}
list.Set( "simfphys_lights", "bwii_xbattleship", light_table)

local V = {
	Name = "Battleship",
	Model = "models/cpthazama/bwii/xylvania/battleship.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Battalion Wars II",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = -180,

	Members = {
		Mass = 25000,
		AirFriction = 5,
		StrengthenSuspension = false,
		-- Inertia = Vector(100000,80000,10000),
		LightsTable = "bwii_xbattleship",
		
		OnSpawn = function(ent)
			ent:SetNWBool("TurretSafeMode",false)
			ent:SetNWBool("SpecialCam_Loader",true)
			ent:SetNWBool("simfphys_NoRacingHud",true)
			ent.OnTakeDamage = AVX.TankTakeDamage
		end,
		
		OnTick = function(ent)
			
		end,
		
		OnDestroyed = 
			function(ent)
				if IsValid( ent.Gib ) then
					local gib = ent.Gib
					if ent:WaterLevel() > 0 then
						for i = 1,math.random(2,5) do
							local effectdata = EffectData()
							effectdata:SetOrigin(gib:GetPos() +gib:GetRight() *math.Rand(-80,80) +gib:GetUp() *math.Rand(-125,125) +gib:GetRight() *math.Rand(-125,125))
							util.Effect( "simfphys_explosion", effectdata )
						end
						local ship = ents.Create("prop_dynamic")
						ship:SetModel(gib:GetModel())
						ship:SetPos(ent:GetPos())
						ship:SetAngles(ent:GetAngles())
						ship:Spawn()
						ship:SetPoseParameter("turret_yaw",ent:GetPoseParameter("turret_yaw"))
						ship:SetPoseParameter("turret_pitch",ent:GetPoseParameter("turret_pitch"))
						ship:SetColor(Color(72,72,72))
						ship:ResetSequence("sink")
						ship:SetPlaybackRate(0.3)
						ship:EmitSound("cpthazama/bwii/DE_Vehicle_S_"..math.random(1,2)..".wav",150,100)
						timer.Simple(ship:SequenceDuration(ship:LookupSequence("sink")) /ship:GetPlaybackRate(),function()
							if IsValid(ship) then
								ship:Remove()
							end
						end)
						gib:Remove()
					else
						gib:SetPoseParameter("turret_yaw",ent:GetPoseParameter("turret_yaw"))
						gib:SetPoseParameter("turret_pitch",ent:GetPoseParameter("turret_pitch"))
					end
				end
			end,
		
		MaxHealth = BWII_HP_BATTLESHIP,
		
		IsArmored = true,
		
		NoWheelGibs = true,
		
		FirstPersonViewPos = Vector(0,0,0),
		
		FrontWheelRadius = 5,
		RearWheelRadius = 5,
		
		EnginePos = Vector(-9.97,-17.44,93.83),
		
		CustomWheels = true,
		CustomSuspensionTravel = 1,
		
		CustomWheelModel = "models/props_c17/canisterchunk01g.mdl",
		
		CustomWheelPosFL = Vector(150,120,5),
		CustomWheelPosFR = Vector(-150,120,5),
		CustomWheelPosRL = Vector(150,-120,5),
		CustomWheelPosRR = Vector(-150,-120,5),
		CustomWheelAngleOffset = Angle(0,0,90),
		
		CustomMassCenter = Vector(0,0,0),
		
		CustomSteerAngle = 60,
		
		SeatOffset = Vector(-15,-2,298.49),
		SeatPitch = 0,
		SeatYaw = 90,
		
		ModelInfo = {
			WheelColor = Color(0,0,0,0),
		},
			
		ExhaustPositions = {
			{
				pos = Vector(-113.28,2.66,290.53),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-157.26,2.55,271.68),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-197.22,3.02,251.13),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-113.28,2.66,290.53),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-157.26,2.55,271.68),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-197.22,3.02,251.13),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-113.28,2.66,290.53),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-157.26,2.55,271.68),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-197.22,3.02,251.13),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-113.28,2.66,290.53),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-157.26,2.55,271.68),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-197.22,3.02,251.13),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-113.28,2.66,290.53),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-157.26,2.55,271.68),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-197.22,3.02,251.13),
				ang = Angle(0,0,0)
			},
		},

		
		PassengerSeats = {
			{
				pos = Vector(-41.1,58.04,215.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(-41.1,-58.04,215.5),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,185),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,185),
				ang = Angle(0,0,0)
			},
			{
				pos = Vector(0,0,185),
				ang = Angle(0,90,0)
			},
		},
		
		FrontHeight = 6,
		FrontWheelMass = 200,
		FrontConstant = 35000,
		FrontDamping = 3500,
		FrontRelativeDamping = 2500,

		RearHeight = 6, 
		RearWheelMass = 200,
		RearConstant = 35000,
		RearDamping = 3500,
		RearRelativeDamping = 2500,

		FastSteeringAngle = 2,
		SteeringFadeFastSpeed = 535,

		TurnSpeed = 1,

		MaxGrip = 1,
		Efficiency = 1,
		GripOffset = -3,
		BrakePower = 50, 

		IdleRPM = 200, 
		LimitRPM = 1000, 
		Revlimiter = false, 
		PeakTorque = 450, 
		PowerbandStart = 200,
		PowerbandEnd = 1200,
		Turbocharged = false, 
		Supercharged = false, 
		Backfire = false, 
		
		FuelFillPos = Vector(1.26,-64.49,84.18),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 150,
		
		PowerBias = 1,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "cpthazama/bwii/xylvania/VNX_BShip_Eng2.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "cpthazama/bwii/xylvania/VNX_BShip_Eng1.wav",
		Sound_MidPitch = 1,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 58,
		Sound_MidFadeOutRate = 0.476,
		
		Sound_High = "cpthazama/bwii/xylvania/VNX_BShip_Eng1.wav",
		Sound_HighPitch = 1,
		Sound_HighVolume = 1,
		Sound_HighFadeInRPMpercent = 40,
		Sound_HighFadeInRate = 0.19,
		
		Sound_Throttle = "",
		Sound_ThrottlePitch = 0,
		Sound_ThrottleVolume = 0,
		
		snd_horn = "common/null.wav",
		
		-- ForceTransmission = 1,
		
		DifferentialGear = 0.4,
		Gears = {-0.2,0,0.1} 
	}
}
list.Set( "simfphys_vehicles", "bwii_xbattleship", V )