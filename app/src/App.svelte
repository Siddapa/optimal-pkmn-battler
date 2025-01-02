<script src="main.js">
    import Settings            from './components/Settings.svelte';
    import Import              from './components/Import.svelte';
    import Box                 from './components/Box.svelte';
    import Editor              from './components/Editor.svelte';
    import PanningDecisionTree from './components/PanningDecisionTree.svelte';
</script>


<main class="container">
    <div class="settings">
        <Settings/>
    </div>
    <div class="import">
        <Import/>
    </div>
    <div class="box" overflow-y=auto>
        <Box/>
    </div>
    <div class="editor">
        <Editor/>
    </div>
    <div class = "decision-tree">
        <PanningDecisionTree/>
    </div>
</main>


<style>
    .container {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        grid-template-rows: repeat(2, 1fr);
        padding-top: 0px;
        padding-side: 0px;
        grid-column-gap: 10px;
        grid-row-gap: 0px;
    }

    .settings {
        height: fit-content;
        width: fit-content;
        grid-area: 1 / 1 / 2 / 2;
        border: 1px solid red;
    }
    .import {
        height: fit-content;
        width: fit-content;
        grid-area: 1 / 2 / 2 / 3;
        border: 1px solid red;
    }
    .box {
        height: fit-content;
        width: fit-content;
        grid-area: 2 / 1 / 3 / 2;
        border: 1px solid red;
    }
    .editor {
        height: fit-content;
        width: fit-content;
        grid-area: 2 / 2 / 3 / 3;
        border: 1px solid red;
    }
    .decision-tree {
        height: fit-content;
        width: fit-content;
        grid-area: 1 / 3 / 3 / 4;
        border: 1px solid red;
    }
</style>
