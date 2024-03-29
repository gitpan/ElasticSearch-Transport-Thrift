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

require 5.6.0;
use strict;
use warnings;

use ElasticSearch::Transport::ThriftBackend::Thrift;
use ElasticSearch::Transport::ThriftBackend::Thrift::Transport;

package ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransport;
{
  $ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransport::VERSION = '0.03';
}
use base('ElasticSearch::Transport::ThriftBackend::Thrift::Transport');

sub new
{
    my $classname = shift;
    my $transport = shift;
    my $rBufSize  = shift || 512;
    my $wBufSize  = shift || 512;

    my $self = {
        transport => $transport,
        rBufSize  => $rBufSize,
        wBufSize  => $wBufSize,
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

sub close()
{
    my $self = shift;
    $self->{transport}->close();
}

sub readAll
{
    my $self = shift;
    my $len  = shift;

    return $self->{transport}->readAll($len);
}

sub read
{
    my $self = shift;
    my $len  = shift;
    my $ret;

    # Methinks Perl is already buffering these for us
    return $self->{transport}->read($len);
}

sub write
{
    my $self = shift;
    my $buf  = shift;

    $self->{wBuf} .= $buf;
    if (length($self->{wBuf}) >= $self->{wBufSize}) {
        $self->{transport}->write($self->{wBuf});
        $self->{wBuf} = '';
    }
}

sub flush
{
    my $self = shift;

    if (length($self->{wBuf}) > 0) {
        $self->{transport}->write($self->{wBuf});
        $self->{wBuf} = '';
    }
    $self->{transport}->flush();
}


#
# BufferedTransport factory creates buffered transport objects from transports
#
package ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransportFactory;
{
  $ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransportFactory::VERSION = '0.03';
}

sub new {
    my $classname = shift;
    my $self      = {};

    return bless($self,$classname);
}

#
# Build a buffered transport from the base transport
#
# @return ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransport transport
#
sub getTransport
{
    my $self  = shift;
    my $trans = shift;

    my $buffered = ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransport->new($trans);
    return $buffered;
}


1;

__END__
=pod

=head1 NAME

ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransport

=head1 VERSION

version 0.03

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Clinton Gormley.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

