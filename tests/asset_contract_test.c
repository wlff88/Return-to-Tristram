#include "resurrected/assets/assets.h"
#include <stdio.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "FAILED line %d: %s\n", __LINE__, #x); return 1; } } while (0)
static RttAssetStatus fail(void *context, const char *id, RttAssetKind kind, RttAssetView *out) {
    (void)id; (void)kind;
    memset(out, 255, sizeof(*out));
    return *(RttAssetStatus *)context;
}
int main(void) {
    RttAssetStatus status = RTT_NOT_FOUND;
    RttAssetProvider providers[] = { {"first", RTT_RGBA8, &status, fail}, rtt_test_provider() };
    RttAssetResolver resolver = {providers, 2};
    RttAssetView view = {0};
    const char *invalid[] = {NULL, "", "asset://", "asset://a/../b", "asset://a//b", "asset://a/", "C:/file", "asset://A/b", "asset://a/%2e"};
    size_t i;
    for (i = 0; i < sizeof(invalid)/sizeof(*invalid); ++i) CHECK(!rtt_asset_id_valid(invalid[i]));
    CHECK(rtt_resolve(&resolver, "asset://test/checker/texture", RTT_RGBA8, &view) == RTT_OK);
    CHECK(view.size == 16 && view.width == 2 && view.data[3] == 255);
    status = RTT_UNSUPPORTED;
    CHECK(rtt_resolve(&resolver, "asset://test/checker/texture", RTT_RGBA8, &view) == RTT_OK);
    status = RTT_IO_ERROR;
    CHECK(rtt_resolve(&resolver, "asset://test/checker/texture", RTT_RGBA8, &view) == RTT_IO_ERROR);
    CHECK(view.data == NULL && view.size == 0);
    status = RTT_NOT_FOUND;
    CHECK(rtt_resolve(&resolver, "asset://missing/texture", RTT_RGBA8, &view) == RTT_NOT_FOUND);
    CHECK(rtt_resolve(&resolver, "asset://test/checker/texture", RTT_MESH, &view) == RTT_UNSUPPORTED);
    CHECK(rtt_resolve(&resolver, "asset://test/checker/texture", (RttAssetKind)3, &view) == RTT_INVALID);
    puts("Provider priority, fallback, error isolation, logical IDs and capabilities: passed");
    return 0;
}
