#!/usr/bin/env perl
# The above shebang is for "perlbrew", otherwise use /usr/bin/perl or the file path quoted for "which perl"
#
# Please refer to the Plain Old Documentation (POD) at the end of this Perl Script for further information

use strict;
use JSON;
use HTTP::Tiny;

# #CONFIGURATION Remove "#" for Smart::Comments
# use Smart::Comments;

my $VERSION = "0.0.3"; # May be required to upload script to CPAN i.e. http://www.cpan.org/scripts/submitting.html

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
my $facebook_user_id = $maltego_selected_entity_value;

print("<MaltegoMessage>\n");
print("<MaltegoTransformResponseMessage>\n");
print("\t<UIMessages>\n");
print(
"\t\t<UIMessage MessageType=\"Inform\">Facebook GraphAPI Profile Cover Image Local Transform v$VERSION</UIMessage>\n"
);

my $facebook_graphapi_URL = "http://graph.facebook.com/$facebook_user_id";

# Create a new JSON request

my $http_request = HTTP::Tiny->new;

# TODO Availability of $facebook_graphapi_URL i.e. is "up" and resulting HTTP Status Code
my $http_response = $http_request->get("$facebook_graphapi_URL");

my $http_response_ref = decode_json( $http_response->{content} );
if ($http_response_ref) {
    my %http_response = %$http_response_ref;
    if ($http_response{error}) {
    	print(
		"\t\t<UIMessage MessageType=\"PartialError\">\"$facebook_user_id\" User ID does not exist</UIMessage>\n"
		);
		print ("</UIMessages>\n");   	
    	print("\t<Entities>\n");
	} else {
		print ("</UIMessages>\n");
		print("\t<Entities>\n");


   		print(
		"\t\t<Entity Type=\"maltego.FacebookObject\"><Value>$http_response{'id'}</Value></Entity>\n"
 		);
    	print(
		"\t\t<Entity Type=\"maltego.affiliation.Facebook\"><Value>$http_response{'name'}</Value>\n"
 	    );
 	    print("\t\t\t<AdditionalFields>\n");

	    # ISSUE "affiliation.network" is by Default a "Read Only" field in Maltego.
    	print("\t\t\t\t<Field Name=\"affiliation.network\">Facebook</Field>\n");
    	print(
       	 "\t\t\t\t<Field Name=\"affiliation.uid\">$http_response{'id'}</Field>\n"
    	);
    	print(
		"\t\t\t\t<Field Name=\"affiliation.profile-url\">http://www.facebook.com/profile.php?id=$http_response{'id'}</Field>\n"
   	 	);
    	print("\t\t\t</AdditionalFields>\n");
    	print("\t\t</Entity>\n");
	}
}
else {

    # REFACTOR as <UIMessages>
    print STDERR ("$facebook_user_id is not a Facebook User\n");
}

# TODO Return optional error Maltego Entity.
print("\t</Entities>\n");

# http://ctas.paterva.com/view/Specification#Message_Wrapper
print("</MaltegoTransformResponseMessage>\n");
print("</MaltegoMessage>\n");

=head1 NAME

from_user_id-to_affliation_facebook.pl - "From Facebook User ID To Facebook Affiliation"

=head1 VERSION

This documentation refers "From Facebook User ID To Facebook Affiliation" Alpha v$VERSION

=head1 CONFIGURATION

Set the value(s) marked as #CONFIGURATION above this POD
    
=head1 USAGE

from_user_id-to_affliation_facebook.pl $maltego_selected_entity $maltego_additional_field_values

=head1 REQUIRED ARGUEMENTS
                
=head1 OPTIONAL ARGUEMENTS

=head1 DESCRIPTION

Returns the Facebook Affiliation Entity based on the provided (User) ID of GraphAPI in Maltego

=head1 DEPENDENCIES

=head1 PREREQUISITES

JSON CPAN Module
HTTP::Tiny CPAN Module

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
