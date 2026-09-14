# DevilutionX table overrides

Files in this directory are sparse RTT patches, not copies of upstream tables.

- key columns identify upstream rows;
- blank cells preserve upstream values;
- existing rows are patched;
- generated complete tables are written only to `out/`.

The first pipeline smoke test targets `Experience.tsv` and deliberately keeps level 1 unchanged.
