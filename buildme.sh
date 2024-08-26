R=/usr/share/bdf2psf/
F=/usr/share/bdf2psf/fontsets/
E=${R}standard.equivalents
E=$E+${R}arabic.equivalents

M=${R}ascii.set
M=$M+${R}useful.set

S=${R}ascii.set
#S=$S+${R}useful.set
S=$S+${R}linux.set
#S=$S+${F}Uni1.512
#S=$S+${F}Uni2.512
#S=$S+${F}Uni3.512
S=$S+${F}Lat15.256
S=$S+${F}Lat2.256
#S=$S+${F}Lat38.256
S=$S+${F}Lat7.256
S=$S+${F}Greek.256
#S=$S+${F}CyrSlav.256
S=$S+${F}CyrKoi.256
#S=$S+${F}CyrAsia.256
#S=$S+${F}Arabic.512
#S=$S+${F}Hebrew.256
#S=$S+${F}Thai.256
#S=$S+${F}Vietnamese.512
#S=$S+${F}Ethiopian.512
#S=$S+${F}Armenian.256
#S=$S+${F}Lao.256
#S=$S+${F}Georgian.256
S=$S+${R}freebsd.set

set -x
set -e
set -o pipefail

rm -rf fixed-15x30n fixed-15x30b

perl txtbdf.pl <fixed-15x30n.txt >fixed-15x30n.bdf
mkdir -p fixed-15x30n
perl bdfxbm.pl fixed-15x30n <fixed-15x30n.bdf
bdf2psf --fb fixed-15x30n.bdf ofw.equivalents ofw.set 256 fixed-15x30n-256.psf
bdf2psf --fb fixed-15x30n.bdf $E $S 512 fixed-15x30n.psf

perl txtbdf.pl <fixed-15x30b.txt >fixed-15x30b.bdf
mkdir -p fixed-15x30b
perl bdfxbm.pl fixed-15x30b <fixed-15x30b.bdf
bdf2psf --fb fixed-15x30b.bdf ofw.equivalents ofw.set 256 fixed-15x30b-256.psf
bdf2psf --fb fixed-15x30b.bdf $E $S 512 fixed-15x30b.psf
