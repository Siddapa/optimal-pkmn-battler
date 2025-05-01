<div>
    <h3 class="title">Decision Tree</h3>
    <div class="generate-settings">
        <input class="button" type="button" value="Generate Tree" on:click={updateGraph}/>
        <span class="status">{$status}</span>
        <div id="decisionGraph"></div>
    </div>
</div>


<script lang="ts">
    import { onMount } from "svelte";
    import { Uint32 } from "../wasi/types.ts";
    import { DataSet, Network } from "vis-network/standalone";
    import { status, wasmWorker, playerBox, enemyBox } from '../stores.ts';

    let tree_root;

    let network;
    var nodes = new DataSet([]);
    var edges = new DataSet([]);
    var nodes_buffer = [];
    var edges_buffer = [];
    let graph_id = 0;

    onMount(() => {
        initGraph();
    });

    function initGraph() {
        var container = document.getElementById("decisionGraph");
        var data = {
            nodes: nodes,
            edges: edges,
        };
        var options = {
            layout: {
                hierarchical: {
                    direction: "UD",
                    levelSeparation: 200,
                    nodeSpacing: 250,
                },
            },
            physics: {
                "enabled": false,
                barnesHut: {
                    springConstant: 0,
                    avoidOverlap: 1,
                }
            },
            width: "100%",
            height: "100%",
        };
        network = new Network(container, data, options);
    }

    const updateGraph = async () => {
        if ($playerBox.length == 0) {
            $status = "Import some pokemon for the player first!";
            return;
        } else if ($enemyBox.length == 0) {
            $status = "Import some pokemon for the enemy first!";
            return;
        }

        nodes.clear();
        edges.clear();
        network.redraw();

        $status = "Calculating optimal line...";

        $wasmWorker.exports.generateOptimizedDecisionTree(new Uint32(0)).then(async (result) => {
            [tree_root] = result;

            $status = "Fetching tree...";
            const [tree_data] = await $wasmWorker.exports.getTreeData(new Uint32(tree_root));
            const tree_stats = fetchStats(tree_data, 0);
            console.log("tree_data", tree_data);
            console.log("tree_stats", tree_stats);

            $status = "Populating graph...";
            await populateDecisionGraph(tree_data, 0);

            $status = "Rendering graph...";
            nodes.add(nodes_buffer);
            edges.add(edges_buffer);
            network.redraw();
            network.moveTo({
                position : {x: 0, y: -90 * tree_stats.max_depth},
                scale: 0.5,
                animation: {
                    duration: 4000,
                    easingFunction: "easeOutCubic"
                },
            });

            $status = "Finished!";
            graph_id = 0;
            nodes_buffer = [];
            edges_buffer = [];
        });
    }

    const fetchStats = (tree_data, depth) => {
        let node_count = 1;
        let max_depth = 0;
        for (const next_node_data of tree_data['children']) {
            const child_stats = fetchStats(next_node_data, depth + 1);
            node_count += child_stats.node_count;
            if (child_stats.max_depth > max_depth) {
                max_depth = child_stats.max_depth;
            }
        }
        if (depth > max_depth) {
            max_depth = depth;
        }

        return {
            node_count: node_count,
            max_depth: max_depth,
        };
    }

    const populateDecisionGraph = async (tree_data, depth) => {
        const id = tree_data['data'][0];
        const score = tree_data['data'][1];
        const result = tree_data['data'][2];
        const player_lead_name = tree_data['data'][3];
        const player_lead_hp = tree_data['data'][4];
        const player_choice = tree_data['data'][5];
        const enemy_lead_name = tree_data['data'][6];
        const enemy_lead_hp = tree_data['data'][7];
        const enemy_choice = tree_data['data'][8];

        var bkgdColor = "#00FF00";
        if (result != 1) {
            bkgdColor = "#ADD8E6"
        } else if (player_lead_hp == 0 || enemy_lead_hp == 0) {
            bkgdColor = "#FF0000"
        }
        
        const curr_id = graph_id;
        nodes_buffer.push({
            id: graph_id,
            level: depth, 
            label: `${player_lead_name} (${player_lead_hp})\nvs\n${enemy_lead_name} (${enemy_lead_hp})\n${score}`, 
            color: {
                background: bkgdColor
            },
            font: {
                face: "Roboto",
                size: 18
            },
            node_data: tree_data['data']
        });
        graph_id += 1;

        for (const next_node_data of tree_data['children']) {
            const [child_id, child_player_choice, child_enemy_choice] = await populateDecisionGraph(next_node_data, depth + 1);
            edges_buffer.push({
                from: curr_id,
                to: child_id, 
                label: `P: ${child_player_choice}\nE: ${child_enemy_choice}`,
                font: {
                    face: "Roboto",
                    color: "red", 
                    size: 18,
                    strokeWidth: 0,
                },
                shadow: false,
                arrows: "to"
            })
        }

        return [curr_id, player_choice, enemy_choice];
    }
</script>


<style>
    .generate-settings {
        display: grid;
        grid-template-columns: repeat(2, fit-content(100%));
        grid-template-rows: repeat(2, fit-content(100%));
        grid-column-gap: 1em;
        grid-row-gap: 1em;
    }

    .button {
        width: 10em;
        height: 2em;
    }

    .status {
        color: lightgreen;
        width: 15em;
        height: 2em;
    }

    #decisionGraph {
        border: 1px solid white;
        width: 25em;
        height: 30em;
        grid-area: 2 / 1 / 3 / 3;
    }

</style>
