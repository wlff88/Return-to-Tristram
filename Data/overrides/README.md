# DevilutionX table overrides

Files in this directory are sparse RTT patches, not copies of upstream tables.

Rules:

- key columns identify existing upstream rows;
- blank cells preserve upstream values;
- existing rows may be patched;
- complete generated tables are written only to `out/`;
- table families are declared centrally in `config/table-map.json`;
- optional mapped tables need no patch file until RTT authors an override;
- adding new rows is intentionally blocked by the exporter.

A new row is not a normal sparse override. It must first receive a stable RTT semantic ID and define its save/network compatibility behavior before the exporter is extended to emit it.

Phase 2 maps items, affixes, uniques, monsters, spells and all shipped class tables in addition to the existing Experience and starter-loadout overrides.
