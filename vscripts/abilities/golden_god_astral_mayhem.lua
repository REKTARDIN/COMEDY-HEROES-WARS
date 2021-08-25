golden_god_astral_mayhem = class({})

LinkLuaModifier( "modifier_golden_god_astral_mayhem", "abilities/golden_god_astral_mayhem.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golden_god_astral_mayhem_buff", "abilities/golden_god_astral_mayhem.lua", LUA_MODIFIER_MOTION_NONE )

function golden_god_astral_mayhem:GetIntrinsicModifierName() return "modifier_golden_god_astral_mayhem" end

function golden_god_astral_mayhem:DoDebuff(hTarget)
    local damage = self:GetAbilityDamage() + ((self:GetSpecialValueFor("current_health_damage_pct") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_goldengod_2") or 0)) / 100 * self:GetCaster():GetMaxHealth())
    hTarget:AddNewModifier(self:GetCaster(), self, "modifier_golden_god_astral_mayhem_buff", {damage = damage, duration = self:GetSpecialValueFor("counter_duration")})
end

modifier_golden_god_astral_mayhem = class ( {})

function modifier_golden_god_astral_mayhem:IsHidden() return true end
function modifier_golden_god_astral_mayhem:RemoveOnDeath() return false end
function modifier_golden_god_astral_mayhem:IsPurgable() return false end

function modifier_golden_god_astral_mayhem:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }
	return funcs
end

function modifier_golden_god_astral_mayhem:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and self:GetAbility():IsOwnersManaEnough() and params.target:IsRealHero() and self:GetAbility():GetAutoCastState() and IsValidEntity(params.target) and self:GetAbility():IsCooldownReady() and (not self:GetCaster():PassivesDisabled()) then		
            EmitSoundOn("Hero_TemplarAssassin.Trap.Explode", self:GetParent())
            
            self:GetAbility():DoDebuff(params.target)
			self:GetAbility():UseResources(true, false, true)
		end
	end
end

if modifier_golden_god_astral_mayhem_buff == nil then modifier_golden_god_astral_mayhem_buff = class({}) end

function modifier_golden_god_astral_mayhem_buff:IsPurgable() return false end
function modifier_golden_god_astral_mayhem_buff:RemoveOnDeath() return false end
function modifier_golden_god_astral_mayhem_buff:IsHidden() return false end
function modifier_golden_god_astral_mayhem_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end 

function modifier_golden_god_astral_mayhem_buff:OnCreated(params)
   self.damage = params.damage

   if IsServer() then
        self:StartIntervalThink(1.0)
        self:OnIntervalThink()
   end
end

function modifier_golden_god_astral_mayhem_buff:GetEffectName()
    return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end

function modifier_golden_god_astral_mayhem_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_golden_god_astral_mayhem_buff:OnIntervalThink()
    if IsServer() then
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self.damage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            ability = self:GetAbility(),
            damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
        })
    end
 end
