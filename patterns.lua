local st = "minecraft:stone"
local stbr = "minecraft:stonebrick"
local stbrsl = "minecraft:stone_slab:5"
local rs = "minecraft:redstone"
local rsbl = "minecraft:redstone_block"
local ii = "minecraft:iron_ingot"
local iin = "minecraft:iron_nugget"
local gi = "minecraft:gold_ingot"
local gin = "minecraft:gold_nugget"
local papr = "minecraft:paper"
local cane = "minecraft:reeds"
local dmnd = "minecraft:diamond"
local stk = "minecraft:stick"

local cwir = "opencomputers:material:0"
local dchip = "opencomputers:material:29"
local transistor = "opencomputers:material:6"
local mchip1 = "opencomputers:material:7"
local mchip2 = "opencomputers:material:8"
local mchip3 = "opencomputers:material:9"

local function block9(x)
    return {x, x, x, [5] = x, [6] = x, [7] = x, [9] = x, [10] = x, [11] = x}
end

local function mchip(x)
    return {x, x, x, [5] = rs, [6] = transistor, [7] = rs, [9] = x, [10] = x, [11] = x }
end

return {
    [stbr] = {st, st, [5] = st, [6] = st, qty = 4},
    [stbrsl] = {stbr, stbr, stbr, qty = 6},
    [rsbl] = block9(rs),
    [iin] = {ii},
    [gin] = {gi},
    [papr] = {cane, cane, cane},
    [transistor] = {ii, ii, ii, [5] = gin, [6] = papr, [7] = gin, [10] = rs},
    [mchip1] = mchip(iin),
    [mchip2] = mchip(gin),
    [mchip3] = mchip(dchip),
    [cwir] = {stk, iin, stk},
    [dchip] = {cwir, dmnd}
}