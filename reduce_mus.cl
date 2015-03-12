#
#Version 0.1   Modified by D. Moser in 2015-01-12
#

procedure reduce_mus

string pfximg = "aeri"              {prompt="Prefix of the images (WITHOUT '_' at end)"}
string sfximg1= "_r"                {prompt="Suffix 1 of image and flats (WITHOUT '_' at end)"}
string sfximg2= "_b"                {prompt="Suffix 2 of image and flats (WITHOUT '_' at end)"}
#bool   dov1   = yes                 {prompt="Do version .1 of the reduction?"}
#bool   dov2   = yes                 {prompt="Do version .2 of the reduction?"}
bool   zerocor= yes                  {prompt="Do bias correction?"}
int     modo = 2                     {min=1,max=2, prompt="Spectra in: 1-Lines; 2-Columns (Ikon default)"}
string flattyp = "suf"               {enum="ccd|suf|none", prompt="Flat correction: CCD, Suffix or None"}
bool   timgs  = yes                  {prompt="Trim the images?"}
string trimsec= "[1:2048,49:2000]"   {prompt="[1:2048,49:2000]](Ikon)"}
real    rdnoise = 0.9                {prompt="ReadNoise (e-) to be used"}
real       gain = 6.66                {prompt="Gain to be used"}
#bool   flatcor= yes                  {prompt="Apply normalized flat to the images?"}
bool   tracecr= yes                  {prompt="Trace the dispertion?"}
#bool   halp_out=yes                  {prompt="Produce an Halpha output (spec. cut)?"}
#bool   hbet_out=yes                  {prompt="Produce an Hbeta output (spec. cut)?"}
bool   verify = yes                  {prompt="* Use this spec?",mode="q"}

#"[56:2096,43:589]" for 105
#"[25:585,8:2042]" for Ikon

struct *fstruct

begin

string imglist, ftemp, fname, lixo, refimg, lampimg, refflat, normflat, flatref
real crval
#,rdnoise, gain
int clen
bool flatcor

if(sfximg1==" " || sfximg1=="  ")
  sfximg1=""
if(sfximg2==" " || sfximg2=="  ")
  sfximg2=""

#CCD 105 at OPD
#rdnoise = 2.5
#gain = 2.5
apextract.dispaxis = modo
unlearn ccdproc
unlearn apall

if (access ("database")==no) {
    mkdir("database")
}
copy("../calib/database/*", "database/")

if (sfximg1!="") {
print("# Reduction of "//pfximg//sfximg1//" images...")

if (flattyp == "suf") {
    flatcor = yes
    flatref = "avg_flat"//sfximg1
    normflat = "../calib/norm_flat"//sfximg1
}
if (flattyp == "ccd") {
    flatcor = yes
    flatref = "../calib/avg_flat"
    normflat = "../calib/norm_flat"
}
if (flattyp == "none") {
    flatcor = no
    flatref = "../calib/lamp"//sfximg1
    normflat = ""
}
lampimg = "avg_lamp"//sfximg1//".ms"

imglist = mktemp("imglist")
files(pfximg//sfximg1//"*.fits", > imglist)

fstruct = imglist
if (fscan(fstruct, fname) != EOF){
  #imcopy ("../calib/norm_flat"//sfximg1//".fits", "norm_flat"//sfximg1//".fits", verbose-)
  #ccdproc ("norm_flat"//sfximg1//".fits", output="", ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=no, darkcor=no, flatcor=no, trimsec=trimsec, zero="", flat="")

  ccdproc.flat = normflat
  ccdproc (fname, output="cp_"//fname, ccdtype="", fixpix=no, overscan=no, zerocor=zerocor, darkcor=no, flatcor=flatcor, zero="../calib/avg_bias", trim=timgs, trimsec=trimsec)

  clen = strlen (fname)
  apall ("cp_"//fname, 50, output=substr(fname,1,clen-5)//".ms", apertures="", format="multispec", references=flatref, profiles="", interactive=yes, find=yes, recenter=yes, resize=yes, edit=yes, trace=tracecr, fittrace=yes, extract=yes, extras=no, review=yes, line=INDEF, nsum=20, lower=-5., upper=5., apidtable="", b_function="chebyshev", b_order=2, b_sample="-15:-11,11:15", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=4, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)
  refimg = fname

  imcopy(substr(refimg,1,clen-5)//".ms", pfximg//sfximg1//"_comb.ms")

  while (fscan(fstruct, fname) != EOF) {
    ccdproc (fname, output="cp_"//fname, ccdtype="", fixpix=no, overscan=no, zerocor=zerocor, darkcor=no, flatcor=flatcor, zero="../calib/avg_bias", trim=timgs, trimsec=trimsec)

    clen = strlen (fname)
    apall ("cp_"//fname, 50, output=substr(fname,1,clen-5)//".ms", apertures="", format="multispec", references=flatref, profiles="", interactive=yes, find=yes, recenter=yes, resize=yes, edit=yes, trace=tracecr, fittrace=yes, extract=yes, extras=no, review=yes, line=INDEF, nsum=20, lower=-5., upper=5., apidtable="", b_function="chebyshev", b_order=2, b_sample="-15:-11,11:15", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=4, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)

    if (verify)
      sarith(pfximg//sfximg1//"_comb.ms","+",substr(fname,1,clen-5)//".ms","",merge+,clobber+,ignore+)
  }

  unlearn continuum
  unlearn sarith
  continuum(pfximg//sfximg1//"_comb.ms", pfximg//sfximg1//"_comb.ms.cont", order=5)
  sarith(pfximg//sfximg1//"_comb.ms", "/", pfximg//sfximg1//"_comb.ms.cont", output=pfximg//sfximg1//"_norm.ms", errval=1.)

  hedit (pfximg//sfximg1//"_comb.ms", "REFSPEC1", lampimg, add=yes, addonly=no, delete=no, verify=no, show=no, update=yes)
  hedit (pfximg//sfximg1//"_norm.ms", "REFSPEC1", lampimg, add=yes, addonly=no, delete=no, verify=no, show=no, update=yes)
  unlearn dispcor  
  dispcor (pfximg//sfximg1//"_comb.ms", pfximg//sfximg1//".ms.cal")
  dispcor (pfximg//sfximg1//"_norm.ms", pfximg//sfximg1//".ms.norm")

  unlearn scombine
  scombine(pfximg//sfximg1//".ms.cal", pfximg//sfximg1//".sum", group="images", combine="sum")
  scombine(pfximg//sfximg1//".ms.norm", pfximg//sfximg1//".norm", group="images", combine="sum")
  sarith(pfximg//sfximg1//".sum", "/", pfximg//sfximg1//".norm", output=pfximg//sfximg1//".cal", errval=1.)

  #~ imdel (pfximg//sfximg1//"_comb.ms.cont", verify-)
  #~ imdel (pfximg//sfximg1//"*norm*", verify-)
  #~ imdel (pfximg//sfximg1//"*sum*", verify-)

  rvcor(images=pfximg//sfximg1//".cal", imupdat+)
  hselect(pfximg//sfximg1//".cal","VHELIO",yes) | scan(y)
  dopcor (pfximg//sfximg1//".cal", pfximg//sfximg1//".rv", redshift=-y, isveloc=yes, disper=yes)
  hedit  (pfximg//sfximg1//".rv", fields="DOPCOR", value="Heliocentric system", add+, ver-, show-, up+)
  hedit  (pfximg//sfximg1//".rv", fields="VSUN,VLSR", value="", add-, del+, ver-, show-, up+)

  hselect(pfximg//sfximg1//".cal", "CRVAL1", yes) | scan (crval)
  if (crval < 5000) {
  #if (hbet_out) {
    #dispcor (pfximg//sfximg1//"_comb.0001", pfximg//".hbeta", w1=4811, w2=4911)
    dispcor (pfximg//sfximg1//".rv", pfximg//".hbeta", w1=4811, w2=4911)
    splot pfximg//".hbeta"
  }
  else {
  #if (halp_out) {
    #dispcor (pfximg//sfximg1//"_comb.0001", pfximg//".halpha", w1=6513, w2=6613)
    dispcor (pfximg//sfximg1//".rv", pfximg//".halpha", w1=6513, w2=6613)
    splot pfximg//".halpha"
  }

}
delete (imglist, ver-, >& "dev$null")
imdel ("cp*", verify-)
}
#
if (sfximg2!="") {
print("# Reduction of "//pfximg//sfximg2//" images...")

if (flattyp == "suf") {
    flatcor = yes
    flatref = "avg_flat"//sfximg2
    normflat = "../calib/norm_flat"//sfximg2
}
if (flattyp == "ccd") {
    flatcor = yes
    flatref = "../calib/avg_flat"
    normflat = "../calib/norm_flat"
}
if (flattyp == "none") {
    flatcor = no
    flatref = "../calib/lamp"//sfximg2
    normflat = ""
}
lampimg = "avg_lamp"//sfximg2//".ms"

imglist = mktemp("imglist")
files(pfximg//sfximg2//"*.fits", > imglist)

fstruct = imglist
if (fscan(fstruct, fname) != EOF){
  #imcopy ("../calib/norm_flat"//sfximg2//".fits", "norm_flat"//sfximg2//".fits", verbose-)
  #ccdproc ("norm_flat"//sfximg2//".fits", output="", ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=no, darkcor=no, flatcor=no, trimsec=trimsec, zero="", flat="")

  ccdproc.flat = normflat
  ccdproc (fname, output="cp_"//fname, ccdtype="", fixpix=no, overscan=no, zerocor=zerocor, darkcor=no, flatcor=flatcor, zero="../calib/avg_bias", trim=timgs, trimsec=trimsec)

  clen = strlen (fname)
  apall ("cp_"//fname, 50, output=substr(fname,1,clen-5)//".ms", apertures="", format="multispec", references=flatref, profiles="", interactive=yes, find=yes, recenter=yes, resize=yes, edit=yes, trace=tracecr, fittrace=yes, extract=yes, extras=no, review=yes, line=INDEF, nsum=20, lower=-5., upper=5., apidtable="", b_function="chebyshev", b_order=2, b_sample="-15:-11,11:15", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=4, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)
  refimg = fname

  imcopy(substr(refimg,1,clen-5)//".ms", pfximg//sfximg2//"_comb.ms")

  while (fscan(fstruct, fname) != EOF) {
    ccdproc (fname, output="cp_"//fname, ccdtype="", fixpix=no, overscan=no, zerocor=zerocor, darkcor=no, flatcor=flatcor, zero="../calib/avg_bias", trim=timgs, trimsec=trimsec)

    clen = strlen (fname)
    apall ("cp_"//fname, 50, output=substr(fname,1,clen-5)//".ms", apertures="", format="multispec", references=flatref, profiles="", interactive=yes, find=yes, recenter=yes, resize=yes, edit=yes, trace=tracecr, fittrace=yes, extract=yes, extras=no, review=yes, line=INDEF, nsum=20, lower=-5., upper=5., apidtable="", b_function="chebyshev", b_order=2, b_sample="-15:-11,11:15", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=4, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)

    if (verify)
      sarith(pfximg//sfximg2//"_comb.ms","+",substr(fname,1,clen-5)//".ms","",merge+,clobber+,ignore+)
  }

  unlearn continuum
  unlearn sarith
  continuum(pfximg//sfximg2//"_comb.ms", pfximg//sfximg2//"_comb.ms.cont", order=5)
  sarith(pfximg//sfximg2//"_comb.ms", "/", pfximg//sfximg2//"_comb.ms.cont", output=pfximg//sfximg2//"_norm.ms", errval=1.)

  hedit (pfximg//sfximg2//"_comb.ms", "REFSPEC1", lampimg, add=yes, addonly=no, delete=no, verify=no, show=no, update=yes)
  hedit (pfximg//sfximg2//"_norm.ms", "REFSPEC1", lampimg, add=yes, addonly=no, delete=no, verify=no, show=no, update=yes)
  unlearn dispcor  
  dispcor (pfximg//sfximg2//"_comb.ms", pfximg//sfximg2//".ms.cal")
  dispcor (pfximg//sfximg2//"_norm.ms", pfximg//sfximg2//".ms.norm")

  unlearn scombine
  scombine(pfximg//sfximg2//".ms.cal", pfximg//sfximg2//".sum", group="images", combine="sum")
  scombine(pfximg//sfximg2//".ms.norm", pfximg//sfximg2//".norm", group="images", combine="sum")
  sarith(pfximg//sfximg2//".sum", "/", pfximg//sfximg2//".norm", output=pfximg//sfximg2//".cal", errval=1.)

  #~ imdel (pfximg//sfximg2//"_comb.ms.cont", verify-)
  #~ imdel (pfximg//sfximg2//"*norm*", verify-)
  #~ imdel (pfximg//sfximg2//"*sum*", verify-)

  rvcor(images=pfximg//sfximg2//".cal", imupdat+)
  hselect(pfximg//sfximg2//".cal","VHELIO",yes) | scan(y)
  dopcor (pfximg//sfximg2//".cal", pfximg//sfximg2//".rv", redshift=-y, isveloc=yes, disper=yes)
  hedit  (pfximg//sfximg2//".rv", fields="DOPCOR", value="Heliocentric system", add+, ver-, show-, up+)
  hedit  (pfximg//sfximg2//".rv", fields="VSUN,VLSR", value="", add-, del+, ver-, show-, up+)

  hselect(pfximg//sfximg2//".cal", "CRVAL1", yes) | scan (crval)
  if (crval < 5000) {
  #if (hbet_out) {
    #dispcor (pfximg//sfximg2//"_comb.0001", pfximg//".hbeta", w1=4811, w2=4911)
    dispcor (pfximg//sfximg2//".rv", pfximg//".hbeta", w1=4811, w2=4911)
    splot pfximg//".hbeta"
  }
  else {
  #if (halp_out) {
    #dispcor (pfximg//sfximg2//"_comb.0001", pfximg//".halpha", w1=6513, w2=6613)
    dispcor (pfximg//sfximg2//".rv", pfximg//".halpha", w1=6513, w2=6613)
    splot pfximg//".halpha"
  }

}
delete (imglist, ver-, >& "dev$null")
imdel ("cp*", verify-)
}
#

fstruct = ""

end
