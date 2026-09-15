return {
    id = "rtt.crafting",
    key = "crafting",
    order = 70,
    depends = { "rtt.core", "rtt.itemization" },
    demonstrator = "store-open lifecycle observation for future crafting services",
    probe = function() return "crafting-framework-ready" end,
    on_store_opened = function(state, storeName)
        state.storeOpens = (state.storeOpens or 0) + 1
        state.lastStore = storeName
    end,
}
