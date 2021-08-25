desaad_jojo = class({})

LinkLuaModifier( "modifier_desaad_jojo_initial_debuff", "abilities/desaad_jojo", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_desaad_jojo_debuff", "abilities/desaad_jojo", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function desaad_jojo:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = self:GetSpecialValueFor( "initial_duration" )

	-- add debuff
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_desaad_jojo_initial_debuff", -- modifier name
		{ duration = duration } -- kv
    )
    
    ApplyDamage({
        victim = target,
        attacker = self:GetCaster(),
        ability = self,
        damage = self:GetSpecialValueFor("initial_damage") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_desaad_2") or 0),
        damage_type = self:GetAbilityDamageType()
    })

    EmitSoundOn( "Hero_ShadowDemon.DemonicPurge.Cast", target )
    
    local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/warlock/warlock_ti10_head/warlock_ti_10_fatal_bonds_cast.vpcf", PATTACH_CUSTOMORIGIN, nil );
    ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true );
    ParticleManager:SetParticleControlEnt( nFXIndex, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true );
    ParticleManager:ReleaseParticleIndex( nFXIndex );
end


modifier_desaad_jojo_initial_debuff = class({})

function modifier_desaad_jojo_initial_debuff:IsHidden() return false end
function modifier_desaad_jojo_initial_debuff:IsBuff() return false end
function modifier_desaad_jojo_initial_debuff:IsPurgable() return false end
function modifier_desaad_jojo_initial_debuff:GetEffectName() return "particles/desaad/desaad_jojo_debuff.vpcf" end
function modifier_desaad_jojo_initial_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_desaad_jojo_initial_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_building_placement_bad.vpcf" end
function modifier_desaad_jojo_initial_debuff:StatusEffectPriority() return 1000 end

function modifier_desaad_jojo_initial_debuff:OnCreated(params)
	if IsServer() then
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()
        self.parent = self:GetParent()
	end
end

function modifier_desaad_jojo_initial_debuff:OnDestroy()
    if IsServer() then
        if self.parent and self.caster and self.ability then
            self.parent:AddNewModifier(self.caster, self.ability, "modifier_desaad_jojo_debuff", {duration = self.ability:GetSpecialValueFor("debuff_duration")})
        end
    end
end

function modifier_desaad_jojo_initial_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function modifier_desaad_jojo_initial_debuff:GetModifierMoveSpeedBonus_Percentage (params)
    return self:GetAbility():GetSpecialValueFor("first_slow")
end

modifier_desaad_jojo_debuff = class({})

function modifier_desaad_jojo_debuff:IsHidden() return false end
function modifier_desaad_jojo_debuff:IsBuff() return false end
function modifier_desaad_jojo_debuff:IsPurgable() return false end

function modifier_desaad_jojo_debuff:OnCreated(params)
	if IsServer() then
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            ability = self:GetAbility(),
            damage = self:GetAbility():GetAbilityDamage(),
            damage_type = self:GetAbility():GetAbilityDamageType()
        })

        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/silencer/silencer_ti10_immortal_shield/silencer_ti10_immortal_curse_cast.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() );
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true );
        ParticleManager:ReleaseParticleIndex( nFXIndex );

        EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Impact", self:GetParent())
	end
end


function modifier_desaad_jojo_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function modifier_desaad_jojo_debuff:GetModifierMoveSpeedBonus_Percentage (params)
    return self:GetAbility():GetSpecialValueFor("debuff_slowing")
end
