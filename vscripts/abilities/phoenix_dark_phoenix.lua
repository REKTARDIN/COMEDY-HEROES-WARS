if phoenix_dark_phoenix == nil then phoenix_dark_phoenix = class({}) end

LinkLuaModifier("modifier_phoenix_dark_phoenix", "abilities/phoenix_dark_phoenix.lua", LUA_MODIFIER_MOTION_NONE)

function phoenix_dark_phoenix:IsSellable()
    return false
end

function phoenix_dark_phoenix:OnUpgrade()
    if IsServer() then
        self.ability = self:GetCaster():FindAbilityByName("phoenix_icarus")
        self.ability:SetLevel(self:GetLevel())
    end
end

phoenix_dark_phoenix.models = nil
phoenix_dark_phoenix.ability = nil

function phoenix_dark_phoenix:AddModels()
    if IsServer() then
        self.models = {}

        local a = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/phoenix/phoenix_wings.vmdl"})
        a:FollowEntity(self:GetCaster(), true)

        local b = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/phoenix/phoenix_wings_fx.vmdl"})
        b:FollowEntity(self:GetCaster(), true)

        local c = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/phoenix/phoenix_bird_head.vmdl"})
        c:FollowEntity(self:GetCaster(), true)

        table.insert( self.models, a )
        table.insert( self.models, b )
        table.insert( self.models, c )
    end
end

function phoenix_dark_phoenix:OnSpellStart()
	local duration = self:GetSpecialValueFor(  "duration" )

	if self:GetCaster():HasTalent("special_bonus_unique_jean_1") then
        duration = self:GetCaster():FindTalentValue("special_bonus_unique_jean_1") + duration
	end
	
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_phoenix_dark_phoenix", { duration = duration } )

	local nFXIndex = ParticleManager:CreateParticle( "particles/addons_gameplay/pit_lava_blast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetCaster():GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "Hero_Phoenix.SuperNova.Explode", self:GetCaster() )
end

if modifier_phoenix_dark_phoenix == nil then modifier_phoenix_dark_phoenix = class({}) end

function modifier_phoenix_dark_phoenix:RemoveOnDeath() return true end
function modifier_phoenix_dark_phoenix:IsPurgable() return false end
function modifier_phoenix_dark_phoenix:IsHidden() return false end
function modifier_phoenix_dark_phoenix:IsAura() return true end
function modifier_phoenix_dark_phoenix:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_phoenix_dark_phoenix:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_phoenix_dark_phoenix:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_phoenix_dark_phoenix:GetAuraSearchFlags()	return 0 end
function modifier_phoenix_dark_phoenix:GetModifierAura() return "modifier_phoenix_fire_spirit_burn" end

function modifier_phoenix_dark_phoenix:GetEffectName()
	return "particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf"
end

function modifier_phoenix_dark_phoenix:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_phoenix_dark_phoenix:OnCreated(table)
	if IsServer() then
        local caster = self:GetParent()
        
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_ambient.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() );
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetOrigin(), true );
		ParticleManager:SetParticleControlEnt( nFXIndex, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_tailbase", self:GetParent():GetAbsOrigin(), true );
        self:AddParticle(nFXIndex, false, false, -1, false, false)

        if self:GetAbility().models == nil then
            self:GetAbility():AddModels()
        end

        for k,v in pairs(self:GetAbility().models) do
            v:RemoveEffects(EF_NODRAW)
        end

        self:GetAbility().ability:SetHidden(false)
	end
end

function modifier_phoenix_dark_phoenix:OnDestroy()
	if IsServer() then
        local caster = self:GetParent()
        
		EmitSoundOn("Hero_Phoenix.FireSpirits.Launch", caster)

        for k,v in pairs(self:GetAbility().models) do
            v:AddEffects(EF_NODRAW)
        end

        self:GetAbility().ability:SetHidden(true)
	end
end

function modifier_phoenix_dark_phoenix:DeclareFunctions() --we want to use these functions in this item
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end


function modifier_phoenix_dark_phoenix:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true
	}

	return state
end

function modifier_phoenix_dark_phoenix:GetModifierModelChange( params )
    return "models/heroes/phoenix/phoenix_bird.vmdl"
end

function modifier_phoenix_dark_phoenix:GetModifierSpellAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "spell_amp" )
end

function modifier_phoenix_dark_phoenix:GetModifierCastRangeBonus( params )
    return self:GetAbility():GetSpecialValueFor( "range_bonus" )
end

function modifier_phoenix_dark_phoenix:GetModifierAttackRangeBonus( params )
    return self:GetAbility():GetSpecialValueFor( "range_bonus" )
end

function modifier_phoenix_dark_phoenix:GetAttackSound( params )
    return "Hero_Phoenix.Attack"
end

