#include "runtime/runtime_adapter.h"

const char *rtt_runtime_kind_name(RttRuntimeKind kind)
{
    switch (kind) {
    case RTT_RUNTIME_ABYSS:
        return "abyss";
    case RTT_RUNTIME_DEVILUTIONX:
        return "devilutionx";
    case RTT_RUNTIME_UNKNOWN:
    default:
        return "unknown";
    }
}

int rtt_runtime_adapter_valid(const RttRuntimeAdapter *adapter)
{
    return adapter != NULL && adapter->get_info != NULL;
}
