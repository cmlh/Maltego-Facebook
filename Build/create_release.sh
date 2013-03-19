#!/bin/sh
#
# Creates the download release
#
# christian.heinrich@cmlh.id.au
#
git describe --long --abbrev=4 > git_blob.txt
cd ..
tar -cvf ./Releases/Maltego-Facebook-`git describe`.tar ./Local_Transforms/etc/*.conf ./Local_Transforms/*.pl ./Local_Transforms/Images/*
tar -rvf ./Releases/Maltego-Facebook-`git describe`.tar ./Entities/*.mtz
tar -rvf ./Releases/Maltego-Facebook-`git describe`.tar ./Build/git_blob.txt
gzip ./Releases/Maltego-Facebook-`git describe`.tar
cd Build
