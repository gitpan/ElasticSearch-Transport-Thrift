
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601",
    "Test::More" => 0
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "A Thrift backend for ElasticSearch",
  "dist_author" => [
    "Clinton Gormley <drtech\@cpan.org>"
  ],
  "dist_name" => "ElasticSearch-Transport-Thrift",
  "dist_version" => "0.01",
  "license" => "perl",
  "module_name" => "ElasticSearch::Transport::Thrift",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Bit::Vector" => 0,
    "Class::Accessor" => 0,
    "Encode" => 0,
    "HTTP::Request" => 0,
    "IO::Select" => 0,
    "IO::Socket::INET" => 0,
    "IO::String" => 0,
    "LWP::UserAgent" => 0,
    "POSIX" => 0,
    "base" => 0,
    "constant" => 0,
    "parent" => 0,
    "perl" => "5.6.0",
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
