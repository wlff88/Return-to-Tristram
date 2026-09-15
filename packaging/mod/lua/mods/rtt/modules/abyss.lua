return {
    id = "rtt.abyss",
    key = "abyss",
    order = 100,
    depends = { "rtt.core", "rtt.monsters", "rtt.bosses" },
    demonstrator = "GameStart lifecycle observation for future deterministic Abyss sessions",
    probe = function() return "abyss-framework-ready" end,
    on_game_start = function(state) state.gameStarts = (state.gameStarts or 0) + 1 end,
}
