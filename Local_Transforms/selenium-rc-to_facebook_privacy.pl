#!/usr/bin/env perl
# The above shebang is for "perlbrew", otherwise use /usr/bin/perl or the file path quoted for "which perl"
#
# Please refer to the Plain Old Documentation (POD) at the end of this Perl Script for further information

use strict;
use Config::Std;
use Test::More "no_plan";
# my $builder = Test::More->builder->output('selenium.txt');
use Test::WWW::Selenium;
use Term::ANSIColor;

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

my %maltego_additional_field_values =
  split_maltego_additional_fields($maltego_additional_field_values);

my $facebook_user_name = $maltego_selected_entity_value;
my $facebook_user_id   = $maltego_additional_field_values{"uid"};

# "###" is for Smart::Comments CPAN Module
### \$facebook_user_id is: $facebook_user_id;
### \$facebook_user_name is: $facebook_user_name;

# CONFIGURATION
# REFACTOR with "easydialogs" e.g. http://www.paterva.com/forum//index.php/topic,134.0.html as recommended by Andrew from Paterva
read_config './etc/selenium.conf' => my %config;
my $facebook_email = $config{'Selenium'}{'email'};
my $facebook_pass  = $config{'Selenium'}{'pass'};

my $sel = Test::WWW::Selenium->new(
    host        => "localhost",
    port        => "4444",
    browser     => "*firefox",
    browser_url => "https://facebook.com"
);

# Login to Facebook
$sel->open_ok("/");
$sel->type_ok( "email", $facebook_email );
$sel->type_ok( "pass",  $facebook_pass );
$sel->click_ok("id=loginbutton");
$sel->wait_for_page_to_load_ok;
$sel->pause("10000");

# Authenticated to Facebook
my $facebook_photo_privacy;
$sel->open_ok("/profile.php?id=$facebook_user_id&sk=photos");
$sel->wait_for_page_to_load_ok;
$sel->pause("10000");

# $sel->is_text_present_ok("only shares some information publicly");
if ( $sel->is_text_present("only shares some information publicly") ) {
    $facebook_photo_privacy = "private";
}
else { $facebook_photo_privacy = "public"; }

# Logout of Facebook
$sel->click_ok("css=div.menuPulldown");
$sel->click_ok("//input[\@value=\'Log Out\']");
$sel->wait_for_page_to_load_ok;

# TODO Randomize the sleep() and user-agent
sleep(5);

print("<MaltegoMessage>\n");
print("<MaltegoTransformResponseMessage>\n");
print("\t<UIMessages>\n");
print(
"\t\t<UIMessage MessageType=\"Inform\">Facebook Privacy (Selenium RC) Local Transform v$VERSION</UIMessage>\n"
);
print("\t\t<UIMessage MessageType=\"Inform\">");
my $facebook_photo_uimessage;

if ( $facebook_photo_privacy =~ "private" ) {

    # print color 'red';
    $facebook_photo_uimessage =
      "$facebook_user_name has configured their Facebook Photos as Private";
    open FACEBOOK_PHOTO_PRIVATE, ">>facebook_photo_private_log";
    print FACEBOOK_PHOTO_PRIVATE "$facebook_user_id,$facebook_user_name\n";
    close FACEBOOK_PHOTO_PRIVATE;
    print "$facebook_photo_uimessage";
}
if ( $facebook_photo_privacy =~ "public" ) {

    # print color 'green';
    $facebook_photo_uimessage =
      "$facebook_user_name has configured their Facebook Photos as Public";
    open FACEBOOK_PHOTO_PUBLIC, ">>facebook_photo_public_log";
    print FACEBOOK_PHOTO_PUBLIC "$facebook_user_id,$facebook_user_name\n";
    close FACEBOOK_PHOTO_PUBLIC;
    print "$facebook_photo_uimessage";
    print STDERR "$facebook_photo_uimessage\n";
}

print("</UIMessage>\n\t</UIMessages>\n");

print("\t<Entities>\n");

# TODO Return optional error Maltego Entity.
if ( $facebook_photo_privacy =~ "public" ) {
    print
"\t\t<Entity Type=\"cmlh.facebook.photo.privacy\"><Value>Public</Value></Entity>\n";
}
if ( $facebook_photo_privacy =~ "private" ) {
    print
"\t\t<Entity Type=\"cmlh.facebook.photo.privacy\"><Value>Private</Value></Entity>\n";
}
print("\t</Entities>\n");

# http://ctas.paterva.com/view/Specification#Message_Wrapper
print("</MaltegoTransformResponseMessage>\n");
print("</MaltegoMessage>\n");

sub split_maltego_additional_fields {

    my $maltego_additional_field_values = $_[0];
    my @maltego_additional_field_values =
      split( '#', $maltego_additional_field_values );

    my %maltego_additional_field_values;

    foreach (@maltego_additional_field_values) {
        my ( $key, $value ) = split( /=/, $_, 2 );
        $maltego_additional_field_values{"$key"} = "$value";
    }

    return %maltego_additional_field_values;
}

=head1 NAME

selenium-rc-to_facebook_privacy.pl - "To Facebook Privacy"

=head1 VERSION

This documentation refers "To Facebook Privacy" Alpha v$VERSION

=head1 CONFIGURATION

Set the value(s) marked as #CONFIGURATION above this POD
    
=head1 USAGE

selenium-rc-to_facebook_privacy.pl $maltego_selected_entity $maltego_additional_field_values

=head1 REQUIRED ARGUEMENTS
                
=head1 OPTIONAL ARGUEMENTS

=head1 DESCRIPTION

Returns the Facebook Image, Name and Link in Maltego via the Facebook GraphAPI

=head1 DEPENDENCIES

=head1 PREREQUISITES

Test::WWW::Selenium CPAN Module

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


