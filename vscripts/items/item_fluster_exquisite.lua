LinkLuaModifier("modifier_item_fluster_exquisite_passive", "items/item_fluster_exquisite.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_fluster_exquisite_passive_aura_dummy", "items/item_fluster_exquisite.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_fluster_exquisite_passive_aura_buff", "items/item_fluster_exquisite.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_fluster_exquisite_blast_debuff", "items/item_fluster_exquisite.lua", LUA_MODIFIER_MOTION_NONE)

item_fluster_exquisite = class({})

function item_fluster_exquisite:GetIntrinsicModifierName()
    return "modifier_item_fluster_exquisite_passive"
end

function item_fluster_exquisite:OnSpellStart()
    if IsServer() then
        local radius = self:GetSpecialValueFor("blast_radius")
        local duration = self:GetSpecialValueFor("blast_debuff")
        local damage = self:GetSpecialValueFor("blast_damage")

        local units = FindUnitsInRadius(
            self:GetCaster():GetTeam(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        EmitSoundOn("Hero_Grimstroke.InkSwell.Stun", self:GetCaster())

        local nFXIndex = ParticleManager:CreateParticle( "particles/stygian/fluster_blast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:SetParticleControl( nFXIndex, 2, Vector(radius, radius, radius) )
        ParticleManager:SetParticleControl( nFXIndex, 4, self:GetCaster():GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        AddFOWViewer(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), radius, 1.0, false)

        for i, unit in pairs(units) do
            ApplyDamage(
                {
                    victim = unit,
                    attacker = self:GetCaster(),
                    damage = damage,
                    damage_type = DAMAGE_TYPE_PURE,
                    ability = self
                }
            )

            unit:Purge(true, false, false, false, false)

            unit:AddNewModifier(
                self:GetCaster(),
                self,
                "modifier_truesight",
                {duration = self:GetSpecialValueFor("blast_debuff_duration")}
            )

            unit:AddNewModifier(
                self:GetCaster(),
                self,
                "modifier_item_shivas_guard_blast",
                {duration = self:GetSpecialValueFor("blast_debuff_duration")})

        end
    end
end

--------------------------------------------------------------------------------
modifier_item_fluster_exquisite_passive = class({})

function modifier_item_fluster_exquisite_passive:IsHidden()
    return true
end

function modifier_item_fluster_exquisite_passive:IsPurgable()
    return false
end

function modifier_item_fluster_exquisite_passive:IsPermanent()
    return true
end

function modifier_item_fluster_exquisite_passive:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_fluster_exquisite_passive:RemoveOnDeath()
    return false
end

function modifier_item_fluster_exquisite_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function modifier_item_fluster_exquisite_passive:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_fluster_exquisite_passive:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_fluster_exquisite_passive:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_fluster_exquisite_passive:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_fluster_exquisite_passive:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed_ptc")
end

function modifier_item_fluster_exquisite_passive:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_fluster_exquisite_passive:IsAura()
    return true
end

function modifier_item_fluster_exquisite_passive:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_fluster_exquisite_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_item_fluster_exquisite_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_fluster_exquisite_passive:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_fluster_exquisite_passive:GetModifierAura()
    return "modifier_item_fluster_exquisite_passive_aura_dummy"
end


modifier_item_fluster_exquisite_passive_aura_dummy = class({})

function modifier_item_fluster_exquisite_passive_aura_dummy:IsPurgable()
    return false
end

function modifier_item_fluster_exquisite_passive_aura_dummy:IsHidden()
    return true
end

function modifier_item_fluster_exquisite_passive_aura_dummy:OnCreated()
    if IsServer() then
        if self:GetAbility():GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() and self:GetParent():IsRealHero() then
            self:GetParent():AddNewModifier(
                self:GetAbility():GetCaster(),
                self:GetAbility(),
                "modifier_item_fluster_exquisite_passive_aura_buff",
                nil
            )
        else
            if self:GetParent():GetTeamNumber() ~= self:GetAbility():GetCaster():GetTeamNumber() then
                self:GetParent():AddNewModifier(
                self:GetAbility():GetCaster(),
                self:GetAbility(),
                "modifier_item_shivas_guard_aura",
                nil
                )
            end
        end
    end
end

function modifier_item_fluster_exquisite_passive_aura_dummy:OnDestroy()
    if IsServer() then
        if self:GetAbility():GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
            self:GetParent():RemoveModifierByName("modifier_item_fluster_exquisite_passive_aura_buff")

        else

            if self:GetParent():GetTeamNumber() ~= self:GetAbility():GetCaster():GetTeamNumber() then
                self:GetParent():RemoveModifierByName("modifier_item_shivas_guard_aura")
            end
        end
    end
end

modifier_item_fluster_exquisite_passive_aura_buff = class({})

function modifier_item_fluster_exquisite_passive_aura_buff:IsPurgable()
    return false
end

function modifier_item_fluster_exquisite_passive_aura_buff:GetTexture ()
    return self:GetAbility():GetAbilityTextureName()
end

function modifier_item_fluster_exquisite_passive_aura_buff:GetTexture()
    return "custom/item_fluster"
end

function modifier_item_fluster_exquisite_passive_aura_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE}
end


function modifier_item_fluster_exquisite_passive_aura_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_fluster_exquisite_passive_aura_buff:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_item_fluster_exquisite_passive_aura_buff:OnTakeDamage( params )
    if params.attacker ~= self:GetParent() and not params.unit:IsBuilding() and params.unit:GetTeamNumber() == self:GetAbility():GetCaster():GetTeamNumber() then
        if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and params.attacker:HasModifier("modifier_item_fluster_exquisite_passive_aura_dummy") and params.attacker:GetTeamNumber() ~= self:GetAbility():GetCaster():GetTeamNumber() and params.damage <= self:GetParent():GetHealth() then

            self.aura_heal = self:GetAbility():GetSpecialValueFor("aura_dmg_heal_ptc")

            self:GetParent():Heal(params.damage * self.aura_heal * 0.01, params.attacker)

            self.lifesteal_pfx = ParticleManager:CreateParticle("particles/stygian/bloodletter_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, self:GetParent():GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
        end
    end
end

modifier_item_fluster_exquisite_blast_debuff = class({})

function modifier_item_fluster_exquisite_blast_debuff:IsPurgable()
    return true
end

function modifier_item_fluster_exquisite_blast_debuff:IsDebuff()
    return true
end

function modifier_item_fluster_exquisite_blast_debuff:GetTexture ()
    return self:GetAbility():GetAbilityTextureName()
end

function modifier_item_fluster_exquisite_blast_debuff:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_item_fluster_exquisite_blast_debuff:GetModifierMoveSpeedBonus_Percentage (params)
    return self:GetAbility():GetSpecialValueFor("blast_slow")
end



