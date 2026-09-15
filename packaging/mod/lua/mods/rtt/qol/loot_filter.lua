local userConfig = require("mods.rtt.qol.loot_filter_config")

local lootFilter = {}

-- Loot Filter 2.0 remains presentation-only. A false result suppresses only the
-- ground label; the item still exists in the world and remains pickable.
lootFilter.presets = {
    permissive = {
        weapon = 0,
        armor = 0,
        jewelry = 0,
        equipment = 0,
    },
    balanced = {
        weapon = 200,
        armor = 200,
        jewelry = 0,
        equipment = 200,
    },
    strict = {
        weapon = 750,
        armor = 750,
        jewelry = 250,
        equipment = 750,
    },
}

lootFilter.config = userConfig

local function contains(list, value)
    for _, candidate in ipairs(list or {}) do
        if candidate == value then
            return true
        end
    end
    return false
end

local function activePreset()
    local preset = lootFilter.presets[userConfig.preset]
    if preset == nil then
        return lootFilter.presets.balanced
    end
    return preset
end

local function categoryFor(item)
    if item:isWeapon() then
        return "weapon"
    end
    if item:isArmor() or item:isHelm() or item:isShield() then
        return "armor"
    end
    if item:isJewelry() then
        return "jewelry"
    end
    return "equipment"
end

local function minimumValue(category)
    local overrides = userConfig.normalValueOverrides or {}
    local override = overrides[category]
    if type(override) == "number" then
        return math.max(0, override)
    end
    return activePreset()[category] or activePreset().equipment
end

function lootFilter.getActivePreset()
    return userConfig.preset or "balanced"
end

function lootFilter.shouldShow(item)
    if userConfig.enabled == false then
        return true
    end

    -- DevilutionX item_quality: 0 = normal, 1 = magic, 2 = unique.
    -- RTT never suppresses labels for generated-quality items at this stage.
    if item.magical ~= 0 then
        return true
    end

    -- Safety floor: currency, consumables, quests/misc and any non-equipment
    -- always remain labelled. User rules can only hide NORMAL EQUIPMENT.
    if item:isGold() or item:isUsable() or not item:isEquipment() then
        return true
    end

    local itemName = item:getName()
    if contains(userConfig.alwaysShowNames, itemName) then
        return true
    end
    if contains(userConfig.hideNormalNames, itemName) then
        return false
    end

    local category = categoryFor(item)
    return item.value >= minimumValue(category)
end

return lootFilter
