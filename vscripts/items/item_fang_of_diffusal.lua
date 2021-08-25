if item_fang_of_diffusal == nil then item_fang_of_diffusal = class({}) end

LinkLuaModifier( "modifier_item_fang_of_diffusal_active", "items/item_fang_of_diffusal.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_fang_of_diffusal", "items/item_fang_of_diffusal.lua", LUA_MODIFIER_MOTION_NONE )


function item_fang_of_diffusal:GetIntrinsicModifierName()
	return "modifier_item_fang_of_diffusal"
end

function item_fang_of_diffusal:OnSpellStart()
    local duration = self:GetSpecialValueFor("windwalk_duration")

    local caster = self:GetCaster()

    EmitSoundOn("DOTA_Item.ShadowAmulet.Activate", caster)
    caster:AddNewModifier(caster, self, "modifier_item_fang_of_diffusal_active", {duration = duration})
    caster:AddNewModifier(caster, self, "modifier_invisible", {duration = duration})
end

if modifier_item_fang_of_diffusal_active == nil then modifier_item_fang_of_diffusal_active = class({}) end

function modifier_item_fang_of_diffusal_active:IsHidden ()
    return true --we want item's passive abilities to be hidden most of the times
end

function modifier_item_fang_of_diffusal_active:IsPurgable()
	return false
end

function modifier_item_fang_of_diffusal_active:DeclareFunctions ()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_item_fang_of_diffusal_active:GetModifierPreAttack_BonusDamage( params )
    local hAbility = self:GetAbility()
    return hAbility:GetSpecialValueFor( "windwalk_bonus_damage_pre_attack" )
end


function modifier_item_fang_of_diffusal_active:OnAbilityExecuted( params )
	 if params.unit == self:GetParent() then
        self:Destroy()
     end
end

function modifier_item_fang_of_diffusal_active:OnCreated(table)
     if IsServer() then
        self.IsActive = true
     end
end

function modifier_item_fang_of_diffusal_active:GetModifierMoveSpeedBonus_Percentage()
     return self:GetAbility():GetSpecialValueFor("windwalk_movement_speed")
end

function modifier_item_fang_of_diffusal_active:OnAttackLanded( params )
    if params.attacker == self:GetParent() then
        local target = params.target
        if target then 
            local pct_burn = target:GetMana()*self:GetAbility():GetSpecialValueFor("manaburn_active")/100
                target:SpendMana(pct_burn, self:GetAbility())
    
            ApplyDamage({victim = params.target, 
                attacker = params.attacker, 
                damage = pct_burn, 
                damage_type = DAMAGE_TYPE_MAGICAL, 
                ability = self:GetAbility()})
                
            ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_manaburn_basher_ti_5_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target))

            EmitSoundOn("Hero_Antimage.ManaBreak", params.target)

            target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_diffusal_blade_slow", {duration = 4})
        end
        self.IsActive = false
    	self:Destroy()
    end
end

if modifier_item_fang_of_diffusal == nil then
    modifier_item_fang_of_diffusal = class({})
end
function modifier_item_fang_of_diffusal:IsHidden()
    return true --we want item's passive abilities to be hidden most of the times
end

function modifier_item_fang_of_diffusal:DeclareFunctions() --we want to use these functions in this item
local funcs = {
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_EVENT_ON_ATTACK_LANDED,
}

return funcs
end

function modifier_item_fang_of_diffusal:OnAttackLanded(params)
    if IsServer() then
        local mana_damage = self:GetAbility():GetSpecialValueFor("mana_burn")

        if not params.attacker:IsRealHero() then 
            mana_damage = self:GetAbility():GetSpecialValueFor("mana_burn_illusions")
        end 

        if params.attacker == self:GetParent() and params.target:IsBuilding() == false and params.target:GetMana() > 0 then
            params.target:SpendMana(mana_damage, self:GetAbility())

        ApplyDamage({victim = params.target, 

            attacker = params.attacker, 
            damage = mana_damage, 
            damage_type = DAMAGE_TYPE_PHYSICAL, 
            ability = self:GetAbility()})

            ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_manaburn_basher_ti_5_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target))
            EmitSoundOn("Hero_Antimage.ManaBreak", params.target)
        end
    end
end

function modifier_item_fang_of_diffusal:GetModifierBonusStats_Intellect( params )
    local hAbility = self:GetAbility()
    return hAbility:GetSpecialValueFor( "bonus_int" )
end
function modifier_item_fang_of_diffusal:GetModifierBonusStats_Agility( params )
    local hAbility = self:GetAbility()
    return hAbility:GetSpecialValueFor( "bonus_agi" )
end

function modifier_item_fang_of_diffusal:GetModifierAttackSpeedBonus_Constant( params )
    local hAbility = self:GetAbility()
    return hAbility:GetSpecialValueFor( "bonus_as" )
end

function modifier_item_fang_of_diffusal:GetModifierPreAttack_BonusDamage( params )
    local hAbility = self:GetAbility()
    return hAbility:GetSpecialValueFor( "bonus_damage" )
end

function item_fang_of_diffusal:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

