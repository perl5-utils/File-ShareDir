#!/usr/bin/perl -w

# Compile-testing for PITA::Report

use strict;
use lib ();
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		$FindBin::Bin = $FindBin::Bin; # Avoid a warning
		chdir catdir( $FindBin::Bin, updir() );
		lib->import('blib', 'lib');
	}
}

use Test::More tests => 15;
use File::ShareDir;

# Existance
ok( ! defined &dist_dir,    'dist_dir not imported by default'    );
ok( ! defined &module_dir,  'module_dir not imported by default'  );
ok( ! defined &dist_file,   'dist_file not imported by default'   );
ok( ! defined &module_file, 'module_file not imported by default' );
use_ok( 'File::ShareDir', ':ALL' );
ok( defined &dist_dir,    'dist_dir imported'    );
ok( defined &module_dir,  'module_dir imported'  );
ok( defined &dist_file,   'dist_file imported'   );
ok( defined &module_file, 'module_file imported' );





#####################################################################
# Support Methods

is( File::ShareDir::_MODULE('File::ShareDir'), 'File::ShareDir',
	'_MODULE returns correct for known loaded module' );





#####################################################################
# Functionality Tests

my $module_dir = module_dir('File::ShareDir');
ok( $module_dir, 'Can find our own module dir' );
ok( -d $module_dir, '... and is a dir' );
ok( -r $module_dir, '... and have read permissions' );

my $dist_dir = dist_dir('File-ShareDir');
ok( $dist_dir, 'Can find our own module dir' );
ok( -d $dist_dir, '... and is a dir' );
ok( -r $dist_dir, '... and have read permissions' );

