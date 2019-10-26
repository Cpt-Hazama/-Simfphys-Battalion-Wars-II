
local Materials = {
	"particle/smokesprites_0001",
	"particle/smokesprites_0002",
	"particle/smokesprites_0003",
	"particle/smokesprites_0004",
	"particle/smokesprites_0005",
	"particle/smokesprites_0006",
	"particle/smokesprites_0007",
	"particle/smokesprites_0008",
	"particle/smokesprites_0009",
	"particle/smokesprites_0010",
	"particle/smokesprites_0011",
	"particle/smokesprites_0012",
	"particle/smokesprites_0013",
	"particle/smokesprites_0014",
	"particle/smokesprites_0015",
	"particle/smokesprites_0016"
}
function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	self:Explosion( Pos )
	sound.Play("cpthazama/bwii/bomb_explode" .. math.random(1,2) .. ".wav", Pos, 100, 100, 1 )
end

function EFFECT:Explosion( pos )
	local emitter = ParticleEmitter( pos, false )
	
	for i = 0,60 do
		local particle = emitter:Add( Materials[math.random(1,table.Count( Materials ))], pos )
		
		if particle then
			particle:SetVelocity( VectorRand() * 800 )
			particle:SetDieTime( math.Rand(0.8,1.6) )
			particle:SetAirResistance( math.Rand(200,600) ) 
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( math.Rand(20,60) )
			particle:SetEndSize( math.Rand(80,140) )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor(70,63,45)
			particle:SetGravity( Vector( 0, 0, 100 ) )
			particle:SetCollide( false )
		end
	end

	for i = 0,math.random(1,2) do
		local particle = emitter:Add("effects/splashwake3", pos )
		
		if particle then
			particle:SetVelocity(  VectorRand() * 500 )
			particle:SetDieTime(math.Rand(0.2,0.5))
			particle:SetAirResistance( math.Rand(200,600) ) 
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( math.Rand(40,50) )
			particle:SetEndSize( math.Rand(100,200) )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor( 255,255,255 )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			particle:SetCollide( false )
		end
	end
	
	for i = 0, 40 do
		local particle = emitter:Add( "sprites/flamelet"..math.random(1,5), pos )
		
		if particle then
			particle:SetVelocity( VectorRand() * 1000 )
			particle:SetDieTime( 0.14 )
			particle:SetStartAlpha( 255 )
			particle:SetStartSize( 10 )
			particle:SetEndSize( math.Rand(60,120) )
			particle:SetEndAlpha( 100 )
			particle:SetRoll( math.Rand( -1, 1 ) )
			particle:SetColor( 255,175,0 )
			particle:SetCollide( false )
		end
	end
	
	emitter:Finish()
	
	local dlight = DynamicLight( math.random(0,9999) )
	if dlight then
		dlight.pos = pos
		dlight.r = 255
		dlight.g = 180
		dlight.b = 100
		dlight.brightness = 8
		dlight.Decay = 2000
		dlight.Size = 300
		dlight.DieTime = CurTime() + 0.1
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
