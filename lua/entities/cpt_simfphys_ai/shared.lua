ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
ENT.PrintName = "Simfphys AI"
ENT.Author = "Cpt. Hazama"
ENT.Contact = "http://steamcommunity.com/id/cpthazama/" 
ENT.Purpose = ""
ENT.Instructions = ""
ENT.Information	= ""  
-- ENT.Category = "Simfphys"
ENT.AutomaticFrameAdvance = true

ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:PhysicsCollide(data,phys) end

function ENT:PhysicsUpdate(phys) end