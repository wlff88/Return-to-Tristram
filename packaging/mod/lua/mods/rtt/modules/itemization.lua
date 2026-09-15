return {
    id = "rtt.itemization",
    key = "itemization",
    order = 60,
    depends = { "rtt.core" },
    demonstrator = "ItemDataLoaded lifecycle observation for stable-ID item systems",
    probe = function() return "itemization-framework-ready" end,
    on_item_data_loaded = function(state) state.itemDataLoads = (state.itemDataLoads or 0) + 1 end,
    on_unique_item_data_loaded = function(state) state.uniqueItemDataLoads = (state.uniqueItemDataLoads or 0) + 1 end,
}
