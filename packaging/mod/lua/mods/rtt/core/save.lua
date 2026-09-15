local M = {
    CURRENT_VERSION = 2,
    MINIMUM_SUPPORTED_VERSION = 1,
}

local migrations = {}

function M.registerMigration(fromVersion, toVersion, migration)
    assert(type(fromVersion) == "number" and type(toVersion) == "number")
    assert(toVersion == fromVersion + 1, "RTT save migrations must advance exactly one schema version")
    assert(type(migration) == "function")
    assert(migrations[fromVersion] == nil, "Duplicate RTT save migration")
    migrations[fromVersion] = { toVersion = toVersion, run = migration }
end

local function newItemizationState()
    return {
        metadata_version = 1,
        compact_affix_map_version = 1,
    }
end

local function newProgressionState()
    return {
        class_id = nil,
        skill_points = 0,
        skills = {},
        passives = {},
    }
end

M.registerMigration(1, 2, function(document)
    document.itemization_state = document.itemization_state or newItemizationState()
    document.progression_state = document.progression_state or newProgressionState()
    return document
end)

function M.newState(featureFlags, contentIds)
    return {
        rtt_version = M.CURRENT_VERSION,
        feature_flags = featureFlags or {},
        content_ids = contentIds or {},
        module_state = {},
        itemization_state = newItemizationState(),
        progression_state = newProgressionState(),
    }
end

function M.migrate(document)
    assert(type(document) == "table", "RTT save document must be a table")
    local version = document.rtt_version
    assert(type(version) == "number", "RTT save document is missing rtt_version")
    assert(version <= M.CURRENT_VERSION, "RTT save was created by a newer schema")
    assert(version >= M.MINIMUM_SUPPORTED_VERSION, "RTT save schema is too old")
    while version < M.CURRENT_VERSION do
        local migration = migrations[version]
        assert(migration ~= nil, "Missing RTT save migration from version " .. tostring(version))
        document = migration.run(document) or document
        version = migration.toVersion
        document.rtt_version = version
    end
    return document
end

function M.registeredMigrations()
    return migrations
end

return M
