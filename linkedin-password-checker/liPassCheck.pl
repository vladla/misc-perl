#!/usr/bin/perl

use strict;
use warnings;

use Digest::SHA1 qw(sha1_hex);

my $found = "did not find";
my $cracked = "not cracked";
my $password = $ARGV[0];
my $phrase = sha1_hex($password);

open (FILE, "<SHA1.txt");

while (my $line = <FILE>) {
    
    $line = substr($line, 0, 40);

    if ($line eq $phrase) {
        $found = "found";
        last;
    }
    elsif ($line  eq "00000" . substr($phrase, 5)) {
        $found = "found";
        $cracked = "cracked";
        last;
    }
}

print "\nI $found \"$password\" - it was $cracked.\n\n";
