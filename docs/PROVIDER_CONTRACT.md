# Provider contract v1

`src/resurrected/assets/assets.h` is a C99 presentation-only boundary. Logical
IDs are lowercase `asset://` segments containing letters, digits, `_` and `-`.
No filesystem path is accepted. Kind is one of RGBA8, mesh, animation or audio.
Only RGBA8 is implemented by the synthetic provider.

Providers return immutable borrowed bytes, format metadata and a source
fingerprint. Bytes remain valid for the provider lifetime; consumers must
copy/upload them before destruction. The test provider uses static bytes.
Future streaming providers need a new explicit retain/release contract rather
than silently shortening this lifetime.

Resolver order is caller-supplied. NOT_FOUND and UNSUPPORTED permit fallback;
IO_ERROR and INVALID stop resolution. Output is cleared on failure and a
successful RGBA8 result must have dimensions consistent with its byte length.
The last miss status is returned if no provider succeeds.

The synthetic fixture is original 2x2 RGBA test data. It is not a replacement
for missing D2R graphics and is not mapped under game entity IDs.

Tests exercise ordered fallback, errors, kinds, IDs and byte metadata without
game files. Actual gameplay/render integration is pending because upstream
has no gameplay loop. Do not call the provider test a gameplay integration test.

## Installation and manifest boundary

`tools/d2r_install.py --path <installation>` reads `.build.info`, checks the
root layout and reports the active version/build key. Without --path it tries
RTT_D2R_PATH then standard Windows install locations. Explicit paths do not
silently fall back. Conflicting active builds fail.

The deterministic fingerprint hashes canonical version/build identity and
changes on a build update. It is not an asset-content hash. The tool reports
`presentation_supported: false` until real codecs and mappings are verified.
It does not mount CASC or create cache files.

Future LocalAssetCache keys must include input content SHA256, build identity,
mapping version and codec/options version. Default location is outside Git
under LOCALAPPDATA/ReturnToTristram/cache. Cache implementation is deferred
until a transcoder supplies meaningful input/output artifacts.
