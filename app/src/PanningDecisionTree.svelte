<script>
    import { WASI } from "@runno/wasi";
    import { onMount } from "svelte";
    
    let exports;
    let zigRoot;
    let canvasRoot;

    async function run_wasm() {
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
        zigRoot = exports.generateOptimizedDecisionTree()
    }

    const generateCanvasTree = (zigNode, depth) => {
        const playerSpecies = fetchString(exports.memory, exports.getPlayerSpecies(zigNode, 0));
        const enemySpecies = fetchString(exports.memory, exports.getEnemySpecies(zigNode, 0));

        var currCanvasNode = new CanvasNode(
            zigNode,
            0,
            0,
            playerSpecies,
            enemySpecies,
            depth
        );

        const numOfNextTurns = exports.getNumOfNextTurns(zigNode);

        for (let i = 0; i < numOfNextTurns; i++) {
            const nextNode = exports.getNextNode(zigNode, i);
            if (nextNode != 0) { // 0 pointers are null decision nodes
                const childCanvasNode = generateCanvasTree(nextNode, depth + 1);
                currCanvasNode.addChild(childCanvasNode);
            }
        }

        return currCanvasNode;
    }

    function fetchString(memory, strLength) {
        const outputView = new Uint8Array(memory.buffer, 0, strLength);
        return new TextDecoder().decode(outputView);
    }


    let canvas;
    let ctx;

    let isPanning = false;
    let startX, startY;
    let offsetX = 0, offsetY = 0;
    let scale = 1;
    let lastScale = 1;

    const canvasWidth = "800";
    const canvasLength = "1500";
    const topPadding = 50;
    const sidePadding = 25;
    const nodeWidth = 50;
    const nodeHeight = 50;

    class CanvasNode {
        constructor(decisionNode, x, y, playerSpecies, enemySpecies, depth) {
            this.decisionNode = decisionNode;
            this.data = {
                'playerSpecies': playerSpecies,
                'enemySpecies': enemySpecies,
            }
            this.x = x;
            this.y = y;
            this.children = [];
            this.parent = null;
            this.depth = depth;
        }

        addChild(decisionNode) {
            decisionNode.depth = this.depth + 1;
            this.children.push(decisionNode);
            decisionNode.parent = this;
        }

        draw(sibilingIndex, numOfSiblings) {
            console.log(sibilingIndex, numOfSiblings);
            const trueWidth = canvasWidth - (sidePadding * 2)
            var topLeftX = sidePadding + Math.floor(trueWidth / numOfSiblings) * (sibilingIndex - 1);
            if (numOfSiblings == 0) {
                topLeftX = sidePadding + Math.floor(trueWidth / 2) * (sibilingIndex - 1)
            }
            const topLeftY = topPadding + (this.depth * 50) + (this.depth * 10);
            console.log(topLeftX, topLeftY);
            ctx.fillRect(topLeftX, topLeftY, nodeWidth, nodeHeight);
            const childrenLength = this.children.length;
            for (let i = 0; i < childrenLength; i++) {
                this.children[i].draw(i, childrenLength);
            }
        }
    }

    const drawCanvas = () => {
        canvasRoot = generateCanvasTree(zigRoot, 0);
        ctx.clearRect(0, 0, canvasWidth, canvasLength);
        ctx.save();
        ctx.translate(offsetX, offsetY);
        ctx.fillStyle = 'green';
        canvasRoot.draw(0, 0);
        ctx.restore();
    }

    const startPan = (e) => {
        isPanning = true;
        startX = e.clientX - offsetX;
        startY = e.clientY - offsetY;
    };

    const pan = (e) => {
        if (!isPanning) return;
        const deltaX = e.clientX - startX;
        const deltaY = e.clientY - startY;
        offsetX = deltaX;
        offsetY = deltaY;
        drawCanvas();
    };

    const endPan = () => {
        isPanning = false;
    };

    const zoom = (e) => {
        e.preventDefault();
        const zoomFactor = 0.1;
        const newScale = scale + (e.deltaY > 0 ? -zoomFactor : zoomFactor);
        if (newScale > 0.1 && newScale < 10) {
            scale = newScale;
            drawCanvas();
        }
    };

    onMount(async () => {
        ctx = canvas.getContext('2d');
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        await run_wasm();
    });
</script>

<style>
    canvas {
        border: 1px solid #ccc;
        cursor: grab;
    }
    canvas:active {
        cursor: grabbing;
    }
</style>

<div
    onmousedown={startPan}
    onmousemove={pan}
    onmouseup={endPan}
    onmouseleave={endPan}>
    <input type="button" value="Generate Tree" onclick={drawCanvas}/>
    <canvas
        bind:this={canvas}
        width={canvasWidth}
        height={canvasLength}
        onwheel={zoom}
        style="width: 100%; height: 100%; touch-action: none;"
    ></canvas>
</div>
