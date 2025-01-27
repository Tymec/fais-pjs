import { world } from "@minecraft/server";
export default class Builder {
    static fill(x, y, z, width, height, depth, block) {
        var _a;
        const overworld = world.getDimension("overworld");
        for (let i = x; i < x + width; i++) {
            for (let j = y; j < y + height; j++) {
                for (let k = z; k < z + depth; k++) {
                    (_a = overworld.getBlock({ x: i, y: j, z: k })) === null || _a === void 0 ? void 0 : _a.setPermutation(block);
                }
            }
        }
    }
    static tube(x, y, z, radius, height, block) {
        var _a;
        const overworld = world.getDimension("overworld");
        for (let i = x - radius; i <= x + radius; i++) {
            for (let j = y; j < y + height; j++) {
                for (let k = z - radius; k <= z + radius; k++) {
                    if (Math.sqrt(Math.pow(i - x, 2) + Math.pow(k - z, 2)) <= radius) {
                        (_a = overworld.getBlock({ x: i, y: j, z: k })) === null || _a === void 0 ? void 0 : _a.setPermutation(block);
                    }
                }
            }
        }
    }
    static torus(x, y, z, radius, tubeRadius, block) {
        var _a;
        const overworld = world.getDimension("overworld");
        for (let i = x - radius; i <= x + radius; i++) {
            for (let j = y - radius; j <= y + radius; j++) {
                for (let k = z - radius; k <= z + radius; k++) {
                    if (Math.sqrt(Math.pow(i - x, 2) + Math.pow(k - z, 2)) <= radius && Math.sqrt(Math.pow(i - x, 2) + Math.pow(j - y, 2) + Math.pow(k - z, 2)) >= tubeRadius) {
                        (_a = overworld.getBlock({ x: i, y: j, z: k })) === null || _a === void 0 ? void 0 : _a.setPermutation(block);
                    }
                }
            }
        }
    }
}
//# sourceMappingURL=builder.js.map