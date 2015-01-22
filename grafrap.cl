#
# Ver. Set06
#

procedure grafrap(starin,aperturein,n,version1,rootin)

int    starin=1        {prompt="Star number to analyze"}
int    aperturein=8    {prompt="Aperture to analyze"}
int	  n  = 8  {min=4,max=16,prompt="Number of waveplate positions in each group"}
string version1=".1" {prompt="Version of the fits/dat files"}
string version2=".1" {prompt="Version of the input mag files"}
string rootin    ="w"  {prompt="Root for polrap filenames"}
struct *flist1
struct *flist2
struct line1

begin

string nps,sufix,lista,lixo
string imagem1,root

int i

int starini, apertureini, ni

starini = starin
apertureini = aperturein
ni = n
root = rootin

lista = mktemp("lista")

if (ni <= 9) {
	nps = "0"//ni
} else {
	nps = ""//ni
}
if (version2!=".1")
	sufix = version1//version2
else
	sufix = version1

files(root//nps//"*"//sufix//".log",>lista)
	
flist1 = lista

i = 0
while (fscan(flist1,imagem1) != EOF) {
	i += 1
	print ("# Ploting from WP #"//i//" to WP # "//(i+ni-1))
	graf(filein=imagem1,starin=starini,aperturein=apertureini,postype-,meta-)
	
	print ("Hit enter for next .log file")
	lixo = scan(lixo)
}

del (files=lista,go_ahead=yes, verify=no, >& "dev$null")
#$


flist1=""
flist2=""
line1=""

end
