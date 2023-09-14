# Buggly-Gruesome 
This is a stripped down, no frills version of the MSnS extra 029y4a
 code designed to run a stock or nearly stock 4cyl air cooled VW engine
 with Mexican EFI hardware. It uses a modified Megasquirt V2.2 board and a
 custom relay board and is tuned with Tuner Studio running the 029y4a
 .ini file.
 Text editor is Notepad++. Developement suite is Winide.exe. Firmware is
 loaded with prog08sz.exe and the Megaprogrammer by Patrick Carlier.
 It is absolutely essential that the controller is able to communicate
 with and be tuned with Tuner Studio, so the mainController.ini file has
 not been modified. Other than a cosmetic tidy up the msns-extra.h file
 has not been modified. In order to stay compatible with Tuner Studio all
 the variables and configurable constants have been left in place even
 though only a small fraction of them are actually used.
 The engine uses a degreed crank pully and a 36 minus 1 tooth trigger
 wheel with a VR sensor from CB Performance. The sensor conditioner is in
 the relay board with the coil drivers. Fuel strategy is speed density.
 Ignition is waste spark and injection is sequential paired. Pulse widths
start at 10 degrees ATDC and 10 degrees ABDC. Half the fuel delivered on
an open intake valve and the other half on a closed intake valve. Idle
control is PWM for warmup only. I do not use closed loop AFR control or
decel fuel cut, but the options are still there.


