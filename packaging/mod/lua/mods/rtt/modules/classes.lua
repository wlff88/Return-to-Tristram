return {
    id = "rtt.classes",
    key = "classes",
    order = 40,
    depends = { "rtt.core" },
    demonstrator = "class-table lifecycle registration without class mutation",
    probe = function() return "class-framework-ready" end,
    on_game_start = function(state) state.gameStarts = (state.gameStarts or 0) + 1 end,
}
