local M = {}

M.itemization = {
    metadataVersion = 1,
    compactAffixMapVersion = 1,
    dwBuff = {
        upstreamReservedMask = 0x0000001F,
        markerMask = 0x80000000,
        rarityMask = 0x60000000,
        rarityShift = 29,
        slots = {
            { mask = 0x000007E0, shift = 5 },
            { mask = 0x0001F800, shift = 11 },
            { mask = 0x007E0000, shift = 17 },
            { mask = 0x1F800000, shift = 23 },
        },
    },
    affixByCode = {
        [1] = "RTT_AFFIX_0002", [2] = "RTT_AFFIX_0003", [3] = "RTT_AFFIX_0004",
        [4] = "RTT_AFFIX_0005", [5] = "RTT_AFFIX_0006", [6] = "RTT_AFFIX_0007",
        [7] = "RTT_AFFIX_0008", [8] = "RTT_AFFIX_0009", [9] = "RTT_AFFIX_0010",
        [10] = "RTT_AFFIX_0011", [11] = "RTT_AFFIX_0012", [12] = "RTT_AFFIX_0013",
    },
    prototypeItems = {
        "RTT_ITEM_0002", "RTT_ITEM_0003", "RTT_ITEM_0004", "RTT_ITEM_0005",
    },
    prototypeUniques = {
        "RTT_UNIQUE_0002", "RTT_UNIQUE_0003", "RTT_UNIQUE_0004",
    },
    prototypeSets = { "RTT_SET_0002" },
}

M.skills = {
    ["RTT_SKILL_0002"] = { symbol = "BONE_SPIKE", kind = "active", classId = "RTT_CLASS_0002", requiredLevel = 1 },
    ["RTT_SKILL_0003"] = { symbol = "BONE_ARMOR", kind = "active", classId = "RTT_CLASS_0002", requiredLevel = 4 },
    ["RTT_SKILL_0004"] = { symbol = "GRAVE_PACT", kind = "active", classId = "RTT_CLASS_0002", requiredLevel = 8 },
    ["RTT_SKILL_0005"] = { symbol = "SOUL_SIPHON", kind = "notable", classId = "RTT_CLASS_0002", requiredLevel = 6 },
    ["RTT_SKILL_0006"] = { symbol = "OSSUARY_MASTERY", kind = "mastery", classId = "RTT_CLASS_0002", requiredLevel = 15 },
}

M.classes = {
    ["RTT_CLASS_0002"] = {
        symbol = "NECROMANCER",
        presentationBase = "Sorcerer",
        startingSkillId = "RTT_SKILL_0002",
        skillIds = { "RTT_SKILL_0002", "RTT_SKILL_0003", "RTT_SKILL_0004", "RTT_SKILL_0005", "RTT_SKILL_0006" },
    },
}

M.crafting = {
    "RTT_RECIPE_0002",
    "RTT_RECIPE_0003",
    "RTT_RECIPE_0004",
}

return M
