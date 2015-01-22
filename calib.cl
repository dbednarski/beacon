#
#Ver 0.5, 13jul26
#
procedure calib

string suf ="_f"	{prompt="Suffix to be applied to ALL the calib images"}
bool   verify = yes	{prompt="* Stop script if no bias images are found?",mode="q"}

struct *fstruct
#struct *flist1      {prompt="ignore (2 digit number) followed by the list of"}
#struct line1

begin

string ftemp, fname, lixo

if(suf==" " || suf=="  ")
  suf=""

#Clean the routines parameters
unlearn flatcombine
flatcombine.delete=yes
unlearn ccdproc
ccdproc.ccdtype = ""
ccdproc.fixpix = no
ccdproc.overscan = no
ccdproc.trim = no
ccdproc.flatcor = no
ccdproc.darkcor = no
ccdproc.zero = "avg_bias"//suf//".fits"

#Combine bias or inform "no bias correction" to ccdproc
ftemp = mktemp("ftemp")
if (suf == "") 
  files("bias_0*.fits", > ftemp)
else 
  files("bias"//suf//"_0*.fits", > ftemp)
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  lixo = fscan(fstruct, fname) 
  read3Dfits (fname)
  unlearn zerocombine
  zerocombine (read3Dfits.prefix//"bias"//suf//"_0*", output="avg_bias"//suf//".fits", ccdtype="", delete=yes)
}
else {
  ccdproc.zerocor = no
  print ("# NO BIAS IMAGES FOUND!")
  if (verify) {
    delete (ftemp, ver-, >& "dev$null")
    fstruct = ""
    }
}
delete (ftemp, ver-, >& "dev$null")

#Combine flats
ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_u_0*.fits", > ftemp)
else
  files("flat"//suf//"_u_0*.fits", > ftemp)
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  lixo = fscan(fstruct, fname) 
  read3Dfits (fname)
  flatcombine (read3Dfits.prefix//"flat"//suf//"_u_0*", output="avg_flat_u"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mean")
}
delete (ftemp, ver-, >& "dev$null")

ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_b_0*.fits", > ftemp)
else
  files("flat"//suf//"_b_0*.fits", > ftemp)
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  lixo = fscan(fstruct, fname) 
  read3Dfits (fname)
  flatcombine (read3Dfits.prefix//"flat"//suf//"_b_0*", output="avg_flat_b"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mean")
}
delete (ftemp, ver-, >& "dev$null")

ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_v_0*.fits", > ftemp)
else
  files("flat"//suf//"_v_0*.fits", > ftemp)
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  lixo = fscan(fstruct, fname) 
  read3Dfits (fname)
  flatcombine (read3Dfits.prefix//"flat"//suf//"_v_0*", output="avg_flat_v"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mean")
}
delete (ftemp, ver-, >& "dev$null")

ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_r_0*.fits", > ftemp)
else
  files("flat"//suf//"_r_0*.fits", > ftemp)
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  lixo = fscan(fstruct, fname) 
  read3Dfits (fname)
  flatcombine (read3Dfits.prefix//"flat"//suf//"_r_0*", output="avg_flat_r"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mean")
}
delete (ftemp, ver-, >& "dev$null")

ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_i_0*.fits", > ftemp)
else
  files("flat"//suf//"_i_0*.fits", > ftemp)
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  lixo = fscan(fstruct, fname) 
  read3Dfits (fname)
  flatcombine (read3Dfits.prefix//"flat"//suf//"_i_0*", output="avg_flat_i"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mean")
}
delete (ftemp, ver-, >& "dev$null")

fstruct = ""

end
