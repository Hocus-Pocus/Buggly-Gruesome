MS1/Extra 029y4
===============
Firmware version 029y4 can be tuned with
Megatune 2.25
TunerStudio
MegaTunix

See src\msns-extra.asm for full changelog

For upgraders...

029y4 uses different code for 3bar and 4bar sensors. It fixes an older
bug that caused the maps to run really rich compared to a 2.5bar sensor.
However, if you successfully used an older 029 series code you MUST add a bunch
of fuel to your VE table (maybe 25%) or you will run horribly lean.

If you ran 029b-029q YOU MUST RETUNE YOUR VE TABLE. If upgrading from
earlier codes or using custom sensors and Easytherm you should be just
fine.

Please be sure to read the website - including the setup and FAQ pages.
http://www.msextra.com
http://www.msextra.com/doc

********************************** N O T E ****************************************
Checkout upgrading.txt for upgrade notes.

***********************************************************************************
To download the code to your Megasquirt board double-click on
download-firmware.bat and follow the instructions.

You then need to copy the msns-extra.ini file over to where Megatune can
find it.
Double click on copyini.bat to do this

Megatune needs configuring to set it to MSNS_EXTRA mode. Full instructions
are on the website - link above.


The  Default_files  directory contains example files to load into Megatune.
You can use these to load default settings into Megatune if trialling the
software without a megasquirt connected.
Unless you are just testing the software, never just open Megatune offline 
and start changing settings, always load a default file first or work online.
Then SaveAs to your new MSQ.

The SRC directory contains the source code. If you compile then make
sure you move the .s19 up a level or you will download the old version.

For changelog see msns-extra.asm in the src directory

IMPORTANT!

When first creating a tune, you MUST be connected to the Megasquirt 'online' or open
an existing MSQ file. If you start tuning offline with blank settings you will create huge
problems for yourself.

Come to  www.msextra.com  for support.

Please consider making a donation to the developers.

http://www.msextra.com/doc/donations.html