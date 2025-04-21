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


<script>
    import { onMount } from "svelte";
    import { Uint32 } from "@runno/wasi";
    import { DataSet, Network } from "vis-network/standalone";
    import { wasmWorker, playerBox, enemyBox } from '../stores.js';

    let treeRoot;

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
                    levelSeparation: 500,
                    nodeSpacing: 500,
                },
            },
            physics: {
                "enabled": true,
                barnesHut: {
                    springConstant: 0,
                    avoidOverlap: 0.5,
                }
            },
            width: "1000px",
            height: "300px",
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
            [treeRoot] = result;
            nodes_buffer = [];
            edges_buffer = [];

            gs_state = "Fetching tree...";

            await populateDecisionGraph(treeRoot, 0);
            graph_id = 0;

            gs_state = "Rendering graph...";
        
            nodes.add(nodes_buffer);
            edges.add(edges_buffer);
            network.redraw();
            network.moveTo({scale: 0.3, animation: {duration: 5000, easingFunction: "easeInCubic"}});

            gs_state = "Finished!";
        });
    }

    const populateDecisionGraph = async (treeNode, depth) => {
        console.log(graph_id);
        // Fetching node data is the longest part of building the graph
        // DON'T separate out the calls, instead do one bulk read
        // Ideally, we're able to dump the whole tree and read it all at once
        const [score, result, player_lead_name, player_lead_hp, player_choice, enemy_lead_name, enemy_lead_hp, enemy_choice, next_nodes] = await $wasmWorker.exports.getNodeData(new Uint32(treeNode));

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
            treeNode: treeNode
        });
        graph_id += 1;

        for (const next_node of next_nodes) {
            const child_id = await populateDecisionGraph(next_node, depth + 1);
            edges_buffer.push({
                from: curr_id,
                to: child_id, 
                label: "",
                font: {
                    face: "Arial", 
                    color: "blue", 
                    size: 15
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
    }

    .generate-settings {
        width: min-content;
        height: min-content;
        display: grid;
        grid-template-columns: repeat(2, fit-content(100%));
        grid-template-rows: 1fr;
        grid-column-gap: 1em;
        grid-row-gap: 0px;
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
