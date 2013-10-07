#!/bin/bash
rm -r out/*

squish --with-minify
cp -r ./resources out/resources
cp -r ./lib out/lib
cp -r ./config out/config
cp -r ./android out/android