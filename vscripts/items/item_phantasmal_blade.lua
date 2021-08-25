
LinkLuaModifier("modifier_item_phantasmal_blade", "items/item_phantasmal_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_phantasmal_blade_ethereal", "items/item_phantasmal_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_phantasmal_blade_slowing", "items/item_phantasmal_blade.lua", LUA_MODIFIER_MOTION_NONE)

item_phantasmal_blade = class({})

function item_phantasmal_blade:GetIntrinsicModifierName()
    return "modifier_item_phantasmal_blade"
end

function item_phantasmal_blade:OnSpellStart()
    if IsServer() then

        self.caster	= self:GetCaster()

        self.blast_movement_slow = self:GetSpecialValueFor("blast_movement_slow")
        self.duration =	self:GetSpecialValueFor("duration")
        self.blast_agility_multiplier = self:GetSpecialValueFor("blast_agility_multiplier")

        self.blast_damage_base = self:GetSpecialValueFor("blast_damage_base")
        self.ethereal_damage_bonus = self:GetSpecialValueFor("ethereal_damage_bonus")
        self.projectile_speed = self:GetSpecialValueFor("projectile_speed")
        self.tooltip_range	= self:GetSpecialValueFor("tooltip_range")
        self.radius = self:GetSpecialValueFor("radius")

        local target = self:GetCursorTarget()

        self.caster:EmitSound("DOTA_Item.EtherealBlade.Activate")
        self.caster:EmitSound("Hero_Winter_Wyvern.SplinterBlast.Target")
        self.caster:EmitSound("Hero_Pugna.NetherBlast")

        local projectile =
            {
                Target = target,
                Source = self.caster,
                Ability = self,
                EffectName = "particles/stygian/phantsmal_eal_blade.vpcf",
                iMoveSpeed	= self.projectile_speed,
                vSourceLoc 	= caster_location,
                bDrawsOnMinimap = false,
                bDodgeable 	= true,
                bIsAttack = false,
                bVisibleToEnemies = true,
                bReplaceExisting = false,
                flExpireTime = GameRules:GetGameTime() + 20,
                bProvidesVision = false,
            }

        ProjectileManager:CreateTrackingProjectile(projectile)
    end
end

function item_phantasmal_blade:OnProjectileHit(target, vLocation)
    if not IsServer() then return end

    if target and not target:IsMagicImmune() then

        if target:TriggerSpellAbsorb(self) then return nil end

        target:EmitSound("DOTA_Item.EtherealBlade.Target")
        target:EmitSound("Hero_Pugna.NetherBlastPreCast.TI9")
        target:EmitSound("DOTA_Item.EtherealBlade.Target")

        if target:GetTeam() == self.caster:GetTeam() then
            target:AddNewModifier(self.caster, self, "modifier_item_phantasmal_blade_ethereal", {duration = self.duration})
        else
            target:AddNewModifier(self.caster, self, "modifier_item_phantasmal_blade_ethereal", {duration = self.duration})

            local effect_cast = ParticleManager:CreateParticle( "particles/stygian/phantasmal_blade_aoe.vpcf", PATTACH_WORLDORIGIN, nil )
            ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
            ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 1, 1 ) )

            local damageTable = {
                victim = target,
                damage = self.caster:GetPrimaryStatValue() * self.blast_agility_multiplier + self.blast_damage_base,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                attacker = self.caster,
                ability = self
            }

            ApplyDamage(damageTable)

            local point = vLocation
            local radius_damage = (self.caster:GetPrimaryStatValue() * self.blast_agility_multiplier + self.blast_damage_base)/2

            local units = FindUnitsInRadius(
                self:GetCaster():GetTeamNumber(),
                point,
                self:GetCaster(),
                self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                0,
                0,
                false
            )

            if #units > 0 then
                for _,unit in pairs(units) do

                    ApplyDamage({
                        attacker = self:GetCaster(),
                        victim = unit,
                        damage = radius_damage,
                        ability = self,
                        damage_type = DAMAGE_TYPE_MAGICAL
                    })

                    if target:IsAlive() then
                        target:AddNewModifier(self.caster, self, "modifier_item_phantasmal_blade_slowing", {duration = self.duration})
                    end
                end
            end
        end
    end
end

modifier_item_phantasmal_blade = class({})

function modifier_item_phantasmal_blade:IsHidden() 
    return true 
end

function modifier_item_phantasmal_blade:IsPurgable() 
    return false
end

function modifier_item_phantasmal_blade:RemoveOnDeath()	
    return false 
end

function modifier_item_phantasmal_blade:GetAttributes()	
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_phantasmal_blade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end

function modifier_item_phantasmal_blade:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_phantasmal_blade:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_phantasmal_blade:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end


modifier_item_phantasmal_blade_ethereal = class({})

function modifier_item_phantasmal_blade_ethereal:GetStatusEffectName()
    return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_item_phantasmal_blade_ethereal:OnCreated()
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

    self.ethereal_damage_bonus = self:GetAbility():GetSpecialValueFor("ethereal_damage_bonus")

end


function modifier_item_phantasmal_blade_ethereal:OnRefresh()
    self:OnCreated()
end

function modifier_item_phantasmal_blade_ethereal:CheckState()
    local state = {
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_DISARMED] = true
    }

    return state
end

function modifier_item_phantasmal_blade_ethereal:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
    }

    return decFuncs
end

function modifier_item_phantasmal_blade_ethereal:GetModifierMagicalResistanceBonus()
    return self.ethereal_damage_bonus
end

function modifier_item_phantasmal_blade_ethereal:GetAbsoluteNoDamagePhysical()
    return 1
end

modifier_item_phantasmal_blade_slowing = class({})

function modifier_item_phantasmal_blade_slowing:OnCreated()
    
end

function modifier_item_phantasmal_blade_slowing:OnRefresh()
    self:OnCreated()
end

function modifier_item_phantasmal_blade_slowing:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_item_phantasmal_blade_slowing:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("blast_movement_slow")
end


