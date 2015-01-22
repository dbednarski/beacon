#
# Ver. Set06
#

procedure swap(files)

string     files = "*" {prompt="Input files"}
bool		 tcheck= yes {prompt="Check the *real* integration time?"}
real      exptime=0.   {prompt="Optional exptime, keep it 0. if not to be used"}
real          tol=0.5   {prompt="Exptime error tolerance (%)"}
struct *flist1
struct *flist2
struct line1

begin

string filei,temp,lista,line,lixo
string imagem1,imagem2
real	expt,hora,min,seg,exptimage1,exptimage2,dt
real tmin,tmax

filei = files

# Delete first file
del (files=filei//"0000",go_ahead=yes, verify=no, >& "dev$null")
#$

imdel (images=filei//".fits",go_ahead=yes, verify=no, >& "dev$null")

print ("/iraf/extern/beacon/suape"," \"",filei,"\"", >> "roda")
#$

!source roda

delete("roda", ver-)

if (tcheck) {

temp = mktemp("UTS")
lista = mktemp("lista")

files(filei//"*.fits",>lista)
	
hselect(images="@"//lista, fields="UT", expr=yes, > temp)

flist2 = lista
lixo = fscan(flist2,imagem1)
#Define expected exptime
if (exptime == 0.) {
#Get the exptime from the first image
	hselect(images=imagem1, fields="exptime", expr=yes, > "EXPTIME")
	flist2 = "EXPTIME" 
	lixo = fscan(flist2,expt)
	del (files="EXPTIME",go_ahead=yes, verify=no, >& "dev$null")
#$
	if (expt == 0.) 
		ERROR(1,"# ERROR in swap.cl: header keywork exptime=0")
} else 
	expt = exptime
	
tmin = expt*(1.-tol/100.)	
tmax = expt*(1.+tol/100.)	

#print (tmin,tmax)
	
flist1 = temp
flist2 = lista

#Read first line
lixo = fscan(flist1,line)
lixo = fscan(flist2,imagem1)

line1  = substr(line,1,2)
lixo = fscan(line1,hora)

line1  = substr(line,4,5)
lixo = fscan(line1,min)
	
line1  = substr(line,7,12)
lixo = fscan(line1,seg)
	
exptimage1 = 60.*60.*hora+60.*min+seg

while (fscan(flist1,line) != EOF) {
	lixo = fscan(flist2,imagem2)
#Read next line
	line1  = substr(line,1,2)
	lixo = fscan(line1,hora)
	
	line1  = substr(line,4,5)
	lixo = fscan(line1,min)
	
	line1  = substr(line,7,12)
	lixo = fscan(line1,seg)
	
	exptimage2 = 60.*60.*hora+60.*min+seg
	
	dt = exptimage2-exptimage1
#	print(imagem1," ",imagem2," ",dt)
#	print(line,min,seg,exptimage,expt)

	if (dt < tmin || dt > tmax) {
		print ("# WARNING: image "//imagem2//" has wrong exposure time in the header.")
		print ("# Correct exptime: ", dt)
		print ("# This image will be deleted...")
		imdel (images=imagem2,go_ahead=yes, verify=no, >& "dev$null")
#$
	}
	
	exptimage1 = exptimage2
	imagem1 = imagem2
}

del (files=temp,go_ahead=yes, verify=no, >& "dev$null")
#$
del (files=lista,go_ahead=yes, verify=no, >& "dev$null")
#$

}

flist1=""
flist2=""
line1=""

end
