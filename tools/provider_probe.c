#include "resurrected/assets/assets.h"
#include <stdio.h>
int main(void) {
    RttAssetProvider provider = rtt_test_provider();
    RttAssetResolver resolver = { &provider, 1 };
    RttAssetView view;
    if (rtt_resolve(&resolver, "asset://test/checker/texture", RTT_RGBA8, &view) != RTT_OK) return 1;
    printf("RTT provider probe: %ux%u, %zu bytes, source=%s\n", view.width, view.height, view.size, view.source_fingerprint);
    return 0;
}
