item_oblique_distortion = class({})

LinkLuaModifier( "modifier_item_oblique_distortion_active", "items/item_oblique_distortion.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_oblique_distortion", "items/item_oblique_distortion.lua", LUA_MODIFIER_MOTION_NONE )

function item_oblique_distortion:GetIntrinsicModifierName()
    return "modifier_item_oblique_distortion"
end

function item_oblique_distortion:OnSpellStart()
    if IsServer() then

        local target = self:GetCursorTarget()   

        if target ~= nil then
            EmitSoundOn("DOTA_Item.Sheepstick.Activate", target)
            EmitSoundOn("Item.StarEmblem.Enemy", target)

            target:AddNewModifier( self:GetCaster(), self, "modifier_item_oblique_distortion_active", {duration = self:GetSpecialValueFor("active_duration")} )
    end

    if target ~= nil then
            local info = {
                EffectName = "particles/items4_fx/nullifier_proj.vpcf",
                Ability = self,
                iMoveSpeed = 1000,
                Source = self:GetCaster(),
                Target = target,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
            }

            EmitSoundOn( "DOTA_Item.Nullifier.Cast", self:GetCaster() )

            ProjectileManager:CreateTrackingProjectile( info )
        end
    end
end

function item_oblique_distortion:OnProjectileHit( target, vLocation )

    if target and not target:IsMagicImmune() then

    if target:TriggerSpellAbsorb(self) then return nil end

    target:EmitSound("DOTA_Item.Nullifier.Target")
    
    target:Purge(true, false, false, false, false)

    local duration = self:GetSpecialValueFor( "mute_duration" )

        target:AddNewModifier( self:GetCaster(), self, "modifier_item_nullifier_mute", { duration = duration } )
    end
end

if modifier_item_oblique_distortion == nil then modifier_item_oblique_distortion = class({})  end
function modifier_item_oblique_distortion:IsHidden() return true end
function modifier_item_oblique_distortion:IsPurgable() return false end

function modifier_item_oblique_distortion:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_item_oblique_distortion:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_oblique_distortion:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_oblique_distortion:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_oblique_distortion:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_oblique_distortion:GetModifierPreAttack_BonusDamage (params) return self:GetAbility():GetSpecialValueFor ("bonus_damage") end
function modifier_item_oblique_distortion:GetModifierPhysicalArmorBonus (params) return self:GetAbility():GetSpecialValueFor ("bonus_armor") end
function modifier_item_oblique_distortion:GetModifierAttackSpeedBonus_Constant (params) return self:GetAbility():GetSpecialValueFor ("bonus_attack_speed") end
function modifier_item_oblique_distortion:GetModifierConstantHealthRegen( params ) return self:GetAbility():GetSpecialValueFor( "bonus_health_regen" )
end

function modifier_item_oblique_distortion:GetAttributes ()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end

if modifier_item_oblique_distortion_active == nil then modifier_item_oblique_distortion_active = class({}) end

function modifier_item_oblique_distortion_active:IsHidden() return true end
function modifier_item_oblique_distortion_active:IsPurgable() return false end

function modifier_item_oblique_distortion_active:GetEffectName()
    return "particles/econ/items/grimstroke/gs_fall20_immortal/gs_fall20_immortal_soul_debuff.vpcf"
end

function modifier_item_oblique_distortion_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_oblique_distortion_active:OnDestroy()
    if IsServer() then
        self:GetParent():RenderWearables(true)
    end
end

function modifier_item_oblique_distortion_active:OnCreated(params)
    if IsServer() then
        self:GetParent():RenderWearables(false)
    end
end

function modifier_item_oblique_distortion_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }

    return funcs
end

function modifier_item_oblique_distortion_active:GetModifierIncomingDamage_Percentage( params )
    return self:GetAbility():GetSpecialValueFor("active_incoming_damage")
end

function modifier_item_oblique_distortion_active:CheckState ()
    local state = {
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end


