LinkLuaModifier ("modifier_collector_soul_burn_thinker", "abilities/collector_soul_burn.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_collector_soul_burn", "abilities/collector_soul_burn.lua", LUA_MODIFIER_MOTION_NONE)

collector_soul_burn = class({})

function collector_soul_burn:GetAOERadius()
    return self:GetSpecialValueFor("radius") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_collector_1") or 0)
end

function collector_soul_burn:GetBehavior ()
    return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT
end

function collector_soul_burn:OnSpellStart ()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local team_id = caster:GetTeamNumber()
    local duration = self:GetSpecialValueFor("duration")
    
    CreateModifierThinker (caster, self, "modifier_collector_soul_burn_thinker", {duration = duration }, point, team_id, false)
   
    GridNav:DestroyTreesAroundPoint (point, 500, false)

    EmitSoundOn("Hero_KeeperOfTheLight.Recall.Cast", caster)
end

modifier_collector_soul_burn_thinker = class({})

function modifier_collector_soul_burn_thinker:OnCreated (event)
    local thinker = self:GetParent()
    local ability = self:GetAbility()
  
    self.team_number = thinker:GetTeamNumber()
    self.radius = ability:GetAOERadius()
  
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/heroes/hero_collector/collector_soul_burn.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( nFXIndex, 0, thinker:GetAbsOrigin())
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(self.radius, self.radius, 0))
        ParticleManager:SetParticleControl( nFXIndex, 2, Vector(self.radius, self.radius, 0))
        ParticleManager:SetParticleControl( nFXIndex, 3, Vector(self.radius, self.radius, 0))

        self:AddParticle( nFXIndex, false, false, -1, false, true )

        EmitSoundOn("Hero_KeeperOfTheLight.Recall.Target", thinker)
    end
end

function modifier_collector_soul_burn_thinker:CheckState() return {[MODIFIER_STATE_PROVIDES_VISION] = true} end
function modifier_collector_soul_burn_thinker:IsAura() return true end
function modifier_collector_soul_burn_thinker:IsHidden() return true end
function modifier_collector_soul_burn_thinker:IsPurgable() return false end
function modifier_collector_soul_burn_thinker:GetAuraRadius() return self.radius end
function modifier_collector_soul_burn_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_collector_soul_burn_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_collector_soul_burn_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_collector_soul_burn_thinker:GetModifierAura() return "modifier_collector_soul_burn" end

if modifier_collector_soul_burn == nil then modifier_collector_soul_burn = class({}) end

function modifier_collector_soul_burn:OnCreated(params)
    if IsServer() then
        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self:GetAbility():GetAbilityDamage(),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility()
        })
    end
end

function modifier_collector_soul_burn:IsDebuff() return true end
function modifier_collector_soul_burn:IsHidden() return true end
function modifier_collector_soul_burn:IsPurgable() return false end
function modifier_collector_soul_burn:GetEffectName() return "particles/items4_fx/nullifier_mute_debuff_cloud.vpcf" end
function modifier_collector_soul_burn:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_collector_soul_burn:GetStatusEffectName() return "particles/units/heroes/hero_demonartist/demonartist_curse_status_effect.vpcf" end
function modifier_collector_soul_burn:StatusEffectPriority() return 1000 end
function modifier_collector_soul_burn:CheckState() return { [MODIFIER_STATE_SPECIALLY_DENIABLE] = true } end
function modifier_collector_soul_burn:DeclareFunctions() return { MODIFIER_EVENT_ON_SPENT_MANA } end
function modifier_collector_soul_burn:OnSpentMana( params ) 
    if IsServer() then
        if params.unit == self:GetParent() then
            local mana_leak = params.cost * (self:GetAbility():GetSpecialValueFor("mana_ptc") / 100)
            self:GetParent():SetMana(self:GetParent():GetMana() - mana_leak)
        end
    end
end
 