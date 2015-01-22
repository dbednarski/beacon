#
#Ver 0.4, 12mai07
#
procedure reduce

string pref="tpyx" {prompt="Prefix of filenames (WITHOUT '_')"}
string suf ="_f"   {prompt="Suffix of filenames (same of calib. images)"}
bool  dov1 =yes    {prompt="Do the reduction without calibrations?"}
bool  dov2 =yes    {prompt="Do the reduction using the calib. images?"}
real ganho ="3.7"  {prompt="CCD gain to be used"}
real readno="2.19" {prompt="ReadNoise (ADUs) to be used"}

struct *fstruct

begin

string ftemp, fname, flatname
bool exist
int n

if(suf==" " || suf=="  ") {
  suf=""
}
#
##Configuring ccdrap = NOT USED!
#unlearn ccdrap
#ccdrap.apertur = "5:14:1"
#ccdrap.annulus = 40.
#ccdrap.dannulu = 15.
#ccdrap.reject = 65000
#ccdrap.stack1s = no
ccdrap.readnoise = readno
ccdrap.ganho = ganho
ccdrap.zero = "../calib/avg_bias"//suf//".fits"

#Running the 2 versions of reduction, filter by filter
#Filter U
if (dov1 == yes) {
  ftemp = mktemp("ftemp")
  files(pref//suf//"_u*.fits", > ftemp)
  fstruct = ftemp
  exist = no
  n = 0
  while (fscan(fstruct, fname) != EOF) {
    exist = yes
    n = n+1
  }
  if (exist == yes) {
    #read3Dfits (pref//suf//"_u*.fits")
    ccdrap(pref//suf//"_u", version=".1", zerocor=no, flatcor=no) 
    polrap(n=n)
  }
  delete (ftemp, ver-, >& "dev$null")
}

if (dov2 == yes) {
  if ( access(ccdrap.zero) || access("../calib/avg_flat_u"//suf//".fits") ) {
    ftemp = mktemp("ftemp")
    files(pref//suf//"_u*.fits", > ftemp)
    fstruct = ftemp 
    exist = no
    n = 0
    while (fscan(fstruct, fname) != EOF) {
      exist = yes
      n = n+1
    }
    if (exist == yes) {
      #read3Dfits (pref//suf//"_u*.fits")

      if (access(ccdrap.zero)) 
        ccdrap.zerocor=yes
      else
        ccdrap.zerocor=no
      flatname = "../calib/avg_flat_u"//suf//".fits"
      if (access(flatname)) 
        ccdrap.flatcor=yes
      else
        ccdrap.flatcor=no

      ccdrap(pref//suf//"_u", version=".2", flat=flatname)
      polrap(n=n)
    }
  }
  else
    print("CALIBRATION IMAGES NOT FOUND at folder '../calib', FILTER U!!!")

  delete (ftemp, ver-, >& "dev$null")
}

#Filter B
if (dov1 == yes) {
  ftemp = mktemp("ftemp")
  files(pref//suf//"_b*.fits", > ftemp)
  fstruct = ftemp
  exist = no
  n = 0
  while (fscan(fstruct, fname) != EOF) {
    exist = yes
    n = n+1
  }
  if (exist == yes) {
    #read3Dfits (pref//suf//"_b*.fits")
    ccdrap(pref//suf//"_b", version=".1", zerocor=no, flatcor=no) 
    polrap(n=n)
  }
  delete (ftemp, ver-, >& "dev$null")
}

if (dov2 == yes) {
  if ( access(ccdrap.zero) || access("../calib/avg_flat_b"//suf//".fits") ) {
    ftemp = mktemp("ftemp")
    files(pref//suf//"_b*.fits", > ftemp)
    fstruct = ftemp 
    exist = no
    n = 0
    while (fscan(fstruct, fname) != EOF) {
      exist = yes
      n = n+1
    }
    if (exist == yes) {
      #read3Dfits (pref//suf//"_b*.fits")

      if (access(ccdrap.zero)) 
        ccdrap.zerocor=yes
      else
        ccdrap.zerocor=no
      flatname = "../calib/avg_flat_b"//suf//".fits"
      if (access(flatname)) 
        ccdrap.flatcor=yes
      else
        ccdrap.flatcor=no

      ccdrap(pref//suf//"_b", version=".2", flat=flatname)
      polrap(n=n)
    }
  }
  else
    print("CALIBRATION IMAGES NOT FOUND at folder '../calib', FILTER B!!!")

  delete (ftemp, ver-, >& "dev$null")
}

#Filter V
if (dov1 == yes) {
  ftemp = mktemp("ftemp")
  files(pref//suf//"_v*.fits", > ftemp)
  fstruct = ftemp
  exist = no
  n = 0
  while (fscan(fstruct, fname) != EOF) {
    exist = yes
    n = n+1
  }
  if (exist == yes) {
    #read3Dfits (pref//suf//"_v*.fits")
    ccdrap(pref//suf//"_v", version=".1", zerocor=no, flatcor=no) 
    polrap(n=n)
  }
  delete (ftemp, ver-, >& "dev$null")
}

if (dov2 == yes) {
  if ( access(ccdrap.zero) || access("../calib/avg_flat_v"//suf//".fits") ) {
    ftemp = mktemp("ftemp")
    files(pref//suf//"_v*.fits", > ftemp)
    fstruct = ftemp 
    exist = no
    n = 0
    while (fscan(fstruct, fname) != EOF) {
      exist = yes
      n = n+1
    }
    if (exist == yes) {
      #read3Dfits (pref//suf//"_v*.fits")

      if (access(ccdrap.zero)) 
        ccdrap.zerocor=yes
      else
        ccdrap.zerocor=no
      flatname = "../calib/avg_flat_v"//suf//".fits"
      if (access(flatname)) 
        ccdrap.flatcor=yes
      else
        ccdrap.flatcor=no

      ccdrap(pref//suf//"_v", version=".2", flat=flatname)
      polrap(n=n)
    }
  }
  else
    print("CALIBRATION IMAGES NOT FOUND at folder '../calib', FILTER V!!!")

  delete (ftemp, ver-, >& "dev$null")
}

#Filter R
if (dov1 == yes) {
  ftemp = mktemp("ftemp")
  files(pref//suf//"_r*.fits", > ftemp)
  fstruct = ftemp
  exist = no
  n = 0
  while (fscan(fstruct, fname) != EOF) {
    exist = yes
    n = n+1
  }
  if (exist == yes) {
    #read3Dfits (pref//suf//"_r*.fits")
    ccdrap(pref//suf//"_r", version=".1", zerocor=no, flatcor=no) 
    polrap(n=n)
  }
  delete (ftemp, ver-, >& "dev$null")
}

if (dov2 == yes) {
  if ( access(ccdrap.zero) || access("../calib/avg_flat_r"//suf//".fits") ) {
    ftemp = mktemp("ftemp")
    files(pref//suf//"_r*.fits", > ftemp)
    fstruct = ftemp 
    exist = no
    n = 0
    while (fscan(fstruct, fname) != EOF) {
      exist = yes
      n = n+1
    }
    if (exist == yes) {
      #read3Dfits (pref//suf//"_r*.fits")

      if (access(ccdrap.zero)) 
        ccdrap.zerocor=yes
      else
        ccdrap.zerocor=no
      flatname = "../calib/avg_flat_r"//suf//".fits"
      if (access(flatname)) 
        ccdrap.flatcor=yes
      else
        ccdrap.flatcor=no

      ccdrap(pref//suf//"_r", version=".2", flat=flatname)
      polrap(n=n)
    }
  }
  else
    print("CALIBRATION IMAGES NOT FOUND at folder '../calib', FILTER R!!!")

  delete (ftemp, ver-, >& "dev$null")
}

#Filter I
if (dov1 == yes) {
  ftemp = mktemp("ftemp")
  files(pref//suf//"_i*.fits", > ftemp)
  fstruct = ftemp
  exist = no
  n = 0
  while (fscan(fstruct, fname) != EOF) {
    exist = yes
    n = n+1
  }
  if (exist == yes) {
    #read3Dfits (pref//suf//"_i*.fits")
    ccdrap(pref//suf//"_i", version=".1", zerocor=no, flatcor=no) 
    polrap(n=n)
  }
  delete (ftemp, ver-, >& "dev$null")
}

if (dov2 == yes) {
  if ( access(ccdrap.zero) || access("../calib/avg_flat_i"//suf//".fits") ) {
    ftemp = mktemp("ftemp")
    files(pref//suf//"_i*.fits", > ftemp)
    fstruct = ftemp 
    exist = no
    n = 0
    while (fscan(fstruct, fname) != EOF) {
      exist = yes
      n = n+1
    }
    if (exist == yes) {
      #read3Dfits (pref//suf//"_i*.fits")

      if (access(ccdrap.zero)) 
        ccdrap.zerocor=yes
      else
        ccdrap.zerocor=no
      flatname = "../calib/avg_flat_i"//suf//".fits"
      if (access(flatname)) 
        ccdrap.flatcor=yes
      else
        ccdrap.flatcor=no

      ccdrap(pref//suf//"_i", version=".2", flat=flatname)
      polrap(n=n)
    }
  }
  else
    print("CALIBRATION IMAGES NOT FOUND at folder '../calib', FILTER I!!!")

  delete (ftemp, ver-, >& "dev$null")
}

fstruct = ""

end
