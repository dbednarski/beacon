# Package script task for the BEACON package


print ('loading necessary packages ...')

language
print ('language')
bool motd = no
stsdas
print ('stsdas')
graphics
print ('graphics')
stplot
print ('stplot')
digiphot
print ('digiphot')
daophot
print ('daophot')
apphot
print ('apphot')
fitting
print ('fitting')
ctio
print ('ctio')
astutil
print ('astutil')
gasp
print ('gasp')
imred
print ('imred')
ccdred
print ('ccdred')
onedspec
print ('onedspec')
twodspec
print ('twodspec')
apextract
print ('apextract')
echelle
print ('echelle')


#set      beacon      = "iraf$extern/beacon/"
#set      beacon          = beacon
#set      specpbeacon      = "/iraf/extern/pccdpack/specp/"


package  beacon
 
#set     helpdb           = "beacon$pccdpack.db"
#set      helpdb           = "beacon$helpdb.mip"

task     macrol           = "beacon$macrol.cl"
task     pccd             = "beacon$pccd.cl"
#task     specp            = "specpbeacon$specp.cl"
task     graf             = "beacon$graf.cl" 
task     pccdgen          = "beacon$pccdgen.cl"
task     plota_pl		 = "beacon$plota_pl.cl"
task     phot_pol		 = "beacon$phot_pol.cl"
task     plota_luz	 	 = "beacon$plota_luz.cl"
task     $phot_pol_e      = "beacon$pccd/phot_pol_e.e $(*)"
task     ccdrap_301 	 	 = "beacon$ccdrap_301.cl"
task     ccdrap 	 = "beacon$ccdrap.cl"
task     polrap 	 	 = "beacon$polrap.cl"
task     pccdrap 	 	 = "beacon$pccdrap.cl"
task     gzip 	 	 	 = "beacon$gzip.cl"
task     swap 	 	 	 = "beacon$swap.cl"
task     analisa 	 	 = "beacon$analisa.cl"
task     grafrap 	 	 = "beacon$grafrap.cl"
task     fixheadrap 	 = "beacon$fixheadrap.cl"
task     jdrap 	 	 = "beacon$jdrap.cl"
task     read3Dfits	 	 = "beacon$read3Dfits.cl"
task     write3Dfits	 = "beacon$write3Dfits.cl"
task     over3Dfits	 = "beacon$over3Dfits.cl"
task	 calib		 = "beacon$calib.cl"
task	 calib_301		 = "beacon$calib_301.cl"
task	 reduce		 = "beacon$reduce.cl"
task	 reduce_spec		 = "beacon$reduce_spec.cl"
task	 reduce_301		 = "beacon$reduce_301.cl"
task	 calib_spec	 = "beacon$calib_spec.cl"
task     clean_spec      = "beacon$calib_clean.cl"
task     pospars          = "beacon$pospars.par"
task     reduce_mus = "beacon$reduce_mus.cl"
task     calib_mus  = "beacon$calib_mus.cl"
task     tests       = "beacon$tests.cl"
task     logpol          = "beacon$logpol.cl"


type beacon$welcome


clbye ()
