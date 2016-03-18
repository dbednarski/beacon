#
# Ver. Jul06
#

procedure jdrap

int     iw = 1 {prompt="From waveplate position number iw"}
int     fw = 8 {prompt="to waveplate position number fw"}
bool    contiguous = yes {prompt="Positions of wave-plate are contiguous?"}
struct *flist1
struct *flist2
struct *flist3

begin

string line,fileout
string imagem,lista
string diret,raiz
string dia,mes,ano
string lixo1


int i, nw

#LOOP OF THE WP POSITIONS 
	for (i = iw; i <= fw; i += 1) {
		nw = i
		if (contiguous == no) {
			if (i >= 5 && i <=8) {
				nw = nw+4
			}
		}
		if (nw <= 9) {
			raiz = "0"//nw
		} else {
			raiz = ""//nw
		}
		
#ATUALIZAR
		diret = "p"//raiz//"0"
#		diret = "0"//raiz//"0"

		fileout = "../jd0"//raiz
		
		print ""
		print "# Processing images for waveplate position # "//nw
				
		chdir (diret)
		
		print "# Erasing first image..."
		
#ATUALIZAR
		del (files="p*0000",go_ahead=yes, verify=no, >& "dev$null")
#		del (files="0*0000",go_ahead=yes, verify=no, >& "dev$null")

#ATUALIZAR
		imdel (images="p*.fits",go_ahead=yes, 
#		imdel (images="0*.fits",go_ahead=yes, 
		     	  verify=no, >& "dev$null")
#$		

		print "# Performing bit swap"
#Search for first image
		lista = mktemp("lista")
#ATUALIZAR
		files("p*", > lista)
#		files("0*", > lista)
		flist3 = lista
		lixo1 = fscan(flist3, imagem)
		delete (lista, ver-, >& "dev$null")
#$
#ATUALIZAR
		del (files="pp*,hp*",go_ahead=yes, verify=no, >& "dev$null")
#    	del (files="p0*,h0*",go_ahead=yes, verify=no, >& "dev$null")

		swap(files=imagem,tcheck=no)
		
		print ("# Calculating JD and writing it to file jd0"//raiz)
# Set the observatory name
		hedit(images=imagem,fields="OBSERVAT",value="LNA",add=yes,del-,ver-,sho+, >& "dev$null")
#$

# Correct the date format	
		imgets(imagem,"DATE-OBS")
		line = imgets.value
	
		dia = substr(line,1,2)
		mes = substr(line,4,5)
		ano = substr(line,7,10)
	
		hedit(images=imagem,fields="DATE-OBS",value=ano//"-"//mes//"-"//dia,
	      add-,del-,ver-,sho+, >& "dev$null")
#$
		setjd(images=imagem,date="DATE-OBS",exposure="exptime",ra="",dec="",epoch="",
			jd="jd",hjd="",ljd="",utdate+,uttime+,listo-, >& "dev$null")
#$
		
		imgets(imagem,"JD")
		
		delete (fileout, ver-, >& "dev$null")
#$
		
		print(imgets.value, > fileout)

		imdel(imagem,go_ahead=yes,verify=no, >& "dev$null")
#$

 		chdir ("..")
#$

}

flist3 = ""

beep


end

