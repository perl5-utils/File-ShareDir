#!perl

use strict;
use warnings;

use Test::More;

eval "use Test::PerlTidy";
plan skip_all => "Test::PerlTidy required" if $@;

run_tests(
    perltidyrc => '.perltidyrc',
    exclude    => ['travis-perl-helpers', 'inc/inc_File-ShareDir-Install', 'inc/latest.pm', 'inc/latest/private.pm'],
);
