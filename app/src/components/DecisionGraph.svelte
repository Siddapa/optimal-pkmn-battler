<script>
    import { onMount } from "svelte";
    import { DataSet, Network } from "vis-network/standalone";
    import { wasmExports } from '../stores.js';

    let treeRoot;

    let network;
    var nodes = new DataSet([]);
    var edges = new DataSet([]);
    let graphID = 0;

    async function fetchString(strLength) {
        $wasmExports.memory().then((memory) => {
            const outputView = new Uint8Array(memory.buffer, 0, strLength);
            return new TextDecoder().decode(outputView);
        });
        
    }

    async function fetchArray(arrLength) {
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

    const updateGraph = async () => {
        nodes.clear();
        edges.clear();
        network.redraw();

        // console.log($wasmExports);
        // console.log(typeof $wasmExports.memory);
        // $wasmExports.memory().then((result) => console.log(result.buffer));
        // console.log(await $wasmExports.test_int());
        // console.log(fetchString(await $wasmExports.test_string(0)));

        // $wasmExports.generateOptimizedDecisionTree(0).then((result) => {
        //     console.log(result);

        //     treeRoot = result;
        //     populateDecisionGraph(treeRoot, 0);
        // 
        //     network.redraw();
        // });
    }

    const populateDecisionGraph = async (treeNode, depth) => {
        const currNodeID = graphID;

        var bkgdColor = "#00FF00";

        // $wasmExports.getResult(treeNode).then((result) => {
        //     $wasmExports.getHP(treeNode, true).then((playerHP) => {
        //         $wasmExports.getHP(treeNode, false).then((enemyHP) => {
        //             if (result != 1) {
        //                 bkgdColor = "#0000FF";
        //             } else if (playerHP == 0 || enemyHP == 0) {
        //                 bkgdColor = "#FF0000";
        //             }
        //         });
        //     });
        // });

        if (await $wasmExports.getResult(treeNode) != 1) {
            bkgdColor = "#0000FF"
        } else if (await $wasmExports.getHP(treeNode, true) == 0 || await $wasmExports.getHP(treeNode, false) == 0) {
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

        // $wasmExports.getNumOfNextTurns(treeNode).then((numOfNextTurns) => {
        //     for (let i = 0; i < numOfNextTurns; i++) {
        //         $wasmExports.getNextNode(treeNode, i).then((nextNode) => {
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

        const numOfNextTurns = await $wasmExports.getNumOfNextTurns(treeNode);
        for (let i = 0; i < numOfNextTurns; i++) {
            const nextNode = await $wasmExports.getNextNode(treeNode, i);
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
        return fetchString(await $wasmExports.getTransitionChoice(treeNode, index, true, 0)) + "\n" + fetchString(await $wasmExports.getTransitionChoice(treeNode, index, false, 0));
    }

    async function graphNodeLabel(treeNode, depth) {
        return fetchString(await $wasmExports.getSpecies(treeNode, true, 0)) + " (" + String(await $wasmExports.getHP(treeNode, true)) + ")" +
               '\nvs\n' + 
               fetchString(await $wasmExports.getSpecies(treeNode, false, 0)) + " (" + String(await $wasmExports.getHP(treeNode, false)) + ")" + 
               '\n' + 
               fetchArray(await $wasmExports.getTeam(treeNode, 0)) + 
               '\n' + 
               await $wasmExports.getScore(treeNode);
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
