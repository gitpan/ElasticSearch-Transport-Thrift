#
# Autogenerated by ElasticSearch::Transport::ThriftBackend::Thrift
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#
require 5.6.0;
use strict;
use warnings;
use ElasticSearch::Transport::ThriftBackend::Thrift;

package ElasticSearch::Transport::ThriftBackend::Method;
{
  $ElasticSearch::Transport::ThriftBackend::Method::VERSION = '0.02';
}
use constant GET => 0;
use constant PUT => 1;
use constant POST => 2;
use constant DELETE => 3;
use constant HEAD => 4;
use constant OPTIONS => 5;
package ElasticSearch::Transport::ThriftBackend::Status;
{
  $ElasticSearch::Transport::ThriftBackend::Status::VERSION = '0.02';
}
use constant CONT => 100;
use constant SWITCHING_PROTOCOLS => 101;
use constant OK => 200;
use constant CREATED => 201;
use constant ACCEPTED => 202;
use constant NON_AUTHORITATIVE_INFORMATION => 203;
use constant NO_CONTENT => 204;
use constant RESET_CONTENT => 205;
use constant PARTIAL_CONTENT => 206;
use constant MULTI_STATUS => 207;
use constant MULTIPLE_CHOICES => 300;
use constant MOVED_PERMANENTLY => 301;
use constant FOUND => 302;
use constant SEE_OTHER => 303;
use constant NOT_MODIFIED => 304;
use constant USE_PROXY => 305;
use constant TEMPORARY_REDIRECT => 307;
use constant BAD_REQUEST => 400;
use constant UNAUTHORIZED => 401;
use constant PAYMENT_REQUIRED => 402;
use constant FORBIDDEN => 403;
use constant NOT_FOUND => 404;
use constant METHOD_NOT_ALLOWED => 405;
use constant NOT_ACCEPTABLE => 406;
use constant PROXY_AUTHENTICATION => 407;
use constant REQUEST_TIMEOUT => 408;
use constant CONFLICT => 409;
use constant GONE => 410;
use constant LENGTH_REQUIRED => 411;
use constant PRECONDITION_FAILED => 412;
use constant REQUEST_ENTITY_TOO_LARGE => 413;
use constant REQUEST_URI_TOO_LONG => 414;
use constant UNSUPPORTED_MEDIA_TYPE => 415;
use constant REQUESTED_RANGE_NOT_SATISFIED => 416;
use constant EXPECTATION_FAILED => 417;
use constant UNPROCESSABLE_ENTITY => 422;
use constant LOCKED => 423;
use constant FAILED_DEPENDENCY => 424;
use constant INTERNAL_SERVER_ERROR => 500;
use constant NOT_IMPLEMENTED => 501;
use constant BAD_GATEWAY => 502;
use constant SERVICE_UNAVAILABLE => 503;
use constant GATEWAY_TIMEOUT => 504;
use constant INSUFFICIENT_STORAGE => 506;
package ElasticSearch::Transport::ThriftBackend::RestRequest;
{
  $ElasticSearch::Transport::ThriftBackend::RestRequest::VERSION = '0.02';
}
use base qw(Class::Accessor);
ElasticSearch::Transport::ThriftBackend::RestRequest->mk_accessors( qw( method uri parameters headers body ) );

sub new {
  my $classname = shift;
  my $self      = {};
  my $vals      = shift || {};
  $self->{method} = undef;
  $self->{uri} = undef;
  $self->{parameters} = undef;
  $self->{headers} = undef;
  $self->{body} = undef;
  if (UNIVERSAL::isa($vals,'HASH')) {
    if (defined $vals->{method}) {
      $self->{method} = $vals->{method};
    }
    if (defined $vals->{uri}) {
      $self->{uri} = $vals->{uri};
    }
    if (defined $vals->{parameters}) {
      $self->{parameters} = $vals->{parameters};
    }
    if (defined $vals->{headers}) {
      $self->{headers} = $vals->{headers};
    }
    if (defined $vals->{body}) {
      $self->{body} = $vals->{body};
    }
  }
  return bless ($self, $classname);
}

sub getName {
  return 'RestRequest';
}

sub read {
  my ($self, $input) = @_;
  my $xfer  = 0;
  my $fname;
  my $ftype = 0;
  my $fid   = 0;
  $xfer += $input->readStructBegin(\$fname);
  while (1)
  {
    $xfer += $input->readFieldBegin(\$fname, \$ftype, \$fid);
    if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::STOP) {
      last;
    }
    SWITCH: for($fid)
    {
      /^1$/ && do{      if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::I32) {
        $xfer += $input->readI32(\$self->{method});
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^2$/ && do{      if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::STRING) {
        $xfer += $input->readString(\$self->{uri});
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^3$/ && do{      if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::MAP) {
        {
          my $_size0 = 0;
          $self->{parameters} = {};
          my $_ktype1 = 0;
          my $_vtype2 = 0;
          $xfer += $input->readMapBegin(\$_ktype1, \$_vtype2, \$_size0);
          for (my $_i4 = 0; $_i4 < $_size0; ++$_i4)
          {
            my $key5 = '';
            my $val6 = '';
            $xfer += $input->readString(\$key5);
            $xfer += $input->readString(\$val6);
            $self->{parameters}->{$key5} = $val6;
          }
          $xfer += $input->readMapEnd();
        }
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^4$/ && do{      if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::MAP) {
        {
          my $_size7 = 0;
          $self->{headers} = {};
          my $_ktype8 = 0;
          my $_vtype9 = 0;
          $xfer += $input->readMapBegin(\$_ktype8, \$_vtype9, \$_size7);
          for (my $_i11 = 0; $_i11 < $_size7; ++$_i11)
          {
            my $key12 = '';
            my $val13 = '';
            $xfer += $input->readString(\$key12);
            $xfer += $input->readString(\$val13);
            $self->{headers}->{$key12} = $val13;
          }
          $xfer += $input->readMapEnd();
        }
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^5$/ && do{      if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::STRING) {
        $xfer += $input->readString(\$self->{body});
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
        $xfer += $input->skip($ftype);
    }
    $xfer += $input->readFieldEnd();
  }
  $xfer += $input->readStructEnd();
  return $xfer;
}

sub write {
  my ($self, $output) = @_;
  my $xfer   = 0;
  $xfer += $output->writeStructBegin('RestRequest');
  if (defined $self->{method}) {
    $xfer += $output->writeFieldBegin('method', ElasticSearch::Transport::ThriftBackend::TType::I32, 1);
    $xfer += $output->writeI32($self->{method});
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{uri}) {
    $xfer += $output->writeFieldBegin('uri', ElasticSearch::Transport::ThriftBackend::TType::STRING, 2);
    $xfer += $output->writeString($self->{uri});
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{parameters}) {
    $xfer += $output->writeFieldBegin('parameters', ElasticSearch::Transport::ThriftBackend::TType::MAP, 3);
    {
      $xfer += $output->writeMapBegin(ElasticSearch::Transport::ThriftBackend::TType::STRING, ElasticSearch::Transport::ThriftBackend::TType::STRING, scalar(keys %{$self->{parameters}}));
      {
        while( my ($kiter14,$viter15) = each %{$self->{parameters}})
        {
          $xfer += $output->writeString($kiter14);
          $xfer += $output->writeString($viter15);
        }
      }
      $xfer += $output->writeMapEnd();
    }
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{headers}) {
    $xfer += $output->writeFieldBegin('headers', ElasticSearch::Transport::ThriftBackend::TType::MAP, 4);
    {
      $xfer += $output->writeMapBegin(ElasticSearch::Transport::ThriftBackend::TType::STRING, ElasticSearch::Transport::ThriftBackend::TType::STRING, scalar(keys %{$self->{headers}}));
      {
        while( my ($kiter16,$viter17) = each %{$self->{headers}})
        {
          $xfer += $output->writeString($kiter16);
          $xfer += $output->writeString($viter17);
        }
      }
      $xfer += $output->writeMapEnd();
    }
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{body}) {
    $xfer += $output->writeFieldBegin('body', ElasticSearch::Transport::ThriftBackend::TType::STRING, 5);
    $xfer += $output->writeString($self->{body});
    $xfer += $output->writeFieldEnd();
  }
  $xfer += $output->writeFieldStop();
  $xfer += $output->writeStructEnd();
  return $xfer;
}

package ElasticSearch::Transport::ThriftBackend::RestResponse;
{
  $ElasticSearch::Transport::ThriftBackend::RestResponse::VERSION = '0.02';
}
use base qw(Class::Accessor);
ElasticSearch::Transport::ThriftBackend::RestResponse->mk_accessors( qw( status headers body ) );

sub new {
  my $classname = shift;
  my $self      = {};
  my $vals      = shift || {};
  $self->{status} = undef;
  $self->{headers} = undef;
  $self->{body} = undef;
  if (UNIVERSAL::isa($vals,'HASH')) {
    if (defined $vals->{status}) {
      $self->{status} = $vals->{status};
    }
    if (defined $vals->{headers}) {
      $self->{headers} = $vals->{headers};
    }
    if (defined $vals->{body}) {
      $self->{body} = $vals->{body};
    }
  }
  return bless ($self, $classname);
}

sub getName {
  return 'RestResponse';
}

sub read {
  my ($self, $input) = @_;
  my $xfer  = 0;
  my $fname;
  my $ftype = 0;
  my $fid   = 0;
  $xfer += $input->readStructBegin(\$fname);
  while (1)
  {
    $xfer += $input->readFieldBegin(\$fname, \$ftype, \$fid);
    if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::STOP) {
      last;
    }
    SWITCH: for($fid)
    {
      /^1$/ && do{      if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::I32) {
        $xfer += $input->readI32(\$self->{status});
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^2$/ && do{      if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::MAP) {
        {
          my $_size18 = 0;
          $self->{headers} = {};
          my $_ktype19 = 0;
          my $_vtype20 = 0;
          $xfer += $input->readMapBegin(\$_ktype19, \$_vtype20, \$_size18);
          for (my $_i22 = 0; $_i22 < $_size18; ++$_i22)
          {
            my $key23 = '';
            my $val24 = '';
            $xfer += $input->readString(\$key23);
            $xfer += $input->readString(\$val24);
            $self->{headers}->{$key23} = $val24;
          }
          $xfer += $input->readMapEnd();
        }
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
      /^3$/ && do{      if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::STRING) {
        $xfer += $input->readString(\$self->{body});
      } else {
        $xfer += $input->skip($ftype);
      }
      last; };
        $xfer += $input->skip($ftype);
    }
    $xfer += $input->readFieldEnd();
  }
  $xfer += $input->readStructEnd();
  return $xfer;
}

sub write {
  my ($self, $output) = @_;
  my $xfer   = 0;
  $xfer += $output->writeStructBegin('RestResponse');
  if (defined $self->{status}) {
    $xfer += $output->writeFieldBegin('status', ElasticSearch::Transport::ThriftBackend::TType::I32, 1);
    $xfer += $output->writeI32($self->{status});
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{headers}) {
    $xfer += $output->writeFieldBegin('headers', ElasticSearch::Transport::ThriftBackend::TType::MAP, 2);
    {
      $xfer += $output->writeMapBegin(ElasticSearch::Transport::ThriftBackend::TType::STRING, ElasticSearch::Transport::ThriftBackend::TType::STRING, scalar(keys %{$self->{headers}}));
      {
        while( my ($kiter25,$viter26) = each %{$self->{headers}})
        {
          $xfer += $output->writeString($kiter25);
          $xfer += $output->writeString($viter26);
        }
      }
      $xfer += $output->writeMapEnd();
    }
    $xfer += $output->writeFieldEnd();
  }
  if (defined $self->{body}) {
    $xfer += $output->writeFieldBegin('body', ElasticSearch::Transport::ThriftBackend::TType::STRING, 3);
    $xfer += $output->writeString($self->{body});
    $xfer += $output->writeFieldEnd();
  }
  $xfer += $output->writeFieldStop();
  $xfer += $output->writeStructEnd();
  return $xfer;
}

1;

__END__
=pod

=head1 NAME

ElasticSearch::Transport::ThriftBackend::Method

=head1 VERSION

version 0.02

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Clinton Gormley.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

