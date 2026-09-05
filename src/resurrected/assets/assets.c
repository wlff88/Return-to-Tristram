#include "assets.h"
#include <string.h>

int rtt_asset_id_valid(const char *id) {
    size_t i, length = 0, segment = 0;
    if (!id) return 0;
    while (length <= 255 && id[length]) ++length;
    if (length > 255 || length <= 8 || strncmp(id, "asset://", 8)) return 0;
    for (i = 8; i < length; ++i) {
        unsigned char c = (unsigned char)id[i];
        if (c == '/') {
            if (!segment) return 0;
            segment = 0;
        } else {
            if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '-')) return 0;
            ++segment;
        }
    }
    return segment != 0;
}

RttAssetStatus rtt_resolve(const RttAssetResolver *resolver, const char *id, RttAssetKind kind, RttAssetView *out) {
    size_t i;
    RttAssetStatus last = RTT_NOT_FOUND;
    if (!out) return RTT_INVALID;
    memset(out, 0, sizeof(*out));
    if (!resolver || (resolver->count && !resolver->providers) || !rtt_asset_id_valid(id) ||
        (kind != RTT_RGBA8 && kind != RTT_MESH && kind != RTT_ANIMATION && kind != RTT_AUDIO)) return RTT_INVALID;
    for (i = 0; i < resolver->count; ++i) {
        const RttAssetProvider *provider = &resolver->providers[i];
        RttAssetView candidate = {0};
        RttAssetStatus status;
        if (!provider->resolve) return RTT_INVALID;
        if (!(provider->capabilities & (uint32_t)kind)) { last = RTT_UNSUPPORTED; continue; }
        status = provider->resolve(provider->context, id, kind, &candidate);
        if (status == RTT_OK) {
            if (!candidate.data || !candidate.size || candidate.kind != kind || !candidate.source_fingerprint) return RTT_INVALID;
            if (kind == RTT_RGBA8 && (!candidate.width || !candidate.height ||
                (uint64_t)candidate.width * candidate.height > SIZE_MAX / 4 ||
                candidate.size != (size_t)candidate.width * candidate.height * 4)) return RTT_INVALID;
            *out = candidate;
            return RTT_OK;
        }
        if (status != RTT_NOT_FOUND && status != RTT_UNSUPPORTED) return status;
        last = status;
    }
    return last;
}
