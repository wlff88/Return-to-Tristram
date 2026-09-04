# Recovery status

This repository was recreated on 2026-09-04 from surviving Return to Tristram artifacts stored in ChatGPT File Library.

## Confirmed recovered artifacts

- `README.md` — recovered from the saved SDK artifact.
- `SDK_FILELIST.txt` — recovered manifest of the original SDK tree.
- `docs/VERTICAL_SLICE_T1.md` — recovered Worldstone Rift T1 specification.
- `docs/ID_REGISTRY.md` — recovered custom ID registry.
- `return-to-tristram-d2r-sdk-v0.2.0.zip.sha256` checksum survives in File Library.

## Original package identity

- Version: `v0.2.0`
- Archive name: `return-to-tristram-d2r-sdk-v0.2.0.zip`
- SHA-256: `91ad1b3ce7607c7127c182f0fbe9becb4f9cdd2df04fe13dae27cfb27396fe05`

The original ZIP itself is not currently exposed as a retrievable binary file through the available File Library interface. Therefore code files that are listed in `SDK_FILELIST.txt` but not separately preserved must be reconstructed before they can be treated as functional source.

## Important provenance rule

Files copied verbatim from surviving artifacts are considered **recovered**.
Files recreated from documentation/specification must be marked **reconstructed** in their header or commit message until compared against the original archive.

## Next recovery target

Reconstruct and test:

1. Python build/patch/validation scripts.
2. D2RMM TypeScript scaffold.
3. Worldstone Rift T1 implementation.
4. Native mod metadata and CI workflow.
5. Validate locally against vanilla D2R tables extracted by the user.
