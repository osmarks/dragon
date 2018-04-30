local st = "minecraft:stone"
local stbr = "minecraft:stonebrick"
local stbrsl = "minecraft:stone_slab:5"
local rs = "minecraft:redstone"
local rsbl = "minecraft:redstone_block"

local function block9(x)
    return {x, x, x, [5] = x, [6] = x, [7] = x, [9] = x, [10] = x, [11] = x}
end

return {
    [stbr] = {st, st, [5] = st, [6] = st, qty = 4},
    [stbrsl] = {stbr, stbr, stbr, qty = 6},
    [rsbl] = block9(rs)
}