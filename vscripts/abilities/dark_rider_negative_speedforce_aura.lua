if not dark_rider_negative_speedforce_aura then dark_rider_negative_speedforce_aura = class({}) end

function dark_rider_negative_speedforce_aura:GetAbilityTextureName() 
    return self.BaseClass.GetAbilityTextureName(self)  
end

function dark_rider_negative_speedforce_aura:Spawn()
    if IsServer() then self:SetLevel(1) end
end


LinkLuaModifier ("modifier_dark_rider_negative_speedforce", "abilities/dark_rider_negative_speedforce_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_dark_rider_negative_speedforce_aura", "abilities/dark_rider_negative_speedforce_aura.lua", LUA_MODIFIER_MOTION_NONE)

function dark_rider_negative_speedforce_aura:GetIntrinsicModifierName() 
    return "modifier_dark_rider_negative_speedforce_aura"
 end

if modifier_dark_rider_negative_speedforce_aura == nil then modifier_dark_rider_negative_speedforce_aura = class({}) end

function modifier_dark_rider_negative_speedforce_aura:IsAura() 
    return true 
end

function modifier_dark_rider_negative_speedforce_aura:GetEffectName() 
    return "particles/stygian/dark_rider_negative_speedforce_buff.vpcf" 
end

function modifier_dark_rider_negative_speedforce_aura:GetEffectAttachType() 
    return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_dark_rider_negative_speedforce_aura:IsHidden() 
    return true 
end

function modifier_dark_rider_negative_speedforce_aura:IsPurgable() 
    return false 
end

function modifier_dark_rider_negative_speedforce_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }

    return funcs
end

function modifier_dark_rider_negative_speedforce_aura:GetModifierMoveSpeedBonus_Constant() 
    return 35
end

function modifier_dark_rider_negative_speedforce_aura:GetAuraRadius() 
    return self:GetAbility():GetSpecialValueFor("aura_radius") 
end

function modifier_dark_rider_negative_speedforce_aura:GetAuraSearchTeam() 
    return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_dark_rider_negative_speedforce_aura:GetAuraSearchType() 
    return DOTA_UNIT_TARGET_HERO 
end

function modifier_dark_rider_negative_speedforce_aura:GetAuraSearchFlags() 
    return DOTA_UNIT_TARGET_FLAG_NONE 
end

function modifier_dark_rider_negative_speedforce_aura:GetModifierAura() 
    return "modifier_dark_rider_negative_speedforce"
end

function modifier_dark_rider_negative_speedforce_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
    }

    return funcs
end

function modifier_dark_rider_negative_speedforce_aura:GetModifierIgnoreMovespeedLimit() 
    return 1 
end

function modifier_dark_rider_negative_speedforce_aura:GetPriority() 
    return MODIFIER_PRIORITY_SUPER_ULTRA 
end


if modifier_dark_rider_negative_speedforce == nil then modifier_dark_rider_negative_speedforce = class({}) end

function modifier_dark_rider_negative_speedforce:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_UNIT_MOVED
    }

    return funcs
end

function modifier_dark_rider_negative_speedforce:IsHidden() 
    return true 
end

function modifier_dark_rider_negative_speedforce:IsPurgable() 
    return false 
end

function modifier_dark_rider_negative_speedforce:OnCreated( params )
    if IsServer() then self._vPosition = self:GetParent():GetAbsOrigin() end 
    self:StartIntervalThink(0.5)
end

function modifier_dark_rider_negative_speedforce:OnUnitMoved(params)
	if IsServer() and self:GetParent():IsRealHero() then 
		if params.unit == self:GetParent() then 
			if self._vPosition ~= self:GetParent():GetAbsOrigin() then 
				local distance = (self:GetParent():GetAbsOrigin() - self._vPosition):Length2D()

				self._vPosition = self:GetParent():GetAbsOrigin()

				self:OnPositionChanged(distance)
			end 			
		end
	end 
end

function modifier_dark_rider_negative_speedforce:OnPositionChanged( distance )
	if IsServer() then 
		local value = math.floor( distance ) * (self:GetAbility():GetSpecialValueFor("aura_damage") / 100)
            
        self:SetStackCount(self:GetStackCount() + math.floor( distance ))

        local damage_table = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = value,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility()
        }

        ApplyDamage (damage_table)
	end
end

function modifier_dark_rider_negative_speedforce:OnIntervalThink()
    if IsServer() then
		local radius = self:GetAbility():GetSpecialValueFor("aura_radius") 
        local chance = 30
        if self:GetCaster():IsAlive() == false then
            return 
        end

        if self:GetCaster():IsRealHero() == false then
            return 
        end

        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )
        if #units > 0 then
            for _,unit in pairs(units) do
               if self:GetAbility():IsCooldownReady() and RollPercentage(chance) and unit:IsSpeedster() then 
                    if (not unit:IsMagicImmune()) then 
                        unit:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = 1.8 } )
                        EmitSoundOn( "MolagBal.Maceofoblivion.Cast", unit )

                        self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
                    end
                end
            end
        end
    end
end
    