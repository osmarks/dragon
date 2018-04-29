local root = "https://osmarks.ml/git/osmarks/dragon/raw/branch/master/"

local function download(name, file)
    local contents = http.get(root .. name).readAll()
    local f = fs.open(file, "w")
    f.write(contents)
    f.close()
end

local files = { "client.lua", "server.lua", "util.lua" }
for _, f in pairs(files) do
    download(f, f)
    print("Downloaded", f)
end

print "Files downloaded. Either client.lua or server.lua should be run on startup."
print "Opening config editor..."
shell.run "edit conf"
fs.move("conf.lua", "conf") -- edit is really stupid, so un-.lua file