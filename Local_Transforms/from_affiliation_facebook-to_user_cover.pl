#!/usr/bin/env perl
# The above shebang is for "perlbrew", otherwise use /usr/bin/perl or the file path quoted for "which perl"
#
# Please refer to the Plain Old Documentation (POD) at the end of this Perl Script for further information

do 'facebook_graphapi.pl';

# Perl v5.8 is the minimum version required for 'use autodie'
# Perl v5.8.1 is the minimum version required for 'use utf8'
use 5.0080001;
use v5.8.1;

use strict;
use warnings qw(FATAL);
use diagnostics;

use JSON; # JSON v2.53
use HTTP::Tiny;	# HTTP::Tiny v0.024
use Data::Dumper;
use Digest::SHA;

# #CONFIGURATION Remove "#" for Smart::Comments
# use Smart::Comments;

my $VERSION = "0.0.11"; # May be required to upload script to CPAN i.e. http://www.cpan.org/scripts/submitting.html

# Command line arguments from Maltego
my $maltego_selected_entity_value = $ARGV[0];

# "###" is for Smart::Comments CPAN Module
### \$maltego_selected_entity_value is: $maltego_selected_entity_value;

my $maltego_additional_field_values = $ARGV[1];

# "###" is for Smart::Comments CPAN Module
### \$maltego_additional_field_values is: $maltego_additional_field_values;

my %maltego_additional_field_values =
  split_maltego_additional_fields($maltego_additional_field_values);
my $facebook_profileid = $maltego_additional_field_values{"uid"};

my $facebook_affiliation_name = $maltego_selected_entity_value;

# "###" is for Smart::Comments CPAN Module
### \$facebook_profileid is: $facebook_profileid;

my $facebook_graphapi_URL =
  "https://graph.facebook.com/$facebook_profileid?fields=cover";

# "###" is for Smart::Comments CPAN Module
### \$facebook_graphapi_URL is: $facebook_graphapi_URL;

# Create a new JSON request

# TODO Replace WWW::Mechanize with HTTP::Tiny CPAN Module
# TODO Replace WWW::Mechanize with libwhisker
# TODO Replace WWW::Mechanize with LWP::UserAgent
my $http_request = HTTP::Tiny->new;

# TODO Availability of $facebook_graphapi_URL i.e. is "up" and resulting HTTP Status Code
my $http_response = $http_request->get("$facebook_graphapi_URL");

# decode_json returns a reference to a hash
# TODO -debug flag as a command line argument
# open( DEBUG_LOG, ">>./json_debug_log.txt" );
# print DEBUG_LOG "# \$facebook_graphapi_URL\n\n";
# print DEBUG_LOG "$facebook_graphapi_URL\n\n";
# print DEBUG_LOG "# \http_request->get(\$facebook_graphapi_URL)->content\n\n";
# print DEBUG_LOG ( Data::Dumper::Dumper( decode_json($http_response) ) );
# close DEBUG_LOG;

print("<MaltegoMessage>\n");
print("<MaltegoTransformResponseMessage>\n");
print("\t<UIMessages>\n");
print(
"\t\t<UIMessage MessageType=\"Inform\">Facebook GraphAPI Profile Cover Image Local Transform v$VERSION</UIMessage>\n"
);

facebook_graphapi_down("$facebook_graphapi_URL")
  unless $http_response->{success};

my $http_response_ref = decode_json( $http_response->{content} )->{cover};
if ($http_response_ref) {

    my %http_response                 = %$http_response_ref;
    my $facebook_affiliation_filename = $facebook_affiliation_name;
    $facebook_affiliation_filename =~ s/\s//g;

    #TODO Refactor as sub() {}
    if ( -e "./Images/Covers/$facebook_affiliation_filename.jpg" ) {
        open COVER_JPG, "./Images/Covers/$facebook_affiliation_filename.jpg";
        my $sha = new Digest::SHA;
        $sha->addfile(*COVER_JPG);
        close COVER_JPG;
        my $hex = $sha->hexdigest();
        print(
"\t\t<UIMessage MessageType=\"Inform\">SHA of previous $facebook_affiliation_filename.jpg is $hex</UIMessage>\n"
        );
    }
    else {
        print
"\t\t<UIMessage MessageType=\"Inform\">./Images/Covers/$facebook_affiliation_filename.jpg does not exist</UIMessage>\n";
    }

    $http_request->mirror( $http_response{'source'},
        "./Images/Covers/$facebook_affiliation_name.jpg" );
    open COVER_JPG, "./Images/Covers/$facebook_affiliation_name.jpg";
    my $sha = new Digest::SHA;
    $sha->addfile(*COVER_JPG);
    close COVER_JPG;
    my $hex = $sha->hexdigest();
    print(
"\t\t<UIMessage MessageType=\"Inform\">SHA of recent $facebook_affiliation_filename.jpg is $hex</UIMessage>\n"
    );
    print("\t</UIMessages>\n");
    print("\t<Entities>\n");
    print("\t\t<Entity Type=\"maltego.image\"><Value>$hex</Value>\n");
    print("\t\t\t<AdditionalFields>\n");
    print(
        "\t\t\t\t<Field Name=\"fullimage\">$http_response{'source'}</Field>\n");
    print("\t\t\t</AdditionalFields>\n");
    print("\t\t\t<IconURL>$http_response{'source'}</IconURL>\n");
    print("\t\t</Entity>\n");
    print(
"\t\t<Entity Type=\"maltego.FacebookObject\"><Value>$http_response{'id'}</Value>\n"
    );
    print("\t\t\t<IconURL>$http_response{'source'}</IconURL>\n");
    print("\t\t</Entity>\n");
}
else {

    # REFACTOR as <UIMessages>
    print STDERR ("No Facebook Cover Photo for $facebook_profileid\n");
    print(
        "\t\t<Entity Type=\"maltego.image\"><Value>No Cover</Value></Entity>\n"
    );
}

# TODO Return optional error Maltego Entity.
print("\t</Entities>\n");

# http://ctas.paterva.com/view/Specification#Message_Wrapper
print("</MaltegoTransformResponseMessage>\n");
print("</MaltegoMessage>\n");

=head1 NAME

from_affliation_facebook-to_user_cover.pl - "To Facebook Profile Cover Image"

=head1 VERSION

This documentation refers "To Facebook Profile Cover Image" Alpha v$VERSION

=head1 CONFIGURATION

Set the value(s) marked as #CONFIGURATION above this POD
    
=head1 USAGE

from_affliation_facebook-to_facebook_profile_cover_image.pl $maltego_selected_entity $maltego_additional_field_values

=head1 REQUIRED ARGUEMENTS
                
=head1 OPTIONAL ARGUEMENTS

=head1 DESCRIPTION

Returns the Facebook Cover Image and its ID in Maltego via the Facebook GraphAPI

=head1 DEPENDENCIES

=head1 PREREQUISITES

JSON CPAN Module
WWW::Mechanize CPAN Module
Digest::SHA CPAN Module

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


