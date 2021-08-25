if not item_fractured_cape then item_fractured_cape = class({}) end 

LinkLuaModifier ("modifier_item_fractured_cape_active", "items/item_fractured_cape.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_fractured_cape", "items/item_fractured_cape.lua", LUA_MODIFIER_MOTION_NONE)

function item_fractured_cape:GetIntrinsicModifierName()
    return "modifier_item_fractured_cape"
end

function item_fractured_cape:OnSpellStart ()
    if IsServer() then 
        local hTarget = self:GetCursorTarget()
        if hTarget ~= nil then
            local duration = self:GetSpecialValueFor( "active_duration" )

            hTarget:Purge(false, true, false, true, false)

            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_item_fractured_cape_active", { duration = duration } )
            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_lycan_summon_wolves_invisibility", { duration = duration } )

            EmitSoundOn( "Hero_VoidSpirit.Pulse", hTarget )

            local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_totem_cast_ti6_combined.vpcf", PATTACH_CUSTOMORIGIN, nil );
            ParticleManager:SetParticleControl( nFXIndex, 0, hTarget:GetOrigin() );
            ParticleManager:ReleaseParticleIndex( nFXIndex );

            EmitSoundOn( "Hero_VoidSpirit.Pulse.Target", self:GetCaster() )
        end
    end
end

if modifier_item_fractured_cape_active == nil then modifier_item_fractured_cape_active = class({}) end

function modifier_item_fractured_cape_active:IsPurgable() return false end
function modifier_item_fractured_cape_active:IsHidden()  return false end

function modifier_item_fractured_cape_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }

    return funcs
end

function modifier_item_fractured_cape_active:GetModifierAvoidDamage(params)
    if RollPercentage(self:GetAbility():GetSpecialValueFor("active_chance")) then
        return 1
    end

    return 0
end

function modifier_item_fractured_cape_active:GetStatusEffectName()
    return "particles/status_fx/status_effect_combo_breaker.vpcf"
end

function modifier_item_fractured_cape_active:StatusEffectPriority()
    return 1000
end

function modifier_item_fractured_cape_active:GetEffectName ()
    return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end


if modifier_item_fractured_cape == nil then modifier_item_fractured_cape = class({}) end

function modifier_item_fractured_cape:IsHidden() return true end
function modifier_item_fractured_cape:IsPurgable() return false end
function modifier_item_fractured_cape:IsPermanent() return true end
function modifier_item_fractured_cape:DestroyOnExpire() return false end
function modifier_item_fractured_cape:GetAttributes () return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_item_fractured_cape:OnCreated( params )
    if IsServer() then
    end
end

function modifier_item_fractured_cape:OnDestroy()
    if IsServer() then
      
    end
end

function modifier_item_fractured_cape:IsCooldownReady()
   return self:GetRemainingTime() <= 0
end

function modifier_item_fractured_cape:StartCooldown(cd)
    return self:SetDuration(cd, false)
end

function modifier_item_fractured_cape:DeclareFunctions() 
    local funcs = {
	    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_AVOID_DAMAGE,
        MODIFIER_PROPERTY_DODGE_PROJECTILE 
    }

    return funcs
end

function modifier_item_fractured_cape:GetModifierAvoidDamage(params)
    if IsServer() then
        if self:IsCooldownReady() and params.target == self:GetParent() and params.attacker ~= self:GetParent() and params.attacker:IsBuilding() == false and params.attacker:IsRealHero() and self:GetParent():IsRealHero() then
            EmitSoundOn("Hero_Clinkz.Strafe", self:GetParent())

            local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_clinkz/clinkz_strafe_dodge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() );
            ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );
            ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );

            self:StartCooldown(3.5)
            
            return 1
        end
    end

    return 0
end

function modifier_item_fractured_cape:GetModifierDodgeProjectile(params)
    if IsServer() then
        if self:IsCooldownReady()  then
            EmitSoundOn("Hero_Clinkz.Strafe", self:GetParent())

            local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_clinkz/clinkz_strafe_dodge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() );
            ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );
            ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );

            self:StartCooldown(3.5)

            return 1
        end
    end

    return 0
end

function modifier_item_fractured_cape:GetModifierMagicalResistanceBonus( params ) return self:GetAbility():GetSpecialValueFor ("bonus_magic_resist" )  end
function modifier_item_fractured_cape:GetModifierAttackSpeedBonus_Constant( params ) return self:GetAbility():GetSpecialValueFor ("bonus_attack_speed" )  end
function modifier_item_fractured_cape:GetModifierPhysicalArmorBonus( params ) return self:GetAbility():GetSpecialValueFor ("bonus_armor" )  end
function modifier_item_fractured_cape:GetModifierBonusStats_Intellect( params ) return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )  end
function modifier_item_fractured_cape:GetModifierBonusStats_Strength( params )  return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )  end
function modifier_item_fractured_cape:GetModifierBonusStats_Agility( params ) return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) end
function modifier_item_fractured_cape:GetModifierManaBonus( params )  return self:GetAbility():GetSpecialValueFor( "bonus_mana" ) end
function modifier_item_fractured_cape:GetModifierConstantManaRegen( params )   return self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" )  end
