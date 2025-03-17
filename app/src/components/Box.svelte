<div>
    <h3>Box</h3>
    <div class="box-container">
        {#each $mons as pokemon, i}
            <img 
                class="box-mon"
                id = {type + "-" + i}
                src="sprites/gen1/{pokemon['species'].toLowerCase()}.PNG"
                onclick={() => selection(type, i)}
            >
        {/each}
    </div>
</div>

<script>
    let {mons, type} = $props();

    function selection(type, i) {
        alert(index);
    }
</script>

<style>
    .box-container {
        display: grid;
        grid-template-columns: auto auto auto auto auto auto;
        overflow-y: auto;
        overflow-x: hidden;
        height: 300px;
        width: 200px;
        background-image: url("backgrounds/beach.png");
        background-size: cover;
        border: 2px solid white;
        grid-row-gap: 10px;
        grid-column-gap: 10px;
        padding: 5px;
    }

    .box-mon {
        mix-blend-mode: multiply;
        background-color: red;
    }
</style>
