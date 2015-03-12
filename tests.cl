#
#Version: 0.1   Modified by D. Moser in 2015-01-12
#

procedure tests

bool   biascomb = yes       {prompt="Combine bias (filenames '*bias*.fits')?"}
bool   flatccd  = no        {prompt="Use CCD flat only ('*flat*.fits')? Suffixes ignored"}
string flatpfx1 = "_a1"      {prompt="Suffix 1 of lamp files to be combined (WITHOUT '_') at end"}
string flatpfx2 = "_v1"      {prompt="Suffix 2 of lamp files to be combined (WITHOUT '_') at end"}
string flatpfx3 = "_a2"      {prompt="Suffix 3 of lamp files to be combined (WITHOUT '_') at end"}
string flatpfx4 = "_v2"      {prompt="Suffix 4 of lamp files to be combined (WITHOUT '_') at end"}
real    rdnoise = 0.9       {prompt="ReadNoise (e-) to be used"}
real       gain = 6.66      {prompt="Gain to be used"}
bool     verify = yes       {prompt="* Stop script if no bias images are found?",mode="q"}

struct *fstruct, fstruct2

begin

string ftemp, fname, fname2, lixo, refflat
bool flatcor

print("beacon")
copy("beacon$*par", ".", ver+)

end
