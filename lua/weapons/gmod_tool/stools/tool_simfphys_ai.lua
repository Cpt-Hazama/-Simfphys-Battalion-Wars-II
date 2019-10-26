TOOL.Category = "Simfphys"
TOOL.Name = "Spawn Tank AI"
TOOL.Command = nil
TOOL.ConfigName = ""
---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
	language.Add("tool.tool_simfphys_ai.name","Spawn Tank AI")
	language.Add("tool.tool_simfphys_ai.desc","Gives armed vehicles AI")
	language.Add("tool.tool_simfphys_ai.0","+attack to give AI | +attack2 to remove AI")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:LeftClick(tr)
	-- if CLIENT then return end
	if tr.Entity && tr.Entity:IsValid() && IsValid(tr.Entity) then
		local ent = tr.Entity
		if !ent:IsVehicle() then return end
		if ent:GetClass() == "gmod_sent_vehicle_fphysics_base" then
			if IsValid(ent.Simfphys_AI) then return end
			if CLIENT then return end
			local ai = ents.Create("cpt_simfphys_ai")
			ai:SetPos(ent:GetPos() +Vector(0,0,2))
			ai:SetAngles(ent:GetAngles())
			ai:SetModel(ent:GetModel())
			ai:SetOwner(ent)
			ai:Spawn()
			ai:SetOwner(ent)
			ai.Team = ent:GetNWInt("bwii_team")
			ent.Simfphys_AI = ai
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:RightClick(tr)
	-- if CLIENT then return end
	if tr.Entity && tr.Entity:IsValid() && IsValid(tr.Entity) && tr.Entity:IsNPC() then
		local ent = tr.Entity
		if !ent:IsNPC() then return end
		if IsValid(ent.Simfphys_AI) then
			ent.Simfphys_AI:Remove()
			ent:SetEnemy(NULL)
		end
	end
end