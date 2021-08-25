flash_team = class({})

LinkLuaModifier("modifier_flash_team", "abilities/flash_team.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flash_team_killer_frost", "abilities/flash_team.lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
EF_TEAM_VIBE = "Vibe" ---claws
EF_TEAM_FROST = "Frost" ---blade
EF_TEAM_SPEEDFORCE = "Speedforce" ---punch

flash_team.team = "Not_team"
flash_team.team_id = 0

function flash_team:IsStealable()
    return false
end

function flash_team:ProcsMagicStick()
    return false
end

function flash_team:GetIntrinsicModifierName()
    return "modifier_flash_team"
end

function flash_team:GetAbilityTextureName()
    if self:GetCaster():GetModifierStackCount(self:GetIntrinsicModifierName(), self:GetCaster()) == 1 then return "custom/flash_team_frost" end
    if self:GetCaster():GetModifierStackCount(self:GetIntrinsicModifierName(), self:GetCaster()) == 2 then return "custom/flash_team_vibe" end
    if self:GetCaster():GetModifierStackCount(self:GetIntrinsicModifierName(), self:GetCaster()) == 3 then return "custom/flash_team_speedforce" end

    return self.BaseClass.GetAbilityTextureName(self)
end

function flash_team:ChangeTeam(team)
    if IsServer() then
    
        if team == 1 then self.team = EF_TEAM_FROST EmitSoundOn("Hero_Juggernaut.Attack", self:GetCaster())
        elseif (team == 2) then self.team = EF_TEAM_VIBE EmitSoundOn("Hero_Lycan.Attack", self:GetCaster())
        elseif (team == 3) then self.team = EF_TEAM_SPEEDFORCE EmitSoundOn("Hero_OgreMagi.Attack", self:GetCaster())
        end

        self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName()):ForceRefresh()
    end
end
--------------------------------------------------------------------------------

function flash_team:OnSpellStart()
    if IsServer() then
        self.team_id = self.team_id + 1
        if self.team_id > 3 then self.team_id = 1 end

        self:ChangeTeam(self.team_id)
    end
end

if not modifier_flash_team then modifier_flash_team = class({}) end


function modifier_flash_team:IsHidden() return true end
function modifier_flash_team:IsPurgable() return false end

function modifier_flash_team:OnCreated(params)
    if IsServer() then self:StartIntervalThink(0.1) end
end

function modifier_flash_team:OnIntervalThink()
    if IsServer() then
        self:SetStackCount(self:GetAbility().team_id)
    end
end

function modifier_flash_team:TeamFrost()
    if self:GetStackCount() == 1 then return true end
end

function modifier_flash_team:TeamVibe()
    if self:GetStackCount() == 2 then return true end
end

function modifier_flash_team:TeamSpeedforce()
    if self:GetStackCount() == 3 then return true end
end

function modifier_flash_team:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
    }

    return funcs
end

function modifier_flash_team:GetModifierProcAttack_BonusDamage_Magical (params)
    if IsServer() then
        if self:TeamVibe() then if RollPercentage(self:GetAbility():GetSpecialValueFor ("vibe_bash_chance")) then
            
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = 0.5})

            EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", params.target)
        
                return self:GetAbility():GetSpecialValueFor ("vibe_damage")
            end
        end
    end
end

function modifier_flash_team:OnAttackLanded (params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            if not params.target:IsBuilding() and RollPercentage(self:GetAbility():GetSpecialValueFor("speedforce_lightning_chance")) and self:TeamSpeedforce() then
                local hTarget = params.target
                local caster = params.attacker

                local ability = caster:FindAbilityByName("flash_speedforce_lightning")

                    if ability then
                        caster:SetCursorCastTarget(hTarget)
                        caster:SetCursorPosition(hTarget:GetAbsOrigin())

                    ability:CastAbility()           
            end
        end

        if params.target ~= nil and params.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and self:TeamFrost() then
        
            local duration = self:GetAbility():GetSpecialValueFor("frost_duration")
    
            local target = params.target

                EmitSoundOn("", hTarget)

                target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_flash_team_killer_frost", {duration = duration})    
            end
        end
    end
end

function modifier_flash_team:GetAttributes ()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end

if modifier_flash_team_killer_frost == nil then modifier_flash_team_killer_frost = class({}) end

function modifier_flash_team_killer_frost:IsBuff()
    return false
end

function modifier_flash_team_killer_frost:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_flash_team_killer_frost:GetStatusEffectName ()
    return "particles/status_fx/status_effect_frost.vpcf"
end

--------------------------------------------------------------------------------

function modifier_flash_team_killer_frost:StatusEffectPriority ()
    return 1000
end

function modifier_flash_team_killer_frost:GetModifierAttackSpeedBonus_Constant (params)
    return self:GetAbility():GetSpecialValueFor ("frost_pct")
end

function modifier_flash_team_killer_frost:GetModifierMoveSpeedBonus_Percentage (params)
    return self:GetAbility():GetSpecialValueFor("frost_pct")
end

function modifier_flash_team_killer_frost:GetModifierHPRegenAmplify_Percentage (params)
    return self:GetAbility():GetSpecialValueFor ("frost_pct")
end

function modifier_flash_team_killer_frost:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end
