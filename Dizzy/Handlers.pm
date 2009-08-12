package Dizzy::Handlers;

use strict;
use warnings;

my %handlers;

sub GO_ON()    { 1; }
sub STOP()     { 0; }

sub invoke {
	my ($name, @args) = @_;
	my $ret;
	foreach my $handler (@{$handlers{$name}}) {
		$ret = $handler->(@args);
		last if ($ret == STOP);
	}
}

sub register {
	while (my ($name, $code) = splice(@_, 0, 2)) {
		push(@{$handlers{$name}}, $code);
	}
}

1;
