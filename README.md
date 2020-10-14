BEACON PACKAGE
==============

IRAF tools for polarimetry and spectroscopy taken at OPD

Beacon Group page: http://beacon.iag.usp.br/
Reduction tutorial: http://www.astro.iag.usp.br/~bednarski/obs/ixon-tutorial.pdf
General reduction guide: http://www.astro.iag.usp.br/~bednarski/obs/roteiro_reducao.txt


Installing Beacon Package
======================

a. First, install the linux package bc. In Debian-based distributions:

$ sudo apt-get install bc

b. Now, assuming you are inside your IRAF installation directory,
go to ‘extern/’ subdirectory to install the Beacon package and type

$ git clone https://github.com/dbednarski/beacon.git

c. Edit the file ‘unix/hlib/extern.pkg’ inside IRAF directory, adding the
following lines before the line containing the keep command:

reset beacon    = iraf$extern/beacon
task beacon.pkg = beacon$beacon.cl

Open IRAF and compile the .f Fortran codes below.
PS: if you are using a 64-bits Debian-based distribution, maybe you can
skip this step because there are binary files already, which should work
in you computer.

ecl> cd PATH_TO_BEACON_PACKAGE/pccd
ecl> !sudo chmod -R 777 .
ecl> !rm pccd2000gen05.mac.e ccdrap_e.e
ecl> fc pccd2000gen05.mac.f -o pccd2000gen05.mac.e
ecl> fc ccdrap_e.f -o ccdrap_e.e
