#!/bin/sh
#
# Clones the wiki from GitHub
#
# christian.heinrich@cmlh.id.au
#
rm -rf ../Maltego-Facebook.wiki
cd ..
git clone git@github.com:cmlh/Maltego-Facebook.wiki
cd Build
