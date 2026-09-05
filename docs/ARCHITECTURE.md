# Architecture Notes

## System boundaries

The project is split into three conceptual products:

1. **Abyss Core** — upstream clean-room Diablo II simulation/runtime.
2. **Abyss Resurrected** — compatibility, asset-provider, cache and modern presentation layer.
3. **Return to Tristram** — original gameplay/content/endgame module.

The most important boundary is between **simulation** and **presentation**.

```text
Simulation state
  units / maps / skills / missiles / items / quests
                    |
                    v
            Presentation snapshot
                    |
        +-----------+-----------+
        |                       |
   AssetResolver              Renderer
        |
 +------+------+ 
 |             |
D2R           RTT/Test
provider      provider
```

## Asset-provider contract

A provider should expose capabilities and resolve logical asset identifiers. It should not leak source-specific paths into gameplay code.

Minimum responsibilities:

- capability query;
- asset existence query;
- metadata/manifest lookup;
- load/open resource handle;
- source build fingerprint;
- diagnostics.

The resolver owns provider priority/fallback.

## D2R provider security/distribution boundary

Treat the D2R installation as external user data.

- read-only source;
- no network retrieval;
- no repository writes;
- no CI dependency;
- no protection bypass;
- local derivative cache is disposable and build-fingerprinted;
- unsupported versions fail closed with diagnostics.

## Data-driven RTT

RTT should move content out of C wherever practical. A future schema should cover:

- items/affixes;
- skills;
- monsters;
- encounter phases;
- loot tables;
- recipes;
- portals/keys;
- map metadata.

The schema format is intentionally undecided until the upstream Abyss data model is audited.

## Upstream integration rule

Do not choose fork/subtree/submodule by preference alone. ADR 0001 must evaluate maintenance burden, patch visibility, build ergonomics and license preservation against current upstream structure.

## Future renderer

Do not assume the final renderer must reproduce D2R internals. Required outcome is equivalent high-resolution presentation quality, while the simulation remains Abyss-driven. The provider should make it possible to use D2R-local presentation resources when technically and legally appropriate and to fall back to project-owned/test assets.
