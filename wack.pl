#!/usr/bin/perl

use strict;
use warnings;
use BerkeleyDB;

my %wallet;
my $filename = shift || 'wallet.dat';
my $db  = tie %wallet, 'BerkeleyDB::Btree',
        -Filename => $filename,
        -Subname  => "main",
        -Flags => DB_RDONLY,
    or die  "Cannot open file $filename: $! $BerkeleyDB::Error\n";

my $counts = {};
while (my ($k,$v) = each %wallet) {
    my $len  = unpack("W", substr($k, 0, 1));
    my $type = substr $k, 1, $len;
    my $key  = substr $k, $len+1;

    #printf "%s => %x\n", $k, $v;
    if ($type eq 'key') {
        my $privkey = unpack("H*", $v);
        $key = unpack("H*", $key);
        print "key=$key, privkey=$privkey\n";
    } elsif ($type eq 'zkey') {
        my $privkey = unpack("H*", $v);
        $key = unpack("H*", $key);
        print "zkey=$key, privkey=$privkey\n";
    } elsif ($type eq 'name') {
        print "name: $key, $v\n";
    } elsif ($type eq 'bestblock') {
        my $len = length $v;
        print "bestblock ($len bytes):\nbestblock: $key, $v\n";
    } elsif ($type eq 'version') {
        my $version = unpack("I", $v);
        print "version: $version\n";
    } else {
        my $len = length $v;
        print "$type ($len bytes): $key, $v\n";
    }
    $counts->{$type}++;
    printf "$len $type %s:\n", $key;
}

printf "Stats\n";
while (my ($k,$v) = each %$counts) {
    print "$k => $v\n";
}
