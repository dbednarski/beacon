#
#Version 0.2   11jun08
#Version 0.3   11jul12 - heliocentric system
#

procedure reduce_spec

string pfximg = "28cma"              {prompt="Prefix of the images (WITHOUT '_' at end)"}
string sfximg1= "_a2"                {prompt="Suffix 1 of image and flats (WITHOUT '_' at end)"}
string sfximg2= "_v2"                {prompt="Suffix 2 of image and flats (WITHOUT '_' at end)"}
#bool   dov1   = yes                 {prompt="Do version .1 of the reduction?"}
#bool   dov2   = yes                 {prompt="Do version .2 of the reduction?"}
bool   zerocor= yes                  {prompt="Do bias correction?"}
bool   timgs  = yes                  {prompt="Trim the images?"}
int     modo = 2                     {min=1,max=2, prompt="Spectra in: 1-Lines(105); 2-Columns(Ikon)"}
string trimsec= "[56:2096,43:589]"   {prompt="[56:2096,43:589](105) [25:585,8:2042](Ikon)"}
real    rdnoise = 2.5                {prompt="ReadNoise (e-) to be used"}
real       gain = 2.5                {prompt="Gain to be used"}
bool   flatcor= yes                  {prompt="Apply normalized flat to the images?"}
bool   tracecr= yes                  {prompt="Trace the dispertion?"}
bool   verify = yes                  {prompt="* Use this spec?",mode="q"}

#"[56:2096,43:589]" for 105
#"[25:585,8:2042]" for Ikon

struct *fstruct


begin

string imglist, ftemp, fname, lixo, refimg, lampimg
real crval #,rdnoise, gain
int clen

if(sfximg1==" " || sfximg1=="  ")
  sfximg1=""
if(sfximg2==" " || sfximg2=="  ")
  sfximg2=""

#CCD 105 at OPD
#rdnoise = 2.5
#gain = 2.5
apextract.dispaxis = modo
unlearn ccdproc


print("# Reduction of "//pfximg//sfximg1//" images...")

imglist = mktemp("imglist")
files(pfximg//sfximg1//"*.fits", > imglist)

fstruct = imglist
if (fscan(fstruct, fname) != EOF){
  imcopy ("../calib/norm_flat"//sfximg1//".fits", "norm_flat"//sfximg1//".fits", verbose-)
  ccdproc ("norm_flat"//sfximg1//".fits", output="", ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=no, darkcor=no, flatcor=no, trimsec=trimsec, zero="", flat="")

  ccdproc (fname, output="cp_"//fname, ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=zerocor, darkcor=no, flatcor=flatcor, trimsec=trimsec, zero="../calib/avg_bias.fits", flat="norm_flat"//sfximg1//".fits")

  apall ("cp_"//fname, 1, output=fname, apertures="", format="onedspec", references="", profiles="", interactive=yes, find=yes, recenter=yes, resize=yes, edit=yes, trace=tracecr, fittrace=yes, extract=yes, extras=no, review=yes, line=INDEF, nsum=200, lower=-10., upper=10., apidtable="", b_function="chebyshev", b_order=2, b_sample="-125:-50,50:125", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=3, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)
  refimg = fname

  clen = strlen (refimg)
  imcopy(substr(refimg,1,clen-5)//".0001", pfximg//sfximg1//"_comb.0001")

  while (fscan(fstruct, fname) != EOF) {
    ccdproc (fname, output="cp_"//fname, ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=zerocor, darkcor=no, flatcor=flatcor, trimsec=trimsec, zero="../calib/avg_bias.fits", flat="norm_flat"//sfximg1//".fits")

    apall ("cp_"//fname, 1, output=fname, apertures="", format="onedspec", references="cp_"//refimg, profiles="", interactive=yes, find=yes, recenter=yes, resize=yes, edit=yes, trace=tracecr, fittrace=yes, extract=yes, extras=no, review=yes, line=INDEF, nsum=200, lower=-10., upper=10., apidtable="", b_function="chebyshev", b_order=2, b_sample="-125:-50,50:125", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=3, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)  

    clen = strlen (fname)
    if (verify)
      sarith(pfximg//sfximg1//"_comb.0001","+",substr(fname,1,clen-5)//".0001","",merge+,clobber+,ignore+)
  }

  ftemp = mktemp("ftemp")
  files(pfximg//"*lamp*"//sfximg1//"*.fits", > ftemp)
  files(pfximg//sfximg1//"*lamp*.fits", >> ftemp)

  fstruct = ftemp
  lixo = fscan(fstruct, lampimg) 
  ccdproc (lampimg, output="cp_"//lampimg, ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=zerocor, darkcor=no, flatcor=flatcor, trimsec=trimsec, zero="../calib/avg_bias.fits", flat="norm_flat"//sfximg1//".fits")

  apall ("cp_"//lampimg, 1, output=lampimg, apertures="", format="onedspec", references="cp_"//refimg, profiles="", interactive=no, find=no, recenter=no, resize=no, edit=no, trace=no, fittrace=no, extract=yes, extras=no, review=no, line=INDEF, nsum=200, lower=-10., upper=10., apidtable="", b_function="chebyshev", b_order=2, b_sample="-125:-50,50:125", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=3, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="none", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1) 
  delete (ftemp, ver-, >& "dev$null")
  imdel ("cp*", verify-)

  clen = strlen (lampimg)
  unlearn identify
  identify (substr(lampimg,1,clen-5)//".0001")

  hedit (pfximg//sfximg1//"_comb.0001", "REFSPEC1", substr(lampimg,1,clen-5)//".0001", add=yes, addonly=no, delete=no, verify=no, show=no, update=yes)

  unlearn dispcor  
  dispcor (pfximg//sfximg1//"_comb.0001", pfximg//sfximg1//".cal")

  rvcor(images=pfximg//sfximg1//".cal", imupdat+)
  hselect(pfximg//sfximg1//".cal","VHELIO",yes) | scan(y)
  dopcor (pfximg//sfximg1//".cal", pfximg//sfximg1//".rv", redshift=-y, isveloc=yes, disper=yes)
  hedit  (pfximg//sfximg1//".rv", fields="DOPCOR", value="Heliocentric system", add+, ver-, show-, up+)
  hedit  (pfximg//sfximg1//".rv", fields="VSUN,VLSR", value="", add-, del+, ver-, show-, up+)
 
  hselect(pfximg//sfximg1//".cal", "CRVAL1", yes) | scan (crval)
  if (crval < 5000) {
    #dispcor (pfximg//sfximg1//"_comb.0001", pfximg//".hbeta", w1=4811, w2=4911)
    dispcor (pfximg//sfximg1//".rv", pfximg//".hbeta", w1=4811, w2=4911)
    splot pfximg//".hbeta"
  }
  else {
    #dispcor (pfximg//sfximg1//"_comb.0001", pfximg//".halpha", w1=6513, w2=6613)
    dispcor (pfximg//sfximg1//".rv", pfximg//".halpha", w1=6513, w2=6613)
    splot pfximg//".halpha"
  }

} 
delete (imglist, ver-, >& "dev$null")

print("")
print("# Reduction of "//pfximg//sfximg2//" images...")

imglist = mktemp("imglist")
files(pfximg//sfximg2//"*.fits", > imglist)

fstruct = imglist
if (fscan(fstruct, fname) != EOF){
  imcopy ("../calib/norm_flat"//sfximg2//".fits", "norm_flat"//sfximg2//".fits", verbose-)
  ccdproc ("norm_flat"//sfximg2//".fits", output="", ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=no, darkcor=no, flatcor=no, trimsec=trimsec, zero="", flat="")

  ccdproc (fname, output="cp_"//fname, ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=zerocor, darkcor=no, flatcor=flatcor, trimsec=trimsec, zero="../calib/avg_bias.fits", flat="norm_flat"//sfximg2//".fits")

  apall ("cp_"//fname, 1, output=fname, apertures="", format="onedspec", references="", profiles="", interactive=yes, find=yes, recenter=yes, resize=yes, edit=yes, trace=tracecr, fittrace=yes, extract=yes, extras=no, review=yes, line=INDEF, nsum=200, lower=-10., upper=10., apidtable="", b_function="chebyshev", b_order=2, b_sample="-125:-50,50:125", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=3, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)
  refimg = fname

  clen = strlen (refimg)
  imcopy(substr(refimg,1,clen-5)//".0001", pfximg//sfximg2//"_comb.0001")

  while (fscan(fstruct, fname) != EOF) {
    ccdproc (fname, output="cp_"//fname, ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=zerocor, darkcor=no, flatcor=flatcor, trimsec=trimsec, zero="../calib/avg_bias.fits", flat="norm_flat"//sfximg2//".fits")

    apall ("cp_"//fname, 1, output=fname, apertures="", format="onedspec", references="cp_"//refimg, profiles="", interactive=yes, find=yes, recenter=yes, resize=no, edit=yes, trace=tracecr, fittrace=yes, extract=yes, extras=no, review=yes, line=INDEF, nsum=200, lower=-10., upper=10., apidtable="", b_function="chebyshev", b_order=2, b_sample="-125:-50,50:125", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=3, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)  

    clen = strlen (fname)
    if (verify) {
      sarith(pfximg//sfximg2//"_comb.0001","+",substr(fname,1,clen-5)//".0001","",merge+,clobber+,ignore+) }
  }
  
  ftemp = mktemp("ftemp")
  files(pfximg//"*lamp*"//sfximg2//"*.fits", > ftemp)
  files(pfximg//sfximg2//"*lamp*.fits", >> ftemp)

  fstruct = ftemp
  lixo = fscan(fstruct, lampimg) 
  ccdproc (lampimg, output="cp_"//lampimg, ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=zerocor, darkcor=no, flatcor=flatcor, trimsec=trimsec, zero="../calib/avg_bias.fits", flat="norm_flat"//sfximg2//".fits")

  apall ("cp_"//lampimg, 1, output=lampimg, apertures="", format="onedspec", references="cp_"//refimg, profiles="", interactive=no, find=no, recenter=no, resize=no, edit=no, trace=no, fittrace=no, extract=yes, extras=no, review=no, line=INDEF, nsum=200, lower=-10., upper=10., apidtable="", b_function="chebyshev", b_order=2, b_sample="-125:-50,50:125", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=3, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="none", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1) 
  delete (ftemp, ver-, >& "dev$null")
  imdel ("cp*", verify-)

  clen = strlen (lampimg)
  unlearn identify
  identify (substr(lampimg,1,clen-5)//".0001")

  hedit (pfximg//sfximg2//"_comb.0001", "REFSPEC1", substr(lampimg,1,clen-5)//".0001", add=yes, addonly=no, delete=no, verify=no, show=no, update=yes)

  unlearn dispcor
  dispcor (pfximg//sfximg2//"_comb.0001", pfximg//sfximg2//".cal")

  rvcor(images=pfximg//sfximg2//".cal", imupdat+)

#  hselect(pfximg//sfximg2//".cal","UT",yes) | scan(s1)
#  y = strlen(s1)
#  if (y == 0.) {
#    hselect(pfximg//sfximg2//".cal","FRAME",yes) | scan(s1)
#    y = strlen(s1)
#    s1 = substr(s1,12,y)
#    hedit(pfximg//sfximg2//".cal", fields="UT", value=s1, add+, ver+, show-, up+)
#  }  

  hselect(pfximg//sfximg2//".cal","VHELIO",yes) | scan(y)
  dopcor (pfximg//sfximg2//".cal", pfximg//sfximg2//".rv", redshift=-y, isveloc=yes, disper=yes)
  hedit  (pfximg//sfximg2//".rv", fields="DOPCOR", value="Heliocentric system", add+, ver-, show-, up+)
  hedit  (pfximg//sfximg2//".rv", fields="VSUN,VLSR", value="", add-, del+, ver-, show-, up+)
 
  hselect(pfximg//sfximg2//".cal", "CRVAL1", yes) | scan (crval)
  if (crval < 5000) {
    #dispcor (pfximg//sfximg2//"_comb.0001", pfximg//".hbeta", w1=4811, w2=4911)
    dispcor (pfximg//sfximg2//".rv", pfximg//".hbeta", w1=4811, w2=4911)
    splot pfximg//".hbeta"
  }
  else {
    #dispcor (pfximg//sfximg2//"_comb.0001", pfximg//".halpha", w1=6513, w2=6613)
    dispcor (pfximg//sfximg2//".rv", pfximg//".halpha", w1=6513, w2=6613)
    splot pfximg//".halpha"
  }

} 
delete (imglist, ver-, >& "dev$null")


fstruct = ""

end
