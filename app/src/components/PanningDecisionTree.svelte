<script>
    import { WASI } from "@runno/wasi";
    import { onMount } from "svelte";
    import { DataSet, Network } from "vis-network/standalone";

    let exports;
    let zigRoot;

    let network;
    var nodes = new DataSet([]);
    var edges = new DataSet([]);
    let graphID = 0;

    async function runWASM() {
        const wasi = new WASI({
            args: [],
            env: {},
            stdout: (out) => console.log("stdout", out),
            // Removed stderr printing
            stdin: () => prompt("stdin:"),
            fs: {},
        });
        const wasm = await WebAssembly.instantiateStreaming(
            fetch("gen1.wasm"), {
                ...wasi.getImportObject(),
                env: {},
            });
        const result = wasi.start(wasm, {});

        exports = wasm.instance.exports;
    }

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
            width: "500px",
            height: "550px",
        };
        network = new Network(container, data, options);
    }

    const updateGraph = () => {
        nodes.clear();
        edges.clear();
        zigRoot = exports.generateOptimizedDecisionTree()

        populateDecisionGraph(zigRoot);
        
        network.redraw();
    }

    const populateDecisionGraph = (zigNode) => {
        const currNodeID = graphID;
        console.log(currNodeID);
        nodes.add([{id: currNodeID, label: graphNodeLabel(zigNode), zigNode: zigNode}]);
        graphID += 1;

        const numOfNextTurns = exports.getNumOfNextTurns(zigNode);
        for (let i = 0; i < numOfNextTurns; i++) {
            const nextNode = exports.getNextNode(zigNode, i);
            if (nextNode != 0) { // 0 pointers are null decision nodes
                const childNodeID = populateDecisionGraph(nextNode, nodes, edges);
                edges.add([{from: currNodeID, to: childNodeID, arrows: "to"}])
            }
        }

        return currNodeID;
    }

    function graphNodeLabel(zigNode) {
        return fetchString(exports.memory, exports.getPlayerSpecies(zigNode, 0)) + 
               '\nvs\n' + 
               fetchString(exports.memory, exports.getEnemySpecies(zigNode, 0));
    }

    onMount(() => {
        runWASM();
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
