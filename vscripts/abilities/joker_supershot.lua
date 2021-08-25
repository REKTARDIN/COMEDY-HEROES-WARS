joker_supershot = class({})

LinkLuaModifier("modifier_joker_supershot_passive", "abilities/joker_supershot", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_joker_supershot_movespeed", "abilities/joker_supershot", LUA_MODIFIER_MOTION_NONE)

function joker_supershot:GetIntrinsicModifierName()
    return "modifier_joker_supershot_passive"
end

function joker_supershot:GetCastRange(vLocation, hTarget) 
	return self.BaseClass.GetCastRange (self, vLocation, hTarget) + self:GetCaster():GetCastRangeBonus() + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_joker_5") or 0)
 end

function joker_supershot:OnSpellStart()	
	self.range = self:GetSpecialValueFor( "range" )	+ self:GetCaster():GetCastRangeBonus() + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_joker_5") or 0)
    self.offset = 50
	self.vTargetLocation = self:GetCursorPosition()
	self.flAccumulatedTime = 0.0
	self.vDirection = self.vTargetLocation - self:GetCaster():GetOrigin() 
	self.nDaggersThrown = 0

	local vDirection = self.vTargetLocation  - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	local count =  self:GetSpecialValueFor( "bullet_count" )
	
    for i = 1, count do
        local vOffset = RandomVector( self.offset )
		vOffset.z = 0.0
		
		local vDirection = ( self.vTargetLocation + vOffset ) - self:GetCaster():GetOrigin() 
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		self:ThrowDagger( vDirection )

		EmitSoundOn( "Hero_Snapfire.Shotgun.Load", self:GetCaster() )
    end
end

--------------------------------------------------------------------------------

function joker_supershot:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) then

        EmitSoundOn( "Hero_Snapfire.Shotgun.Fire", hTarget )
		
		self:GetCaster():PerformAttack(hTarget, true, true, true, true, false, false, true)
	end

	return true
end

--------------------------------------------------------------------------------

function joker_supershot:ThrowDagger( vDirection )
    local info = 
    {
        EffectName = "particles/hero_spawn/spawn_glory_weapon_attack.vpcf",
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetAttachmentOrigin(1), 
        fStartRadius = self.offset + 50.0,
        fEndRadius = 50.0,
        vVelocity = vDirection * self:GetCaster():GetProjectileSpeed(),
        bDeleteOnHit = true,
        bProvidesVision = true,
        iVisionRadius = 1000,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        fDistance = self.range,
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    }
    
    ProjectileManager:CreateLinearProjectile( info )
    
    EmitSoundOn( "Hero_Sniper.MKG_attack", self:GetCaster() )
end

modifier_joker_supershot_passive = class({})

function modifier_joker_supershot_passive:IsHidden()
	return true
end

function modifier_joker_supershot_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_joker_supershot_passive:OnCreated( kv )

	self.bonus = self:GetAbility():GetSpecialValueFor( "passive_bonus_damage" )
end

function modifier_joker_supershot_passive:OnRefresh( kv )

	self.bonus = self:GetAbility():GetSpecialValueFor( "passive_bonus_damage" )
end

function modifier_joker_supershot_passive:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_joker_supershot_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE

	}

	return funcs
end

function modifier_joker_supershot_passive:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus
end

function modifier_joker_supershot_passive:OnAbilityFullyCast( params )
	if IsServer() then
		if params.unit~=self:GetParent() or params.ability:IsItem() then return end

		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_joker_supershot_movespeed", {duration = 1.5})

	end
end

modifier_joker_supershot_movespeed = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_joker_supershot_movespeed:IsHidden()
	return false
end

function modifier_joker_supershot_movespeed:IsDebuff()
	return false
end

function modifier_joker_supershot_movespeed:IsPurgable()
	return true
end

function modifier_joker_supershot_movespeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,	

	}

	return funcs
end

function modifier_joker_supershot_movespeed:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end