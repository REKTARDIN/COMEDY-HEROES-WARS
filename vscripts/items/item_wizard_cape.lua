LinkLuaModifier( "modifier_item_wizard_cape", "items/item_wizard_cape.lua", LUA_MODIFIER_MOTION_NONE )

if item_wizard_cape == nil then item_wizard_cape = class({}) end

function item_wizard_cape:GetIntrinsicModifierName()
    return "modifier_item_wizard_cape"
end

function item_wizard_cape:OnSpellStart()
    if IsServer() then
        local radius = self:GetSpecialValueFor("debuff_radius")
        local duration = self:GetSpecialValueFor("resist_debuff_duration")
        local vLoc = self:GetCursorPosition()

        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(),
            vLoc,
            self:GetCaster(),
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
            0,
            false )

        if #units > 0 then
            for _, unit in pairs(units) do
                unit:AddNewModifier( self:GetCaster(), self, "modifier_item_veil_of_discord_debuff", { duration = duration } )
            end
        end

        local nFXIndex = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl( nFXIndex, 0, vLoc )
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(self:GetSpecialValueFor("debuff_radius"), self:GetSpecialValueFor("debuff_radius"), 1) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        EmitSoundOn( "Hero_KeeperOfTheLight.SolarBind.Target", self:GetCaster() )

    end
end

if modifier_item_wizard_cape == nil then
    modifier_item_wizard_cape = class({})
end

function modifier_item_wizard_cape:IsHidden()
    return true
end

function modifier_item_wizard_cape:IsPurgable()
    return false
end


function modifier_item_wizard_cape:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS
    }

    return funcs
end

function modifier_item_wizard_cape:IsAura()
    return true
end

function modifier_item_wizard_cape:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_wizard_cape:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_wizard_cape:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_wizard_cape:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_wizard_cape:GetModifierAura()
    return "modifier_item_ring_of_basilius_effect"
end

function modifier_item_wizard_cape:OnTakeDamage( params )
    if IsServer() then
        if self:GetCaster() == nil then
            return 0
        end

        if self:GetCaster():PassivesDisabled() then
            return 0
        end

        if self:GetCaster() ~= self:GetParent() then
            return 0
        end

        if not params.inflictor then
            return 0
        end

        local hAttacker = params.attacker
        local hVictim = params.unit
        local fDamage = params.damage

        if hVictim ~= nil and hAttacker ~= nil and hAttacker == self:GetCaster() and hAttacker:GetTeamNumber() ~= hVictim:GetTeamNumber() then
            if params.damage_type > 1 then
                local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hVictim:GetOrigin(), hVictim, self:GetAbility():GetSpecialValueFor("splash_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
                if #units > 0 then
                    for _,unit in pairs(units) do
                        pcall(function()
                            if unit ~= hVictim then
                                ParticleManager:CreateParticle("particles/econ/events/ti7/shivas_guard_impact_ti7_splash.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)

                                ApplyDamage ( {
                                    victim = unit,
                                    attacker = self:GetParent(),
                                    damage = fDamage * (self:GetAbility():GetSpecialValueFor("magical_splash") / 100),
                                    damage_type = DAMAGE_TYPE_PURE,
                                    ability = self:GetAbility(),
                                    damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_HPLOSS,
                                })
                            end
                        end)
                    end
                end
            end
        end
    end

    return 0
end
function modifier_item_wizard_cape:GetModifierConstantManaRegen( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" )
end

function modifier_item_wizard_cape:GetModifierBonusStats_Intellect( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

function modifier_item_wizard_cape:GetModifierCastRangeBonus( params )
    return self:GetAbility():GetSpecialValueFor( "cast_range_bonus" )
end

function modifier_item_wizard_cape:GetModifierManaBonus( params )
    return self:GetAbility():GetSpecialValueFor( "mana_bonus" )
end

function modifier_item_wizard_cape:GetModifierHealthBonus( params )
    return self:GetAbility():GetSpecialValueFor( "health_bonus" )
end

function modifier_item_wizard_cape:GetModifierBonusStats_Agility( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_agility" )
end

function modifier_item_wizard_cape:GetModifierBonusStats_Strength( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_strength" )
end
