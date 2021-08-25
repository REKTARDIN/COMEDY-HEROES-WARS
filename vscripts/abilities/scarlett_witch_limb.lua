LinkLuaModifier( "modifier_scarlett_witch_limb", "abilities/scarlett_witch_limb.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_scarlett_witch_damage_buff", "abilities/scarlett_witch_limb.lua", LUA_MODIFIER_MOTION_NONE )

scarlett_witch_limb = class({}) 

function scarlett_witch_limb:IsStealable() return false end 

function scarlett_witch_limb:GetConceptRecipientType() return DOTA_SPEECH_USER_ALL end
function scarlett_witch_limb:SpeakTrigger() return DOTA_ABILITY_SPEAK_CAST end
function scarlett_witch_limb:OnAbilityPhaseStart() return true end

function scarlett_witch_limb:OnSpellStart()
    if IsServer() then
        EmitSoundOn("Hero_Grimstroke.InkCreature.Cast", self:GetCaster())

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_scarlett_witch_limb", {
            duration = self:GetSpecialValueFor("roaming_duration") 
        })
    end 
end

modifier_scarlett_witch_limb = class({})

function modifier_scarlett_witch_limb:IsPurgable() return false end
function modifier_scarlett_witch_limb:IsHidden() return true end
function modifier_scarlett_witch_limb:GetStatusEffectName() return "particles/ares_izanagi/status_effect_dark_willow_shadow_realm.vpcf" end
function modifier_scarlett_witch_limb:StatusEffectPriority() return -1 end
function modifier_scarlett_witch_limb:GetEffectName() return "particles/witch/witch_limb.vpcf" end
function modifier_scarlett_witch_limb:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_scarlett_witch_limb:OnCreated(params)
    if IsServer() then 
        self.damage_ptc = (self:GetAbility():GetSpecialValueFor("damage_gain_ptc") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_scarlett_witch_2") or 0)) / 100
        self.damage = 0
    end
end

function modifier_scarlett_witch_limb:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }

    return funcs
end

function modifier_scarlett_witch_limb:OnDestroy()
    if IsServer() then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_scarlett_witch_damage_buff", {
            duration = self:GetAbility():GetSpecialValueFor("damage_buff_duration"),
            damage = self.damage
        })
    end
end

function modifier_scarlett_witch_limb:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end

function modifier_scarlett_witch_limb:GetModifierAvoidDamage( params )
    if IsServer() then
        if params.target == self:GetParent() and (not params.target:IsBuilding()) and (not params.target:IsAncient()) then
            self.damage = self.damage + (params.damage * self.damage_ptc)

            return 1
        end
    end

    return 0
end

modifier_scarlett_witch_damage_buff = class({}) 

function modifier_scarlett_witch_damage_buff:IsHidden() return true end
function modifier_scarlett_witch_damage_buff:IsPurgable() return false end
function modifier_scarlett_witch_damage_buff:RemoveOnDeath() return true end
function modifier_scarlett_witch_damage_buff:GetModifierPreAttack_BonusDamage(params) return self:GetStackCount() end

function modifier_scarlett_witch_damage_buff:OnCreated(params)
    if IsServer() then
       self:SetStackCount(params.damage) 

       self.projectile = self:GetCaster():GetRangedProjectileName()

       self:GetCaster():SetRangedProjectileName("particles/witch/witch_shadow_attack.vpcf")
    end
end

function modifier_scarlett_witch_damage_buff:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK
    }

    return funcs
end

function modifier_scarlett_witch_damage_buff:OnDestroy()
    if IsServer() then
        self:GetCaster():SetRangedProjectileName(self.projectile)
    end
end

function modifier_scarlett_witch_damage_buff:OnAttack(params)
    if IsServer () then
        if params.attacker == self:GetParent() then
            EmitSoundOn("Hero_Grimstroke.DarkArtistry.Damage.Creep", params.target)
            EmitSoundOn("Hero_Grimstroke.InkSwell.Target", self:GetParent())
            
            self:Destroy()

            return 1
        end
    end

    return 0
end