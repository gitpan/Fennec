
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'Module::Build' => '0.3601'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Workflow based testing framework for Perl.',
  'dist_author' => [
    'Chad \'Exodist\' Granum <exodist7@gmail.com>'
  ],
  'dist_name' => 'Fennec',
  'dist_version' => '0.030',
  'license' => 'perl',
  'module_name' => 'Fennec',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Benchmark' => '0',
    'Carp::Always' => '0',
    'Cwd' => '0',
    'Data::Dumper' => '0',
    'Devel::CallerStack' => '0',
    'Digest::MD5' => '0',
    'Exporter::Declare' => '0.024',
    'File::Temp' => '0',
    'List::MoreUtils' => '0',
    'List::Util' => '0',
    'Parallel::Runner' => '0.008',
    'Scalar::Util' => '0',
    'Time::HiRes' => '0',
    'Try::Tiny' => '0'
  },
  'script_files' => [],
  'share_dir' => {
    'dist' => 'share'
  }
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
