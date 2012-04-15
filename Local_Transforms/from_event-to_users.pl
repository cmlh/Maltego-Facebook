#!/usr/bin/env perl
# The above shebang is for "perlbrew", otherwise use /usr/bin/perl or the file path quoted for "which perl"
#
# Please refer to the Plain Old Documentation (POD) at the end of this Perl Script for further information

use strict;
use JSON;
use HTTP::Tiny;
use Data::Dumper;
use Config::Std;

# #CONFIGURATION Remove "#" for Smart::Comments
use Smart::Comments;

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

# TODO The FBID will be an Additional <Field> and 'name' will be the $maltego_selected_entity_value once the "To Facebook Metadata URLs" Local Transform is refactored
my $facebook_event_id = $maltego_additional_field_values[2];
$facebook_event_id =~ s/(event.id=)//g;


# CONFIGURATION
# REFACTOR with "easydialogs" e.g. http://www.paterva.com/forum//index.php/topic,134.0.html as recommended by Andrew from Paterva
read_config './etc/facebook_graphapi.conf' => my %config;
my $facebook_graphapi_access_token = $config{'GraphAPI'}{'access_token'};

my @facebook_graphapi_event_connections =
  ( "invited", "attending", "maybe", "declined" );

my $http_request = HTTP::Tiny->new;

# Create a new JSON request

# TODO Replace HTTP::Tiny with WWW::Mechanize CPAN Module
# TODO Replace HTTP::Tiny with libwhisker
# TODO Replace HTTP::Tiny with LWP::UserAgent

my @facebook_user_fbids;
my @facebook_user_name;

foreach (@facebook_graphapi_event_connections) {

    my $facebook_graphapi_event_connection = $_;

    my $facebook_graphapi_URL =
"https://graph.facebook.com/$facebook_event_id/$facebook_graphapi_event_connection?access_token=$facebook_graphapi_access_token";

    # "###" is for Smart::Comments CPAN Module
    ### \$facebook_graphapi_URL is: $facebook_graphapi_URL;

	# TODO Availability of $facebook_graphapi_URL i.e. is "up" and resulting HTTP Status Code
    my $http_response = $http_request->get("$facebook_graphapi_URL");

    # TODO Exit if OAuth Token i.e. $facebook_graphapi_access_token, is invalid

    # decode_json returns a reference to a hash
    # TODO -debug flag as a command line argument
    open( DEBUG_LOG, ">>./json_debug_log.txt" );
    print DEBUG_LOG "# \$facebook_graphapi_URL\n\n";
    print DEBUG_LOG "$facebook_graphapi_URL\n\n";
    print DEBUG_LOG "# \http_request->get(\$facebook_graphapi_URL)\n\n";
    print DEBUG_LOG (
        Data::Dumper::Dumper( decode_json( $http_response->{content} ) ) );
    close DEBUG_LOG;

    my $http_response_ref = decode_json( $http_response->{content} )->{data};

    my @http_response = @$http_response_ref;

    for my $href (@http_response) {
        for ( keys %$href ) {
        	# REFACTOR Replace Arrays with Array of Hashes
            push( @facebook_user_fbids, "$href->{'id'}" );
            push( @facebook_user_name,  "$href->{'name'}" );
        }
    }
    my $facebook_user_fbids_length = @facebook_user_fbids;
    my $facebook_user_name_length = @facebook_user_name;
    
    # "###" is for Smart::Comments CPAN Module
    ### Length of \@facebook_user_fbids is: $facebook_user_fbids_length;
    ### Length of \@facebook_user_name is: $facebook_user_name_length;
}

# The filename for EVENT can be changed once the "\/:*?<>|" characters are stripped from maltego_selected_entity_value
open EVENT, (">$facebook_event_id.csv");

my $facebook_user_name_element = 0;

foreach (@facebook_user_fbids) {
	print EVENT "$_,$facebook_user_name[$facebook_user_name_element]\n";
	$facebook_user_name_element++;
}
close EVENT;

print("<MaltegoMessage>\n");
print("<MaltegoTransformResponseMessage>\n");
print("\t<UIMessages>\n");
print(
"\t\t<UIMessage MessageType=\"Inform\">Facebook GraphAPI Event to User v$VERSION</UIMessage>\n"
);
print("\t</UIMessages>\n");
print("\t<Entities>\n");
$facebook_user_name_element = 0;

foreach (@facebook_user_fbids) {
    print(
        "\t\t<Entity Type=\"maltego.affiliation.Facebook\"><Value>$_</Value>\n"
    );
    print("\t\t\t<AdditionalFields>\n");
    print(
"\t\t\t\t<Field Name=\"person.name\"> $facebook_user_name[$facebook_user_name_element]</Field>\n"
    );
    $facebook_user_name_element++;
    print("\t\t\t\t<Field Name=\"affiliation.network\">Facebook</Field>\n");
    print("\t\t\t\t<Field Name=\"affiliation.uid\">$_</Field>\n");
    print("\t\t\t\t<Field Name=\"affiliation.profile-url\">$_</Field>\n");
    print("\t\t\t</AdditionalFields>\n");
    my $facebook_graphapi_user_picture_URL =
      "https://graph.facebook.com/$_/picture";
    print("\t\t\t<IconURL>$facebook_graphapi_user_picture_URL</IconURL>\n");
    print("\t\t</Entity>\n");
}
print("\t</Entities>\n");

# http://ctas.paterva.com/view/Specification#Message_Wrapper
print("</MaltegoTransformResponseMessage>\n");
print("</MaltegoMessage>\n");

=head1 NAME

from_event-to_users - "To Facebook Event Users"

=head1 VERSION

This documentation refers "To Facebook Event Users" Alpha v$VERSION

=head1 CONFIGURATION

Set the value(s) marked as #CONFIGURATION above this POD
    
=head1 USAGE

from_facebook_event-to_facebook_users.pl $maltego_selected_entity $maltego_additional_field_values

=head1 REQUIRED ARGUEMENTS
                
=head1 OPTIONAL ARGUEMENTS

=head1 DESCRIPTION

Returns the Facebook Users(s) of a Facebook Event in Maltego via the Facebook GraphAPI
Refer to http://developers.facebook.com/docs/reference/api/event/ for futher information.

=head1 DEPENDENCIES

=head1 PREREQUISITES

JSON CPAN Module
HTTP::Tiny CPAN Module
Smart::Comments CPAN Module

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


