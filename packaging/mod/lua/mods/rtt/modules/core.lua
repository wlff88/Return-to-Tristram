return {
    id = "rtt.core",
    key = "core",
    order = 10,
    depends = {},
    demonstrator = "deterministic lifecycle bootstrap and self-test",
    probe = function() return "core-framework-ready" end,
    on_init = function(state, context)
        state.initialized = true
        state.frameworkVersion = context.config.frameworkVersion
    end,
    on_mods_loaded = function(state) state.modsLoaded = true end,
}
