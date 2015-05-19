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
unlearn zerocombine
flatcombine.delete=yes
unlearn ccdproc
ccdproc.ccdtype = ""
ccdproc.fixpix = no
ccdproc.overscan = no
ccdproc.trim = no
ccdproc.flatcor = no
ccdproc.darkcor = no
#ccdproc.trim=yes
#ccdproc.trimsec="[226:325,201:300]"

delete(read3Dfits.prefix//"*", ver-, >& "dev$null")


#Combine bias or inform "no bias correction" to ccdproc
ftemp = mktemp("ftemp")
if (suf == "") 
  files("bias_[0-9]*.fits", > ftemp)
else 
  files("bias"//suf//"_[0-9]*.fits", > ftemp)
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  read3Dfits(fname)
  while(fscan(fstruct, fname) != EOF)
    read3Dfits(fname)
  delete("avg_bias"//suf//".fits", ver-, >& "dev$null" )
  zerocombine(read3Dfits.prefix//"*", output="avg_bias"//suf//".fits", ccdtype="", delete=yes)
  ccdproc.zero = "avg_bias"//suf//".fits"
}
else {
  ccdproc.zerocor = no
  print ("# NO BIAS IMAGES FOUND!")
  if (verify)
    fstruct = ""
}
delete (ftemp, ver-, >& "dev$null")


#Combine flats
ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_u_[0-9]*.fits", > ftemp)
else {
  files("flat"//suf//"_u_[0-9]*.fits", > ftemp)
  files("flat_u"//suf//"_[0-9]*.fits", >> ftemp)
}
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  read3Dfits(fname)
  while(fscan(fstruct, fname) != EOF)
    read3Dfits(fname)
 delete("avg_flat_u"//suf//".fits", ver-, >& "dev$null" )
  flatcombine(read3Dfits.prefix//"*", output="avg_flat_u"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mode")
}
delete (ftemp, ver-, >& "dev$null")


ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_b_0*.fits", > ftemp)
else {
  files("flat"//suf//"_b_0*.fits", > ftemp)
  files("flat_b"//suf//"_[0-9]*.fits", >> ftemp)
}
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  read3Dfits(fname)
  while(fscan(fstruct, fname) != EOF)
    read3Dfits(fname)
 delete("avg_flat_b"//suf//".fits", ver-, >& "dev$null" )
  flatcombine (read3Dfits.prefix//"*", output="avg_flat_b"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mode")
}
delete (ftemp, ver-, >& "dev$null")


ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_v_0*.fits", > ftemp)
else {
  files("flat"//suf//"_v_0*.fits", > ftemp)
  files("flat_v"//suf//"_[0-9]*.fits", >> ftemp)
}
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  read3Dfits(fname)
  while(fscan(fstruct, fname) != EOF)
    read3Dfits(fname)
 delete("avg_flat_v"//suf//".fits", ver-, >& "dev$null" )
  flatcombine (read3Dfits.prefix//"*", output="avg_flat_v"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mode")
}
delete (ftemp, ver-, >& "dev$null")


ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_r_0*.fits", > ftemp)
else {
  files("flat"//suf//"_r_0*.fits", > ftemp)
  files("flat_r"//suf//"_[0-9]*.fits", >> ftemp)
}
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  read3Dfits(fname)
  while(fscan(fstruct, fname) != EOF)
    read3Dfits(fname)
 delete("avg_flat_r"//suf//".fits", ver-, >& "dev$null" )
  flatcombine (read3Dfits.prefix//"*", output="avg_flat_r"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mode")
}
delete (ftemp, ver-, >& "dev$null")


ftemp = mktemp("ftemp")
if (suf == "") 
  files("flat_i_0*.fits", > ftemp)
else {
  files("flat"//suf//"_i_0*.fits", > ftemp)
  files("flat_i"//suf//"_[0-9]*.fits", >> ftemp)
}
fstruct = ftemp
if (fscan(fstruct, fname) != EOF) {
  read3Dfits(fname)
  while(fscan(fstruct, fname) != EOF)
    read3Dfits(fname)
 delete("avg_flat_i"//suf//".fits", ver-, >& "dev$null" )
  flatcombine (read3Dfits.prefix//"*", output="avg_flat_i"//suf//".fits", ccdtype="", subsets=no, delete=yes, scale="mode")
}
delete (ftemp, ver-, >& "dev$null")


fstruct = ""

end
