# ABOUT

File::ShareDir - Locate per-dist and per-module shared files

## SYNOPSIS

```
use File::ShareDir ':ALL';

# Where are distribution-level shared data files kept
$dir = dist_dir('File-ShareDir');

# Where are module-level shared data files kept
$dir = module_dir('File::ShareDir');

# Find a specific file in our dist/module shared dir
$file = dist_file(  'File-ShareDir',  'file/name.txt');
$file = module_file('File::ShareDir', 'file/name.txt');

# Like module_file, but search up the inheritance tree
$file = class_file( 'Foo::Bar', 'file/name.txt' );
```

# Installation

Use `cpan -i File::ShareDir` or cpanm/cpanp equivalent or your operating
system's package manager.

Alternatively, download the File::ShareDir tarball and do:

```
perl Makefile.PL
make
make test
sudo make install
```

# Links and more information

* [MetaCPAN](https://metacpan.org/release/File-ShareDir)
* [GitHub VCS Repository](https://github.com/perl5-utils/File-ShareDir)

