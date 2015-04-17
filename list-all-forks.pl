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

sub get_repo_page
{
	my ($user, $page) = @_;

	my $url = sprintf 'https://api.github.com/users/%s/repos?page=%d', $user, $page;

	my $json_str = get ($url);
	if (!defined $json_str) {
		printf "Could not get $url";
		return;
	}

	my $obj = decode_json ($json_str);

	return $obj;
}

sub get_all_repos
{
	my ($user) = @_;
	my @repos;

	for my $i (1 .. $MAX_PAGES) {
		my @pages = get_repo_page ($user, $i);
		if (!@pages) {
			return;
		}

		my $count = scalar keys $pages[0];
		if ($count == 0) {
			last;
		}

		foreach my $r (keys $pages[0]) {
			if (!$pages[0][$r]->{'fork'}) {
				next;
			}
			push @repos, $pages[0][$r];
			print Dumper $pages[0][$r];
		}
	}

	return @repos;
}

sub main
{
	my $user = $ARGV[0] || 'flatcap';

	my @repos = get_all_repos ($user);
	if (!@repos) {
		return;
	}

	for my $r (@repos) {
		my $date = substr $r->{'created_at'}, 0, $DATE_LEN;
		printf "%s - %s\n", $date, $r->{'name'};
		my $d = $r->{'description'};
		if ($d) {
			printf "\t\"%s\"\n", $d;
		}
		printf "\n";
	}

	return;
}


main ();

