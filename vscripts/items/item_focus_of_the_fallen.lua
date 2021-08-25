LinkLuaModifier( "modifier_item_focus_of_the_fallen", "items/item_focus_of_the_fallen.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_focus_of_the_fallen_active", "items/item_focus_of_the_fallen.lua", LUA_MODIFIER_MOTION_NONE )

if item_focus_of_the_fallen == nil then
    item_focus_of_the_fallen = class({})
end

function item_focus_of_the_fallen:GetIntrinsicModifierName()
    return "modifier_item_focus_of_the_fallen"
end

function item_focus_of_the_fallen:OnSpellStart()
    if IsServer() then
        local hTarget = self:GetCursorTarget()
        local hCaster = self:GetCaster()

        if hTarget ~= nil then
            local info = {
                EffectName = "particles/stygian/focus_of_falleneal_blade.vpcf",
                Ability = self,
                iMoveSpeed = 2000,
                Source = hCaster,
                Target = hTarget,
            }

            EmitSoundOn( "Hero_Grimstroke.SoulChain.Cast", self:GetCaster() )

            ProjectileManager:CreateTrackingProjectile( info )
        end
    end
end

--------------------------------------------------------------------------------

function item_focus_of_the_fallen:OnProjectileHit( hTarget, vLocation )
    if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:IsMagicImmune() ) then
        EmitSoundOn( "Hero_Grimstroke.InkSwell.Stun", hTarget )

        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_item_focus_of_the_fallen_active", { duration = self:GetSpecialValueFor("active_duration") } )
    end

    return true
end

if modifier_item_focus_of_the_fallen == nil then modifier_item_focus_of_the_fallen = class({}) end

function modifier_item_focus_of_the_fallen:IsHidden() return true end
function modifier_item_focus_of_the_fallen:IsPurgable() return false end
function modifier_item_focus_of_the_fallen:IsPermanent() return true end
function modifier_item_focus_of_the_fallen:RemoveOnDeath() return false end

function modifier_item_focus_of_the_fallen:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }

    return funcs
end

function modifier_item_focus_of_the_fallen:GetModifierBonusStats_Strength( params ) return self:GetAbility():GetSpecialValueFor( "bonus_strength" ) end
function modifier_item_focus_of_the_fallen:GetModifierBonusStats_Intellect( params )  return self:GetAbility():GetSpecialValueFor( "bonus_intellect" ) end
function modifier_item_focus_of_the_fallen:GetModifierBonusStats_Agility( params ) return self:GetAbility():GetSpecialValueFor( "bonus_agility" ) end
function modifier_item_focus_of_the_fallen:GetModifierHealthBonus( params ) return self:GetAbility():GetSpecialValueFor( "bonus_health" ) end
function modifier_item_focus_of_the_fallen:GetModifierStatusResistance( params ) return self:GetAbility():GetSpecialValueFor( "status_resistance" ) end
function modifier_item_focus_of_the_fallen:GetModifierEvasion_Constant( params ) return self:GetAbility():GetSpecialValueFor( "bonus_evasion" ) end
function modifier_item_focus_of_the_fallen:GetModifierHPRegenAmplify_Percentage( params ) return self:GetAbility():GetSpecialValueFor( "hp_regen_amp" ) end

function modifier_item_focus_of_the_fallen:GetModifierConstantHealthRegen( params )
    if IsServer() then
        self:SetStackCount(self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("health_regen_pct") / 100))
    end

    return self:GetStackCount()
end

if modifier_item_focus_of_the_fallen_active == nil then  modifier_item_focus_of_the_fallen_active = class({}) end

function modifier_item_focus_of_the_fallen_active:IsHidden()
    return false
end

function modifier_item_focus_of_the_fallen_active:IsBuff ()
    return false
end
function modifier_item_focus_of_the_fallen_active:GetTexture ()
    return self:GetAbility():GetAbilityTextureName()
end

--------------------------------------------------------------------------------

function modifier_item_focus_of_the_fallen_active:StatusEffectPriority ()
    return 1000
end

--------------------------------------------------------------------------------

function modifier_item_focus_of_the_fallen_active:GetEffectName ()
    return "particles/stygian/chaos_king_dark_wave_root.vpcf"
end

--------------------------------------------------------------------------------

function modifier_item_focus_of_the_fallen_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_item_focus_of_the_fallen_active:IsPurgable()
    return false
end

function modifier_item_focus_of_the_fallen_active:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function item_focus_of_the_fallen:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end

