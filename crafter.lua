local _ = require "moses"
local util = require "util"
local conf = util.conf

rednet.open(conf.modem)

local patterns = loadfile "patterns.lua"()

local function descend(intermediateFn, terminalFn, i)
    local pattern = patterns[i]
    if pattern then
        intermediateFn(pattern)
        local pqty = pattern.qty -- Qty keys must be removed from the pattern for collation
        -- Otherwise, it shows up as a number stuck in the items needed table, which is bad.
        pattern.qty = nil
        local needs = util.collate(pattern)
        pattern.qty = pqty
        local has = {}
        for slot, item in pairs(pattern) do
            if util.satisfied(needs, has) then break end
            if patterns[item] then
                descend(intermediateFn, terminalFn, item)
                has[item] = (has[item] or 0) + (patterns[item].qty or 1)
            end
        end
    else
        terminalFn(i)
    end
end

local function cost(i)
    local items = {}
    descend(function() end, function(i) table.insert(items, i) end, i)
    return util.collate(items)
end

local function tasks(i)
    local t = {}
    descend(function(pat) table.insert(t, pat) end, function() end, i)
    return t
end

-- Splits "mod:item:meta" into {"mod:item", "meta"}
local function splitItemString(is)
    local parts = util.split(is, ":")
    return {parts[1] .. ":" .. parts[2], tonumber(parts[3]) or 0}
end

local function craftOne(pat)
    for slot, itemName in pairs(pat) do
        if slot ~= "qty" then
            local ispl = splitItemString(itemName)
            util.query { cmd = "extract", meta = ispl[2], name = ispl[1], destInv = conf.name, destSlot = slot, qty = 1 }
        end
    end
    turtle.craft()
    util.dump(16)
end

local function craft(i)
    turtle.select(16) -- so that crafting outputs go here

    local stored = util.query { cmd = "list" }
    local reqs = cost(i)

    if util.satisfied(reqs, stored) then
        local tsks = _.reverse(tasks(i)) -- tasks returns the highest level/most complex/most subtask-requring tasks first.
        for _, tsk in pairs(tsks) do
            craftOne(tsk)
        end
    else
        return "ERROR"
    end
end

while true do
    local id, msg = rednet.receive "dragon"
    if msg and msg.cmd and msg.cmd == "craft" and msg.item then
        craft(msg.item)
        rednet.send(id, "OK", "dragon")
    end
end