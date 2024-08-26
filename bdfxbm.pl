use strict;
use warnings;

# Render the fonts for quick check/preview

my $dir = shift @ARGV;
my $wid = 32;
#system "rm -rf $dir; mkdir $dir";

sub inf
{
	my $if = shift;

	my ($w, $h);

	my @g;
	my $c;
	my @l;
	while (<$if>) {
		chomp;
		if (/^FONTBOUNDINGBOX\s+(\d+)\s+(\d+)\s+/) {
			($w, $h) = ($1, $2);
			next;
		} elsif (/^STARTCHAR\s+(\S+)$/) {
			die unless defined $w;
			die unless defined $h;
			$c = $1;
			#warn "glyph '$c'";
		} elsif (/^ENDCHAR$/) {
			die unless defined $c;
			push @g, {
				name => $c,
				lines => [ @l ],
			};
			undef $c;
			@l = ();
		} elsif (/^[a-fA-F0-9]+$/) {
			push @l, hex $_;
		}
	}

	return ($w, $h, @g);
}

sub outf
{
	my $of = shift;
	my $wid = shift;
	my $w = shift;
	my $h = shift;
	my @g = @_;

	printf $of "#define psf_width %d\n", $w * $wid;
	printf $of "#define psf_height %d\n", $h * int ((scalar @g + $wid - 1) / $wid);
	printf $of "static unsigned char psf_bits[] = {\n";

	sub revb { ord pack 'b8', sprintf '%08b', (shift @_ & 0xff) }


	my $ls = 0;
	my $ln = 0;

	while (exists $g[$ls]) {
		for my $l (0..$h-1) {
			my $bits = 0;
			my $cur = 0;
			for my $o (0..$wid-1) {
				$cur <<= $w;
				if (exists $g[$o+$ls]) {
					$cur |= $g[$o+$ls]{lines}[$l] >> 8 - $w % 8;
				}
				$bits += $w;
				while ($bits >= 8) {
					$bits -= 8;
					printf $of '0x%02x, ', revb($cur >> $bits);
				}
			}
			printf $of '0x%02x, ', revb($cur << 8 - $bits) if $bits;
			print $of "\n";
		}
		$ls += $wid;
	}

	print $of "};\n";
}

# Read input
my ($w, $h, @g) = inf \*STDIN;

# Produce large picture
if ($dir) {
	open my $bg, ">$dir/font.xbm" or die "$dir: $!";
	outf $bg, $wid, $w, $h, @g;
} else {
	outf \*STDOUT, $wid, $w, $h, @g;
	exit 0;
}

# Produce HTML
my $i = 0;
open my $ht, ">$dir/index.html" or die $!;
print $ht <<EOF;
<head>
<style>
	table, td, th, tr {
		border: 0px;
		margin: 0px;
		padding: 0px;
		border-spacing: 0px;
	}
	table td {
		//border: 1px solid #f0f0f0;
	}
	table {
		border: 1px solid black;
		padding: .5em;
		margin: .5em;
	}
</style>
</head>

<h2>Full character dump</h2>

<table class="big">
EOF
foreach my $g (@g) {
	my $n = sprintf '%04d-%s', $i, $g->{name};
	print $ht "\n<tr>" if $i % $wid == 0;
	unless (-f "$dir/$n.xbm") {
		open my $f, ">$dir/$n.xbm" or die "$n: $!";
		outf $f, 1, $w, $h, $g;
		undef $f;
	}
	unless (-f "$dir/$n.png") {
		system "magick -quiet $dir/$n.xbm $dir/$n.png"
			and system "convert -quiet $dir/$n.xbm $dir/$n.png";
	}
	print $ht "<td><img src='$n.png' title='$g->{name}'></td>";
	print $ht "</tr>" if ($i + 1) % $wid == 0;
	$i++;
}
print $ht "</table>";

print $ht <<EOF;

<h2>Drawing continuity checks</h2>

<table>
<tr>
<td><img src="0914-SF010000.png" title="0914-SF010000"></td>
<td><img src="0946-SF060000.png" title="0946-SF060000"></td>
<td><img src="0906-SF100000.png" title="0906-SF100000"></td>
<td><img src="0948-uni252E.png" title="0948-uni252E"></td>
<td><img src="0907-uni2501.png" title="0907-uni2501"></td>
<td><img src="0947-uni252D.png" title="0947-uni252D"></td>
<td><img src="0999-SF480000.png" title="0999-SF480000"></td>
<td><img src="0918-SF030000.png" title="0918-SF030000"></td>
</tr>
<tr>
<td><img src="0930-SF080000.png" title="0930-SF080000"></td>
<td><img src="0962-SF050000.png" title="0962-SF050000"></td>
<td><img src="1022-uni257C.png" title="1022-uni257C"></td>
<td><img src="0939-uni2525.png" title="0939-uni2525"></td>
<td><img src="0980-SF510000.png" title="0980-SF510000"></td>
<td><img src="1004-SF540000.png" title="1004-SF540000"></td>
<td><img src="1006-SF440000.png" title="1006-SF440000"></td>
<td><img src="0995-SF190000.png" title="0995-SF190000"></td>
</tr>
<tr>
<td><img src="0992-SF360000.png" title="0992-SF360000"></td>
<td><img src="1001-SF450000.png" title="1001-SF450000"></td>
<td><img src="0998-SF470000.png" title="0998-SF470000"></td>
<td><img src="1001-SF450000.png" title="1001-SF450000"></td>
<td><img src="0995-SF190000.png" title="0995-SF190000"></td>
<td><img src="0922-SF020000.png" title="0922-SF020000"></td>
<td><img src="1002-SF460000.png" title="1002-SF460000"></td>
<td><img src="0926-SF040000.png" title="0926-SF040000"></td>
</tr>

<tr>
<td><img src="0933-uni251F.png" title="0933-uni251F"></td>
<td><img src="0948-uni252E.png" title="0948-uni252E"></td>
<td><img src="0955-uni2535.png" title="0955-uni2535"></td>
<td><img src="0950-uni2530.png" title="0950-uni2530"></td>
<td><img src="0941-uni2527.png" title="0941-uni2527"></td>
<td><img src="0982-SF390000.png" title="0982-SF390000"></td>
<td><img src="0978-SF430000.png" title="0978-SF430000"></td>
<td><img src="0985-SF250000.png" title="0985-SF250000"></td>
</tr>

<tr>
<td><img src="0937-uni2523.png" title="0937-uni2523"></td>
<td><img src="0971-uni2545.png" title="0971-uni2545"></td>
<td><img src="0948-uni252E.png" title="0948-uni252E"></td>
<td><img src="0977-uni254B.png" title="0977-uni254B"></td>
<td><img src="0943-uni2529.png" title="0943-uni2529"></td>
<td><img src="0988-SF380000.png" title="0988-SF380000"></td>
<td><img src="0998-SF470000.png" title="0998-SF470000"></td>
<td><img src="0991-SF260000.png" title="0991-SF260000"></td>
</tr>

<tr>
<td><img src="0925-uni2517.png" title="0925-uni2517"></td>
<td><img src="0929-uni251B.png" title="0929-uni251B"></td>
<td><img src="0923-uni2515.png" title="0923-uni2515"></td>
<td><img src="0961-uni253B.png" title="0961-uni253B"></td>
<td><img src="0927-uni2519.png" title="0927-uni2519"></td>
<td><img src="0981-SF520000.png" title="0981-SF520000"></td>
<td><img src="0954-SF070000.png" title="0954-SF070000"></td>
<td><img src="0984-SF210000.png" title="0984-SF210000"></td>
</tr>

<tr>
<td><img src="0915-uni250D.png" title="0915-uni250D"></td>
<td><img src="0953-uni2533.png" title="0953-uni2533"></td>
<td><img src="0947-uni252D.png" title="0947-uni252D"></td>
<td><img src="0952-uni2532.png" title="0952-uni2532"></td>
<td><img src="1024-uni257E.png" title="1024-uni257E"></td>
<td><img src="0996-SF200000.png" title="0996-SF200000"></td>
<td><img src="0916-uni250E.png" title="0916-uni250E"></td>
<td><img src="0996-SF200000.png" title="0996-SF200000"></td>
</tr>

<tr>
<td><img src="1023-uni257D.png" title="1023-uni257D"></td>
<td><img src="1025-uni257F.png" title="1025-uni257F"></td>
<td><img src="1010-uni2570.png" title="1010-uni2570"></td>
<td><img src="0940-uni2526.png" title="0940-uni2526"></td>
<td><img src="1007-uni256D.png" title="1007-uni256D"></td>
<td><img src="1005-SF530000.png" title="1005-SF530000"></td>
<td><img src="0966-uni2540.png" title="0966-uni2540"></td>
<td><img src="0990-SF270000.png" title="0990-SF270000"></td>
</tr>

<tr>
<td><img src="0924-uni2516.png" title="0924-uni2516"></td>
<td><img src="1009-uni256F.png" title="1009-uni256F"></td>
<td><img src="1016-uni2576.png" title="1016-uni2576"></td>
<td><img src="0954-SF070000.png" title="0954-SF070000"></td>
<td><img src="0954-SF070000.png" title="0954-SF070000"></td>
<td><img src="1002-SF460000.png" title="1002-SF460000"></td>
<td><img src="1009-uni256F.png" title="1009-uni256F"></td>
<td><img src="1017-uni2577.png" title="1017-uni2577"></td>
</tr>

<tr>
<td><img src="1020-uni257A.png" title="1020-uni257A"></td>
<td><img src="0907-uni2501.png" title="0907-uni2501"></td>
<td><img src="0953-uni2533.png" title="0953-uni2533"></td>
<td><img src="0921-uni2513.png" title="0921-uni2513"></td>
<td><img src="0917-uni250F.png" title="0917-uni250F"></td>
<td><img src="0949-uni252F.png" title="0949-uni252F"></td>
<td><img src="1018-uni2578.png" title="1018-uni2578"></td>
<td><img src="1015-uni2575.png" title="1015-uni2575"></td>
</tr>

<tr>
<td><img src="0981-SF520000.png" title="0981-SF520000"></td>
<td><img src="0984-SF210000.png" title="0984-SF210000"></td>
<td><img src="0934-uni2520.png" title="0934-uni2520"></td>
<td><img src="0968-uni2542.png" title="0968-uni2542"></td>
<td><img src="0960-uni253A.png" title="0960-uni253A"></td>
<td><img src="0963-uni253D.png" title="0963-uni253D"></td>
<td><img src="0999-SF480000.png" title="0999-SF480000"></td>
<td><img src="0920-uni2512.png" title="0920-uni2512"></td>
</tr>

<tr>
<td><img src="1003-SF400000.png" title="1003-SF400000"></td>
<td><img src="0991-SF260000.png" title="0991-SF260000"></td>
<td><img src="0934-uni2520.png" title="0934-uni2520"></td>
<td><img src="0940-uni2526.png" title="0940-uni2526"></td>
<td><img src="1020-uni257A.png" title="1020-uni257A"></td>
<td><img src="0944-uni252A.png" title="0944-uni252A"></td>
<td><img src="0979-SF240000.png" title="0979-SF240000"></td>
<td><img src="0913-uni250B.png" title="0913-uni250B"></td>
</tr>

<tr>
<td><img src="1020-uni257A.png" title="1020-uni257A"></td>
<td><img src="0911-uni2509.png" title="0911-uni2509"></td>
<td><img src="1024-uni257E.png" title="1024-uni257E"></td>
<td><img src="0910-uni2508.png" title="0910-uni2508"></td>
<td><img src="1014-uni2574.png" title="1014-uni2574"></td>
<td><img src="0924-uni2516.png" title="0924-uni2516"></td>
<td><img src="0990-SF270000.png" title="0990-SF270000"></td>
<td><img src="1019-uni2579.png" title="1019-uni2579"></td>
</tr>
</table>

<table>
<tr>
<td><img src="0875-uni239B.png" title="0875-uni239B"></td>
<td><img src="0878-uni239E.png" title="0878-uni239E"></td>
<td><img src="0887-uni23A7.png" title="0887-uni23A7"></td>
<td><img src="0890-uni23AB.png" title="0890-uni23AB"></td>
<td><img src="0881-uni23A1.png" title="0881-uni23A1"></td>
<td><img src="0884-uni23A4.png" title="0884-uni23A4"></td>
</tr>

<tr>
<td><img src="0876-uni239C.png" title="0876-uni239C"></td>
<td><img src="0879-uni239F.png" title="0879-uni239F"></td>
<td><img src="0888-uni23A8.png" title="0888-uni23A8"></td>
<td><img src="0891-uni23AC.png" title="0891-uni23AC"></td>
<td><img src="0882-uni23A2.png" title="0882-uni23A2"></td>
<td><img src="0885-uni23A5.png" title="0885-uni23A5"></td>
</tr>

<tr>
<td><img src="0877-uni239D.png" title="0877-uni239D"></td>
<td><img src="0880-uni23A0.png" title="0880-uni23A0"></td>
<td><img src="0889-uni23A9.png" title="0889-uni23A9"></td>
<td><img src="0892-uni23AD.png" title="0892-uni23AD"></td>
<td><img src="0883-uni23A3.png" title="0883-uni23A3"></td>
<td><img src="0886-uni23A6.png" title="0886-uni23A6"></td>
</tr>
</table>
EOF
