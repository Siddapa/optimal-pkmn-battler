<script>
    import { onMount } from "svelte";
    import { DataSet, Network } from "vis-network/standalone";
    import { wasmWorker } from '../stores.js';

    let treeRoot;

    let network;
    var nodes = new DataSet([]);
    var edges = new DataSet([]);
    let graphID = 0;

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

    const updateGraph = async () => {
        nodes.clear();
        edges.clear();
        network.redraw();

        $wasmWorker.exports.generateOptimizedDecisionTree(0).then((result) => {
            console.log(result);

            treeRoot = result;
            populateDecisionGraph(treeRoot, 0);
        
            network.redraw();
        });
    }

    const populateDecisionGraph = async (treeNode, depth) => {
        const currNodeID = graphID;

        var bkgdColor = "#00FF00";

        // $wasmWorker.exports.getResult(treeNode).then((result) => {
        //     $wasmWorker.exports.getHP(treeNode, true).then((playerHP) => {
        //         $wasmWorker.exports.getHP(treeNode, false).then((enemyHP) => {
        //             if (result != 1) {
        //                 bkgdColor = "#0000FF";
        //             } else if (playerHP == 0 || enemyHP == 0) {
        //                 bkgdColor = "#FF0000";
        //             }
        //         });
        //     });
        // });

        if (await $wasmWorker.exports.getResult(treeNode) != 1) {
            bkgdColor = "#0000FF"
        } else if (await $wasmWorker.exports.getHP(treeNode, true) == 0 || await $wasmWorker.exports.getHP(treeNode, false) == 0) {
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

        // $wasmWorker.exports.getNumOfNextTurns(treeNode).then((numOfNextTurns) => {
        //     for (let i = 0; i < numOfNextTurns; i++) {
        //         $wasmWorker.exports.getNextNode(treeNode, i).then((nextNode) => {
        //             if (nextNode != 0) { // 0 pointers are null decision nodes
        //                 const childNodeID = populateDecisionGraph(nextNode, depth + 1);
        //                 edges.add([{
        //                     from: currNodeID, 
        //                     to: childNodeID, 
        //                     label: graphEdgeLabel(treeNode, i),
        //                     font: {
        //                         face: "Arial", 
        //                         color: "blue", 
        //                         size: 15
        //                     },
        //                     shadow: false,
        //                     arrows: "to"
        //                 }])
        //             }
        //         });
        //     }
        // });

        const numOfNextTurns = await $wasmWorker.exports.getNumOfNextTurns(treeNode);
        for (let i = 0; i < numOfNextTurns; i++) {
            const nextNode = await $wasmWorker.exports.getNextNode(treeNode, i);
            if (nextNode != 0) { // 0 pointers are null decision nodes
                const childNodeID = await populateDecisionGraph(nextNode, depth + 1);
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

    async function graphEdgeLabel(treeNode, index) {
        return $wasmWorker.exports.getTransitionChoice(treeNode, index, true, 0) + "\n" + await $wasmWorker.exports.getTransitionChoice(treeNode, index, false, 0);
    }

    async function graphNodeLabel(treeNode, depth) {
        return await $wasmWorker.exports.getSpecies(treeNode, true, 0) + " (" + String(await $wasmWorker.exports.getHP(treeNode, true)) + ")" +
               '\nvs\n' + 
               await $wasmWorker.exports.getSpecies(treeNode, false, 0) + " (" + String(await $wasmWorker.exports.getHP(treeNode, false)) + ")" + 
               '\n' + 
               await $wasmWorker.exports.getScore(treeNode);
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
