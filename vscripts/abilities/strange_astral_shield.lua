strange_astral_shield = class({})
LinkLuaModifier ("modifier_strange_astral_shield", "abilities/strange_astral_shield.lua", LUA_MODIFIER_MOTION_NONE)

function strange_astral_shield:OnSpellStart()
    if IsServer() then
        local hTarget = self:GetCursorTarget()
		local stun_duration = self:GetSpecialValueFor( "stun_duration" )

        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_strange_astral_shield", { duration = self:GetSpecialValueFor( "duration" ) } )
        
        EmitSoundOn( "Hero_Bane.Enfeeble.Cast", hTarget )
    end
end

modifier_strange_astral_shield = class({})

function modifier_strange_astral_shield:IsHidden() return false end
function modifier_strange_astral_shield:IsPurgable() return false end

modifier_strange_astral_shield.m_hDamageData = 0
modifier_strange_astral_shield.m_hLastDamageDealer = nil

function modifier_strange_astral_shield:OnCreated( kv )
    if IsServer() then
        self.m_hDamageData = 0
        self.m_hLastDamageDealer = nil

        self.block = self:GetAbility():GetSpecialValueFor("damage_absorb")

        if self:GetCaster():HasTalent("special_bonus_unique_strange_4") then
            self.block = self.block + self:GetCaster():FindTalentValue("special_bonus_unique_strange_4")
        end

		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/ember_spirit/ember_ti9/ember_ti9_flameguard.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 2, Vector(300, 0, 0) )
		self:AddParticle( nFXIndex, false, false, -1, false, true )
	end
end

function modifier_strange_astral_shield:OnDestroy()
    if IsServer() then
        local damage = self.m_hDamageData - self.block

        if damage > 0 and self.m_hLastDamageDealer ~= nil and (not self.m_hLastDamageDealer:IsNull()) then
            ApplyDamage ( {
                victim = self:GetParent(),
                attacker = self.m_hLastDamageDealer,
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self:GetAbility(),
                damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_HPLOSS,
            })

            EmitSoundOn("Hero_Bane.Nightmare.End", self:GetParent())
        end
	end
end

function modifier_strange_astral_shield:OnWantsApplyDamage(params)
    if IsServer() then
        ---- if parent == victim from damage filter
        if EntIndexToHScript(params.entindex_victim_const) == self:GetParent() and params.damagetype_const ~= DAMAGE_TYPE_PHYSICAL then
            self.m_hDamageData = self.m_hDamageData + params.damage
            self.m_hLastDamageDealer = EntIndexToHScript(params.entindex_attacker_const)

            params.damage = 0
        end
    end
end
