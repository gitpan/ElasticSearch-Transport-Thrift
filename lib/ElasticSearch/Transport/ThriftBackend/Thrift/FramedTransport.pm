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

use strict;
use warnings;

use ElasticSearch::Transport::ThriftBackend::Thrift;
use ElasticSearch::Transport::ThriftBackend::Thrift::Transport;

#
# Framed transport. Writes and reads data in chunks that are stamped with
# their length.
#
# @package thrift.transport
#
package ElasticSearch::Transport::ThriftBackend::Thrift::FramedTransport;
{
  $ElasticSearch::Transport::ThriftBackend::Thrift::FramedTransport::VERSION = '0.03';
}

use base('ElasticSearch::Transport::ThriftBackend::Thrift::Transport');

sub new
{
    my $classname = shift;
    my $transport = shift;
    my $read      = shift || 1;
    my $write     = shift || 1;

    my $self      = {
        transport => $transport,
        read      => $read,
        write     => $write,
        wBuf      => '',
        rBuf      => '',
    };

    return bless($self,$classname);
}

sub isOpen
{
    my $self = shift;
    return $self->{transport}->isOpen();
}

sub open
{
    my $self = shift;

    $self->{transport}->open();
}

sub close
{
    my $self = shift;

    $self->{transport}->close();
}

#
# Reads from the buffer. When more data is required reads another entire
# chunk and serves future reads out of that.
#
# @param int $len How much data
#
sub read
{

    my $self = shift;
    my $len  = shift;

    if (!$self->{read}) {
        return $self->{transport}->read($len);
    }

    if (length($self->{rBuf}) == 0) {
        $self->_readFrame();
    }


    # Just return full buff
    if ($len > length($self->{rBuf})) {
        my $out = $self->{rBuf};
        $self->{rBuf} = '';
        return $out;
    }

    # Return substr
    my $out = substr($self->{rBuf}, 0, $len);
    $self->{rBuf} = substr($self->{rBuf}, $len);
    return $out;
}

#
# Reads a chunk of data into the internal read buffer.
# (private)
sub _readFrame
{
    my $self = shift;
    my $buf  = $self->{transport}->readAll(4);
    my @val  = unpack('N', $buf);
    my $sz   = $val[0];

    $self->{rBuf} = $self->{transport}->readAll($sz);
}

#
# Writes some data to the pending output buffer.
#
# @param string $buf The data
# @param int    $len Limit of bytes to write
#
sub write
{
    my $self = shift;
    my $buf  = shift;
    my $len  = shift;

    unless($self->{write}) {
        return $self->{transport}->write($buf, $len);
    }

    if ( defined $len && $len < length($buf)) {
        $buf = substr($buf, 0, $len);
    }

    $self->{wBuf} .= $buf;
  }

#
# Writes the output buffer to the stream in the format of a 4-byte length
# followed by the actual data.
#
sub flush
{
    my $self = shift;

    unless ($self->{write}) {
        return $self->{transport}->flush();
    }

    my $out = pack('N', length($self->{wBuf}));
    $out .= $self->{wBuf};
    $self->{transport}->write($out);
    $self->{transport}->flush();
    $self->{wBuf} = '';

}

1;

__END__
=pod

=head1 NAME

ElasticSearch::Transport::ThriftBackend::Thrift::FramedTransport

=head1 VERSION

version 0.03

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Clinton Gormley.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

