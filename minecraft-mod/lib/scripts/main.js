import { world, system } from "@minecraft/server";
import Structures from "./structures.js";
const START_TICK = 100;
// global variables
let curTick = 0;
function mainTick() {
    try {
        curTick++;
        if (curTick === START_TICK) {
            const overworld = world.getDimension("overworld");
            const spawnLocation = world.getDefaultSpawnLocation();
            Structures.buildCastle(spawnLocation.x, spawnLocation.y, spawnLocation.z);
            overworld.playSound("mob.enderdragon.growl", spawnLocation);
            world.sendMessage("The castle has been built!");
        }
    }
    catch (e) {
        console.warn("Tick error: " + e);
    }
    system.run(mainTick);
}
system.run(mainTick);
//# sourceMappingURL=main.js.map