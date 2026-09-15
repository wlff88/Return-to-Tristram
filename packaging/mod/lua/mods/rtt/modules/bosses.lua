return {
    id = "rtt.bosses",
    key = "bosses",
    order = 90,
    depends = { "rtt.core", "rtt.monsters" },
    demonstrator = "UniqueMonsterDataLoaded lifecycle observation for future boss phases",
    probe = function() return "boss-framework-ready" end,
    on_unique_monster_data_loaded = function(state) state.uniqueMonsterDataLoads = (state.uniqueMonsterDataLoads or 0) + 1 end,
}
