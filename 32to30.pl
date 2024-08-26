#!/usr/bin/perl

# A hacky tool to bootstrap a 30px wide font from the 32px
# Needs manual fixing afterwards.

use strict;
use warnings;

#open my $f, '<new30.txt', or die $!;

sub bad()
{
print <<EOF;
# #-------------#
# #-------------#
# ##-----------##
# ##-----------##
# -##---------##-
# -##---------##-
# --##-------##--
# --##-------##--
# ---##-----##---
# ---##-----##---
# ----##---##----
# ----##---##----
# -----#####-----
# -----#####-----
# ------###------
# ------###------
# -----#####-----
# -----#####-----
# ----##---##----
# ----##---##----
# ---##-----##---
# ---##-----##---
# --##-------##--
# --##-------##--
# -##---------##-
# -##---------##-
# ##-----------##
# ##-----------##
# #-------------#
# #-------------#
EOF
}

sub prt
{
	my $cmt = shift;
	print map { "$cmt# $_\n" } @_;
}

sub col
{
	my $idx = shift;
	join '', map { substr $_, $idx, 1 } @_;
}

sub del
{
	my $idx = shift;
	#delete substr $_, $idx, 1 foreach @_;
	#return @_;
	map { substr ($_, 0, $idx) .  substr ($_, $idx+1) } @_;
}

my @bmp;
while (<>) {
	chomp;
	#warn ">>$_<<\n";

	if ($_ eq 'BITMAP') {
		die if @bmp;
	} elsif (/# ([-#]+)(\s+.*)?$/) {
		push @bmp, $1;
		die unless length $1 == 16;
		next;
	} elsif ($_ eq 'ENDCHAR') {

		if ($bmp[30] eq $bmp[31]) {
			#delete $bmp[31];
			pop @bmp;
		} elsif ($bmp[27] eq $bmp[26]) {
			splice(@bmp, 26, 1);
		}
		if ($bmp[0] eq $bmp[1]) {
			#delete $bmp[0];
			shift @bmp;
		}


		if (col(0,@bmp) eq col(14,@bmp) and col(14,@bmp) eq col(15,@bmp)) {
			@bmp = del(15,@bmp);
		} elsif (col(0,@bmp) eq col(1,@bmp)) {
			@bmp = del(0,@bmp);
		} elsif (col(6,@bmp) eq col(7,@bmp)) {
			@bmp = del(6,@bmp);
		} elsif (col(0,@bmp) eq col(15,@bmp)) {
			@bmp = del(15,@bmp);
		} elsif (col(14,@bmp) eq col(15,@bmp)) {
			@bmp = del(15,@bmp);
		} elsif (col(13,@bmp) eq col(14,@bmp)) {
			@bmp = del(13,@bmp);
		}



		if (scalar @bmp == 31
			and $bmp[27] eq '---------##----'
			and $bmp[28] eq '---------#####-'
			and $bmp[29] eq '----------####-'
		) {
			$bmp[27] = '---------###---';
			$bmp[28] = '----------####-';
			splice(@bmp,30,1);
		}
		if (scalar @bmp == 31
			and $bmp[27] eq '------##-------'
			and $bmp[28] eq '------#####----'
			and $bmp[29] eq '-------####----'
		) {
			$bmp[27] = '------###------';
			$bmp[28] = '-------####----';
			splice(@bmp,30,1);
		}
		if (scalar @bmp == 31
			and $bmp[26] eq '-------##------'
			and $bmp[27] eq '-------##------'
			and $bmp[28] eq '------###------'
			and $bmp[29] eq '------##-------'
			and $bmp[30] eq '-----##--------'

		) {
			splice(@bmp,28,1);
		}
		if (scalar @bmp == 31
			and $bmp[26] eq '--##-----------'
			and $bmp[27] eq '--##-----------'
			and $bmp[28] eq '-###-----------'
			and $bmp[29] eq '-##------------'
			and $bmp[30] eq '##-------------'

		) {
			splice(@bmp,28,1);
		}
		if (scalar @bmp == 31
			and $bmp[26] eq '----------##---'
			and $bmp[27] eq '----------##---'
			and $bmp[28] eq '---------###---'
			and $bmp[29] eq '---------##----'
			and $bmp[30] eq '--------##-----'

		) {
			splice(@bmp,28,1);
		}
		if (scalar @bmp == 31
			and $bmp[28] eq '---------####--'
			and $bmp[29] eq '---------###---'
			and $bmp[30] eq '---------------'
		) {
			splice(@bmp,29,1);
		}


		if (scalar @bmp == 31
			and $bmp[26] eq '--------####---'
			and $bmp[27] eq '--------###----'
			and $bmp[28] eq '--------######-'
			and $bmp[29] eq '---------#####-'
			and $bmp[30] eq '---------------'
		) {
			pop @bmp;
		}
		if (scalar @bmp == 31
			and $bmp[26] eq '-----####------'
			and $bmp[27] eq '-----###-------'
			and $bmp[28] eq '-----######----'
			and $bmp[29] eq '------#####----'
			and $bmp[30] eq '---------------'
		) {
			pop @bmp;
		}
		if (scalar @bmp == 31
			and $bmp[27] eq '------###------'
			and $bmp[28] eq '------###------'
			and $bmp[29] eq '-----###-------'
			and $bmp[30] eq '----###--------'
		) {
			splice(@bmp,28,1);
		}
		if (scalar @bmp == 31
			and $bmp[27] eq '--###----------'
			and $bmp[28] eq '--###----------'
			and $bmp[29] eq '-###-----------'
			and $bmp[30] eq '###------------'
		) {
			splice(@bmp,28,1);
		}
		if (scalar @bmp == 31
			and $bmp[27] eq '---------###---'
			and $bmp[28] eq '---------###---'
			and $bmp[29] eq '--------###----'
			and $bmp[30] eq '-------###-----'
		) {
			splice(@bmp,28,1);
		}



		if (scalar @bmp == 31 and $bmp[29] eq $bmp[30]) {
			pop @bmp;
		}
		if (scalar @bmp == 31 and $bmp[28] eq $bmp[29]) {
			splice(@bmp,29,1);
		}


		if (scalar @bmp == 31) {
			bad();
			#prt("//T ",@bmp);
			prt("//[".$bmp[27]."] ",@bmp);
		} elsif (scalar @bmp != 30) {
			bad();
			prt("//Y ",@bmp);
		} elsif (length $bmp[0] ne 15) {
			bad();
			prt("//X ",@bmp);
		} else {
			prt("",@bmp);
		}
		@bmp = ();
	}

	s/(FONT \S+)-32-320-72-72-C-160-(\S+)/$1-30-300-75-75-C-150-$2/;
	s/SIZE 32 72 72/SIZE 30 75 75/;
	s/FONTBOUNDINGBOX 16 32 0 -6/FONTBOUNDINGBOX 15 30 0 -7/;
	s/PIXEL_SIZE 32/PIXEL_SIZE 30/;
	s/POINT_SIZE 320/POINT_SIZE 300/;
	s/RESOLUTION_X 72/RESOLUTION_X 75/;
	s/RESOLUTION_Y 72/RESOLUTION_Y 75/;
	s/MIN_SPACE 16/MIN_SPACE 15/;
	s/DWIDTH 16 0/DWIDTH 15 0/;
	s/BBX 16 32 0 -6/BBX 15 30 0 -7/;
	s/AVERAGE_WIDTH 160/AVERAGE_WIDTH 150/;
	s/FONT_ASCENT 26/FONT_ASCENT 23/;
	s/FONT_DESCENT 6/FONT_DESCENT 7/;
	s/SWIDTH 500 0/SWIDTH 666 0/;

	print "$_\n";
}
