--local util = require "util"
--local conf = util.conf

local patterns = loadfile("patterns.lua")()

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
    return items
end

local function tasks(i)
    local t = {}
    descend(function(pat) table.insert(t, pat) end, function() end, i)
    return t
end

local function craft(i)
    local stored = utils.query { cmd = "list" }
    local reqs = cost(i)

    if util.satisfied(reqs, stored) then
        -- do crafting stuff
    else
        return "ERROR"
    end
end

return { cost = cost, descend = descend, collate = collate, tasks = tasks }