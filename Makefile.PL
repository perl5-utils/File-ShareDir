use inc::Module::Install 0.75;

all_from      'lib/File/ShareDir.pm';
requires      'Carp'             => 0;
requires      'Params::Util'     => '0.07';
requires      'Class::Inspector' => '1.12';
requires      'File::Spec'       => '0.80';
test_requires 'Test::More'       => '0.47';
install_share;

WriteAll;
