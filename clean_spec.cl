#
#Version 0.1   May2011
#

procedure clean

bool verify = yes  {prompt="Clean all previous spec. reduction?"}

begin

if (verify) {
  imdel("*norm*",verify-)
  imdel("*comb*",verify-)
  imdel("*00??.0001.fits",verify-)
  imdel("cp*",verify-)
  del("img*",verify-)
}
print("* Check the '.hxxx' and '.cal' files!")

end
