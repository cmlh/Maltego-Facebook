#!/bin/sh
#
# This is a workaround until I convert this to TAP
#
# christian.heinrich@cmlh.id.au
# 
cd ..
# No Cover Image
./from_affiliation_facebook-to_user_cover.pl "Christian Heinrich" "person.name=Christian Heinrich#network=Facebook#uid=100002552265389#profile_url=http://www.facebook.com/cmlh.id.au"
# With Cover Image
./from_affiliation_facebook-to_user_cover.pl "Dhillon Kannabhiran" "person.name=Dhillon Kannabhiran#network=facebook#uid=547636255#profile_url=http://www.facebook.com/profile.php?id\\=547636255#icon-url=http://profile.ak.fbcdn.net/hprofile-ak-ash4/260979_547636255_1707259828_n.jpg"
