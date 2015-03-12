#
# Ver. Jul06
#

procedure polrap

int	   n  = 8  {min=4,max=16,prompt="Number of waveplate positions in each group"}
string  type = "dat" {enum="dat|mag", prompt="Input type: .mag or .dat files"}
string  version1=".1" {prompt="Version of the input fits files (output of ccdrap routine)"}
string  version2=".1" {prompt="Version of the input mag files"}
string  rootout    ="w"  {prompt="Root for output filenames"}
string  rootin    =""  {prompt="Root for input filenames"}
string minimum="full" {enum="first|full",prompt="MACROL: minimum? (first,full)"}
string  pout = "00" {prompt="WP position(s) to be ignored. Sintax: # of WP to"}
#bool    format  =no  {prompt="8 WPP in the format 1-4, 9-12?"}
struct *flist1      {prompt="ignore (2 digit number) followed by the list of"}
struct *flist2      {prompt="WP pos. (2 digit numbers) separated by 1 space"}
struct line1

begin

string maglist,magout,namev,arquivo,sufix
string raiz,nps
int    i,j,k,nt,ng
int    nig,lig[100],temp,lwp[16]
real dt

string lixo1,fileout,filein
string line

bool ver,ignore


if (!access(pccdgen.fileexe)){
  print("ERROR: file ", pccdgen.fileexe, " not found!\nVerify and try again.")
  error(1,1)
}


print ("# ATTENTION: don't forget to set the parameters of PCCDGEN before using this script")
print (" ")


#Read the pout parameter
line1  = substr(pout,1,2)
lixo = fscan(line1,nig)

#print (nig)
if (nig > 0) {
	print ("# The following "//nig//" waveplate position(s) will be ignored:")
	for (i=1; i <= nig; i+=1) {
	   line1  = substr(pout,3+(i-1)*3,5+(i-1)*3)
	   lixo = fscan(line1,temp)
	   lig[i] = temp
	   print(lig[i])
	}	   
	print (" ")
#Check whether the WP positions to be ignored are in crescent order
	for (i=2; i <= nig; i+=1) {
		if (lig[i] < lig[i-1]) {
			error(1,"WP positions to be ignored must be in crescent order.")
		}
	}
}



if (n <= 9) {
	nps = "0"//n
} else {
	nps = ""//n
}
if (type=="mag" && version2!=".1")
	sufix = version1//version2//".dat"
else
	sufix = version1//".dat"

	
#Create the magfile used as input for the routine	
maglist = mktemp ("tmpvar")
magout = rootout//nps #mktemp ("tmpvar")
	
if (type == "mag")
	files ("*"//version1//".*mag"//version2, > maglist)
else
	files (rootin//"*"//version1//".dat", > maglist)

flist1 = maglist
i = 0
while (fscan(flist1, lixo1) != EOF) {
	i = i+1
}
nt = i
ng = nt - n + 1
	
print ("# Grouping the "//nt//" WP positions in "//ng//" groups of "//n//" positions")
print (" ")

# Codigo abaixo tirado do reduce da Claudia
	flist1 = maglist
	i = 0
	#
	delete (magout//"*"//sufix,ver-)
	while (fscan(flist1, namev) != EOF) {
	  i = i+1
	  for (j=i; j >= i-(n-1); j-=1) {
	    if (j < 10)
		arquivo = magout//"00"//j//sufix
	    else if ( j < 100)
		arquivo = magout//"0"//j//sufix
	    else
		arquivo = magout//j//sufix
	    if (type == "mag") {
			txdump(namev,fields="image,msky,nsky,rapert,sum,area",
				  expr="yes",>> arquivo)
	    } else {
	    		delete("roda",ver-, >& "dev$null")
#$
			print("cat ",namev,">> ",arquivo, >> "roda")
			!source roda
	    }
#	    print (namev,arquivo)
	  }
	}
	#
	for (j=i; j >= i-(n-2); j-=1) {
	    if (j < 10)
		arquivo = magout//"00"//j//sufix
	    else if ( j < 100)
		arquivo = magout//"0"//j//sufix
	    else
		arquivo = magout//j//sufix
	    delete (arquivo, ver-)
#	    print (namev,arquivo)
	  }
	#
	for (j=-(n-2); j <= 0; j+=1) {
	  arquivo = magout//"00"//j//sufix
	  delete (arquivo, ver-)
#	    print (namev,arquivo)
	  }
	#
	
#reduce (varim="@"//maglist, outdat=magout, interval=n)
#error(1,"bla")


print ("# Running pccdgen & macrol")
print (" ")

dt = 0.
for (i = 1; i <= ng; i += 1) {
# Determine the list of WP positions to be considered in this group
	
	ignore = no
	for(j=i; j<=i+n-1; j += 1) {
		ver = no
		for (k=1; k<=nig; k += 1) {
			if (j == lig[k]) 
# This means that WP j must be ignored
				ver = yes
				ignore = yes #this means that at least one WP was ignored
		}
		lwp[j-i+1] = 1
		if (ver) lwp[j-i+1] = 0
	}
#Make String
	lixo = ""
	for(k=1; k<=n; k += 1) 
		lixo = lixo//lwp[k]
	
#Setup the pospars parameters
pospars.pos_1 = no
pospars.pos_2 = no
pospars.pos_3 = no
pospars.pos_4 = no
pospars.pos_5 = no
pospars.pos_6 = no
pospars.pos_7 = no
pospars.pos_8 = no
pospars.pos_9 = no
pospars.pos_10 = no
pospars.pos_11 = no
pospars.pos_12 = no
pospars.pos_13 = no
pospars.pos_14 = no
pospars.pos_15 = no
pospars.pos_16 = no
if (lwp[1] == 1) pospars.pos_1 = yes
if (lwp[2] == 1) pospars.pos_2 = yes
if (lwp[3] == 1) pospars.pos_3 = yes
if (lwp[4] == 1) pospars.pos_4 = yes
if (lwp[5] == 1) pospars.pos_5 = yes
if (lwp[6] == 1) pospars.pos_6 = yes
if (lwp[7] == 1) pospars.pos_7 = yes
if (lwp[8] == 1) pospars.pos_8 = yes
if (lwp[9] == 1) pospars.pos_9 = yes
if (lwp[10] == 1) pospars.pos_10 = yes
if (lwp[11] == 1) pospars.pos_11 = yes
if (lwp[12] == 1) pospars.pos_12 = yes
if (lwp[13] == 1) pospars.pos_13 = yes
if (lwp[14] == 1) pospars.pos_14 = yes
if (lwp[15] == 1) pospars.pos_15 = yes
if (lwp[16] == 1) pospars.pos_16 = yes


	if (i <= 99) {
		raiz = "0"//i
	} else {
		raiz = ""//i
	}
	if (i <= 9) {
		raiz = "00"//i
	} 
		
	filein  = rootout//nps//raiz//sufix
	if (type=="mag" && version2!=".1") {
		fileout = rootout//nps//raiz//version1//version2 
		if (ignore) fileout = fileout//"_WP"//lixo
	} else {
		fileout = rootout//nps//raiz//version1
		if (ignore) fileout = fileout//"_WP"//lixo
	}
	print ("# Grupo # "//i//". Root: "//fileout//". List: ",lixo)
	
	
	
	delete (fileout//".log", ver-, >& "dev$null")
#$	
	
	pccdgen (filename=filein, nhw=n,deltatheta=dt,fileout=fileout//".log", >& "dev$null")
#$	
	macrol (file_in=fileout//".log",file_out=fileout, minimun=minimum, >& "dev$null")
#$	
	cat (fileout//".out")

	dt = dt-45.
	
	if (dt < -135.) {
		dt = 0.
	}
}

	
	
delete (maglist, ver-,  >& "dev$null")
#$	
#delete (magout//"*",  ver-,  >& "dev$null")
#$
delete("roda",ver-, >& "dev$null")
#$

grafrap.rootin = rootout


flist1 = ""
flist2 = ""
line1  = ""

end

