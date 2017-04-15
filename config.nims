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

task demo, "demo the library":
    mkDir("bin")
    switch("r")
    switch("out", "bin/demo")
    setCommand("c", "demo.nim")

task demo2, "demo the library":
    mkDir("bin")
    switch("r")
    switch("out", "bin/demo2")
    setCommand("c", "demo2.nim")

