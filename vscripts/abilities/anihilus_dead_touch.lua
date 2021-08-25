anihilus_dead_touch = class({})

LinkLuaModifier( "modifier_anihilus_dead_touch_debuff", "abilities/anihilus_dead_touch", LUA_MODIFIER_MOTION_NONE )

function anihilus_dead_touch:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "scepter_cooldown" )
	end

	return self.BaseClass.GetCooldown( self, iLevel )
end

--------------------------------------------------------------------------------
-- Ability Start
function anihilus_dead_touch:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- add modifier
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_anihilus_dead_touch_debuff", -- modifier name
		{ duration = duration } -- kv
    )
    
	EmitSoundOn( "Hero_Dark_Seer.Ion_Shield_Start.TI8", target )
end

modifier_anihilus_dead_touch_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_anihilus_dead_touch_debuff:IsHidden()
	return false
end

function modifier_anihilus_dead_touch_debuff:IsDebuff()
	return true
end

function modifier_anihilus_dead_touch_debuff:IsStunDebuff()
	return false
end

function modifier_anihilus_dead_touch_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_anihilus_dead_touch_debuff:OnCreated( kv )
	-- references
    self.slow = self:GetAbility():GetSpecialValueFor( "slow" )

    self.debuffs = nil
    self.debuffs = {}
    
    self.limit = self:GetAbility():GetSpecialValueFor( "debuffs_limit" )

    if self:GetCaster():HasScepter() then
        self.limit = self:GetAbility():GetSpecialValueFor( "scepter_debuffs_limit" )
    end

	local damage = self:GetAbility():GetSpecialValueFor( "damage_per_second" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_anihilus_3") or 0)
	local interval = 1

    if IsServer() then
        self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
        }
    
		-- Start interval
		self:StartIntervalThink( interval )
		self:OnIntervalThink()
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_anihilus_dead_touch_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_MODIFIER_ADDED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_anihilus_dead_touch_debuff:OnModifierAdded( params )
    if IsServer() then
        if params.unit == self:GetParent() and self.limit >= 1 then
            local modifiers = self:GetParent():FindAllModifiers()

            for _, mod in pairs(modifiers) do 
                if mod ~= self then
                    if self.limit <= 0 then
                        break 
                    end

                    if (mod:IsDebuff() or mod:IsHexDebuff() or mod:IsStunDebuff() or string.match(mod:GetName(), "_debuff")) and (not self:HasRecord(self.debuffs, mod)) then
                        if mod:GetDuration() > 1 and (not mod:GetAuraOwner()) then
                            mod:SetDuration(mod:GetDuration() * 2, true)

                            self.limit = self.limit - 1

                            table.insert(self.debuffs, mod)
                        end
                    end
                end
            end 
        end
	end
end

function modifier_anihilus_dead_touch_debuff:HasRecord(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function modifier_anihilus_dead_touch_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_anihilus_dead_touch_debuff:OnIntervalThink()
	ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_anihilus_dead_touch_debuff:GetEffectName()
	return "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf"
end

function modifier_anihilus_dead_touch_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
