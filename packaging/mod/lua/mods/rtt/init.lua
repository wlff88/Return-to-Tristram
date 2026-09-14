-- Return to Tristram runtime bootstrap.

local events = require("devilutionx.events")
local lootFilter = require("mods.rtt.qol.loot_filter")

-- The engine hook defaults to showing labels when this event does not exist,
-- so registering it here keeps the extension RTT-specific.
if events.ShouldShowItemLabel == nil then
    events.registerCustom("ShouldShowItemLabel")
end

events.ShouldShowItemLabel.add(lootFilter.shouldShow)

local rtt = {
    name = "Return to Tristram",
    version = "0.1.0-dev",
    lootFilter = lootFilter,
}

return rtt
