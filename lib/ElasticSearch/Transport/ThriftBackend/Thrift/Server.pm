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
no warnings 'redefine';

use ElasticSearch::Transport::ThriftBackend::Thrift;
use ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransport;
use ElasticSearch::Transport::ThriftBackend::Thrift::BinaryProtocol;

#
# Server base class module
#
package ElasticSearch::Transport::ThriftBackend::Thrift::Server;
{
  $ElasticSearch::Transport::ThriftBackend::Thrift::Server::VERSION = '0.02';
}

# 3 possible constructors:
#   1.  (processor, serverTransport)
#   2.  (processor, serverTransport, transportFactory, protocolFactory)
#   3.  (processor, serverTransport,
#        inputTransportFactory, outputTransportFactory,
#        inputProtocolFactory, outputProtocolFactory)
sub new
{
    my $classname    = shift;
    my @args         = @_;

    my $self;

    if (scalar @args == 2)
    {
      $self = _init($args[0], $args[1],
                    ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransportFactory->new(),
                    ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransportFactory->new(),
                    ElasticSearch::Transport::ThriftBackend::Thrift::BinaryProtocolFactory->new(),
                    ElasticSearch::Transport::ThriftBackend::Thrift::BinaryProtocolFactory->new());
    }
    elsif (scalar @args == 4)
    {
      $self = _init($args[0], $args[1], $args[2], $args[2], $args[3], $args[3]);
    }
    elsif (scalar @args == 6)
    {
      $self = _init($args[0], $args[1], $args[2], $args[3], $args[4], $args[5]);
    }
    else
    {
      die "ElasticSearch::Transport::ThriftBackend::Thrift::Server expects exactly 2, 4, or 6 args";
    }

    return bless($self,$classname);
}

sub _init
{
    my $processor              = shift;
    my $serverTransport        = shift;
    my $inputTransportFactory  = shift;
    my $outputTransportFactory = shift;
    my $inputProtocolFactory   = shift;
    my $outputProtocolFactory  = shift;

    my $self = {
        processor              => $processor,
        serverTransport        => $serverTransport,
        inputTransportFactory  => $inputTransportFactory,
        outputTransportFactory => $outputTransportFactory,
        inputProtocolFactory   => $inputProtocolFactory,
        outputProtocolFactory  => $outputProtocolFactory,
    };
}

sub serve
{
    die "abstract";
}

sub _clientBegin
{
    my $self  = shift;
    my $iprot = shift;
    my $oprot = shift;

    if (exists  $self->{serverEventHandler} and
        defined $self->{serverEventHandler})
    {
        $self->{serverEventHandler}->clientBegin($iprot, $oprot);
    }
}

sub _handleException
{
    my $self = shift;
    my $e    = shift;

    if ($e =~ m/TException/ and exists $e->{message}) {
        my $message = $e->{message};
        my $code    = $e->{code};
        my $out     = $code . ':' . $message;

        $message =~ m/ElasticSearch::Transport::ThriftBackend::TTransportException/ and die $out;
        if ($message =~ m/TSocket/) {
            # suppress TSocket messages
        } else {
            warn $out;
        }
    } else {
        warn $e;
    }
}


#
# SimpleServer from the Server base class that handles one connection at a time
#
package ElasticSearch::Transport::ThriftBackend::Thrift::SimpleServer;
{
  $ElasticSearch::Transport::ThriftBackend::Thrift::SimpleServer::VERSION = '0.02';
}
use base qw( ElasticSearch::Transport::ThriftBackend::Thrift::Server );

sub new
{
    my $classname = shift;
    my @args      = @_;

    my $self      = $classname->SUPER::new(@args);
    return bless($self,$classname);
}

sub serve
{
    my $self = shift;

    $self->{serverTransport}->listen();
    while (1)
    {
        my $client = $self->{serverTransport}->accept();
        my $itrans = $self->{inputTransportFactory}->getTransport($client);
        my $otrans = $self->{outputTransportFactory}->getTransport($client);
        my $iprot  = $self->{inputProtocolFactory}->getProtocol($itrans);
        my $oprot  = $self->{outputProtocolFactory}->getProtocol($otrans);
        eval {
            $self->_clientBegin($iprot, $oprot);
            while (1)
            {
                $self->{processor}->process($iprot, $oprot);
            }
        }; if($@) {
            $self->_handleException($@);
        }

        $itrans->close();
        $otrans->close();
    }
}


#
# ForkingServer that forks a new process for each request
#
package ElasticSearch::Transport::ThriftBackend::Thrift::ForkingServer;
{
  $ElasticSearch::Transport::ThriftBackend::Thrift::ForkingServer::VERSION = '0.02';
}
use base qw( ElasticSearch::Transport::ThriftBackend::Thrift::Server );

use POSIX ":sys_wait_h";

sub new
{
    my $classname = shift;
    my @args      = @_;

    my $self      = $classname->SUPER::new(@args);
    return bless($self,$classname);
}


sub serve
{
    my $self = shift;

    $self->{serverTransport}->listen();
    while (1)
    {
        my $client = $self->{serverTransport}->accept();
        $self->_client($client);
    }
}

sub _client
{
    my $self   = shift;
    my $client = shift;

    eval {
        my $itrans = $self->{inputTransportFactory}->getTransport($client);
        my $otrans = $self->{outputTransportFactory}->getTransport($client);

        my $iprot  = $self->{inputProtocolFactory}->getProtocol($itrans);
        my $oprot  = $self->{outputProtocolFactory}->getProtocol($otrans);

        $self->_clientBegin($iprot, $oprot);

        my $pid = fork();

        if ($pid) #parent
        {
            $self->_parent($pid, $itrans, $otrans);
        } else {
            $self->_child($itrans, $otrans, $iprot, $oprot);
        }
    }; if($@) {
        $self->_handleException($@);
    }
}

sub _parent
{
    my $self   = shift;
    my $pid    = shift;
    my $itrans = shift;
    my $otrans = shift;

    # add before collect, otherwise you race w/ waitpid
    $self->{children}->{$pid} = 1;
    $self->_collectChildren();

    # Parent must close socket or the connection may not get closed promptly
    $self->tryClose($itrans);
    $self->tryClose($otrans);
}

sub _child
{
    my $self   = shift;
    my $itrans = shift;
    my $otrans = shift;
    my $iprot  = shift;
    my $oprot  = shift;

    my $ecode = 0;
    eval {
        while (1)
        {
            $self->{processor}->process($iprot, $oprot);
        }
    }; if($@) {
        $ecode = 1;
        $self->_handleException($@);
    }

    $self->tryClose($itrans);
    $self->tryClose($otrans);

    exit($ecode);
}

sub tryClose
{
    my $self = shift;
    my $file = shift;

    eval {
        if (defined $file)
        {
          $file->close();
        }
    }; if($@) {
        if ($@ =~ m/TException/ and exists $@->{message}) {
            my $message = $@->{message};
            my $code    = $@->{code};
            my $out     = $code . ':' . $message;

            warn $out;
        } else {
            warn $@;
        }
    }
}

sub _collectChildren
{
    my $self = shift;

    while (scalar keys %{$self->{children}})
    {
        my $pid    = waitpid(-1, WNOHANG);

        if ($pid>0)
        {
            delete $self->{children}->{$pid};
        }
        else
        {
            last;
        }
    }
}


1;

__END__
=pod

=head1 NAME

ElasticSearch::Transport::ThriftBackend::Thrift::Server

=head1 VERSION

version 0.02

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Clinton Gormley.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
