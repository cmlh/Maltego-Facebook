#!/bin/sh
#
# Creates the download release
#
# christian.heinrich@cmlh.id.au
#
cd ..
rm -rf ./Local_Transforms/Images/*
mkdir ./Local_Transforms/Images/Pictures
mkdir ./Local_Transforms/Images/Covers
tar -cvf ./Releases/Maltego-Facebook-$1.tar ./Local_Transforms/etc/*.conf ./Local_Transforms/*.pl ./Local_Transforms/Images/*
tar -rvf ./Releases/Maltego-Facebook-$1.tar ./Entities/*.mtz
gzip ./Releases/Maltego-Facebook-$1.tar
cd Build
