local f = fs.open("conf", "r")
local conf = textutils.unserialise(f.readAll())
f.close()

local errors = {
	matches = function(error, etyp)
		return error and error[1] == etyp
	end,
	error = function(etyp, ...)
		local ret = {etyp}
		for _, arg in pairs({...}) do
			table.insert(ret, arg)
		end
		return ret
	end,
	missingItems = "EITEMS",
	noSpace = "ESPACE",
	noPattern = "EPATTERN",
	
}

-- Queries Dragon servers. In a loop.
local function query(m)
	local uid = math.random(0, 1000000000)
	m.uid = uid
	local resp
	repeat
    	rednet.broadcast(m, "dragon")
    	_, resp = rednet.receive("dragon", 1)
	until resp and resp.msg and resp.uid == uid
	return resp.msg
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
local function split(str, sSeparator, nMax, bRegexp)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)
 
	local aRecord = {}
 
	if str:len() > 0 then
	   local bPlain = not bRegexp
	   nMax = nMax or -1
 
	   local nField, nStart = 1, 1
	   local nFirst,nLast = str:find(sSeparator, nStart, bPlain)
	   while nFirst and nMax ~= 0 do
		  aRecord[nField] = str:sub(nStart, nFirst-1)
		  nField = nField+1
		  nStart = nLast+1
		  nFirst,nLast = str:find(sSeparator, nStart, bPlain)
		  nMax = nMax-1
	   end
	   aRecord[nField] = str:sub(nStart)
	end
 
	return aRecord
 end

local function processMessage(f)
	local id, msg = rednet.receive "dragon"
	if msg and msg.uid then
		local r = f(msg)
		rednet.send(id, { uid = msg.uid, msg = r }, "dragon")
	end
end

return { conf = conf, query = query, fetch = fetch, dump = dump, collate = collate, satisfied = satisfied, split = split, processMessage = processMessage }