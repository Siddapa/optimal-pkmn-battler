<script>
    import { onMount } from "svelte";
    import { DataSet, Network } from "vis-network/standalone";
    import { wasmExports } from '../stores.js';

    let zigRoot;

    let network;
    var nodes = new DataSet([]);
    var edges = new DataSet([]);
    let graphID = 0;

    function fetchString(memory, strLength) {
        const outputView = new Uint8Array(memory.buffer, 0, strLength);
        return new TextDecoder().decode(outputView);
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
                },
            },
            edges: {
                smooth: {
                    forceDirection: "vertical"
                },
            },
            width: "500px",
            height: "550px",
        };
        network = new Network(container, data, options);
    }

    const updateGraph = () => {
        nodes.clear();
        edges.clear();
        network.redraw();
        zigRoot = $wasmExports.generateOptimizedDecisionTree()

        populateDecisionGraph(zigRoot, 0);
        
        network.redraw();
    }

    const populateDecisionGraph = (zigNode, depth) => {
        const currNodeID = graphID;
        nodes.add([{id: currNodeID, level: depth, label: graphNodeLabel(zigNode, depth), zigNode: zigNode}]);
        graphID += 1;

        const numOfNextTurns = $wasmExports.getNumOfNextTurns(zigNode);
        for (let i = 0; i < numOfNextTurns; i++) {
            const nextNode = $wasmExports.getNextNode(zigNode, i);
            if (nextNode != 0) { // 0 pointers are null decision nodes
                const childNodeID = populateDecisionGraph(nextNode, depth + 1);
                edges.add([{from: currNodeID, to: childNodeID, arrows: "to"}])
            }
        }

        return currNodeID;
    }

    function graphNodeLabel(zigNode, depth) {
        return fetchString($wasmExports.memory, $wasmExports.getPlayerSpecies(zigNode, 0)) + " (" + String($wasmExports.getPlayerHP(zigNode)) + ")" +
               '\nvs\n' + 
               fetchString($wasmExports.memory, $wasmExports.getEnemySpecies(zigNode, 0)) + " (" + String($wasmExports.getEnemyHP(zigNode)) + ")";
    }

    onMount(() => {
        initGraph();
    });
</script>

<div>
    <h3>Decision Tree</h3>
    <input type="button" value="Generate Tree" onclick={updateGraph}/>
    <br>
    <br>
    <div id="decisionGraph"></div>
</div>

<style>
    #decisionGraph {
        border: 1px solid white;
    }
</style>
