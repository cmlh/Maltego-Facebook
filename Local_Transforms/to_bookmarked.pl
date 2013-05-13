#!/usr/bin/env perl
#
# Please refer to the Plain Old Documentation (POD) at the end of this Perl Script for further information

use strict;
# use warnings;
use Data::Dumper;

# #CONFIGURATION Remove "#" for Smart::Comments
# use Smart::Comments;

my $VERSION = "0.0.1"; # May be required to upload script to CPAN i.e. http://www.cpan.org/scripts/submitting.html

# Command line arguments from Maltego
my $maltego_selected_entity_value = $ARGV[0];

# "###" is for Smart::Comments CPAN Module
### \$maltego_selected_entity_value is: $maltego_selected_entity_value;

my $maltego_additional_field_values = $ARGV[1];

# "###" is for Smart::Comments CPAN Module
### \$maltego_additional_field_values is: $maltego_additional_field_values;

my @maltego_additional_field_values =
  split( '#', $maltego_additional_field_values );

# TODO Refactor with sub split_maltego_additional_fields()
# TODO If UID field is empty, then extract UID from the "Profile URL" field
my $affilation_facebook_uid = $maltego_additional_field_values[3];

# Workaround for the "#attachments_internal=x" matelgo additional field
# REFACTOR @maltego_additional_field_values to a hash based on key"="value of each element
if ( $affilation_facebook_uid !~ m/uid=/ ) {
    $affilation_facebook_uid = $maltego_additional_field_values[4];
}

$affilation_facebook_uid =~ s/(uid=)//g;

print("<MaltegoMessage>\n");
print("<MaltegoTransformResponseMessage>\n");
print("\t<UIMessages>\n");
print(
"\t\t<UIMessage MessageType=\"Inform\">To Bookmarked Local Transform v$VERSION</UIMessage>\n"
);
print("\t</UIMessages>\n");

print("\t<Entities>\n");

# TODO Insert Date and Time
print("<Entity Type=\"maltego.Phrase\"><Value>Reviewed</Value></Entity>\n");

# TODO Return optional error Maltego Entity.
print("\t</Entities>\n");

# http://ctas.paterva.com/view/Specification#Message_Wrapper
print("</MaltegoTransformResponseMessage>\n");
print("</MaltegoMessage>\n");

=head1 NAME

to_bookmarked.pl - "To Bookmarked"

=head1 VERSION

This documentation refers "To Bookmarked" Alpha v$VERSION

=head1 CONFIGURATION

Set the value(s) marked as #CONFIGURATION above this POD
    
=head1 USAGE

to_reviewed.pl $maltego_selected_entity $maltego_additional_field_values

=head1 REQUIRED ARGUEMENTS
                
=head1 OPTIONAL ARGUEMENTS

=head1 DESCRIPTION

Returns the "Bookmarked" as a phrase (which can be subsequently modified with whatever) in Maltego as an alternative to Bookmarks.

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
