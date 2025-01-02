<div>
    <h3>Box</h3>
    <div class="box-container">
        <img class="box-mon" src="sprites/gen1/mew.PNG" alt="Empty Image">
    </div>
</div>

<style>
    .box-container {
        display: grid;
        grid-template-columns: auto auto auto auto auto auto;
        overflow-y: auto;
        overflow-x: hidden;
        height: 300px;
        width: 500px;
        background-image: url("backgrounds/beach.png");
        background-size: cover;
        border: 3px solid white;
        grid-row-gap: 10px;
        grid-column-gap: 10px;
        padding: 5px;
    }

    .box-mon {
        mix-blend-mode: multiply;
    }
</style>
