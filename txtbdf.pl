#!/usr/bin/perl -n

# This tool converts a BDF format and a human-editable
# text file and the other way around.

chomp;

if (/FONTBOUNDINGBOX\s+(\d+)\s+(\d+)\s+\S+\s+\S+$/) {
	($col, $row) = ($1, $2);
	$shift = ($col % 4) ? 4-($col % 4) : 0;
}

if (/^# ([\.\-#]+)(\s+.*)?/) {
	my $s = $1;
	die unless $col;
	die unless $col == length $s;
	$s =~ s/[\.\-]/0/g;
	$s =~ s/#/1/g;
	printf "%04x\n", (oct "0b$s") << $shift;
	next;
}

/^#/ and die ">>$_<<";
if (/^[0-9a-fA-F]{4,}$/) {
	die unless $col;
	my $s = sprintf "%0$col".'b', (hex $_) >> $shift;
	$s =~ s/0/-/g;
	$s =~ s/1/#/g;
	print "# $s ; $_\n";
	next;
}

print "$_\n";
