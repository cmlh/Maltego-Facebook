#!/bin/sh
#
# Reverts the perl shebang line, i.e. #!, to /usr/bin/env perl
#
# christian.heinrich@cmlh.id.au
#
find ../Local_Transforms/ -name \*.pl -exec perl -pi -e '$_ = "#!/usr/bin/env perl\n" if ($. == 1);' {} \; 
