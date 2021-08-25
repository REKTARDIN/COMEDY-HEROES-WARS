if not cosmos_starfall then cosmos_starfall = class({}) end
LinkLuaModifier( "modifier_cosmos_starfall", "abilities/cosmos_starfall.lua", LUA_MODIFIER_MOTION_NONE )

function cosmos_starfall:GetIntrinsicModifierName() return "modifier_cosmos_starfall" end

modifier_cosmos_starfall = class({})
function modifier_cosmos_starfall:IsHidden() return true end
function modifier_cosmos_starfall:IsPurgable() return false end
function modifier_cosmos_starfall:RemoveOnDeath() return false end
function modifier_cosmos_starfall:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_cosmos_starfall:OnAbilityFullyCast(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            if params.ability and (not params.ability:IsItem()) then  
                EmitSoundOn("Hero_Mirana.Starstorm.Cast", self:GetCaster())

                local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
                if #units > 0 then
                    for _,unit in pairs(units) do
                        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/mirana/mirana_starstorm_bow/mirana_starstorm_starfall_attack.vpcf", PATTACH_CUSTOMORIGIN, nil )
                        ParticleManager:SetParticleControl( nFXIndex, 0, unit:GetOrigin() )
                        ParticleManager:ReleaseParticleIndex( nFXIndex )

                        EmitSoundOn( "Hero_Mirana.Starstorm.Impact", unit )

                        local damage = {
                            victim = unit,
                            attacker = self:GetCaster(),
                            damage = self:GetAbility():GetSpecialValueFor("damage"),
                            damage_type = DAMAGE_TYPE_MAGICAL,
                            ability = self:GetAbility()
                        }
                
                        ApplyDamage( damage )
                    end
                end
            end
        end
    end
end
