#!/bin/sh
#
# Creates the download release
#
# christian.heinrich@cmlh.id.au
#
git describe --all --abbrev=4 HEAD^ > version.txt
cd ..
tar -cvf ./Releases/Maltego-Facebook-`git describe`.tar ./Local_Transforms/etc/*.conf ./Local_Transforms/*.pl ./Local_Transforms/Images/*
tar -rvf ./Releases/Maltego-Facebook-`git describe`.tar ./Entities/*.mtz
tar -rvf ./Releases/Maltego-Facebook-`git describe`.tar ./Build/version.txt
gzip ./Releases/Maltego-Facebook-`git describe`.tar
cd Build
