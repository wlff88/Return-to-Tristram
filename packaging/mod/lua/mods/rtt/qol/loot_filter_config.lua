-- Return to Tristram — Loot Filter 2.0 user configuration.
--
-- This file is intentionally plain Lua so a user can edit it without rebuilding
-- RTT. The filter remains presentation-only: hidden labels never remove items,
-- alter drops, change RNG, or block pickup.

return {
    enabled = true,

    -- Available presets: "permissive", "balanced", "strict".
    -- balanced preserves the Phase 2 behavior for ordinary weapons/armor.
    preset = "balanced",

    -- Optional per-category value overrides. Use nil to inherit the preset.
    normalValueOverrides = {
        weapon = nil,
        armor = nil,
        jewelry = nil,
        equipment = nil,
    },

    -- Exact translated item names to force visible. Useful for personally
    -- interesting normal bases while keeping a stricter general preset.
    alwaysShowNames = {
    },

    -- Exact translated names of NORMAL EQUIPMENT whose labels should be hidden.
    -- Magic/unique items, gold, consumables and non-equipment are never hidden by
    -- this rule, even if their name is listed here.
    hideNormalNames = {
    },
}
