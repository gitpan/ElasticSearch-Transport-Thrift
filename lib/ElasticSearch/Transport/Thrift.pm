package ElasticSearch::Transport::Thrift;

use strict;
use warnings FATAL => 'all';
use ElasticSearch::Transport::ThriftBackend::Rest;
use ElasticSearch::Transport::ThriftBackend::Thrift;
use ElasticSearch::Transport::ThriftBackend::Thrift::Socket;
use ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransport;
use ElasticSearch::Transport::ThriftBackend::Thrift::BinaryProtocol;

our $VERSION = '0.03';

use Encode qw(decode_utf8);

use parent 'ElasticSearch::Transport';

my %Methods = (
    'GET'     => ElasticSearch::Transport::ThriftBackend::Method::GET,
    'PUT'     => ElasticSearch::Transport::ThriftBackend::Method::PUT,
    'POST'    => ElasticSearch::Transport::ThriftBackend::Method::POST,
    'DELETE'  => ElasticSearch::Transport::ThriftBackend::Method::DELETE,
    'HEAD'    => ElasticSearch::Transport::ThriftBackend::Method::HEAD,
    'OPTIONS' => ElasticSearch::Transport::ThriftBackend::Method::OPTIONS
);

#===================================
sub protocol     {'thrift'}
sub default_port {9500}
#===================================

#===================================
sub send_request {
#===================================
    my $self   = shift;
    my $server = shift;
    my $params = shift;

    my $method = $params->{method};
    $self->throw( 'Param', "Unknown thrift method '$method'" )
        unless exists $Methods{$method};

    my $request = ElasticSearch::Transport::ThriftBackend::RestRequest->new();
    $request->method( $Methods{$method} );
    $request->uri( $params->{cmd} );
    $request->parameters( $params->{qs} || {} );
    $request->body( encode_utf8( $params->{data} || '{}' ) );
    $request->headers( {} );

    my $response;
    eval {
        my $client = $self->client($server);
        $response = $client->execute($request);
    } or do {
        my $error = $@ || 'Unknown';
        if ( ref $error && $error->{message} ) {
            $self->throw( 'Timeout', $error->{message} )
                if $error->{message} =~ /TSocket: timed out/;
            $self->throw( 'Connection', $error->{message} );
        }
        $self->throw( 'Request', $error );
    };

    my $content = $response->body;
    $content = decode_utf8($content) if defined $content;

    my $code = $response->status;
    return $content if $code && $code >= 200 && $code <= 209;

    my $msg = $self->http_status($code);

    my $type = $self->code_to_error($code)
        || (
        $msg eq 'REQUEST_TIMEOUT' || $msg eq 'GATEWAY_TIMEOUT'
        ? 'Timeout'
        : 'Request'
        );
    my $error_params = {
        server      => $server,
        status_code => $code,
        status_msg  => $msg,
    };

    if ( $type eq 'Request' or $type eq 'Conflict' or $type eq 'Missing' ) {
        $error_params->{content} = $content;
    }
    $self->throw( $type, $msg . ' (' . $code . ')', $error_params );
}

#===================================
sub refresh_servers {
#===================================
    my $self = shift;
    $self->clear_clients;
    return $self->SUPER::refresh_servers;
}

#===================================
sub client {
#===================================
    my $self = shift;
    my $server = shift || '';
    if ( my $client = $self->{_client}{$$}{$server} ) {
        return $client if $client->{input}{trans}->isOpen;
    }

    $self->{_client} = { $$ => {} }
        unless $self->{_client}{$$};

    my ( $host, $port ) = ( $server =~ /^(.+):(\d+)$/ );
    $self->throw( 'Param', "Couldn't understand server '$server'" )
        unless $host && $port;

    my $socket
        = ElasticSearch::Transport::ThriftBackend::Thrift::Socket->new( $host,
        $port );

    my $timeout = ( $self->timeout || 10000 ) * 1000;
    $socket->setSendTimeout($timeout);
    $socket->setRecvTimeout($timeout);

    my $transport
        = ElasticSearch::Transport::ThriftBackend::Thrift::BufferedTransport
        ->new($socket);
    my $protocol
        = ElasticSearch::Transport::ThriftBackend::Thrift::BinaryProtocol
        ->new($transport);
    my $client = $self->{_client}{$$}{$server}
        = ElasticSearch::Transport::ThriftBackend::RestClient->new($protocol);

    $transport->open;

    return $client;
}

# ABSTRACT: A Thrift backend for ElasticSearch


__END__
=pod

=head1 NAME

ElasticSearch::Transport::Thrift - A Thrift backend for ElasticSearch

=head1 VERSION

version 0.03

=head1 SYNOPSIS

    use ElasticSearch;
    my $e = ElasticSearch->new(
        servers     => 'search.foo.com:9500',
        transport   => 'thrift',
        timeout     => '10',
    );

You need to have the C<transport-thrift> plugin installed on your
ElasticSearch server for this to work.

=head1 DESCRIPTION

ElasticSearch::Transport::Thrift uses the Thrift to talk to ElasticSearch
over sockets.

Although the C<thrift> interface has the right buzzwords (binary, compact,
sockets), the generated Perl code is very slow. Until that is improved, I
recommend one of the C<http> backends instead.

=head1 SEE ALSO

=over

=item * L<ElasticSearch>

=item * L<ElasticSearch::Transport>

=item * L<ElasticSearch::Transport::HTTP>

=item * L<ElasticSearch::Transport::HTTPLite>

=item * L<ElasticSearch::Transport::HTTPTiny>

=item * L<ElasticSearch::Transport::Curl>

=item * L<ElasticSearch::Transport::AEHTTP>

=item * L<ElasticSearch::Transport::AECurl>

=item * L<ElasticSearch::Transport::HTTPLite>

=back

1;

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Clinton Gormley.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

