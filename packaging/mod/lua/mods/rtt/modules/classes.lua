local catalog = require("mods.rtt.data.phase4_catalog")

return {
    id = "rtt.classes",
    key = "classes",
    order = 40,
    depends = { "rtt.core" },
    demonstrator = "Phase 4 logical class registry with Necromancer vertical-slice identity",
    probe = function()
        local necromancer = catalog.classes["RTT_CLASS_0002"]
        return necromancer ~= nil
            and necromancer.symbol == "NECROMANCER"
            and necromancer.startingSkillId == "RTT_SKILL_0002"
    end,
    on_init = function(state)
        state.prototypeClassId = "RTT_CLASS_0002"
        state.prototypeClass = catalog.classes[state.prototypeClassId]
    end,
    on_game_start = function(state)
        state.gameStarts = (state.gameStarts or 0) + 1
    end,
    catalog = catalog.classes,
}
