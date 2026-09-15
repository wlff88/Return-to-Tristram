return {
    id = "rtt.monsters",
    key = "monsters",
    order = 80,
    depends = { "rtt.core" },
    demonstrator = "MonsterDataLoaded lifecycle observation",
    probe = function() return "monster-framework-ready" end,
    on_monster_data_loaded = function(state) state.monsterDataLoads = (state.monsterDataLoads or 0) + 1 end,
}
