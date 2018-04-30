local f = fs.open("conf", "r")
local conf = textutils.unserialise(f.readAll())
f.close()

-- Queries Dragon servers. In a loop.
local function query(m)
	local msg
	repeat
    	rednet.broadcast(m, "dragon")
    	_, msg = rednet.receive("dragon", 1)
	until msg
	return msg
end

-- Fetches an item with the given display name in the given quantity.
local function fetch(item, toGet)
	local result
	repeat
		local toGetNow = 64
		if toGet < 64 then toGetNow = toGet end

		result = query { cmd = "extract", dname = item, destInv = conf.name, qty = toGetNow }
		if result and type(result) == "table" and result[1] then
			toGet = toGet - result[1]
		end

		if conf.introspection then
			conf.introspection.pullItems(conf.name, 1)
		end
	until toGet <= 0 or result == "ERROR"
end

-- Dumps an inventory slot into storage
function dump(slot)
	if conf.introspection then
		conf.introspection.pushItems(conf.name, slot)
		slot = 1
	end
	query { cmd = "insert", fromInv = conf.name, fromSlot = slot }
end

-- Converts a table of the form {"x", "x", "y"} into {x = 2, y = 1}
local function collate(items)
    local ret = {}
    for _, i in pairs(items) do
        ret[i] = (ret[i] or 0) + 1
    end
    return ret
end

-- Checks whether "needs"'s (a collate-formatted table) values are all greater than those of "has"
local function satisfied(needs, has)
    local good = true
    for k, qty in pairs(needs) do
        if qty > (has[k] or 0) then good = false end
    end
    return good
end

-- Python-style version from http://lua-users.org/wiki/SplitJoin
-- Why is this not in the standard Lua library?!
local function split(sSeparator, nMax, bRegexp)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)
 
	local aRecord = {}
 
	if self:len() > 0 then
	   local bPlain = not bRegexp
	   nMax = nMax or -1
 
	   local nField, nStart = 1, 1
	   local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
	   while nFirst and nMax ~= 0 do
		  aRecord[nField] = self:sub(nStart, nFirst-1)
		  nField = nField+1
		  nStart = nLast+1
		  nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		  nMax = nMax-1
	   end
	   aRecord[nField] = self:sub(nStart)
	end
 
	return aRecord
 end

return { conf = conf, query = query, fetch = fetch, dump = dump, collate = collate, satisfied = satisfied, split = split }