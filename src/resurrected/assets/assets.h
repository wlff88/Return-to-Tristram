#ifndef RTT_ASSETS_H
#define RTT_ASSETS_H
#include <stddef.h>
#include <stdint.h>

typedef enum { RTT_OK, RTT_NOT_FOUND, RTT_UNSUPPORTED, RTT_INVALID, RTT_IO_ERROR } RttAssetStatus;
typedef enum { RTT_RGBA8 = 1, RTT_MESH = 2, RTT_ANIMATION = 4, RTT_AUDIO = 8 } RttAssetKind;

/* Immutable borrowed bytes: valid until the provider is destroyed. A renderer
 * must copy/upload them before then. No filesystem path crosses this API. */
typedef struct {
    const uint8_t *data;
    size_t size;
    uint32_t width, height;
    RttAssetKind kind;
    const char *source_fingerprint;
} RttAssetView;
typedef struct {
    const char *name;
    uint32_t capabilities;
    void *context;
    RttAssetStatus (*resolve)(void *, const char *, RttAssetKind, RttAssetView *);
} RttAssetProvider;
typedef struct {
    const RttAssetProvider *providers;
    size_t count;
} RttAssetResolver;

int rtt_asset_id_valid(const char *id);
RttAssetStatus rtt_resolve(const RttAssetResolver *, const char *, RttAssetKind, RttAssetView *);
RttAssetProvider rtt_test_provider(void);
#endif
