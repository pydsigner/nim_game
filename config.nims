import ospaths

let
    path = thisDir()
    name = splitPath(path)[1]

# for GDB happiness
# switch("debuginfo")
# switch("linedir", "on")
switch("hints", "off")
switch("verbosity", "0")
switch("nimcache", ".nimcache")

task build, "build the example":
    mkDir("bin")
    switch("out", "bin" / name)
    setCommand("c", "main.nim")

task run, "run the example":
    switch("r")
    buildTask()




