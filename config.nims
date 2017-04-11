#import os
import ospaths

let
    path = thisDir()
    name = splitPath(path)[1]

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




