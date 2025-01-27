import { world, BlockPermutation } from "@minecraft/server";

export default class Builder {
    static fill(x: number, y: number, z: number, width: number, height: number, depth: number, block: BlockPermutation) {
        const overworld = world.getDimension("overworld");

        for (let i = x; i < x + width; i++) {
            for (let j = y; j < y + height; j++) {
                for (let k = z; k < z + depth; k++) {
                    overworld.getBlock({ x: i, y: j, z: k })?.setPermutation(block);
                }
            }
        }
    }

    static tube(x: number, y: number, z: number, radius: number, height: number, block: BlockPermutation) {
        const overworld = world.getDimension("overworld");

        for (let i = x - radius; i <= x + radius; i++) {
            for (let j = y; j < y + height; j++) {
                for (let k = z - radius; k <= z + radius; k++) {
                    if (Math.sqrt(Math.pow(i - x, 2) + Math.pow(k - z, 2)) <= radius) {
                        overworld.getBlock({ x: i, y: j, z: k })?.setPermutation(block);
                    }
                }
            }
        }
    }

    static torus(x: number, y: number, z: number, radius: number, tubeRadius: number, block: BlockPermutation) {
        const overworld = world.getDimension("overworld");

        for (let i = x - radius; i <= x + radius; i++) {
            for (let j = y - radius; j <= y + radius; j++) {
                for (let k = z - radius; k <= z + radius; k++) {
                    if (Math.sqrt(Math.pow(i - x, 2) + Math.pow(k - z, 2)) <= radius && Math.sqrt(Math.pow(i - x, 2) + Math.pow(j - y, 2) + Math.pow(k - z, 2)) >= tubeRadius) {
                        overworld.getBlock({ x: i, y: j, z: k })?.setPermutation(block);
                    }
                }
            }
        }
    }
}