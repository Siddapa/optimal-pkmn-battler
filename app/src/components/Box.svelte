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
        alert(i);
    }
</script>

<style>
    .box-container {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        grid-template-rows: fit-content(100%);
        grid-row-gap: 1em;
        overflow-x: hidden;
        height: 30em;
        width: 20em;
        background-image: url("backgrounds/beach.png");
        background-size: cover;
        border: 2px solid white;
    }

    .box-mon {
        mix-blend-mode: multiply;
        background-color: red;
    }
</style>
