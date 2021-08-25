typhus_locust_of_decay = class({})

function typhus_locust_of_decay:OnSpellStart()

    local caster = self:GetCaster()
    local point = self:GetCursorPosition() + RandomVector(1)

    local radius = self:GetSpecialValueFor("radius")
    local speed = self:GetSpecialValueFor("speed")
    local range = self:GetSpecialValueFor("range") + caster:GetCastRangeBonus()
    local spread = self:GetSpecialValueFor("spread")
    local count = self:GetSpecialValueFor("count")

    local direction = (point - caster:GetAbsOrigin()):Normalized()

    local start_angle = start_angle
    local interval_angle = 0

    if count == 1 then
        start_angle = 0
    else
        start_angle = spread/2 * (-1)
        interval_angle = spread/(spread - 1)
    end
    
    for i = 1, count, 1 do
        local angle = start_angle + ( i-1 ) * interval_angle
        local angle = math.rad(angle) 
        
        local dir1 = direction.x * math.cos(angle) - direction.y * math.sin(angle)
        local dir2 = direction.x * math.sin(angle) + direction.y * math.cos(angle)
        local dir3 = direction.z

        local vector = Vector(dir1, dir2, dir3):Normalized()

        local velocity = vector * speed

        local info = {
        Source = caster,
        Ability = self,
        EffectName = "particles/stygian/typhus_swarm_projectile.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),

        fDistance = range,
        fStartRadius = radius,
        fEndRadius = radius,
        
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

    EmitSoundOn("Hero_Undying.Decay.Transfer", caster)
end

function typhus_locust_of_decay:OnProjectileHit(hTarget, vLocation)

    local damage = self:GetSpecialValueFor("damage")

    local damage_table = {  
    victim = hTarget,
    attacker = self:GetCaster(),
    damage = damage,
    damage_type = self:GetAbilityDamageType(),
    ability = self }

    ApplyDamage(damage_table)

    EmitSoundOn("Hero_Undying.Decay.Target", hTarget)
end