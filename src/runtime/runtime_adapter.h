#ifndef RTT_RUNTIME_ADAPTER_H
#define RTT_RUNTIME_ADAPTER_H

#include <stddef.h>

typedef enum RttRuntimeKind {
    RTT_RUNTIME_UNKNOWN = 0,
    RTT_RUNTIME_ABYSS,
    RTT_RUNTIME_DEVILUTIONX
} RttRuntimeKind;

typedef struct RttRuntimeInfo {
    RttRuntimeKind kind;
    const char *name;
    const char *upstream_revision;
    unsigned int capabilities;
} RttRuntimeInfo;

enum RttRuntimeCapability {
    RTT_RUNTIME_CAP_EVENTS        = 1u << 0,
    RTT_RUNTIME_CAP_ENTITY_QUERY  = 1u << 1,
    RTT_RUNTIME_CAP_ITEM_GRANT    = 1u << 2,
    RTT_RUNTIME_CAP_QUEST_HOOKS   = 1u << 3,
    RTT_RUNTIME_CAP_ASSET_MAPPING = 1u << 4,
    RTT_RUNTIME_CAP_GAMEPAD       = 1u << 5
};

typedef struct RttRuntimeAdapter {
    void *context;
    RttRuntimeInfo (*get_info)(void *context);
    int (*poll_event)(void *context, char *event_name, size_t event_name_size);
    int (*map_asset)(void *context, const char *logical_id, char *native_id, size_t native_id_size);
} RttRuntimeAdapter;

const char *rtt_runtime_kind_name(RttRuntimeKind kind);
int rtt_runtime_adapter_valid(const RttRuntimeAdapter *adapter);

#endif
