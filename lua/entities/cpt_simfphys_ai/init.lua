AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	-- self:SetModel("models/props_junk/garbage_glassbottle001a_chunk04.mdl")
	-- self:SetModel(self:GetOwner():GetModel())
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetSolidMask(MASK_NPCWORLDSTATIC)
	self:SetHealth(math.huge)
	self.ChasePosition = nil
	self:SetModelData()
	self:SetCustomCollisionCheck(true)
	self.HasInit = false
	self.FireVehicle = false
end

function ENT:SetModelData()
	-- if IsValid(self:GetOwner()) then
		-- if !IsValid(self:GetOwner():GetEnemy()) then return end
		-- local vel = self:GetOwner():GetVelocity():Length()
		-- self:GetOwner():GetPhysicsObject():SetVelocity(self:GetOwner():GetPhysicsObject():GetPos() -self:GetOwner():GetEnemy():GetPos())
		-- if vel > 0 then
			-- self.loco:SetDesiredSpeed(vel)
		-- end
		-- if self:GetOwner():GetPos():Distance(self:GetPos()) > vel *1.5 then
			-- self:SetPos(self:GetOwner():GetPos() +self:GetOwner():GetForward() *20)
		-- end
	-- end
end

function ENT:KeyDown(key)
	if key == IN_ATTACK then
		return self.FireVehicle
	end
	return false
end

function ENT:GetInfoNum(cvar,dvalue)
	return 1
end

function ENT:ChangeKey(key,value,veh,enemy)
	if value == true then
		if veh.PressedKeys[key] == false then
			veh.PressedKeys[key] = true
			veh.PressedKeys["Space"] = true
			timer.Simple(0.02,function()
				if IsValid(veh) then
					veh.PressedKeys["Space"] = false
				end
			end)
		end
	else
		if veh.PressedKeys[key] == true then
			veh.PressedKeys[key] = false
			veh.PressedKeys["Space"] = true
			timer.Simple(0.02,function()
				if IsValid(veh) then
					veh.PressedKeys["Space"] = false
				end
			end)
		end
	end
end

function ENT:Think()
	if self.HasInit && IsValid(self:GetOwner()) then
		local veh = self:GetOwner()
		if !IsValid(veh) then self:Remove() return end
		if GetConVarNumber("ai_disabled") == 1 then self:SetPos(veh:GetPos()) return end
		local enemy = veh:GetEnemy()
		if math.Round(self:GetVelocity():Length(),0) <= 50 then
			self.loco:SetDesiredSpeed(200)
		else
			self.loco:SetDesiredSpeed(self:GetVelocity():Length() *1.3)
		end
		if self:GetPos():Distance(veh:GetPos()) > 800 then
			self:SetPos(veh:GetPos())
		end
		if !IsValid(enemy) then
			for _,v in ipairs(ents.GetAll()) do
				if v:IsVehicle() then self:DetectVehicles(v,veh) end
				if v:IsPlayer() then self:DetectPlayers(v,veh) end
			end
		end
		self:HandleKeys(veh,self)
	end
end

function ENT:DetectVehicles(v,veh)
	if v == veh || v:GetParent() == veh then return end
	if (v:IsVehicle() && v:GetNWInt("bwii_team") == self.Team) then return end
	if v:IsVehicle() && !IsValid(v.Simfphys_AI) then return end
	veh:SetEnemy(v)
	veh:SetNWEntity("bwii_ent",v)
end

function ENT:DetectPlayers(v,veh)
	if v:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1 then return end
	if (v:IsPlayer() && v:lfsGetAITeam() == self.Team) then return end
	veh:SetEnemy(v)
	veh:SetNWEntity("bwii_ent",v)
end

function ENT:HandleKeys(veh,enemy)
	local left = 0
	local right = 0
	-- print(self:GetPos():Distance(veh:GetPos()))
	if self:GetPos():Distance(veh:GetPos()) <= 50 then return end
	-- if enemy:GetPos():Distance(veh:GetPos()) <= 200 then
		-- veh.PressedKeys["Space"] = true
		-- return
	-- else
		-- veh.PressedKeys["Space"] = false
	-- end
	if veh:IsFrontOfMe(enemy,90) then
		if veh:IsLeftOfMe(enemy,90) then
			-- veh.PressedKeys["A"] = true
			left = 1
		elseif !veh:IsLeftOfMe(enemy,90) then
			-- veh.PressedKeys["A"] = false
			left = 0
		elseif veh:IsRightOfMe(enemy,90) then
			-- veh.PressedKeys["D"] = true
			right = 1
		elseif !veh:IsRightOfMe(enemy,90) then
			-- veh.PressedKeys["D"] = false
			right = 0
		end
		veh.PressedKeys["W"] = true
	else
		veh.PressedKeys["W"] = false
	end
	if veh:IsBehindMe(enemy,90) then
		if veh:IsLeftOfMe(enemy,90) then
			-- veh.PressedKeys["D"] = true
			right = 1
		elseif !veh:IsLeftOfMe(enemy,90) then
			-- veh.PressedKeys["D"] = false
			right = 0
		elseif veh:IsRightOfMe(enemy,90) then
			-- veh.PressedKeys["A"] = true
			left = 1
		elseif !veh:IsRightOfMe(enemy,90) then
			-- veh.PressedKeys["A"] = false
			left = 0
		end
		veh.PressedKeys["S"] = true
	else
		veh.PressedKeys["S"] = false
	end
	veh:PlayerSteerVehicle(self,left,right)
end

function ENT:ChasePos(options,veh,enemy)
	if IsValid(veh) then
		if IsValid(enemy) then
			self.ChasePosition = enemy:GetPos()
			local path = Path("Chase")
			path:SetMinLookAheadDistance(options.lookahead or 300)
			path:SetGoalTolerance(options.goaltolerance or 20)
			path:Compute(self,self.ChasePosition)
			if !path:IsValid() then return end
			while path:IsValid() do
				if path:GetAge() > 0.1 then
					path:Compute(self,self.ChasePosition)
				end
				path:Update(self)
				if GetConVarNumber("simfphys_drawaipath") == 1 then path:Draw() end
				if self.loco:IsStuck() then
					self:HandleStuck()
					return
				end
				self:SetModelData()
				coroutine.yield()
			end
		end
	end
end

function ENT:RunBehaviour()
	while (true) do
		if IsValid(self) then
			if !self.HasInit then
				self.HasInit = true
				if IsValid(self:GetOwner()) then
					local veh = self:GetOwner()
					self.VehicleOwner = veh
					function veh:SetEnemy(entity)
						self.Enemy = entity
					end
					function veh:GetEnemy()
						self.Enemy = self.Enemy or NULL
						return self.Enemy
					end
					function veh:SetAI(ent)
						self.AI = ent
					end
					function veh:GetAI()
						self.AI = self.AI or NULL
						return self.AI
					end
					function veh:IsBehindMe(enemy,checkRadius)
						return !(self:GetForward():Dot(((enemy:GetPos() +enemy:OBBCenter()) -self:GetPos()):GetNormalized()) > math.cos(math.rad(checkRadius)))
					end
					function veh:IsFrontOfMe(enemy,checkRadius)
						return (self:GetForward():Dot(((enemy:GetPos() +enemy:OBBCenter()) -self:GetPos()):GetNormalized()) > math.cos(math.rad(checkRadius)))
					end
					function veh:IsLeftOfMe(enemy,checkRadius)
						return !(self:GetRight():Dot(((enemy:GetPos() +enemy:OBBCenter()) -self:GetPos()):GetNormalized()) > math.cos(math.rad(checkRadius)))
					end
					function veh:IsRightOfMe(enemy,checkRadius)
						return (self:GetRight():Dot(((enemy:GetPos() +enemy:OBBCenter()) -self:GetPos()):GetNormalized()) > math.cos(math.rad(checkRadius)))
					end
					veh:SetNWBool("bwii_AI",true)
					veh:SetActive(true)
					-- veh:SetDriver(self)
					veh:StartEngine()
					self.VehicleEntity = NULL
					self.VehicleFunc = NULL
					if simfphys then
						if simfphys.ManagedVehicles then
							for k,v in pairs(simfphys.ManagedVehicles) do
								if IsValid(v.entity) && v.entity == veh then
									self.VehicleEntity = v.entity
									self.VehicleFunc = v.func
									-- v.func:SetAI(self)
								end
							end
						end
					end
				end
			end
			if IsValid(self:GetOwner()) then
				local veh = self:GetOwner()
				local enemy = veh:GetEnemy()
				-- if !IsValid(enemy) then
					-- for _,v in ipairs(player.GetAll()) do
						-- veh:SetEnemy(v)
						-- print("Found " .. tostring(v))
					-- end
				-- end
				self:ChasePos({},veh,enemy)
				self:SetModelData()
			end
		end
		coroutine.yield()
	end
end

function ENT:HandleStuck()
	if IsValid(self) && self:GetOwner() && IsValid(self:GetOwner()) then
		self:SetPos(self:GetOwner():GetPos() +self:GetOwner():GetUp() *150)
	end
end

function ENT:OnRemove()
	if IsValid(self.VehicleOwner) then self.VehicleOwner:SetNWBool("bwii_AI",false) end
end

function ENT:OnKilled()
	self:Remove()
end