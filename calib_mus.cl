#
#Version: 0.1   Modified by D. Moser in 2015-01-12
#

procedure calib_mus

bool   biascomb = yes       {prompt="Combine bias (filenames '*bias*.fits')?"}
bool   flatccd  = no        {prompt="Use CCD flat only ('*flat*.fits')? Suffixes ignored"}
string flatpfx1 = "_a1"      {prompt="Suffix 1 of lamp files to be combined (WITHOUT '_') at end"}
string flatpfx2 = "_v1"      {prompt="Suffix 2 of lamp files to be combined (WITHOUT '_') at end"}
string flatpfx3 = "_a2"      {prompt="Suffix 3 of lamp files to be combined (WITHOUT '_') at end"}
string flatpfx4 = "_v2"      {prompt="Suffix 4 of lamp files to be combined (WITHOUT '_') at end"}
bool   timgs  = yes          {prompt="Trim the images?"}
string trimsec= "[1:2048,49:2000]"   {prompt="[1:2048,49:2000]](Ikon)"}
real    rdnoise = 0.9       {prompt="ReadNoise (e-) to be used"}
real       gain = 6.66      {prompt="Gain to be used"}
bool     verify = yes       {prompt="* Stop script if no bias images are found?",mode="q"}

struct *fstruct, fstruct2

begin

string ftemp, fname, fname2, lixo, refflat
bool flatcor

#~ if (verify) {
    #~ print('# blah!')
#~ }

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
unlearn apflatten
unlearn aptrace
unlearn apdefault
unlearn ecidentify
ccdproc.ccdtype = ""
ccdproc.fixpix = no
ccdproc.overscan = no
ccdproc.trim = no
ccdproc.flatcor = no
ccdproc.darkcor = no
ccdproc.zero = "avg_bias"

#Combine bias images
if (biascomb) {
  print("# Bias correction enabled ...")
  ftemp = mktemp("ftemp")
  files("bias*.fits", > ftemp)
  fstruct = ftemp
  if (fscan(fstruct, fname) != EOF) {
    del ("avg_bias.fits", verify=no, >& "dev$null")
    print("# Combining bias images...")
    unlearn zerocombine
    zerocombine ("@"//ftemp, output="avg_bias", ccdtype="")
  }
  else {
    print ("# NO BIAS IMAGES FOUND!")
    if (verify) {
      delete (ftemp, ver-, >& "dev$null")
      fstruct = ""
    }
  }
  if(timgs){
    imcopy("avg_bias", "avg_bias.ori")
    ccdproc.flat=""
    ccdproc("avg_bias", ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=no, darkcor=no, flatcor=no, trimsec=trimsec, zero="")
  }
}
else {
  ccdproc.zerocor = no
  print ("# NO BIAS IMAGES FOUND!")
  if (verify) {
    delete (ftemp, ver-, >& "dev$null")
    fstruct = ""
    }
}

apflatten.functio="spline3"
apflatten.order=5
aptrace.order=4
apdefault.b_sampl="-15:-11,11:15"
apdefault.b_order=2
apall.b_order=2
apfit.backgro="fit"
apsum.backgro="fit"
imcombine.rdnoise=rdnoise
imcombine.gain=gain
#imcombine.reject="avsigclip"
ecidentify.xorder=2
ecidentify.yorder=2
#Combine flat 1 images 
if (flatccd) {
    flatcor = no
    ftemp = mktemp("ftemp")
    files("*flat*.fits", > ftemp)
    fstruct = ftemp
    if (fscan(fstruct, fname) != EOF) {
        flatcor = yes
        print("# Combining flat images...")
#    if (access ("combflatobj.fits"))
#      imdel ("combflatobj.fits", verify=no)
        flatcombine ("@"//ftemp, output="avg_flat", ccdtype="", subsets=no, scale="mean")
    #~ boxcar ("avg"//flatpfx1, "norm"//flatpfx1, 10, 10, boundary="nearest", constant=0.)
    #~ imarith ("avg"//flatpfx1,"/","norm"//flatpfx1, "norm"//flatpfx1, title="", divzero=0.,hparams="",pixtype="", calctype="", verbose=no, noact=no)
        ccdproc.flat=""
        ccdproc("avg_flat", ccdtype="", fixpix=no, overscan=no, trim=timgs, zerocor=yes, darkcor=no, flatcor=no, trimsec=trimsec, zero="avg_bias")
        apflatten("avg_flat", "norm_flat")
    }
    else{
        print("# No flat images found !!!")
    }
    delete (ftemp, ver-, >& "dev$null")
}
else{
    if (flatpfx1 != "") {
        flatcor = no
        ftemp = mktemp("ftemp")
        files("flat"//flatpfx1//"_*.fits", > ftemp)
        fstruct = ftemp
        if (fscan(fstruct, fname) != EOF) {
            flatcor = yes
            print("# Combining flat"//flatpfx1//"_* images...")
            ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=no, zero="avg_bias", trim=timgs, trimsec=trimsec)
            if (access ("cp_"//fname)==no) {
                imcopy(fname, "cp_"//fname)
            }
            while (fscan(fstruct, fname) != EOF) {
                ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=no, zero="avg_bias", trim=timgs, trimsec=trimsec)
                if (access("cp_"//fname)==no) {
                    imcopy(fname, "cp_"//fname)
                }                
            }
            lixo = mktemp("ftemp2")
            files("cp_flat"//flatpfx1//"_*.fits", > lixo)
    #    if (access ("combflatobj.fits"))
    #      imdel ("combflatobj.fits", verify=no)
            flatcombine ("@"//lixo, output="avg_flat"//flatpfx1, ccdtype="", subsets = no, scale="mean")
        #~ boxcar ("avg"//flatpfx1, "norm"//flatpfx1, 10, 10, boundary="nearest", constant=0.)
        #~ imarith ("avg"//flatpfx1,"/","norm"//flatpfx1, "norm"//flatpfx1, title="", divzero=0.,hparams="",pixtype="", calctype="", verbose=no, noact=no)
            apflatten("avg_flat"//flatpfx1, "norm_flat"//flatpfx1)
            delete (lixo, ver-, >& "dev$null")
        }
        else{
            print("# No flat images found !!!")
        }
        delete (ftemp, ver-, >& "dev$null")
    }
    if (flatpfx2 != "") {
        flatcor = no
        ftemp = mktemp("ftemp")
        files("flat"//flatpfx2//"_*.fits", > ftemp)
        fstruct = ftemp
        if (fscan(fstruct, fname) != EOF) {
            flatcor = yes
            print("# Combining flat"//flatpfx2//"_* images...")
            ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=no, zero="avg_bias", trim=timgs, trimsec=trimsec)
            if (access ("cp_"//fname)==no) {
                imcopy(fname, "cp_"//fname)
            }
            while (fscan(fstruct, fname) != EOF) {
                ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=no, zero="avg_bias", trim=timgs, trimsec=trimsec)
                if (access("cp_"//fname)==no) {
                    imcopy(fname, "cp_"//fname)
                }                
            }
            lixo = mktemp("ftemp2")
            files("cp_flat"//flatpfx2//"_*.fits", > lixo)
    #    if (access ("combflatobj.fits"))
    #      imdel ("combflatobj.fits", verify=no)
            flatcombine ("@"//lixo, output="avg_flat"//flatpfx2, ccdtype="", subsets = no, scale="mean")
        #~ boxcar ("avg"//flatpfx2, "norm"//flatpfx2, 10, 10, boundary="nearest", constant=0.)
        #~ imarith ("avg"//flatpfx2,"/","norm"//flatpfx2, "norm"//flatpfx2, title="", divzero=0.,hparams="",pixtype="", calctype="", verbose=no, noact=no)
            apflatten("avg_flat"//flatpfx2, "norm_flat"//flatpfx2)
            delete (lixo, ver-, >& "dev$null")
        }
        else{
            print("# No flat images found !!!")
        }
        delete (ftemp, ver-, >& "dev$null")
    }
    if (flatpfx3 != "") {
        flatcor = no
        ftemp = mktemp("ftemp")
        files("flat"//flatpfx3//"_*.fits", > ftemp)
        fstruct = ftemp
        if (fscan(fstruct, fname) != EOF) {
            flatcor = yes
            print("# Combining flat"//flatpfx3//"_* images...")
            ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=no, zero="avg_bias", trim=timgs, trimsec=trimsec)
            if (access ("cp_"//fname)==no) {
                imcopy(fname, "cp_"//fname)
            }
            while (fscan(fstruct, fname) != EOF) {
                ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=no, zero="avg_bias", trim=timgs, trimsec=trimsec)
                if (access("cp_"//fname)==no) {
                    imcopy(fname, "cp_"//fname)
                }                
            }
            lixo = mktemp("ftemp2")
            files("cp_flat"//flatpfx3//"_*.fits", > lixo)
    #    if (access ("combflatobj.fits"))
    #      imdel ("combflatobj.fits", verify=no)
            flatcombine ("@"//lixo, output="avg_flat"//flatpfx3, ccdtype="", subsets = no, scale="mean")
        #~ boxcar ("avg"//flatpfx3, "norm"//flatpfx3, 10, 10, boundary="nearest", constant=0.)
        #~ imarith ("avg"//flatpfx3,"/","norm"//flatpfx3, "norm"//flatpfx3, title="", divzero=0.,hparams="",pixtype="", calctype="", verbose=no, noact=no)
            apflatten("avg_flat"//flatpfx3, "norm_flat"//flatpfx3)
            delete (lixo, ver-, >& "dev$null")
        }
        else{
            print("# No flat images found !!!")
        }
        delete (ftemp, ver-, >& "dev$null")
    }
    if (flatpfx4 != "") {
        flatcor = no
        ftemp = mktemp("ftemp")
        files("flat"//flatpfx4//"_*.fits", > ftemp)
        fstruct = ftemp
        if (fscan(fstruct, fname) != EOF) {
            flatcor = yes
            print("# Combining flat"//flatpfx4//"_* images...")
            ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=no, zero="avg_bias", trim=timgs, trimsec=trimsec)
            if (access ("cp_"//fname)==no) {
                imcopy(fname, "cp_"//fname)
            }
            while (fscan(fstruct, fname) != EOF) {
                ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=no, zero="avg_bias", trim=timgs, trimsec=trimsec)
                if (access("cp_"//fname)==no) {
                    imcopy(fname, "cp_"//fname)
                }                
            }
            lixo = mktemp("ftemp2")
            files("cp_flat"//flatpfx4//"_*.fits", > lixo)
    #    if (access ("combflatobj.fits"))
    #      imdel ("combflatobj.fits", verify=no)
            flatcombine ("@"//lixo, output="avg_flat"//flatpfx4, ccdtype="", subsets = no, scale="mean")
        #~ boxcar ("avg"//flatpfx4, "norm"//flatpfx4, 10, 10, boundary="nearest", constant=0.)
        #~ imarith ("avg"//flatpfx4,"/","norm"//flatpfx4, "norm"//flatpfx4, title="", divzero=0.,hparams="",pixtype="", calctype="", verbose=no, noact=no)
            apflatten("avg_flat"//flatpfx4, "norm_flat"//flatpfx4)
            delete (lixo, ver-, >& "dev$null")
        }
        else{
            print("# No flat images found !!!")
        }
        delete (ftemp, ver-, >& "dev$null")
    }
}

#LAMP process...
if (flatpfx1 != "") {
    ftemp = mktemp("ftemp")
    files("lamp*"//flatpfx1//"_*.fits", > ftemp)
    fstruct = ftemp
    if (flatccd) {
        ccdproc.flat="norm_flat"
        refflat="avg_flat"
    }
    else {
        ccdproc.flat="norm_flat"//flatpfx1
        refflat="avg_flat"//flatpfx1
    }
    while (fscan(fstruct, fname) != EOF) {
        ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=flatcor, zero="avg_bias", trim=timgs, trimsec=trimsec)
    }
    delete (ftemp, ver-, >& "dev$null")
    ftemp = mktemp("ftemp")
    files("cp_*lamp*"//flatpfx1//"*.fits", > ftemp)
    imcombine("@"//ftemp, output="avg_lamp"//flatpfx1)
    imdel ("cp*", verify-)
    delete (ftemp, ver-, >& "dev$null")
    #
    apall ("avg_lamp"//flatpfx1, 50, output="avg_lamp"//flatpfx1//".ms", apertures="", format="multispec", references=refflat, profiles="", interactive=no, find=no, recenter=no, resize=no, edit=no, trace=no, fittrace=no, extract=yes, extras=no, review=no, line=INDEF, nsum=20, lower=-5., upper=5., apidtable="", b_function="chebyshev", b_order=2, b_sample="-15:-11,11:15", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=4, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="none", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)
    ecidentify ("avg_lamp"//flatpfx1//".ms")
}
if (flatpfx2 != "") {
    ftemp = mktemp("ftemp")
    files("lamp*"//flatpfx2//"_*.fits", > ftemp)
    fstruct = ftemp
    if (flatccd) {
        ccdproc.flat="norm_flat"
        refflat="avg_flat"
    }
    else {
        ccdproc.flat="norm_flat"//flatpfx2
        refflat="avg_flat"//flatpfx2
    }
    while (fscan(fstruct, fname) != EOF) {
        ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=flatcor, zero="avg_bias", trim=timgs, trimsec=trimsec)
    }
    delete (ftemp, ver-, >& "dev$null")
    ftemp = mktemp("ftemp")
    files("cp_*lamp*"//flatpfx2//"*.fits", > ftemp)
    imcombine("@"//ftemp, output="avg_lamp"//flatpfx2)
    imdel ("cp*", verify-)
    delete (ftemp, ver-, >& "dev$null")
    #
    apall ("avg_lamp"//flatpfx2, 50, output="avg_lamp"//flatpfx2//".ms", apertures="", format="multispec", references=refflat, profiles="", interactive=no, find=no, recenter=no, resize=no, edit=no, trace=no, fittrace=no, extract=yes, extras=no, review=no, line=INDEF, nsum=20, lower=-5., upper=5., apidtable="", b_function="chebyshev", b_order=2, b_sample="-15:-11,11:15", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=4, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="none", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)
    ecidentify ("avg_lamp"//flatpfx2//".ms")
}
if (flatpfx3 != "") {
    ftemp = mktemp("ftemp")
    files("lamp*"//flatpfx3//"_*.fits", > ftemp)
    fstruct = ftemp
    if (flatccd) {
        ccdproc.flat="norm_flat"
        refflat="avg_flat"
    }
    else {
        ccdproc.flat="norm_flat"//flatpfx3
        refflat="avg_flat"//flatpfx3
    }
    while (fscan(fstruct, fname) != EOF) {
        ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=flatcor, zero="avg_bias", trim=timgs, trimsec=trimsec)
    }
    delete (ftemp, ver-, >& "dev$null")
    ftemp = mktemp("ftemp")
    files("cp_*lamp*"//flatpfx3//"*.fits", > ftemp)
    imcombine("@"//ftemp, output="avg_lamp"//flatpfx3)
    imdel ("cp*", verify-)
    delete (ftemp, ver-, >& "dev$null")
    #
    apall ("avg_lamp"//flatpfx3, 50, apertures="", format="multispec", references=refflat, profiles="", interactive=no, find=no, recenter=no, resize=no, edit=no, trace=no, fittrace=no, extract=yes, extras=no, review=no, line=INDEF, nsum=20, lower=-5., upper=5., apidtable="", b_function="chebyshev", b_order=2, b_sample="-15:-11,11:15", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=4, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="none", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)
    ecidentify ("avg_lamp"//flatpfx3//".ms")
}
if (flatpfx4 != "") {
    ftemp = mktemp("ftemp")
    files("lamp*"//flatpfx4//"_*.fits", > ftemp)
    fstruct = ftemp
    if (flatccd) {
        ccdproc.flat="norm_flat"
        refflat="avg_flat"
    }
    else {
        ccdproc.flat="norm_flat"//flatpfx4
        refflat="avg_flat"//flatpfx4
    }
    while (fscan(fstruct, fname) != EOF) {
        ccdproc (fname, output="cp_"//fname, ccdtype="", flatcor=flatcor, zero="avg_bias", trim=timgs, trimsec=trimsec)
    }
    delete (ftemp, ver-, >& "dev$null")
    ftemp = mktemp("ftemp")
    files("cp_*lamp*"//flatpfx4//"*.fits", > ftemp)
    imcombine("@"//ftemp, output="avg_lamp"//flatpfx4)
    imdel ("cp*", verify-)
    delete (ftemp, ver-, >& "dev$null")
    #
    apall ("avg_lamp"//flatpfx4, 50, apertures="", format="multispec", references=refflat, profiles="", interactive=no, find=no, recenter=no, resize=no, edit=no, trace=no, fittrace=no, extract=yes, extras=no, review=no, line=INDEF, nsum=20, lower=-5., upper=5., apidtable="", b_function="chebyshev", b_order=2, b_sample="-15:-11,11:15", b_naverage=-3, b_niterate=0, b_low_reject=3., b_high_rejec=3., b_grow=0., width=5., radius=10., threshold=0.,minsep=5., maxsep=1000., order="increasing", aprecenter="", npeaks=INDEF, shift=yes, llimit=INDEF, ulimit=INDEF,ylevel=0.1, peak=yes, bkg=yes, r_grow=0., avglimits=no, t_nsum=10, t_step=10, t_nlost=3, t_function="legendre", t_order=4, t_sample="*", t_naverage=1, t_niterate=0, t_low_reject=3., t_high_rejec=3., t_grow=0., background="none", skybox=1, weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise=rdnoise, gain=gain, lsigma=4., usigma=4., nsubaps=1)
    ecidentify ("avg_lamp"//flatpfx4//".ms")
}

fstruct = ""
delete (ftemp, ver-, >& "dev$null")

end

