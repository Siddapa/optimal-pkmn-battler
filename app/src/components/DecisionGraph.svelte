<div>
    <h3>Decision Tree</h3>
    <div class="generate-settings">
        <input class="button" type="button" value="Generate Tree" on:click={updateGraph}/>
        <span class="status">{gs_state}</span>
    </div>
    <br>
    <br>
    <div id="decisionGraph"></div>
</div>


<script lang="ts">
    import { onMount } from "svelte";
    import { Uint32 } from "../wasi/types.ts";
    import { DataSet, Network } from "vis-network/standalone";
    import { wasmWorker, playerBox, enemyBox } from '../stores.ts';

    let tree_root;

    let network;
    var nodes = new DataSet([]);
    var edges = new DataSet([]);
    var nodes_buffer = [];
    var edges_buffer = [];
    let graph_id = 0;

    let gs_state = $state("");

    onMount(() => {
        initGraph();
    });

    function update_gs(...states) {
        gs_states = states;
    }

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
            gs_state = "Import some pokemon for the player first!";
            return;
        } else if ($enemyBox.length == 0) {
            gs_state = "Import some pokemon for the enemy first!";
            return;
        }

        nodes.clear();
        edges.clear();
        network.redraw();

        gs_state = "Calculating optimal line...";

        $wasmWorker.exports.generateOptimizedDecisionTree(new Uint32(0)).then(async (result) => {
            [tree_root] = result;

            gs_state = "Fetching tree...";
            const [tree_data] = await $wasmWorker.exports.getTreeData(new Uint32(tree_root));
            console.log(tree_data);

            gs_state = "Populating graph...";
            await populateDecisionGraph(tree_data, 0);

            gs_state = "Rendering graph...";
            nodes.add(nodes_buffer);
            edges.add(edges_buffer);
            network.redraw();
            network.moveTo({scale: 0.3, animation: {duration: 5000, easingFunction: "easeInCubic"}});

            gs_state = "Finished!";
            graph_id = 0;
            nodes_buffer = [];
            edges_buffer = [];
        });
    }

    const populateDecisionGraph = async (tree_data, depth) => {
        const score = tree_data['data'][0];
        const result = tree_data['data'][1];
        const player_lead_name = tree_data['data'][2];
        const player_lead_hp = tree_data['data'][3];
        const player_choice = tree_data['data'][4];
        const enemy_lead_name = tree_data['data'][5];
        const enemy_lead_hp = tree_data['data'][6];
        const enemy_choice = tree_data['data'][7];

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
            }
        });
        graph_id += 1;

        for (const next_node_data of tree_data['children']) {
            const child_id = await populateDecisionGraph(next_node_data, depth + 1);
            edges_buffer.push({
                from: curr_id,
                to: child_id, 
                label: `P: ${player_choice}\nE: ${enemy_choice}`,
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

        return curr_id;
    }
</script>


<style>
    #decisionGraph {
        border: 1px solid white;
        width: 25em;
        height: 30em;
    }

    .generate-settings {
        display: grid;
        grid-template-columns: repeat(2, fit-content(100%));
        grid-template-rows: 1fr;
        grid-column-gap: 1em;
        grid-row-gap: 0em;
    }

    .button {
        width: 10em;
        height: 2em;
    }

    .status {
        color: lightgreen;
        width: 30em;
        height: 2em;
    }

</style>
