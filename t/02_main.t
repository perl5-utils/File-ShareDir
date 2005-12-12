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
		lib->import(
			catdir('blib', 'lib'),
			catdir('blib', 'arch'),
			'lib',
			);
	}
}

use Test::More tests => 24;
use File::ShareDir;

sub dies {
	my $code    = shift;
	my $message = shift || 'Code dies as expected';
	my $rv      = eval { &$code() };
	ok( $@, $message );
}

# Print the contents of @INC
#diag("\@INC = qw{");
#foreach ( @INC ) {
#	diag("    $_");
#}
#diag("    }");




#####################################################################
# Loading and Importing

# Don't import by default
ok( ! defined &dist_dir,    'dist_dir not imported by default'    );
ok( ! defined &module_dir,  'module_dir not imported by default'  );
ok( ! defined &dist_file,   'dist_file not imported by default'   );
ok( ! defined &module_file, 'module_file not imported by default' );

use_ok( 'File::ShareDir', ':ALL' );

# Import as needed
ok( defined &dist_dir,    'dist_dir imported'    );
ok( defined &module_dir,  'module_dir imported'  );
ok( defined &dist_file,   'dist_file imported'   );
ok( defined &module_file, 'module_file imported' );

# Allow all named functions
use_ok( 'File::ShareDir',
	'module_dir', 'module_file', 'dist_dir', 'dist_file',
	);





#####################################################################
# Support Methods

is( File::ShareDir::_MODULE('File::ShareDir'), 'File::ShareDir',
	'_MODULE returns correct for known loaded module' );
is( File::ShareDir::_DIST('File-ShareDir'), 'File-ShareDir',
	'_DIST returns correct for known good dist' );





#####################################################################
# Module Tests

my $module_dir = module_dir('File::ShareDir');
ok( $module_dir, 'Can find our own module dir' );
ok( -d $module_dir, '... and is a dir' );
ok( -r $module_dir, '... and have read permissions' );

dies( sub { module_dir() }, 'No params to module_dir dies' );
dies( sub { module_dir('') }, 'Null param to module_dir dies' );
dies( sub { module_dir('File::ShareDir::Bad') }, 'Getting module dir for known non-existanct module dies' );





#####################################################################
# Distribution Tets

my $dist_dir = dist_dir('File-ShareDir');
ok( $dist_dir, 'Can find our own dist dir' );
ok( -d $dist_dir, '... and is a dir' );
ok( -r $dist_dir, '... and have read permissions' );

my $dist_file = dist_file('File-ShareDir', 'sample.txt');
ok( $dist_file, 'Can find our sample module file' );
ok( -f $dist_file, '... and is a file' );
ok( -r $dist_file, '... and have read permissions' );
