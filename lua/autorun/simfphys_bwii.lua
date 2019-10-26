TEAM_ANGLO = 13
TEAM_FRONTIER = 14
TEAM_SOLAR = 15
TEAM_LEGION = 16
TEAM_TUNDRA = 17
TEAM_XYLVANIA = 18

BWII_RL_ANTIAIRVEH = 2
BWII_RL_ARTILLERY = 7
BWII_RL_BATTLESTATION = 5.75
BWII_RL_BATTLESHIP = 6
BWII_RL_DREADNOUGHT = 7
BWII_RL_SUBMARINE = 4
BWII_RL_FRIGATE = 4
BWII_RL_HEAVYTANK = 4
BWII_RL_LIGHTTANK = 3

BWII_HP_ANTIAIRVEH = 4400
BWII_HP_ARTILLERY = 4750
BWII_HP_APC = 3750
BWII_HP_BATTLESTATION = 22100
BWII_HP_HEAVYTANK = 7500
BWII_HP_LIGHTTANK = 4750
BWII_HP_HEAVYRECON = 3500
BWII_HP_RECON = 2000

BWII_HP_FRIGATE = 15000
BWII_HP_BATTLESHIP = 26000
BWII_HP_DREADNOUGHT = 30000
BWII_HP_SUBMARINE = 7500
BWII_HP_TRANSPORT = 12000

BWII_DMG_BATTLESHIP = 2375
BWII_DMG_DREADNOUGHT = 3750
BWII_DMG_SUBMARINE = 4000

BWII_DMG_ANTIAIRVEH = 600
BWII_DMG_ARTILLERY = 2375
BWII_DMG_BATTLESTATION = 3750
BWII_DMG_HEAVYTANK = 2100
BWII_DMG_LIGHTTANK = 1550
BWII_DMG_MG = 8
BWII_DMG_HMG = 18
BWII_DMG_AA = 80

hook.Add("CalcMainActivity", "bwii_customanimations", function(ply)
	local Ent = ply:GetSimfphys()

	if not IsValid(Ent) then return end	
	local Pod = ply:GetVehicle()
	if Pod:GetNWBool("BWII_StandTurret") then
		if ply.m_bWasNoclipping then 
			ply.m_bWasNoclipping = nil 
			ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM) 
			if CLIENT then 
				ply:SetIK(true)
			end 
		end 
		
		ply.CalcIdeal = ACT_HL2MP_IDLE_DUEL
		ply.CalcSeqOverride = ply:LookupSequence("idle_dual")
		return ply.CalcIdeal, ply.CalcSeqOverride
	elseif Pod:GetNWBool("BWII_Stand") then
		if ply.m_bWasNoclipping then 
			ply.m_bWasNoclipping = nil 
			ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM) 
			if CLIENT then 
				ply:SetIK(true)
			end 
		end 
		
		ply.CalcIdeal = ACT_STAND
		ply.CalcSeqOverride = ply:LookupSequence("idle_all_02")
		return ply.CalcIdeal, ply.CalcSeqOverride
	end
end)

if CLIENT then
local function simfphys_HUD_BWII()
	local ply = LocalPlayer()	
	if not IsValid( ply ) or not ply:Alive() then return end
	local pod = ply:GetVehicle()
	if not IsValid(pod) then return end
	local vehicle = ply:GetSimfphys()
	if not IsValid(vehicle) then return end
	-- if !string.find(vehicle:GetClass(),"bwii_") then return end
	if string.find(vehicle:GetModel(),"models/cpthazama/bwii/") then
		local icon = vehicle:GetNWString("bwii_icon")
		local name = vehicle:GetNWString("bwii_name")
		if icon == nil then return end
		if name == nil then return end
		local hp = vehicle:GetCurHealth()
		local maxhp = vehicle:GetMaxHealth()

		local iTeam = ply:lfsGetAITeam()
		local teamTexture
		local teamColor = {r=255,g=255,b=255}
		if iTeam == TEAM_ANGLO then
			teamTexture = "a"
			teamColor = {r=255,g=212,b=0}
		elseif iTeam == TEAM_FRONTIER then
			teamTexture = "w"
			teamColor = {r=30,g=230,b=0}
		elseif iTeam == TEAM_SOLAR then
			teamTexture = "s"
			teamColor = {r=218,g=218,b=218}
		elseif iTeam == TEAM_LEGION then
			teamTexture = "i"
			teamColor = {r=191,g=127,b=255}
		elseif iTeam == TEAM_TUNDRA then
			teamTexture = "t"
			teamColor = {r=230,g=0,b=0}
		elseif iTeam == TEAM_XYLVANIA then
			teamTexture = "x"
			teamColor = {r=100,g=170,b=255}
		else
			teamTexture = "s"
			teamColor = {r=255,g=255,b=255}
		end

		local text = name
		local posX = 535
		local posY = 1050
		local color = Color(225,255,225,255)
		draw.SimpleText(text,"Trebuchet24",posX,posY,color)

		-- local scale = 115
		-- local scaleB = 100
		-- local posX = 585
		-- local posY = 1043
		-- surface.SetMaterial(Material("bwii/hud_hp.png"))
		-- surface.SetDrawColor(100,170,255,255)
		-- surface.DrawTexturedRectRotated(posX,posY,scale,scaleB,0)

		local scale = 120
		local scaleB = 32
		local posX = 593
		local posY = 1037
		surface.SetMaterial(Material("bwii/hud_hp.png"))
		surface.SetDrawColor(teamColor.r,teamColor.g,teamColor.b,255)
		surface.DrawTexturedRectRotated(posX,posY,scale,scaleB,0)
		
		-- local scale = ((120 /maxhp) *hp)
		-- local scaleB = 95
		-- local posX = 622
		-- local posY = 996
		-- local posXB = 585
		-- local posYB = 1042
		-- surface.SetMaterial(Material("bwii/bar.vtf"))
		-- surface.SetDrawColor(255,170,0,255)
		-- surface.DrawTexturedRectRotated(posXB -scale *(1 -(hp /maxhp)) *0.5,posYB,scale,scaleB,0)

		local scale = ((120 /maxhp) *hp)
		local scaleB = 35
		local posXB = 593
		local posYB = 1037
		surface.SetMaterial(Material("bwii/bar.vtf"))
		surface.SetDrawColor(255,170,0,255)
		surface.DrawTexturedRectRotated(posXB -scale *(1 -(hp /maxhp)) *0.5,posYB,scale,scaleB,0)

		local scale = 100
		local scaleB = 70
		local posX = 595
		local posY = 985
		surface.SetMaterial(Material("bwii/" .. teamTexture .. "_plat.vtf"))
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(posX,posY,scale,scaleB,0)

		local scale = 120
		local posX = 591
		local posY = 945
		surface.SetMaterial(Material(icon))
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(posX,posY,scale,scale,0)
		
		if hp <= maxhp *0.4 then
			local scale = 85
			local posX = 591
			local posY = 945
			surface.SetMaterial(Material("bwii/enemy.png"))
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRectRotated(posX,posY,scale,scale,0)
		end
	end
end
hook.Add("HUDPaint","simfphys_HUD_BWII",simfphys_HUD_BWII)
end