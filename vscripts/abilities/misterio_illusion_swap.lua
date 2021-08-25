misterio_illusion_swap = class({})

--------------------------------------------------------------------------------

function misterio_illusion_swap:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------

function misterio_illusion_swap:CastFilterResultTarget( hTarget )
    if self:GetCaster() == hTarget then
        return UF_FAIL_CUSTOM
    end

    if hTarget:GetOwner() ~= self:GetCaster() or not hTarget:IsIllusion() then
        return UF_FAIL_CUSTOM
    end
    
    return UF_SUCCESS
end

--------------------------------------------------------------------------------

function misterio_illusion_swap:GetCustomCastErrorTarget( hTarget )
    if self:GetCaster() == hTarget then
        return "#dota_hud_error_cant_cast_on_self"
    end

    if hTarget:GetOwner() ~= self:GetCaster() or not hTarget:IsIllusion() then
        return "#dota_hud_error_cant_cast_on_ancient"
    end

    return ""
end

--------------------------------------------------------------------------------

function misterio_illusion_swap:GetCooldown( nLevel )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "nether_swap_cooldown_scepter" )
	end

	return self.BaseClass.GetCooldown( self, nLevel )
end

--------------------------------------------------------------------------------

function misterio_illusion_swap:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	if hCaster == nil or hTarget == nil then
		return
	end

	local vPos1 = hCaster:GetOrigin()
	local vPos2 = hTarget:GetOrigin()
	
	local caster_forward = hCaster:GetForwardVector()
	local target_forward = hTarget:GetForwardVector()

	hTarget:SetForwardVector(caster_forward)
	hCaster:SetForwardVector(target_forward)
	
	hCaster:SetOrigin( vPos2 )
	hTarget:SetOrigin( vPos1 )

	local nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster )
	ParticleManager:SetParticleControlEnt( nCasterFX, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nCasterFX )

	local nTargetFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControlEnt( nTargetFX, 1, hCaster, PATTACH_ABSORIGIN_FOLLOW, nil, hCaster:GetOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nTargetFX )

	EmitSoundOn( "Hero_VengefulSpirit.NetherSwap", hCaster )
	EmitSoundOn( "Hero_VengefulSpirit.NetherSwap", hTarget )

	hCaster:StartGesture( ACT_DOTA_CHANNEL_END_ABILITY_4 )
end