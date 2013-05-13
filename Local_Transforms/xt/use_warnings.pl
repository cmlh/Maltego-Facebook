#!/usr/bin/env perl
# The above shebang is for "perlbrew", otherwise use /usr/bin/perl or the file path quoted for "which perl"
#
# Please refer to the Plain Old Documentation (POD) at the end of this Perl Script for further information

use strict;

#use warnings;

# Not possible to define number of tests as it is defined by the number of *.pl files in ../Local_Transforms
use Test::More "no_plan";

# #CONFIGURATION Remove "#" for Smart::Comments
# use Smart::Comments;

my $VERSION = "0.0.1"; # May be required to upload script to CPAN i.e. http://www.cpan.org/scripts/submitting.html

my @pl_files;

@pl_files = <../*.pl>;

my $pl_file;

foreach $pl_file (@pl_files) {

    print $pl_file . "\n";
    open( PLFILE, $pl_file ) or die "Could not open $pl_file";
    my $line;
    my $result = "not ok";
    foreach $line (<PLFILE>) {
        if ( $line =~ "use warnings" ) {
            $result = "ok";
            ok( $line =~ "# use warnings", "use warnings" );
            diag("$line");
        }
    }
    if ( $result eq "not ok" ) {
        fail("use warnings");
    }
}

=head1 NAME

use_warnings.pl - "use warnings Test"

=head1 VERSION

This documentation refers "use warnings Test" Alpha v$VERSION

=head1 CONFIGURATION

Set the value(s) marked as #CONFIGURATION above this POD
    
=head1 USAGE

use_warnings.pl

=head1 REQUIRED ARGUEMENTS
                
=head1 OPTIONAL ARGUEMENTS

=head1 DESCRIPTION

Test to ensure that the use warnings comment is stated.

=head1 DEPENDENCIES

=head1 PREREQUISITES

=head1 COREQUISITES

=head1 INSTALLATION

=head1 OSNAMES

osx

=head1 SCRIPT CATEGORIES

Web

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

Please refer to the comments beginning with "TODO" in the Perl Code.

=head1 AUTHOR

Christian Heinrich

=head1 CONTACT INFORMATION

http://cmlh.id.au/contact

=head1 MAILING LIST

=head1 REPOSITORY

http://github.com/cmlh/Maltego-Facebook

=head1 FURTHER INFORMATION AND UPDATES

http://cmlh.id.au/tagged/maltego

=head1 LICENSE AND COPYRIGHT

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. 

Copyright 2012 Christian Heinrich


