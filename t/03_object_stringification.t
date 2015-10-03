#!/usr/bin/perl

use strict;

use FindBin;
use File::Temp qw(tempdir);
use File::Copy::Recursive qw(dircopy);

BEGIN {
    $| = 1;
    $^W = 1;
}

{
    package MyPackage;

    use overload 
        fallback => 1,
        '""' => sub { $_[0]->{lib} };

    sub new {
        my ($class, $lib) = @_;
        my $self = bless {}, $class;
        $self->{lib} = $lib;
        return $self;
    }

    sub MyPackage::INC {
        my ($self, $filename) = @_;
        return if ($filename ne 'File/ShareDir.pm');

        my $filepath = sprintf("%s/$filename", $self->{lib});
        open(my $fh, '<', $filepath) or die $!;
        $INC{$filename} = $filepath;
        return $fh;
    }

}

use Test::More tests => 3;

my $tempdir = tempdir(CLEANUP => 1);
my $templib = "$tempdir/lib";
my $bliblibdir = "$FindBin::RealBin/../blib/lib";

dircopy($bliblibdir, $templib) or die $!;

unshift @INC, MyPackage->new($templib); 

require File::ShareDir;

#diag $INC{'File/ShareDir.pm'};
ok($INC{'File/ShareDir.pm'} =~ /^\Q$tempdir\E/, 
        "File::ShareDir loaded from tempdir");

my $dist_dir = File::ShareDir::dist_dir('File-ShareDir');
#diag $dist_dir;
ok( ($dist_dir && $dist_dir =~ /^\Q$tempdir\E/),
        'Can find our own dist dir from tempdir' );
 
my $dist_file = File::ShareDir::dist_file('File-ShareDir', 'sample.txt');
#diag $dist_file;
ok( ($dist_file && $dist_file =~ /^\Q$tempdir\E/),
        'Can find our sample module file from tempdir' );


