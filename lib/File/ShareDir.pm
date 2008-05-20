package File::ShareDir;

=pod

=head1 NAME

File::ShareDir - Locate per-dist and per-module shared files

=head1 SYNOPSIS

  use File::SharedDir ':ALL';
  
  # Where are distribution-level shared data files kept
  $dir = dist_dir('File-ShareDir');
  
  # Where are module-level shared data files kept
  $dir = module_dir('File::ShareDir');
  
  # Find a specific file in our dist/module shared dir
  $file = dist_file(  'File-ShareDir',  'file/name.txt');
  $file = module_file('File::ShareDir', 'file/name.txt');
  
  # Like module_file, but search up the inheritance tree
  $file = class_file( 'Foo::Bar', 'file/name.txt' );
=head1 DESCRIPTION

The intent of L<File::ShareDir> is to provide a companion to
L<Class::Inspector> and L<File::HomeDir>, modules that take a
process that is well-known by advanced Perl developers but gets a
little tricky, and make it more available to the larger Perl community.

Quite often you want or need your Perl module (CPAN or otherwise)
to have access to a large amount of read-only data that is stored
on the file-system at run-time.

On a linux-like system, this would be in a place such as /usr/share,
however Perl runs on a wide variety of different systems, and so
the use of any one location is unreliable.

Perl provides a little-known method for doing this, but almost
nobody is aware that it exists. As a result, module authors often
go through some very strange ways to make the data available to
their code.

The most common of these is to dump the data out to an enormous
Perl data structure and save it into the module itself. The
result are enormous multi-megabyte .pm files that chew up a
lot of memory needlessly.

Another method is to put the data "file" after the __DATA__ compiler
tag and limit yourself to access as a filehandle.

The problem to solve is really quite simple.

  1. Write the data files to the system at install time.
  
  2. Know where you put them at run-time.

Perl's install system creates an "auto" directory for both
every distribution and for every module file.

These are used by a couple of different auto-loading systems
to store code fragments generated at install time, and various
other modules written by the Perl "ancient masters".

But the same mechanism is available to any dist or module to
store any sort of data.

=head2 Using Data in your Module

C<File::ShareDir> forms one half of a two part solution.

Once the files have been installed to the correct directory,
you can use C<File::ShareDir> to find your files again after
the installation.

For the installation half of the solution, see L<Module::Install>
and its C<install_share> directive.

=head1 FUNCTIONS

C<File::ShareDir> provides four functions for locating files and
directories.

For greater maintainability, none of these are exported by default
and you are expected to name the ones you want at use-time, or provide
the C<':ALL'> tag. All of the following are equivalent.

  # Load but don't import, and then call directly
  use File::ShareDir;
  $dir = File::ShareDir::dist_dir('My-Dist');
  
  # Import a single function
  use File::ShareDir 'dist_dir';
  dist_dir('My-Dist');
  
  # Import all the functions
  use File::ShareDir ':ALL';
  dist_dir('My-Dist');

All of the functions will check for you that the dir/file actually
exists, and that you have read permissions, or they will throw an
exception.

=cut

use 5.005;
use strict;
use base 'Exporter';
use Carp             'croak';
use File::Spec       ();
use Params::Util     '_CLASS';
use Class::Inspector ();

use vars qw{$VERSION @EXPORT_OK %EXPORT_TAGS};
BEGIN {
	$VERSION     = '1.06';
	@EXPORT_OK   = qw{dist_dir dist_file module_dir module_file class_file};
	%EXPORT_TAGS = (
		ALL => [ @EXPORT_OK ],
		);	
}

use constant IS_MACOS => !!($^O eq 'MacOS');





#####################################################################
# Interface Functions

=pod

=head2 dist_dir

  # Get a distrubition's shared files directory
  my $dir = dist_dir('My-Distribution');

The C<dist_dir> function takes a single parameter of the name of an
installed (CPAN or otherwise) distribution, and locates the shared
data directory created at install time for it.

Returns the directory path as a string, or dies if it cannot be
located or is not readable.

=cut

sub dist_dir {
	my $dist = _DIST(shift);

	# Create the subpath
	my $path = File::Spec->catdir(
		'auto', split( /-/, $dist ),
		);

	# Find the full dir withing @INC
	foreach my $inc ( @INC ) {
		next unless defined $inc and ! ref $inc;
		my $dir = File::Spec->catdir( $inc, $path );
		next unless -d $dir;
		unless ( -r $dir ) {
			croak("Directory '$dir', no read permissions");
		}
		return $dir;
	}

	# Couldn't find it
	croak("Failed to find share dir for dist '$dist'");
}

=pod

=head2 module_dir

  # Get a module's shared files directory
  my $dir = module_dir('My::Module');

The C<module_dir> function takes a single parameter of the name of an
installed (CPAN or otherwise) module, and locates the shared data
directory created at install time for it.

In order to find the directory, the module B<must> be loaded when
calling this function.

Returns the directory path as a string, or dies if it cannot be
located or is not readable.

=cut

sub module_dir {
	my $module = _MODULE(shift);
	my $short  = Class::Inspector->filename($module);
	my $long   = Class::Inspector->loaded_filename($module);
	$short =~ tr{/} {:} if IS_MACOS;
	substr( $short, -3, 3, '' );
	$long  =~ m{^(.*)\Q$short\E\.pm\z}s or die("Failed to find base dir");
	my $dir = File::Spec->catdir( "$1", 'auto', $short );
	unless ( -d $dir ) {
		croak("Directory '$dir', does not exist");
	}
	unless ( -r $dir ) {
		croak("Directory '$dir', no read permissions");
	}
	return $dir;		
}

=pod

=head2 dist_file

  # Find a file in our distribution shared dir
  my $dir = dist_file('My-Distribution', 'file/name.txt');

The C<dist_file> function takes two params of the distribution name
and file name, locates the dist dir, and then finds the file within
it, verifying that the file actually exists, and that it is readable.

The filename should be a relative path in the format of your local
filesystem. It will simply added to the directory using L<File::Spec>'s
C<catfile> method.

Returns the file path as a string, or dies if the file or the dist's
directory cannot be located, or the file is not readable.

=cut

sub dist_file {
	my $dist = _DIST(shift);
	my $file = _FILE(shift);

	# Create the subpath
	my $path = File::Spec->catdir(
		'auto', split( /-/, $dist ), $file,
		);

	# Find the full dir withing @INC
	foreach my $inc ( @INC ) {
		next unless defined $inc and ! ref $inc;
		my $full = File::Spec->catdir( $inc, $path );
		next unless -e $full;
		unless ( -r $full ) {
			croak("Directory '$full', no read permissions");
		}
		return $full;
	}

	# Couldn't find it
	croak("Failed to find shared file '$file' for dist '$dist'");
}

=pod

=head2 module_file

  # Find a file in our module shared dir
  my $dir = module_file('My::Module', 'file/name.txt');

The C<module_file> function takes two params of the module name
and file name. It locates the module dir, and then finds the file within
it, verifying that the file actually exists, and that it is readable.

In order to find the directory, the module B<must> be loaded when
calling this function.

The filename should be a relative path in the format of your local
filesystem. It will simply added to the directory using L<File::Spec>'s
C<catfile> method.

Returns the file path as a string, or dies if the file or the dist's
directory cannot be located, or the file is not readable.

=cut

sub module_file {
	my $module = _MODULE(shift);
	my $file   = _FILE(shift);
	my $dir    = module_dir($module);
	my $path   = File::Spec->catfile($dir, $file);
	unless ( -e $path ) {
		croak("File '$file' does not exist in module dir");
	}
	unless ( -r $path ) {
		croak("File '$file' cannot be read, no read permissions");
	}
	$path;
}


=pod

=head2 class_file

  # Find a file in our module shared dir, or in our parent class
  my $dir = class_file('My::Module', 'file/name.txt');

The C<module_file> function takes two params of the module name
and file name. It locates the module dir, and then finds the file within
it, verifying that the file actually exists, and that it is readable.

In order to find the directory, the module B<must> be loaded when
calling this function.

The filename should be a relative path in the format of your local
filesystem. It will simply added to the directory using L<File::Spec>'s
C<catfile> method.

If the file is NOT found for that module, C<class_file> will scan up
the module's @ISA tree, looking for the file in all of the parent
classes.

This allows you to, in effect, "subclass" shared files.

Returns the file path as a string, or dies if the file or the dist's
directory cannot be located, or the file is not readable.

=cut

sub class_file {
	my $module = _MODULE(shift);
	my $file   = _FILE(shift);

	# Get the super path ( not including UNIVERSAL )
	# Rather than using Class::ISA, we'll use an inlined version
	# that implements the same basic algorithm.
	my @path  = ();
	my @queue = ( $module );
	my %seen  = ( $module => 1 );
	while ( my $cl = shift @queue ) {
		push @path, $cl;
		no strict 'refs';
		unshift @queue, grep { ! $seen{$_}++ }
			map { s/^::/main::/; s/\'/::/g; $_ }
			( @{"${cl}::ISA"} );
	}

	# Search up the path
	foreach my $class ( @path ) {
		my $dir = eval {
			 module_dir($class);
		};
		next if $@;
		my $path = File::Spec->catfile($dir, $file);
		unless ( -e $path ) {
			next;
		}
		unless ( -r $path ) {
			croak("File '$file' cannot be read, no read permissions");
		}
		return $path;
	}
	croak("File '$file' does not exist in class or parent shared files");
}




#####################################################################
# Support Functions

# Matches a valid distribution name
### This is a total guess at this point
sub _DIST {
	if ( defined $_[0] and ! ref $_[0] and $_[0] =~ /^[a-z0-9+_-]+$/is ) {
		return shift;
	}
	croak("Not a valid distribution name");
}

# A valid and loaded module name
sub _MODULE {
	my $module = _CLASS(shift) or croak("Not a valid module name");
	if ( Class::Inspector->loaded($module) ) {
		return $module;
	}
	croak("Module '$module' is not loaded");
}

# A valid file name
sub _FILE {
	my $file = shift;
	unless ( defined $file and ! ref $file and length $file ) {
		croak("Did not pass a file name");
	}
	if ( File::Spec->file_name_is_absolute($file) ) {
		croak("Cannot use absolute file name '$file'");
	}
	$file;
}

1;

=pod

=head1 SUPPORT

Bugs should always be submitted via the CPAN bug tracker

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-ShareDir>

For other issues, contact the maintainer

=head1 AUTHOR

Adam Kennedy E<lt>adamk@cpan.orgE<gt>, L<http://ali.as/>

=head1 SEE ALSO

L<File::HomeDir>, L<Module::Install>, L<Module::Install::Share>

=head1 COPYRIGHT

Copyright (c) 2005, 2006 Adam Kennedy.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
