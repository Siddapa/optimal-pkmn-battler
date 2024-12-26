<script>
    import { onMount } from "svelte";

    let canvas;
    let ctx;
    let isPanning = false;
    let startX, startY;
    let offsetX = 0, offsetY = 0;
    let scale = 1;
    let lastScale = 1;

    const draw = () => {
        if (ctx) {
            // Clear the canvas
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // Draw something, for example, a rectangle or any shape
            ctx.save();
            ctx.translate(offsetX, offsetY);
            ctx.fillStyle = 'skyblue';
            ctx.fillRect(50, 50, 200, 150); // Example shape
            ctx.restore();
        }
    };

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
        draw();
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
            draw();
        }
    };

    onMount(() => {
        ctx = canvas.getContext('2d');
        draw();
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
    on:mousedown={startPan}
    on:mousemove={pan}
    on:mouseup={endPan}
    on:mouseleave={endPan}>
    <canvas
        bind:this={canvas}
        width="800"
        height="1500"
        on:wheel={zoom}
        style="width: 100%; height: 100%; touch-action: none;"
    ></canvas>
</div>
