tzeentch_darkest_curse = class({})

LinkLuaModifier( "modifier_tzeentch_darkest_curse", "abilities/tzeentch_darkest_curse.lua", 0)
LinkLuaModifier( "modifier_tzeentch_labyrinth_of_glass", "abilities/tzeentch_labyrinth_of_glass", LUA_MODIFIER_MOTION_NONE )

function tzeentch_darkest_curse:Precache( context )
    PrecacheResource( "particle", "particles/hero_tzeench/tzeentch_darkest_curse_cast.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_demonartist/demonartist_soulchain_debuff_tgt.vpcf", context )
end

--------------------------------------------------------------------------------

function tzeentch_darkest_curse:OnSpellStart()
	local radius = self:GetSpecialValueFor( "radius" ) 
    local duration = self:GetDuration()
    
    if self:GetCaster():HasScepter() then
        radius = 99999
    end

	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
    
    if #units > 0 then
		for _,unit in pairs(units) do
            unit:AddNewModifier( self:GetCaster(), self, "modifier_tzeentch_darkest_curse", { duration = duration } )
            
            if self:GetCaster():HasScepter() then
                unit:AddNewModifier( self:GetCaster(), self:GetCaster():GetAbilityByIndex(2), "modifier_tzeentch_labyrinth_of_glass", { duration = duration } )
            end
		end
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/hero_tzeench/tzeentch_darkest_curse_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControl( nFXIndex, 1, self:GetCaster():GetOrigin() )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "Hero_VoidSpirit.Dissimilate.Cast", self:GetCaster() )

	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_3 );
end

modifier_tzeentch_darkest_curse = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_tzeentch_darkest_curse:IsHidden()
	return false
end

function modifier_tzeentch_darkest_curse:IsDebuff()
	return true
end

function modifier_tzeentch_darkest_curse:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_tzeentch_darkest_curse:OnCreated( kv )
	-- references
    self.slow = -self:GetAbility():GetSpecialValueFor( "movespeed_slow" ) -- special value
    self.ptc_damage = self:GetAbility():GetSpecialValueFor( "ptc_damage" ) / 100 -- special value
    self.damage_red = -self:GetAbility():GetSpecialValueFor( "damage_red" ) 

    if IsServer() then
        self:StartIntervalThink(1)
        self:OnIntervalThink()
    end
end

-- Modifier Effects
function modifier_tzeentch_darkest_curse:OnIntervalThink()
    if IsServer() then
        local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self:GetParent():GetHealth() * self.ptc_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
            damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
		}

		ApplyDamage( damage )
    end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_tzeentch_darkest_curse:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}

	return funcs
end

function modifier_tzeentch_darkest_curse:GetModifierPreAttack_BonusDamage(params)
	return self.slow
end

function modifier_tzeentch_darkest_curse:GetModifierTotalDamageOutgoing_Percentage(params)
	return self.damage_red
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_tzeentch_darkest_curse:GetEffectName()
	return "particles/units/heroes/hero_demonartist/demonartist_soulchain_debuff_tgt.vpcf"
end

function modifier_tzeentch_darkest_curse:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end