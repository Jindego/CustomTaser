hook.Add( "CalcView", "gstore_tased_view", function( ply, origin, angles, fov )
	if ( ply:GetNWBool( "gstore_tased" ) ) then
		local ragdoll = ply:GetNWEntity( "gstore_ragdoll_entity" )

		if ( not IsValid( ragdoll ) ) then return end
			
		local CamPos = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) )
			
		if ( not CamPos ) then return end

		local baseView = {
			origin = CamPos.Pos, 
			angles = CamPos.Ang, 
			fov = 90, 
			znear = 1
		}
			
		return baseView
	end
end )