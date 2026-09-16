local catalog = require("mods.rtt.data.phase4_catalog")

local function countEntries(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

return {
    id = "rtt.itemization",
    key = "itemization",
    order = 60,
    depends = { "rtt.core" },
    demonstrator = "Phase 4 stable-ID itemization catalog and compact affix metadata contract",
    probe = function()
        -- affixByCode grows as new affix families are added (12 -> 15 when
        -- Marrow/vitality landed); a lower bound catches truncation without
        -- needing to bump this number on every future addition.
        return catalog.itemization.metadataVersion == 1
            and catalog.itemization.compactAffixMapVersion == 1
            and countEntries(catalog.itemization.affixByCode) >= 15
    end,
    on_init = function(state)
        state.metadataVersion = catalog.itemization.metadataVersion
        state.compactAffixMapVersion = catalog.itemization.compactAffixMapVersion
        state.registeredAffixes = countEntries(catalog.itemization.affixByCode)
        state.prototypeItems = #catalog.itemization.prototypeItems
        state.prototypeUniques = #catalog.itemization.prototypeUniques
        state.prototypeSets = #catalog.itemization.prototypeSets
    end,
    on_item_data_loaded = function(state)
        state.itemDataLoads = (state.itemDataLoads or 0) + 1
    end,
    on_unique_item_data_loaded = function(state)
        state.uniqueItemDataLoads = (state.uniqueItemDataLoads or 0) + 1
    end,
    catalog = catalog.itemization,
}
