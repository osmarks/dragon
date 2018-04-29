local f = fs.open("conf", "r")
local conf = textutils.unserialise(f.readAll())
f.close()

local function query(m)
	local msg
	repeat
    	rednet.broadcast(m, "dragon")
    	_, msg = rednet.receive("dragon", 1)
	until msg
	return msg
end

return { conf = conf, query = query }