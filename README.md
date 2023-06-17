# 34249-SignalModulation

We are implementing Pam-2/4/8 in VHDL.

# Using OSVVM
mkdir sim
git submodule update --init --recursive

In Modelsim open sim folder
source ../OsvvmLibraries/Scripts/StartUp.tcl
build ../OsvvmLibrarires

To make a Modelsim project with all files use:
do ../tb/tranceiver/sim.do
!!Set project type to vhdl 2008!!