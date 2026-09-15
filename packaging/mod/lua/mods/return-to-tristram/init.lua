-- DevilutionX loose-mod entry point.
-- The runtime folder is named `return-to-tristram`, so DevilutionX discovers
-- this exact package path: lua/mods/return-to-tristram/init.lua.
-- Keep RTT implementation modules under mods.rtt.* and delegate from here.

return require("mods.rtt.init")
