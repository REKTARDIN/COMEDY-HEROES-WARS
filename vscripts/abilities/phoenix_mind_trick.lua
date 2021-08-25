phoenix_mind_trick = class ( {})

LinkLuaModifier ("modifier_phoenix_mind_trick", "abilities/phoenix_mind_trick.lua", LUA_MODIFIER_MOTION_NONE)

function phoenix_mind_trick:GetCooldown (nLevel) return self.BaseClass.GetCooldown (self, nLevel) end
function phoenix_mind_trick:GetCastRange (vLocation, hTarget) return self.BaseClass.GetCastRange (self, vLocation, hTarget) end

--------------------------------------------------------------------------------

function phoenix_mind_trick:OnSpellStart ()
    local hTarget = self:GetCursorTarget ()
    if hTarget ~= nil then
        if ( not hTarget:TriggerSpellAbsorb (self) ) then
            local duration = self:GetSpecialValueFor ("duration")

            hTarget:AddNewModifier (self:GetCaster (), self, "modifier_phoenix_mind_trick", { duration = duration } )
            EmitSoundOn ("Hero_Phoenix.FireSpirits.Target", hTarget)
        end
    end
end


modifier_phoenix_mind_trick = class({})

function modifier_phoenix_mind_trick:GetEffectName () return "particles/items4_fx/spirit_vessel_damage_spirit.vpcf" end
function modifier_phoenix_mind_trick:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_phoenix_mind_trick:IsPurgable() return true end


function modifier_phoenix_mind_trick:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST 
    }

    return funcs
end

function modifier_phoenix_mind_trick:OnAbilityFullyCast( params )
    if IsServer() then 
        if self:GetParent() == params.unit then 
            local dmg = self:GetParent():GetHealth() * (self:GetAbility():GetSpecialValueFor("ptc_cur_dmg") / 100) + self:GetAbility():GetSpecialValueFor("damage_per_cast")
            
            local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
            ParticleManager:SetParticleControl( nFXIndex, 1, Vector(300, 300, 0) )
            ParticleManager:ReleaseParticleIndex( nFXIndex )

            self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = 0.5})

            EmitSoundOn("Hero_Phoenix.SuperNova.Death", self:GetParent())

            ApplyDamage({attacker = self:GetCaster(), victim = self:GetParent(), ability = self:GetAbility(), damage = dmg, damage_type = DAMAGE_TYPE_PURE})
        end
    end 
end


function modifier_phoenix_mind_trick:CheckState()
    return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end

