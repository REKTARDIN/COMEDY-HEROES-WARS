anihilus_timeless_tenet = class({})
LinkLuaModifier( "modifier_anihilus_timeless_tenet", "abilities/anihilus_timeless_tenet.lua", LUA_MODIFIER_MOTION_NONE )

local SPEED = 6000

--------------------------------------------------------------------------------
-- Ability Start
function anihilus_timeless_tenet:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- logic
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf",
		iMoveSpeed = SPEED,
		bDodgeable = false,                           -- Optional
    }
    
	ProjectileManager:CreateTrackingProjectile(info)

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_death_coil_abaddon.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( "Hero_Abaddon.DeathCoil.Cast", self:GetCaster() )
end
--------------------------------------------------------------------------------
-- Projectile
function anihilus_timeless_tenet:OnProjectileHit( target, location )
	if target:IsInvulnerable() or target:TriggerSpellAbsorb( self ) then
        return
    end

    local duration = self:GetSpecialValueFor("duration") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_anihilus_1") or 0)
    
    target:AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_anihilus_timeless_tenet",
        {duration = duration}
    )

    local damageTable = {
        victim = target,
        attacker = self:GetCaster(),
        damage = self:GetAbilityDamage(),
        damage_type = self:GetAbilityDamageType(),
        ability = self, --Optional.
    }

    ApplyDamage(damageTable)

	EmitSoundOn( "Hero_Abaddon.DeathCoil.Target", target )
end

if modifier_anihilus_timeless_tenet == nil then modifier_anihilus_timeless_tenet = class({}) end

function modifier_anihilus_timeless_tenet:IsDebuff() return true end
function modifier_anihilus_timeless_tenet:IsHidden() return false end
function modifier_anihilus_timeless_tenet:IsPurgable() return false end
function modifier_anihilus_timeless_tenet:GetEffectName() return "particles/cosmos/cosmos_space_warp_debuff.vpcf" end
function modifier_anihilus_timeless_tenet:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_anihilus_timeless_tenet:GetStatusEffectName() return "particles/status_fx/status_effect_enigma_malefice.vpcf" end
function modifier_anihilus_timeless_tenet:StatusEffectPriority() return 1000 end
function modifier_anihilus_timeless_tenet:CheckState() return { [MODIFIER_STATE_SPECIALLY_DENIABLE] = true } end
function modifier_anihilus_timeless_tenet:DeclareFunctions() return { MODIFIER_PROPERTY_DISABLE_TURNING, MODIFIER_PROPERTY_EVASION_CONSTANT } end
function modifier_anihilus_timeless_tenet:GetModifierDisableTurning ( params ) return 1 end
function modifier_anihilus_timeless_tenet:GetModifierEvasion_Constant ( params ) return -100 end
 
function modifier_anihilus_timeless_tenet:OnCreated(params)
    if IsServer() then
        self.ptc = self:GetAbility():GetSpecialValueFor("damage_ptc") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_anihilus_2") or 0)

        self:StartIntervalThink(1)
        self:OnIntervalThink()
    end
end

function modifier_anihilus_timeless_tenet:OnIntervalThink()
    local damage = self:GetParent():GetHealth() * (self.ptc / 100)
    self:GetParent():ModifyHealth(self:GetParent():GetHealth() - damage, self:GetAbility(), true, 0)
end
