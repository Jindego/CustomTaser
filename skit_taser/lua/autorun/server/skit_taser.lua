CreateConVar( "taser_duration", "5", FCVAR_NONE, "The stun duration of the taser." )
CreateConVar( "taser_damage", "0", FCVAR_NONE, "The damage of the taser." )
CreateConVar( "taser_delay", "5", FCVAR_NONE, "The delay of each shot." )
CreateConVar( "taser_range", "150", FCVAR_NONE, "The range of the taser." )

hook.Add( "PhysgunPickup", "gstore_disable_when_tased", function( _, ent )
    if ( ent:GetNWBool( "gstore_tased" ) ) then return false end
end )

hook.Add( "EntityTakeDamage", "gstore_ragdoll_damage", function( ent, data )
    if ( ent:GetClass() == "prop_ragdoll" and ent.OwnerEnt != nil ) then
        if ( data:GetAttacker():GetClass() == "worldspawn" and IsValid( ent.OwnerEnt ) ) then
            ent.OwnerEnt:TakeDamage( data:GetDamage() / 12, data:GetAttacker(), data:GetInflictor() )
        elseif ( IsValid( ent.OwnerEnt ) ) then
            ent.OwnerEnt:TakeDamage( data:GetDamage(), data:GetAttacker(), data:GetInflictor() )
        end
    end
end )

hook.Add( "Think", "gstore_tased_entity_pos", function()
    for _, ent in pairs( ents.GetAll() ) do
        if ( ent:GetNWBool( "gstore_tased" ) and IsValid( ent:GetNWEntity( "gstore_ragdoll_entity" ) ) ) then
            ent:SetVelocity( Vector( 0, 0, 0 ) )
            ent:SetPos( ent:GetNWEntity( "gstore_ragdoll_entity" ):GetPos() )
        end
    end
end )

hook.Add( "PlayerSpawn", "gstore_remove_tased_ragdoll", function( ply )
    if ( IsValid( ply:GetNWEntity( "gstore_ragdoll_entity" ) ) ) then
        ply:GetNWEntity( "gstore_ragdoll_entity" ):Remove()
        ply:SetNWEntity( "gstore_ragdoll_entity", nil )
    end
	
	if ( ply:GetNWBool( "gstore_tased" ) ) then
		ply:Freeze( false )
		ply:SetNWBool( "gstore_tased", false )
	end
end )

hook.Add( "PlayerSwitchWeapon", "gstore_prevent_switch_when_tased", function(ply)
    if ( ply:GetNWBool( "gstore_tased" ) ) then
        return true
    end
end )

hook.Add( "PostPlayerDeath", "gstore_remove_ragdoll", function( ply )
	if ( ply:GetNWBool( "gstore_tased" ) ) then
		ply:GetRagdollEntity():Remove()
	end
end ) 

hook.Add( "PlayerDisconnected", "gstore_remove_tased_ragdoll", function( ply )
	if ( IsValid( ply:GetNWEntity( "gstore_ragdoll_entity" ) ) ) then
        ply:GetNWEntity( "gstore_ragdoll_entity" ):Remove()
        ply:SetNWEntity( "gstore_ragdoll_entity", nil )
    end
end )

hook.Add( "Shutdown", "gstore_remove_tased_ragdoll", function()
	for _, ply in pairs( player.GetAll() ) do
		if ( IsValid( ply:GetNWEntity( "gstore_ragdoll_entity" ) ) ) then
			ply:GetNWEntity( "gstore_ragdoll_entity" ):Remove()
			ply:SetNWEntity( "gstore_ragdoll_entity", nil )
		end
	end
end )