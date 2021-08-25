beyonder_void = class({}) 
LinkLuaModifier( "modifier_beyonder_void_debuff", "abilities/beyonder_void.lua", LUA_MODIFIER_MOTION_NONE )

function cap_shield_clash:OnSpellStart()
    if IsServer() then 
        local info = {
            EffectName = "particles/econ/items/vengeful/vs_ti8_immortal_shoulder/vs_ti8_immortal_magic_missle.vpcf",
            Ability = self,
            iMoveSpeed = 1400,
            Source = self:GetCaster (),
            Target = self:GetCursorTarget (),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
        }

        ProjectileManager:CreateTrackingProjectile(info)

        EmitSoundOn ("Hero_Abaddon.DeathCoil.Cast", self:GetCaster () )
    end
end

function cap_shield_clash:OnProjectileHit (hTarget, vLocation)
    if hTarget ~= nil and ( not hTarget:IsInvulnerable () ) and ( not hTarget:TriggerSpellAbsorb (self) ) and ( not hTarget:IsMagicImmune () ) then
    
        EmitSoundOn ("Hero_Abaddon.DeathCoil.Target", hTarget)

        local duration = 1.0

        hTarget:AddNewModifier(self:GetCaster (), self, "modifier_beyonder_void_debuff", { duration = duration} )
    end
end

modifier_beyonder_void_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_beyonder_void_debuff:IsHidden()
	return true
end

function modifier_beyonder_void_debuff:IsDebuff()
	return true
end

function modifier_beyonder_void_debuff:RemoveOnDeath()
	return true
end

function modifier_beyonder_void_debuff:IsPurgable()
	return false
end

function modifier_beyonder_void_debuff:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.5)
    end
end

function modifier_beyonder_void_debuff:OnIntervalThink(hTarget)
    if IsServer() then

    local caster = self:GetCaster()
    local target = hTarget
    
	if target == nil or target:IsInvulnerable() or target:TriggerSpellAbsorb( self ) then
		return
    end
    
	local mana_damage_pct = self:GetSpecialValueFor("void_damage_per_mana")
	local mana_stun = self:GetSpecialValueFor("void_ministun")
	local radius = self:GetSpecialValueFor( "void_aoe_radius" )
	local mana_damage_pct = (target:GetMaxMana() - target:GetMana()) * mana_damage_pct

	-- Apply Damage	 
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = mana_damage_pct,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	-- ApplyDamage(damageTable)

	-- Find Units in Radius
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		target:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
        ApplyDamage(damageTable)
        end
    end
end
