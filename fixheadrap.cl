#
# Ver. Set06
#

procedure fixheadrap

string files           {prompt="Input filenames (wildcards may be used)"}
struct *flist1
struct *flist2
struct line1

begin

string filei,line
string imagem1,lista
string dia,mes,ano

int i

filei = files

if (filei=="")
	error(1,"Input filename list can't be an empty string...")

lista = mktemp("lista")

files(filei,>lista)
	
flist1 = lista

#i = 0
while (fscan(flist1,imagem1) != EOF) {
#	i += 1
#	print ("# Ploting from WP #"//i//" to WP # "//(i+n-1))
	
# Set the observatory name
	hedit(images=imagem1,fields="OBSERVAT",value="LNA",add=yes,del-,ver-,sho+)

# Correct the date format	
	imgets(imagem1,"DATE-OBS")
	line = imgets.value
	
	dia = substr(line,1,2)
	mes = substr(line,4,5)
	ano = substr(line,7,10)
	
	hedit(images=imagem1,fields="DATE-OBS",value=ano//"-"//mes//"-"//dia,
	      add-,del-,ver-,sho+)
}

del (files=lista,go_ahead=yes, verify=no, >& "dev$null")
#$


flist1=""
flist2=""
line1=""

end
