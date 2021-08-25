hellspont_fireballs = class({})

function hellspont_fireballs:OnSpellStart()

    local caster = self:GetCaster()
    local point = self:GetCursorPosition() + RandomVector(1)

    local cards_radius = self:GetSpecialValueFor("cards_radius")
    local cards_speed = self:GetSpecialValueFor("cards_speed")
    local cards_range = self:GetSpecialValueFor("cards_range") 
    local cards_spread = self:GetSpecialValueFor("cards_spread")
    local cards_count = self:GetSpecialValueFor("cards_count")

    local direction = (point - caster:GetAbsOrigin()):Normalized()

    local start_angle = start_angle
    local interval_angle = 0

    if cards_count == 1 then
        start_angle = 0
    else
        start_angle = cards_spread/2 * (-1)
        interval_angle = cards_spread/(cards_count - 1)
    end
    
    for i = 1, cards_count, 1 do
        local angle = start_angle + ( i-1 ) * interval_angle
        local angle = math.rad(angle) 
        
        local dir1 = direction.x * math.cos(angle) - direction.y * math.sin(angle)
        local dir2 = direction.x * math.sin(angle) + direction.y * math.cos(angle)
        local dir3 = direction.z

        local vector = Vector(dir1, dir2, dir3):Normalized()

        local velocity = vector * cards_speed

        local info = {
        Source = caster,
        Ability = self,
        EffectName = "particles/econ/items/troll_warlord/troll_ti10_shoulder/troll_ti10_whirling_axe_ranged.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),

        fDistance = cards_range,
        fStartRadius = cards_radius,
        fEndRadius = cards_radius,
        
        bHasFrontalCone = false,
        bReplaceExisting = false,

        iUnitTargetTeam = self:GetAbilityTargetTeam(),
        iUnitTargetFlags = self:GetAbilityTargetFlags(),
        iUnitTargetType = self:GetAbilityTargetType(),

        fExpireTime = GameRules:GetGameTime() + 10.0,

        vVelocity = Vector(velocity.x, velocity.y, 0),
        bProvidesVision = false,
    }

    ProjectileManager:CreateLinearProjectile(info)
end

    EmitSoundOn("Hero_VengefulSpirit.MagicMissile", caster)
end

function hellspont_fireballs:OnProjectileHit(hTarget, vLocation)

    local damage = self:GetSpecialValueFor("cards_damage")

    local damage_table = {  
    victim = hTarget,
    attacker = self:GetCaster(),
    damage = damage,
    damage_type = self:GetAbilityDamageType(),
    ability = self }

    ApplyDamage(damage_table)

    EmitSoundOn("Hero_VengefulSpirit.MagicMissile", hTarget)
end