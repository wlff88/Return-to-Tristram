#!/usr/bin/env python3
from __future__ import annotations

import json
import struct
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AFFIX_DATA = json.loads((ROOT / "Data/itemization/affixes.json").read_text(encoding="utf-8"))

UPSTREAM_MASK = 0x0000001F
RTT_MARKER_MASK = 0x80000000
RTT_RARITY_MASK = 0x60000000
RTT_RARITY_SHIFT = 29
RTT_RARITY_RARE = 1
RTT_METADATA_MASK = 0xFFFFFFE0
CF_LEVEL = (1 << 6) - 1
AFFIX_MASKS = (0x000007E0, 0x0001F800, 0x007E0000, 0x1F800000)
AFFIX_SHIFTS = (5, 11, 17, 23)
ITEM_PACK = struct.Struct("<IHHBBBBBHI")

AFFIX_BY_CODE = {entry["compactCode"]: entry for entry in AFFIX_DATA["entries"]}
NAME_FIRST = ("Grave", "Bone", "Ash", "Dread", "Marrow", "Crypt", "Soul", "Night")
NAME_SECOND = ("Bite", "Ward", "Oath", "Song", "Brand", "Veil", "Grasp", "Spite")


@dataclass(frozen=True)
class ItemModel:
    seed: int
    item_level: int
    kind: str
    item_index: int
    dw_buff: int = 0


def u32(value: int) -> int:
    return value & 0xFFFFFFFF


def mix(value: int) -> int:
    value = u32(value)
    value ^= value >> 16
    value = u32(value * 0x7FEB352D)
    value ^= value >> 15
    value = u32(value * 0x846CA68B)
    value ^= value >> 16
    return u32(value)


def tier_code(item_level: int, tier1_code: int) -> int:
    if item_level >= 20:
        return tier1_code + 2
    if item_level >= 10:
        return tier1_code + 1
    return tier1_code


def item_tags(item: ItemModel) -> set[str]:
    tags = {"equipment"}
    if item.kind == "weapon":
        tags.add("weapon")
    if item.kind in {"armor", "helm"}:
        tags.add("armor")
    if item.kind == "shield":
        tags.update({"armor", "shield"})
    return tags


def slot_accepts_position(slot: int, position: str) -> bool:
    return (slot < 2 and position == "prefix") or (slot >= 2 and position == "suffix")


def affix_compatible(item: ItemModel, compact_code: int, slot: int) -> bool:
    if compact_code == 0:
        return True
    affix = AFFIX_BY_CODE.get(compact_code)
    if affix is None:
        return False
    if not slot_accepts_position(slot, affix["position"]):
        return False
    if item.item_level < affix["minItemLevel"]:
        return False
    return bool(item_tags(item).intersection(affix["tags"]))


def build_rare_codes(item: ItemModel, salt: int = 0) -> tuple[int, int, int, int]:
    codes = [0, 0, 0, 0]
    selector = mix(u32(item.seed + salt + 0x52545434))

    if item.kind == "weapon":
        codes[0] = tier_code(item.item_level, 1)
    elif item.kind in {"armor", "shield", "helm"}:
        codes[0] = tier_code(item.item_level, 4)

    fire = tier_code(item.item_level, 7)
    lightning = tier_code(item.item_level, 10)
    if selector & 1:
        codes[2], codes[3] = lightning, fire
    else:
        codes[2], codes[3] = fire, lightning

    for slot, code in enumerate(codes):
        if not affix_compatible(item, code, slot):
            codes[slot] = 0
    return tuple(codes)


def set_rare_metadata(item: ItemModel, codes: tuple[int, int, int, int]) -> int:
    dw_buff = item.dw_buff & UPSTREAM_MASK
    dw_buff |= RTT_MARKER_MASK | (RTT_RARITY_RARE << RTT_RARITY_SHIFT)
    for slot, code in enumerate(codes):
        dw_buff |= (code << AFFIX_SHIFTS[slot]) & AFFIX_MASKS[slot]
    return u32(dw_buff)


def get_code(dw_buff: int, slot: int) -> int:
    return (dw_buff & AFFIX_MASKS[slot]) >> AFFIX_SHIFTS[slot]


def roll(seed: int, compact_code: int, slot: int, minimum: int, maximum: int) -> int:
    span = maximum - minimum + 1
    roll_key = u32(
        seed
        + compact_code * 0x9E3779B9
        + (slot + 1) * 0x85EBCA6B
    )
    return minimum + mix(roll_key) % span


def rare_name(item: ItemModel) -> str:
    mixed = mix(u32(item.seed + item.item_index * 0x9E3779B9 + 0x52415245))
    return f"{NAME_FIRST[mixed % len(NAME_FIRST)]} {NAME_SECOND[(mixed >> 8) % len(NAME_SECOND)]}"


def rtt_stats(item: ItemModel) -> dict[str, int]:
    if (item.dw_buff & RTT_MARKER_MASK) == 0:
        return {}
    result: dict[str, int] = {}
    for slot in range(4):
        code = get_code(item.dw_buff, slot)
        if code == 0 or not affix_compatible(item, code, slot):
            continue
        affix = AFFIX_BY_CODE[code]
        effect = affix["effect"]
        value = roll(item.seed, code, slot, effect["min"], effect["max"])
        result[effect["stat"]] = result.get(effect["stat"], 0) + value
    return result


def generate_fresh_rare(kind: str, item_level: int, item_index: int, start_seed: int) -> ItemModel:
    # Mirror the engine's Rare range. The important property here is that the
    # generation path is fresh-only; recreate/load never calls this function.
    seed = start_seed
    while True:
        rarity_roll = mix(seed ^ 0xA17E4D31) % 100
        if 6 <= rarity_roll < 21:
            base = ItemModel(seed=seed, item_level=item_level, kind=kind, item_index=item_index, dw_buff=0x10)
            codes = build_rare_codes(base)
            return ItemModel(**{**base.__dict__, "dw_buff": set_rare_metadata(base, codes)})
        seed += 1


def pack_item(item: ItemModel) -> bytes:
    return ITEM_PACK.pack(
        item.seed,
        item.item_level & CF_LEVEL,
        item.item_index,
        3,
        40,
        40,
        0,
        0,
        0,
        item.dw_buff,
    )


def unpack_recreate(payload: bytes, kind: str) -> ItemModel:
    seed, create_info, item_index, _bid, _dur, _mdur, _ch, _mch, _value, dw_buff = ITEM_PACK.unpack(payload)
    # RTT recreation is marker-gated. No marker means no RTT mutation at load.
    return ItemModel(
        seed=seed,
        item_level=create_info & CF_LEVEL,
        kind=kind,
        item_index=item_index,
        dw_buff=dw_buff,
    )


def assert_slot_contract(item: ItemModel) -> None:
    prefixes = 0
    suffixes = 0
    for slot in range(4):
        code = get_code(item.dw_buff, slot)
        if code == 0:
            continue
        affix = AFFIX_BY_CODE[code]
        assert affix_compatible(item, code, slot), (item, slot, code)
        if affix["position"] == "prefix":
            prefixes += 1
        else:
            suffixes += 1
    assert prefixes <= 2
    assert suffixes <= 2


def round_trip_case(kind: str, item_level: int, item_index: int, start_seed: int) -> None:
    generated = generate_fresh_rare(kind, item_level, item_index, start_seed)
    assert generated.dw_buff & RTT_MARKER_MASK
    assert ((generated.dw_buff & RTT_RARITY_MASK) >> RTT_RARITY_SHIFT) == RTT_RARITY_RARE
    assert_slot_contract(generated)

    before_metadata = generated.dw_buff & RTT_METADATA_MASK
    before_stats = rtt_stats(generated)
    before_name = rare_name(generated)

    payload = pack_item(generated)
    assert len(payload) == 19
    recreated = unpack_recreate(payload, kind)

    assert recreated.dw_buff == generated.dw_buff
    assert (recreated.dw_buff & RTT_METADATA_MASK) == before_metadata
    assert rtt_stats(recreated) == before_stats
    assert rare_name(recreated) == before_name

    # Re-packing the recreated item must produce the same ItemPack bytes.
    assert pack_item(recreated) == payload


def main() -> None:
    # Verify the runtime data contract used by the engine implementation.
    for code, affix in AFFIX_BY_CODE.items():
        assert 1 <= code <= 63
        assert affix["position"] in {"prefix", "suffix"}
        assert isinstance(affix["minItemLevel"], int) and affix["minItemLevel"] >= 1
        assert affix["tags"]

    cases = 0
    kinds = (("weapon", 120), ("armor", 58), ("shield", 75), ("helm", 53), ("jewelry", 151))
    for kind, item_index in kinds:
        for level in (1, 9, 10, 19, 20, 30):
            for seed_base in (1, 0x12345678, 0xDEADBEEF):
                round_trip_case(kind, level, item_index, seed_base)
                cases += 1

    # Same compact code in different slots must not collapse to the same roll.
    # This guards the seed + compactCode + slot requirement explicitly.
    embers = AFFIX_BY_CODE[7]["effect"]
    assert roll(0x12345678, 7, 2, embers["min"], embers["max"]) != roll(
        0x12345678, 7, 3, embers["min"], embers["max"]
    )

    # Legacy/no-marker load invariant: RTT metadata/stats/name logic must not
    # silently upgrade an existing item during unpack/recreate.
    legacy = ItemModel(seed=0xCAFEBABE, item_level=20, kind="weapon", item_index=120, dw_buff=0x10)
    legacy_payload = pack_item(legacy)
    legacy_recreated = unpack_recreate(legacy_payload, legacy.kind)
    assert legacy_recreated == legacy
    assert (legacy_recreated.dw_buff & RTT_MARKER_MASK) == 0
    assert rtt_stats(legacy_recreated) == {}
    assert pack_item(legacy_recreated) == legacy_payload

    print(f"OK: RTT Rare round-trip — {cases} generate/pack/unpack/recreate cases are deterministic")


if __name__ == "__main__":
    main()
