/* pccd2000.mac.f -- translated by f2c (version 20050501).
   You must link the resulting object file with libf2c:
	on Microsoft Windows system, link with libf2c.lib;
	on Linux or Unix systems, link with .../path/to/libf2c.a -lm
	or, if you install libf2c.a in a standard place, with -lf2c -lm
	-- in that order, at the end of the command line, as in
		cc *.o -lf2c -lm
	Source for libf2c is in /netlib/f2c/libf2c.zip, e.g.,

		http://www.netlib.org/f2c/libf2c.zip
*/

#include "f2c.h"

/* Common Block Declarations */

struct {
    doublereal deltatheta, ganho;
    integer npsky;
} delta_;

#define delta_1 delta_

/* Table of constant values */

static integer c__9 = 9;
static integer c__1 = 1;
static integer c__3 = 3;
static integer c__5 = 5;

/* Main program */ int MAIN__()
{
    /* Format strings */
    static char fmt_2000[] = "(1x,4(f10.6),2x,f8.2,2x,f10.6)";
    static char fmt_3000[] = "((1x,4(f10.6)))";

    /* System generated locals */
    integer i__1, i__2, i__3, i__4;
    icilist ici__1;
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    integer s_wsle(), do_lio(), e_wsle(), s_rsle(), e_rsle(), s_rsfe(), 
	    do_fio(), e_rsfe(), f_open(), i_indx();
    /* Subroutine */ int s_copy();
    integer s_rsli(), e_rsli(), f_clos(), s_wsfe(), e_wsfe();

    /* Local variables */
    static char filename[60];
    static doublereal a[4000];
    static integer i__, j, k, l;
    static doublereal p, q, u, z__[16], readnoise, ae[16], ao[16], ap[10], 
	    sigmatheor, ane[320000]	/* was [2000][16][10] */, ano[320000]	
	    /* was [2000][16][10] */;
    static integer nap;
    static doublereal ske[16], sko[16];
    static integer nhw;
    static char calc[1];
    static doublereal aree[16], areo[16];
    static char line[1000];
    static doublereal skye[32000]	/* was [2000][16] */, skyo[32000]	
	    /* was [2000][16] */, areae[320000]	/* was [2000][16][10] */;
    static char image[12];
    static doublereal areao[320000]	/* was [2000][16][10] */, sigma, 
	    theta;
    extern /* Subroutine */ int polar_();
    static doublereal arease[32000]	/* was [2000][16] */, areaso[32000]	
	    /* was [2000][16] */;
    static integer nstars, nimages;

    /* Fortran I/O blocks */
    static cilist io___1 = { 0, 6, 0, 0, 0 };
    static cilist io___2 = { 0, 6, 0, 0, 0 };
    static cilist io___3 = { 0, 6, 0, 0, 0 };
    static cilist io___4 = { 0, 6, 0, 0, 0 };
    static cilist io___5 = { 0, 5, 0, 0, 0 };
    static cilist io___7 = { 0, 6, 0, 0, 0 };
    static cilist io___8 = { 0, 6, 0, 0, 0 };
    static cilist io___9 = { 0, 6, 0, 0, 0 };
    static cilist io___10 = { 0, 6, 0, 0, 0 };
    static cilist io___11 = { 0, 5, 0, 0, 0 };
    static cilist io___13 = { 0, 6, 0, 0, 0 };
    static cilist io___14 = { 0, 6, 0, 0, 0 };
    static cilist io___15 = { 0, 5, 0, 0, 0 };
    static cilist io___17 = { 0, 6, 0, 0, 0 };
    static cilist io___18 = { 0, 6, 0, 0, 0 };
    static cilist io___19 = { 0, 5, 0, 0, 0 };
    static cilist io___21 = { 0, 6, 0, 0, 0 };
    static cilist io___22 = { 0, 6, 0, 0, 0 };
    static cilist io___23 = { 0, 5, 0, "(a1)", 0 };
    static cilist io___25 = { 0, 6, 0, 0, 0 };
    static cilist io___26 = { 0, 6, 0, 0, 0 };
    static cilist io___27 = { 0, 5, 0, 0, 0 };
    static cilist io___29 = { 0, 6, 0, 0, 0 };
    static cilist io___30 = { 0, 6, 0, 0, 0 };
    static cilist io___31 = { 0, 5, 0, 0, 0 };
    static cilist io___32 = { 0, 6, 0, 0, 0 };
    static cilist io___33 = { 0, 6, 0, 0, 0 };
    static cilist io___34 = { 0, 5, 0, 0, 0 };
    static cilist io___35 = { 0, 6, 0, 0, 0 };
    static cilist io___37 = { 0, 6, 0, 0, 0 };
    static cilist io___40 = { 0, 8, 0, "(a)", 0 };
    static cilist io___51 = { 0, 8, 0, "(a)", 0 };
    static cilist io___56 = { 0, 6, 0, 0, 0 };
    static cilist io___57 = { 0, 6, 0, 0, 0 };
    static cilist io___71 = { 0, 6, 0, 0, 0 };
    static cilist io___72 = { 0, 6, 0, 0, 0 };
    static cilist io___73 = { 0, 6, 0, fmt_2000, 0 };
    static cilist io___74 = { 0, 6, 0, 0, 0 };
    static cilist io___75 = { 0, 6, 0, 0, 0 };
    static cilist io___76 = { 0, 6, 0, fmt_3000, 0 };
    static cilist io___77 = { 0, 6, 0, 0, 0 };



/* 	Calculo da Polarizacao de Estrelas a partir de */
/* 	fotometria de abertura usando qphot ou apphot. */



/*       Numero estrelas        =  2000 */
/*       Numero posicoes lamina =  16 */
/*       Numero aberturas       =  10 */

/*       ano(# estrelas, pos. lamina, aberturas) */



    s_wsle(&io___1);
    do_lio(&c__9, &c__1, "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	     (ftnlen)50);
    e_wsle();
    s_wsle(&io___2);
    do_lio(&c__9, &c__1, "$$$$pccd2000.f VERSION 09/12/02      $$$$$$$$$$$$$",
	     (ftnlen)50);
    e_wsle();
    s_wsle(&io___3);
    do_lio(&c__9, &c__1, "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	     (ftnlen)50);
    e_wsle();

    s_wsle(&io___4);
    do_lio(&c__9, &c__1, "*.dat file to reduce: ", (ftnlen)22);
    e_wsle();
    s_rsle(&io___5);
    do_lio(&c__9, &c__1, filename, (ftnlen)60);
    e_rsle();
/* 	filename = filename(1:index(filename,' ')-1) // '.dat' */
    s_wsle(&io___7);
    e_wsle();
    s_wsle(&io___8);
    do_lio(&c__9, &c__1, "***** FILENAME = ", (ftnlen)17);
    do_lio(&c__9, &c__1, filename, (ftnlen)60);
    do_lio(&c__9, &c__1, "*****", (ftnlen)5);
    e_wsle();
    s_wsle(&io___9);
    e_wsle();

    s_wsle(&io___10);
    do_lio(&c__9, &c__1, "# of stars in the file :", (ftnlen)24);
    e_wsle();
    s_rsle(&io___11);
    do_lio(&c__3, &c__1, (char *)&nstars, (ftnlen)sizeof(integer));
    e_rsle();
    s_wsle(&io___13);
    do_lio(&c__9, &c__1, "No. of stars : ", (ftnlen)15);
    do_lio(&c__3, &c__1, (char *)&nstars, (ftnlen)sizeof(integer));
    e_wsle();

    s_wsle(&io___14);
    do_lio(&c__9, &c__1, "# of waveplate positions observed :", (ftnlen)35);
    e_wsle();
    s_rsle(&io___15);
    do_lio(&c__3, &c__1, (char *)&nhw, (ftnlen)sizeof(integer));
    e_rsle();
    s_wsle(&io___17);
    do_lio(&c__9, &c__1, "No. of waveplate positions : ", (ftnlen)29);
    do_lio(&c__3, &c__1, (char *)&nhw, (ftnlen)sizeof(integer));
    e_wsle();

    s_wsle(&io___18);
    do_lio(&c__9, &c__1, "# of apertures observed :", (ftnlen)25);
    e_wsle();
    s_rsle(&io___19);
    do_lio(&c__3, &c__1, (char *)&nap, (ftnlen)sizeof(integer));
    e_rsle();
    s_wsle(&io___21);
    do_lio(&c__9, &c__1, "No. of apertures observed: ", (ftnlen)27);
    do_lio(&c__3, &c__1, (char *)&nap, (ftnlen)sizeof(integer));
    e_wsle();

    s_wsle(&io___22);
    do_lio(&c__9, &c__1, "Calcita (c) ou polaroide (p) ?", (ftnlen)30);
    e_wsle();
    s_rsfe(&io___23);
    do_fio(&c__1, calc, (ftnlen)1);
    e_rsfe();
    s_wsle(&io___25);
    do_lio(&c__9, &c__1, "Calcita (c) ou polaroide (p) ? ", (ftnlen)31);
    do_lio(&c__9, &c__1, calc, (ftnlen)1);
    e_wsle();

    s_wsle(&io___26);
    do_lio(&c__9, &c__1, "Readnoise - ADU", (ftnlen)15);
    e_wsle();
    s_rsle(&io___27);
    do_lio(&c__5, &c__1, (char *)&readnoise, (ftnlen)sizeof(doublereal));
    e_rsle();
    s_wsle(&io___29);
    do_lio(&c__9, &c__1, "Readnoise - ADU : ", (ftnlen)18);
    do_lio(&c__5, &c__1, (char *)&readnoise, (ftnlen)sizeof(doublereal));
    e_wsle();

    s_wsle(&io___30);
    do_lio(&c__9, &c__1, "Gain - e/adu ", (ftnlen)13);
    e_wsle();
    s_rsle(&io___31);
    do_lio(&c__5, &c__1, (char *)&delta_1.ganho, (ftnlen)sizeof(doublereal));
    e_rsle();
    s_wsle(&io___32);
    do_lio(&c__9, &c__1, "Gain (e/adu) : ", (ftnlen)15);
    do_lio(&c__5, &c__1, (char *)&delta_1.ganho, (ftnlen)sizeof(doublereal));
    e_wsle();

    s_wsle(&io___33);
    do_lio(&c__9, &c__1, "Delta of angle : ", (ftnlen)17);
    e_wsle();
    s_rsle(&io___34);
    do_lio(&c__5, &c__1, (char *)&delta_1.deltatheta, (ftnlen)sizeof(
	    doublereal));
    e_rsle();
    s_wsle(&io___35);
    do_lio(&c__9, &c__1, "Delta of angle : ", (ftnlen)17);
    do_lio(&c__5, &c__1, (char *)&delta_1.deltatheta, (ftnlen)sizeof(
	    doublereal));
    e_wsle();

    if (*(unsigned char *)calc == 'c' || *(unsigned char *)calc == 'C') {
	nimages = 2;
    } else {
	if (*(unsigned char *)calc == 'p' || *(unsigned char *)calc == 'P') {
	    nimages = 1;
	}
    }

    s_wsle(&io___37);
    do_lio(&c__9, &c__1, "Number of images of 1 star: ", (ftnlen)28);
    do_lio(&c__3, &c__1, (char *)&nimages, (ftnlen)sizeof(integer));
    e_wsle();

    o__1.oerr = 0;
    o__1.ounit = 8;
    o__1.ofnmlen = 60;
    o__1.ofnm = filename;
    o__1.orl = 0;
    o__1.osta = "old";
    o__1.oacc = 0;
    o__1.ofm = 0;
    o__1.oblnk = 0;
    f_open(&o__1);

    i__1 = nhw;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__2 = nstars;
	for (j = 1; j <= i__2; ++j) {
/* 			print*, j */
	    s_rsfe(&io___40);
	    do_fio(&c__1, line, (ftnlen)1000);
	    e_rsfe();
	    s_copy(image, line, (ftnlen)12, (ftnlen)(i_indx(line, " ", (
		    ftnlen)1000, (ftnlen)1)));
/* 			print*, line */
	    i__3 = i_indx(line, " ", (ftnlen)1000, (ftnlen)1) - 1;
	    ici__1.icierr = 0;
	    ici__1.iciend = 0;
	    ici__1.icirnum = 1;
	    ici__1.icirlen = 1000 - i__3;
	    ici__1.iciunit = line + i__3;
	    ici__1.icifmt = 0;
	    s_rsli(&ici__1);
	    i__4 = nap * 3 + 2;
	    for (l = 1; l <= i__4; ++l) {
		do_lio(&c__5, &c__1, (char *)&a[l - 1], (ftnlen)sizeof(
			doublereal));
	    }
	    e_rsli();
/*      			print*,a */
/* 			stop */
	    skyo[j + i__ * 2000 - 2001] = a[0];
	    areaso[j + i__ * 2000 - 2001] = a[1];
/* 			print* */
/* 			print*, skyo(j,i) */
/* 			print* */
	    if (i__ == 1 && j == 1) {
		i__3 = nap;
		for (k = 1; k <= i__3; ++k) {
		    ap[k - 1] = a[k + 1];
		}
	    }
	    i__3 = nap;
	    for (k = 1; k <= i__3; ++k) {
		ano[j + (i__ + (k << 4)) * 2000 - 34001] = a[nap + 2 + k - 1];
	    }
	    i__3 = nap;
	    for (k = 1; k <= i__3; ++k) {
		areao[j + (i__ + (k << 4)) * 2000 - 34001] = a[nap + 2 + nap 
			+ k - 1];
	    }

	    if (nimages == 2) {
		s_rsfe(&io___51);
		do_fio(&c__1, line, (ftnlen)1000);
		e_rsfe();
		s_copy(image, line, (ftnlen)12, (ftnlen)(i_indx(line, " ", (
			ftnlen)1000, (ftnlen)1)));
		i__3 = i_indx(line, " ", (ftnlen)1000, (ftnlen)1) - 1;
		ici__1.icierr = 0;
		ici__1.iciend = 0;
		ici__1.icirnum = 1;
		ici__1.icirlen = 1000 - i__3;
		ici__1.iciunit = line + i__3;
		ici__1.icifmt = 0;
		s_rsli(&ici__1);
		i__4 = nap * 3 + 2;
		for (l = 1; l <= i__4; ++l) {
		    do_lio(&c__5, &c__1, (char *)&a[l - 1], (ftnlen)sizeof(
			    doublereal));
		}
		e_rsli();
		skye[j + i__ * 2000 - 2001] = a[0];
		arease[j + i__ * 2000 - 2001] = a[1];
		i__3 = nap;
		for (k = 1; k <= i__3; ++k) {
		    ane[j + (i__ + (k << 4)) * 2000 - 34001] = a[nap + 2 + k 
			    - 1];
		}
		i__3 = nap;
		for (k = 1; k <= i__3; ++k) {
		    areae[j + (i__ + (k << 4)) * 2000 - 34001] = a[nap + 2 + 
			    nap + k - 1];
		}
	    }
	}
    }

    cl__1.cerr = 0;
    cl__1.cunit = 8;
    cl__1.csta = 0;
    f_clos(&cl__1);

    s_wsle(&io___56);
    do_lio(&c__9, &c__1, "REDUCAO CCD", (ftnlen)11);
    e_wsle();
    i__1 = nstars;
    for (j = 1; j <= i__1; ++j) {
	s_wsle(&io___57);
	do_lio(&c__9, &c__1, "STAR #", (ftnlen)6);
	do_lio(&c__3, &c__1, (char *)&j, (ftnlen)sizeof(integer));
	do_lio(&c__9, &c__1, " ******************************", (ftnlen)31);
	e_wsle();
	i__2 = nap;
	for (k = 1; k <= i__2; ++k) {
	    delta_1.npsky = 0;
	    i__3 = nhw;
	    for (i__ = 1; i__ <= i__3; ++i__) {
		sko[i__ - 1] = skyo[j + i__ * 2000 - 2001];
		if (nimages == 2) {
		    ske[i__ - 1] = skye[j + i__ * 2000 - 2001];
		}
		ao[i__ - 1] = ano[j + (i__ + (k << 4)) * 2000 - 34001];
		if (nimages == 2) {
		    ae[i__ - 1] = ane[j + (i__ + (k << 4)) * 2000 - 34001];
		}
		areo[i__ - 1] = areao[j + (i__ + (k << 4)) * 2000 - 34001];
		if (nimages == 2) {
		    aree[i__ - 1] = areae[j + (i__ + (k << 4)) * 2000 - 34001]
			    ;
		}
		delta_1.npsky = (integer) (delta_1.npsky + areaso[j + i__ * 
			2000 - 2001] + arease[j + i__ * 2000 - 2001]);
	    }
	    delta_1.npsky /= (float)2.;
	    polar_(ao, ae, &nhw, sko, ske, areo, aree, &nimages, &q, &u, &
		    sigma, &sigmatheor, &p, &theta, z__, &readnoise);

	    s_wsle(&io___71);
	    do_lio(&c__9, &c__1, "APERTURE = ", (ftnlen)11);
	    do_lio(&c__5, &c__1, (char *)&ap[k - 1], (ftnlen)sizeof(
		    doublereal));
	    e_wsle();
	    s_wsle(&io___72);
	    do_lio(&c__9, &c__1, "   Q        U        SIGMA        P    THE\
TA SIGMAtheor.", (ftnlen)56);
	    e_wsle();
	    s_wsfe(&io___73);
	    do_fio(&c__1, (char *)&q, (ftnlen)sizeof(doublereal));
	    do_fio(&c__1, (char *)&u, (ftnlen)sizeof(doublereal));
	    do_fio(&c__1, (char *)&sigma, (ftnlen)sizeof(doublereal));
	    do_fio(&c__1, (char *)&p, (ftnlen)sizeof(doublereal));
	    do_fio(&c__1, (char *)&theta, (ftnlen)sizeof(doublereal));
	    do_fio(&c__1, (char *)&sigmatheor, (ftnlen)sizeof(doublereal));
	    e_wsfe();
	    s_wsle(&io___74);
	    e_wsle();
	    s_wsle(&io___75);
	    do_lio(&c__9, &c__1, " Z(I)= Q*cos(4psi(I)) + U*sin(4psi(I))", (
		    ftnlen)38);
	    e_wsle();
	    s_wsfe(&io___76);
	    i__3 = nhw;
	    for (l = 1; l <= i__3; ++l) {
		do_fio(&c__1, (char *)&z__[l - 1], (ftnlen)sizeof(doublereal))
			;
	    }
	    e_wsfe();
	    s_wsle(&io___77);
	    e_wsle();

	}
    }
/* L1000: */

} /* MAIN__ */


/* Subroutine */ int polar_(ano, ane, n, skyo, skye, areao, areae, nim, q, u, 
	sigma, sigmatheor, p, theta, z__, readnoise)
doublereal *ano, *ane;
integer *n;
doublereal *skyo, *skye, *areao, *areae;
integer *nim;
doublereal *q, *u, *sigma, *sigmatheor, *p, *theta, *z__, *readnoise;
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    double sqrt(), cos(), sin(), atan();

    /* Local variables */
    static integer i__;
    static doublereal r2, ak, an, r2t, psi[16], sky, raiz, sume, sumo, sumz2, 
	    skyee, skyoo;
    static integer npstar;




    /* Parameter adjustments */
    --z__;
    --areae;
    --areao;
    --skye;
    --skyo;
    --ane;
    --ano;

    /* Function Body */
    sumo = (float)0.;
    sume = (float)0.;
    an = (float)0.;
    sky = (float)0.;
    r2t = (float)0.;
    npstar = (float)0.;
/* 	readnoise=9.86 */
    r2 = *readnoise * *readnoise;
/* 	deltatheta = 91.8 */
/*        deltatheta = 0.d+0 */
    raiz = sqrt((float)2.);

    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	psi[i__ - 1] = (i__ - 1) * (float)22.5 * (float)3.14159 / 180;
	skyoo = skyo[i__] * areao[i__];
	ano[i__] -= skyoo;
	sumo += ano[i__];
	if (*nim == 2) {
	    skyee = skye[i__] * areae[i__];
	    ane[i__] -= skyee;
	    an += (ane[i__] + ano[i__]) / (float)2.;
	    sume += ane[i__];
	    sky += (skyee + skyoo) / (float)2.;
	    r2t += r2 * (areae[i__] + areao[i__]) / (float)2.;
	    npstar = (integer) (npstar + (areae[i__] + areao[i__]) / (float)
		    2.);
	} else {
	    r2t += r2 * areao[i__];
	    npstar = (integer) (npstar + areao[i__]);
	    an += ano[i__];
	    sky += skyoo;
	}
    }
    ak = sume / sumo;
    an /= *n;
    sky /= *n;
    r2t /= *n;
    r2t *= delta_1.ganho;

    *sigmatheor = an / sqrt(an + (npstar / delta_1.npsky + 1) * (sky + r2t));
    *sigmatheor *= sqrt(delta_1.ganho);
    *sigmatheor = (float)1. / *sigmatheor;
    *sigmatheor /= sqrt((real) (*n));
    if ((real) (*nim) == (float)1.) {
	*sigmatheor *= (float)2.;
    }

    sumz2 = (float)0.;
    *q = (float)0.;
    *u = (float)0.;

    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (*nim == 2) {
	    z__[i__] = (ane[i__] - ano[i__] * ak) / (ane[i__] + ano[i__] * ak)
		    ;
	} else {
	    z__[i__] = -(ano[i__] / an - (float)1.);
	}
	sumz2 += z__[i__] * z__[i__];
	*q += z__[i__] * cos(psi[i__ - 1] * 4);
	*u += z__[i__] * sin(psi[i__ - 1] * 4);
    }

    *q /= *n / (float)2.;
    *u /= *n / (float)2.;
    *p = sqrt(*q * *q + *u * *u);
    *sigma = sqrt((sumz2 / (*n / (float)2.) - *q * *q - *u * *u) / (*n - (
	    float)2.));
    *theta = atan(*u / *q);
    *theta = *theta * 180 / (float)3.14159;
    if (*q < 0.) {
	*theta += (float)180.;
    }
    if (*u < (float)0. && *q > 0.) {
	*theta += (float)360.;
    }
    *theta /= (float)2.;
    if (*theta >= (float)180.) {
	*theta += -180;
    }
    *theta = 180 - *theta + delta_1.deltatheta;
    if (*theta >= (float)180.) {
	*theta += -180;
    }

    *q = *p * cos(*theta * 2 * (float)3.14159 / 180);
    *u = *p * sin(*theta * 2 * (float)3.14159 / 180);

    return 0;

} /* polar_ */

/* Main program alias */ int pccd_ () { MAIN__ (); }
