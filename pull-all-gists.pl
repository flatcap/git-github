#!/usr/bin/perl

use strict;
use warnings;

our $VERSION = 0.1;

use LWP::Simple;
use JSON qw(decode_json);
use Data::Dumper;

# my $url = "https://api.github.com/users/flatcap/gists";
my $url = 'http://flatcap.xyz/gists/flatcap.json';

my $json = get ($url);
if (!defined $json) {
	die "Could not get $url!";
}

my $decoded_json = decode_json ($json);
print Dumper $decoded_json;

