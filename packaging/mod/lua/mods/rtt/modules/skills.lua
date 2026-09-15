local catalog = require("mods.rtt.data.phase4_catalog")

local function countSkills()
    local count = 0
    for _ in pairs(catalog.skills) do count = count + 1 end
    return count
end

return {
    id = "rtt.skills",
    key = "skills",
    order = 50,
    depends = { "rtt.core" },
    demonstrator = "Phase 4 active/notable/mastery skill registry with save-schema-ready progression state",
    probe = function()
        return countSkills() == 5
            and catalog.skills["RTT_SKILL_0002"].kind == "active"
            and catalog.skills["RTT_SKILL_0006"].kind == "mastery"
    end,
    on_init = function(state)
        state.registeredSkills = countSkills()
        state.experienceEvents = 0
    end,
    on_player_gain_experience = function(state, ...)
        state.experienceEvents = (state.experienceEvents or 0) + 1
    end,
    catalog = catalog.skills,
}
