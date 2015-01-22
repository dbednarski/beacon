## Sobrescreve um fits 3D (por exemplo, saido do CCD Ikon no modo dinâmico) e escreve
## as imagens individuais (2D)

procedure over3Dfits(image)

string   image="" {prompt="Fits filename (without the .fits, '*' is accepted)"}
struct *flist1 

begin

int i,nframes
string suffix,imag,lista

imag = image

##Gera lista de arquivos a serem processados
lista = mktemp("lista")
files(imag//"*.fits", > lista)

flist1 = lista
while (fscan(flist1, imag) != EOF) {

##retira o .fits do nome
	imag = substr(imag,1,(strlen(imag)-5))

##Apaga arquivos anteriores
#	imdel (images=prefix//imag//"_*",go_ahead=yes, verify=no, >& "dev$null")
#$

	unlearn imgets
	imgets(imag,"NUMKIN")
	nframes = int(imgets.value)
        if (nframes != 1)
          print("# There is a CUBE of data!")
        else {
          imcopy(input=imag//"[*,*,1]",output=imag,verbose=no)
          print ("# Extracting 2D Fits files from 3D File: ", imag)
        }

#	for (i = 1; i <= nframes; i += 1) {
#		suffix = "_"//i
#		if (i < 1000) suffix = "_0"//i
#		if (i < 100) suffix = "_00"//i
#		if (i < 10) suffix = "_000"//i	
#		imcopy(input=imag//"[*,*,"//i//"]",
#		  	output=prefix//imag//suffix,verbose=no)
#	}
}

delete (lista, ver-, >& "dev$null")
#$
flist1 = ""

end
