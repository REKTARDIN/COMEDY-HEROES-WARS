LinkLuaModifier ("modifier_item_mirror_shield_passive", "items/item_mirror_shield.lua", LUA_MODIFIER_MOTION_NONE)

item_mirror_shield = class({})

function item_mirror_shield:GetIntrinsicModifierName() return "modifier_item_mirror_shield_passive" end

modifier_item_mirror_shield_passive = class({})

function modifier_item_mirror_shield_passive:IsHidden() return true end
function modifier_item_mirror_shield_passive:IsPurgable() return false end

function modifier_item_mirror_shield_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_AVOID_DAMAGE,
        MODIFIER_PROPERTY_DODGE_PROJECTILE 
    }
end

function modifier_item_mirror_shield_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("all_stats") end
function modifier_item_mirror_shield_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("all_stats") end
function modifier_item_mirror_shield_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("all_stats") end

function modifier_item_mirror_shield_passive:GetModifierAvoidDamage(params)
    if IsServer() then
        if RollPercentage(self:GetAbility():GetSpecialValueFor("reflect_chance")) then
            if self:GetAbility():IsCooldownReady() and params.target == self:GetParent() and params.attacker ~= self:GetParent() and params.attacker:IsBuilding() == false and params.attacker:IsRealHero() and self:GetParent():IsRealHero() then
                EmitSoundOn("Hero_Clinkz.Strafe", self:GetParent())

                local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_clinkz/clinkz_strafe_dodge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() );
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );
                ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );

                self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("block_cooldown"))
                
                return 1
            end
        end
    end

    return 0
end

function modifier_item_mirror_shield_passive:GetModifierDodgeProjectile(params)
    if IsServer() then
        if RollPercentage(self:GetAbility():GetSpecialValueFor("reflect_chance")) and self:GetAbility():IsCooldownReady() then
            EmitSoundOn("Hero_Clinkz.Strafe", self:GetParent())

            local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_clinkz/clinkz_strafe_dodge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() );
            ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );
            ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );

            self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("block_cooldown"))

            return 1
        end
    end

    return 0
end
