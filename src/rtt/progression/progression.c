#include "rtt/progression/progression.h"

int rtt_progression_has_connection(const RttProgressionGraph *graph, size_t from, size_t to)
{
    if (graph == NULL || from >= graph->node_count || to >= graph->node_count)
        return 0;

    for (size_t i = 0; i < graph->edge_count; ++i) {
        const RttProgressionEdge edge = graph->edges[i];
        if ((edge.from == from && edge.to == to) || (edge.from == to && edge.to == from))
            return 1;
    }

    return 0;
}

int rtt_progression_can_unlock(const RttProgressionGraph *graph, const RttProgressionState *state, size_t node_index)
{
    if (graph == NULL || state == NULL || state->unlocked == NULL || node_index >= graph->node_count)
        return 0;
    if (state->unlocked_count < graph->node_count || state->unlocked[node_index] != 0)
        return 0;

    const RttProgressionNode *node = &graph->nodes[node_index];
    if (state->character_level < node->required_level || state->available_points < node->cost)
        return 0;

    /* Starter nodes (index 0) can be purchased without an existing connection. */
    if (node_index == 0)
        return 1;

    for (size_t i = 0; i < graph->node_count; ++i) {
        if (state->unlocked[i] != 0 && rtt_progression_has_connection(graph, i, node_index))
            return 1;
    }

    return 0;
}

int rtt_progression_unlock(const RttProgressionGraph *graph, RttProgressionState *state, size_t node_index)
{
    if (!rtt_progression_can_unlock(graph, state, node_index))
        return 0;

    state->available_points -= graph->nodes[node_index].cost;
    state->unlocked[node_index] = 1;
    return 1;
}
