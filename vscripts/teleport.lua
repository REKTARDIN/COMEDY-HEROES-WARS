Teleports = class({})

Teleports.positions = {}

function Spawn()
    local radius = thisEntity:Attribute_GetFloatValue("radius", 300)
    local cooldown = thisEntity:Attribute_GetFloatValue("cooldown", 30)

    thisEntity.cooldown = 0
    thisEntity.totalCoodlown = cooldown

    thisEntity:SetContextThink("Think", function() Teleports:Think(thisEntity) return 0.03 end, 0.03)

    Teleports.positions[thisEntity] = Vector(thisEntity:Attribute_GetFloatValue("pos_x", 0), thisEntity:Attribute_GetFloatValue("pos_y", 0), thisEntity:Attribute_GetFloatValue("pos_z", 0))

    print(thisEntity:GetClassname())
end

function Teleports:Think(entity) 
    if entity and entity.cooldown then
        if entity.cooldown > 0 then
            entity.cooldown = entity.cooldown - 0.03
        end 
    end
end

function OnEnterTrigger(params)

end

function OnLeftTrigger(params)

end