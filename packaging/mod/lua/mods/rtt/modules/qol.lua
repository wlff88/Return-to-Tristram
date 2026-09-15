local lootFilter = require("mods.rtt.qol.loot_filter")

return {
    id = "rtt.qol",
    key = "qol",
    order = 20,
    depends = { "rtt.core" },
    demonstrator = "Lua-driven item-label loot filter",
    probe = function() return "loot-filter-ready" end,
    on_init = function(state, context)
        if context.events.ShouldShowItemLabel == nil then
            context.events.registerCustom("ShouldShowItemLabel")
        end
        context.events.ShouldShowItemLabel.add(lootFilter.shouldShow)
        state.lootFilterRegistered = true
    end,
}
