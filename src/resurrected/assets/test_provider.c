#include "assets.h"
#include <string.h>

/* Original synthetic fixture, deliberately not a Diablo asset. */
static const uint8_t pixels[] = { 45, 170, 120, 255, 210, 190, 60, 255,
                                210, 190, 60, 255, 45, 170, 120, 255 };
static RttAssetStatus resolve(void *context, const char *id, RttAssetKind kind, RttAssetView *out) {
    (void)context;
    if (kind != RTT_RGBA8) return RTT_UNSUPPORTED;
    if (strcmp(id, "asset://test/checker/texture")) return RTT_NOT_FOUND;
    *out = (RttAssetView){ pixels, sizeof(pixels), 2, 2, RTT_RGBA8, "rtt-synthetic-checker-v1" };
    return RTT_OK;
}
RttAssetProvider rtt_test_provider(void) {
    return (RttAssetProvider){ "synthetic", RTT_RGBA8, NULL, resolve };
}
