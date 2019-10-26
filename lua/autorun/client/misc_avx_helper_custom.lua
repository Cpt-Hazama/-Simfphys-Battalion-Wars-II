CreateConVar("simfphys_drawaipath","0",{FCVAR_NONE})

local function GetTrackPos( ent, div, smoother )
	local spin_left = ent.trackspin_l and (-ent.trackspin_l / div) or 0
	local spin_right = ent.trackspin_r and (-ent.trackspin_r / div) or 0

	ent.sm_TrackDelta_L = ent.sm_TrackDelta_L and (ent.sm_TrackDelta_L + (spin_left - ent.sm_TrackDelta_L) * smoother) or 0
	ent.sm_TrackDelta_R = ent.sm_TrackDelta_R and (ent.sm_TrackDelta_R + (spin_right- ent.sm_TrackDelta_R) * smoother) or 0

	return {Left = ent.sm_TrackDelta_L,Right = ent.sm_TrackDelta_R}
end

local function UpdateTrackScrollTexture( ent )
	local id = ent:EntIndex()

	if not ent.wheel_left_mat then
		local left_mat_table = {
			["$basetexture"] = ent.TrackTexture,
			["$alphatest"] = "1",
			["$translate"] = "[0.0 0.0 0.0]",
			["Proxies"] = {
				["TextureTransform"] = {
					["translateVar"] = "$translate",
					["centerVar"]    = "$center",
					["resultVar"]    = "$basetexturetransform",
					}
				}
			}
		if ent.TrackNormal then
			left_mat_table["$bumpmap"] = ent.TrackNormal
		end
		ent.wheel_left_mat = CreateMaterial(ent.TrackID .. "trackmat_" .. id .. "_left", "VertexLitGeneric", left_mat_table )
	end

	if not ent.wheel_right_mat then
		local right_mat_table = {
			["$basetexture"] = ent.TrackTexture,
			["$alphatest"] = "1",
			["$translate"] = "[0.0 0.0 0.0]",
			["Proxies"] = {
				["TextureTransform"] = {
					["translateVar"] = "$translate",
					["centerVar"]    = "$center",
					["resultVar"]    = "$basetexturetransform",
					}
				}
			}
		if ent.TrackNormal then
			right_mat_table["$bumpmap"] = ent.TrackNormal
		end
		ent.wheel_right_mat = CreateMaterial(ent.TrackID .. "trackmat_" .. id .. "_right", "VertexLitGeneric", right_mat_table )
	end

	local TrackPos = GetTrackPos( ent, ent.TrackDiv, ent.TrackMult )
	local trackArg = ent.TrackSlot

	if trackArg == 1 then
		ent.wheel_left_mat:SetVector("$translate", Vector(TrackPos.Left,0,0) )
		ent.wheel_right_mat:SetVector("$translate", Vector(TrackPos.Right,0,0) )
	elseif trackArg == 2 then
		ent.wheel_left_mat:SetVector("$translate", Vector(0,TrackPos.Left,0) )
		ent.wheel_right_mat:SetVector("$translate", Vector(0,TrackPos.Right,0) )
	elseif trackArg == 3 then
		ent.wheel_left_mat:SetVector("$translate", Vector(0,0,TrackPos.Left) )
		ent.wheel_right_mat:SetVector("$translate", Vector(0,0,TrackPos.Right) )
	end

	ent:SetSubMaterial( ent.LeftTrackSubMatIndex or 1, "!" .. ent.TrackID .. "trackmat_" .. id .. "_left" )
	ent:SetSubMaterial( ent.RightTrackSubMatIndex or 2, "!" .. ent.TrackID .. "trackmat_" .. id .. "_right" )
end

local function UpdateTracks()
	for i, ent in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) ) do
		if ent.TrackID then
			UpdateTrackScrollTexture(ent)
		end
	end
end

hook.Add( "Think", "avx_misc_manage_tanks_custom", function()
	UpdateTracks()
end )

AVX = AVX or {}

AVX.VehicleSettings = AVX.VehicleSettings or {}

net.Receive( "avx_misc_register_tank_custom", function( length )
	local ent = net.ReadEntity()
	local type = net.ReadString()

	if not IsValid( ent ) then return end

	local settings = AVX.VehicleSettings[type]

	ent.TrackID = settings.TrackID
	ent.TrackTexture = settings.TrackTexture
	ent.TrackNormal = settings.TrackNormal
	ent.TrackSlot = settings.TrackSlot
	ent.TrackDiv = settings.TrackDiv
	ent.TrackMult = settings.TrackMult
	ent.LeftTrackSubMatIndex = settings.LeftTrackSubMatIndex
	ent.RightTrackSubMatIndex = settings.RightTrackSubMatIndex
end)