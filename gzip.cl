#
# Ver. Jul06
#

procedure gzip

int     nwav = 8 {prompt="Number of waveplate positions"}
bool    contiguous = yes {prompt="Positions of wave-plate are contiguous?"}
bool    zip=yes {prompt="Yes: zips files; No: unzips files"}

#string  imgref = ""      {prompt="Input reference image"}
#string  images = ""      {prompt="Input images to align"}
#string  shifts = "shifts" {prompt="shifts file"}
struct *flist1
struct *flist2


begin

string temp1, temp2, temp3, temp4, temp5, aa, linedata
struct line1, line2
real   xref, yref, xcomp, ycomp, deltax, deltay
bool   bb=no
int    n=0
int    nlin

bool ver, ver1

int i,j, nw

string diret,raiz
string lixo1
string zeroi,flati
string arq,arqim

	for (i = 1; i <= nwav; i += 1) {
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
		
		diret = "p"//raiz//"0"
		
		print ""
		print ""
		print "# Processing images for waveplate position # "//nw
		
		chdir (diret)
		
		if (zip) {
			!gzip *
		} else {
			!gunzip *.gz
		}	
		
		chdir ("..")
	}
beep

flist1=""
flist2=""
datapars.datamin=INDEF

end

