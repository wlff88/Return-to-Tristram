# Mod source matrix

This file gates any feature inspired by or adapted from third-party Diablo I projects. A feature may be implemented only under the policy recorded here; assets are always reviewed separately from source code.

Audit date: 2026-09-14.

| Project | Intended value | Current policy | Source / pinned reference | Licence / permission status | Notes |
|---|---|---|---|---|---|
| DevilutionX | Engine foundation, TSV/Lua mod runtime, controller/network/platform support | **Adapt / pinned dependency** | `diasurgical/DevilutionX@ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6` | Sustainable Use License 1.0 reviewed | Engine submodule. Keep RTT non-commercial and retain required notices. |
| Tchernobog | Itemisation, classes, crafting, stash, multiplayer/endgame ideas | **Reference / reimplement** | `qndel/tchernobog_versions`; official releases currently include 0.2.2f | No public source licence established | Public GitHub repository contains only a README and release binaries, not an auditable source tree. Do not import binary-derived code. |
| Belzebub | Restored/expanded campaign, quests, locations, classes, crafting and itemisation concepts | **Reference / reimplement** | Official Diablo 1 HD Mod site, Belzebub 1.045 | No public source licence established | Treat restored Diablo concepts separately from Belzebub-authored implementation/content. No code import unless an explicitly licensed source release is located. |
| The Hell 4 | Difficulty design, monsters, affixes, class/balance and endgame ideas | **Reference first; selective adaptation only after provenance review** | `roboserg/the-hell-4-src@e8d0cc7468fe93227956d7477c7735e07a831c7f` | README grants derivative works and redistribution if the readme is retained and derivative uses another name | Repository is an unaffiliated mirror/fork of the March 3, 2026 source release. Before copying code, record exact files and verify the relevant notice/provenance. Do not copy workshop/game assets. |
| Infernity | QoL, stash/inventory, weapon swap, loot filter, shared map/XP, Inferno and item-generation ideas | **Adapt or reimplement per feature** | `qndel/Infernity@452155fd1a543964d07d8c2cd08ccf11014f5ade` | Unlicense / public domain dedication reviewed | Strongest near-term source for isolated QoL mechanics. Prefer DevilutionX-native implementations where upstream already provides equivalent behaviour. |

## Verified feature leads

### Infernity

Candidates worth studying first:

- stash and expanded inventory behaviour;
- alternate weapon slot / weapon swap;
- 12 spell hotkeys;
- loot filtering;
- shared multiplayer map and XP;
- larger gold stacks;
- monster resistance display;
- shift-click belt handling;
- third-affix item generation / Inferno difficulty as design references.

Do not port old rendering/HD work where DevilutionX already solves the problem.

### The Hell 4

Use mainly as an algorithm/design reference for:

- higher difficulty scaling;
- monster and boss composition;
- affix/item progression;
- class and endgame systems.

The source derives from an old Hellfire decompilation and is architecturally far from DevilutionX. Direct large-scale merges are prohibited; adaptations must be small and attributable.

### Tchernobog / Belzebub

Until an auditable, explicitly licensed source tree is identified, these projects are product/design references only. Mechanics may be independently implemented from observed/documented behaviour. Do not decompile their distributed binaries for RTT.

## Save-compatibility warning for itemisation

Diablo/DevilutionX packs items using base item ID, creation info and seed, then recreates item properties on load. Changing affix pools or ordering can therefore cause existing generated items to change when reloaded. New affixes, rare-item rules and corruption systems require an RTT save/version policy before they are enabled in a release.

## Classification

- **Adapt / pinned dependency** — use upstream code with an exact revision and licence compliance.
- **Adapt** — copy or transform specific source with file-level provenance and required notices.
- **Reimplement** — reproduce behaviour using new RTT code/data rather than third-party implementation.
- **Reference first** — study behaviour/source before deciding whether adaptation is appropriate.
- **Reference only** — do not import source; use only high-level design/behaviour as inspiration.
- **Reject** — intentionally excluded.

## Import checklist

Before any third-party source file or substantial code fragment enters RTT:

1. record project, repository, exact commit/tag and upstream path;
2. record the licence/permission text that applies;
3. identify whether Blizzard/proprietary assets or derived data are mixed into the source;
4. choose Adapt, Reimplement, Reference only or Reject;
5. document modifications and destination RTT module;
6. run save/network compatibility review when gameplay tables or deterministic generation are affected.
