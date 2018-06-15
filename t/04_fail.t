#!perl

use strict;
use warnings;

use Test::More;

sub dies
{
    my $code    = shift;
    my $pattern = shift;
    my $message = shift || 'Code dies as expected';
    my $rv      = eval { &$code() };
    my $err     = $@;
    like($err, $pattern, $message);
}

use File::ShareDir ':ALL';

dies(sub { module_dir() },   qr/Not a valid module name/, 'No params to module_dir dies');
dies(sub { module_dir('') }, qr/Not a valid module name/, 'Null param to module_dir dies');
dies(
    sub { module_dir('File::ShareDir::Bad') },
    qr/Module 'File::ShareDir::Bad' is not loaded/,
    'Getting module dir for known non-existant module dies',
);
# test from RT#125582
dies(
    sub { dist_file('File-ShareDir', 'file/name.txt'); },
    qr,Failed to find shared file 'file/name.txt' for dist 'File-ShareDir',,
    "Getting non-existant file dies"
);

done_testing;
