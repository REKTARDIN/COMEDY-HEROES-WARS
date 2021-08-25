venom_hook = class({})

LinkLuaModifier("modifier_venom_hook_slowing", "abilities/venom_hook.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venom_hook_movement", "abilities/venom_hook.lua", LUA_MODIFIER_MOTION_NONE)

local SPEED = 3000
local PROJ_SPEED = 3000

--------------------------------------------------------------------------------

function venom_hook:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", context )
	PrecacheResource( "particle", "particles/heroes/hero_venom/venom_hook.vpcf", context )
end

function venom_hook:OnSpellStart()
    local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
    vDirection.z = 0
    vDirection = vDirection:Normalized()
    
    local flCastRange = self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster())

	local info = {
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self:GetSpecialValueFor( "radius" ),
		fEndRadius = self:GetSpecialValueFor( "radius" ),
		vVelocity = vDirection * PROJ_SPEED,
		fDistance = self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() ),
        Source = self:GetCaster(),
        bDeleteOnHit = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	}

    self.proj = ProjectileManager:CreateLinearProjectile( info )

    self.vHookOffset = Vector( 0, 0, 96 )
    self.vTargetPosition = self:GetCaster():GetOrigin() + vDirection * flCastRange
    
    local vHookTarget = self.vTargetPosition + self.vHookOffset
    local vKillswitch = Vector( ( ( flCastRange / SPEED ) ), 0, 0 )
    
    self.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/heroes/hero_venom/venom_hook.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleAlwaysSimulate( self.nChainParticleFXIndex )
	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster():GetOrigin() + self.vHookOffset, true )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 3, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 6, Vector( SPEED, flCastRange, 64 ) )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControlEnt( self.nChainParticleFXIndex, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true )
    
	EmitSoundOn( "Hero_Bristleback.ViscousGoo.Cast" , self:GetCaster() )
end

--------------------------------------------------------------------------------

function venom_hook:OnProjectileThink_ExtraData(vLocation, data)
    if IsServer() then
        if self.nChainParticleFXIndex then
            ParticleManager:SetParticleControl( self.nChainParticleFXIndex, 3, (vLocation + Vector(0, 0, 64)))
        end

        if GridNav:IsNearbyTree(vLocation, 64, false) and self.proj then
            ProjectileManager:DestroyLinearProjectile(self.proj)
            self.proj = nil

            local kv = {pos_x = vLocation.x, pos_y = vLocation.y, pos_z = vLocation.z}

            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_venom_hook_movement", kv)

            EmitSoundOnLocationWithCaster(vLocation, "Hero_Bristleback.ViscousGoo.Target" , self:GetCaster() )

            ---GridNav:DestroyTreesAroundPoint(vLocation, 64, false)

            if self.nChainParticleFXIndex then
                ParticleManager:DestroyParticle(self.nChainParticleFXIndex, true)
                self.nChainParticleFXIndex = nil
            end
        end
    end
end

function venom_hook:OnProjectileHit_ExtraData(hTarget, vLocation, data)
    if hTarget ~= nil then
        local point = self:GetCaster():GetAbsOrigin() + (hTarget:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized() * ((hTarget:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() / 2)
        local kv = {pos_x = point.x, pos_y = point.y, pos_z = point.z}

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_venom_hook_movement", kv)
        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_venom_hook_movement", kv)

        EmitSoundOnLocationWithCaster(vLocation, "Hero_Bristleback.ViscousGoo.Target" , self:GetCaster() )

        local damage = {
            victim = hTarget,
            attacker = self:GetCaster(),
            damage = self:GetSpecialValueFor("damage"),
            damage_type = DAMAGE_TYPE_PURE,
            ability = self
        }

        ApplyDamage( damage )

        if self.proj then
            ProjectileManager:DestroyLinearProjectile(self.proj)
        end
        if self.nChainParticleFXIndex then
            ParticleManager:DestroyParticle(self.nChainParticleFXIndex, true)
            self.nChainParticleFXIndex = nil
        end
    else
        if self.nChainParticleFXIndex then
            ParticleManager:DestroyParticle(self.nChainParticleFXIndex, true)
            self.nChainParticleFXIndex = nil
        end 
    end

	return false
end

modifier_venom_hook_movement = class({})
--------------------------------------------------------------------------------

function modifier_venom_hook_movement:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_venom_hook_movement:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_venom_hook_movement:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_venom_hook_movement:OnCreated( kv )
	if IsServer() then
        self.vStartPosition = self:GetParent():GetAbsOrigin()
        self.vEndPosition = Vector(kv.pos_x, kv.pos_y, kv.pos_z)

        self:StartIntervalThink(FrameTime())
        
		self.speed = SPEED

		if not self:GetParent():IsAlive() then
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

function modifier_venom_hook_movement:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_venom_hook_movement:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function modifier_venom_hook_movement:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end

function modifier_venom_hook_movement:OnDestroy()
	if IsServer() then
        FindClearSpaceForUnit( self:GetParent(), self:GetParent():GetAbsOrigin(), false )
        
        if self:GetCaster():IsFriendly(self:GetParent()) then
        else
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")}) 
            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_venom_hook_slowing", {duration = self:GetAbility():GetSpecialValueFor("slowing_duration")}) 
        end
	end
end

function modifier_venom_hook_movement:OnIntervalThink()
	if IsServer() then
        local distance = (self.vEndPosition  - self:GetParent():GetAbsOrigin()):Length2D()
        local direction = (self.vEndPosition - self:GetParent():GetAbsOrigin()):Normalized()

        if distance > 128 then
      		self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin() + direction * SPEED * FrameTime())
    	else
    		self:Destroy()
    	end
	end
end



if modifier_venom_hook_slowing == nil then modifier_venom_hook_slowing = class({}) end

--------------------------------------------------------------------------------

function modifier_venom_hook_slowing:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_venom_hook_slowing:RemoveOnDeath()
	return true
end

function modifier_venom_hook_slowing:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_venom_hook_slowing:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slowing")
end

function modifier_venom_hook_slowing:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end