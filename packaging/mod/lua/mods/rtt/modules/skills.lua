return {
    id = "rtt.skills",
    key = "skills",
    order = 50,
    depends = { "rtt.core" },
    demonstrator = "experience event observation for future skill progression",
    probe = function() return "skill-framework-ready" end,
    on_player_gain_experience = function(state, ...)
        state.experienceEvents = (state.experienceEvents or 0) + 1
    end,
}
