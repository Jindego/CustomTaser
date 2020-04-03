if ( CLIENT ) then
    SWEP.WepSelectIcon = surface.GetTextureID( "vgui/entities/weapon_taser" )
    SWEP.BounceWeaponIcon = false

    killicon.Add( "weapon_taser", "vgui/entities/killicon_taser", Color( 255, 255, 255, 255 ) )
end

SWEP.PrintName = "Taser"
SWEP.Author = "Skit"
SWEP.Purpose = "GMODSTORE"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true;

SWEP.HoldType  = "revolver"

SWEP.Primary.ClipSize = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Sound = "ced/taser/taser_shot.wav"

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Spawnable = true

SWEP.UseHands = true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Prongs = {}
SWEP.Deploying = false

function SWEP:Deploy()
    self:SetHoldType( self.HoldType )
    self:SendWeaponAnim( ACT_VM_DRAW )

    self.Owner:EmitSound( "ced/taser/taser_draw.wav" )

    self.Deploying = true
    timer.Simple( self.Owner:GetViewModel():SequenceDuration(), function()
        if ( IsValid( self ) ) then
            self.Deploying = false
        end
    end )

    if ( SERVER ) then
        self.ShootPos = ents.Create( "prop_physics" )
        self.ShootPos:SetModel( "models/props_lab/tpplug.mdl" )
        self.ShootPos:SetNoDraw( true )
        self.ShootPos:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
        self.ShootPos:Spawn()
		
        if ( not self.Owner:Crouching() ) then
			self.ShootPos:SetPos( self:GetBonePosition( self:LookupBone( "ValveBiped.Bip01_R_Hand" ) ) )
		else
			self.ShootPos:SetPos( self:GetBonePosition( self:LookupBone( "ValveBiped.Bip01_R_Hand" ) ) )
		end
		
		local range = GetConVar( "taser_range" ):GetFloat() or 450
		for _, p in pairs( self.Prongs ) do
			self.Cable = constraint.Rope( self.ShootPos, p, 0, 0, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), range, 0, 0, 0.25, "cable/cable2", false )
			self.Cable2 = constraint.Rope( self.ShootPos, p, 0, 0, Vector( 0, 0, -1 ), Vector( 0, 0, 0 ), range, 0, 0, 0.25, "cable/cable2", false )
		end
    end

    return true
end

function SWEP:Holster()
    if ( SERVER ) then
		for _, p in pairs( self.Prongs ) do
			if ( not IsValid( p.Target ) and IsValid( p ) ) then
				p:Remove()
				table.RemoveByValue( self.Prongs, p )
			end
		end
	
        if ( IsValid( self.ShootPos ) ) then
            self.ShootPos:Remove()
        end

        if ( IsValid( self.Cable ) and IsValid( self.Cable2 ) ) then
            self.Cable:Remove()
            self.Cable2:Remove()
        end
    end

    return true
end

function SWEP:Think()
    if ( SERVER and IsValid( self.ShootPos ) ) then
        if ( not self.Owner:Crouching() ) then
			self.ShootPos:SetPos( self:GetBonePosition( self:LookupBone( "ValveBiped.Bip01_R_Hand" ) ) )
		else
			self.ShootPos:SetPos( self:GetBonePosition( self:LookupBone( "ValveBiped.Bip01_R_Hand" ) ) )
		end

        self.ShootPos:SetAngles( Angle( 0, 0, 0 ) )
    elseif ( SERVER ) then
        self.ShootPos = ents.Create( "prop_physics" )
        self.ShootPos:SetModel( "models/props_lab/tpplug.mdl" )
        self.ShootPos:SetNoDraw( true )
        self.ShootPos:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		
        if ( not self.Owner:Crouching() ) then
			self.ShootPos:SetPos( self:GetBonePosition( self:LookupBone( "ValveBiped.Bip01_R_Hand" ) ) )
		else
			self.ShootPos:SetPos( self:GetBonePosition( self:LookupBone( "ValveBiped.Bip01_R_Hand" ) ) )
		end
		
        self.ShootPos:Spawn()
		
		local range = GetConVar( "taser_range" ):GetFloat() or 450
		for _, p in pairs( self.Prongs ) do
			self.Cable = constraint.Rope( self.ShootPos, p, 0, 0, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), range, 0, 0, 0.25, "cable/cable2", false )
			self.Cable2 = constraint.Rope( self.ShootPos, p, 0, 0, Vector( 0, 0, -1 ), Vector( 0, 0, 0 ), range, 0, 0, 0.25, "cable/cable2", false )
		end
    end
end

function SWEP:PrimaryAttack()
    if ( self.Deploying ) then return false end
	
	self:ShootEffects()

    if ( SERVER ) then
        self.Owner:EmitSound( self.Primary.Sound )

        local tr = self.Owner:GetEyeTrace()

        self.Prong = ents.Create( "taser_prong" )
        self.Prong:SetAngles( self.Owner:EyeAngles() )
        self.Prong:SetPos( self.Owner:GetShootPos() )
        self.Prong:SetAngles( self.Owner:EyeAngles() )
        self.Prong.Owner = self.Owner
        self.Prong:Spawn()

        table.insert( self.Prongs, #self.Prongs + 1, self.Prong )

        local phys = self.Prong:GetPhysicsObject()
        local range = GetConVar( "taser_range" ):GetFloat() or 450
        phys:ApplyForceCenter( self.Owner:GetAimVector():GetNormalized() * math.pow( tr.HitPos:Length(), 8 ) )

        self.Cable = constraint.Rope( self.ShootPos, self.Prong, 0, 0, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ), range, 0, 0, 0.25, "cable/cable2", false )
        self.Cable2 = constraint.Rope( self.ShootPos, self.Prong, 0, 0, Vector( 0, 0, -1 ), Vector( 0, 0, 0 ), range, 0, 0, 0.25, "cable/cable2", false )
    
		self:SetNextPrimaryFire( CurTime() + ( GetConVar( "taser_delay" ):GetFloat() or 7 ) )
	end
end

function SWEP:SecondaryAttack()
    if ( self.Prongs == nil ) then return end

    for _, p in pairs( self.Prongs ) do
        if ( IsValid( p.Target ) ) then
            p.Target:TakeDamage( GetConVar( "taser_damage" ):GetFloat() or 0.5, self.Owner, self )
        end
    end

    self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:ShootEffects()
    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetTexture( self.WepSelectIcon )

	y = y + 10
	x = x + 30
	wide = wide - 20

	surface.DrawTexturedRect( x , y , ( wide / 1.35 ), ( wide / 1.35 ) )

	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end