doomslayer_powershot = class({})
LinkLuaModifier( "modifier_doomslayer_powershot", "abilities/doomslayer_powershot.lua", LUA_MODIFIER_MOTION_NONE )

function doomslayer_powershot:Spawn()
    if IsServer() then
        self:SetThink( "OnIntervalThink", self, 0.25 )
    end
end

function doomslayer_powershot:OnIntervalThink()
    if IsServer() then
        self:SetActivated(not self:GetCaster():HasModifier("modifier_doomslayer_doom"))
    end

    return 0.25
end

function doomslayer_powershot:GetIntrinsicModifierName()
    return "modifier_doomslayer_powershot"
end

function doomslayer_powershot:GetCooldown( nLevel )
    return self.BaseClass.GetCooldown( self, nLevel )
end

function doomslayer_powershot:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
        EmitSoundOn( "Hero_Snapfire.Shotgun.Target", hTarget )
        
		local stun = self:GetSpecialValueFor( "stun_duration" )
		local d = self:GetAbilityDamage() + (((self:GetSpecialValueFor("attack_damage_ptc") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_doomslayer_4") or 0)) / 100) * self:GetCaster():GetAverageTrueAttackDamage(hTarget))

        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = stun } )

        print(d)

		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = d,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

        ApplyDamage( damage )
	end

	return true
end

if modifier_doomslayer_powershot == nil then modifier_doomslayer_powershot = class({}) end

function modifier_doomslayer_powershot:IsHidden() return false end
function modifier_doomslayer_powershot:IsPurgable() return false end

function modifier_doomslayer_powershot:DeclareFunctions ()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_doomslayer_powershot:OnAttackLanded (params)
    if IsServer () then
        if params.attacker == self:GetParent () then
            if self:GetAbility():IsCooldownReady() and self:GetAbility():GetAutoCastState() and self:GetAbility():IsOwnersManaEnough() and not self:GetParent():HasModifier("modifier_doomslayer_doom") then
                if not params.target:IsBuilding() and not params.target:IsAncient() then
                    self:GetAbility():PayManaCost()
                    self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))

                    local info = {
                        EffectName = "particles/econ/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf",
                        Ability = self:GetAbility(),
                        iMoveSpeed = self:GetParent():GetProjectileSpeed(),
                        Source = self:GetCaster(),
                        Target = params.target,
                        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
                    }
                
                    ProjectileManager:CreateTrackingProjectile( info )

                    EmitSoundOn("Hero_Snapfire.Shotgun.Fire", self:GetParent())
                end
            end
        end
    end

    return 0
end

