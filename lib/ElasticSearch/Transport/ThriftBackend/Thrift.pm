#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

our $VERSION = '0.1';

require 5.6.0;
use strict;
use warnings;

#
# Data types that can be sent via ElasticSearch::Transport::ThriftBackend::Thrift
#
package ElasticSearch::Transport::ThriftBackend::TType;
use constant STOP   => 0;
use constant VOID   => 1;
use constant BOOL   => 2;
use constant BYTE   => 3;
use constant I08    => 3;
use constant DOUBLE => 4;
use constant I16    => 6;
use constant I32    => 8;
use constant I64    => 10;
use constant STRING => 11;
use constant UTF7   => 11;
use constant STRUCT => 12;
use constant MAP    => 13;
use constant SET    => 14;
use constant LIST   => 15;
use constant UTF8   => 16;
use constant UTF16  => 17;
1;

#
# Message types for RPC
#
package ElasticSearch::Transport::ThriftBackend::TMessageType;
use constant CALL      => 1;
use constant REPLY     => 2;
use constant EXCEPTION => 3;
use constant ONEWAY    => 4;
1;

package ElasticSearch::Transport::ThriftBackend::Thrift::TException;

sub new {
    my $classname = shift;
    my $self = {message => shift, code => shift || 0};

    return bless($self,$classname);
}
1;

package ElasticSearch::Transport::ThriftBackend::TApplicationException;
use base('ElasticSearch::Transport::ThriftBackend::Thrift::TException');

use constant UNKNOWN              => 0;
use constant UNKNOWN_METHOD       => 1;
use constant INVALID_MESSAGE_TYPE => 2;
use constant WRONG_METHOD_NAME    => 3;
use constant BAD_SEQUENCE_ID      => 4;
use constant MISSING_RESULT       => 5;

sub new {
    my $classname = shift;

    my $self = $classname->SUPER::new();

    return bless($self,$classname);
}

sub read {
    my $self  = shift;
    my $input = shift;

    my $xfer  = 0;
    my $fname = undef;
    my $ftype = 0;
    my $fid   = 0;

    $xfer += $input->readStructBegin(\$fname);

    while (1)
    {
        $xfer += $input->readFieldBegin(\$fname, \$ftype, \$fid);
        if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::STOP) {
            last; next;
        }

      SWITCH: for($fid)
      {
          /1/ && do{

              if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::STRING) {
                  $xfer += $input->readString(\$self->{message});
              } else {
                  $xfer += $input->skip($ftype);
              }

              last;
          };

          /2/ && do{
              if ($ftype == ElasticSearch::Transport::ThriftBackend::TType::I32) {
                  $xfer += $input->readI32(\$self->{code});
              } else {
                  $xfer += $input->skip($ftype);
              }
              last;
          };

          $xfer += $input->skip($ftype);
      }

      $xfer += $input->readFieldEnd();
    }
    $xfer += $input->readStructEnd();

    return $xfer;
}

sub write {
    my $self   = shift;
    my $output = shift;

    my $xfer   = 0;

    $xfer += $output->writeStructBegin('ElasticSearch::Transport::ThriftBackend::TApplicationException');

    if ($self->getMessage()) {
        $xfer += $output->writeFieldBegin('message', ElasticSearch::Transport::ThriftBackend::TType::STRING, 1);
        $xfer += $output->writeString($self->getMessage());
        $xfer += $output->writeFieldEnd();
    }

    if ($self->getCode()) {
        $xfer += $output->writeFieldBegin('type', ElasticSearch::Transport::ThriftBackend::TType::I32, 2);
        $xfer += $output->writeI32($self->getCode());
        $xfer += $output->writeFieldEnd();
    }

    $xfer += $output->writeFieldStop();
    $xfer += $output->writeStructEnd();

    return $xfer;
}

sub getMessage
{
    my $self = shift;

    return $self->{message};
}

sub getCode
{
    my $self = shift;

    return $self->{code};
}

1;

__END__
=pod

=head1 NAME

ElasticSearch::Transport::ThriftBackend::TType

=head1 VERSION

version 0.03

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Clinton Gormley.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

