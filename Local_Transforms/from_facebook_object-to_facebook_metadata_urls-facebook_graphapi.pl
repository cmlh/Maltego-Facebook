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
# use Smart::Comments;

my $VERSION = "0.0.5"; # May be required to upload script to CPAN i.e. http://www.cpan.org/scripts/submitting.html

# Command line arguments from Maltego
my $maltego_selected_entity_value = $ARGV[0];

# "###" is for Smart::Comments CPAN Module
### \$maltego_selected_entity_value is: $maltego_selected_entity_value;

my $maltego_additional_field_values = $ARGV[1];

# "###" is for Smart::Comments CPAN Module
### \$maltego_additional_field_values is: $maltego_additional_field_values;

my @maltego_additional_field_values =
  split( '#', $maltego_additional_field_values );

my $facebook_object_id = $maltego_selected_entity_value;

# CONFIGURATION
# REFACTOR with "easydialogs" e.g. http://www.paterva.com/forum//index.php/topic,134.0.html as recommended by Andrew from Paterva
read_config './etc/facebook_graphapi.conf' => my %config;
my $facebook_graphapi_access_token = $config{'GraphAPI'}{'access_token'};

my $facebook_graphapi_URL =
  "https://graph.facebook.com/$facebook_object_id?metadata=1&access_token=$facebook_graphapi_access_token";

# "###" is for Smart::Comments CPAN Module
### \$facebook_graphapi_URL is: $facebook_graphapi_URL;

# Create a new JSON request

# TODO Replace HTTP::Tiny with WWW::Mechanize CPAN Module
# TODO Replace HTTP::Tiny with libwhisker
# TODO Replace HTTP::Tiny with LWP::UserAgent
my $http_request = HTTP::Tiny->new;

# TODO Availability of $facebook_graphapi_URL i.e. is "up" and resulting HTTP Status Code
my $http_response = $http_request->get("$facebook_graphapi_URL");

# decode_json returns a reference to a hash
# TODO -debug flag as a command line argument
open( DEBUG_LOG, ">>./json_debug_log.txt" );
print DEBUG_LOG "# \$facebook_graphapi_URL\n\n";
print DEBUG_LOG "$facebook_graphapi_URL\n\n";
print DEBUG_LOG "# \http_request->get(\$facebook_graphapi_URL)\n\n";
print DEBUG_LOG (
    Data::Dumper::Dumper( decode_json( $http_response->{content} ) ) );
close DEBUG_LOG;

print("<MaltegoMessage>\n");
print("<MaltegoTransformResponseMessage>\n");
print("\t<UIMessages>\n");
print(
"\t\t<UIMessage MessageType=\"Inform\">Facebook GraphAPI FBID Metadata URL v$VERSION</UIMessage>\n"
);
print("\t</UIMessages>\n");
print("\t<Entities>\n");
my $http_response_ref = decode_json( $http_response->{content} );

if ($http_response_ref) {
    my %http_response = %$http_response_ref;

    # QA
    print(
"\t\t<Entity Type=\"maltego.Phrase\"><Value>$http_response{'metadata'}->{'type'}</Value></Entity>\n"
    );

# ISSUE $http_response{'type'} has moved to $http_response{'metadata'}->{'type'}
    if ( $http_response{'metadata'}->{'type'} eq "event" ) {

        # TODO Return the 'Name' of the event rather than the FBID
        # TODO Return the 'id' of the event as an Additional <Field>
        print(
"\t\t<Entity Type=\"cmlh.facebook.event\"><Value>$http_response{'name'}</Value>\n"
        );
        print("\t\t\t<AdditionalFields>\n");
        print(
            "\t\t\t\t<Field Name=\"event.id\">$http_response{'id'}</Field>\n");
        print(
"\t\t\t\t<Field Name=\"facebook.object\">$http_response{'id'}</Field>\n"
        );
        print("\t\t\t</AdditionalFields>\n");
        print("\t\t</Entity>\n");
    }
    if ( $http_response{'metadata'}->{'type'} eq "group" ) {

        # TODO Return the 'Name' of the event rather than the FBID
        # TODO Return the 'id' of the event as an Additional <Field>
        print(
"\t\t<Entity Type=\"cmlh.facebook.group\"><Value>$http_response{'name'}</Value>\n"
        );
        print("\t\t\t<AdditionalFields>\n");
        print(
            "\t\t\t\t<Field Name=\"group.id\">$http_response{'id'}</Field>\n");
        print(
"\t\t\t\t<Field Name=\"facebook.object\">$http_response{'id'}</Field>\n"
        );
        print("\t\t\t</AdditionalFields>\n");
        print("\t\t</Entity>\n");
    }

    print(
"\t\t<Entity Type=\"maltego.FacebookObject\"><Value>$http_response{'id'}</Value></Entity>\n"
    );
    my $connection_URL_ref = $http_response{'metadata'}->{connections};
    my %connection_URL     = %$connection_URL_ref;
    foreach my $URL ( keys %connection_URL ) {
        print("\t\t<Entity Type=\"maltego.URL\"><Value>$URL</Value>\n");
        print("\t\t\t<AdditionalFields>\n");
        print("\t\t\t\t<Field Name=\"url\">$connection_URL{$URL}</Field>\n");

        # "###" is for Smart::Comments CPAN Module
        ### \$URL is: $URL;
        print("\t\t\t\t<Field Name=\"title\">$URL</Field>\n");
        print("\t\t\t</AdditionalFields>\n");
        print("\t\t</Entity>\n");
    }
}
else {

    # REFACTOR as <UIMessages>
    print STDERR ("No Metadata for $facebook_object_id\n");
}

# TODO Return optional error Maltego Entity.
print("\t</Entities>\n");

# http://ctas.paterva.com/view/Specification#Message_Wrapper
print("</MaltegoTransformResponseMessage>\n");
print("</MaltegoMessage>\n");

=head1 NAME

from_facebook_object-to_graphapi_metadata_urls.pl - "To Facebook Metadata URLs"

=head1 VERSION

This documentation refers "To Facebook Metadata URLs" Alpha v$VERSION

=head1 CONFIGURATION

Set the value(s) marked as #CONFIGURATION above this POD
    
=head1 USAGE

from_facebook_object-to_facebook_metadata_urls.pl $maltego_selected_entity $maltego_additional_field_values

=head1 REQUIRED ARGUEMENTS
                
=head1 OPTIONAL ARGUEMENTS

=head1 DESCRIPTION

Returns the Connections of a Facebook Object in Maltego
Refer to "Introspection" of http://developers.facebook.com/docs/reference/api/

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
