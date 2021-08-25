LinkLuaModifier( "modifier_item_awakened_mjolnir", "items/item_awakened_mjolnir.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_awakened_mjolnir_cooldown", "items/item_awakened_mjolnir.lua", LUA_MODIFIER_MOTION_NONE )

item_awakened_mjolnir = class({})

local INDEX_FADE_TIME = 0.1

function item_awakened_mjolnir:GetIntrinsicModifierName()
    return "modifier_item_awakened_mjolnir"
end

modifier_item_awakened_mjolnir = class({})

modifier_item_awakened_mjolnir.m_hCashedUnit = nil

function modifier_item_awakened_mjolnir:IsHidden() return true end
function modifier_item_awakened_mjolnir:IsPermanent() return true end
function modifier_item_awakened_mjolnir:IsPurgable() return false end
function modifier_item_awakened_mjolnir:RemoveOnDeath() return false end

function modifier_item_awakened_mjolnir:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

     return funcs
end

function modifier_item_awakened_mjolnir:GetModifierBonusStats_Strength( params ) return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) end
function modifier_item_awakened_mjolnir:GetModifierBonusStats_Intellect( params ) return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) end
function modifier_item_awakened_mjolnir:GetModifierBonusStats_Agility( params ) return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" ) end
function modifier_item_awakened_mjolnir:GetModifierPreAttack_BonusDamage( params ) return self:GetAbility():GetSpecialValueFor( "bonus_damage" ) end
function modifier_item_awakened_mjolnir:GetModifierAttackSpeedBonus_Constant( params ) return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" ) end

function modifier_item_awakened_mjolnir:OnCreated()
    if self:GetAbility():GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
        self:GetParent():AddNewModifier(
            self:GetAbility():GetCaster(),
            self:GetAbility(),
            "modifier_item_mjollnir_static",
            nil
        )
    end
end

function modifier_item_awakened_mjolnir:OnDestroy()
    if self:GetAbility():GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
        self:GetParent():RemoveModifierByName("modifier_item_mjollnir_static")
    end
end


function modifier_item_awakened_mjolnir:OnAttackLanded( params )
    if IsServer() then
        if params.target and params.attacker == self:GetParent() and not self:GetParent():IsIllusion() then

            if params.target:IsBuilding() then
                return nil
            end

            if RollPercentage(self:GetAbility():GetSpecialValueFor("chain_chance")) and not self:GetParent():HasModifier("modifier_item_awakened_mjolnir_cooldown") then
                self:Chain(params.target)
                params.attacker:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_item_awakened_mjolnir_cooldown", {duration = self:GetAbility():GetSpecialValueFor("chain_cooldown")})
            end
        end
    end
end

function modifier_item_awakened_mjolnir:Chain(target)
    if IsServer() then
        if target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then

            local radius = self:GetAbility():GetSpecialValueFor( "chain_radius" )

            local units = FindUnitsInRadius( target:GetTeamNumber(), target:GetOrigin(), target, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false )
            if #units > 0 then
                for i = 1, #units do
                    local unit = units[i]
                    local next_unit = units[i + 1]

                    if not unit:IsNull() and unit then
                        Timers:CreateTimer(INDEX_FADE_TIME * i, function()
                            local damage = {
                                victim = unit,
                                attacker = self:GetCaster(),
                                damage = self:GetAbility():GetSpecialValueFor( "chain_damage" ),
                                damage_type = DAMAGE_TYPE_MAGICAL,
                                ability = self:GetAbility()
                            }

                            ApplyDamage( damage )

                            EmitSoundOn("Item.Maelstrom.Chain_Lightning", unit)



                            if next_unit and not next_unit:IsNull() then
                                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/zeus/zeus_ti8_immortal_arms/zeus_ti8_immortal_arc.vpcf", PATTACH_CUSTOMORIGIN, nil );
                                ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true );
                                ParticleManager:SetParticleControlEnt( nFXIndex, 1, next_unit, PATTACH_POINT_FOLLOW, "attach_hitloc", next_unit:GetOrigin(), true );
                                ParticleManager:ReleaseParticleIndex( nFXIndex );

                                EmitSoundOn("Item.Maelstrom.Chain_Lightning.Jump", next_unit)
                            end
                        end)
                    end
                end
            end
        end
    end
end

modifier_item_awakened_mjolnir_cooldown = class({})

function modifier_item_awakened_mjolnir_cooldown:IsHidden() return true end
function modifier_item_awakened_mjolnir_cooldown:IsPurgable() return false end

