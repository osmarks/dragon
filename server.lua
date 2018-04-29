local util = require "util"
local conf = util.conf

rednet.open(conf.modem)

local inventories = {}
for _, n in pairs(peripheral.getNames()) do
    local p = peripheral.wrap(n)
    if 
        string.find(n, "chest") or
        string.find(n, "shulker") then
        inventories[n] = p
    end
end

local nameCache = {}

function cache(item, chest, slot)
    local idx = item.name .. ":" .. item.damage
    
    if nameCache[idx] then
        return nameCache[idx]
    else
		local n = chest.getItemMeta(slot).displayName
        nameCache[idx] = n
		return n
    end
end

local index = {}
function updateIndexFor(name)
    local inv = inventories[name]
    local data = inv.list()
    
    for slot, item in pairs(data) do
        data[slot].displayName = cache(item, inv, slot)
    end
    
    index[name] = data
end

function updateIndex()
	for n in pairs(inventories) do
		updateIndexFor(n)
		sleep()
	end
	print "Indexing complete."
end

function find(predicate)
    for name, items in pairs(index) do
        for slot, item in pairs(items) do
            if predicate(item) then
                return name, slot, item
            end
        end
    end
end

function findSpace()
    for name, items in pairs(index) do
        if #items < inventories[name].size() then
            return name
        end
    end
end

function processRequest(msg)
    print(textutils.serialise(msg))

    if msg.cmd == "extract" then
        local inv, slot, item = find(function(item)
            return 
                (not msg.meta or item.damage == msg.meta) and
                (not msg.name or item.name == msg.name) and
                (not msg.dname or string.find(item.displayName:lower(), msg.dname:lower()))
        end)

		index[inv][slot] = nil

		local moved = peripheral.call(conf.bufferOutInternal, "pullItems", inv, slot, msg.qty or 64, 1)

		if msg.destInv then
			moved = peripheral.call(conf.bufferOutExternal, "pushItems", msg.destInv, 1)
		end

		return {moved, item}
	elseif msg.cmd == "insert" then
		if msg.fromInv and msg.fromSlot then
			peripheral.call(conf.bufferInExternal, "pullItems", msg.fromInv, msg.fromSlot, msg.qty or 64, 1)
		end

		local toInv = findSpace()
		if not toInv then return "ERROR" end
		
		peripheral.call(conf.bufferInInternal, "pushItems", toInv, 1)

		updateIndexFor(toInv) -- I don't know a good way to figure out where exactly the items went

		return "OK"
	elseif msg.cmd == "buffers" then
		return { conf.bufferInExternal, conf.bufferOutExternal }
	elseif msg.cmd == "reindex" then
		updateIndex()
		return "OK"
    elseif msg.cmd == "list" then
        return index
    elseif msg.cmd == "name" then
        msg.meta = msg.meta or 0
        return msg.name and msg.meta and nameCache[msg.name .. ":" .. msg.meta]
    end
end

function processRequests()
    while true do
        local id, msg = rednet.receive "dragon"
        if msg and msg.cmd then
            local ok, r = pcall(processRequest, msg)

			if not ok then r = "ERROR" end
			
            rednet.send(id, r, "dragon")
        end
    end
end

updateIndex()
processRequests()