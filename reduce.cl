#
#Ver 2.0, 14ago16
#
procedure reduce(pref)

string pref="tpyx" {prompt="Prefix of filenames (WITHOUT '_')"}
string suf="_f"   {prompt="Suffix of filenames (same of calib. images)"}
string calib="../calib"   {prompt="Path to calib directory (WITHOUT last '/')"}
bool  dov1=yes    {prompt="Do the reduction without calibrations?"}
bool  dov2=yes    {prompt="Do the reduction using the calib. images?"}
bool  head=yes    {prompt="Use gain and readnoise values from headers?"}
bool  usecoords=yes    {prompt="Use previous daofind coordinates to next filters?"}
bool  dograph=yes    {prompt="Generate all .png graphs?"}
real ganho="INDEF"   {prompt="CCD gain to be used if head=no (e/adu)"}
real readno="INDEF"  {prompt="ReadNoise (ADUs) to be used if head=no (adu)"}
string graphpol="/iraf/iraf-2.16.1/extern/beacon/grafpol.py"   {prompt="Path to the grafpol.py code"}

struct *fstruct


begin

string ftemp, ftemp2, fname, flatname, inname, filter[5], verbose, coordfile
int i, n

verbose = mktemp("verb")
coordfile=""
filter[1]="u"
filter[2]="b"
filter[3]="v"
filter[4]="r"
filter[5]="i"

# Set pccdgen parameters
pccdgen.wavetyp="half"
pccdgen.calc="c"
pccdgen.retar=180.

# Set gain and readnoise from prompt
if(!head) {
  ccdrap.readnoise = readno
  ccdrap.ganho = ganho
}

# Set zero parameters of ccdrap
ccdrap.zero = calib//"/avg_bias"//suf//".fits"
if(dov2 && access(ccdrap.zero))
  ccdrap.zerocor=yes
else
  ccdrap.zerocor=no

if(suf==" " || suf=="  ")
  suf=""



# Loop at the filters
for (i = 1; i < 6; i=i+1) {

  ftemp = mktemp("ftemp_"//filter[i])
  ftemp2 = mktemp("ftemp2o_"//filter[i])

  # List the files with filter before suffix
  inname=pref//"_"//filter[i]//suf
  files(inname//"*.fits", > ftemp)


  # If ftemp file is void, tests if "filter" and "suf" are inverted in filenames
  fstruct = ftemp
  if(fscan(fstruct, fname) == EOF){

    delete (ftemp, ver-, >& "dev$null")
    inname=pref//suf//"_"//filter[i]
    files(inname//"*.fits", > ftemp)

    fstruct = ftemp
    if(fscan(fstruct, fname) == EOF){
      delete (ftemp, ver-, >& "dev$null")
      next
    }
    else{
      # List only images of type pref_filter[i]_suf_####.fits, where #### is only digits
      grep("'^"//inname//"_[0-9]*.fits'", ftemp, > ftemp2)
      delete (ftemp, ver-, >& "dev$null")
      fstruct = ftemp2
    }
  }
  else {
    # List only images of type pref_filter[i]_suf_####.fits, where #### are only digits. It's essential to avoid get a second suffix (e.g. if suffix parameter is "_g5", it gets only "dsco_v_g5_0000.fits" files and not "dsco_v_g5_f_0000.fits")
    grep("'^"//inname//"_[0-9]*.fits'", ftemp, > ftemp2)
    delete (ftemp, ver-, >& "dev$null")
    fstruct = ftemp2
  }


  # COUNT LINES
  n = 0
  while (fscan(fstruct, fname) != EOF)
    n = n+1


  # Receive gain and readnoise from headers
  if(head) {
    imgets(fname, "GAIN")
    ccdrap.ganho=real(imgets.value)
    imgets(fname, "RDNOISE")
    ccdrap.readnoise=real(imgets.value)/ccdrap.ganho
  }


  # Reduce without calib images
  if(dov1==yes) {

    # The '|| access("coord_"//inname//".ord")' condition is redundant with ccdrap statments
    if( !usecoords || (coordfile=="" && !access("coord_"//inname//".ord")) || access("coord_"//inname//".ord"))
      ccdrap(inname, version=".1", zerocor=no, flatcor=no, zero="", flat="", coordref=no, coord="")
    else
      ccdrap(inname, version=".1", zerocor=no, flatcor=no, zero="", flat="", coordref=yes, coord=coordfile)

    if(n<=16)
      polrap(n=n)
    if(n>8)
      polrap(n=8)
    if(n>16)
      polrap(n=16)

    print("FILTER "//filter[i]//" .1: DONE!", >> verbose)
  }


  # Reduce with calib images
  if(dov2==yes) {

    flatname = calib//"/avg_flat_"//filter[i]//suf//".fits"
    if (access(flatname)) 
      ccdrap.flatcor=yes
    else
      ccdrap.flatcor=no

    if(ccdrap.flatcor || ccdrap.zerocor){

      if( !usecoords || (coordfile=="" && !access("coord_"//inname//".ord")) || access("coord_"//inname//".ord"))
        ccdrap(inname, version=".2", flat=flatname, coordref=no, coord="")
      else
        ccdrap(inname, version=".2", flat=flatname, coordref=yes, coord=coordfile)

      if(n<=16)
        polrap(n=n)
      if(n>8)
        polrap(n=8)
      if(n>16)
        polrap(n=16)

      if(!ccdrap.flatcor)
        print("FILTER "//filter[i]//" .2: DONE without flat.", >> verbose)
      else if(!ccdrap.zerocor)
        print("FILTER "//filter[i]//" .2: DONE without bias.", >> verbose)
      else
        print("FILTER "//filter[i]//" .2: DONE!", >> verbose)
    }
    else
      print("FILTER "//filter[i]//" .2: ERROR - calibration images not found.", >> verbose)

  }

  coordfile="coord_"//inname//".ord"
  delete (ftemp2, ver-, >& "dev$null")

}


# Bednarski: generate .png modulation graphs:
if(dograph) {
  print("\n# Generating graphs...\n")
  print(graphpol, " -a ", > "roda")
  !source roda
  delete("roda", ver-, >& "dev$null")
}


# Print the sumary of reductions
if(access(verbose)){
  print("\n\n================")
  cat(verbose)
  delete(verbose, ver-, >& "dev$null")
}
else
  print("Nothing done.")


fstruct = ""

end
