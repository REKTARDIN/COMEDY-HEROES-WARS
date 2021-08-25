LinkLuaModifier( "modifier_ross_flaming_fists", "abilities/ross_flaming_fists.lua", LUA_MODIFIER_MOTION_NONE )

ross_flaming_fists = class({})

function ross_flaming_fists:OnSpellStart()

  self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ross_flaming_fists", { duration = self:GetSpecialValueFor("buff_duration") })

  local nFXIndex = ParticleManager:CreateParticle ("particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast_beam.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster());
  ParticleManager:SetParticleControl(nFXIndex, 0, self:GetCaster():GetOrigin());
  ParticleManager:ReleaseParticleIndex (nFXIndex);

  EmitSoundOn( "Hero_Huskar.Burning_Spear.Cast", self:GetCaster() )
end

modifier_ross_flaming_fists = class({})
function modifier_ross_flaming_fists:IsHidden() return false end
function modifier_ross_flaming_fists:IsPurgable() return false end

function modifier_ross_flaming_fists:GetStatusEffectName()
   return "particles/status_fx/status_effect_drunken_brawler.vpcf"
end

function modifier_ross_flaming_fists:GetEffectName()
    return "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf"
end

function modifier_ross_flaming_fists:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
 
function modifier_ross_flaming_fists:StatusEffectPriority()
   return 1000
end

function modifier_ross_flaming_fists:DeclareFunctions ()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_ross_flaming_fists:OnAttackLanded (params)
    if IsServer () then
        if params.attacker == self:GetParent () then
            local hTarget = params.target
            
            EmitSoundOn("Hero_Tusk.WalrusPunch.Damage", hTarget)
            EmitSoundOn("Hero_Tusk.WalrusKick.Target", hTarget)
           
            local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
            if #units > 0 then
                for _,unit in pairs(units) do
                    local crit = self:GetAbility():GetSpecialValueFor("damage_crit_ptc") + self:GetCaster():RULK_GetUltimateStacks() 
                    self:GetParent():DoCrit(unit, crit)

                    local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
                    ParticleManager:SetParticleControl( nFXIndex, 0, unit:GetOrigin() )
                    ParticleManager:ReleaseParticleIndex( nFXIndex )
                end
            end

            self:Destroy()
        end
    end
    return 0
end
