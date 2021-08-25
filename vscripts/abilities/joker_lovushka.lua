LinkLuaModifier(
    "joker_lovushka_thinker",
    "abilities/joker_lovushka.lua",
    LUA_MODIFIER_MOTION_NONE
)

local INTERVAL = 0.5

joker_lovushka = class({})

function joker_lovushka:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local team_id = caster:GetTeamNumber()

    local thinker = CreateModifierThinker(caster, self, "joker_lovushka_thinker", {duration = self:GetSpecialValueFor("duration")}, point, team_id, false)
    
    EmitSoundOn("Hero_Techies.LandMine.Plant", caster)
end

joker_lovushka_thinker = class({})

function joker_lovushka_thinker:OnCreated(event)
    if IsServer() then
        local thinker = self:GetParent()
        local ability = self:GetAbility()
        self.get_damage = self:GetCaster():GetAverageTrueAttackDamage(self:GetParent())
       
        self.activated = false

        self.duration = self:GetAbility():GetSpecialValueFor("active_duration")
        self.pct_damage = self:GetAbility():GetSpecialValueFor("attack_damage_pct")
        self.get_damage = self:GetCaster():GetAverageTrueAttackDamage(self:GetParent()) * self.pct_damage / 100
        self.damage = self:GetAbility():GetSpecialValueFor("spark_damage") + self.get_damage
        self.delay = self:GetAbility():GetSpecialValueFor("activation_delay") - (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_joker_2") or 0)
        self.radius = self:GetAbility():GetSpecialValueFor("radius")

        self.time_with_heroes = 0
        self.current_time = self.duration

        self:StartIntervalThink(INTERVAL)
        self:OnIntervalThink()
    
        self:GetParent():SetOriginalModel("models/items/rattletrap/frostivus2018_lighter_fighter_cog/frostivus2018_lighter_fighter_cog.vmdl")
        self:GetParent():SetModelScale(1.0)
    end
end

function joker_lovushka_thinker:OnIntervalThink()
    local thinker = self:GetParent()
    local thinker_pos = thinker:GetAbsOrigin()

    if not self.activated then
        local heroes = self:GetHeroesCountInRadius()
        local creeps = self:GetCreepsCountInRadius()

        if self:GetCaster():HasTalent("special_bonus_unique_joker_4") then
            if heroes > 0 or creeps > 0 then
                self.time_with_heroes = self.time_with_heroes + INTERVAL
            else 
                self.time_with_heroes = 0 
            end
        else 
            if heroes > 0 then
                self.time_with_heroes = self.time_with_heroes + INTERVAL
            else 
                self.time_with_heroes = 0 
            end
        end

        if self.time_with_heroes > self.delay then
            self.time_with_heroes = 0

            self.activated = true
        end
    else 
        local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
        if #units > 0 then
            for _,unit in pairs(units) do
                ApplyDamage(
                    {
                        attacker = self:GetAbility():GetCaster(),
                        victim = unit,
                        ability = self:GetAbility(),
                        damage = self.damage,
                        damage_type = self:GetAbility():GetAbilityDamageType()
                    }
                )

                EmitSoundOn("Hero_Bristleback.PistonProngs.QuillSpray.Cast", unit)
            end
        end

        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        EmitSoundOn( "Hero_Snapfire.ExplosiveShellsBuff.Attack", self:GetParent() )

        self.current_time = self.current_time - INTERVAL

        if self.current_time <= 0 then
            self:Destroy()

            UTIL_Remove(self:GetParent())
        end
    end
end

function joker_lovushka_thinker:GetHeroesCountInRadius()
    local heroes = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, FIND_CLOSEST, false )

    return #heroes
end

function joker_lovushka_thinker:GetCreepsCountInRadius()
    local creeps = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false )

    return #creeps
end

function joker_lovushka_thinker:OnDestroy()
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
    end
end

function joker_lovushka_thinker:CheckState()
    if self.duration then
        return {[MODIFIER_STATE_PROVIDES_VISION] = true}
    end
    return nil
end
