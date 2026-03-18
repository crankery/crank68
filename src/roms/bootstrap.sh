#!/bin/bash

if [ $1 == "clean" ]; then
    rm -rf tools
fi

# ensure the bin directory exists
if [ ! -d "tools" ]; then
    mkdir tools
fi

pushd tools

if [ -d "vasm.tar.gz" ]; then
    echo "vasm.tar.gz already exists, skipping download and build."
else
    # download and uncompress vasm
    wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz
    tar -xf vasm.tar.gz
    rm vasm.tar.gz

    # build vasm for 6800 with Motorola syntax
    pushd vasm
    make CPU=6800 SYNTAX=mot
    popd
fi

if [ -d "srec2bin" ]; then
    echo "srec2bin already exists, skipping clone and build."
else
    git clone git@github.com:rageworx/srec2bin.git
    pushd srec2bin
    make
    popd
fi 

# back to root
popd
