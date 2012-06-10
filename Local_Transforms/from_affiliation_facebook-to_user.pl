#!/usr/bin/env perl
#
# Please refer to the Plain Old Documentation (POD) at the end of this Perl Script for further information

use strict;
use JSON;
use WWW::Mechanize;
use Data::Dumper;

# #CONFIGURATION Remove "#" for Smart::Comments
# use Smart::Comments;

my $VERSION = "0.0.2"; # May be required to upload script to CPAN i.e. http://www.cpan.org/scripts/submitting.html

# Command line arguments from Maltego
my $maltego_selected_entity_value = $ARGV[0];

# "###" is for Smart::Comments CPAN Module
### \$maltego_selected_entity_value is: $maltego_selected_entity_value;

my $maltego_additional_field_values = $ARGV[1];

# "###" is for Smart::Comments CPAN Module
### \$maltego_additional_field_values is: $maltego_additional_field_values;

my @maltego_additional_field_values =
  split( '#', $maltego_additional_field_values );

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
"\t\t<UIMessage MessageType=\"Inform\">Facebook GraphAPI Profile Cover Image Local Transform v$VERSION</UIMessage>\n"
);
print("\t</UIMessages>\n");

my $facebook_graphapi_URL =
  "https://graph.facebook.com/$affilation_facebook_uid";

# Create a new JSON request

# TODO Replace WWW::Mechanize with HTTP::Tiny CPAN Module
# TODO Replace WWW::Mechanize with libwhisker
# TODO Replace WWW::Mechanize with LWP::UserAgent
my $http_request = WWW::Mechanize->new;

# TODO Availability of $facebook_graphapi_URL i.e. is "up" and resulting HTTP Status Code
my $http_response = $http_request->get("$facebook_graphapi_URL")->content;

#$facebook_timeline_profile is 1 if uid contains non digit characters and 2 if it has $http_response->{cover}
my $facebook_timeline_profile = 0;

my $http_response_ref = decode_json($http_response)->{cover};
if ($http_response_ref) {
	$facebook_timeline_profile++;
}

# "###" is for Smart::Comments CPAN Module
### \$facebook_timeline_profile is: $facebook_timeline_profile;

print("\t<Entities>\n");

my $http_response_ref = decode_json($http_response);
if ($http_response_ref) {
    my %http_response = %$http_response_ref;
    print(
"\t\t<Entity Type=\"cmlh.facebook.user\"><Value>$http_response{'id'}</Value>\n"
    );
    print ("\t\t<AdditionalFields>\n");
    print("\t\t\t\t<Field Name=\"id\">$http_response{'id'}</Field>\n");
    print("\t\t\t\t<Field Name=\"name\">$http_response{'name'}</Field>\n");
    print("\t\t\t\t<Field Name=\"name.first\">$http_response{'first_name'}</Field>\n");
    print("\t\t\t\t<Field Name=\"name.middle\">$http_response{'middle_name'}</Field>\n");
    print("\t\t\t\t<Field Name=\"name.last\">$http_response{'last_name'}</Field>\n");
	print("\t\t\t\t<Field Name=\"gender\">$http_response{'gender'}</Field>\n");
	print("\t\t\t\t<Field Name=\"locale\">$http_response{'locale'}</Field>\n");
	
	# TODO E-mail (Maltego) Entity based on Username
	print("\t\t\t\t<Field Name=\"name.user\">$http_response{'username'}</Field>\n");
	print ("\t\t</AdditionalFields>\n");
	my $facebook_graphapi_user_picture_URL =
      "https://graph.facebook.com/$http_response{'id'}/picture";
	print("\t\t\t<IconURL>$facebook_graphapi_user_picture_URL</IconURL>\n");
	# Requires Access Token
	# print("\t\t\t\t<Field Name=\"link\">$http_response{'link'}</Field>\n");
	# third_party_id
	# updated_time
	# verified
	# video_upload_limits
	#
	# Connections API
	# friends - via connection 
	# mutualfriends - via connection
	# permissions - via connection
	# picture
	# subscribedto
	# subscribers
	print("\t\t</Entity>\n");
}
else {

    # REFACTOR as <UIMessages>
    print STDERR ("$affilation_facebook_uid is not a Facebook User\n");
}

# TODO Return optional error Maltego Entity.
print("\t</Entities>\n");

# http://ctas.paterva.com/view/Specification#Message_Wrapper
print("</MaltegoTransformResponseMessage>\n");
print("</MaltegoMessage>\n");

=head1 NAME

from_affiliation_facebook-to_cover_image.pl - "To Facebook Profile Cover Image"

=head1 VERSION

This documentation refers "To Facebook Profile Cover Image" Alpha v$VERSION

=head1 CONFIGURATION

Set the value(s) marked as #CONFIGURATION above this POD
    
=head1 USAGE

from_affiliation_facebook-to_facebook_profile_cover_image.pl $maltego_selected_entity $maltego_additional_field_values

=head1 REQUIRED ARGUEMENTS
                
=head1 OPTIONAL ARGUEMENTS

=head1 DESCRIPTION

Returns the Facebook Cover Image and its FBID in Maltego via the Facebook GraphAPI

=head1 DEPENDENCIES

=head1 PREREQUISITES

JSON CPAN Module
WWW::Mechanize CPAN Module

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