local catalog = require("mods.rtt.data.phase4_catalog")

return {
    id = "rtt.crafting",
    key = "crafting",
    order = 70,
    depends = { "rtt.core", "rtt.itemization" },
    demonstrator = "Phase 4 stable recipe registry with mutation deferred to engine-safe item reconstruction",
    probe = function() return #catalog.crafting == 3 end,
    on_init = function(state)
        state.recipeCount = #catalog.crafting
        state.recipeIds = catalog.crafting
        state.mutationsEnabled = false
    end,
    recipes = catalog.crafting,
}
