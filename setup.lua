local argv = {...}
local root = "https://osmarks.ml/git/osmarks/dragon/raw/branch/master/"

local function download(url, file)
    local contents = http.get(url).readAll()
    local f = fs.open(file, "w")
    f.write(contents)
    f.close()
end

local files = { "client.lua", "server.lua", "util.lua", "setup.lua", "crafter.lua", "patterns.lua" }
for _, f in pairs(files) do
    download(root .. f, f)
    print("Downloaded", f)
end

-- Download functional Lua library
download("https://raw.githubusercontent.com/Yonaba/Moses/master/moses_min.lua", "moses.lua")
print "Downloaded Moses library"

print "Files downloaded. Either client.lua or server.lua should be run on startup."

if argv[1] == "update" then os.reboot() end

print "Opening config editor..."
shell.run "edit conf"
pcall(fs.move, "conf.lua", "conf") -- edit is really stupid, so un-.lua output file

local ty
repeat
    print "Would you like this node set up as a server, crafter or client?"
    ty = read()
until ty == "server" or ty == "client" or ty == "crafter"

local f = fs.open("startup", "w")
f.write("shell.run '" .. ty .. "'")
f.close()

os.setComputerLabel "Dragon Node"

print "Done! Reboot or run startup."