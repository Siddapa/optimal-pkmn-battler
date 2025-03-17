<script>
    import { onMount } from "svelte";
    import { DataSet, Network } from "vis-network/standalone";
    import { wasmExports } from '../stores.js';

    let treeRoot;

    let network;
    var nodes = new DataSet([]);
    var edges = new DataSet([]);
    let graphID = 0;

    function fetchString(strLength) {
        const outputView = new Uint8Array($wasmExports.memory.buffer, 0, strLength);
        return new TextDecoder().decode(outputView);
    }

    function fetchArray(arrLength) {
        return new Int8Array($wasmExports.memory.buffer, 0, arrLength);
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
                    levelSeparation: 300,
                    nodeSpacing: 300,
                },
            },
            physics: {
                "enabled": false,
                barnesHut: {
                    avoidOverlap: 0.5,
                }
            },
            width: "1000px",
            height: "300px",
        };
        network = new Network(container, data, options);
    }

    const updateGraph = () => {
        nodes.clear();
        edges.clear();
        network.redraw();
        treeRoot = $wasmExports.generateOptimizedDecisionTree(0);

        populateDecisionGraph(treeRoot, 0);
        
        network.redraw();
    }

    const populateDecisionGraph = (treeNode, depth) => {
        const currNodeID = graphID;

        var bkgdColor = "#00FF00";

        if ($wasmExports.getResult(treeNode) != 1) {
            bkgdColor = "#0000FF"
        } else if ($wasmExports.getHP(treeNode, true) == 0 || $wasmExports.getHP(treeNode, false) == 0) {
            bkgdColor = "#FF0000"
        }
        
        nodes.add([{
            id: currNodeID, 
            level: depth, 
            label: graphNodeLabel(treeNode, depth), 
            color: {
                background: bkgdColor
            },
            treeNode: treeNode
        }]);
        graphID += 1;

        const numOfNextTurns = $wasmExports.getNumOfNextTurns(treeNode);
        for (let i = 0; i < numOfNextTurns; i++) {
            const nextNode = $wasmExports.getNextNode(treeNode, i);
            if (nextNode != 0) { // 0 pointers are null decision nodes
                const childNodeID = populateDecisionGraph(nextNode, depth + 1);
                edges.add([{
                    from: currNodeID, 
                    to: childNodeID, 
                    label: graphEdgeLabel(treeNode, i),
                    font: {
                        face: "Arial", 
                        color: "blue", 
                        size: 15
                    },
                    shadow: false,
                    arrows: "to"
                }])
            }
        }

        return currNodeID;
    }

    function graphEdgeLabel(treeNode, index) {
        return fetchString($wasmExports.getTransitionChoice(treeNode, index, true, 0)) + "\n" + fetchString($wasmExports.getTransitionChoice(treeNode, index, false, 0));
    }

    function graphNodeLabel(treeNode, depth) {
        return fetchString($wasmExports.getSpecies(treeNode, true, 0)) + " (" + String($wasmExports.getHP(treeNode, true)) + ")" +
               '\nvs\n' + 
               fetchString($wasmExports.getSpecies(treeNode, false, 0)) + " (" + String($wasmExports.getHP(treeNode, false)) + ")" + 
               '\n' + 
               fetchArray($wasmExports.getTeam(treeNode, 0)) + 
               '\n' + 
               $wasmExports.getScore(treeNode);
    }

    onMount(() => {
        initGraph();
    });
</script>

<div>
    <h3>Decision Tree</h3>
    <input type="button" value="Generate Tree" on:click={updateGraph}/>
    <br>
    <br>
    <div id="decisionGraph"></div>
</div>

<style>
    #decisionGraph {
        border: 1px solid white;
    }
</style>
