<div>
    <h3>Player Box</h3>
    <div class="box-container">
        {#each $playerBox as pokemon}
            <img class="box-mon" src="sprites/gen1/{pokemon['species'].toLowerCase()}.PNG">
        {/each}
    </div>
</div>

<script>
    import { playerBox } from '../stores.js';
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
    }
</style>
