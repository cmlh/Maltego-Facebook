#!/usr/bin/env perl
# The above shebang is for "perlbrew", otherwise use /usr/bin/perl or the file path quoted for "which perl"
#
# Please refer to the Plain Old Documentation (POD) at the end of this Perl Script for further information

## Perl v5.8 is the minimum version required for 'use autodie'
# Perl v5.8.1 is the minimum version required for 'use utf8'
use 5.0080001;
use v5.8.1;

use utf8;

# use lib '[Insert CPAN Module Path]';
use strict;
use warnings 'FATAL';
use diagnostics;

# TODO use autodie qw(:all);
use autodie;

use JSON; # JSON v2.53
use HTTP::Tiny;	# HTTP::Tiny v0.024
# use Data::Dumper;
use Digest::SHA;
use POSIX qw(strftime);

# #CONFIGURATION Remove "#" for Smart::Comments
# use Smart::Comments '###', '####', '#####';

# "#####" is for Smart::Comments CPAN Module
##### [<now>] Commenced

my $VERSION = "0.0_24"; # May be required to upload script to CPAN i.e. http://www.cpan.org/scripts/submitting.html

#TODO Refactor facebook_graphapi.pl as a module
do 'facebook_graphapi.pl';

# Command line arguments from Maltego
my $maltego_selected_entity_value = $ARGV[0];

# "####" is for Smart::Comments CPAN Module
#### \$maltego_selected_entity_value is: $maltego_selected_entity_value;

my $maltego_additional_field_values = $ARGV[1];

# "####" is for Smart::Comments CPAN Module
#### \$maltego_additional_field_values is: $maltego_additional_field_values;

my %maltego_additional_field_values =
  split_maltego_additional_fields($maltego_additional_field_values);
my $facebook_profileid = $maltego_additional_field_values{"uid"};
my $facebook_affiliation_name = $maltego_selected_entity_value;

is_facebook_profileid_empty($facebook_profileid, $facebook_affiliation_name, $VERSION);

# "###" is for Smart::Comments CPAN Module
### \$facebook_profileid is: $facebook_profileid;

my $facebook_graphapi_URL =
  "https://graph.facebook.com/$facebook_profileid?fields=cover";

# "###" is for Smart::Comments CPAN Module
### \$facebook_graphapi_URL is: $facebook_graphapi_URL;

# Create a new JSON request

my $http_request = HTTP::Tiny->new;
$http_request->agent('Mozilla/5.0');

my $http_response = $http_request->get("$facebook_graphapi_URL");

# decode_json returns a reference to a hash
# TODO -debug flag as a command line argument
# open( DEBUG_LOG, ">>./json_debug_log.txt" );
# print DEBUG_LOG "# \$facebook_graphapi_URL\n\n";
# print DEBUG_LOG "$facebook_graphapi_URL\n\n";
# print DEBUG_LOG "# \http_request->get(\$facebook_graphapi_URL)->content\n\n";
# print DEBUG_LOG ( Data::Dumper::Dumper( decode_json($http_response) ) );
# close DEBUG_LOG;

facebook_graphapi_down("$facebook_graphapi_URL", $VERSION)
  unless $http_response->{success};

print("<MaltegoMessage>\n");
print("<MaltegoTransformResponseMessage>\n");
print("\t<UIMessages>\n");

print(
"\t\t<UIMessage MessageType=\"Inform\">Facebook GraphAPI Profile Cover Image Local Transform v$VERSION</UIMessage>\n"
);



my $http_response_ref = decode_json( $http_response->{content} );
my %http_response                 = %$http_response_ref;

if (!( $http_response{'cover'}{'source'})) {
 	print ("\t\t<UIMessage MessageType=\"Inform\">No Cover Picture for $facebook_affiliation_name;</UIMessage>\n");
 	print("\t</UIMessages>\n");
 	print("\t<Entities>\n");
 	print("\t\t<Entity Type=\"maltego.Image\"><Value>No Cover</Value></Entity>\n");
} 

elsif ($http_response_ref) {

    my $facebook_affiliation_filename = $facebook_affiliation_name;
    $facebook_affiliation_filename =~ s/\s//g;

	# Value of $new_image is 1 if prior image does not exist in the /Images/ dir or SHA-1 hash is different
	my $new_image = "0";
	my $hex_previous;
    #TODO Refactor as sub()
    #TODO mkdir /Images/Covers if it does not exist
    if ( -e "./Images/Covers/$facebook_affiliation_filename.jpg" ) {
        open COVER_JPG, "./Images/Covers/$facebook_affiliation_filename.jpg";
        my $sha = new Digest::SHA;
        $sha->addfile(*COVER_JPG);
        close COVER_JPG;
        my $hex_previous = $sha->hexdigest();
        print("\t\t<UIMessage MessageType=\"Inform\">SHA of previous $facebook_affiliation_filename.jpg is $hex_previous</UIMessage>\n");
        unlink ("./Images/Covers/$facebook_affiliation_filename.jpg");
    }
    else {
        print
"\t\t<UIMessage MessageType=\"Inform\">./Images/Covers/$facebook_affiliation_filename.jpg does not exist</UIMessage>\n";
		$new_image = "1";
    }
	
    $http_request->mirror( $http_response{'cover'}{'source'},
        "./Images/Covers/$facebook_affiliation_filename.jpg" );
    open COVER_JPG, "./Images/Covers/$facebook_affiliation_filename.jpg";
    my $sha = new Digest::SHA;
    $sha->addfile(*COVER_JPG);
    close COVER_JPG;
    my $hex_recent = $sha->hexdigest();
   	# "###" is for Smart::Comments CPAN Module
	### \$hex_recent is: $hex_recent;
	### \$hex_current is: $hex_previous;
    if ($hex_previous eq $hex_recent) {
    	$new_image = "0";
		print ("\t\t<UIMessage MessageType=\"Inform\">Cover Image for $facebook_affiliation_name has not changed</UIMessage>\n");
    } 
    else {
    	 print ("\t\t<UIMessage MessageType=\"Inform\">Cover Image for $facebook_affiliation_name has been updated</UIMessage>\n");
	}
	# Refer to "man git-rev-parse" -short for length of four
	# Also, since the end user might not have the image on first execution it is not possible to generate the git hash as the blob is unknown.
	my $shortern_hash = substr($hex_recent, 0, 4);
	# "###" is for Smart::Comments CPAN Module
	### \$shortern_hash is: $shortern_hash;
    # print("\t\t<UIMessage MessageType=\"Inform\">SHA of recent $facebook_affiliation_filename.jpg is $hex</UIMessage>\n");
    print("\t</UIMessages>\n");
    print("\t<Entities>\n");
    if ($new_image eq "1") {
    	# "###" is for Smart::Comments CPAN Module
		### \$new_image is: $new_image;
    	print("\t\t<Entity Type=\"maltego.image\"><Value>Cover - $shortern_hash</Value>\n");
    	print("\t\t\t<AdditionalFields>\n");
    	print(
        	"\t\t\t\t<Field Name=\"fullimage\">$http_response{'source'}</Field>\n");
        	my $date = strftime("%d %b %Y at %H:%M:%S", localtime(time));
        	print("\t\t\t\t<Field Name=\'notes#\'>Discovered on $date</Field>\n");
    	print("\t\t\t</AdditionalFields>\n");
    	print("\t\t\t\t<IconURL>$http_response{'source'}</IconURL>\n");
    	print("\t\t</Entity>\n");
	    print(
			"\t\t<Entity Type=\"maltego.FacebookObject\"><Value>Cover - $shortern_hash</Value>\n"
    	);
    	print("\t\t\t<AdditionalFields>\n");
    	print(
        	"\t\t\t\t<Field Name=\"fullimage\">$http_response{'source'}</Field>\n");
        	my $date = strftime("%d %b %Y at %H:%M:%S", localtime(time));
        	print("\t\t\t\t<Field Name=\'notes#\'>Discovered on $date</Field>\n");
    	print("\t\t\t</AdditionalFields>\n");
   		print("\t\t\t<IconURL>$http_response{'source'}</IconURL>\n");
    	print("\t\t</Entity>\n");
    }
}

# TODO Return optional error Maltego Entity.
print("\t</Entities>\n");

# http://ctas.paterva.com/view/Specification#Message_Wrapper
print("</MaltegoTransformResponseMessage>\n");
print("</MaltegoMessage>\n");

##### [<now>] Finished

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
HTTP::Tiny CPAN Module
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

http://github.com/cmlh/

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

Copyright 2012, 2013 Christian Heinrich


