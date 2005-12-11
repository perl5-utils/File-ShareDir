use inc::Module::Install;

name           ( 'File-ShareDir'               );
all_from       ( 'lib/File/ShareDir.pm'        );
requires       ( 'perl'             => '5.005' );
requires       ( 'Carp'             => 0       );
requires       ( 'Params::Util'     => '0.07'  );
requires       ( 'Class::Inspector' => '1.12'  );
requires       ( 'File::Spec'       => '0.80'  );
build_requires ( 'Test::More'       => '0.47'  );
auto_install   (                               );

&WriteAll;
