#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_json(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))

registry = load_json("config/content-ids.json")
save_schema = load_json("config/save-schema.json")
base_items = load_json("Data/itemization/base_items.json")
affixes = load_json("Data/itemization/affixes.json")
uniques = load_json("Data/itemization/uniques.json")
sets = load_json("Data/itemization/sets.json")
recipes = load_json("Data/crafting/recipes.json")
skills = load_json("Data/skills/skills.json")
classes = load_json("Data/classes/classes.json")

if registry.get("schemaVersion") != 2:
    raise SystemExit("Phase 4 content registry must be schemaVersion 2")
for namespace in ("item", "affix", "unique", "set", "skill", "class", "recipe"):
    if namespace not in registry["namespaces"]:
        raise SystemExit(f"missing Phase 4 registry namespace: {namespace}")

entries = registry["entries"]
ids = [entry["id"] for entry in entries]
symbols = [(entry["namespace"], entry["symbol"]) for entry in entries]
if len(ids) != len(set(ids)):
    raise SystemExit("duplicate stable content ID")
if len(symbols) != len(set(symbols)):
    raise SystemExit("duplicate content symbol in namespace")
registry_ids = set(ids)


def require_registered(stable_id, context):
    if stable_id not in registry_ids:
        raise SystemExit(f"{context} references unregistered stable ID {stable_id}")

for item in base_items["entries"]:
    require_registered(item["stableId"], "base item")

codes = []
for affix in affixes["entries"]:
    require_registered(affix["stableId"], "affix")
    code = affix["compactCode"]
    if not 1 <= code <= 63:
        raise SystemExit(f"affix compact code out of range: {code}")
    codes.append(code)
if len(codes) != len(set(codes)):
    raise SystemExit("duplicate compact affix code")
if sorted(codes) != list(range(1, len(codes) + 1)):
    raise SystemExit("Phase 4 compact affix codes must be append-only and contiguous from 1")

encoding = affixes["encoding"]
upstream_mask = int(encoding["upstreamReservedMask"], 16)
marker_mask = int(encoding["rttMarkerMask"], 16)
rarity_mask = int(encoding["rarityMask"], 16)
slot_masks = [int(slot["mask"], 16) for slot in encoding["slots"]]
all_rtt_masks = [marker_mask, rarity_mask, *slot_masks]
for mask in all_rtt_masks:
    if mask & upstream_mask:
        raise SystemExit("RTT item metadata overlaps DevilutionX dwBuff bits 0-4")
for i, mask in enumerate(all_rtt_masks):
    for other in all_rtt_masks[i + 1:]:
        if mask & other:
            raise SystemExit("RTT item metadata masks overlap")
if (marker_mask | rarity_mask | sum(slot_masks)) != 0xFFFFFFE0:
    raise SystemExit("RTT item metadata must own exactly dwBuff bits 5-31")
if encoding["compactCode"].get("policy") != "append-only-never-reuse":
    raise SystemExit("compact affix code policy must be append-only-never-reuse")

base_ids = {entry["stableId"] for entry in base_items["entries"]}
affix_ids = {entry["stableId"] for entry in affixes["entries"]}
skill_ids = {entry["stableId"] for entry in skills["entries"]}
class_ids = {entry["stableId"] for entry in classes["entries"]}

for unique in uniques["entries"]:
    require_registered(unique["stableId"], "unique")
    if unique["baseItemId"] not in base_ids:
        raise SystemExit(f"unique {unique['stableId']} references unknown base item")
    for affix_id in unique.get("fixedAffixes", []):
        if affix_id not in affix_ids:
            raise SystemExit(f"unique {unique['stableId']} references unknown affix {affix_id}")
    signature_skill = unique.get("signature", {}).get("skillId")
    if signature_skill is not None and signature_skill not in skill_ids:
        raise SystemExit(f"unique {unique['stableId']} references unknown skill {signature_skill}")

for set_def in sets["entries"]:
    require_registered(set_def["stableId"], "set")
    for item_id in set_def.get("prototypePieces", []):
        if item_id not in base_ids:
            raise SystemExit(f"set {set_def['stableId']} references unknown prototype item {item_id}")
    for bonus in set_def.get("bonuses", []):
        for effect in bonus.get("effects", []):
            skill_id = effect.get("skillId")
            if skill_id is not None and skill_id not in skill_ids:
                raise SystemExit(f"set {set_def['stableId']} references unknown skill {skill_id}")

for skill in skills["entries"]:
    require_registered(skill["stableId"], "skill")
    if skill["classId"] not in class_ids:
        raise SystemExit(f"skill {skill['stableId']} references unknown class")

for class_def in classes["entries"]:
    require_registered(class_def["stableId"], "class")
    if class_def["startingSkillId"] not in skill_ids:
        raise SystemExit(f"class {class_def['stableId']} has unknown starting skill")
    for skill_id in class_def.get("skillIds", []):
        if skill_id not in skill_ids:
            raise SystemExit(f"class {class_def['stableId']} references unknown skill {skill_id}")

for recipe in recipes["entries"]:
    require_registered(recipe["stableId"], "recipe")

if save_schema.get("schemaVersion") != 2 or save_schema.get("currentVersion") != 2:
    raise SystemExit("Phase 4 requires Save Schema v2")
if save_schema.get("minimumSupportedVersion") != 1:
    raise SystemExit("Save Schema v2 must retain support for v1")
migrations = save_schema.get("migrations", [])
if not any(m.get("from") == 1 and m.get("to") == 2 for m in migrations):
    raise SystemExit("Save Schema v2 is missing migration 1 -> 2")
field_names = {field["name"] for field in save_schema["fields"]}
for field in ("itemization_state", "progression_state"):
    if field not in field_names:
        raise SystemExit(f"Save Schema v2 missing {field}")

save_lua = (ROOT / "packaging/mod/lua/mods/rtt/core/save.lua").read_text(encoding="utf-8")
for token in (
    "CURRENT_VERSION = 2",
    "M.registerMigration(1, 2",
    "itemization_state",
    "compact_affix_map_version = 1",
    "progression_state",
    "skill_points = 0",
):
    if token not in save_lua:
        raise SystemExit(f"runtime save migration missing token: {token}")

runtime_catalog = (ROOT / "packaging/mod/lua/mods/rtt/data/phase4_catalog.lua").read_text(encoding="utf-8")
for token in (
    "upstreamReservedMask = 0x0000001F",
    "markerMask = 0x80000000",
    "rarityMask = 0x60000000",
    "RTT_AFFIX_0013",
    "RTT_CLASS_0002",
    "RTT_SKILL_0006",
    "RTT_SET_0002",
    "RTT_RECIPE_0004",
):
    if token not in runtime_catalog:
        raise SystemExit(f"runtime Phase 4 catalog missing token: {token}")

for module_path, required_token in (
    ("packaging/mod/lua/mods/rtt/modules/itemization.lua", "compactAffixMapVersion"),
    ("packaging/mod/lua/mods/rtt/modules/crafting.lua", "recipeCount"),
    ("packaging/mod/lua/mods/rtt/modules/skills.lua", "RTT_SKILL_0006"),
    ("packaging/mod/lua/mods/rtt/modules/classes.lua", "RTT_CLASS_0002"),
):
    text = (ROOT / module_path).read_text(encoding="utf-8")
    if 'require("mods.rtt.data.phase4_catalog")' not in text or required_token not in text:
        raise SystemExit(f"Phase 4 runtime module contract incomplete: {module_path}")

print(
    "OK: Phase 4 foundation — "
    f"{len(base_ids)} base archetypes, {len(affix_ids)} affixes, "
    f"{len(uniques['entries'])} uniques, {len(sets['entries'])} sets, "
    f"{len(skill_ids)} skills, {len(classes['entries'])} classes, "
    f"{len(recipes['entries'])} recipes; Save Schema v2 migration present"
)
