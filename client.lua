local util = require "util"
local conf = util.conf
local query = util.query

rednet.open(conf.modem)

if conf.introspection then
	conf.introspection = peripheral.call(conf.introspection, "getInventory")
end

local function split(str, sep)
	local t = {}
	for sub in str:gmatch("[^" .. sep .. "]+") do
		table.insert(t, sub)
	end
	
	return t
end

-- Attempts to interpret the first of a list of tokens as a number.
function tryNumber(tokens)
	local fst = table.remove(tokens, 1)
	local qty = tonumber(fst)

	if not qty then
		table.insert(tokens, 1, fst)
	end

	return qty
end

-- Help text
local help = [[
Welcome to the Dragon CLI.
Commands:
w [name] - withdraw all items whose names contain [name]
w [qty] [name] - withdraw [qty] items whose names contain [name]
c - Craft item, using the turtle's inventory as a grid (turtle.craft)
ac [item] - Atempt to craft item, using Dragon autocrafting. Takes an internal name.
d - Dump all items into storage
d [slot] - Dump items in [slot] into storage
r - Force connected storage server to reindex
help - Display this
This is an unstable version and does not support a GUI or multiple storage servers.]]

print "Dragon CLI"
while true do
	write "|> "
	local tokens = split(read(), " ")
	local cmd = table.remove(tokens, 1)
    
	if cmd == "w" then
		local qty = tryNumber(tokens)
		if not qty then
			qty = math.huge
		end
        
		local item = table.concat(tokens, " ")
		util.fetch(item, qty)
    elseif cmd == "c" then
		turtle.craft()
	elseif cmd == "d" then
		local slot = tryNumber(tokens)
		
		if slot then dump(slot) else
			local size = 16
			if conf.introspection then size = conf.introspection.size() end
			for i = 1, size do
				util.dump(i)
			end
		end
	elseif cmd == "r" then
		query { cmd = "reindex" }
	elseif cmd == "ac" then
		query { cmd = "craft", item = tokens[1] }
	elseif cmd == "help" then
		textutils.pagedPrint(help)
	end
end