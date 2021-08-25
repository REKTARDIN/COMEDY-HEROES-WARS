LinkLuaModifier ("modifier_gambit_kinetic_shockwave", "abilities/gambit_kinetic_shockwave.lua", LUA_MODIFIER_MOTION_NONE)

gambit_kinetic_shockwave = class({})

function gambit_kinetic_shockwave:GetIntrinsicModifierName() 
    return "modifier_gambit_kinetic_shockwave" 
end

function gambit_kinetic_shockwave:CreateShockwave(hTarget) 
    if IsServer() then
        self.damage = self:GetSpecialValueFor("shock_damage") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_gambit_2") or 0)
        
        local vDirection = hTarget:GetAbsOrigin() - self:GetCaster():GetOrigin()
        vDirection = vDirection:Normalized()

        local info = {
            EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
            Ability = self,
            vSpawnOrigin = self:GetCaster():GetOrigin(), 
            fStartRadius = self:GetSpecialValueFor( "shock_width" ),
            fEndRadius = self:GetSpecialValueFor( "shock_width" ),
            vVelocity = vDirection *  self:GetSpecialValueFor( "shock_speed" ),
            fDistance = self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() ),
            Source = self:GetCaster(),
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            bProvidesVision = false
        }

        ProjectileManager:CreateLinearProjectile( info )
        
        EmitSoundOn( "Hero_Magnataur.ShockWave.Cast.Anvil" , self:GetCaster() )

        self:UseResources(false, false, true)
    end
end

--------------------------------------------------------------------------------

function gambit_kinetic_shockwave:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = this,
		}

		ApplyDamage( damage )
	end

	return false
end

--------------------------------------------------------------------------------

modifier_gambit_kinetic_shockwave = class({})

function modifier_gambit_kinetic_shockwave:IsHidden() return true end
function modifier_gambit_kinetic_shockwave:IsPurgable() return false end

function modifier_gambit_kinetic_shockwave:DeclareFunctions() 
    return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PROCATTACK_FEEDBACK}
end

function modifier_gambit_kinetic_shockwave:OnCreated(params)
    if IsServer() then
        self:SetStackCount(self:GetParent():GetBaseAgility())
    end
end

function modifier_gambit_kinetic_shockwave:OnRefresh(params)
    if IsServer() then
        self:SetStackCount(self:GetParent():GetBaseAgility())
    end
end

function modifier_gambit_kinetic_shockwave:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility") / 100 * self:GetStackCount()
end

function modifier_gambit_kinetic_shockwave:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed") + (IsHasTalent(self:GetParent():GetPlayerOwnerID(), "bonus_movespeed") or 0)
end

function modifier_gambit_kinetic_shockwave:GetModifierProcAttack_Feedback(params)
    if IsServer() then
        if IsValidEntity(params.target) and self:GetAbility():IsCooldownReady() then
            self:GetAbility():CreateShockwave(params.target)
        end
    end
end