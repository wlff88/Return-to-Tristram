#!/usr/bin/env python3
from __future__ import annotations

import configparser
import csv
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
ENGINE = ROOT / "Engine" / "devilutionx"
BASELINE = "ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6"
EXPECTED_MODULES = ("core", "qol", "quests", "classes", "skills", "itemization", "crafting", "monsters", "bosses", "abyss")
EXPECTED_CLASSES = ("warrior", "rogue", "sorcerer", "monk", "bard", "barbarian")


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read_json(relative: str) -> dict:
    path = ROOT / relative
    if not path.is_file():
        fail(f"missing {relative}")
    return json.loads(path.read_text(encoding="utf-8"))


def tsv_header(path: Path) -> list[str]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle, delimiter="\t")
        try:
            return next(reader)
        except StopIteration:
            fail(f"empty TSV: {path.relative_to(ROOT)}")


def validate_features() -> None:
    config = configparser.ConfigParser()
    config.optionxform = str
    config.read(ROOT / "config/features.ini", encoding="utf-8")
    if int(config["rtt"].get("frameworkVersion", "0")) != 1:
        fail("frameworkVersion must remain 1")
    configured_save_version = int(config["rtt"].get("saveSchemaVersion", "0"))
    if configured_save_version < 1:
        fail("saveSchemaVersion must be at least 1")
    save_schema = read_json("config/save-schema.json")
    if configured_save_version != int(save_schema.get("currentVersion", 0)):
        fail("features.ini saveSchemaVersion must match config/save-schema.json currentVersion")
    if int(config["rtt"].get("networkProtocolVersion", "0")) != 2:
        fail("networkProtocolVersion must be 2 for Phase 4 progression packets")
    for module in EXPECTED_MODULES:
        if config["modules"].get(module, "").lower() != "true":
            fail(f"Phase 2 module must be framework-enabled: {module}")


def validate_table_map() -> None:
    table_map = read_json("config/table-map.json")
    if table_map.get("schemaVersion") != 2 or table_map.get("baseline") != BASELINE:
        fail("table-map schema/baseline mismatch")
    tables = table_map.get("tables", [])
    names = {entry["name"] for entry in tables}
    required = {"experience", "items", "item-prefixes", "item-suffixes", "unique-items", "monsters", "unique-monsters", "spells", "class-catalog"}
    for class_name in EXPECTED_CLASSES:
        for suffix in ("animations", "attributes", "sounds", "sprites", "starting-loadout"):
            required.add(f"{class_name}-{suffix}")
    missing = sorted(required - names)
    if missing:
        fail(f"table-map is missing Phase 2 mappings: {missing}")
    outputs: set[str] = set()
    for entry in tables:
        if entry["output"] in outputs:
            fail(f"duplicate table-map output: {entry['output']}")
        outputs.add(entry["output"])
        upstream = ENGINE / entry["upstream"]
        if not upstream.is_file():
            fail(f"mapped upstream file does not exist: {entry['upstream']}")
        if entry["key"] not in tsv_header(upstream):
            fail(f"mapped key {entry['key']!r} not in {entry['upstream']}")


def validate_registry() -> None:
    registry = read_json("config/content-ids.json")
    if int(registry.get("schemaVersion", 0)) < 1 or registry.get("policy") != "append-only":
        fail("content registry must remain append-only and use schemaVersion >= 1")
    width = int(registry["numericSuffixWidth"])
    seen_ids: set[str] = set()
    seen_symbols: set[tuple[str, str]] = set()
    for entry in registry["entries"]:
        namespace = entry["namespace"]
        if namespace not in registry["namespaces"]:
            fail(f"unknown registry namespace: {namespace}")
        rule = registry["namespaces"][namespace]
        match = re.fullmatch(rf"{re.escape(rule['prefix'])}_(\d{{{width}}})", entry["id"])
        if match is None:
            fail(f"invalid stable RTT id: {entry['id']}")
        number = int(match.group(1))
        if not int(rule["min"]) <= number <= int(rule["max"]):
            fail(f"stable RTT id outside namespace range: {entry['id']}")
        if entry["id"] in seen_ids:
            fail(f"duplicate stable RTT id: {entry['id']}")
        symbol_key = (namespace, entry["symbol"])
        if symbol_key in seen_symbols:
            fail(f"duplicate symbol within namespace: {symbol_key}")
        seen_ids.add(entry["id"])
        seen_symbols.add(symbol_key)
    source_files = {"item":"Data/items.tsv", "affix":"Data/affixes.tsv", "unique":"Data/uniques.tsv", "monster":"Data/monsters.tsv", "spell":"Data/spells.tsv", "recipe":"Data/recipes.tsv"}
    for relative in source_files.values():
        path = ROOT / relative
        with path.open("r", encoding="utf-8", newline="") as handle:
            for row in csv.DictReader(handle, delimiter="\t"):
                content_id = (row.get("id") or "").strip()
                if content_id and content_id not in seen_ids:
                    fail(f"{relative} uses unregistered stable id: {content_id}")


def validate_save_and_network() -> None:
    save = read_json("config/save-schema.json")
    network = read_json("config/network-policy.json")
    manifest = configparser.ConfigParser()
    manifest.optionxform = str
    manifest.read(ROOT / "packaging/mod/manifest.ini", encoding="utf-8")
    if int(save.get("currentVersion", 0)) < 1 or save.get("minimumSupportedVersion") != 1:
        fail("RTT save schema must preserve v1 as the minimum supported version")
    if save.get("saveExtension") != manifest["mod"].get("saveExtension"):
        fail("save schema extension does not match manifest")
    if save.get("namespace") != manifest["mod"].get("programId"):
        fail("save schema namespace does not match manifest programId")
    if network.get("protocolVersion") != 2 or network.get("baseline") != BASELINE:
        fail("network policy protocol/baseline mismatch")
    for key in ("sameRttVersion", "sameEngineBaseline", "sameContentRegistry", "sameSaveSchema"):
        if network["requirements"].get(key) is not True:
            fail(f"network compatibility requirement must be true: {key}")


def validate_runtime_modules() -> None:
    discovery = ROOT / "packaging/mod/lua/mods/return-to-tristram/init.lua"
    if not discovery.is_file() or 'require("mods.rtt.init")' not in discovery.read_text(encoding="utf-8"):
        fail("DevilutionX discovery entry point is missing/broken")
    root_init = ROOT / "packaging/mod/lua/mods/rtt/init.lua"
    init_text = root_init.read_text(encoding="utf-8")
    for token in ('require("mods.rtt.core.framework")', 'require("mods.rtt.module_catalog")', 'require("mods.rtt.generated.contract")', 'require("mods.rtt.generated.content_ids")', "framework.boot", "framework.selfTest"):
        if token not in init_text:
            fail(f"RTT bootstrap missing framework token: {token}")
    for module in EXPECTED_MODULES:
        path = ROOT / f"packaging/mod/lua/mods/rtt/modules/{module}.lua"
        if not path.is_file():
            fail(f"runtime module missing: {path.relative_to(ROOT)}")
        text = path.read_text(encoding="utf-8")
        for token in (f'id = "rtt.{module}"', f'key = "{module}"', "demonstrator =", "probe = function"):
            if token not in text:
                fail(f"{path.relative_to(ROOT)} missing token: {token}")


def main() -> int:
    validate_features()
    validate_table_map()
    validate_registry()
    validate_save_and_network()
    validate_runtime_modules()
    for relative in ("docs/PHASE2_MOD_FRAMEWORK.md", "docs/MULTIPLAYER_COMPATIBILITY.md", "scripts/generate-framework-data.py"):
        if not (ROOT / relative).is_file():
            fail(f"missing Phase 2 artifact: {relative}")
    print("OK: Phase 2 RTT Mod Framework contract remains complete under the current forward-compatible schemas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
