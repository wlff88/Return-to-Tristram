-- Return to Tristram runtime bootstrap.

local events = require("devilutionx.events")
local config = require("mods.rtt.config")
local framework = require("mods.rtt.core.framework")
local save = require("mods.rtt.core.save")
local modules = require("mods.rtt.module_catalog")
local contract = require("mods.rtt.generated.contract")
local contentIds = require("mods.rtt.generated.content_ids")

assert(contract.frameworkVersion == config.frameworkVersion, "RTT framework contract/config version mismatch")
assert(contract.saveSchemaVersion == config.saveSchemaVersion, "RTT save schema contract/config mismatch")
assert(contract.networkProtocolVersion == config.networkProtocolVersion, "RTT network contract/config mismatch")

local context = { contract = contract, contentIds = contentIds, save = save }
local status = framework.boot(events, modules, config, context)
local selfTest = framework.selfTest()

return {
    name = "Return to Tristram",
    version = "0.1.0-dev",
    frameworkVersion = config.frameworkVersion,
    contract = contract,
    contentIds = contentIds,
    save = save,
    framework = framework,
    frameworkStatus = status,
    selfTest = selfTest,
}
