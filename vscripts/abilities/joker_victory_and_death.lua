joker_victory_and_death = class({})

LinkLuaModifier( "modifier_joker_victory_and_death_thinker", "abilities/joker_victory_and_death.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_joker_victory_and_death_debuff", "abilities/joker_victory_and_death.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
local SPEED = 2000
local INTERVAL = 0.1

function joker_victory_and_death:IsStealable()
   return true
end

function joker_victory_and_death:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function joker_victory_and_death:OnSpellStart()
    if IsServer() then
        local target = CreateModifierThinker(self:GetCaster(), self, "modifier_joker_victory_and_death_thinker", nil, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)

        local info = {
			EffectName = "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_projectile.vpcf",
			Ability = self,
			iMoveSpeed = SPEED,
			Source = self:GetCaster(),
			Target = target,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}

        ProjectileManager:CreateTrackingProjectile( info )

        EmitSoundOn( "Hero_Snapfire.MortimerBlob.Projectile", self:GetCaster() )
    end
end

--------------------------------------------------------------------------------

function joker_victory_and_death:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
        EmitSoundOn( "Hero_Riki.Smoke_Screen.ti8", hTarget )

        if IsServer() then
            local bomb = hTarget:FindModifierByName("modifier_joker_victory_and_death_thinker")

            if bomb then
                bomb:SetDuration(self:GetSpecialValueFor("duration"), true)

                bomb:Explode(vLocation)
            end
        end
	end

	return true
end

--------------------------------------------------------------------------------

modifier_joker_victory_and_death_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_joker_victory_and_death_thinker:IsHidden() return false end
function modifier_joker_victory_and_death_thinker:IsPurgable() return false end

modifier_joker_victory_and_death_thinker.bActivated = false

--------------------------------------------------------------------------------
-- Initializations
function modifier_joker_victory_and_death_thinker:Explode( loc )
    self.bActivated = true
    self.radius = self:GetAbility():GetSpecialValueFor("radius")

    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/hero_joker/joker_toxic_smoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( nFXIndex, 0, loc)
        ParticleManager:SetParticleControl(nFXIndex, 1, Vector(self.radius, self.radius, 0) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_joker_victory_and_death_thinker:IsAura() return self.bActivated end
function modifier_joker_victory_and_death_thinker:GetModifierAura() return "modifier_joker_victory_and_death_debuff" end
function modifier_joker_victory_and_death_thinker:GetAuraRadius() return self.radius end
function modifier_joker_victory_and_death_thinker:GetAuraDuration() return 0.1 end
function modifier_joker_victory_and_death_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_joker_victory_and_death_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_joker_victory_and_death_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end

function modifier_joker_victory_and_death_thinker:OnDestroy()
    if IsServer() then
        UTIL_Remove(self:GetParent())
    end
end

--------------------------------------------------------------------------------
modifier_joker_victory_and_death_debuff = class({})

function modifier_joker_victory_and_death_debuff:IsHidden() return false end
function modifier_joker_victory_and_death_debuff:IsDebuff() return true end
function modifier_joker_victory_and_death_debuff:IsStunDebuff() return true end
function modifier_joker_victory_and_death_debuff:IsPurgable() return true end

function modifier_joker_victory_and_death_debuff:OnCreated( kv )
    if IsServer() then
        self.damage = self:GetAbility():GetSpecialValueFor("damage")

        self:StartIntervalThink(INTERVAL)
        self:OnIntervalThink()
    end
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_joker_victory_and_death_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

function modifier_joker_victory_and_death_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slowing")
end

function modifier_joker_victory_and_death_debuff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor_reduction")
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_joker_victory_and_death_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_EVADE_DISABLED] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true
    }

    return state
end

function modifier_joker_victory_and_death_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_joker_victory_and_death_debuff:OnIntervalThink()
    if IsServer() then
        local damage = self.damage * INTERVAL

        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetAbility():GetCaster(),
            damage = damage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            ability = self:GetAbility()
        })  
    end
end

