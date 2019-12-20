AddCSLuaFile()

properties.Add("Add AI Driver", {
	MenuLabel = "#Add AI Driver",
	Order = 9999,
	MenuIcon = "icon16/bullet_add.png",

	Filter = function(self,ent,ply)
		if !IsValid(ent) then return false end
		if !ent:IsVehicle() then return false end
		if !ent:GetClass() == "gmod_sent_vehicle_fphysics_base" then return false end
		if !string.find(ent:GetModel(),"models/cpthazama/bwii/") then return false end
		-- if IsValid(ent.Simfphys_AI) then return false end
		return true
	end,
	Action = function(self,ent) -- CS
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	Receive = function(self,length,player) -- SV
		local ent = net.ReadEntity()
		if !self:Filter(ent,player) then return end
		if !IsValid(ent.Simfphys_AI) then
			local ai = ents.Create("cpt_simfphys_ai")
			ai:SetPos(ent:GetPos() +Vector(0,0,2))
			ai:SetAngles(ent:GetAngles())
			ai:SetModel(ent:GetModel())
			ai:SetOwner(ent)
			ai:Spawn()
			ai:SetOwner(ent)
			ai.Team = ent:GetNWInt("bwii_team")
			ent.Simfphys_AI = ai
		else
			player:ChatPrint("[BW] AI Driver already in vehicle!")
		end
	end
})

properties.Add("Remove AI Driver", {
	MenuLabel = "#Remove AI Driver",
	Order = 9999,
	MenuIcon = "icon16/bullet_delete.png",

	Filter = function(self,ent,ply)
		if !IsValid(ent) then return false end
		if !ent:IsVehicle() then return false end
		if !ent:GetClass() == "gmod_sent_vehicle_fphysics_base" then return false end
		if !string.find(ent:GetModel(),"models/cpthazama/bwii/") then return false end
		-- if !IsValid(ent.Simfphys_AI) then return false end
		return true
	end,
	Action = function(self,ent) -- CS
		self:MsgStart()
			net.WriteEntity(ent)
		self:MsgEnd()
	end,
	Receive = function(self,length,player) -- SV
		local ent = net.ReadEntity()
		if !self:Filter(ent,player) then return end
		if IsValid(ent.Simfphys_AI) then
			ent.Simfphys_AI:Remove()
			ent.Simfphys_AI = NULL
			ent:SetEnemy(NULL)
			ent:SetNWBool("bwii_AI",false)
			ent:SetActive(false)
		else
			player:ChatPrint("[BW] No AI Driver to remove!")
		end
	end
})