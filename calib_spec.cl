#
#Version: 0.2   11jun08
#Version: 0.3   11jul13 - Debuged some errors...
#

procedure calib_spec

bool   biascomb = yes        {prompt="Combine bias (filenames '*bias*.fits')?"}
string flatpfx1 = "flat_a1"  {prompt="Prefix 1 of flat filenames to be combined (WITHOUT '_')"}
string flatpfx2 = "flat_v1"  {prompt="Prefix 2 of flat filenames to be combined (WITHOUT '_')"}
string flatpfx3 = "flat_a2"  {prompt="Prefix 3 of flat filenames to be combined (WITHOUT '_')"}
string flatpfx4 = "flat_v2"  {prompt="Prefix 4 of flat filenames to be combined (WITHOUT '_')"}
real    rdnoise = 2.5        {prompt="ReadNoise (e-) to be used"}
real       gain = 2.5        {prompt="Gain to be used"}
bool     verify = yes        {prompt="* Stop script if no bias images are found?",mode="q"}

struct *fstruct

begin

#CCD 105 at OPD
#rdnoise = 2.5
#gain = 2.5
#real rdnoise, gain

string ftemp, fname, lixo


if(flatpfx1==" " || flatpfx1=="  ")
  flatpfx1=""
if(flatpfx2==" " || flatpfx2=="  ")
  flatpfx2=""
if(flatpfx3==" " || flatpfx3=="  ")
  flatpfx3=""
if(flatpfx4==" " || flatpfx4=="  ")
  flatpfx4=""

#Clean the routines parameters
unlearn flatcombine
unlearn ccdproc
ccdproc.ccdtype = ""
ccdproc.fixpix = no
ccdproc.overscan = no
ccdproc.trim = no
ccdproc.flatcor = no
ccdproc.darkcor = no
ccdproc.zero = "avg_bias.fits"

#Combine bias images	
if (biascomb) {
  print("# Combining bias images...")

  ftemp = mktemp("ftemp")
  files("*bias*.fits", > ftemp)
  unlearn zerocombine
#  if (access ("avg_bias.fits"))
#    imdel ("avg_bias.fits", verify=no)
  zerocombine ("@"//ftemp, output="avg_bias", ccdtype="")
  delete (ftemp, ver-, >& "dev$null")
}
else {
  ccdproc.zerocor = no
  print ("# NO BIAS IMAGES FOUND!")
  if (verify) {
    delete (ftemp, ver-, >& "dev$null")
    fstruct = ""
    }
}

#Combine flat 1 images 
if (flatpfx1 != "") {

  ftemp = mktemp("ftemp")
  files(flatpfx1//"_*.fits", > ftemp)
  fstruct = ftemp
  if (fscan(fstruct, fname) != EOF) {
    print("# Combining "//flatpfx1//" images...")
  
#    if (access ("combflatobj.fits"))
#      imdel ("combflatobj.fits", verify=no)
    flatcombine ("@"//ftemp, output="avg_"//flatpfx1, ccdtype="", subsets = no, scale="mean")
  delete (ftemp, ver-, >& "dev$null")

  boxcar ("avg_"//flatpfx1, "norm_"//flatpfx1, 10, 10, boundary="nearest", constant=0.)
  imarith ("avg_"//flatpfx1,"/","norm_"//flatpfx1, "norm_"//flatpfx1, title="", divzero=0.,hparams="",pixtype="", calctype="", verbose=no, noact=no)
  }
}

#Combine flat 2 images 
if (flatpfx2 != "") {

  ftemp = mktemp("ftemp")
  files(flatpfx2//"_*.fits", > ftemp)
  fstruct = ftemp
  if (fscan(fstruct, fname) != EOF) {
    print("# Combining "//flatpfx2//" images...")
  
#    if (access ("combflatobj.fits"))
#      imdel ("combflatobj.fits", verify=no)
    flatcombine ("@"//ftemp, output="avg_"//flatpfx2, ccdtype="", subsets = no, scale="mean")
  delete (ftemp, ver-, >& "dev$null")

  boxcar ("avg_"//flatpfx2, "norm_"//flatpfx2, 10, 10, boundary="nearest", constant=0.)
  imarith ("avg_"//flatpfx2,"/","norm_"//flatpfx2, "norm_"//flatpfx2, title="", divzero=0.,hparams="",pixtype="", calctype="", verbose=no, noact=no)
  }
}

#Combine flat 3 images 
if (flatpfx3 != "") {

  ftemp = mktemp("ftemp")
  files(flatpfx3//"_*.fits", > ftemp)
  fstruct = ftemp
  if (fscan(fstruct, fname) != EOF) {
    print("# Combining "//flatpfx3//" images...")
  
#    if (access ("combflatobj.fits"))
#      imdel ("combflatobj.fits", verify=no)
    flatcombine ("@"//ftemp, output="avg_"//flatpfx3, ccdtype="", subsets = no, scale="mean")
  delete (ftemp, ver-, >& "dev$null")

  boxcar ("avg_"//flatpfx3, "norm_"//flatpfx3, 10, 10, boundary="nearest", constant=0.)
  imarith ("avg_"//flatpfx3,"/","norm_"//flatpfx3, "norm_"//flatpfx3, title="", divzero=0.,hparams="",pixtype="", calctype="", verbose=no, noact=no)
  }
}

#Combine flat 4 images 
if (flatpfx4 != "") {

  ftemp = mktemp("ftemp")
  files(flatpfx4//"_*.fits", > ftemp)
  fstruct = ftemp
  if (fscan(fstruct, fname) != EOF) {
    print("# Combining "//flatpfx4//" images...")
  
#    if (access ("combflatobj.fits"))
#      imdel ("combflatobj.fits", verify=no)
    flatcombine ("@"//ftemp, output="avg_"//flatpfx4, ccdtype="", subsets = no, scale="mean")
  delete (ftemp, ver-, >& "dev$null")

  boxcar ("avg_"//flatpfx4, "norm_"//flatpfx4, 10, 10, boundary="nearest", constant=0.)
  imarith ("avg_"//flatpfx4,"/","norm_"//flatpfx4, "norm_"//flatpfx4, title="", divzero=0.,hparams="",pixtype="", calctype="", verbose=no, noact=no)
  }
}

fstruct = ""

end

