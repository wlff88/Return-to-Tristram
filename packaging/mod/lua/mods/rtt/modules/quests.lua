return {
    id = "rtt.quests",
    key = "quests",
    order = 30,
    depends = { "rtt.core" },
    demonstrator = "GameStart lifecycle observation for future quest state machines",
    probe = function() return "quest-lifecycle-ready" end,
    on_game_start = function(state) state.gameStarts = (state.gameStarts or 0) + 1 end,
}
