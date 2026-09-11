#ifndef RTT_PROGRESSION_H
#define RTT_PROGRESSION_H

#include <stddef.h>

typedef enum RttProgressionNodeType {
    RTT_NODE_MINOR = 0,
    RTT_NODE_NOTABLE,
    RTT_NODE_KEYSTONE,
    RTT_NODE_MASTERY,
    RTT_NODE_SPECIALIZATION
} RttProgressionNodeType;

typedef struct RttProgressionNode {
    const char *id;
    RttProgressionNodeType type;
    unsigned int cost;
    unsigned int required_level;
} RttProgressionNode;

typedef struct RttProgressionEdge {
    size_t from;
    size_t to;
} RttProgressionEdge;

typedef struct RttProgressionGraph {
    const RttProgressionNode *nodes;
    size_t node_count;
    const RttProgressionEdge *edges;
    size_t edge_count;
} RttProgressionGraph;

typedef struct RttProgressionState {
    unsigned int character_level;
    unsigned int available_points;
    unsigned char *unlocked;
    size_t unlocked_count;
} RttProgressionState;

int rtt_progression_has_connection(const RttProgressionGraph *graph, size_t from, size_t to);
int rtt_progression_can_unlock(const RttProgressionGraph *graph, const RttProgressionState *state, size_t node_index);
int rtt_progression_unlock(const RttProgressionGraph *graph, RttProgressionState *state, size_t node_index);

#endif
