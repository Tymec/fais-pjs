import { BlockPermutation } from "@minecraft/server";

import Builder from "./builder.js";

export default class Structures {
    static buildCastle(x: number, y: number, z: number) {
        // build two towers
        let cobblestoneBlock = BlockPermutation.resolve("minecraft:cobblestone");
        Builder.tube(x, y, z, 5, 10, cobblestoneBlock);
        Builder.tube(x + 10, y, z, 5, 10, cobblestoneBlock);

        // build a moat
        let waterBlock = BlockPermutation.resolve("minecraft:water");
        Builder.torus(x + 5, y, z + 5, 5, 10, waterBlock);

        // build a bridge
        let plankBlock = BlockPermutation.resolve("minecraft:planks");
        Builder.fill(x + 5, y, z - 1, x + 5, 2, z + 1, plankBlock);
    }
}