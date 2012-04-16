#!/bin/sh
#
# Creates the download release
#
# christian.heinrich@cmlh.id.au
#
cd ..
tar -cvf ./Releases/$1.tar ./Local_Transforms/*.pl
tar -rvf ./Releases/$1.tar ./Entities/*.mtz
gzip ./Releases/$1.tar
cd Build
