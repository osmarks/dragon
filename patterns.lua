local st = "minecraft:stone"
local stbr = "minecraft:stonebrick"
local stbrsl = "minecraft:stone_slab:5"

return {
    [stbr] = {st, st, [4] = st, [5] = st, qty = 4},
    [stbrsl] = {stbr, stbr, stbr, qty = 6}
}