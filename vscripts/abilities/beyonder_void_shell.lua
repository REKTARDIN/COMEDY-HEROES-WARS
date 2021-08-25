LinkLuaModifier ("modifier_beyonder_void_shell_passive", "abilities/beyonder_void_shell.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_beyonder_void_shell_active", "abilities/beyonder_void_shell.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_beyonder_void_shell_active_buff", "abilities/beyonder_void_shell.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_beyonder_void_shell_active_bkb", "abilities/beyonder_void_shell.lua", LUA_MODIFIER_MOTION_NONE)
beyonder_void_shell = class({})

function beyonder_void_shell:OnSpellStart()
    local duration = self:GetSpecialValueFor( "duration" )
    local duration_spikes = 1.5
    local caster = self:GetCaster()

    if self:GetCaster():HasScepter() then
        duration_spikes = 3.0
        caster:AddNewModifier(caster, self, "modifier_beyonder_void_shell_active_bkb", {duration = 2.0})
    end

    if self:GetCaster():HasTalent("special_bonus_unique_beyonder_2") then
        duration_spikes = duration_spikes + self:GetCaster():FindTalentValue("special_bonus_unique_beyonder_2")
    end

    caster:AddNewModifier(caster, self, "modifier_beyonder_void_shell_active", {duration = duration_spikes})
    caster:AddNewModifier(caster, self, "modifier_beyonder_void_shell_active_buff", {duration = duration})
end

modifier_beyonder_void_shell_active = class({})

function modifier_beyonder_void_shell_active:IsHidden() 
    return true
end

function modifier_beyonder_void_shell_active:RemoveOnDeath() 
    return false 
end

function modifier_beyonder_void_shell_active:IsPurgable() 
    return false 
end

function modifier_beyonder_void_shell_active:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.5)
    end
end

function modifier_beyonder_void_shell_active:OnIntervalThink()
    if IsServer() then 
        local caster = self:GetCaster()
        local radius = self:GetAbility():GetSpecialValueFor("radius")
        local damage = self:GetAbility():GetSpecialValueFor("spikes_base_damage")

        local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_void_spirit/pulse/void_spirit_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )

        EmitSoundOn( "Hero_VoidSpirit.Pulse", caster )
    
        -- Find Units in Radius
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(),	
            caster:GetOrigin(),	
            nil,	
            radius,	
            DOTA_UNIT_TARGET_TEAM_ENEMY,	
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	
            0,	
            false	
        )
    
        -- Apply Damage	 
        local damageTable = {
            attacker = caster,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility(), --Optional.
        }

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            damageTable.damage = damage
            ApplyDamage( damageTable ) 
        end
    end  
end

modifier_beyonder_void_shell_active_buff = class({})

function modifier_beyonder_void_shell_active_buff:IsHidden() 
    return false
end

function modifier_beyonder_void_shell_active_buff:RemoveOnDeath() 
    return false 
end

function modifier_beyonder_void_shell_active_buff:IsPurgable() 
    return true 
end

function modifier_beyonder_void_shell_active_buff:GetEffectName()
    return "particles/stygian/beyonder_void_rageecon/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_eztzhok.vpcf"
end
          
function modifier_beyonder_void_shell_active_buff:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function modifier_beyonder_void_shell_active_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor( "buff_bonus_attack_speed" )
end

function modifier_beyonder_void_shell_active_buff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor( "buff_bonus_magical_resistance" )
end 

modifier_beyonder_void_shell_active_bkb = class({})

function modifier_beyonder_void_shell_active_bkb:IsHidden() 
    return false
end

function modifier_beyonder_void_shell_active_bkb:RemoveOnDeath() 
    return false 
end

function modifier_beyonder_void_shell_active_bkb:IsPurgable() 
    return true 
end

function modifier_beyonder_void_shell_active_bkb:GetEffectName()
    return "particles/econ/items/silencer/silencer_ti6/silencer_last_word_status_ti6.vpcf"
end

function modifier_beyonder_void_shell_active_bkb:OnCreated()
    if IsServer() then
        self:GetParent():Purge(false, true, false, true, true)
    end
end

function modifier_beyonder_void_shell_active_bkb:CheckState() 
    return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_beyonder_void_shell_active_bkb:DeclareFunctions() 
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} 
end

function modifier_beyonder_void_shell_active_bkb:GetModifierMagicalResistanceBonus() 
    return 100 
end


