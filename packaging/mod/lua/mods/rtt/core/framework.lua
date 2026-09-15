local M = {}

local registered = {}
local byId = {}
local booted = false

local eventHooks = {
    LoadModsComplete = "on_mods_loaded",
    ItemDataLoaded = "on_item_data_loaded",
    UniqueItemDataLoaded = "on_unique_item_data_loaded",
    MonsterDataLoaded = "on_monster_data_loaded",
    UniqueMonsterDataLoaded = "on_unique_monster_data_loaded",
    GameStart = "on_game_start",
    GameDrawComplete = "on_game_draw_complete",
    StoreOpened = "on_store_opened",
    OnMonsterTakeDamage = "on_monster_take_damage",
    OnPlayerTakeDamage = "on_player_take_damage",
    OnPlayerGainExperience = "on_player_gain_experience",
}

local function validateModule(module)
    assert(type(module) == "table", "RTT module must be a table")
    assert(type(module.id) == "string" and module.id:match("^rtt%."), "RTT module id must start with rtt.")
    assert(type(module.key) == "string" and module.key ~= "", "RTT module key is required")
    assert(type(module.order) == "number", "RTT module order is required")
    assert(type(module.demonstrator) == "string" and module.demonstrator ~= "", "RTT module demonstrator is required")
    assert(type(module.probe) == "function", "RTT module probe() is required")
    if module.depends ~= nil then
        assert(type(module.depends) == "table", "RTT module depends must be a table")
    end
end

function M.register(module, enabled)
    validateModule(module)
    assert(byId[module.id] == nil, "Duplicate RTT module id: " .. module.id)
    local entry = { definition = module, enabled = enabled ~= false, state = {} }
    table.insert(registered, entry)
    byId[module.id] = entry
end

local function validateDependencies()
    for _, entry in ipairs(registered) do
        local module = entry.definition
        for _, dependencyId in ipairs(module.depends or {}) do
            local dependency = byId[dependencyId]
            assert(dependency ~= nil, module.id .. " depends on missing module " .. dependencyId)
            assert(dependency.definition.order < module.order, module.id .. " dependency order is not deterministic")
        end
    end
end

local function dispatch(hook, ...)
    for _, entry in ipairs(registered) do
        if entry.enabled then
            local callback = entry.definition[hook]
            if callback ~= nil then
                callback(entry.state, ...)
            end
        end
    end
end

function M.boot(events, modules, config, context)
    if booted then
        return M.status()
    end
    for _, module in ipairs(modules) do
        M.register(module, config.modules[module.key])
    end
    table.sort(registered, function(a, b)
        if a.definition.order == b.definition.order then
            return a.definition.id < b.definition.id
        end
        return a.definition.order < b.definition.order
    end)
    validateDependencies()

    context = context or {}
    context.events = events
    context.config = config
    for _, entry in ipairs(registered) do
        if entry.enabled and entry.definition.on_init ~= nil then
            entry.definition.on_init(entry.state, context)
        end
    end

    for eventName, hookName in pairs(eventHooks) do
        local event = events[eventName]
        if event ~= nil then
            local dispatchHook = hookName
            event.add(function(...)
                dispatch(dispatchHook, ...)
            end)
        end
    end
    booted = true
    return M.status()
end

function M.selfTest()
    local results = {}
    for _, entry in ipairs(registered) do
        local ok, value = pcall(entry.definition.probe)
        results[entry.definition.id] = {
            enabled = entry.enabled,
            ok = ok and value ~= false,
            result = ok and value or tostring(value),
            demonstrator = entry.definition.demonstrator,
        }
    end
    return results
end

function M.status()
    local result = { booted = booted, modules = {} }
    for _, entry in ipairs(registered) do
        result.modules[entry.definition.id] = {
            enabled = entry.enabled,
            order = entry.definition.order,
            demonstrator = entry.definition.demonstrator,
            state = entry.state,
        }
    end
    return result
end

return M
