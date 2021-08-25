if not zed_shadow_clones then zed_shadow_clones = class({}) end 

LinkLuaModifier( "modifier_zed_shadow_clones", "abilities/zed_shadow_clones", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zed_shadow_clones_debuff", "abilities/zed_shadow_clones", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zed_shadow_ilussion", "abilities/zed_shadow_clones", LUA_MODIFIER_MOTION_NONE )

zed_shadow_clones.shadows = {}

--------------------------------------------------------------------------------
-- Ability Start
function zed_shadow_clones:OnSpellStart()
    if IsServer() then
        local hTarget = self:GetCursorTarget()

        self.shadows = {}

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_zed_shadow_clones", {target = hTarget:entindex()})
    end
end

function zed_shadow_clones:GetClones()
    return self.shadows
end

function zed_shadow_clones:OnRushDone(hTarget)
    if IsServer() then
        local pos1 = hTarget:GetAbsOrigin() + hTarget:GetForwardVector() * 256.0
        local pos2 = hTarget:GetAbsOrigin() - hTarget:GetForwardVector() * 256.0

        local illusion = self:CreateIllusion(self:GetCaster(), pos1, hTarget)
        local illusion1 = self:CreateIllusion(self:GetCaster(), pos2, hTarget)

        table.insert(self.shadows, illusion)
        table.insert(self.shadows, illusion1)

        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_zed_shadow_clones_debuff", {duration = self:GetSpecialValueFor("clones_duration")})
    end
end

function zed_shadow_clones:CreateIllusion(caster, loc, target)
    local illusion = CreateUnitByName(caster:GetUnitName(), loc, true, caster, nil, caster:GetTeamNumber())  --handle_UnitOwner needs to be nil, or else it will crash the game.
    illusion:SetPlayerID(caster:GetPlayerOwnerID())
    illusion:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

    --Level up the illusion to the caster's level.
    local caster_level = caster:GetLevel()
    for i = 1, caster_level - 1 do
        illusion:HeroLevelUp(false)
    end

    --Set the illusion's available skill points to 0 and teach it the abilities the caster has.
    illusion:SetAbilityPoints(0)

    for ability_slot = 0, 15 do
        local individual_ability = caster:GetAbilityByIndex(ability_slot)
        if individual_ability ~= nil then
            local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
            if illusion_ability ~= nil then
                illusion_ability:SetLevel(individual_ability:GetLevel())
            end
        end
    end

    --Recreate the caster's items for the illusion.
    for item_slot = 0, 5 do
        local individual_item = caster:GetItemInSlot(item_slot)
        if individual_item ~= nil then
            local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
            illusion:AddItem(illusion_duplicate_item)
        end
    end

    illusion:AddNewModifier(caster, self, "modifier_zed_shadow_ilussion", {duration = self:GetSpecialValueFor("clones_duration")})
    illusion:MakeIllusion()

    Timers:CreateTimer(0.03, function()
        illusion:MoveToTargetToAttack(target)
    end)

    return illusion
end

if not modifier_zed_shadow_clones then modifier_zed_shadow_clones = class({}) end 

modifier_zed_shadow_clones = class({
    IsHidden = function() return true end,
    IsPurgable = function() return false end,
    RemoveOnDeath = function() return true end,
    CheckState = function() return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true} end
})
 
function modifier_zed_shadow_clones:GetEffectName()
    return "particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf"
end

function modifier_zed_shadow_clones:OnCreated(params)
    if not IsServer() then return end
    
    self.target = EntIndexToHScript(params.target)
    self.speed = self:GetAbility():GetSpecialValueFor("rush_speed")

    self:StartIntervalThink(FrameTime())
end

function modifier_zed_shadow_clones:OnIntervalThink()
    if not IsServer() then return end

    self:GetCaster():FaceTowards(self.target:GetAbsOrigin())

    self.distance = (self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()

    if self.distance > 160 then
        self:GetCaster():SetOrigin(self:GetCaster():GetAbsOrigin() + (self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized() * self.speed * FrameTime())
    else
        self:Destroy()
    end
end

function modifier_zed_shadow_clones:OnDestroy()
    if not IsServer() then return end

    local caster = self:GetCaster()

    self:GetAbility():OnRushDone(self.target)
end

modifier_zed_shadow_ilussion = class({
    CheckState = function() return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    } end

})

function modifier_zed_shadow_ilussion:GetStatusEffectName()
	return "particles/status_fx/status_effect_void_spirit_aether_remnant.vpcf"
end

function modifier_zed_shadow_ilussion:StatusEffectPriority()
	return 1000
end

function modifier_zed_shadow_ilussion:IsHidden()
	return true
end

function modifier_zed_shadow_ilussion:IsPermanent()
	return true
end

function modifier_zed_shadow_ilussion:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_zed_shadow_ilussion:IsPurgable()
	return false
end

function modifier_zed_shadow_ilussion:OnCreated(table)
	if IsServer() then 
		self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_illusion", {duration = self:GetAbility():GetSpecialValueFor("clones_duration"), outgoing_damage = 100, incoming_damage = 100})
        self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_kill", {duration = self:GetAbility():GetSpecialValueFor("clones_duration")})
	end
end

modifier_zed_shadow_clones_debuff = class({
    IsPurgable = function() return true end,
    GetStatusEffectName = function() return "particles/status_fx/status_effect_gods_strength.vpcf" end,
    StatusEffectPriority = function() return 1 end,
    GetEffectName = function() return "particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf" end,
    GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
    DeclareFunctions = function() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end,

})

function modifier_zed_shadow_clones_debuff:OnCreated()
    self.bonus_damage = 0 
end

function modifier_zed_shadow_clones_debuff:OnTakeDamage(params)	
    if params.unit == self:GetParent() then self.bonus_damage = self.bonus_damage + params.damage end 
end

--[[
    gain	0
new_pos	Vector 0000000000C21988 [0.000000 0.000000 0.000000]
process_procs	true
order_type	0
target	table: 0x00c123a0
octarine_tested	false
issuer_player_index	0
stout_tested	false
ignore_invis	false
fail_type	2163576
damage_category	0
reincarnate	false
ability_special_level	-1
damage	0
activity	-1
locket_amp_applied	false
ranged_attack	false
record	-1
unit	table: 0x00783228
do_not_consume	false
damage_type	32767
cost	125
diffusal_applied	false
mkb_tested	false
distance	0
no_attack_cooldown	false
damage_flags	0
original_damage	0
heart_regen_applied	false
ability	table: 0x00783678
basher_tested	false
sange_amp_applied	false
]]

function modifier_zed_shadow_clones_debuff:OnAbilityFullyCast(params)	
    if IsServer() then
        if params.unit == self:GetAbility():GetCaster() then 
            local units = self:GetAbility():GetClones()
    
            for _, clone in pairs(units) do
                if clone and (not params.ability:IsItem()) then  
                    local ability = clone:FindAbilityByName(params.ability:GetAbilityName())

                    if ability then
                        clone:SetCursorCastTarget(self:GetCaster():GetCursorCastTarget())
                        clone:SetCursorPosition(self:GetCaster():GetCursorPosition())

                        clone:SetForwardVector((self:GetCaster():GetCursorPosition() - clone:GetAbsOrigin()):Normalized())

                        ability:CastAbility() 
                    end
                end
            end
        end 
    end
end

function modifier_zed_shadow_clones_debuff:GetModifierMoveSpeedBonus_Percentage(params)	
    return -self:GetAbility():GetSpecialValueFor("debuff_slowing")
end

function modifier_zed_shadow_clones_debuff:OnDestroy()
	if IsServer() then
        EmitSoundOn ("Hero_ArcWarden.SparkWraith.Activate", self:GetParent())
        EmitSoundOn ("Hero_ArcWarden.SparkWraith.Damage", self:GetParent())

        EmitSoundOn ("Hero_ArcWarden.SparkWraith.Activate", self:GetAbility():GetCaster())
        EmitSoundOn ("Hero_ArcWarden.SparkWraith.Damage", self:GetAbility():GetCaster())

        local particle = ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, Vector(100, 0, 0))
        ParticleManager:ReleaseParticleIndex(particle)

        self:GetCaster():Heal(self.bonus_damage * self:GetAbility():GetSpecialValueFor("total_dmg_ptc") / 100, self:GetAbility())

        ApplyDamage({attacker = self:GetAbility():GetCaster(), victim = self:GetParent(), ability = self:GetAbility(), damage = self.bonus_damage * self:GetAbility():GetSpecialValueFor("total_dmg_ptc") / 100, damage_type = DAMAGE_TYPE_MAGICAL})

        self.bonus_damage = 0
	end
end
