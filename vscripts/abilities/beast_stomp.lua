beast_stomp = class({})
LinkLuaModifier( "modifier_beast_stomp", "abilities/beast_stomp.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_beast_stomp_stacks", "abilities/beast_stomp.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_beast_stomp_buff", "abilities/beast_stomp.lua", LUA_MODIFIER_MOTION_NONE )

function beast_stomp:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local duration = ability:GetSpecialValueFor("stomp_duration")

    caster:AddNewModifier(caster, ability, "modifier_beast_stomp_stacks", { duration = duration })
    caster:AddNewModifier(caster, ability, "modifier_beast_stomp", { duration = duration })
end

modifier_beast_stomp = class({})
function modifier_beast_stomp:IsDebuff() return false end
function modifier_beast_stomp:IsHidden() return true end
function modifier_beast_stomp:IsPurgable() return false end
function modifier_beast_stomp:OnCreated()
    if IsServer() then
        local rate = self:GetAbility():GetSpecialValueFor("stomp_tick")
        self:StartIntervalThink(rate)
    end
end

function modifier_beast_stomp:OnIntervalThink()
    local caster = self:GetParent()
    local ability = self:GetAbility()
    local radius = ability:GetSpecialValueFor("radius")
    local damage = ability:GetSpecialValueFor("stomp_damage")

    local damageTable = {
        -- victim = target,
        attacker = caster,
        damage = damage,
        damage_type = ability:GetAbilityDamageType(),
        ability = ability, --Optional.
    }

    -- find enemies
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),	-- int, your team number
        caster:GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    local herohit = false
    local stackgained = false
    local stacks = caster:GetModifierStackCount("modifier_beast_stomp_stacks", caster)

    for _,enemy in pairs(enemies) do
        if enemy:IsRealHero() then herohit = true end
        if herohit == true and stackgained == false then
            caster:SetModifierStackCount("modifier_beast_stomp_stacks", caster, stacks + 1)
            stackgained = true
        end

        damageTable.victim = enemy
        ApplyDamage(damageTable)
    end

    self:PlayEffects()

    if caster:GetModifierStackCount("modifier_beast_stomp_stacks", caster) == ability:GetSpecialValueFor("stunstacks") then
        caster:AddNewModifier(caster, ability, "modifier_beast_stomp_buff", { duration = ability:GetSpecialValueFor("buff_duration") })
    end
end

function modifier_beast_stomp:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end

function modifier_beast_stomp:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
    return decFuncs
end

function modifier_beast_stomp:GetActivityTranslationModifiers()
    return "stompy"
end

function modifier_beast_stomp:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf"
    local radius = self:GetAbility():GetSpecialValueFor("radius")

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_beast_stomp_stacks = class({})
function modifier_beast_stomp_stacks:IsDebuff() return false end
function modifier_beast_stomp_stacks:IsHidden() return false end
function modifier_beast_stomp_stacks:IsPurgable() return false end

modifier_beast_stomp_buff = class({})
function modifier_beast_stomp_buff:IsDebuff() return false end
function modifier_beast_stomp_buff:IsHidden() return false end
function modifier_beast_stomp_buff:IsPurgable() return true end

function modifier_beast_stomp_buff:DeclareFunctions()
    local funcs =
        {
            MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
        }
    return funcs
end

function modifier_beast_stomp_buff:GetModifierProcAttack_Feedback( params )
    local caster = self:GetParent()
    local ability = self:GetAbility()
    local damage = ability:GetSpecialValueFor("buff_damage") + caster:GetStrength()
    local stun = ability:GetSpecialValueFor("stun_duration")

    if IsServer() then
        EmitSoundOn( "Hero_EarthShaker.Totem.Attack", params.target )

        local passiveproc = false

        local damageTable = {
            victim = params.target,
            attacker = caster,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            ability = ability, --Optional.
        }
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, params.target, damage, nil)

        params.target:AddNewModifier(caster, ability, "modifier_stunned", { duration = stun })
        ApplyDamage(damageTable)

        self:Destroy()
    end
end
