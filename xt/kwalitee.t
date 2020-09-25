#!perl

## in a separate test file

use strict;
use warnings;

use Test::More;
use Test::Kwalitee 'kwalitee_ok';

kwalitee_ok(qw(-has_meta_yml));

done_testing;
