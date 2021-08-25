item_chaos_asteroid_hammer = class({})

LinkLuaModifier("modifier_item_chaos_asteroid_hammer", "items/item_chaos_asteroid_hammer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_chaos_asteroid_hammer_burn", "items/item_chaos_asteroid_hammer.lua", LUA_MODIFIER_MOTION_NONE)


function item_chaos_asteroid_hammer:GetIntrinsicModifierName()
    return "modifier_item_chaos_asteroid_hammer"
end

function item_chaos_asteroid_hammer:GetAOERadius()
    return self:GetSpecialValueFor("impact_radius")
end

function item_chaos_asteroid_hammer:OnSpellStart()
    if IsServer() then
        local radius = self:GetSpecialValueFor("impact_radius")

        self.get_cursor_position = self:GetCursorPosition()

        AddFOWViewer(self:GetCaster():GetTeam(), self.get_cursor_position, radius, 3.8, false)

        self.aoe_particle = ParticleManager:CreateParticleForTeam("particles/stygian/asteroid_hammer_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeam())
        ParticleManager:SetParticleControl(self.aoe_particle, 0, self.get_cursor_position)
        ParticleManager:SetParticleControl(self.aoe_particle, 1, Vector(radius, 1, 1))

        self.cast_particle	= ParticleManager:CreateParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_cast_spirit_arc_pnt_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

        self:GetCaster():EmitSound("Hero_ElderTitan.EchoStomp.Channel.ti7_layer")
    end
end

function item_chaos_asteroid_hammer:OnChannelFinish(bInterrupted)
    if IsServer() then

        local land_time	= self:GetSpecialValueFor("land_time")
        local radius = self:GetSpecialValueFor("impact_radius")
        local damage = self:GetSpecialValueFor("impact_damage")
        local burn_duration = self:GetSpecialValueFor("burn_duration")
        local damage_buildings	= self:GetSpecialValueFor("impact_buildings_damage")
        local stun_duration = 2

        if bInterrupted then
            self:GetCaster():StopSound("DOTA_Item.MeteorHammer.Channel")

            ParticleManager:DestroyParticle(self.aoe_particle, true)
            ParticleManager:DestroyParticle(self.cast_particle, true)
        else
            self:GetCaster():EmitSound("Hero_ElderTitan.EchoStomp.Channel.ti7_layer")
            self:GetCaster():EmitSound("Hero_Invoker.ChaosMeteor.Cast")
            self:GetCaster():EmitSound("Hero_Invoker.ChaosMeteor.Impact")

            local meteor_particle = ParticleManager:CreateParticle("particles/stygian/asteroid_hammer.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(meteor_particle, 0, self.get_cursor_position + Vector(radius, 0, radius))
            ParticleManager:SetParticleControl(meteor_particle, 1, self.get_cursor_position)
            ParticleManager:SetParticleControl(meteor_particle, 2, Vector(land_time, 0, 0))
            ParticleManager:ReleaseParticleIndex(meteor_particle)

            Timers:CreateTimer(land_time, function()
                if not self:IsNull() then
                    GridNav:DestroyTreesAroundPoint(self.get_cursor_position, radius, true)

                    local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
                    ParticleManager:SetParticleControl(nFXIndex, 0, self.get_cursor_position)
                    ParticleManager:SetParticleControl(nFXIndex, 1, Vector(self:GetSpecialValueFor("impact_radius"), self:GetSpecialValueFor("impact_radius"), 0))

                    ParticleManager:ReleaseParticleIndex(nFXIndex)

                    EmitSoundOnLocationWithCaster(self.get_cursor_position, ("Hero_Phoenix.SuperNova.Explode"), self:GetCaster())

                    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                        self.get_cursor_position,
                        nil,
                        radius,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false)

                    for _, enemy in pairs(enemies) do
                        enemy:EmitSound("DOTA_Item.MeteorHammer.Damage")
                        enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = stun_duration})
                        enemy:AddNewModifier(self:GetCaster(), self, "modifier_item_chaos_asteroid_hammer_burn", {duration = burn_duration})

                        local impactDamage = damage

                        if enemy:IsBuilding() then
                            impactDamage = damage_buildings
                        end


                        local damageTable = {
                            victim 	= enemy,
                            damage 	= impactDamage,
                            damage_type	= DAMAGE_TYPE_MAGICAL,
                            damage_flags = DOTA_DAMAGE_FLAG_NONE,
                            attacker = self:GetCaster(),
                            ability = self
                        }

                        ApplyDamage(damageTable)
                    end
                end
            end)
        end
    end
    ParticleManager:ReleaseParticleIndex(self.aoe_particle)
    ParticleManager:ReleaseParticleIndex(self.cast_particle)
end

modifier_item_chaos_asteroid_hammer = class({})

function modifier_item_chaos_asteroid_hammer:IsHidden()	return true end
function modifier_item_chaos_asteroid_hammer:IsPurgable() return false end
function modifier_item_chaos_asteroid_hammer:RemoveOnDeath() return false end
function modifier_item_chaos_asteroid_hammer:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_chaos_asteroid_hammer:OnCreated()
    if IsServer() then
        if self:GetAbility() == nil then
            return
        end
    end
end

function modifier_item_chaos_asteroid_hammer:DeclareFunctions()
    local decFuncs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }

    return decFuncs
end

function modifier_item_chaos_asteroid_hammer:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_chaos_asteroid_hammer:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_chaos_asteroid_hammer:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_chaos_asteroid_hammer:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_chaos_asteroid_hammer:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

modifier_item_chaos_asteroid_hammer_burn = class({})

function modifier_item_chaos_asteroid_hammer_burn:GetEffectName()
    return "particles/items4_fx/meteor_hammer_spell_debuff.vpcf"
end

function modifier_item_chaos_asteroid_hammer_burn:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_chaos_asteroid_hammer_burn:OnCreated()
    if IsServer() then

        self.caster	= self:GetCaster()

        self.burn_thinker =	self:GetAbility():GetSpecialValueFor("burn_interval")

        self.affectedUnits	= {}

        table.insert(self.affectedUnits, self:GetParent())

        self.burn_damage = self:GetAbility():GetSpecialValueFor("burn_damage")

        if self:GetParent():IsBuilding() then
            self.burn_damage = self:GetAbility():GetSpecialValueFor("burn_damage_buildings")
        end

        self.damageTable = {
            victim 	= self:GetParent(),
            damage 	= self.burn_damage,
            damage_type	= DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            attacker = self.caster,
            ability = self:GetAbility()
        }

        self:StartIntervalThink(self.burn_thinker)
    end
end

function modifier_item_chaos_asteroid_hammer_burn:OnIntervalThink()
    if not IsServer() then return end

    ApplyDamage(self.damageTable)

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), self.burn_damage, nil)
end





