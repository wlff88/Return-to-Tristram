local lootFilter = {}

lootFilter.config = {
    enabled = true,
    -- Hide labels only for cheap normal equipment. The item itself is never
    -- removed, altered, or made unpickable.
    minNormalEquipmentValue = 200,
}

function lootFilter.shouldShow(item)
    if not lootFilter.config.enabled then
        return true
    end

    -- DevilutionX item_quality: 0 = normal, 1 = magic, 2 = unique.
    if item.magical ~= 0 then
        return true
    end

    -- Never hide currency, consumables, quest/misc objects, or anything that
    -- is not equipment. This makes the default filter deliberately safe.
    if item:isGold() or item:isUsable() or not item:isEquipment() then
        return true
    end

    return item.value >= lootFilter.config.minNormalEquipmentValue
end

return lootFilter
