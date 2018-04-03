#!/usr/bin/perl

use strict;
use Regexp::Assemble;
use Bing::Translate;
use YAML::XS 'LoadFile';
use FindBin;

### Config

my $homeDir  = $FindBin::Bin;
my $config   = LoadFile($homeDir . '/config.yml');
my $exclude  = $homeDir . '/exclude.list';
my $id       = $config->{client_id};
my $secret   = $config->{client_secret};
my $src_lang = $config->{source_language};
my $dst_lang = $config->{destination_language};

### Build Regex Exclusion List
### NOTE: exclude list is read in regex format

my $ra = Regexp::Assemble->new;
$ra->add_file( $exclude );
my $regex = $ra->re;

### Count Lines in a File

sub count_lines {
  my $f = shift;
  my $l = 0;
  open FILE, $f or die "Can't read from '$f': $!";
  $l++ while (<FILE>);
  close FILE;
  return $l;
}

### Translation

sub trn {
  my $arg = shift;
  if ( length($arg) > 0 && $arg ne " " ) {
    my $translator = Bing::Translate->new($id, $secret);
    my $result = $translator->translate("$arg", $src_lang, $dst_lang);
    return $result;
  }
  else {
    return "";
  }
}

### Runtime

unless ( defined $ARGV[0] && defined $ARGV[1] ) {
  print "Usage: $0 <input file> <output file> \n";
  exit;
}

my $input = $ARGV[0];
my $output = $ARGV[1];

my $i = 0;
my $t = count_lines($input);

if ( $t > 0 ) {
  $|++;
  open WRITE, ">:utf8", $output or die "Can't write to '$output': $!";
  open READ, $input or die "Can't read from '$input': $!";
    while (my $row = <READ>) {
      $i++;
      print "\rTranslating line $i of $t";
      $row = join '', map { $_ =~ $regex ? $_ : trn($_) } split /($regex)/, $row;
      print WRITE $row;
    }
  close(READ);
  close(WRITE);
  print "\nFinished. Wrote $i lines to $output. \n";
}
else {
  print "Input file is empty.\n";
}
