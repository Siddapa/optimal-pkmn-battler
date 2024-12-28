<script>
    import PanningDecisionTree from './PanningDecisionTree.svelte';

    const greet = async () => {
        const response = await fetch("gen1.wasm");
        const buffer = await response.arrayBuffer();
        const wasm_battler = WebAssembly.instantiate(buffer, {});
        console.log(response);
        console.log(wasm_battler);
        return wasm_battler.instance.exports.greet;
    };

    // var greet;
    // const request = new XMLHttpRequest();
    // request.open("GET", "gen1.wasm");
    // request.responseType = "arraybuffer";
    // request.send();

    // request.onload = () => {
    //     const bytes = request.response;
    //     console.log(bytes);
    //     WebAssembly.instantiate(bytes, {}).then((results) => {
    //         greet = results.instance.exports.greet;
    //     });
    // };
</script>


<main class="container">
    <div class="settings">
        <h3>Settings</h3>
        <h2>{greet()}</h2>
    </div>
    <div class="import">
        <h3>Hello</h3>
        <form method="POST">
            <input class="import-input" type="text" align="left">
            <br>
            <input value="Import Box" class="import-submit" type="submit">
        </form>
    </div>
    <div class="box" overflow-y=auto>
        <h3>Box</h3>
        <div class="box-container">
            <img class="box-mon" src="sprites/gen1/mew.PNG" alt="Empty Image">
        </div>
    </div>
    <div class="editor">
        <h3>Editor</h3>
        <div class="editor-inline">
            <h5>Type: </h5>
            <select max-height=10px>
                <option value="None">-</option>
                <option value="Normal">Normal</option>
                <option value="Fire">Fire</option>
                <option value="Water">Water</option>
                <option value="Electric">Electric</option>
                <option value="Grass">Grass</option>
                <option value="Ice">Ice</option>
                <option value="Fighting">Fighting</option>
                <option value="Poison">Poison</option>
                <option value="Ground">Ground</option>
                <option value="Flying">Fighting</option>
                <option value="Psychic">Psychic</option>
                <option value="Bug">Bug</option>
                <option value="Rock">Rock</option>
                <option value="Ghost">Ghost</option>
                <option value="Dragon">Dragon</option>
            </select>
            <select max-height=10px>
                <option value="None">-</option>
                <option value="Normal">Normal</option>
                <option value="Fire">Fire</option>
                <option value="Water">Water</option>
                <option value="Electric">Electric</option>
                <option value="Grass">Grass</option>
                <option value="Ice">Ice</option>
                <option value="Fighting">Fighting</option>
                <option value="Poison">Poison</option>
                <option value="Ground">Ground</option>
                <option value="Flying">Fighting</option>
                <option value="Psychic">Psychic</option>
                <option value="Bug">Bug</option>
                <option value="Rock">Rock</option>
                <option value="Ghost">Ghost</option>
                <option value="Dragon">Dragon</option>
            </select>
        </div>
    </div>
    <div class = "decision-tree">
        <h3>Decision Tree</h3>
        <PanningDecisionTree/>
    </div>
</main>


<style>
    .container {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        grid-template-rows: repeat(2, 1fr);
        grid-column-gap: 100px;
        grid-row-gap: 0px;
    }
    .container > div {
        min-width: 300px;
        min-height: 300px;
    }

    .settings {
        grid-area: 1 / 1 / 2 / 2;
    }
    .import {
        grid-area: 1 / 2 / 2 / 3;
    }
    .box {
        width: fit-content;
        grid-area: 2 / 1 / 3 / 2;
    }
    .editor {
        grid-area: 2 / 2 / 3 / 3;
    }
    .decision-tree {
        grid-area: 1 / 3 / 3 / 4;
    }

    .box-container {
        display: grid;
        grid-template-columns: auto auto auto auto auto auto;
        overflow-y: auto;
        overflow-x: hidden;
        height: 300px;
        width: 500px;
        background-image: url("backgrounds/beach.png");
        background-size: cover;
        border: 3px solid blue;
        grid-row-gap: 10px;
        grid-column-gap: 10px;
        padding: 5px;
    }

    canvas {
        box-sizing: border-box;
        width: 100%;
        height: 100%;
        user-select: none;
        touch-action: none;
        background-color: #ccc;
        overscroll-behavior: none;
        -webkit-user-select: none; /* disable selection/Copy of UIWebView */
        -webkit-touch-callout: none; /* disable the IOS popup when long-press on a link */
    }

    .editor-inline {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        width: fit-content;
        column-gap: 10px;
    }

    .box-mon {
        mix-blend-mode: multiply;
    }

    .import-input {
        width: 200px;
        height: 200px;
    }
</style>
