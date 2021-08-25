loki_focal_strike = class({})

LinkLuaModifier( "modifier_loki_focal_strike", "abilities/loki_focal_strike.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_loki_focal_strike_armor_reduction", "abilities/loki_focal_strike.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function loki_focal_strike:OnSpellStart()
	local info = {
        EffectName = "particles/econ/items/templar_assassin/templar_assassin_focal/templar_assassin_meld_focal_attack.vpcf",
        Ability = self,
        iMoveSpeed = self:GetSpecialValueFor( "lance_speed" ),
        Source = self:GetCaster(),
        Target = self:GetCursorTarget(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }

    ProjectileManager:CreateTrackingProjectile( info )
    
    EmitSoundOn( "Hero_PhantomLancer.Concord.Throw", self:GetCaster() )
    
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_loki_focal_strike", {duration = self:GetSpecialValueFor("duration")})
    self:GetCaster():MoveToTargetToAttack(self:GetCursorTarget())

    local units = self:GetCaster():FindAllIllusions()
    if units ~= nil then
        if #units > 0 then
            for _, unit in pairs(units) do
                unit:AddNewModifier(self:GetCaster(), self, "modifier_loki_focal_strike", {duration = self:GetSpecialValueFor("duration")})
                unit:MoveToTargetToAttack(self:GetCursorTarget())
            end
        end
    end
end

--------------------------------------------------------------------------------

function loki_focal_strike:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
        EmitSoundOn( "Hero_PhantomLancer.Concord.Impact", self:GetCaster() )
        
		local damage = self:GetSpecialValueFor( "lance_damage" )
        local duration = self:GetSpecialValueFor( "duration" )

		ApplyDamage({
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self:GetSpecialValueFor( "lance_damage" ),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
        })
        
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_loki_focal_strike_armor_reduction", { duration = duration } )
	end

	return true
end

modifier_loki_focal_strike = class({})

modifier_loki_focal_strike.speed = 550

function modifier_loki_focal_strike:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn_illusion.vpcf"
end

function modifier_loki_focal_strike:GetEffectAttachType ()
    return PATTACH_ABSORIGIN
end

function modifier_loki_focal_strike:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
    }

    return funcs
end
function modifier_loki_focal_strike:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_loki_focal_strike:GetModifierMoveSpeed_Max( params )
    return self.speed
end

function modifier_loki_focal_strike:GetModifierMoveSpeed_Limit( params )
    return self.speed
end

function modifier_loki_focal_strike:GetModifierMoveSpeed_Absolute( params )
    return self.speed
end

function modifier_loki_focal_strike:IsHidden()
    return true
end

function modifier_loki_focal_strike:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end

modifier_loki_focal_strike_armor_reduction = class({})

function modifier_loki_focal_strike_armor_reduction:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

function modifier_loki_focal_strike_armor_reduction:GetModifierPhysicalArmorBonus( params )
    return self:GetAbility():GetSpecialValueFor( "armor_reduction" )
end
