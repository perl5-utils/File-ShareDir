#!perl

use strict;
use warnings;

use Test::More;
use Test::PerlTidy;

run_tests(
    perltidyrc => '.perltidyrc',
    exclude    => ['travis-perl-helpers', 'inc/inc_File-ShareDir-Install', 'inc/latest.pm', 'inc/latest/private.pm'],
);
