#!/usr/bin/perl

use strict;
use warnings;

our $VERSION = 0.1;

use LWP::Simple;
use JSON qw(decode_json);
use Data::Dumper;
use Readonly;

Readonly my $DATE_LEN  => 10;
Readonly my $MAX_PAGES => 20;

sub get_gist_page
{
	my ($user, $page) = @_;

	my $url = sprintf 'https://api.github.com/users/%s/gists?page=%d', $user, $page;

	my $json_str = get ($url);
	if (!defined $json_str) {
		printf "Could not get $url";
		return;
	}

	my $obj = decode_json ($json_str);

	return $obj;
}

sub get_all_gists
{
	my ($user) = @_;
	my @gists;

	for my $i (1 .. $MAX_PAGES) {
		my @pages = get_gist_page ($user, $i);
		if (!@pages) {
			return;
		}

		my $count = scalar keys $pages[0];
		if ($count == 0) {
			last;
		}

		foreach my $g (keys $pages[0]) {
			# printf "%s\n", $pages[0][$g]->{'id'};
			push @gists, $pages[0][$g];
		}
	}

	return @gists;
}

sub main
{
	my $user = $ARGV[0] || 'flatcap';

	my @gists = get_all_gists ($user);
	if (!@gists) {
		return;
	}

	for my $g (@gists) {
		my $date = substr $g->{'created_at'}, 0, $DATE_LEN;
		printf "%s - %s\n", $date, $g->{'id'};
		my $d = $g->{'description'};
		if ($d) {
			printf "\t\"%s\"\n", $d;
		}
		for my $f (keys $g->{'files'}) {
			printf "\t%s (%d bytes)\n", $f, $g->{'files'}->{$f}->{'size'};
		}
		printf "\n";
	}

	return;
}


main ();

