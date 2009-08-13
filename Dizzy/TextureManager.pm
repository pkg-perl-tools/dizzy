package Dizzy::TextureManager;

use strict;
use warnings;

use OpenGL::Simple qw(:all);
use Math::Trig;
use Time::HiRes qw(sleep time);
use Dizzy::TextureGenerator;
use Dizzy::GLUT;
use Dizzy::Handlers;

my @textures;
my $current_texture_id = 0;
my $previous_texture_id = 0;
my $texture_resolution = 0;

sub add {
	my %args = @_;
	push(@textures, \%args);
	$textures[$#textures]->{gl_texture} = Dizzy::TextureGenerator::new_from_func(
		function     => $textures[$#textures]->{function},
		resolution   => $texture_resolution,
	);
	delete($textures[$#textures]->{function});
	return $#textures;
}

sub set {
	my ($id) = @_;
	Dizzy::Handlers::invoke("texture_switch",
		gl_texture      => $textures[$id]->{gl_texture},
		old_gl_texture  => $textures[$previous_texture_id]->{gl_texture},
		_texman_new_id  => $id,
		_texman_old_id  => $current_texture_id,
	);
}

# -----------------------------------------------------------------------------
# some handlers

# transforms a texture walk request (such as one triggered by cursor keys) into
# something that we all understand: a renderable GL texture ID.
sub handler_walking {
	my %args = @_;

	if (exists($args{direction})) {
		# find out about the next texture
		my $id = $current_texture_id + $args{direction};
		$id += @textures;
		$id %= @textures;

		set($id);

		return Dizzy::Handlers::STOP;
	} else {
		return Dizzy::Handlers::GO_ON;
	}
}

# if this comes through, the texture was successfully changed
# (if not, texblend might have refused the change because it already is
# blending)
sub handler_switch {
	my %args = @_;

	$previous_texture_id = $args{_texman_old_id};
	$current_texture_id = $args{_texman_new_id};

	Dizzy::Handlers::invoke("texture_changed",
		name => $textures[$current_texture_id]->{name},
	);

	Dizzy::Handlers::STOP;
}

sub init {
	my %args = @_;

	$texture_resolution = $args{texture_resolution};

	Dizzy::Handlers::register(
		texture_switch => \&handler_walking,
	);
	Dizzy::Handlers::register_last(
		texture_switch => \&handler_switch,
	);
}

1;
