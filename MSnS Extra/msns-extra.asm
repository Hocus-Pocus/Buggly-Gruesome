***************************************************************************
***************************************************************************
** MegasquirtnSpark - extra  + enhanced
** by James Murray (james@nscc.info)
** and Phil Ringwood (philip.ringwood@ntlworld.com)
**
** IMPORTANT!!! Complain to us, not the orignal authors whose code we have used.
**
**
** Adds lots of new features, see the website for details
** http://megasquirt.sourceforge.net/extra
**
** 006 looks ok on stim. Simulated crank signal on middle LED
** coil outputs on top and bottom
** 007 - make simulator a config option. Can only be changed at compile time
**       at present. May need to implement paged tables in future.
** 008 - added 'S' signature command
** called it MSnS-extra009  - software config of code type via Megatune
** userdefined can choose between MSnS / Neon with or without crank simulator
**
** Think coila and coilb are transposed for some reason? FIXED
** 010 fix bug that caused MSnS mode not to work. Interrupt disarm/re-arm
** was half implemented
** 011 add initial support for 36-1 and 60-2 wheels (simulators)
** 012 jumped onto multiple tables
**     VE tables+req fuel will be flash or RAM. All other constants flash only
**     Initial page allocation: 0 variables ; 1,2 fuel ; 3 spark
** 012d try spark as 10x10. Not yet supported by MT so put back to 8x8
** 013  start rolling in DT code - pretty radical changes!!
** 014  Extended spark table to 12x12. OK on scope. Injectors to fix.
** 014b no. squirts + mode always from table 1. Alternating only in single table.
** 014c Added 10deg timing offset and start of EDIS support
** 014d fixed up rev limiters. dropped cool off period and removed duplication
** 014e  work on 36-1 decoder
** 014f  fix up FIDLE spark output
** 014h  kpa fix by Phil
** 015b  changes to DT mode selection
** (changelog continues lower)
***************************************************************************
***************************************************************************
***************************************************************************
**   Added MSnS-Enhanced functions to James' MSnS-Extra -  P Ringwood
**   (Aug 2004)
**
**   I/O Structure:
**
**   X0 - Flyback
**   X1 - Flyback
**   X2 - Water Injection Pump Output
**   X3 - Water Injection Pulsed Output @ Injector #2 rate
**   X4 - Output 1
**   X5 - Output 2
**   X6 - EGT Input (0-5V)
**   X7 - Fuel Pressure Input (0-5V)
**
**    TOMI HEADER JP1
**    Pin 4 - Launch control Input (Low Active)
**    pin 5 - Knock Input (Low Active)
**    pin 6 - NOS System Feedback (low active)
**
**    Added knock detection system: See help file for details or the
**    knock part of the code
**    Knock detected on pin 5 of the HEADER TOM (JP1) when it is low it
**    detects a knock
**
**    Added an Ignition Advance relative to Coolant temp
**
**    The Launch Control has been Modified with an idea by Matt, now you
**    have the option of a variable hard cut rev limit point. If its
**    selected in MT then the rpm the engine is running at when the
**    launch button/switch is pressed is set as the hard limit. this
**    is to enable you to alter the setting at the track without having
**    to get the laptop out. I wouldnt recommend this with a clutch switch
**    as every time you put your foot on the clutch it will take in the
**    rpm and use that as the limit, I would use a thumb switch or
**    something similar as the launch switch.
**
**    If you dont like it just select it off in MT:-)
**
**    Added an Over boost protection rev cut and soft cut settings
**
**    Added Water Injection Control comes on when IAT and boost above
**    set-points
**    Water pump output (X2)  Pulsed output @ injector #2 rate to fast
**    acting solenoid (X3)
**
**    Added fuel pressure monitoring (X7) and EGT monitoring (X6)
**
**    Added Target AFR's (Dave Edge's Code) <45KPa  >90KPa (Full closed
**    loop mode)
**
**    Added Ignition Retard with IAT temperature at a rate of
**    1 degree retard / user defined degrees of IAT (thanks to Eric
**    for his help)
**
**    KPa open loop for O2 added, optional between Throttle or KPa
**    Throttle Position Open loop is now adjustable.
**    N.B. Only works when not in "Target AFR Mode"
***************************************************************************
* 015c Weird spark and irq led glitch that has been present for a number of
*      releases now 99% fixed with some tweaks to TIMERROLL
*      Cranking advance calc fixed (was 10deg offset)
* 015d Make high/low speed spark calc based on cycle time not fixed rpm so
*      it works at the right set point for any number of cylinders
*      Support for 1-8 cylinders even-fire now. 9+ don't work
*      Made ve1x,2,3 into macro instead of subroutine to save a little stack.
* 015d4 Try to optimise 8,10,12,16. Assume 9,11,13,14,15 illegal.
* 015d5 Rectify some spark calc errors to do with 10deg offset
* 015e  Move code to 8MHz (altered burner.asm too)
* 015e1,2 Add EDIS support (timing 1-2 retarded at low advance for some reason)
* 015e3  Dual EDIS
* 015e4  some fixes by PR
* 016    Added Fan control from MSnEDIS. Left retard input for now.
* 017a   Changed from "A" = 31 back to 25 and added "a" = 31 for enhancements
* 017b   Added seperate fuel and spark cut selections for launch and revlimiter
*        also option for the base number to cut sparks from. - PR
* 017c   Added Roger Enns' Staging Injection System - PR
* 017d   Changed the Barometric Correction so as it can be set to a max KPa and
*        a min KPa value, incase of a processor reset during running. - PR
* 017e   Bug fix for PW1 in DT Mode
*        Added a second O2 sensor option to run EGO on VE Table2
*        and page2 enrichments. - PR
* 017e1  Added fuel and or spark cut to over boost protection - PR
* 017e2  Added cli to P and B SCI routines to help stumbles when using MT
* 017e3  ??????
* 017e4  Boost Control check added before doing output1 as same pin used - PR
* 017e5  Tidied up some DT functions (ASECnt EgoCnt) - PR
* 017e6  Added NOS Anti-turbolag - PR
* 018    Added another 12x12 spark table. Can be used with NOS or Just
*        with JP1 Pin6 input, this can be switched in on the run. -PR
* 018a   Changes to Neon code to keep ign outputs on right channel
* 018b   (aborted changes to Neon code to make 24bit hi-res timer)
* 018c   Changes to TIMERROLL. Just add on 0.1ms to current value.
* 018d   More optimisation on cycle calcs in TIMERROLL to speed it up
* 018e   Moved NOS and Staging PW checks to main routine - PR
* 018f   Added adjustable timer for Spark Table 2 to cut in at after input on. - PR
* 018g   Can turn off Magnus' false trigger fix (test option)
* 019    Added to VE table 1 to make it 11x11 - PR
* 019a   Went to 12x12 for VE table1 - PR
* 019b   Both VE tables now 12x12 - PR
* 019c   Idle PWM Bug fix. Added a window operation to the Outputs 1 and 2 - PR
* 019d   Changes to Target AFR, to allow tps to change target when MAP >90KPa
*        Also added VE table 3 for use with the extra Spark Table - PR
* 020    Changes to target afrs so now it has user setpoints for the KPa points.
*        Increased pages to 8, removed page8 = 0 as per James' instructions - PR
* 020a   Made output duty cycle configurable 50%/75% Mod to EDIS so
*        "zero delay" is now 64us I found the output unreliable before.
* 020a1  Change to EDIS multispark mode. 2048us always sent during crank
*        (fixed 10BTDC)
* 020b   Added 12x12 afr target table to both VE tables 1 and 3.
*        Removed D.Edge's Targets - PR
* 020c   Bug fix for prime pulse, was always 25.5mS. Added priming pulse
*        after 2 seconds
*        option and Prime pump without prime pulse and 2 x priming pulses
*        option. - PR
* 020d   Anti-Rev System added, crude Traction Control. - PR
* 020e   Refined Anti-Rev system, fixed a few bugs in it, working well
*        on stim - PR
* 020f   Bug fixes to Boost Controller - PR
* 020g   We think 12x12 AFR targets is confusing, so brought it down to 8x8.
*        Added RPM to Boost Controller and Knock can now remove boost
*        via Boost conroller - PR
* 020h   Optimisation of the header file for the enhanced stuff, to stop
*        stack over writing - PR
* 020i   Rolled JSM strand 020a+020a1 into this release. Added multi-spark
*        set point
* 020j   True (crude) dwell control for MSnS needs more testing
*        Next cylinder mode if < 20 deg trigger angle. Part way to TFI.
* 020k   Some changes to the Anti-Rev system - PR
* 020m   Now Anti-Rev has a counter for counting engine cycles - PR
* 020n   Changes to make the AFR target in AFR rather than volts - PR
* 020o   Reorganised position of AFR inc files, added speed inputs and
*        calculations to Anti-Rev - PR
* 020p   Removed all WB inc files, no need to have incs MT can do it now.
*        Also changed the outputs so as all can be inverted, should have
*        done this a while ago.
* 020p1  Added page zero check and reload all the feature bits - JSM
* 020p2  Removed wheel ENcoders. Accel/decel ctime correction in DOSQUIRT
*        At high rpm dwell period reduces to minimum 0.2ms off time
*        Changed output state in bootload and stall mode to avoid
*        overheating coil - JSM
* 020p3  (ignore testing stack)
* 020p4  Traction and AFR changes - PR
* 020q   7pin HEI - JSM
* 020r   Removed toothsync, ignore_small,HoldSpark variables. See notes in .h
*        Changes to Neon for low speed
* 020r3  Continue Neon (works)
* 020r4  Added Megaview fix to 'A' command
* 020s   Added ability to switch to targets above tps setpoint and Alpha-n.
*        Re-organised Spark Angle Additions to clear a byte from the h
*        file and limits minimum angle to MSnS or
*        Edis limit - PR
* 020t   Combined 020s and 020r branches. Took out some of the limits
*        from 020s as it didn't work?
* 020t1  Fixed the Limits in subracting nos, etc, angles (BCS rather than
*        BMI, thanks James) - Phil
* 020t2  Bug fix to the Shift Light code. - Phil
* 020t3  PWM idle warmup open loop
* 020t4  Cranking mode blocked until stall or restart (For low rpm rock
*        climbers)
* 020i1  turn off DOSQUIRT cli, interrupt protection in TIMERROLL
* 020i2  turn off TIMERROLL cli
* 020i3  Bandaid for rpmp/rpmc calc to stop drop to zero. MV fix
* 020i4  Undid i2 change
* 020i5  Check to see if we missed a 0.1ms int during 0.1ms, if we did
*        then repeat section
* 020i6  Removed i3 bandaid. Added hi speed/low spd LED
* 020i7  Changed hi/low speed calc to MSnS style rpm based
* 020i7a Commented 'ACK IRQ' in TIMERROLL - fixed stumble?!?!?!?!?!
*        No spikes visible.
* 020i8  Revert to ctime based hi/low selection. Keep ACK commented.
* 020i9  Fixed real issue, I'd changed re-enabling around RPMLOWBYTECHK,
*        put back to std)
* 020u   Included all fixes from 020i9
* 020v   Try to support Page Chunk write
* 020v1  Small boost controller changes (Matt Dupuis idea)
* 020v2  Added interpolated allowable traction slip and traction indicator
*        to OUTPUTS - PR
* 020v3  Fixed up chunk write "X" command.
* 020v4  Added hysterisis to outputs 1 and 2 - Phil
* 020w   Added two new tables for 3d mapped boost control
* 020w1  Textual config error messages
* 020w2  Looking at Neon mode. Fixed silly error in .asm + .h
* 020w3  Boost controller changes
* 020w4  Make flood clear TPS setting configurable
* 020w5  Rolled out NOS and Knock subraction of angles and BCS changes
*        to cure int miss - PR
* 021    new version number. Changed signature.
* 021a   Timing angle error crept in at 020w5. Fixed.
* 021b   Added 1 second delay before cant_crank applied. Stall timer now
*        0.25s if not cranking.
* 021c   Send the ports a-d in realtime data
* 021d   Added facility to cut decel enrichment when above user setpoint
*        in KPa, and added timer to over run - PR
* 021e   Added 300 KPa sensor capability - PR
* 021f   Make 7.37MHz again for MV testing, only partial change. 0.1ms
*        and EDIS calc untouched
* 021f1  Back to 8MHz. Code now sets MV mode if we receive an 'A' command.
*        Then W is ignored
*        to save corrupting data and V returns 125 zeros.
* 021f2  Make Megaview emuluation mode the default until S,P,R,X received
* 021f3  Increase running stall timeout to 0.5s
* 021g   Fix to 300kpa baro correction and make it one-shot - PR
* 021h   Change stall timeout so FP runs as normal on startup and 0.5s
*        stall limit only comes into effect once we've left crank mode for sure
* 021i   Yet another fix to 300KPa stuff and added 400KPa sensor capability - PR
* 021j   Added an IAT related boost reduction to the boost controller,
*        fixed bug in ASE - PR
* 021k   Added another 6x6 boost table KPa based to switch to on the run - PR
* 021l   Another output added, LED18 can now be reused for output4 or for
*        Fan Control as well as X2 - PR
* 021m   Bug fix to Fixed Angle, found MT not sending a perfect #00 when
*        -10 deg set so now we check if its lower than #03 - PR
* 021n   Finally managed to get the adv angle limit for traction control
*        to work - PR
* 021n1  Rolled back some of the code to how it was in 021h/021i, to fix a
*        Neon problem - LJ
* 021o   Fixed Fuel Pump prime timer and interpoled prime now works on
*        first pulse - PR
* 021p   Cranking PW can use CLT or MAT or average (hot start on cold
*        day issues)
* 021q   Generic wheel decoder, started LED18.
* 021q1  Looking good. Added third wasted spark coil output on middle LED
* 021q2  Mode was hard coded to wheel decoder, fixed
* 021q2  Make <21 teeth use low-res timer for decoding
* 021q3  Fixed a bug preventing time based cranking working with wheel
*        decoder in ChkHold
*        Tidied up a few sections in that area to remove some bra.
*        Increased Neon initial sync from 3 pulses to 5.
*        Fixed a silly error that stopped low-res from working (add
*	instead of adc)
* 021r   Added "late leading" feature. Sort of works?
*        No O2 correction in Overrun fuel cut mode
* 021s   Over flow fixed by adding supernorm into calculations - PR
* 021t   Undid 021n1 cranking changes. Looks ok on stim.
* 021u   Toyota DLI ignition multiplex output. D17 is IGt, D19 is IGdA,
*        D18 is IGdB
* 021v   Tiny MV/Megatunix compatability tweak. Added 'T' Text version of
*        release.  Send back some real data to MV 'V' command to get
*        correct map reading with 4250 sensor.  Add low speed check for
*        wheel decoders to prevent false sparking at too low rpm
*        Make trigger return cranking only apply when cranking, not when "slow"
*        Took out en_ack and falsetrig advanced options
* 021w1  Changes to spark output selection, big tidy up into macro and
*        new hei4 dwell setting
* 021w2  Remove some feature ram variables to make space for dwell timers.
* 021w3  Tried a super short 5us dwell for HEI - didn't work.)
* 021w4  The trigger return for cranking only fix broke the Neon decoder. Oops.
* 021w5  Included Lee's crank phase fix for Neon mode. Fixed low speed spark.
*        Two line error in dwell timer code was to blame.
*        Dwell and multi outputs still not working, needs more resolution.
* 021w6  Added config checks for wasted spark outputs, more work on dwell.
*        Make 75%,50% what they say when in wasted spark
* 021w7  Removed RAM copies of feature3,4,5,6 to allow more space. All
*        features need re-testing
* 021w8  Made dwell timers 16bit. Had to stack h in TIMERROLL and SPARKTIME.
*        Beware of stack overflow.
* 021w9  Combination of HEI4 + real dwell. Can choose to turn coil on at
*        trigger during cranking
* 021w10 Added MV compatability to 300 and 400 KPa sensors, limit is 255KPa,
*        untested - PR
* 021w11 Cosmetic change only
* 021x   Added compatability with Eric's Aceleration Wizard in MT and bug
*        fix to Knock angle - PR
* 021x1  Added MAPlast and TPSlast into real time variables sent to MT - PR
* 021x2  Re-write of Neon section. This is designed to improve cranking
*        decoding. - LJ
* 021x2  fixes were merged in later by JSM)
* 021x3  Fix to check7 section for 3 spark outputs. More work on dwell
* 021x4  Added accel/decel correction for dwell. (try to fix wacky HEI7
*        behaviour)
*        add check for missed sparktime, caused by 'early' trigger
* 021x5  When in "low speed" and doing dwell control, schedule dwell at same
*        time as spark
*        In "high speed" the dwell control is still poor during varying rpm
* 021x6  Bug fix to MAP based Accel stuff,added decel as a seperate option
*        for MAP or TPS - PR
* 021x7  Added coolant check to over run fuel cut off and decay to accel
*        enrichment - PR
* 021x7a No code changes just comments added to the Flash area for tuning
*        software writters to see whats where - PR
* 021x8  Really fixed(?) spark output checking in check7 and added
*        another couple of checks on the outputs
* 021x9  Bug fix to Accel decay also added X6 and X7 checks to Outputs
*        1 and 2 and the facility to have output3 switch on if Output1
*        and Source or Output2 on- PR
* 021x10 Another bug fix to Accel Decay - PR
* 022    Re-arranged/shrunk data tables to give more variable space - PR
*        Renamed to 022 because data format is incompatible.
* 022a   Made min nitrous rpm for interpolated fuel a user setting - JSM
*        Fix to nitrous duty cycle cut - JSM
*        Added Ryan's PWM idle improvements (using diff 021u vs 021u-idle)
*        and made settings flashable. Not tested yet - JSM
* 022b   Removed InjOCFuel_f 1 and 2 from code as not used and causing
*        trouble in MT - PR
* 022b1  Fix to V command, was sending 212 rather than 200, thanks Dave - PR
* 022b2  More comments added for Tuning software writers - PR (No code changes)
* 022c   Added Table for cranking Pulse Widths - PR
* 022c1  Bug fix to Priming PW in table mode - PR
* 022d   Added Table for ASE - PR
* 022d1  Slight change to outputs to allow it to work better with MTx - PR
* 022e   Dwell calc based on batt voltage
*        Reduce multiplication of period correction
*        Dwell delay timed with hi-res timer where dwell period fits
*        between trigger and spark
*        (to-do: change spark cut/hold spark to omit coil on instead of
*        coil off)
*        Testing required. Wheel decoder looks odd, but could be test
*        bench not code?
* 022e1  Changed some comments for Tuning Software writters - PR
* 022e2  More comments for software writters, grrrrrr :-) - PR
* 022e3  Entire msns-extra.asm file comments cleaned and beautified.
*        comments are now tabbed and a best effort has been made to keep
*        them from wrapping over an 80 col display and to keep them as close
*        to lined up as possible.   Only 1 code change in load_table: to
*        switch to 201 from 212 - DJA 02-15-2005
* 022e4  Bug fix found by DJA after comments - PR
* 022f   Added lineto clear megaview compat mode when a "P" command arrives
*        handles the case where the ecu resets in use, it'll go back to
*        enahanced mode. upon recept of next P cmd. should help megatune
*        and megatunix. (megatunix detected it)
* 022g   work on moving some dwell calcs to mainloop to avoid dropouts in wheel decoder mode
*        Added equates in .h to allow temp storage in burner ram area (when
*        not burning of course!) e.g. DOSQUIRT, TIMERROLL, SPARKTIME
*        Revised check at end of TIMERROLL to avoid missing the next int
* 022h   Added the ability to turn accel enrich off during ase - PR
* 022i   Major movement and optimising of main loop, removed items like fuel and spark
*        calculations from being done within a subroutine. - PR
* 022i1  Even more optimising of main loop - PR
* 022i2  ? - PR
* 022i3  Uncommented some CLIs in TIMERROLL and commented some in "B" command.
*        Also some CLI taken out of burnconst (burner8b.asm) to ensure that nothing
*        can clobber the burner ram while it is in use. Hopes to fix serial comms
*        symptoms since 022g
* 022i4  Replaced a line that got deleted in error.
* 022i5  Bug fix for DT, makes single table modes better too - PR
* 022i6  Removed old ASE settings and Cranking PW, all done with the tables now - PR
* 022i7  Bug fix for DT, req_fuel ram not correct and ALT/SIM removed from VE2 - PR
* 022j   Moved Page2 in line with Page1 so RAM lines up again, so rolled out 022i7 fix,
*        Also made the new output bits after secl + 30 - PR
* 023    Rolled code version forward as Page 2 moved in 022j - PR
* 023a   Added the facility to have normal Prime Pulse and interpoled, also added IAT
*        check when firing up ADC so its stored ready for Prime Pulse Calcs - PR
*-> 023b released by Phil.... code not in here yet <-*
* 023c1  Spark changes
*        Rename some variables, HRcTime -> global iTime, next cyl mode cleanup to
*        remove nasty hack. Should work on any num cyls now.
*        Extended T2 to 24bits in software, very small overhead every 65ms
* 023c2  Send iTimeX out with realtime data so hi-res rpm calc gauge works at all rpm
*        iTime to get zeroed on stall. Why no fuel < 100rpm? A fix in place
*        Make dwell settings in 0.05ms. Do period calcs in us then convert to 0.1ms
*        afterwards. Hope to reduce jittering of dwell period when predicting many
*        periods ahead
* 023c3  More of the same
* 023c4  Fix what got broken in wheel decoder
* 023c5  Include Phil's 023b fixes
* 023c6  Fixed up my typos in Neon section
*        Bumped up default values for very cold crank PW and ASE to give users the idea.
*        These tables should have a 1/x type decay, really ramping up when cold.
* 023c7  Next cyl low rpm/dwell issue? Set spark angle as trigg angle when NC/cranking
*        iTime calc was getting missed
* 023c8  Make spark output pos/neg a quick byte for tiny speedup in ints
* 023c9  Added second input for wheel decoder in pin10
* 023c10 Change ddrc only the fly after a B. Put output on correct pin!
* 023c11 10deg offset in next cyl displayed crank angle
*        Known limitation. Next cyl and wheel decoder do not work correctly
*        I'll look into this as it could be great for dual VR pickup bikes
* 023c12 At ~500 rpm seeing phantom misdecoded outputs. Can't be sure if this
*        is real or testbench. Seems ok now with no code changes??!
* 024    Same code new name
* 024a   Changes to HEI7 bypass code to be closer to GM
* 024b   Added Fixed ASE period to ASE - PR
* 024c   Added fixed VE value period during Fixed ASE timer and jump past warmup
*        section if its not needed to save some time - PR
* 024d   Changed from fixed VE to fixed MAP during ASE, also tidied up the spark-fuel
*        cut options as they were difficult to fault find - PR
* 024e   Changes to 300-400KPa stuff, added supernorm to the calcs - PR
* 024f   Increased hires/lowres dwell margin aiming to eliminate observed problem
*        as the dwell start point goes earlier than the trigger
*        Fixed a silly typo (JSM) that had broken Neon - JSM
* 024g   Removed one shot from error message so MTx can display errors, also
*        added the 300-400KPa fix to the DT stuff - PR
* 024h   Add an option to allow better testing of wasted spark outputs on the stim.
*        It takes the normal tach input and steps through the outputs. DO NOT USE
*        ON THE CAR!
* 024h1  Block v.low speed misdecoding for wheel and add a failsafe "turnallspkoff"
*        in the mainloop when not running
* 024h2  Had to make the error message one-shot again or it cocks up Megatune
* 024i   Moved sparkcut to cut dwell not spark to avoid module overheating
* 024i2  Start of output support for twin rotor
* 024i3  Increased hires/lowres dwell margin as missed sparks still evident
* 024i4  More twin rotor. Fixed 1ms split working for testing.
* 024i5  Added maps for split, not used yet
* 024i6  Added vars to use split map and fixed split for testing
* 024i7  Inital checks for rotary outputs
*        Got it working on scope both with fixed and mapped split
*        Changed the way trigger return is used in MSnS slightly (PR reported problem)
* 024i8  Dwell was half what it should be due to remenants of test code
* 024j   Fix to 3-400KPa stuff - PR
* 024k   Ensure all spark outputs are inactive at power on
* 024l   Fixed the IAT from being altered during fixed MAP - PR
* 024l2  Fixup wheel decoding not picking up. Fixup excessive dwell at cranking rpm
* 024l3  Rotary - make sure trailing coil is off when it ought to be.
*        Dwell is still imperfect under changing rpm
* 024m   Bug fix to second O2 sensor correction limit - PR
* 024n   (024l3 change got lost.. put back in)
*        Wheel decoder fix used mask of $3f, should have been $5f
*        Changed dwell calcs a bit, found that accel/decel correction wasn't
*        working because iTimep wasn't being stored correctly
* 024n2,3,4,5 internal releases
* 024o   DT test to see if alt - sim modes work (worked OK)- PR
* 024p   Added the 3-400KPa fix to the DT code - PR
* 024q   Work on wheel decoder sync issue. Works on scope. To be tested on bench.
*        Now picks up 36-1 on bench fine. Trigger return with dwell gives odd
*        results.
* 024r   Added personality checks to spark stuff, if personality = 00 then no spark
*        stuff needs to be run. Tidied up a few bra instructions to jmp - PR
* 024s   Added the ability to use the MAP sensor as constant baro corr when in
*        alpha-n mode - PR
* 024s1  Realised constant baro wasnt what was needed, it was the KPa calcs,
*        so added that to the calcs as an option for alpha-n - PR
* 024s2  Test code - added bandaid to check if 0.1ms got missed, fire off in mainloop
* 024s4  Test code make dwell delay fixed 1ms - no dropouts
* 024s5  Remove unused UMUL32
* 024s6  Check for negative iTime caused by missed T2X increment
* 024s7  Forgot to remove fixed 1ms..
* 024s8  False trigger protection was still commented out
* 024s9  Odd fire averaging back into code (was never in MSnS)
* 024s12 Wheel decoder false trigger protection at tooth level.
*        Rolling filtered average tooth time stored. If IRQ trigger comes far too
*        early then must be a false trigger, gets ignored. Missing tooth period
*        also compared to rolling average instead of just previous period.
* 025a   Logging of wheel decoder teeth time - page 9 ($F0)
* 025b   Logging of "trigger" time - page 10 ($F1) Data reduced to 99 x byte pairs
*        199th byte is pointer to next byte to be written
*        200th byte low bit =0 for us, 1 = 0.1ms units
* 025c   Added hysteresis to Rotary split and other trailing fixups
* 025d   Include Ryan Davidson idle code. Add configurable tach output
* 025e   Hopefully included all of Ryan's code this time.
* 025f   Added a way to trigger extra cranking fuel by making TPS go above floodclear
*        3 times whilst engine not running or cranking. - PR
* 025g   Added a RPM based Accel Enrichment, triggers from MAP or TPS as usual, but
*        the fuel added is based on the engine rpm not rate of change. - PR
* 025g1  Small change to RPM AE - PR
* 025g2  Added a check to see if RPM AE lower than decay value also bug
*        fix to AE stuff - PR
* 025h   Rolled in Ken Culver's (KC) rotary fixes that were against 025e
* 025i   Big changes to the way dwell is handled when multiple coils are used.
*        When Launch is on, nitrous is off.
* 025i3  Work in progress. Make dwelldelay1,2,3,4 work from flash for testing only.
*        CalcSpk dwell working as expected.
* 025i4  Test dwelldelay1,2,3,4 calcs
* 025i5  Dwelldelay calcs fixups. Looks ok on scope and in logged debug data.
* 025i6  Removed debug data from "R" command
* 025j   Moved the RPM based AE stuff to a different page - PR
* 025j1  Warmup Idle bug fix, in Warmup mode only - PR
* 025j2  Fixup fixed "dwell" duty cycle for single output - JSM
* 025k   Merged in KC's 025i6mod rotary changes - JSM
* 025l   Added Mass Air Flow Meter as an option for fuel calculations - PR
* 025l2  Bug fix to Idle PWM as noticed by Caaarlo - PR
* 025m   Bug fix in major error to KPa and MAF stuff - PR
* 025n   Poor wheel pickup after stall. Tiny change in stall section.
* 025n1  If >20 teeth then 3/4 rolling average else use last tooth
* 025n2  Zero lowres on stall
* 025n3  Don't check for false triggers in wheel until synced up
* 025n4,5,6,7  Working on dwell calc + dwell accel correction. Sign was wrong
* 025n8  Reduced amount of accel factor added in all those sections of dwell delay calc.
* 025n9  Removed "double it in accel" dwell correction
* 025p   Bug fix for Hot Idle PWM - PR
* 025q   Added Air Density Factor as an option for MAF stuff - PR
* 025q1  Added Constant Baro Correction using a Standard 4250 map sensor on X7 - PR
* 025v   Changes to IAT air density, now uses CLT sensor too - PR
* 025v1  Bug fix to IAT correction air density, have to do airtemp calcs first - PR
* 025w   Changed fixed Temperature values to variable in coolant Air Density - PR
* 025x   Roll in KC's Idle-advance code and revert a few small changes from 025k, 025n9
*        For testing purposes, make hi-res dwell optional
* 025x1  Typo in "fix"
* 025y   Flat shift and launch have own limits
*        Launch to nitrous on delay, flat shift to nitrous on delay
*        Start of nitrous fuel hold-on in code.
* 025z   Flat shift has own retard limit and setting.
* 026a   Next-cyl railing at trigger fix from Baldur.
* 026b   Minor tweak to when SparkAngle gets saved for better next cyl stability at low advance
*        Config option to bypass "new" 025 wheel decoder element
* 026c   SparkD now gets turned off in stall. Soft rev limiter fixed.
*        SparkAngle now stored once all calcs done.
* 026d   Added config data for 2nd stage nitrous and updates to .ini. Code does not use it yet.
*        Fixed false "config error" when choosing fuel only. JSM
* 026e   Included PR's fix for realtime baro correction
* 026f   Experimental oddfire ignition offset code. Dwell WILL NOT work correctly.
* 026g   Save ram by combining stHp, avgtoothh and low bytes. Added another byte
*        Add hysteresis to hi-res dwell.
* 026g2  Turn on fuel pump as soon as any trigger received.
* 026h   Constant baro correction for alpha-n
* 026h2  Undid 026g2 fuel pump as it was half hearted and caused problems for some.
* 026i   Re-write rpm calc for better odd-fire averaging. Avg now done before calc
*        with period data not avg of 8 bit answer
* 026j   Added 5th and 6th spark outputs and 5 & 6 o/p dwell
*        Code went beyond $D000 and collided with flash tables. Tables moved to $E000.
*        Added "dual dizzy" output option, allows 4,6 triggers to control 2 alternate coils
*        Some work on oddfire dwell, dwells across two periods only to avoid "oddness".. perhaps
*      **Reversed sense of 2nd trigger input** so it is the same as the IRQ
*        Extended the oddfire offset stuff to the six outputs.
*        (No feedback on whether this code is any use yet.)
*        TO-DO review dwell calcs for 5 and 6 outputs, working but imperfect
* 027a   Same code. Bumped up number as so much changed.
* 027a1  Fixed a false config error in dual dizzy mode
* 027b   Prevent dual dizzy if not in wheel decoder. Fix? for low speed TFI
* 027c   Found bug in coil selection on 5cyl COP. Make 2nd trigger high/low active
* 027d   Added low speed dwell for channels E & F
* 027e   Idle advance and staging changes - KC
*   still to add the RX8 code Ken has written and re-arrange flash_table0 for more ram
* 028a   Rearrange and shrink flash tables to create more RAM. This required moving lots and
*        lots of config data and there could easily be breakage
* 028b   2nd trigger and missing tooth would not have worked, tooth count still reset to zero
* 028c   2nd trigger + missing, now specify 720deg worth of teeth. i.e. 60-2 = 120 tooth
*        Tested with ms2wheelsim.
* 028d   KG idle code added
*        page selection fixup and a few tweaks - JSM
* 029a   Idle tweak KG. Staging no looping - JSM
*        Included PR's decel mode AE changes and MAF stuff (026h2-> 026h3)
* 029b   Staging. KC. One line idle change KG
*        Get tooth and trigger loggers working right again (028 broke it)
*        Re-arranged 2nd trigger bits in 0.1ms. Did I get it right this time? JSM
* 029c did not exist, but "029c" ini file exists
* 029d   Fixed warmup >255% bug
*        Merged ksp's Boost Control bits from 024s9bc (report bcDC%)
*        Pambient for 300/400kpa sensors set to more reasonable, but hardcoded, value
* 029e   Removed ability to turn off hires dwell. Set "running" as soon as we get IRQ
*        Tweaks to wheeldecoder to "help" starting sync
* 029f   Pambient for boost control is a flash var
* 029g   Made wheel decoder use hardcoded WHEELINIT holdoff value again as pre 029e
* 029h   Comment out line for KeithG idle. Add debug pages $F2,$F3 to read back RAM
*        see mem_map.txt
*        Change TX logic to enable 256 bytes to be returned
*        Check Pambient is non zero else default to 100T
* 029h5  Bug fix to RPM based AE stuff - PR
* 029i   Make 60-2 wheel decoder use *2 instead of *2.5 for comparison
*        Bumped up format version because RPM-AE bytes were in wrong order
* 029j   026h+ had bug that caused reset when loading in MSQ.
* 029j1  Bug fix to Decel mode and made Decel timer same as Accel timer - PR
* 029k   KeithG change to idle (uncomment a few lines)
*        Make wheel decoder for "-2" use *1.5 like "-1"
*        Moved 300kpa,400kpa map sensor settings to constants page, rewrote code
*        that used them and introduced baro300, baro400 include files.
*        Make default 024s9 style wheel decoder, changed default baro limits tighter
*        Remove 029j1 code as it broke GammaE on startup, not sure why yet.
* 029l   Put 029j1 code back in with two line fix from PhilR. 025 decoder default.
* 029m   CLT/rpm air density stuff had serious bugs. Changed multiply.
*        Real problem was table size was incorrectly defined so tablelookup fell off the end.
*        Changed default data to something that seems more reasonable. (JSM)
* 029n   Tweaks to baro corr. Confirmed 2 equal sensors required for realtime.
* 029n2,3,4 ini file changes only
* 029o   Moved ego step count select to page1 so it can appear on right dialogue
*        False trigger disabling option re-added (for use with trigger logger)
* 029p   Always use 024s9 style decoder during cranking
* 029q   Bumped up code version so that format and version match for release. No real change.
* 029r  Undid one of 029e changes as it made wheel sync a lot worse.
*        wheel sync was fine (for me) in 027 series codes. Probably 029e broke it.
* 029s   Config errors >9 weren't working (was #10 instead of #10T)
*        Added error check for LED17 + FIDLE configured
* 029t  WUE/ASE were broken
*       Removed VEx_LOOKUP subroutines to try to save 2bytes of stack
* 029u  Found a bug that was causing spikes in many parameters (been there for ages)
* 029v  Made tacho output 50% duty
* 029w  Added an extra pulh for rotary trailing to SPARKTIME... stops stack overflow
** 029x  portc bit7 is set if config_error
** 029x1 Gobble data if write to invalid page. Should reduce chance of corruption if
**        W command executed without first setting page.
** 029x2 Make sure we read SCDR
* 029y1 MegaMeet special. Add spark hardware latency
* 029y2 Include 029x mods in 029y code
* 029y3 2nd trigger Rising and Falling option for LS1
* 029y4 Re-write of 3bar and 4bar map code so that same kPa gives same PW
*       regardless of sensor type.
****************************************************************************
****************************************************************************
**   M E G A S Q U I R T N S P A R K - 2 0 0 3 - V2.986
**
**   By Magnus Bjelk (magnus@r16site.com)
**
**   Fuel injection and ignition controller
**   based on the work of Bowling and Grippo
**
**   Large chunks of code is from MegaSquirtDT by Eric Fahlgren/Guy Hill
***************************************************************************
***************************************************************************

***************************************************************************
***************************************************************************
**   M E G A S Q U I R T - 2 0 0 1 - V2.00
**
**   (C) 2002 - B. A. Bowling And A. C. Grippo
**
**   This header must appear on all derivatives of this code.
**
***************************************************************************
***************************************************************************


;--------------------------------------------------------------------------
; Version 2.0
;--------------------------------------------------------------------------
; 2003-07-08 MBJ        First release
;
;--------------------------------------------------------------------------
; Version 2.01
;--------------------------------------------------------------------------
; 2003-07-16 MBJ        Bugfix. rpm not zero until 2.5 seconds after start
;                       resulting in lots of advance at cranking if you're
;                       quick on the key
;--------------------------------------------------------------------------
; Version 2.02
;--------------------------------------------------------------------------
; 2003-08-04 MBJ        Bugfix. Ignition module output always on for 3.2ms
;                       resulting in high rpm (more than 6000 for 4 cyl)
;                       late ignition. Added kind of dwell control
;--------------------------------------------------------------------------
; Version 2.986
;--------------------------------------------------------------------------
; 2003-09-16 MBJ        Updated to be compatible with MegaSquirt 2.986
;--------------------------------------------------------------------------
; Version 3.0
;--------------------------------------------------------------------------
; 2003-10-08 MBJ        Adding new features:
;                       Long triggers, up to 135 deg, different angle calc
;                       Timebased cranking timing, for VR pickups
;                       Invert output option
;                       Rev limiters, soft and hard
;                       Programable outputs
;                       Fixed high speed rpm calculation
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; Version 3.01
;--------------------------------------------------------------------------
; 2004-05-08 MBJ        Bugfix. Extra long triggers (over 89.5 deg) not
;                       working as intended
;--------------------------------------------------------------------------

.header 'MegaSquirt'
;.base 10t
.pagewidth 130
.pagelength 90
;.set simulate

.nolist
	include "gp32.equ"
.list
	org	ram_start
	include "msns-extra.h"

***************************************************************************
; Argument list for LinInterp, used throughout.
;
; If you move these down to LinInterp, the assembler can't use direct
; addressing for some arguments, so the code is bigger.

liX1      equ  tmp1
liX2      equ  tmp2
liY1      equ  tmp3
liY2      equ  tmp4
liX       equ  tmp5
liY       equ  tmp6 ; Function output.

;udvd32 uses some memory space, use tmp instead
INTACC1          equ tmp1  ; and 2,3,4
INTACC2          equ tmp5  ; and 6,7,8
;                    tmp9,10,11 used within udvd32
; udvd32 is only used within Calcrpm, ought to rewrite a simpler routine

;misc_spark uses these
dwelltmpX        equ  tmp2
dwelltmpH        equ  tmp3
dwelltmpL        equ  tmp4
dwelltmpXp       equ  tmp12
dwelltmpHp       equ  tmp13
dwelltmpLp       equ  tmp14
dwelltmpXac      equ  tmp20  ; use these so they don't get trashed by lookup
dwelltmpHac      equ  tmp21
dwelltmpLac      equ  tmp22
dwelltmpXop      equ  tmp5   ; these are the us result
dwelltmpHop      equ  tmp6
dwelltmpLop      equ  tmp7
dwelltmpXms     equ  tmp8   ; these are the 0.1ms result before transferring to dwelldelay1,2,3,4
dwelltmpHms     equ  tmp9
dwelltmpLms     equ  tmp10

SparkdltX        equ  tmp2  ; not used at same time as dwelltmpX etc.
SparkdltH        equ  tmp3
SparkdltL        equ  tmp4

***************************************************************************
*some paging macros. (Were subroutines but consume yet more stack)
***************************************************************************
; NOTE! page  stores which table is paged into RAM.

;                    VE TABLE 1
$MACRO ve1x   				; gets a VE byte from page1 or RAM.
					; On entry X contains index.
					; Returns byte in A
        lda     page
        cmp     #01T
        bne     ve1xf
        lda     VE_r,x
        bra     ve1xc
ve1xf:  lda     VE_f1,x
ve1xc:
$MACROEND

;                   VE TABLE 2
$MACRO ve2x				; gets a VE byte from page2 or RAM.
					; On entry X contains index.
					; Returns byte in A
        lda     page
        cmp     #02T
        bne     ve2xf
        lda     VE_r,x
        bra     ve2xc
ve2xf:  lda     VE_f2,x
ve2xc:
$MACROEND

;                  SPARK TABLE 1
$MACRO ve3x   				; gets a ST byte from page3 or RAM.
					; On entry X contains index.
					; Returns byte in A
        lda     page
        cmp     #03T
        bne     ve3xf
        lda     VE_r,x
        bra     ve3xc
ve3xf:  lda     ST_f1,x
ve3xc:
$MACROEND

;                  SPARK TABLE 2
$MACRO ve4x				; gets a ST byte from page4 or RAM.
					; On entry X contains index.
					; Returns byte in A
        lda     page
        cmp     #04T
        bne     ve4xf
        lda     VE_r,x
        bra     ve4xc
ve4xf:  lda     ST_f2,x
ve4xc:
$MACROEND

;                   VE TABLE 3
$MACRO ve5x				; gets a VE byte from page5 or RAM.
					; On entry X contains index.
					; Returns byte in A
        lda     page
        cmp     #05T
        bne     ve5xf
        lda     VE_r,x
        bra     ve5xc
ve5xf:  lda     VE_f3,x
ve5xc:
$MACROEND

;                  AFR TABLE 1 for VE1
$MACRO AFR1X				; gets an AFR byte from page6 or RAM.
					; On entry X contains index.
					; Returns byte in A
        lda     page
        cmp     #06T
        bne     ve6xf
        lda     VE_r,x
        bra     ve6xc
ve6xf:  lda     AFR_f1,x
ve6xc:
$MACROEND

;                 AFR TABLE 2 for VE3
$MACRO AFR2X				; gets an AFR byte from page7 or RAM.
					; On entry X contains index.
					; Returns byte in A
        lda     page
        cmp     #07T
        bne     ve7xf
        lda     VE_r,x
        bra     ve7xc
ve7xf:  lda     AFR_f2,x
ve7xc:
$MACROEND


***************************************************************************
**
** Main Routine Here - Initialization and main loop
**
** Note: Org down 128 bytes below the "rom_start" point
**       because of erase bug in bootloader routine
** All MS HC908 continue to be shipped with the bug to preserve backward
** compatability (BB posted on this on www.msefi.com)
** Do not mess with this offset or your chip won't boot!
**
** Note: Items commented out after the Start entry point are
**       taken care of in the Boot_R12.asm code
***************************************************************************
	org	{rom_start + 128}
Start:
	ldhx	#init_stack+1		; Set the stack Pointer
	txs				; Move before burner to avoid conflict

; Clock now 8MHz - DJLH
	bclr	BCS,pctl		; Select external Clock Reference
	bclr	PLLON,pctl		; Turn Off PLL
	mov	#$02,pctl		; Set P and E Bits
	mov	#$D0,pmrs		; Set L
	mov	#$03,pmsh		; Set N (MSB)
	mov	#$D1,pmsl		; Set N (LSB)
	bset	AUTO,pbwc
	bset	PLLON,pctl		; Turn back on PLL
;PLLwait:
        brclr   LOCK,pbwc,*
        bset    BCS,pctl


;
;   Set all RAM to known value - for code runaway protection.
;   If there is ever a code runaway, and processor tries
;    executing this as an opcode ($32) then a reset will occur.
;
	ldhx   #ram_start		; Point to start of RAM
ClearRAM:
	lda	#$32			; This is an illegal op-code -
					; cause reset if executed
	sta    ,x			; Set RAM location
	aix    #1			; advance pointer
	cphx   #ram_last+1		; done ?
	bne    ClearRAM			; loop back if not


; Set up the port data-direction registers

        lda     #%00000000
        sta     ddrb			; Set as inputs (ADC will select
					; which channel later)
        lda     #%00110000		; Turn off injectors (inverted output)
        sta     portd
        bset    launch,ptdpue
        bset    NosIn,ptdpue		; Set all the inputs internal
					; pull ups On

        lda     feature8_f              ; using spark F ?
        bit     #spkfopb
        beq     no_spk_f
        lda     #%11110101              ; make pin an output
        bra     store_ddrd
no_spk_f:
        bset    KnockIn,ptdpue
        lda     #%11110001		; Changed to 0 is an output
store_ddrd:
        sta     ddrd			; Outputs for injector

        clr     porta
        lda     #%11111111
        sta     ddra			; Outputs for Fp and Spark
        lda     #$00
        sta     portc
;is PTC4 an input?    - see also 'B' code section
        lda     feature1_f   ; we haven't copied to RAM yet
        bit     #wd_2trigb
        beq     norm_op_ddrc
        lda     #%00001111              ; make PTC4 an input for second trigger
        bra     op_ddrc
norm_op_ddrc:
        lda     #%00011111		; ** Was 11111111
op_ddrc:
        sta     ddrc			; Outputs for LED
        lda     #%00000001		; Serial Comm Port
        sta     ddre

; Set up the Real-time clock Timer (TIM2)
        MOV     #%00110011,t2sc		; Stop Timer so it can be set up
					; No overflow interrupt, stop,
					; reset, div / 8

        mov     #$FF,T2MODH		; Free running timer
        mov     #$FF,T2MODL

        mov     #0T,T2CH0H		; Channel 0 high, 0
;        mov     #92T,T2CH0L		; Channel 0 low, 92 = 0.1 ms
        mov     #100T,T2CH0L		; Channel 0 low, 100 = 0.1 ms
					; @ 8.0MHz - DJLH
        mov     #%01010100,T2SC0	; Output compare, interrupt enabled

        mov     #$00,T2CH1H		; Channel 1 high, to be used
					; for spark control
        mov     #$00,T2CH1L		; Channel 1 low, 0
        mov     #%01010100,T2SC1	; Channel 1 Output compare,
					; interrupt enabled
; edis? mov     #%01010000,T2SC1	; Channel 1 Output compare,
					; interrupt enabled
        bclr    TOF,T2SC1		; clear any pending interrupt
        bclr    TOIE,T2SC1		; Disable timer interrupt until
					; we are ready


;;        mov     #%00010011,T2SC		; Start timer, no overflow int, div / 8
        mov     #%01010011,T2SC		; Start timer, overflow int, div / 8

; Set up the PWM for the Injector (for current limit mode)
        MOV     #T1Timerstop,t1sc	; Stop Timer so it can be set up
        mov     #$00,T1MODH
        mov     #$64,T1MODL		; set timer modulus register to 100
					; decimal
;	mov     #T1SCX_NO_PWM,T1SC0	; make this normal port output
					; (PWM MODE is #$5E)
;	mov     #T1SCX_NO_PWM,T1SC1	; make this normal port output
					; (PWM MODE is #$5E)
        mov     #$00,T1CH0H
        lda     INJPWM_f1
        sta     T1CH0L
        mov     #$00,T1CH1H
        lda     dtmode_f
        bit     #alt_i2t2
        beq     setpwmsingle
        lda     INJPWM_f2
        bra     store_pwm
setpwmsingle:
        lda     INJPWM_f1
store_pwm:
        sta     T1CH1L
;        MOV     #Timergo_NO_INT,T1SC	;  No interrupts for this

; Set up SCI port
	lda	#$30			; This is 9615 baud w/ the osc
					; frequency 8.0M - DJLH
	sta	scbr
	bset	ensci,scc1		; Enable SCI
	bset	RE,SCC2			; Enable receiver
        bset    SCRIE,SCC2              ; Enable Receive interrupt
	lda	SCS1			; Clear SCI transmitter Empty Bit
        clr     txcnt
        clr     txgoal

; Set up Interrupts
        mov     #%00000100,INTSCR	;Enable IRQ

;clear water outputs
        bclr     water,porta		;water injection
        bclr     water2,porta           ;2nd water injection output
        brset    out3sparkd,feature2,w_no3
        bclr     Output3,portd
w_no3:
;
; Load the constants (VE Table, etc) from Flash to RAM - the program
; uses the RAM values.
; Changed!
; For multi table work we always operate from flash unless directed to
; copy the data into RAM for tuning. Even then only the VE tables will
; use the RAM version.  Extra coding could change this, but the initial
; release will use all other variables from flash ONLY - so be sure to
; "send" the data after changes.
;
        lda      #$ff
        sta      page		; select invalid page to make
					;sure we run from flash
; Set up RAM Variable - also when burning page0 search for "burning page0"
        lda     feature1_f
        sta     feature1
        lda     feature2_f
        sta     feature2
;        lda     feature3_f - flash only
;        sta     feature3
;        lda     feature4_f - flash only
;        sta     feature4
;        lda     feature5_f - flash only
;        sta     feature5
;        lda     feature6_f - flash only
;        sta     feature6
        lda     feature7_f
        sta     feature7
;        lda     feature8_f - flash only
;        sta     feature8
        lda     outputpins_f
        sta     outputpins
        lda     personality_f
        sta     personality		;move from flash to ram

        clr     mms
        clr     ms
        clr     tenth
        clr     secl
        clr     sech
        clr     squirt
        clr     engine
        clr     rpmph
        clr     rpmpl
        clr     rpmch
        clr     rpmcl
        clr     rpm
        clr	flocker
        lda     #$00
        sta     splitdelH       ; initial value for rotary split
        sta     splitdelL
        sta     iTimepX
        sta     iTimepH
        sta     iTimepL
        sta     KnockAngleRet
        sta     KnockAdv
        sta     KnockTimLft
        sta     KnockAngle
        sta     TCAngle
        sta     KnockBoost
        sta     CltIatAngle
        sta     TCAccel
        sta     pwcalc1
        sta     pwcalc2
        sta     pw1
        sta     pw2
        clr     pwrun1
        clr     pwrun2
        lda     #$FF
        sta     TPSlast
        sta     rpmlast
        clr     egocount
        sta     N2Olaunchdel

        ldhx    #0
        sthx    dwelldelay1
        sthx    dwelldelay2
        sthx    dwelldelay3
        sthx    dwelldelay4
        sthx    dwelldelay5
        sthx    dwelldelay6

        lda     #$BB
        sta     baro
        sta     map
        sta     mat
        sta     clt
        sta     tps
        sta     batt

        lda     #$64
        sta     aircor
        sta     vecurr
        sta     barocor
        sta     warmcor
        sta     egocorr
        sta     EgoCorr2
	sta	tpsfuelcut
        clr     gammae
;        lda     #$46  - why ? just stored $BB above
;        sta     map
;        lda     #$65
;        sta     baro
        clr     tpsaccel
        clr     Decay_Accel
        clr     igncount1
        clr     igncount2
        clr     idleDC			; set fully closed
        clr     idlelastdc		; PWM idle kg
        bclr    idleon,engine		; PWM idle kg
        bclr    idashbit,EnhancedBits6	; PWM idle kg
        bclr    istartbit,EnhancedBits6	; PWM idle kg
        lda     Spark2Delay_f
        sta     ST2Timer		; Set delay timer for ST2
        lda     VE3Delay_f
        sta     VE3Timer		; Set Delay timer for VE 3
        clra
	sta	idledelayclock		; PWM idle kg
        sta     TCSparkCut
        sta     SRevLimTimeLeft
        sta     NitrousAngle		; Clear the NOS Angle
        sta     NosPW			; Clear the Nos PW
        sta     SparkCutCnt		; Spark Cut counter - Enhanced
        sta     pw_staged		; Reset the Staged PW
	sta	pw_staged2
	sta	stgTransitionCnt
	sta	idlAdvHld
        clr     SparkBits
        clr     Sparkonleftah
        clr     Sparkonleftal
        clr     Sparkonleftbh
        clr     Sparkonleftbl
        clr     Sparkonleftch
        clr     Sparkonleftcl
        clr     Sparkonleftdh
        clr     Sparkonleftdl
        clr     Sparkonlefteh
        clr     Sparkonleftel
        clr     Sparkonleftfh
        clr     Sparkonleftfl
        clr     lowresH			; low res (0.1ms) timer
        clr     lowresL			;
        lda     dwellcrank_f
        sta     dwelldms		; initial dwell period
        mov     #$10,dwellush		; } high speed dwell delay,
					; default of 4.1ms
        clr     dwellusl		; } until calc in main loop
        bset    SparkLSpeed,SparkBits	; At boot turn on low speed ignition
        clr     RevLimBits
        clr     EnhancedBits
        clr     EnhancedBits2
        clr     EnhancedBits4
        clr     EnhancedBits5
        clr     EnhancedBits6
        clr     coilsel
        bset    coilabit,coilsel
        bset    coilerr,RevLimBits	; set "error" bit so first coil found is used

;possible that this calc could go wrong if a large "addition" was used but then a small
;real angle. Shouldn't happen if angles set correctly.
        lda     TriggAngle_f
        cmp     #57T			; check for next cyl mode
        bhi     init_crang		; trigger angle > 20, continue
        bset    nextcyl,EnhancedBits4
init_crang:
        lda     CrankAngle_f
        sta     SparkAngle
        brset   EDIS,personality,init_edis

;this won't work for next-cyl but will be ignored at low rpm anyway
        lda     TriggAngle_f
        sub     CrankAngle_f
        add     #28T			; - - 10deg
        sta     DelayAngle
        lda     SparkHoldCyc_f
        bra     init_cont

init_edis:
        lda     TriggAngle_f
        sta     DelayAngle
        lda     #$05			; set initial SAW to 10 degrees
        sta     sawh
        lda     #$00
        sta     sawl

init_cont:
        sta     wheelcount		; (HoldSpark)
        brset   MSNEON,personality,init_wheel
        brset   WHEEL,personality,init_wheel
        bra     init_no_hold
init_wheel:
	mov     #WHEELINIT,wheelcount	; holdoff for Neon/Wheel
        bclr    wsync,EnhancedBits6
        bset    whold,EnhancedBits6
        lda     #0
        sta     avgtoothh
        sta     avgtoothl
;if 2nd trig rising and falling then store existing value of pin to monitor state
        lda     dtmode_f
        bit     #trig2risefallb
        beq     init_no_hold
        brclr   pin11,portc,iw_rf2
        bset    rise,sparkbits
        bra     init_no_hold
iw_rf2:
        bclr    rise,sparkbits

init_no_hold:

        lda     #$FF
        sta     iTimeH
        sta     iTimeL
        sta     iTimeX

;see if inverted or non-inv output and use a quick bit
        lda     SparkConfig1_f		; check if noninv or inv spark
        bit     #M_SC1InvSpark
        bne     inspk_inv
        bclr    invspk,EnhancedBits4	; set non-inverted
        bra     inspk_done
inspk_inv:
        bset    invspk,EnhancedBits4	; set inverted
inspk_done:

        lda     p8feat1_f
        bit     #rotary2b
        beq     not_init_rot
        bset    rotary2,EnhancedBits5  ; set rotary quick bit
        bclr    wspk,EnhancedBits4	; set that we are NOT doing normal wasted spark
        bra     done_rot
not_init_rot:
        bclr    rotary2,EnhancedBits5  ; clr rotary quick bit

done_rot:

;decide if we are doing multiple wasted spark outputs
        brset   MSNEON,personality,wsp_init
        brset   WHEEL,personality,wsp_init
        bra     mv_init			; not wasted spark so skip
wsp_init:
        brclr   REUSE_LED19,outputpins,mv_init
        brset   rotary2,EnhancedBits5,mv_init
        bset    wspk,EnhancedBits4	; set that we are doing wasted spark
mv_init:
; set MegaView mode to block enhanced comms, S,P,R,X commands reset
; it to allow normal ops
        bset    mv_mode,EnhancedBits2

;If HEI set bypass to 0v
        brclr   HEI7,personality,not_hei7_init
        bset    aled,portc
not_hei7_init:

        brclr   DUALEDIS,personality,chk_out
        bset    EDIS,personality	; DUALEDIS implies EDIS

chk_out:
**** add in some sanity checks for outputs vs. code base ****
        lda     personality
        bne     check_out_config
;        lda     outputpins		; assumes if personality zero
;					; then any outputs are error
;        beq     b_dc			; no personality, no outputs
;wrong!  This prevents "Fuel only", just check for conflicts
        bra     check3

;set_error:
        mov     #1,tmp4
        bset    config_error,feature2
        jmp     done_checks

check_out_config:
        brclr   REUSE_LED17,outputpins,block_neon
        brclr   REUSE_LED19,outputpins,block_neon
        bra     check_msns
block_neon:
        brclr   MSNEON,personality,check_msns
        mov     #2,tmp4
        bset    config_error,feature2	; if MSNEON but haven't
					; reused led17&19 then error
        jmp     done_checks

check_msns:
        brclr   MSNS,personality,check3
        brset   REUSE_FIDLE,outputpins,check3
        brset   REUSE_LED17,outputpins,check3
        mov     #3,tmp4
        bset    config_error,feature2	; if MSNS and haven't reused
					; FIDLE or LED17 then error
        jmp     done_checks

check3:   ; check for idle conflict
;        brclr   PWMidle,feature2,check4
        lda     feature13_f
        bit     #pwmidleb
        beq     check4
        brclr   REUSE_FIDLE,outputpins,check4
        mov     #4,tmp4
        bset    config_error,feature2	; trying to use PWM idle and spark
					; on FIDLE
        jmp     done_checks

check4:         ; check we don't have Water and Fan control as both use X2
        lda     feature3_f
        bit     #WaterInjb
        beq     check5
;        brclr   WaterInj,feature3,check5
        brclr   X2_FAN,outputpins,check5
        mov     #5,tmp4
        bset    config_error,feature2	; X2 in conflict
b_dc:
        jmp     done_checks
check5:
        brclr   Nitrous,feature1,check6
        lda     feature3_f
        bit     #WaterInjb
        beq     check6
;        brclr   WaterInj,feature3,check6
        mov     #6,tmp4
        bset    config_error,feature2	; X4 water/nitrous pin in conflict
        jmp     done_checks

check6:         ;7pin HEI must have spark output B (LED19) defined. For bypass output
        brclr   HEI7,personality,check7
        brset   REUSE_LED19,outputpins,check7
        mov     #7,tmp4
        bset    config_error,feature2
        jmp     done_checks

check7:   ; do some checks on wasted spark outputs
        brset   rotary2,EnhancedBits5,check8a
;  coilc is the pain - set if LED18=1 and LED18_2=1
        brclr   wspk,EnhancedBits4,check8	; don't bother if we
						; aren't doing multiple outputs
        brclr   WHEEL,personality,check8
        brset   out3sparkd,feature2,ck74	; 4th output
        brclr   REUSE_LED18,outputpins,ck72	; not 3rd output
        brclr   REUSE_LED18_2,outputpins,ck72	; not 3rd output
        bra     ck73				; LED18=1 & LED18_2=1
ck74:
        lda     trig4_f
        beq     ck7err
        brclr   REUSE_LED18,outputpins,ck7err
        brclr   REUSE_LED18_2,outputpins,ck7err
ck73:
        lda     trig3_f
        beq     ck7err
        brclr   REUSE_LED19,outputpins,ck7err
ck72:
        lda     trig2_f
        beq     ck7err
ck72b:
        brclr   REUSE_LED17,outputpins,ck7err
ck71:
        lda     trig1_f
        beq     ck7err
        bra     check7b				; passed all checks
ck7err:
        mov     #8,tmp4
        bset    config_error,feature2
        jmp     done_checks
check7b:	; can't use FIDLE for spark if doing wasted spark
        brclr   REUSE_FIDLE,outputpins,check7c
        mov     #9,tmp4
        bset    config_error,feature2
        jmp     done_checks

check7c:
;now check other way around
;first check for dual dizzy feature
        lda     feature6_f
        bit     #dualdizzyb
        bne     check8       ; if dual dizzy then only 2 outputs anyway

        lda     trig4_f				; if trig4 pt set must have
						; spark o/p d
        beq     ck7c3
        brclr   out3sparkd,feature2,ck7err	; 4th output
ck7c3:
        lda     trig3_f				; if trig3 pt set must
						; have spark o/p c
        beq     check8
        brclr   REUSE_LED18,outputpins,ck7err
        brclr   REUSE_LED18_2,outputpins,ck7err

check8:
        bra     check9
check8a:
        ; do rotary2 output checks, must have led17,18,19 set to spark and two
        ; wheel triggers
        brclr   REUSE_LED18,outputpins,ck8aerr
        brclr   REUSE_LED18_2,outputpins,ck8aerr
        brclr   REUSE_LED19,outputpins,ck8aerr
        brclr   REUSE_LED17,outputpins,ck8aerr
;now check wheel decoder is setup
        brclr   WHEEL,personality,ck8cerr
;check for two triggers
        lda     trig2_f
        beq     ck8berr
        lda     trig1_f
        beq     ck8berr
        bra     check9

ck8aerr:
        mov     #10T,tmp4
        bset    config_error,feature2
        bra     done_checks
ck8berr:
        mov     #11T,tmp4
        bset    config_error,feature2
        bra     done_checks
ck8cerr:
        mov     #12T,tmp4
        bset    config_error,feature2
        bra     done_checks

check9:
        brclr   REUSE_FIDLE,outputpins,check10
        brclr   REUSE_LED17,outputpins,check10
        mov     #13T,tmp4
        bset    config_error,feature2
        bra     done_checks
check10:
; count how many ignition types and if more than one give an error
        clra
        brclr   MSNS,personality,check10a
        inca
check10a:
        brclr   MSNEON,personality,check10b
        inca
check10b:
        brclr   WHEEL,personality,check10c
        inca
check10c:
        brclr   EDIS,personality,check10d
        inca
check10d:
        brclr   TFI,personality,check10e
        inca
check10e:
        brclr   HEI7,personality,check10f
        inca
check10f:
        cmp     #1
        bls     check11
        mov     #14T,tmp4
        bset    config_error,feature2
        bra     done_checks

check11:
done_checks:
;make sure all spark outputs are inactive as soon as poss

        jsr     turnallsparkoff     ; subroutine

start_adc:
; Fire up the ADC, and perform three conversions to get the baro value, IAT
; and the clt temp

	lda	#%01110000	; Set up divide 8 and internal bus clock source
	sta	adclk
	lda	#%00000000	; Select one conversion, no interrupt, AD0
	sta	adscr
	brclr   coco,adscr,*	; wait until conversion is finished

	lda	adr
	sta	baro		; Store value in Barometer

	lda	#%00000010	; Select second conversion, no interrupt, AD2
	sta	adscr
	brclr   coco,adscr,*	; wait until conversion is finished

	ldx      adr
	lda     THERMFACTOR,x
	sta     coolant		; Coolant temperature in degrees F + 40

	lda	#%00000011	; Select third conversion, no interrupt, AD3
	sta	adscr
	brclr   coco,adscr,*	; wait until conversion is finished

	ldx      adr
	lda     MATFACTOR,x
        sta     airTemp
	clr     adsel		; Clear the channel selector
TURN_ON_INTS:
        cli			; Turn on all interrupts now

***************************************************************************
** Check for config error
***************************************************************************
        brset   config_error,feature2,config_er1JMP

***************************************************************************
**
** Prime Pulse - Shoot out one priming pulse of length PRIMEP now or
** after 2 seconds
** Also added the facility for 2 priming pulses  P Ringwood
**
***************************************************************************
        bclr   Primed,EnhancedBits		; Clear the primed bit
        lda    feature11_f4
        bit    #PrimeTwiceb
        bne    Two_Primes
;        brset  PrimeTwice,feature6,Two_Primes	; Are we firing priming
						; pulses twice?
        inc    TCSparkCut			; Add 1 to prime counter
						; so it only does it once
Two_Primes:					; using spark cut byte to
						; cut down bytes
        lda    feature11_f4
        bit    #PrimeLateb
        bne    PrimeLater
;        brset  PrimeLate,feature6,PrimeLater	; Are we going to prime late?

PrimeNow:
        inc    TCSparkCut			; Increase Prime Pulse Counter
        lda    TCSparkCut

        cmp    #02T				; Have we reached prime
						; pulse count limit?
        blo    Prime_Not_Done
        bset   Primed,EnhancedBits		; Set Primed bit high if
						; we've done all pulses
        lda    #00T
        sta    TCSparkCut			; Clear this for use later

Prime_Not_Done:
        lda    feature11_f4                     ; Priming pulse table or box?
        bit    #NoPrimePb
        beq    PrimeTable_P                     ; Prime table

        lda    primePulse_f                     ; Prime pulse
        beq    Prime_NoPrime                    ; if zero are we priming pump?
        bra    prime                            ; Go do prime
Prime_NoPrime:
        lda    feature11_f4                     ; zero pulse so are we priming pump?
        bit    #AlwaysPrimeb
        beq    CalcRunJMP                       ; zero and not fing pump
        bset   Primed,EnhancedBits              ; We have primed now
        lda    #00T                             ; firing pump, put 00 back in acc
        bra    prime

PrimeTable_P:
        ; Interpolate from CLT, same curve as cranking PW.

        jsr    crankingModePrime
        lda    tmp6
        bra    prime

NotPrimed:					; If were here we must
						; be priming late
        lda    secl
        cmp    #02T				; Have we been powered up
						; for 2 secs?
        bhs    PrimeNow				; Yes so fire prime pulse now
        jmp    Prime_Checked			; No so go back to main loop

PrimeLater:
        bset   running,engine
        bset   crank,engine
        bset   fuelp,porta			; Start the pump running
        bra    CalcRunningParameters			; Don't pulse the injectors yet

prime:

        bset   running,engine
        bset   fuelp,porta

        sta    pw1
        clr    pwrun1
        bset   sched1,squirt
        bset   inj1,squirt

        brclr  CrankingPW2,feature1,CalcRunningParameters; can skip prime
						; on second channel
        sta    pw2
        clr    pwrun2
        bset   sched2,squirt
        bset   inj2,squirt
        bra    CalcRunningParameters

config_er1JMP:
        jmp   config_error1			; Config Error jump

PumpPrime:
        bset   crank,engine
        bset   running,engine
        bset   fuelp,porta			; prime the pump
CalcRunJMP:
        bra    CalcRunningParameters            ; Go start the main loop

******** Config error dead end **********
** Toggle these ports as a visual and audible indicator
***************************************************************************
config_error1:
        bset    IMASK,INTSCR			; disable interrupts for
						; IRQ (the ignition i/p)
        bclr    running,engine
        bset    fuelp,porta
;        bclr    wled,portc

dead_end:
        bset    fuelp,porta

        lda     tmp4
        beq     skip_err_msg			; if zero then don't try
						; to send

;find start address or error message
        lda     tmp4
        asla
        tax
        clrh
        lda     error_vector,x
        sta     tmp5
        incx
        lda     error_vector,x
        sta     tmp6

        mov     #$0D,txmode
        bset    TE,SCC2				; Enable Transmit
        bset    SCTIE,SCC2			; Enable transmit interrupt
        clr     tmp4				; wipe error code so we
						; only send it once
        ;if we keep sending it then it gets in the way of tuning software trying to
        ;read and write data to put the error right. e.g. you send 'R' but the code
        ;is in the middle of sending a message
skip_err_msg:

        mov     #10,tmp1
dead_loop1
        clr     tmp2
dead_loop2:
        clr     tmp3
dead_loop3:
        dec     tmp3
        bne     dead_loop3
        dec     tmp2
        bne     dead_loop2
        dec     tmp1
        bne     dead_loop1

        bclr    fuelp,porta

        mov     #10,tmp1
dead_loop4
        clr     tmp2
dead_loop5:
        clr     tmp3
dead_loop6:
        dec     tmp3
        bne     dead_loop6
        dec     tmp2
        bne     dead_loop5
        dec     tmp1
        bne     dead_loop4

        bra     dead_end

*****************************************************************************
*****************************************************************************
**
**  Correction Factor Lookup Table Access
**
**   Perform table lookup for barometer and air density correction factors,
**    and performs coolant temperature conversion from counts to degrees F.
**
**   All tables are pre-computed for all 256 different values
**    and stored in FLASH.
**
**   Note: Coolant temperature is in degrees F plus 40 - this allows
**    unsigned numbers for full temperature range of -40 to 215.
**
***************************************************************************
CalcRunningParameters:

*******************************
        clrh
        brset   OneShotBArro,EnhancedBits2,bEnd_of_Baro	; Only do this once
							; as we may change
							; the baro value


        lda     config13_f1           ; Are we doing baro at all?
        bit     #c13_bc
        beq     non_baro

        lda     feature9_f
        bit     #ConsBarCorb           ; Are we doing constant Bar COr using map on X7 ??
        bne     ConsBar

        lda     config13_f1
        bit     #c13_cs                ; Are we doing Alpha_n?
        beq     OneShot_Bar            ; No so one shot baro only!

        lda     feature9_f             ; Are we doing constant baro correction using
        bit     #BaroCorConstb         ; the on board map in Alpha_n mode?
        beq     OneShot_Bar
        lda     map
        sta     baro                   ; Store the map in the baro variable
        bra     DoBaroCorr

bEnd_of_Baro:
        jmp     End_of_Baro		; extend branch below

non_baro:
        bset    OneShotBArro,EnhancedBits2            ; only do this once

        ; not doing any baro, so use fixed Pambient and 100% baro correction
        lda     Pambient_f     ; load in flash data. Let the user choose the setpoint
        cmp     #20T
        bhi     st_pamb
        lda     #100T           ; if a silly low (or zero) value is set then use default
st_pamb:
        sta     Pambient   ;decide which hardcoded limit to use for starting boost control
        lda     #100T
        bra     DoneBaroCorr


OneShot_Bar:
        bset    OneShotBArro,EnhancedBits2
        bra     DoBaroCorr

ConsBar:                                ; MAP connected to X7, so using constant BARO COR
        lda     o2_fpadc
        sta     baro

DoBaroCorr:
        ldx     baro
        ;check if within sensible range
        cpx     BarroHi_f
        blo     Baro_Lo_Check
        ldx     BarroHi_f
        bra     Do_Baro
Baro_Lo_Check:
        cpx     BarroLow_f
        bhi     Do_Baro
        ldx     BarroLow_f
Do_Baro:
        stx     baro                    ; re-store whatever it ended up as
        lda     config11_f1
        and     #$03                    ; What MAP sensor?
        beq     do_baro4115
        cbeqa   #2T,do_baro_6300
        cbeqa   #3T,do_baro_6400

;do_baro_4250:
        lda     KPAFACTOR4250,x
        sta     Pambient
        lda     BAROFAC4250,x
        bra     DoneBaroCorr

do_baro_6300:
        stx     Pambient ; use raw ADC
        lda     BAROFAC300k,x
        bra     DoneBaroCorr

do_baro_6400:
        stx     Pambient ; use raw ADC
        lda     BAROFAC400k,x
        bra     DoneBaroCorr

do_baro4115:
        lda     KPAFACTOR4115,x
        sta     Pambient
        lda     BAROFAC4115,x
DoneBaroCorr:
        sta     barocor			; Barometer Correction Gamma
End_of_Baro:

;now convert map ADC count into internal kpa
        ldx     map
        lda     config11_f1
        and     #$03
        cbeqa   #1T,do_kpa4250
        cbeqa   #2T,do_kpa6300
        cbeqa   #3T,do_kpa6400
        bra     do_kpa4115


do_kpa4250:
        lda     KPAFACTOR4250,x
        bra     Donekpa

do_kpa4115:
        lda     KPAFACTOR4115,x
        bra     Donekpa

do_kpa6300:
        lda     map			; Use Raw ADC value + offset if 300/400 KPa
        inca				; instead of KPAFACTOR
        bra     Donekpa

do_kpa6400:
        lda     map			; Use Raw ADC value + offset if 300/400 KPa
        inca
        inca				; instead of KPAFACTOR

Donekpa:
        sta     kpa

        ldx     clt
        lda     THERMFACTOR,x
        sta     coolant			; Coolant temperature in degrees F + 40

        ldx     mat
        lda     MATFACTOR,x
        sta     airTemp			; Added for enhanced stuff Air Temp in F + 40

        lda     feature9_f              ; Are we using a MAF?
        bit     #MassAirFlwb
        beq     Do_AirDens
        lda     feature9_f              ; Using MAF, so do we still do Air Cor?
        bit     #NoAirFactorb
        beq     Do_AirDens
        lda     #100T                   ; No Air Cor so set it to 100%
        jmp     Store_AirCor

Do_AirDens:                             ; Not using a Air correction within a MAF

;******** CHECK IF CORRECTING AIR DENSITY *****************
        lda     feature13_f
        bit     #cltMAPb             ; Are we correcting the air density factor?
        beq     NormAirDen           ; If no then do normal air density

; If we get here we are doing correction to air density
; Air Density = IAT Air Density * (Correction * Reduction based on RPM %)

        ldhx    #CltMATRange         ; Temps for table
        sthx    tmp1
        lda     #$06                 ; 7 bytes big
        sta     tmp3

        lda     feature13_f
        bit     #CltMATCheckb
        beq     CoolantRel           ; Are we using Coolant or IAT for correction?
        lda     airTemp              ; MAT based correction
        bra     MATRel

CoolantRel:
        lda     coolant              ; Coolant based correction
MATRel:
        sta     tmp4
        jsr     tableLookup          ; Find the lookup place for coolant
                                     ; corr in table
        clrh
        ldx     tmp5
        lda     cltMATcorr_f,x       ; From correction table to correct Density
        sta     liY2
        decx
        lda     cltMATcorr_f,x
        sta     liY1

        lda     feature13_f
        bit     #CltMATCheckb
        beq     CoolantTabl          ; Are we using Coolant or IAT for correction?
        lda     airTemp
        bra     StoreCoret

CoolantTabl:
        lda     coolant
StoreCoret:
        sta     liX
        jsr     LinInterp
        mov     tmp6,tmp31           ; Tmp31 now contains correction percentage

; So now we have the correction for Air Den, now interpolate the RPM to reduce this if needed due to engine speed
; We do this by having 2 RPM set points, below Lowest is all of calculated coolant correction, above it is interpolated.

        lda     rpm
  	cmp     RPMReduLo_f          ; Are we below the min reduction value?
        blo     Do_Cal_Red1          ; YES so no reduction on correction factor
        lda     rpm
        sta     liX                  ; Store current value to see where we are
        lda     RPMReduHi_f
        sta     liX2                 ; Highest point to stop all correction
        lda     RPMReduLo_f
        sta     liX1                 ; Lowest point to start to remove correction
        lda     tmp31                ; This is the coolant correction value
        sta     liY1
        lda     #100T
        sta     liY2                 ; 100% correction when at this setpoint (No correction)
        jsr     LinInterp            ; Find How much we want to reduce by.
        mov     tmp6,tmp31           ; tmp31 now contains coolant correction * 0-100% reduction depending on RPM

Do_Cal_Red1:
        clrh
        ldx     mat
        lda     AIRDENFACTOR,x       ; Find normal Air Density
;        sta     tmp10
;        clr     tmp11
;        lda     tmp31
;        sta     tmp12
;        clr     tmp13
;        jsr     Supernorm            ; Multiply Norm AirDen with correction
;        mov     tmp10,AirCor         ; Now we have amount of correction based on correction * RPM reduction%
;why use SuperNorm when remainder is zero and we discard output remainder?
;want to do airdenfactor * tmp31 / 100
        ldx     tmp31
        mul             ; (result in x:a)
        pshx
        pulh
        ldx     #100T
        div             ; (h:a / x -> a rem h)
        sta     AirCor
        bra     Do_Mat_Fact          ; jump past normal Air Density

;******** NORMAL AIR DENSITY **************************************
NormAirDen:
        ldx     mat
        lda     AIRDENFACTOR,x
Store_AirCor:
        sta     AirCor			; Air Density Correction Factor

Do_Mat_Fact:

***************************************************************************
**
** Computation of RPM
**
**   Result left in accumulator.
**
**     rpmk:rpmk+1
**     ----------- = rpm
**     rpmph:rpmpl
**
**  rpmk:rpmK+1 = RPM constant = (6,000 * (stroke/2))/ncyl
**  rpmph:rpmpl = period count between IRQ pulsed lines, in 0.1 ms resolution
**
****************************************************************************

CalcRPM:
; 50% re-written in 026i with aim of better odd-fire averaging

        brset     running,engine,dorpmCalc
        ldhx      rpmph
        bne       dorpmCalc		; If zero then jump over calculation
					; - prevent divide by zero
        jmp       rpmCalcZero           ; previous branches out of range

dorpmCalc:
;tmp12,13,14 used to hold average iTime or avg iTime
        sei                    ; must block ints for this little period
        mov       iTimeX,tmp12
        mov       iTimeH,tmp13
        mov       iTimeL,tmp14

        mov       iTimepX,tmp15
        mov       iTimepH,tmp16
        mov       iTimepL,tmp17
        cli

; If odd-fire is set (bit zero of Config13), then average RPM values
        lda       config13_f1
        and       #$01
        beq       NO_ODD_FIRE

YES_ODD_FIRE:
;average previous period with previous previous
        lda       tmp17    ; add together
        add       tmp14
        sta       tmp14
        lda       tmp16
        adc       tmp13
        sta       tmp13
        lda       tmp15
        adc       tmp12
        lsra               ; divide by 2
        sta       tmp12
        ror       tmp13
        ror       tmp14

NO_ODD_FIRE:
        lda       tmp12
        beq       rpmCalcFast		; If we have only 8-bit denominator,
					; then use native divide

;note, udvd32 re-written so that it uses
;tmp1,2,3,4 as intacc1
;tmp5,6,7,8 as intacc2
;tmp9,10,11 as temp storage instead of extra stack

rpmCalcSlow:
;need to divide period (tmp12,13,14) by 100 to obtain period time in 0.1ms
        ldx       #100T
        clrh
        lda       tmp12
        div				; A rem H = (H:A) / X
        sta       tmp12
        lda       tmp13
        div				; A rem H = (H:A) / X
        sta       tmp13
        lda       tmp14
        div				; A rem H = (H:A) / X
        sta       tmp14

        lda       tmp12
        bne       rpmCalcZero           ; if tmp12>0 then very slow indeed (<100rpm)


        clr       intacc1
        clr       intacc1+1

        mov       tmp13,intacc2
        mov       tmp14,intacc2+1

        lda       rpmk_f1
        sta       intacc1+2
        lda       rpmk_f1+1
        sta       intacc1+3

        jsr       udvd32		; 32 / 16 divide

        lda       intacc1+3		; get 8-bit RPM result
        bra       rpmCalcDone

rpmCalcFast:
;This (new) slower code takes the time between IRQs in 1us accuracy to calc the rpm
;this should eliminate the jumpiness at high rpm where one 0.1ms step > 100rpm
;
;Multiply rpmk x 100 then do 32/16 divide using 1us time
        lda      #100T
        ldx      rpmk_f1+1			; LSB of multiplicand.
        mul
        sta      intacc1+3			; LSB of result stored.
        stx	 intacc1+2			; Carry on stack.
        lda      #100T
        ldx      rpmk_f1			; MSB of multiplicand.
        mul
        add      intacc1+2			; Add in carry from LSB.
        sta      intacc1+2		; MSB of result.
        bcc      nox_of
        incx
nox_of:
        stx      intacc1+1
        clr      intacc1
;rpmk x 100 now dividend
;make iTime the divisor
        mov      tmp13,intacc2
        mov      tmp14,intacc2+1
        jsr      udvd32         ; 32/16 divide

        lda      intacc1+3		; get 8-bit RPM result
        bra      rpmCalcDone

rpmCalcZero:
        clra

rpmCalcDone:
        sta       rpm

***************************************************************************
** First, check RPM value to determine if we are cranking or running,
** then calculate the appropriate pulse width.
***************************************************************************
CalcPWs:
        lda     rpm
        cmp     crankRPM_f		; Check if we are cranking,
        bhi     runIt
        brset    cant_crank,EnhancedBits2,runIt 	; don't allow reentry
							; to crank mode while
							; running
crankIt:
        jsr     crankingMode
        jmp     checkRPMsettings
runIt:

;--------------------------------------------------------------------------
; Approximate ranges of the various terms of the equation:
;
;   gammae   90-150, highest when cold, but really of no consequence.
;   vecurr   10-200, biggest range with blown motors.
;   kPa      20-250, biggest range with blown motors.
;   reqFuel  50-150, lowest values with big injectors, blown motors again.
;   battcorr ~100, assume it's constant.
;
; So calc VEcurr * reqFuel before * kPa to minimize overflow.

; calc 'PW1' from table 1
	bclr    page2,EnhancedBits4	; set table 1

	brclr   UseVE3,EnhancedBits,Do_VE1_4_Now	; Jump if aren't using VE table 3
        jmp     VE3_Table
Do_VE1_4_Now:

***************************************************************************
***************************************************************************
**
**  VE 3-D Table Lookup
**
**   This is used to determine value of VE based on RPM and MAP
**   The table looks like:
**
**      105 +....+....+....+....+....+....+....+
**          ....................................
**      100 +....+....+....+....+....+....+....+
**                     ...
**   KPA                 ...
**                         ...
**       35 +....+....+....+....+....+....+....+
**          5    15   25   35   45   55   65   75 RPM/100
**
**
**  Steps:
**   1) Find the bracketing KPA positions via tableLookup, put index in
**       tmp8 and bounding values in tmp9(kpa1) and tmp10(kpa2)
**   2) Find the bracketing RPM positions via tableLookup, store index
**       in tmp11 and bounding values in tmp13(rpm1) and tmp14(rpm2)
**   3) Using the VE table, find the table VE values for tmp15=VE(kpa1,rpm1),
**       tmp16=VE(kpa1,rpm2), tmp17 = VE(kpa2,rpm1), and tmp18 = VE(kpa2,rpm2)
**   4) Find the interpolated VE value at the lower KPA range :
**       x1=rpm1, x2=rpm2, y1=VE(kpa1,rpm1), y2=VE(kpa1,rpm2) - put in tmp19
**   5) Find the interpolated VE value at the upper KPA range :
**       x1=rpm1, x2=rpm2, y1=VE(kpa2,rpm1), y2=VE(kpa2,rpm2) - put in tmp11
**   6) Find the final VE value using the two interpolated VE values:
**       x1=kpa1, x2=kpa2, y1=VE_FROM_STEP_4, y2=VE_FROM_STEP_5
**
***************************************************************************

***************************************************************************
** JSM changed it to just be one routine per page. Maybe Eric will kill
** me, but we've plenty of flash and I'm obviously a bit lazy.
***************************************************************************

VE1_LOOKUP:				; ALWAYS page 1
        clrh
        clrx

        lda     feature9_f
        bit     #MassAirFlwb
        beq     VE1_LOOKUP_PW1          ; Are we using a MAF on pin X7?
        lda     o2_fpadc                ; Using MAF thats on pin X7
        bra     VE1_STEP_1

VE1_LOOKUP_PW1:
        lda     config13_f1
        bit     #c13_cs
        bne     VE1_AN			; Using Alpha_n?
        lda     kpa			; SD, so use kpa for load
        bra     VE1_STEP_1

VE1_AN:
        lda     tps                     ; Alpha_n

VE1_STEP_1:
        sta     kpa_n
        ldhx    #KPARANGEVE_f1
        sthx    tmp1
        lda     #$0b			; 12x12
        sta     tmp3
        lda     kpa_n
        sta     tmp4
        jsr     tableLookup
        lda     tmp1
        lda     tmp2
        mov     tmp5,tmp8		; Index
        mov     tmp1,tmp9		; X1
        mov     tmp2,tmp10		; X2

VE1_STEP_2:
        ldhx    #RPMRANGEVE_f1
        sthx    tmp1
        mov     #$0b,tmp3		; 12x12
        mov     rpm,tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		; Index
        mov     tmp1,tmp13		; X1
        mov     tmp2,tmp14		; X2

VE1_STEP_3:
        clrh
        ldx     #$0c			; 12x12
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        VE1X
        sta     tmp15
        incx
        VE1X
        sta     tmp16
        ldx     #$0c			; 12x12
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        VE1X
        sta     tmp17
        incx
        VE1X
        sta     tmp18

        jsr     VE_STEP_4
        mov     tmp6,vecurr

	jmp     No_VE3

VE3_Table:
	lda     VE3Timer
        beq     VE3_LOOKUP
	jmp     Do_VE1_4_Now
***************************************************************************
*** VE Table 3 Look up
***************************************************************************

VE3_LOOKUP:				; ALWAYS page 3
        clrh
        clrx

        lda     feature9_f
        bit     #MassAirFlwb
        beq     VE3_LOOKUP_PW1          ; Are we using a MAF on pin X7?

        lda     o2_fpadc                ; Using MAF thats on pin X7
        bra     VE3_STEP_1

VE3_LOOKUP_PW1:
        lda     config13_f1
        bit     #c13_cs
        bne     VE3_AN			; if alpha-n

        lda     kpa			; SD, so use kpa for load
        bra     VE3_STEP_1
VE3_AN:
        lda     tps

VE3_STEP_1:
        sta     kpa_n
        ldhx    #KPARANGEVE_f3
        sthx    tmp1
        lda     #$0b			; 12x12
        sta     tmp3
        lda     kpa_n
        sta     tmp4
        jsr     tableLookup
        lda     tmp1
        lda     tmp2
        mov     tmp5,tmp8		; Index
        mov     tmp1,tmp9		; X1
        mov     tmp2,tmp10		; X2

VE3_STEP_2:
        ldhx    #RPMRANGEVE_f3
        sthx    tmp1
        mov     #$0b,tmp3		; 12x12
        mov     rpm,tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		; Index
        mov     tmp1,tmp13		; X1
        mov     tmp2,tmp14		; X2

VE3_STEP_3:

        clrh
        ldx     #$0c			; 12x12
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        VE5X
        sta     tmp15
        incx
        VE5X
        sta     tmp16
        ldx     #$0c			; 12x12
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        VE5X
        sta     tmp17
        incx
        VE5X
        sta     tmp18

        jsr     VE_STEP_4
        mov     tmp6,vecurr

No_VE3:

CalcGammaE:

; Now we do all the WUE, TAE and EGO in sequence rather than subroutines
; (ram saving?)

***************************************************************************
**  PW Correction Factor subroutines.
***************************************************************************
***************************************************************************
**
** Warm-up and After-start Enrichment Section
**
** The Warm-up enrichment is a linear interpolated value from WWU (10 points)
**  which are placed at different temperatures
**
** Method:
**
** 1) Perform ordered table search of WWU (using coolant variable) to determine
**  which bin.
** 2) Perform linear interpolation to get interpolated warmup enrichment
**
** Also, the after-start enrichment value is calculated and applied here - it
** is an added percent value on top of the warmup enrichment, and it is applied
** for the number of ignition cycles specified in AWC. This enrichment starts
** at a value of AWEV at first, then it linearly interpolates down to zero
** after AWC cycles.
**
** 3) If (startw, engine is set) then:
** 4) compare if (awc < ASEcount) then:
** 5) x1=0, x2=AWC, y1=AWEV, y2=0, x=ASEcount, y=ASEenrichment
** 6) else clear startw bit in engine
**
** During calcs we use tmp31 for result then store at end
***************************************************************************
WUE_CALC:
        brclr   crank,engine,WUE1  ; already out of crank mode
        bclr    crank,engine
        clr     TCCycles
        clr     TCAccel
        bset    startw,engine
        bset    warmup,engine
        bclr    FxdASEDone,EnhancedBits4   ; not done yet
        clr     ASEcount
WUE1:
        brset   warmup,engine,WUE1a   ; only run code if in warmup
        mov     #100T,tmp31           ; ensure wue is 100%
        jmp     WUE_DONE
WUE1a:
        lda     coolant
        cmp     #205T
        bhs     Warm_Done_Now  ; If coolant is >165F (greater than the max setting)

;Warm_NotDone:
        ldhx    #WWURANGE
        sthx    tmp1
        mov     #$09,tmp3
        lda     coolant
        sta     tmp4
        jsr     tableLookup

        clrh
        ldx     tmp5
        lda     WWU_f1,x
        sta     liY2
        decx
        lda     WWU_f1,x
        sta     liY1
        lda     coolant
        sta     liX
        jsr     LinInterp
        lda     tmp6
        sta     tmp31   ; save result
        bra     WUE2    ; only end warmup when reached temp
;        cmp     #100T
;        bhi     WUE2

; Outside of warmup range - clear warmup enrichment mode (also ends any ASE)
Warm_Done_Now:
        mov     #100T,tmp31
        bset    FxdASEDone,EnhancedBits4
        bclr    startw,engine
        bclr    warmup,engine
        brset   REUSE_LED18,outputpins,jWUE_DONE
        brset   REUSE_LED18_2,outputpins,jWUE_DONE	; Using led as output 4
        bclr    wled,portc		; not when crank sim or if
					; LED re-used as IRQ indicator
jWUE_DONE:
        jmp     WUE_DONE
WUE2:
        brset   REUSE_LED18,outputpins,WUE2_ledskip
        brset   REUSE_LED18_2,outputpins,WUE2_ledskip ; Using led as output 4
        bset    wled,portc
WUE2_ledskip:
        brclr   startw,engine,jWUE_DONE

; Added a fixed period of ASE rather than a decaying ASE, after fixed period it
; goes to the normal ASE decay type of ASE


        lda     feature10_f5
        bit     #ASEHoldb           ; Are we holding the ASE at a fixed percentage?
        beq     NormASE_Count
        brset   FxdASEDone,EnhancedBits4,NormASE_Count  ; If Fixed ASE done

        lda     coolant             ; We are in fixed Accel mode
        cmp     CltFixASE_f         ; so are we below the temperature setpoint?
        blo     Cont_FixASE
        bset    FxdASEDone,EnhancedBits4
        bra     NormASE_Count
Cont_FixASE:
        lda     ASEcount
        cmp     TimFixASE_f
        blo     Table_ASEStuff      ; Have we passed the Fixed timer yet?

        clr     ASEcount            ; Reset ASE count so we do the norm ASE now  ????
        bset    FxdASEDone,EnhancedBits4
NormASE_Count:
        lda     ASEcount
        cmp     awc_f1			; Check if ASE period has expired.
        bhs     WUE3
;        bra     Table_ASEStuff
; Table ASE stuff based on coolant temp - PR
Table_ASEStuff:
        mov     coolant,tmp4
        ldhx    #WWURANGE
        sthx    tmp1
        mov     #$09,tmp3		; 10 bits wide
        jsr     tableLookup		; This finds the bins when the
					; temperatures are set
        clrh
        ldx     tmp5

        lda     ASEVTbl_f,x
        sta     liY2
        decx
        lda     ASEVTbl_f,x		; This finds the values for the
					; ase percentage for the temperature
        sta     liY1
        mov     coolant,liX
        jsr     LinInterp		; tmp6 contains amount of ase
					; enrichment in percent for this
					; temperature

        clr     liX1
        lda     AWC_f1
        sta     liX2

        lda     tmp6			; Use the value from the interpolated
					; table rather than the normal value
        sta     liY1
        clr     liY2
        clr     liX
        lda     feature10_f5
        bit     #ASEHoldb
        beq     NormASE_Interp
        brclr   FxdASEDone,EnhancedBits4,All_ASECount
NormASE_Interp:
        mov     ASEcount,liX
All_ASECount:
        jsr     LinInterp
        lda     tmp6
        add     tmp31
        bcc     aacok
        lda     #255T     ; overflowed, rail at 255%
aacok:
        sta     tmp31
        bra     WUE_DONE

WUE3:
        bclr    startw,engine		; ASE period terminated, turn off bit.

WUE_DONE:
        mov     tmp31,warmcor          ; only store in warmcor after all calcs
***************************************************************************
**
**  Throttle Position Acceleration Enrichment
**
**   Method is the following:
**
**
**   ACCELERATION ENRICHMENT:
**   If (TPS < TPSlast) goto DECELERATION ENLEANMENT
**   If (TPS - TPSlast) > TPSthresh and TPSAEN == 0 {
**      Turn on acceleration enrichment.
**      1) Set acceleration mode.
**      2) Continuously determine rate-of-change of throttle, and
**          perform interpolation of TPSAQ values to determine
**          acceleration enrichment amount to apply.
**   }
**   If (TPSACLK > TPSACLKCMP) and TPSAEN is set {
**      1) Clear TPSAEN engine bit.
**      2) Set TPSACCEL to 0 ms.
**      3) Go to EGO Delta Step Check Section.
**   }
**
**
**   DECELERATION ENLEANMENT:
**   If (TPSlast - TPS) > TPSthresh {
**      If TPSAEN == 1 {
**         1) TPSACCEL = 0 ms (terminate AE early)
**         2) Clear TPSAEN bit in ENGINE
**         3) Go to EGO Delta Step
**      }
**      If RPM > 15 {
**         Turn on deceleration fuel cut.
**         1) Set TPSACCEL value to TPSDQ
**         2) Set TPSDEN bit in ENGINE
**         3) Go to EGO Delta Step Check Section
**      }
**   }
**   else {
**      If TPSDEN == 1 {
**         1) Clear TPSDEN bit in ENGINE
**         2) TPSACCEL = 0 ms
**         3) Go to EGO Delta Step Check Section
**      }
**   }
**
***************************************************************************
TAE_CALC:
        lda     feature4_f
        bit     #KpaDotSetb
        beq     tps_dotty
;        brclr   KpaDotSet,feature4,tps_dotty	; If not in KPA dot mode
						; jump past KPa settings
        bit     #KpaDotBoostb
        beq     No_Boost_Chk
;        brclr   KpaDotBoost,feature4,No_Boost_Chk; Are we going to stop
						; accel in boost?
        lda     kpa
        cmp     #100T
        bhi     TAE_CHK_JMP1		; If KPa above 100 then no
					; accel deccel enrichment
No_Boost_Chk:
        lda     feature9_f
        bit     #NoAccelASEb                ; Are we Acceling during ASE?
        beq     NoASE_Check_Accel
        brset   startw,engine,TAE_CHK_JMP1  ; Is After Start Enrichment running?

NoASE_Check_Accel:
        sei
        mov     kpa,tmp1		; Load kpa into temp1
        lda     TPSlast
        sta     tmp2
        cli
        lda     tmp1
        cmp     tmp2
        bhi     AE_CHK
        beq     Dec_Accel
        jmp     TDE

tps_dotty:
        sei
        mov     tps,tmp1
        lda     TPSlast
        sta     tmp2
        cli
        lda     tmp1
        cmp     tmp2
        bhi     AE_CHK
        beq     Dec_Accel
        jmp     TDE

Dec_Accel:                               ; Throttle steady but lets check if we have just triggered decel
     	brclr   TPSDEN,ENGINE,AE_CHK     ; If we are not decel then check accel threshold
	jmp     TDE			 ; We are deceling so check decel timers, etc

TAE_CHK_JMP1:
        jmp     TAE_CHK_TIME

AE_CHK:
        bclr    TPSDEN,ENGINE
        mov     #100T,TPSfuelCorr
        sub     tmp2
        sta     tmp31
        lda     feature4_f		; Are we in TPS or KPA mode?
        bit     #KpaDotSetb
        beq     tps_ThreshCheck
        lda     tmp31
        cmp     MAPthresh_f		; Are we above the Accel
					; threshold for MAP?
        bhs     AE_SET
        brclr   TPSAEN,ENGINE,acc_done_led   ; If we are not in AE mode then jump to end
        jmp     TAE_CHK_TIME            ; in AE mode so check timer

tps_ThreshCheck:
        lda     tmp31
        cmp     TPSthresh_f1		; Are we above the Accel
					; threshold for TPS?
        bhs     AE_SET

        brclr   TPSAEN,ENGINE,acc_done_led   ; If we are not in AE mode then jump to end
        jmp     TAE_CHK_TIME
AE_SET:
        brset   TPSAEN,ENGINE,AE_COMP_SHOOT_AMT

; Add in accel enrichment
        lda     feature9_f
        bit     #RpmAEBased             ; This is a basic AE system that uses
        beq     NormalBased_AE          ; RPM rather than dot
        ldhx    #RPMbasedrate_f         ; Lets find out the actual AE with respects to RPM
        sthx    tmp1
        mov     #$03,tmp3
        lda     rpm
        sta     tmp4
        sta     tmp10
        jsr     tableLookup             ; Find the rpm bins we are going to use
        clrh
        ldx     tmp5
        lda     RPMAQ_f2,x
        sta     liY2
        decx
        lda     RPMAQ_f2,x
        sta     liY1
        mov     tmp10,liX
        jsr     LinInterp
        lda     tmp6
        bra     Store_TEA1

NormalBased_AE:
        lda     feature4_f
        bit     #KpaDotSetb
        beq     tps_FirstElem
        lda     MAPAQ_f			; start out using first element
					; - will determine actual next
					; time around
        bra     Store_TEA1

tps_FirstElem:
        lda     TPSAQ_f1		; start out using first element
					; - will determine actual next
					; time around

Store_TEA1:
        sta     TPSACCEL		; Acceleration percent amount
					; - used in later calculations
        sta     Decay_Accel
RPMBackAE:
        clr     TPSACLK
        bset    TPSAEN,ENGINE
        bclr    TPSDEN,ENGINE
        brset   REUSE_LED19,outputpins,acc_done_led	; LED already used
							; in NEON as coilb
        bset    aled,portc
acc_done_led:
        jmp     TAE_DONE
TAE_CHK_JMP:
        jmp     TAE_CHK_TIME

; First, calculate cold temperature add-on enrichment value from coolant value,
; from -40 degrees to 165 degrees.
;
; Then determine cold temperature multiplier value ACCELMULT (in percent),
; from -40 degrees to 165 degrees.
;
; Next, calculate squirt amount (quantity) for acceleration enrichment
; Find bins (between) for corresponding TPSdot, and linear interpolate
; to find enrichment amount (from TPSAQ). This is continuously
; checked every time thru main loop while in acceleration mode,
; and the highest value is latched and used.
;
; The final acceleration applied is:
;  AE = Alookup(TPSdot) * (ACCELMULT/100) + TPSACOLD

AE_COMP_SHOOT_AMT:
        ; First, the amount based on cold temperatures
        lda     warmcor
        cmp     #100T         ; And if Warm corr = 100?
        beq     Warmup_OverAE
        clr     liX1			; 0 -> - 40 degrees
        mov     #205T,liX2		; 165 + 40 degrees (because of
					; offset in lookup table)
        lda     TPSACOLD_f1
        sta     liY1			; This is the amount at coldest
        clr     liY2			; no enrichment addon at warm
					; temperature
        lda     coolant
        sta     liX
        jsr     LinInterp
        mov     liY,tmp13		; result - save here temporarily

; Second, find the multiplier (ACCELMULT) amount based on cold temperatures
        clr     liX1			; 0 -> - 40 degrees
        mov     #205T,liX2		; 165 + 40 degrees
        clr     tmp2
        lda     ACMULT_f1
        sta     liY1			; This is the amount at coldest
        mov     #100T,liY2		; 1.00 multiplier at 165 degrees
        lda     coolant
        sta     liX
        jsr     lininterp
        mov     liY,tmp14		; result - save here temporarily
        bra     AECarry_OnAE

Warmup_OverAE:
        lda     #00T                ; If we get here then the warmup = 100 so no need to
        sta     tmp13               ; Add any cold stuff so bypass it
        lda     #100T
        sta     tmp14
AECarry_OnAE:
        lda     feature9_f
        bit     #RpmAEBased             ; This is a basic AE system that uses
        beq     NotRPMBased             ; engine rpm instead of rate of change of tps
        ldhx    #RPMbasedrate_f         ; or map. Amount added is rpm based.
        sthx    tmp1
        mov     #$03,tmp3
        lda     rpm
        sta     tmp4
        sta     tmp10
        jsr     tableLookup             ; Find the rpm bins we are going to use
        clrh
        ldx     tmp5
        lda     RPMAQ_f2,x
        sta     liY2
        decx
        lda     RPMAQ_f2,x
        bra     Carry_On_TEA

NotRPMBased:
        lda     feature4_f
        bit     #KpaDotSetb
        beq     tps_doty

; Now the amount based on MAPdot
        ldhx    #MAPdotrate_f
        sthx    tmp1
        mov     #$03,tmp3
        lda     kpa			; If not store KPa into last_tps
        sub     TPSlast			;
        sta     tmp4			; TPSDOT
        sta     tmp10			; Save away for later use below
        jsr     tableLookup
        bra     miss_tps		; Jump past the tps checks

; Now the amount based on TPSdot
tps_doty:
        ldhx    #TPSdotrate
        sthx    tmp1
        mov     #$03,tmp3
        lda     tps
        sub     TPSlast
        sta     tmp4			; TPSdot
        sta     tmp10			; Save away for later use below
        jsr     tableLookup
miss_tps:
        clrh
        ldx     tmp5

        lda     feature4_f
        bit     #KpaDotSetb
        beq     TPS_Accel_AE

        lda     MAPAQ_f,x		;MAP Based DOT
        sta     liY2
        decx
        lda     MAPAQ_f,x
        bra     Carry_On_TEA

TPS_Accel_AE:
        lda     TPSAQ_f1,x		; TPS Based dot
        sta     liY2
        decx
        lda     TPSAQ_f1,x

Carry_On_TEA:
        sta     liY1
        mov     tmp10,liX
        jsr     LinInterp

        ; Apply the cold multiplier
        mov     tmp6,tmp11
        clr     tmp12
        lda     tmp14
        jsr     uMulAndDiv
        lda     tmp11
        add     tmp13			; Add on the amount computed in
					; cold temperature enrich above
        sta     tmp6
        cmp     TPSACCEL
        bhi     Higher_AcJMP

; Check if acceleration done
TAE_CHK_TIME:
        brset   TPSDEN,ENGINE,RST_ACCJMP
        lda     TPSaclk
        cmp     TPSASYNC_f1
        bhs     RST_ACCJMP

; MAP or TPS rate stable now so have we selected to interpolate the
; accel enrichments?
        lda     feature8_f
        bit     #InterpAcelb
        bne     Decay_AE_Aw

        lda     feature9_f              ; We are not decaying AE but are we doing RPM based?
        bit     #RpmAEBased             ; If we are in rpm AE mode then check
        beq     TAE_DONEJ               ; rpm AE value as it may be lower than the
        ldhx    #RPMbasedrate_f         ; earlier calculated stuff if rpm has increased.
        sthx    tmp1
        mov     #$03,tmp3
        lda     rpm
        sta     tmp4
        sta     tmp10
        jsr     tableLookup             ; Find the rpm bins we are going to use
        clrh
        ldx     tmp5
        lda     RPMAQ_f2,x
        sta     liY2
        decx
        lda     RPMAQ_f2,x
        sta     liY1
        mov     tmp10,liX
        jsr     LinInterp
        lda     tmp6
        sta     TPSACCEL                ; Store new AE enrichment
TAE_DONEJ:
        jmp     TAE_DONE

Higher_AcJMP:
        bra     Higher_Accel

RST_ACCJMP:
        bra     RST_ACCEL

; Decay the Accel enrichment away to a setpoint in the time period set - Phil
Decay_AE_Aw:
        lda     AccelDecay_f
        cmp     TPSACCEL		; Only do interpolated Decay if
					; Accel is higher than target point
        bhs     TAE_DONEJMP
        sta     liY2			; Load in the Decay PW value in mS
					; at the end of the timer
        clr     lix1			; Acceltimer Start point for
					; linear interpolater.
        lda     TPSASYNC_f1
        sta     lix2			; Stick the max time in lix2 for
					; linear interpolater.
        lda     Decay_Accel
        sta     liY1			; Load in the actual maximum PW we
					; calculated fo the Accel to
					; interpolate from
        lda     TPSaclk
        sta     lix			; Actual timer point
        jsr     lininterp		; Go and work out the value
        lda     tmp6
        sta     tmp31                   ; Save true result for a moment

        lda     feature9_f
        bit     #RpmAEBased             ; If we are in rpm AE mode then check
        beq     NormAEMode              ; rpm AE value as it may be lower than the
        ldhx    #RPMbasedrate_f         ; Decay value.
        sthx    tmp1
        mov     #$03,tmp3
        lda     rpm
        sta     tmp4
        sta     tmp10
        jsr     tableLookup             ; Find the rpm bins we are going to use
        clrh
        ldx     tmp5
        lda     RPMAQ_f2,x
        sta     liY2
        decx
        lda     RPMAQ_f2,x
        sta     liY1
        mov     tmp10,liX
        jsr     LinInterp
        lda     tmp6
        cmp     tmp31                   ; Is the RPM value lower than the
        blo     StoreTPSACCEL           ; AE value? tmp6 < tmp31 ?

NormAEMode:
        lda     tmp31

StoreTPSACCEL:
        sta     TPSACCEL		; Save decaying accel value
TAE_DONEJMP:
        jmp     TAE_DONE

Higher_Accel:
        lda     tmp6			; Replace with this higher value
        sta     TPSACCEL
        sta     Decay_Accel		; Decaying Accel value
        jmp     TAE_DONE

RST_ACCEL:
        mov     #100T,TPSfuelCorr
        clr     TPSACCEL
        clr     Decay_Accel
        bclr    TPSAEN,ENGINE
        bclr    TPSDEN,ENGINE
        brset   REUSE_LED19,outputpins,TAE_DONE
        bclr    aled,portc		; not in Neon
        bra     TAE_DONE

; deaccel
TDE:
        lda     feature6_f
        bit     #NoDecelBoostb		; Have we selected to use Decel
					; all the time?
        beq     NormDecel
        lda     kpa
        cmp     DecelKpa_f
        bhi     TAE_DONE		; If KPa above user defined amount
					; then no decel enrichment

NormDecel:
        brset   TPSDEN,ENGINE,CheckDecelT ; If we are already decelin then carry on with it
        lda     tmp2
        sub     tmp1
        sta     tmp31
        lda     feature4_f		; Are we in TPS or KPA mode?
        bit     #KpaDotSetb
        beq     tps_Decell
        lda     tmp31
        cmp     MAPthresh_f
        blo     TDE_CHK_DONE
        brclr   TPSAEN,ENGINE,TDE_CHK_FUEL_CUT
        bra     Clear_Decel

tps_Decell:
        lda     tmp31
        cmp     TPSthresh_f1
        blo     TDE_CHK_DONE
        brclr   TPSAEN,ENGINE,TDE_CHK_FUEL_CUT

Clear_Decel:
        mov     #100T,TPSfuelCorr
        clr     TPSACCEL
        clr     Decay_Accel
        bclr    TPSAEN,ENGINE
        bclr    TPSDEN,ENGINE
        brset   REUSE_LED19,outputpins,TAE_DONE
        bclr    aled,portc		; not in Neon
        bra     TAE_DONE

TDE_CHK_FUEL_CUT:
        lda     rpm
        cmp     #15T			; Only active above 1500
        blo     TAE_DONE
        bset    TPSDEN,ENGINE
        bclr    TPSAEN,ENGINE
        clr     TPSaclk

CheckDecelT:				; New decel timer
        lda     TPSDQ_f1
        sta     TPSfuelCorr
        lda     TPSaclk                 ; Use accel timer for decel timer
        cmp     TPSASYNC_f1
    ;    cmp     #2T                     ; Have we deceled for 200mSec?
        bhs     Clear_Decel

        brset   REUSE_LED19,outputpins,TAE_DONE
        bclr    aled,portc		; not in Neon
        bra     TAE_DONE

TDE_CHK_DONE:
        brclr   TPSDEN,ENGINE,TAE_DONE
        bclr    TPSDEN,ENGINE
        mov     #100T,TPSfuelCorr
        clr     TPSACCEL
        clr     Decay_Accel

TAE_DONE:

***************************************************************************
**
**  Exhaust Gas Oxygen Sensor Measurement Section
**
**   Steps are the following:
**
**   If EGOdelta = 0                                 then skipo2
**   If KPA > 100                                    then skipo2
**   If RPM < ego_rpm                                then skipo2
**   If TPSAEN in ENGINE or TPSDEN in ENGINE are set then skipo2
**   If coolant < EGOtemp                            then skipo2
**   If sech = 0 and secl < 30 seconds               then skipo2
**     (skip first 30 seconds)
**   If TPS > 3.5 volts                              then skipo2
**
**   If EGOcount > EGOcountcmp {
**      EGOcount = 0
**      If EGO > 26 (counts, or 0.5 Volts) then (rich) {
**         tpm = EGOcurr - EGOdelta
**         if tpm >= EGOlimit then EGOcorr = tpm
**         return
**      }
**      else (lean) {
**         tpm = EGOcorr + EGOdelta
**         if tpm > EGOlimit then EGOcorr = tpm
**         return
**      }
**   }
**
**   skipo2:
**   EGOcorr = 100%
**
***************************************************************************

EGO_CALC:
         lda     feature3_f
         bit     #WaterInjb
         beq     no_ego_w_chk
;        brclr   WaterInj,feature3,no_ego_w_chk
        brset   water,porta,SKIP_ALL_O2	; if water injection on
					; skip both O2 checks
no_ego_w_chk:
        brset   NosSysOn,EnhancedBits,SKIP_ALL_O2; If NOS running then no
					;O2 checks
        brset   OverRun,EnhancedBits,SKIP_ALL_O2; Skip O2 if in Overrun mode
        lda     EGOdelta_f		; No delta means open loop.
        beq     SkipO2JMP

         lda     feature3_f
         bit     #KPaTpsOpenb
         beq     throttle_check
;        brclr KPaTpsOpen,feature3,throttle_check	; 0 = throttle do
					; throttle check  1 = KPa
        lda   kpaO2_f			; In KPa mode so is it higher
					; than setpoint?
        beq   SETAFR_UP			; If its zero dont check it as
					; no open loop
        cmp   kpa
        blo   SKIP_ALL_O2		; If it is dont check O2
No_KPA_Check:
        bra   SETAFR_UP

throttle_check:
	  lda	  tpsO2_f		; Throttle position setpoint
					; check for open loop
          beq     SETAFR_UP		; If its zero dont check it
					; as no open loop
	  cmp	  tps			; Load in TPS
	  blo	  SKIP_ALL_O2
          bra     SETAFR_UP

SkipO2JMP:
         bra    SKIPO2A

SKIP_ALL_O2:				; Skip both O2 checks
         lda    #100T
         sta    EGOCorr
         sta    EgoCorr2
         jmp    EGOALL_DONE

SETAFR_UP:
         lda     feature3_f
         bit     #TargetAFRb
         bne     CheckVE1
;        brset   TargetAFR,feature3,CheckVE1	; Target AFR?

Re_CheckTarg:
         lda     feature6_f
         bit     #TargetAFR3b
         bne     CheckVE3
;        brset   TargetAFR3,feature6,CheckVE3
        jmp     SETAFRNORMAL

CheckVE1:
         brset  useVE3,EnhancedBits,Re_CheckTarg; Are we are using VE3
						; at present if so check
						; if targets needed?
         bra    SETAFRTABLE

CheckVE3:
         brset  useVE3,EnhancedBits,SETAFRTABLE	; If were not running in
						; VE3 then no targets

SETAFRNORMAL:				; Normal setting for AFR
        lda     O2targetV_f
        sta     afrTarget

SETAFRTABLE:				; AFR Table value is already in
					; afrTarget
        lda     ego
        sta     tmp32			; Make tmp32 = the ego raw adc
					; in narrow band or non AFR target mode

AFTERAFRSET:
        brset   TPSAEN,ENGINE,Skip_ALL_O2
        brset   TPSDEN,ENGINE,Skip_ALL_O2
        brset   Traction,EnhancedBits2,Skip_ALL_O2

        lda     sech
        bne     chk_o2_lag		; if high seconds set then we
					; can check o2
        lda     secl
        cmp     #30T			; 30 seconds threshold
        blo     Skip_ALL_O2

CHK_O2_LAG:
; Check if exceeded lag time - if so then we can modify EGOcorr
        lda     EGOcount
        cmp     EGOcountcmp_f
        blo     EGOALL_DONEJMP
; Check if we are over the O2 operating temp
        lda     coolant
        cmp     EGOtemp_f
        blo     SkipO2A
        bra     Do_The_Ego

EGOALL_DONEJMP:
        bra     EGOALL_DONE

Do_The_Ego:
        lda     rpm			; Over EGOrpm we go closed loop.
        cmp     EGOrpm_f
        blo     SkipO2A

; Check if rich/lean
        clr     EGOcount
        lda     kpa			; See if we need to load in a
					; new Ego Limit
        cmp     EgoLimitKPa_f
        bhi     New_EgoLim
        lda     EGOlimit_f		; Original Ego Limit
        sta     tmp31
        bra     EgoLim_Done
New_EgoLim:
        lda     EgoLim2_f		; New Ego Limit
        sta     tmp31
EgoLim_Done:

        lda     config13_f1		; Check if Narrow-band (bit=0)
					; or DIY-WB (bit=1)
        bit     #c13_o2			; Use BIT instead of brset
					; because outside of zero-page
        bne     WBO2TYPE		; Branch if the bit is set
NBO2TYPE:
        lda     tmp32			; EGO
        cmp     afrTarget
        blo     O2_IS_LEAN
        bra     O2_IS_RICH

SkipO2A:				; Jmp for Skip O2
        bra     SkipO2

WBO2TYPE:
        lda     tmp32
        cmp     afrTarget
        bhi     O2_IS_LEAN

; rich o2 - lean out EGOcorr
O2_IS_RICH:
        lda     #100T
        sub     tmp31			; Generate the lower limit rail point
        sta     tmp2
        lda     EGOcorr
        sub     EGOdelta_f		; remove the amount required per step.
        sta     tmp1
        cmp     tmp2
        blo     EGO_DONE		; railed at EGOlimit value
        lda     tmp1
        sta     EGOcorr
        bra     EGO_DONE

; lean o2 - richen EGOcorr
O2_IS_LEAN:
        lda     #100T
        add     tmp31			; Generate the upper limit rail point
        sta     tmp2

        lda     EGOcorr
        add     EGOdelta_f
        sta     tmp1
        cmp     tmp2
        bhi     EGO_DONE		; railed at EGOlimit value
        lda     tmp1
        sta     EGOcorr
        bra     EGO_DONE

; reset EGOcorr to 100%
SkipO2:
        lda     #100T
        sta     EGOcorr
EGO_DONE:
        lda       DTmode_f		; check if DT in use
        bit       #alt_i2t2
        beq      No_DT_SecondO2
        lda     feature12_f2
        bit     #SecondO2b
        bne     DO_Second_Ego
;        brset    SecondO2,feature4,DO_Second_Ego	; Do we have a second
                                                        ; O2 sensor?
No_DT_SecondO2:
        lda     Egocorr
        sta     Egocorr2
EGOALL_DONE:
        jmp     EGO_2Done

;Second O2 Sensor runs from Page2 Enrichments

DO_Second_Ego:
        clr     EGOcount

        lda     rpm			; Over EGOrpm we go closed loop.
        cmp     EGOrpm_f2
        blo     SkipO22
        lda     coolant
        cmp     EGOtemp_f2
        blo     SkipO22

         lda     feature3_f
         bit     #TargetAFRb
         bne     Check2VE1
;        brset   TargetAFR,feature3,Check2VE1	; Target AFR?

Re_Check2Targ:
         lda     feature6_f
         bit     #TargetAFR3b
         bne     Check2VE3
;        brset   TargetAFR3,feature6,Check2VE3
        jmp     SETAFRNORMAL2

Check2VE1:
         brset  useVE3,EnhancedBits,Re_Check2Targ	; Are we are using
							; VE3 at present if
							; so check if targets
							; needed?
         bra    SETAFRTABLE2

Check2VE3:
         brset  useVE3,EnhancedBits,SETAFRTABLE2	; If were not running
							; in VE3 then no
							; targets

SETAFRNORMAL2:				; Normal setting for AFR
        lda     O2targetV_f2
        sta     afrTarget

SETAFRTABLE2:
        lda     o2_fpadc
        sta     tmp32

AFTERAFRSET2:
        lda     kpa			; See if we need to load in a
					; new Ego Limit
        cmp     EgoLimitKPa_f
        bhi     EgoLim2_New
        lda     EGOlimit_f2		; Original Ego Limit from page 2
        sta     tmp31			; We can re-use this as its
					; reset every time
        bra     EgoLim2_Done

EgoLim2_New:
        lda     EgoLim2_f		; New Ego Limit
        sta     tmp31

EgoLim2_Done:

        lda     config13_f2		; Check if Narrow-band (bit=0)
					; or DIY-WB (bit=1)
        bit     #c13_o2			; Use BIT instead of brset because
					; outside of zero-page
        bne     WBO2TYPE2		; Branch if the bit is set
NBO2TYPE2:
        lda     tmp32			; ADC from Second O2
        cmp     afrTarget
        blo     O2_IS_LEANER
        bra     O2_IS_RICHER

WBO2TYPE2:
        lda     tmp32
        cmp     afrTarget
        bhi     O2_IS_LEANER

; rich o2 - lean out EGOcorr2
O2_IS_RICHER:
        lda     #100T
        sub     tmp31			; Generate the lower limit rail point
        sta     tmp2
        lda     EgoCorr2
        sub     EGOdelta_f2
        sta     tmp1
        cmp     tmp2
        blo     EGO_2Done		; railed at EGOlimit value
        lda     tmp1
        sta     EgoCorr2
EGO_2DoneJMP:
        bra     EGO_2Done

SkipO22:
        lda     #100T
        sta     EgoCorr2
        bra     EGO_2Done

; lean o2 - richen EGOcorr2
O2_IS_LEANER:
        lda     #100T
        add     tmp31			; Generate the upper limit rail point
        sta     tmp2
        lda     EgoCorr2
        add     EGOdelta_f2
        sta     tmp1
        cmp     tmp2
        bhi     EGO_2Done		; railed at EGOlimit value
        lda     tmp1
        sta     EgoCorr2
EGO_2Done:

***************************************************************************
***************************************************************************
***************************************************************************
**
** Computation of Fuel Parameters
**
** Remainders are maintained for hi-resolution calculations - results
**  converted back to 100 microsecond resolution at end.
**
** (Warm * Tpsfuelcut)/100 = R1 + rem1/100
** (Barcor * Aircor)/100 = R2 + rem2/100
** ((R1 + rem1/100) * (R2 + rem2/100)) / 100 = R3 + rem3/100
** (EGO * MAP)/100 = R4 + rem4/100
** ((R3 + rem3/100) * (R4 + rem4/100)) /100 = R5 + rem5/100
** (VE * REQ_FUEL)/100 = R6 + rem6/100
** ((R5 + rem5/100) * (R6 + rem6/100))  = R7
**
**
**
** Note: that GAMMAE only includes Warm, Tpsfuelcut, Barocor, and Aircor
** (EGO no longer included)
**
** Rationle on ordering: to prevent calculation overflow for boosted
** operations, the variables have been ordered in specific "pairs" in
** the calculation:
**   EGO * MAP - when at WOT, EGO is set to 100%,
**   so MAP can run up to 255% without overflow
**   VE * REQ_FUEL - for boosted applications,
**   REQ_FUEL tends to be low (below 10 ms) due to the added fuel
**   requirements (i.e. large injectors), so VE entries can be well
**   above 100%.
**
***************************************************************************



WARMACCEL_COMP:

        mov     warmcor,tmp10		; Warmup Correction in tmp10
        clr     tmp11			; tmp11 is zero
        mov     TPSfuelcorr,tmp12	; tpsfuelcut in tmp12
        clr     tmp13			; tmp13 is zero
        jsr     Supernorm		; do the multiply and normalization
        mov     tmp10,tmp31		; save whole result in tmp31
        mov     tmp11,tmp32		; save remainder in tmp32

        mov     barocor,tmp10		; tmp10 is barometer percent
        clr     tmp11			; zero to tmp11
        mov     AirCor,tmp12		; air temp correction % in tmp12
        clr     tmp13			; tmp13 is zero
        jsr     Supernorm		; multiply and divide by 100
					; result in tmp10:tmp11
        mov     tmp31,tmp12		; move saved tmp31 into tmp12
        mov     tmp32,tmp13		; move saved tmp32 into tmp13
        jsr     Supernorm		; multiply/divide
        mov     tmp10,tmp5		; save whole result into tmp5
        mov     tmp11,tmp6		; save remainder into tmp6

        lda     DTmode_f		; Must check the INJ1 GammaE bit,
        bit     #alt_i1ge		; if 0 then set it to 100T to
					; remove GammaE.
        bne     ld_ve_1
        mov     #100T,GammaE
        bra     ld_ve_1Done

ld_ve_1:
        mov     tmp10,GammaE

ld_ve_1Done:
        mov     EGOcorr,tmp10		; closed-loop correction percent
					; into tmp10
        clr     tmp11			; remainder is zero

        brset  hybridAlphaN,feature1,skip_loadcontcomp	; if hybrid then
							; skip AN bypass

        lda    config13_f1
        bit     #c13_cs
        beq     MAFCheck                ; No Alpha but are we using MAF?
        bra     LoadContribDone

MAFCheck:
        lda     feature9_f
        bit     #MassAirFlwb
        beq     skip_loadcontcomp       ; Are we using a MAF on pin X7?
        bra     LoadContribDone

skip_loadcontcomp:
        mov     kpa,tmp12		; MAP into tmp12
        clr     tmp13			; no remainder
        jsr     Supernorm		; do the multiply and divide

; NORMAL KPA stuff now
LoadContribDone:

        mov     tmp5,tmp12		; take saved result in tmp5 and put into tmp12
        mov     tmp6,tmp13		; tmp6 into tmp13
        jsr     Supernorm		; mult/div
        mov     tmp10,tmp3		; result (whole) save in tmp3
        mov     tmp11,tmp4		; remainder result save in tmp4

        mov     vecurr,tmp10		; VE into tmp10
        clr     tmp11			; no remainder value for VE

        lda     page
        cmp     #01T
        beq     rqfr1
        lda     REQ_FUEL_f1
        bra     rqfe1
rqfr1:
        lda     REQ_FUEL_r
rqfe1:
        sta     tmp12			; req-fuel into tmp12
        clr     tmp13			; no remainder
        jsr     Supernorm		; mult/div

        mov     tmp3,tmp12		; take previous result and put in tmp12
        mov     tmp4,tmp13		; again for remainder
        jsr     Supernorm		; multiply/divide
        mov     tmp10,tmp11

;	jsr     BATT_CORR_CALC		; result in tmp6  <- f(Vbatt)


***************************************************************************
** For    V E   T A B L E  1 and 3
** Calculation of Battery Voltage Correction for Injector Opening Time
**
** Leaves result in liY == tmp6.
** Mangles tmp1-tmp5.
**
** Injector open time is implemented as a linear function of
**  battery voltage, from 7.2 volts (61 ADC counts) to 19.2 volts (164 counts),
**  with 13.2 volts (113 counts) being the nominal operating voltage
**
** INJOPEN = injector open time at 13.2 volts in mms
** BATTFAC = injector open adjustment factor 6 volts from 13.2V in mms
**
**
** + (INJOPEN + BATTFAC)
** +   *
** +                     (INJOPEN)
** +                         *
** +                                       (INJOPEN - BATTFAC)
** +                                               *
** +
** ++++++++++++++++++++++++++++++++++++++++++++++++++++++
**           7.2v          13.2v          19.2v
**
***************************************************************************

BATT_CORR_CALC:
        clrh
BATT_CORR_PW:
        mov     #061T,liX1		; x1
        mov     #164T,liX2		; x2
        lda     InjOpen_f1
        add     battfac_f1
        sta     liY1			; y1
        lda     injopen_f1
        sub     battfac_f1
        sta     liY2			; y2
        bpl     MBFF			; y2 < 0, underflow
        clr     liY2			; Screws up slope, but gives
					; reasonable result.
MBFF:
        mov     batt,liX		; xInterp
        jsr     LinInterp		; injector open time in tmp6

***************************************************************************
* Check if 300kpa or 400kpa map sensor
***************************************************************************

        lda     config11_f1
        and     #$03
        cmp     #$02			; Are we using Turbo Map sensor?
        blo     CALC_FINAL    ; skip if 0 or 1

; If we get here we are using non-standard map sensor
; so do kpa * compensation factor to work out larger kpa
; value then add it back to the normal kpa cals later

        cbeqa   #2T,mul300
        ldx     #KPASCALE400
        bra     lcd_cont
mul300:
        ldx     #KPASCALE300
lcd_cont:
        lda     tmp11
        mul
        txa
        add     tmp11
        bcc     Store_Mod_KPa1
        lda     #255T           ; Limit
Store_Mod_KPa1:
        sta     tmp11


***************************************************************************
**       F O R    V E   T A B L E   1 and 3
** Calculation of Final Pulse Width
**
**  The following equation is evaluated here:
**
**  tmp20 = tmp6 + TMP11 + TPSACCEL - INJOCFUEL
**
**  Note that InjOCFuel (injected fuel during injector open and
**  close) is currently a constant - eventually it will be a function
**  of battery voltage.
**
***************************************************************************
CALC_FINAL:

        lda     tmp11			; From required fuel, above.
        beq     PW_Done			; If no calculated pulse, then
					; don't open at all.
        add     tmp6			; from batt correction
        bcs     MaxPulse
        add     TPSACCEL
        bcs     MaxPulse
        bra     PW_Done

MaxPulse:
        lda     #$FF
PW_Done:

        sta     tmp20
        lda     feature5_f
        bit     #stagedeither
        beq     Calc_Final1Done
        jsr     CALC_STAGED_PW   ; Do the Staged PW calculations if set
Calc_Final1Done:
****************************************************************************


	mov     tmp20,tmp1		; store PW from table 1
	lda     DTmode_f
	bit     #alt_i2t2
	bne     do_dt
        jmp     both_table1		; if (inj2=t2) =0 then single table

do_dt:
; calc 'PW2' from table 2
        mov     tmp20,tmp22		; storage for PW1 whilst doing DT
        bset    page2,EnhancedBits4	; set page2
***************************************************************************
** Maybe lazy, but we have lots of flash, so quicker to have one
** routine per page
***************************************************************************
VE2_LOOKUP:				; ALWAYS page 2
        clrh
        clrx

        lda     feature9_f
        bit     #MassAirFlwb
        beq     VE2_LOOKUP_PW1          ; Are we using a MAF on pin X7?
        lda     o2_fpadc                ; Using MAF thats on pin X7
        bra     VE2_STEP_1

VE2_LOOKUP_PW1:
        lda     config13_f2
        bit     #c13_cs
        bne     VE2_AN			; if alpha-N
        lda     kpa			; SD, so use kpa for load
        bra     VE2_STEP_1
VE2_AN:
        lda     tps

VE2_STEP_1:
        sta     kpa_n
        ldhx    #KPARANGEVE_f2
        sthx    tmp1
        lda     #$0b
        sta     tmp3
        lda     kpa_n
        sta     tmp4
        jsr     tableLookup
        lda     tmp1
        lda     tmp2
        mov     tmp5,tmp8		; Index
        mov     tmp1,tmp9		; X1
        mov     tmp2,tmp10		; X2

VE2_STEP_2:
        ldhx    #RPMRANGEVE_f2
        sthx    tmp1
        mov     #$0b,tmp3		; 12x12
        mov     rpm,tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		; Index
        mov     tmp1,tmp13		; X1
        mov     tmp2,tmp14		; X2

VE2_STEP_3:

        clrh
        ldx     #$0c			; 12x12
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        VE2X
        sta     tmp15
        incx
        VE2X
        sta     tmp16
        ldx     #$0c			; 12x12
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        VE2X
        sta     tmp17
        incx
        VE2X
        sta     tmp18

        jsr     VE_STEP_4
        mov     tmp6,vecurr2

 ;*********** Dual Table CALCULATIONS***********************************
 ; I think theres only need to do this bit as the rest would have been done in VE1?

        mov     warmcor,tmp10		; Warmup Correction in tmp10
        clr     tmp11			; tmp11 is zero
        mov     tpsfuelcorr,tmp12	; tpsfuelcut in tmp12
        clr     tmp13			; tmp13 is zero
        jsr     Supernorm		; do the multiply and normalization
        mov     tmp10,tmp31		; save whole result in tmp31
        mov     tmp11,tmp32		; save remainder in tmp32

        mov     barocor,tmp10		; tmp10 is barometer percent
        clr     tmp11			; zero to tmp11
        mov     AirCor,tmp12		; air temp correction % in tmp12
        clr     tmp13			; tmp13 is zero
        jsr     Supernorm		; multiply and divide by 100

					; result in tmp10:tmp11

        mov     tmp31,tmp12		; move saved tmp31 into tmp12
        mov     tmp32,tmp13		; move saved tmp32 into tmp13
        jsr     Supernorm		; multiply/divide
        mov     tmp10,tmp5		; save whole result into tmp5
        mov     tmp11,tmp6		; save remainder into tmp6

        lda     DTmode_f
        bit     #alt_i2ge
        bne     ld_ve_2			; Are we using gammae in Second PW?
        mov     #100T,GammaE
        bra     ld_ve2_Done

ld_ve_2:
        mov     tmp10,GammaE
ld_ve2_Done:
        mov     EGOcorr2,tmp10		; closed-loop correction percent
					; into tmp10
        clr     tmp11			; remainder is zero

        brset  hybridAlphaN,feature1,skip_loadccomp2	; if hybrid then
							; skip AN bypass

        lda    config13_f2
        bit     #c13_cs
        beq     skip_loadccomp2      ; Ignore if not alpha-N

        lda     feature9_f             ; Using Alhpa-n so
        bit     #BaroCorConstb         ; are we adding the KPa factor?
        beq     LoadContribDn2

skip_loadccomp2:

        mov     kpa,tmp12		; MAP into tmp12
        clr     tmp13			; no remainder
        jsr     Supernorm		; do the multiply and divide

; NORMAL KPA stuff now
LoadContribDn2:
        mov     tmp5,tmp12		; take saved result in tmp5 and put into tmp12
        mov     tmp6,tmp13		; tmp6 into tmp13
        jsr     Supernorm		; mult/div
        mov     tmp10,tmp3		; result (whole) save in tmp3
        mov     tmp11,tmp4		; remainder result save in tmp4

        mov     vecurr2,tmp10		; VE into tmp10
        clr     tmp11			; no remainder value for VE
        lda     page
        cmp     #02T
        beq     rqfr2
        lda     REQ_FUEL_f2
        bra     rqfe2
rqfr2:
        lda     REQ_FUEL_r

rqfe2:

        sta     tmp12			; req-fuel into tmp12
        clr     tmp13			; no remainder
        jsr     Supernorm		; mult/div

        mov     tmp3,tmp12		; take previous result and put in tmp12
        mov     tmp4,tmp13		; again for remainder
        jsr     Supernorm		; multiply/divide

        mov     tmp10,tmp11

End_DTCalcs:

    ;     jsr     BATT_CORR_CALC		; result in tmp6

          bra     BATT_CORR_CALC2


***************************************************************************
**            For    V E   T A B L E   2
** Calculation of Battery Voltage Correction for Injector Opening Time
**
** Leaves result in liY == tmp6.
** Mangles tmp1-tmp5.
**
** Injector open time is implemented as a linear function of
**  battery voltage, from 7.2 volts (61 ADC counts) to 19.2 volts (164 counts),
**  with 13.2 volts (113 counts) being the nominal operating voltage
**
** INJOPEN = injector open time at 13.2 volts in mms
** BATTFAC = injector open adjustment factor 6 volts from 13.2V in mms
**
**
** + (INJOPEN + BATTFAC)
** +   *
** +                     (INJOPEN)
** +                         *
** +                                       (INJOPEN - BATTFAC)
** +                                               *
** +
** ++++++++++++++++++++++++++++++++++++++++++++++++++++++
**           7.2v          13.2v          19.2v
**
***************************************************************************

BATT_CORR_CALC2:
        clrh
        mov     #061T,liX1		; x1
        mov     #164T,liX2		; x2
        lda     injopen_f2
        add     battfac_f2
        sta     liY1			; y1
        lda     injopen_f2
        sub     battfac_f2
        sta     liY2			; y2
        bpl     MBFF2			; y2 < 0, underflow
        clr     liY2			; Screws up slope, but gives
					; reasonable result.
MBFF2:
        mov     batt,liX		; xInterp
        jsr     LinInterp		; injector open time in tmp6

***************************************************************************
* Check if 300kpa or 400kpa map sensor
***************************************************************************

        lda     config11_f1
        and     #$03
        cmp     #$02			; Are we using Turbo Map sensor?
        blo     CALC_FINAL2    ; skip if 0 or 1

; If we get here we are using non-standard map sensor
; so do kpa * compensation factor to work out larger kpa
; value then add it back to the normal kpa cals later

        cbeqa   #2T,mul300_2
        ldx     #KPASCALE400
        bra     lcd_cont2
mul300_2:
        ldx     #KPASCALE300
lcd_cont2:
        lda     tmp11
        mul
        txa
        add     tmp11
        bcc     Store_Mod_KPa2
        lda     #255T           ; Limit
Store_Mod_KPa2:
        sta     tmp11

***************************************************************************
**       F O R    V E   T A B L E   2
** Calculation of Final Pulse Width
**
**  The following equation is evaluated here:
**
**  tmp20 = tmp6 + TMP11 + TPSACCEL - INJOCFUEL
**
**  Note that InjOCFuel (injected fuel during injector open and
**  close) is currently a constant - eventually it will be a function
**  of battery voltage.
**
***************************************************************************
CALC_FINAL2:

        lda     tmp11			; From required fuel, above.
        beq     PW2_Done			; If no calculated pulse, then
					; don't open at all.
        add     tmp6			; from batt correction
        bcs     MaxPulse2
        add     TPSACCEL
        bcs     MaxPulse2
        bra     PW2_Done

MaxPulse2:
        lda     #$FF
PW2_Done:
        sta     tmp21           ; PW2 temp

Calc_Final2Done:
****************************************************************************

        mov     tmp22,tmp1		; When DT done put PW1 back into tmp1

PW2_calc:
        clr     tmp2
        lda     DTmode_f
        bit     #alt_i2t2		; if inj2 is not driven from
					; table1 then skip
        bne     pw2_table2
        mov     tmp20,tmp2		; 'PW' from table 1
        bra     checkRPMsettings
pw2_table2:
        mov     tmp21,tmp2		; 'PW' from table 2
        bra     checkRPMsettings

both_table1:
        lda     tmp20
        sta     tmp1
        sta     tmp2

checkRPMsettings:
        ; Do all the rpm related stuff here.

        brclr  ShiftLight,feature2,ShiftLightDone
        lda    feature8_f   ; if spark output E then no shift lights
        bit    #spkeopb
        bne    ShiftLightDone
        ; if rpm < shiftLo  bclr p3_3, bclr p3_4
        ; shiftMd = (shiftLo+shiftHi)/2
        ; if rpm < shiftMd  bset p3_3, bclr p3_4
        ; if rpm < shiftHi  bclr p3_3, bset p3_4
        ; otherwise         bset p3_3, bset p3_4
;if wheel decoder second input is enabled then lower limit only functions

        lda    shiftLo_f
        cmp    rpm
        bls    shiftLight1
        bclr   3,portc
        brset  wd_2trig,feature1,shiftLightDone
        bclr   4,portc
        bra    shiftLightDone
shiftLight1:
        add    shiftHi_f
        rora
        cmp    rpm
        bls    shiftLight2
        bset   3,portc
        brset  wd_2trig,feature1,shiftLightDone
        bclr   4,portc
        bra    shiftLightDone
shiftLight2:
        lda    shiftHi_f
        cmp    rpm
        bls    shiftLight3
        bclr   3,portc
        bset   4,portc
        bra    shiftLightDone
shiftLight3:
        bset   3,portc
        brset  wd_2trig,feature1,shiftLightDone
        bset   4,portc
shiftLightDone:

;Hard Cut Rev and Launch checks
        bclr    sparkCut,RevLimBits		; Reset spark cut bit
        brclr   LaunchControl,feature2,LaunchDone; Is Launch selected?
;Changes to launch system for 025y - JSM
        brset   Launch,portd,Reset_VL		; Button not pressed so
						; reset variable bit
        lda     VlaunchLimit
        cmp     #08T				; If launch limit higher
	bhi     chk_launch_lim			; than 800 then it has been set

;if it is currently zero then we are arming the system.
;If in Vlaunch mode we grab current rpm and save that as the limit
;Else, if rpm > LC_flatsel then use flat shift limit
;else use fixed launch limit
        lda     feature3_f
        bit     #VarLaunchb                     ; Is variable launch wanted,
        beq     No_V_Launch_On                  ; if not go to fixed section

        lda     rpm				; load rpm and set this as limit
        bra     str_launch			;

No_V_Launch_On:
        lda     rpm				; higher or lower than launch/flat limit
        cmp     LC_flatsel_f
        blo	set_launch		        ; lower, so launch
        lda     N2Odel_flat_f                   ; load flat shift delay
        sta     N2Olaunchdel                    ; store into launch/nitrous delay timer
        bset    lc_fs,SparkBits                 ; set flatshift mode on
        lda     LC_flatlim			; higher so use flat shift limit
        bra     str_launch

set_launch:
        lda     N2Odel_launch_f                 ; load launch delay
        sta     N2Olaunchdel                    ; store into launch/nitrous delay timer
        lda     Launchlimit_f                   ; use launch limit
        bra     str_launch

Reset_VL:
        clra
        bclr    lc_fs,SparkBits                 ; make sure flatshift mode off

str_launch:
        sta     VlaunchLimit			; Reset Launch Limit var
        bra     LaunchDone			; Not in Launch mode so

chk_Launch_lim:
        lda     tps				; Is throttle in right place?
        cmp     LC_Throttle_f
        blo     LaunchDone			; No then no LC

        lda     Vlaunchlimit			; load up limit
        cmp     rpm
        blo     Chk_Cuts			; We've hit the limiter...
LaunchDone:

; ***Over Boost Protection**********************************
            lda    Over_B_P_f			; load in Over boost KPa value
            cmp    #101T
            blo    BoostP_Done			; If set to less than 100KPa
						; then no boost protection
            cmp    kpa				; Is the kpa higher than the
						; boost safety high limit?
            bhi    BoostP_Done
            lda    feature5_f
            bit    #BoostCutb
            beq    B_SparkFuel                  ; Spark Cut Mode?

            lda    SparkCutCnt
            cmp    SparkCutBNum_f		; Have we sparked more than
						; the user defined number?
            bhi    B_SparkFuel			; Yes so dont cut any more
						; sparks
            bset   sparkCut,RevLimBits		; No so cut next spark

B_SparkFuel:
           lda    feature5_f
           bit    #BoostCut2b
           bne    cutChannels
           bra     checkRevsOk
BoostP_Done:

;implement fuel cut from rev limiter soft limiter
        brset   RevLimHSoft,RevLimBits,Chk_Rev_Cuts

        ; Hard-cut rev limiter, done here during pulse
        ; calcs to avoid timing issues if we set pw and
        ; then reset it a few instructions later.  I was
        ; seeing "ghost" pulses when this was the case.
checkHighLimit:
        lda     revLimit_f
        beq     checkRevsOk			; Zero means no limit
        cmp     rpm
        bhs     checkRevsOk			; We have not hit any
						; Rev limits

; IF we get here we are in rev limit hard cut mode so check for
; fuel or and spark cut
Chk_Rev_Cuts:
         lda     feature3_f
         bit     #Fuel_SparkHardb               ; Spark cut mode?
         beq     FuelCut_C
         lda     SparkCutCnt			; We are in spark cut only
						; mode so how many sparks
						; are we at?
         cmp     SparkCutNum_f			; User defined spark number
         bhi     Fuelcut_C			; If spark count higher than
						; number dont set spark cut bit
         bset    sparkCut,RevLimBits		; Set sparkcut bit

  ; HARD REV LIMITER FUEL CUT
Fuelcut_C:
         lda     feature3_f
         bit     #FuelSparkCutb                 ; Are we cutting fuel?
         bne     cutChannels
         bra     checkRevsOk

;If we get here we are in Launch control
;so check whether spark and or fuel cuts
Chk_Cuts:
         lda     feature5_f
         bit     #Fuel_SparkHLCb
         beq     SparkFuel_LC                   ;   Spark cut?

         lda     SparkCutCnt			; We are in spark cut
						; mode so how many sparks
						; are we at?
         cmp     SparkCutNLC_f			; User defined spark number
						; for Launch
         bhi     SparkFuel_LC			; If spark count higher than
						; number dont set spark cut bit
         bset    sparkCut,RevLimBits		; Set sparkcut bit

SparkFuel_LC:
         lda     feature5_f                     ; Launch fuel cut?
         bit     #FuelSparkLCb
         bne     cutChannels
         bra     checkRevsOk

cutChannels:
        clr     tmp1
        clr     tmp2
        bclr    OverRun,EnhancedBits		; Reset Over Run Fuel Cut
        mov     tmp1,pwcalc1
        mov     tmp2,pwcalc2
        jmp     spark_lookup					; In fuel cut mode so return
						; with zeros
checkRevsOk:
        brclr   Traction,EnhancedBits2,No_Traction_On
        lda     TCSparkCut
        beq     No_Traction_On			; If zero then no spark cut
        cmp     SparkCutCnt			; In traction mode do we
						; cut sparks
        bls     No_Traction_On
        bset    sparkCut,RevLimBits		; Set sparkcut bit

No_Traction_On:
        brset   OverRun,EnhancedBits,cutChannels; If Over run fuel cut on
						; cut fuel

; Add in the NOS and Staged PW's here
         lda     feature5_f
         bit     #stagedeither
         bne     Add_to_PWCALC
;        brset     staged,feature5,Add_to_PWCALC ; If in Staged mode Add
						; to PW1+2
;        brset     stagedMode,feature5,Add_to_PWCALC; If in Staged mode
						; Add to PW1+2
        brset     Nitrous,feature1,Add_to_PWCALC; If NOS System selected
						; add to PW1+2

        brset     crank,engine,No_TCAccel

        lda       tmp1
        add       TCAccel
        sta       tmp1
        lda       tmp2
        add       TCAccel			; Add in the traction
						; control enrichments
        sta       tmp2
No_TCAccel:
        mov       tmp1,pwcalc1
        mov       tmp2,pwcalc2
        jmp       spark_lookup
Add_to_PWCALC:
        lda       DTmode_f			; check if DT in use
        bit       #alt_i2t2
        beq       Do_Nos_PW1			; i2t2=1

        lda       feature4_f
        bit       #DtNosb
        bne       Dont_Nos_PW1
;        brset     DtNos,feature4,Dont_Nos_PW1
Do_Nos_PW1:
        lda       tmp1
        add       NosPW				; Add Nos PW to pw1
        sta       tmp1
Dont_Nos_PW1:
        brclr     REStaging,EnhancedBits,No_Staging; Staging not running
						; so dont add PW Staging
        lda       pw_staged
        sta       tmp1
No_Staging:					; Staging not running
        lda       feature5_f
        bit       #stagedeither
        bne       Staging_2_PW          ; If in Staged mode Go to NOS PW2
        bra       Staging_Done_PW
Staging_2_PW:
        brclr     REStaging,EnhancedBits,No_PW2_Staging	; Staging Mode not
							; running so no PW2
        lda       pw_staged2
        sta       tmp2
        bra       Staging_Done_PW
No_PW2_Staging:
        clr      tmp2  				; In Staging Mode but not
						; running so PW2 = 0
Staging_Done_PW:
        lda       DTmode_f			; check if DT in use
        bit       #alt_i2t2
        beq       Nos_PWCal2			; i2t2=1
        lda       feature4_f
        bit       #DtNosb
        beq       Calc_PWs_DONE  ; In DT mode so do we add
				 ; NosPW to PW2?
Nos_PWCal2:
        lda       tmp2
        add       NosPW				; Add Nos PW to pwcalc2
        sta       tmp2
Calc_PWs_DONE:
        brset     crank,engine,No_TCAccel2
        lda       tmp1
        add       TCAccel
        sta       tmp1
        lda       tmp2
        add       TCAccel			; Add in the traction
						; control enrichments
        sta       tmp2
No_TCAccel2:
        mov       tmp1,pwcalc1
        mov       tmp2,pwcalc2
        bra       spark_lookup

***************************************************************************
**
** Check if fixed spark angle - only works if we are tuning this page
**
***************************************************************************
spark_lookup:
                lda     personality_f   ; Are we using a spark mode?
                beq     No_Personality

                lda     page
                cmp     #3
                bne     fixed_fl
                lda     FixedAngle_r
                bra     fxr_c
No_Personality:
                jmp     CheckSoftLimit  ; No spark Stuff set, so only fuel

fixed_fl:       lda     FixedAngle_f
fxr_c:
                cmp     #$03
                blo     NOT_FIXED	; Added this as earlier MT didnt
					; send a perfect 00T for -10 (use map)
               ;; sta     SparkAngle	; else use this fixed advance
                jmp     CALC_DELAY
NOT_FIXED:
                brclr   LaunchOn,RevLimBits,Not_LC_in
                brset   lc_fs,SparkBits,nf_flat
                lda     LC_LimAngle_f	; Launch Retard spark Angle
              ;;  sta     SparkAngle
                jmp     CALC_DELAY
nf_flat:
                lda     LC_f_limangle_f
              ;;  sta     SparkAngle
                jmp     CALC_DELAY
Not_LC_in:
		lda	IdleAdvance_f
		cmp	#$03
		blo	use_spark_table
                ; check if set too high. Users loading old MSQ will have $FF in this byte
                cmp     #$F0
		bhi	use_spark_table
		; if there's an idle advance set, see if we want to use it
		lda	coolant
		cmp	IdleCLTThresh_f
		blo	idleadv_cond_false
		; check the tps to see if it's ok to use idle advance
		lda	tps
		cmp	IdleTPSThresh_f
		bhi	idleadv_cond_false
		; ok, tps is where it needs to be, what about rpm?
		lda	rpm
		cmp	IdleRPMThresh_f
		bhi	idleadv_cond_false
		; set a bit to say all conditions are met so the timer will start
		bset	IdleAdvTimeOK,EnhancedBits6
		; check to see if the time is up
		lda	idlAdvHld
		cmp	IdleDelayTime_f
		blo	use_spark_table
		; ok, rpm is also where it should be, so use IdleAdvance_f
		; if we are here, we don't want the timer going up, so stop it
		bclr	IdleAdvTimeOK,EnhancedBits6
		lda	IdleAdvance_f
		jmp	CALC_DELAY
idleadv_cond_false:
		bclr    IdleAdvTimeOK,EnhancedBits6
		clra
		sta	idlAdvHld
use_spark_table:
                brclr   RevLimSoft,RevLimBits,STTABLELOOKUP
                lda     SRevLimAngle	; Retard spark
                jmp     CALC_DELAY
***************************************************************************
**
**  ST 3-D Table Lookup
**
**   This is used to determine value of SparkAngle ST based on RPM and MAP
**   The table looks like:
**
**      105 +....+....+....+....+....+....+....+
**          ....................................
**      100 +....+....+....+....+....+....+....+
**                     ...
**   KPA                 ...
**                         ...
**       35 +....+....+....+....+....+....+....+
**          5    15   25   35   45   55   65   75 RPM/100
**
**
**  Steps:
**   1) Find the bracketing KPA positions via tableLookup,
**       put index in tmp8 and bounding values in tmp9(kpa1) and tmp10(kpa2)
**   2) Find the bracketing RPM positions via tableLookup, store
**       index in tmp11 and bounding values in tmp13(rpm1) and tmp14(rpm2)
**   3) Using the ST table, find the table ST values for tmp15=ST(kpa1,rpm1),
**       tmp16=ST(kpa1,rpm2), tmp17 = ST(kpa2,rpm1), and tmp18 = ST(kpa2,rpm2)
**   4) Find the interpolated ST value at the lower KPA range :
**       x1=rpm1, x2=rpm2, y1=ST(kpa1,rpm1), y2=ST(kpa1,rpm2) - put in tmp19
**   5) Find the interpolated ST value at the upper KPA range :
**       x1=rpm1, x2=rpm2, y1=ST(kpa2,rpm1), y2=ST(kpa2,rpm2) - put in tmp11
**   6) Find the final ST value using the two interpolated ST values:
**       x1=kpa1, x2=kpa2, y1=ST_FROM_STEP_4, y2=ST_FROM_STEP_5
**
***************************************************************************
STTABLELOOKUP:
; First, determine if in Speed-density or Alpha-N mode. If in Alpha-N
; mode, then replace the variable "kpa" with the contents of "tps".
; This will not break anything, since this check is performed again when
; multiplying MAP against the enrichments, and the SCI version of the
; variable is MAP, not kpa

        lda     feature9_f
        bit     #MassAirFlwb
        beq     SD_ALPHa_N              ; Are we using a MAF on pin X7?

        lda     o2_fpadc                ; Using MAF thats on pin X7
        sta     kpa_n
        bra     ST_STEP_1

SD_ALPHa_N:
        lda     config13_f1		; Check if in speed-density or
					; Aplha-N mode
        bit     #$04			; Use BIT instead of brset because
					; outside of zero-page
	beq     Kpa_n_Kpa		; Branch if the bit is clear

        lda     tps                     ; Alpha_N Mode
        sta     kpa_n			; Added so as KPa can be used
					; elsewhere in code
        bra     ST_STEP_1

Kpa_n_Kpa:                              ; Speed Den Mode
        lda     kpa
        sta     kpa_n			; Added so as KPa can be used

ST_STEP_1:					; else where in code
        ldhx    #KPARANGEST_f1
        sthx    tmp1
        lda     #$0b			;(12-1)
        sta     tmp3
        lda     kpa_n
        sta     tmp4
        jsr     tableLookup
        mov     tmp5,tmp8		;Index
        mov     tmp1,tmp9		;X1
        mov     tmp2,tmp10		;X2
ST_STEP_2:
        ldhx    #RPMRANGEST_f1
        sthx    tmp1
        lda     #$0b			;(12-1)
        sta     tmp3
        lda     rpm
        sta     tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		;Index
        mov     tmp1,tmp13		;X1
        mov     tmp2,tmp14		;X2
ST_STEP_3:
;TABLEWALK:
        clrh
        ldx     #$0c			;(12)
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        VE3X
        sta     tmp15
        incx
        VE3X
        sta     tmp16
        ldx     #$0c			;(12)
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        VE3X
        sta     tmp17
        incx
        VE3X
        sta     tmp18
        jmp     ST_STEP_4

ST_STEP_4:
        mov     tmp13,tmp1
        mov     tmp14,tmp2
        mov     tmp15,tmp3
        mov     tmp16,tmp4
        mov     rpm,tmp5
        jsr     lininterp
        mov     tmp6,tmp19

ST_STEP_5:
        mov     tmp13,tmp1
        mov     tmp14,tmp2
        mov     tmp17,tmp3
        mov     tmp18,tmp4
        mov     rpm,tmp5
        jsr     lininterp
        mov     tmp6,tmp11

ST_STEP_6:
        mov     tmp9,tmp1
        mov     tmp10,tmp2
        mov     tmp19,tmp3
        mov     tmp11,tmp4
        mov     kpa_n,tmp5
        jsr     lininterp
        lda     tmp6
        sta     tmp31			; Store the result away

; Spark Table 2 Lookup
ST2_STEP_1:
        lda     feature5_f  ; Are we using SparkTable2?
        bit     #SparkTable2b
        beq     LookUp_Done
					;
        brclr   Nitrous,feature1,No_NOS_STable2	; Are we using NOS?
        brclr   NosSysOn,EnhancedBits,LookUp_Done	; NOS Mode not ready.
No_NOS_STable2:
        lda     ST2Timer		; Spark table 2 delay timer
        bne     LookUp_Done		; If its not zero no ST2
        ldhx    #KPARANGEST_f2
        sthx    tmp1
        lda     #$0b			;(12-1)
        sta     tmp3
        lda     kpa_n
        sta     tmp4
        jsr     tableLookup
        mov     tmp5,tmp8		;Index
        mov     tmp1,tmp9		;X1
        mov     tmp2,tmp10		;X2
        jmp     ST2_STEP_2

LookUp_Done:
        jmp     LookUp_Finished

ST2_STEP_2:
        ldhx    #RPMRANGEST_f2
        sthx    tmp1
        lda     #$0b			;(12-1)
        sta     tmp3
        lda     rpm
        sta     tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		;Index
        mov     tmp1,tmp13		;X1
        mov     tmp2,tmp14		;X2
ST2_STEP_3:
;TABLEWALK:
        clrh
        ldx     #$0c 			;(12)
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        VE4X
        sta     tmp15
        incx
        VE4X
        sta     tmp16
        ldx     #$0c			;(12)
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        VE4X
        sta     tmp17
        incx
        VE4X
        sta     tmp18
        jmp     ST2_STEP_4

ST2_STEP_4:
        mov     tmp13,tmp1
        mov     tmp14,tmp2
        mov     tmp15,tmp3
        mov     tmp16,tmp4
        mov     rpm,tmp5
        jsr     lininterp
        mov     tmp6,tmp19

ST2_STEP_5:
        mov     tmp13,tmp1
        mov     tmp14,tmp2
        mov     tmp17,tmp3
        mov     tmp18,tmp4
        mov     rpm,tmp5
        jsr     lininterp
        mov     tmp6,tmp11

ST2_STEP_6:
        mov     tmp9,tmp1
        mov     tmp10,tmp2
        mov     tmp19,tmp3
        mov     tmp11,tmp4
        mov     kpa_n,tmp5
        jsr     lininterp		; Spark Table 2 result in tmp6
        brclr   NosIn,portd,Not_ST1	; If input low then use ST2

LookUp_Finished:
        lda     tmp31			; Reload the look up angle for ST1
        sta     tmp6
Not_ST1:
        lda     page
        cmp     #3
        bne     trim_fl
        lda     TrimAngle_r
        bra     trim_c
trim_fl: lda     TrimAngle_f
trim_c: bpl     CHECK_SP_ADD		; check adding of trim
        add     tmp6			; add lookup angle
        bcs     TRIM_DONE		; if carry, all is done = high advance
        bpl     TRIM_DONE		; if result is positive
        lda     #$00			; Negative trim over to high advance,
					; clamp to 0
        bra     TRIM_DONE

CHECK_SP_ADD:
        add     tmp6			; add lookup angle
        bcc     TRIM_DONE		; Check if add over into low advance
        bmi     TRIM_DONE		; Check if result negative
        lda     #$FF			; Clamp to maximum

TRIM_DONE:
        brclr   crank,engine,TRIM_DONE2
        brset   nextcyl,EnhancedBits4,td_nc
        lda     CrankAngle_f		; Update spark angle for User Interface
        bra     TRIM_DONE2
td_nc:
        lda     TriggAngle_f            ; if next cyl cranking then use trigger angle
        add     #28T                    ; add on 10 deg offset

TRIM_DONE2:
;       bmi     store_spark		; Check if result negative
					; (i.e. > 10ATDC)
;       lda     #0			; Clamp to minimum (surely safer?)
store_spark:
        brset   crank,engine,store_spark2	; if we are cranking skip
					;to the save

        add     CltIatAngle
        add     KnockAngleRet
        add     NitrousAngle
        clc				; Clear carry bit **
        add     TCAngle
        bcc     Store_Spark_Ang		; Did we over flow with the
					; traction angle? **
        lda     #28T			; Yes so limit angle to 0 deg **
Store_Spark_Ang:
        brclr   LaunchOn,RevLimBits,store_spark2
        brset   lc_fs,SparkBits,nf_flat2
        lda     LC_LimAngle_f		; Launch Retard spark Angle
        bra     store_spark2
nf_flat2:
        lda     LC_f_limangle_f

store_spark2:
CALC_DELAY:
        tax    ; take a copy in x, but don't save to SparkAngle yet

        brset   EDIS,personality,edis_calc

        brclr   nextcyl,EnhancedBits4,this_cyl
        sub     #28T                    ; subtract 10 deg offset
        bcs     next_cyl_rail           ; just in case map has -ves in it.
        cmp     TriggAngle_f
        bhi     next_cyl_calc		; if spark angle > trigger we're ok
next_cyl_rail:
        lda     TriggAngle_f
        add     #31T			; add on 10deg offset + 1 degree safety margin
        tax                             ; save copy in x
        sub     #28T                    ; remove that 10deg offset again
*****************************************************************************
**  next Cyl mode works like this...
**  DelayAngle = SparkAngle-Trigger
*****************************************************************************
next_cyl_calc:
        stx     SparkAngle
        sub     TriggAngle_f
;can't go negative because we checked just above
        sta     DelayAngle
        bra     CheckSoftLimit

this_cyl:
        stx     SparkAngle
        lda     TriggAngle_f
        sub     SparkAngle
        add     #28T
        sta     DelayAngle
        bra     CheckSoftLimit

edis_calc:
*****************************************************************************
** Delay angle not used, but code left as-is for simplicity
** now convert to SAW width.  SAW = 1536 - (25.6 * adv)
** SparkAngle = adv / 45 * 128   by definition in MSS
** adv = SparkAngle * 45 / 128   re-arrange for adv
**              (256 * 45 * SparkAngle)
** SAW = 1536 - (---------------------)
**              (128 * 10             )
**
** SAW (us) = 1536 - (SparkAngle * 9)
** BUT we will use baseline timing of 10ATDC so formula becomes
** SAW (us) = 1792 - (SparkAngle * 9)
**
** JSM - physical tests show some skewing, pulse is 2-3% longer and at
** least 15us too long
** make it 1777 ($6f1)
*****************************************************************************

        stx     SparkAngle
        txa
        ldx      #9
        mul				; stores result in x:a
        stx      tmp1			; save them
        sta      tmp2
        clc
        lda     #$f1			; do 1792-... (1792 = $700) (1777 = $6f1)
        sbc     tmp2
        sta      tmp2
        lda     #$6
        sbc     tmp1
        sta     tmp1
; if rpm < 1100 & multi-mode enabled
;        brclr   multispark,feature4,NOT_MULTI
        lda     feature4_f		; this allow multi spark on/off
					; while running
        bit     #multisparkb
        beq     NOT_MULTI
        lda     rpm
        cmp     edisms_f
        bhs     NOT_MULTI
; add on 2048us (@8MHz)
; the initial 2048us command may correct the 2% error as the EDIS
; module uses it to
; calibrate its own timer
        lda     tmp1
        add     #$08
        sta     tmp1
NOT_MULTI:
        ldhx    tmp1
        sthx    sawh			; save 16-bits in one instruction
					; to avoid interruption

***************************************************************************
**
** Check rev limiters
**
***************************************************************************
CheckSoftLimit:
                bclr    LaunchOn,RevLimBits	; Clear the Soft Launch
						; Rev Limit bit
                brclr   LaunchControl,feature2,Magnus_revlimiters; Is Launch
						; selected?
                brset   Launch,portd,Magnus_revlimiters	; Button not pressed
						; so reset variable bit
                lda     tps			; Is throttle in right place?
                cmp	LC_Throttle_f
                blo     Magnus_revlimiters	; No then no LC
                brset   lc_fs,SparkBits,csl_flat
                lda     LC_Soft_Rpm_f		; Load in Launch soft limiter
                bra     csl_comp
csl_flat:
                lda     LC_f_slim_f
csl_comp:
                beq     Magnus_revlimiters	; If Zero no soft limit
                cmp     rpm			; Is rpm higher than limit?
                bhi     Magnus_revlimiters	; No so no soft limit
                lda     tps			; Is tps higher than setting?
                cmp     LC_Throttle_f
                blo     Magnus_revlimiters	; No so no soft limit
                bset    LaunchOn,RevLimBits	; Set soft Launch bit on
                bra     SRevLimOnDone		; Jump past rpm limit checks

Magnus_revlimiters:
                lda     SRevLimRPM
                beq     SRevLimOnDone		; skip if zero
                cmp     rpm
                blo     SRevLimOn		; rpm higher than limit
                bhi     SRevLimOff		; rpm lower than limit
                brset   RevLimSoft,RevLimBits,SRevLimOn ; at limit check
						; current status
SRevLimOff:
                bclr    RevLimSoft,RevLimBits	; Clear soft limit bit
                bclr    RevLimHSoft,RevLimBits	; Clear soft limit fuel cut bit
                bra     SRevLimDone

SRevLimOn:
                bset    RevLimSoft,RevLimBits	; Set soft limit bit
;                lda     SRevLimCTime		; Set Cool down period
;                sta     SRevLimCoolLeft
                lda     SRevLimTimeLeft		; Check if time left =
						; counting down
                bne     SRevLimOnDone
                brset   RevLimHSoft,RevLimBits,SRevLimOnDone	; Check if
						; soft limit has cut fuel
                lda     SRevLimHTime		; Set delay time for soft
						; limit to cut fuel
                sta     SRevLimTimeLeft
SRevLimOnDone:
SRevLimDone:

***************************************************************************
**
** Check outputs
**
***************************************************************************
CheckOutputs:
                clrh
                brset   BoostControl,feature2,Out1DoneJMP; If Boost control
					; used then no output1
                lda     Out1Source
                cmp     #31T
                beq     TractOut1
                cmp     #05T		; Are we using temperature?
                beq     IAT1Source
                cmp     #06T
                beq     CLT1Source
                bra     Not_Temps1
IAT1Source:
                lda     AirTemp
                sta     tmp31
                cmp     Out1Lim		; Check limit
                bhi     Out1On		; Above limit, set output
                beq     Out1Done	; Equal to limit skip out
                bra     Hyster1
CLT1Source:
                lda     coolant
                sta     tmp31
                cmp     Out1Lim		; Check limit
                bhi     Out1On		; Above limit, set output
                beq     Out1Done	; Equal to limit skip out
                bra     Hyster1

ADCX6_In1:				; ADC Input on X6
                lda     o2_fpadc
                sta     tmp31
                cmp     Out1Lim
                bhi     Out1On
                beq     Out1Done
                bra     Hyster1

ADCX7_In1:				; ADC Input on X7
                lda     egtadc
                sta     tmp31
                cmp     Out1Lim
                bhi     Out1On
                beq     Out1Done
                bra     Hyster1

Out1DoneJMP:
                bra     Out1Done
Not_Temps1:
                ldx     Out1Source	; Get source
                beq     Out1Done	; No source = no check
                lda     secl,x		; Get data
                sta     tmp31
                cmp     Out1Lim		; Check limit
                bhi     Out1On		; Above limit, set output
                beq     Out1Done	; Equal to limit skip out
; Hysterisis check
Hyster1:
                brclr   Output1On,Enhancedbits2,Out1Off	; Is output 1 off?
					; If so carry on as normal
                lda     Out1Lim
                sub     Out1Hys_f	; Subtract Hysterisis for output1
					; from Out1 limit
                cmp     tmp31		; Actual value
                bls     Out1Done	; If actual value higher than
					; Limit-Hysterisis then dont clear
					; output

Out1Off:
                bclr    Output1On,Enhancedbits2	; Turn the output bit check off
                lda     feature4_f
                bit     #InvertOutOneb
                bne     out1_set
                bra     out1_clr	; Below limit, clear output

;Added for traction bit set output
TractOut1:
                brset   Traction,EnhancedBits2,No_Upper_Lim1	; If traction
					; Running set output
                bra     Out1Off


Out1On:
                lda     Out1UpLim_f	; Upper limit. Creates a window
					; for output to work in
                beq     No_Upper_Lim1	; If zero no limit
                cmp     secl,x
                bhi     No_Upper_Lim1	; If higher than setpoint dont
					; clear output
                lda     feature4_f
                bit     #InvertOutOneb
                bne     out1_set
out1_clr:
                bclr    Output1,porta
                bra     Out1Done

No_Upper_Lim1:
                bset    Output1On,Enhancedbits2	; Output on so set bit
                lda     feature4_f
                bit     #InvertOutOneb
                bne     out1_clr
out1_set:
                bset    Output1,porta	; Below limit, set output (Inverted)

Out1Done:

                lda     Out2Source

                cmp     #31T
                beq     TractOut2

                cmp     #05T		; Are we using temperature?
                beq     IAT2Source
                cmp     #06T
                beq     CLT2Source
                bra     Not_Temps2
IAT2Source:
                lda     AirTemp
                sta     tmp31
                cmp     Out2Lim		; Check limit
                bhi     Out2On		; Above limit, set output
                beq     Out2Done	; Equal to limit skip out
                bra     Hyster2
CLT2Source:
                lda     coolant
                sta     tmp31
                cmp     Out2Lim		; Check limit
                bhi     Out2On		; Above limit, set output
                beq     Out2Done	; Equal to limit skip out
                bra     Hyster2

ADCX6_In2:				; ADC Input on X6
                lda     o2_fpadc
                sta     tmp31
                cmp     Out2Lim
                bhi     Out2On
                beq     Out2Done
                bra     Hyster2

ADCX7_In2:
                lda     egtadc
                sta     tmp31
                cmp     Out2Lim
                bhi     Out2On
                beq     Out2Done
                bra     Hyster2

Not_Temps2:
                ldx     Out2Source	; Get source
                beq     Out2Done	; No source = no check
                lda     secl,x		; Get data
                sta     tmp31
                cmp     Out2Lim		; Check limit
                bhi     Out2On		; Above limit, set output
                beq     Out2Done	; Equal to limit skip out
; Hysterisis check
Hyster2:
                brclr   Output2On,Enhancedbits2,Out2Off	; Is output 1 off?
					; If so carry on as normal
                lda     Out2Lim
                sub     Out2Hys_f	; Subtract Hysterisis for output1
					; from Out1 limit
                cmp     tmp31		; Actual value
                bls     Out2Done	; If actual value higher than
					; Limit-Hysterisis then dont
					; clear output

Out2Off:
                bclr    Output2On,Enhancedbits2	; Turn the output bit check off
                lda     feature4_f
                bit     #InvertOutTwob
                bne     Inv_Out2	; Are we inverting output2?
                bclr    Output2,porta	; Below limit, clear output
                bra     Out2Done
Inv_Out2:
                bset    Output2,porta	; Inverting output
                bra     Out2Done

TractOut2:
                brset   Traction,EnhancedBits2,No_Upper_Lim2	; If traction
					; Running set output
                bra     Out2Off

Out2On:
                lda     Out2UpLim_f	; Upper limit. Creates a window
					; for output to work in
                beq     No_Upper_Lim2	; If zero no limit
                cmp     secl,x
                bhi     No_Upper_Lim2	; If higher than setpoint dont
					; clear output
                lda     feature4_f
                bit     #InvertOutTwob
                bne     out2_set
out2_clr:
                bclr    Output2,porta	; Inverting output
                bra     Out2Done

No_Upper_Lim2:
                bset    Output2On,Enhancedbits2	; Output on so set bit
                lda     feature4_f
                bit     #InvertOutTwob
                bne     out2_clr
out2_set:
                bset    Output2,porta	; Below limit, set output (Inverted)
Out2Done:

*******************************************************************************
** OUTPUT 3 Port D 0 (pin 15 top of R14) with delay off timer
*******************************************************************************

                brset   out3sparkd,feature2,out3done
                clrh
                lda     feature8_f
                bit     #Out1_Out3b	; Are we in Out1+ mode?
                beq     Norm_Out3_check
                brclr   Output1,porta,Out3Off	; If Output1 is off then
					; don't do any checks for Out3

Norm_Out3_check:
                lda     Out3Source_f
                bit     #$0f		; Only use 5 bits of this byte
                beq     Out3Done	; No source = no check
           ;     cmp     #01T
           ;     beq     Tract_Output3	; If source = 1 then traction to
					; activate output
                cmp     #31T
                beq     Tract_Output3	; If source = 31 then traction to
					; activate output
                cmp     #02
                beq     DEC_Output3	; If source = 2 then we are using
					; decel to activate output
                cmp     #03T
                beq     ACEL_Output3	; If source = 3 then we are using
					; accel to activate output
                cmp     #05T		; Are we using temperature?
                beq     IAT3Source
                cmp     #06T
                beq     CLT3Source
                cmp     #10T		; Are we looking at Out2?
                beq     Out2_Out3
                cmp     #32T
                beq     Out2_Out3
                ldx     Out3Source_f	; Get source
                lda     secl,x		; Get data
                cmp     Out3Lim_f	; Check limit
                bhi     Out3On		; Above limit, set output
                beq     Out3Done	; Equal to limit skip out
Out3Off:
                lda     TimerOut3_f	; What time delay is set?
                beq     No_Out3_Timer
                cmp     Out3Timer
                bhi     Out3Done

No_Out3_Timer:
                bclr    Output3,portd	; Below limit, clear output
                bra     Out3Done

IAT3Source:
                lda     AirTemp
                cmp     Out3Lim_f	; Check limit
                bhi     Out3On		; Above limit, set output
                beq     Out3Done	; Equal to limit skip out
                bra     Out3Off
CLT3Source:
                lda     coolant
                cmp     Out3Lim_f	; Check limit
                bhi     Out3On		; Above limit, set output
                beq     Out3Done	; Equal to limit skip out
                bra     Out3Off

Out2_Out3:
                brclr   Output2,porta,Out3Off	; If Output2 on then turn
					; output3 on
                bra     Out3On

Tract_Output3:
                brclr   Traction,EnhancedBits2,Out3Off	; If traction Running
					; set output
                bra     Out3On

DEC_Output3:
                brclr   TPSDEN,ENGINE,Out3Off	; If Decel output off
                bra     Out3On

ACEL_Output3:
                brclr   TPSAEN,ENGINE,Out3Off	; If Accel output off

Out3On:
                clr     Out3Timer
                bset    Output3,portd	; Set output

Out3Done:


*****************************************************************************
**   OUTPUT 4
*******************************************************************************
; OUTPUT 4 LED 18 can be used as a standard output or as a fan control
; for those using WATER INJECTION on X2

                brset   REUSE_LED18,outputpins,Out4Done	; being used as IRQ
					; or COIL C
                brclr   REUSE_LED18_2,outputpins,Out4Done	; Are we re
					; using LED18 as output4?
                brset   LED18_FAN,outputpins,Out4Done	; Are we using it
					;as fan control?
                clrh
                lda     Out4Source_f
                bit     #$0f		; Only use 5 bits of this byte
                beq     Out4Done	; No source = no check
           ;     cmp     #01T
           ;     beq     Tract_Output4	; If source = 1 then traction to
					; activate output
                cmp     #31T
                beq     Tract_Output4	; If source = 31 then traction to
					; activate output
                cmp     #02T
                beq     DEC_Output4	; If source = 2 then we are using
					; decel to activate output
                cmp     #03T
                beq     ACEL_Output4	; If source = 3 then we are using
					; accel to activate output
                cmp     #05T		; Are we using temperature?
                beq     IAT4Source
                cmp     #06T
                beq     CLT4Source
                ldx     Out4Source_f	; Get source
                lda     secl,x		; Get data
                cmp     Out4Lim_f	; Check limit
                bhi     Out4On		; Above limit, set output
                beq     Out4Done	; Equal to limit skip out
Out4Off:
                bclr    wled,portc	; Below limit, clear output
                bra     Out4Done

IAT4Source:
                lda     AirTemp
                cmp     Out4Lim_f	; Check limit
                bhi     Out4On		; Above limit, set output
                beq     Out4Done	; Equal to limit skip out
                bra     Out4Off
CLT4Source:
                lda     coolant
                cmp     Out4Lim_f	; Check limit
                bhi     Out4On		; Above limit, set output
                beq     Out4Done	; Equal to limit skip out
                bra     Out4Off

Tract_Output4:
                brclr   Traction,EnhancedBits2,Out4Off	; If traction Running
					; set output
                bra     Out4On

DEC_Output4:
                brclr   TPSDEN,ENGINE,Out4Off	; If Decel output off
                bra     Out4On

ACEL_Output4:
                brclr   TPSAEN,ENGINE,Out4Off	; If Accel output off

Out4On:
                bset    wled,portc	; Set output

Out4Done:

***************************************************************************
**
** Fan Control - added separate off-temp - from RPE
** Can use X2 and or LED18
**
***************************************************************************
        brset   X2_FAN,outputpins,DO_FAN_Check	; Are we using X2 as fan
						; control?
        brset   REUSE_LED18,outputpins,fan_exit
        brclr   REUSE_LED18_2,outputpins,fan_exit
        brset   LED18_FAN,outputpins,DO_FAN_Check	; Are we using LED18
					; as fan control?
fan_exit:
        bra     FAN_DONE		; Nope, so return

DO_FAN_Check:
        brset   crank,engine,FAN_OFF
        lda     coolant
        cmp     EfanOnTemp_f
        bhi     FAN_ON
        cmp     EfanOffTemp_f
        blo     FAN_OFF
        bra     FAN_DONE

FAN_OFF:
        brclr   X2_FAN,outputpins,No_FAN_Porta	; Are we using X2?
        bclr    water,porta		; sharing X2 with water inj output
No_FAN_Porta:
        brclr   LED18_FAN,outputpins,FAN_DONE	; Are we using LED18?
        bclr    wled,portc
        bra     FAN_DONE
FAN_ON:
        brclr   X2_FAN,outputpins,No_FANOn_Porta	; Are we using X2?
        bset    water,porta		; sharing X2 with water inj output
No_FANOn_Porta:
        brclr   LED18_FAN,outputpins,FAN_DONE	; Are we using LED18?
        bset    wled,portc

FAN_DONE:


*******************************************************************************
**
**   Over run fuel cut system                    (P Ringwood)
**
*******************************************************************************
Over_Run:
        lda     feature4_f
        bit     #OverRunOnb
        beq     Over_Run_Done

No_Over_Run:
        lda    kpa
        cmp    ORunKpa_f		; Is the KPa lower than the set point?
        bhi    No_OverRun		; No so no over run
        lda    rpm
        cmp    ORunRpm_f		; Is the rpm higher than the setpoint?
        blo    No_OverRun		; No so no Over run
        lda    tps
        cmp    ORunTPS_f		; Is the TPS below the setpoint?
        bhi    No_OverRun		; No so no over run
        lda    coolant
        cmp    OverRunClt_f1		; Is the coolant temp high enough?
        blo    No_OverRun
        brset  over_Run_Set,EnhancedBits2,No_OverRun_Reset
        bset   over_Run_Set,EnhancedBits2
        lda    #00T
        sta    OverRunTime		; Reset the over run timer once
					; per over run

No_OverRun_Reset:
        lda    OverRunTime
        cmp    OverRunT_f
        bhs    Do_OverRun
        bra    Over_Run_T

Do_OverRun:
        bset   OverRun,EnhancedBits	; Set Over Run Fuel Cut
        bra    Over_Run_Done
No_OverRun:
        bclr  over_Run_Set,EnhancedBits2 ; Clear the over run timer clear bit
Over_Run_T:
        bclr  OverRun,EnhancedBits	; Clear the over run fuel cut

Over_Run_Done:

*****************************************************************************
**  Water Injection section
**
**  Turn 1st water output (X2) on if MAP and RPM and IAT higher than
**  Water set point
**
**  Pulse water2 output (X3) at same rate as Fuel Injector #2.
**
***************************************************************************
        lda     feature3_f
        bit     #WaterInjb
        beq     Water_Inj_Done

Water_Injection:			; we only get here if water
					; inj is enabled
            brset  water,porta,ignore_iat;If water on then dont check
					; IAT again

	      lda   iatpoint_f		; Load Inlet air temp setpoint
	      cmp   airTemp		; Is it higher than actual iat?
            bhi   definatlyno_water


ignore_iat:
          lda  wateripoint_f		; Load water injection point
	    cmp  kpa			; Is it lower than the actual kpa?
	    blo  water_on		; If so turn water pump on
          bra  definatlyno_water	; If not then no water

          lda   rpm
          cmp   wateriRpm_f		; Is the engine above the min rpm?
          blo   definatlyno_water

water_on:
          lda  rpm
          cmp  wateriRpm_f		; Are we actually above the rpm Minimum?
          blo  definatlyno_water
          bset  water,porta		;Turn water pump on
	  bra    Water_Inj_Done

definatlyno_water:

           bclr   water,porta		;Turn off water pump
Water_Inj_Done:

*****************************************************************************
**
**  Coolant Related Ignition Advance (P Ringwood)
**  Add Advance of 1 deg per user defined amount of coolant temp below setpoint
**
*****************************************************************************
***************************************************************************
** DeadBand: If we are within 5 degrees above of coolant setpoint then
** ensure we turn advance  setting to zero. This is incase temp jumps up
** for some reason and leaves advance set.
**
** I have no idea if this could happen but I put it in just incase.
*****************************************************************************
         lda    feature3_f
         bit    #CltIatIgnitionb
         beq    retard_endJmp

IatClt_Related:

      clrh
      lda   cltAdvance_f		; Load Coolant temperature setpoint
      beq   Advance_end			; If zero no Advance
      add   #05T			; Add 5 to the clt temp
      cmp   coolant			; Are we within 5 degrees F of
					; setpoint for clt advance?
      blo   Advance_end			;
      lda   coolant			;
      cmp   cltAdvance_f		; Is the clt under the setpoint?
      blo   carryOn_Advance		; If so carry on with advance
      lda   #$00
      sta   CltIatAngle			; If not then it's in dead band
					; so clear trimAngle
      jmp   retard_end   		; Don't do any Advance / Retard
					; till out of deadband

* End of dead band
**********************************************************************

carryOn_Advance:

      lda   cltDeg_f			; load the temp per 1 deg of Advance.
      beq   Advance_end			; If zero no Advance
      lsra				; Shift bit pattern to the right
					; (Divide by 2)
      bcc   nota_carry			; Check if carry bit clear, skip
					; increment
      inca				; otherwise, increment accumulator
nota_carry:
      sta   tmp31			; Stores half the cltDeg (used for
					; checking division)
      lda   cltAdvance_f		; Load into the accumulator the top
					; temperature limit
      sub   coolant			; How much cooler are we?
      clrh				; Zero out high 8 bits of 16-bit
					; H:X register
					; Accumulator contains low 8 bits
      ldx   cltDeg_f			; Set divisor
      div				; (H:A) /X -> A, with rem in H

      tax				; Move quotient to index register
      pshh				; Transfer remainder to accumulator
      pula
      cmp   tmp31			; See if the remainder is more than
					; half of divisor
      blo   roundedAdvance
      incx				; It was a big remainder, round up.

roundedAdvance:
      lda   #3T				; 1 degree
      mul				; X * A -> (X:A)
      cpx   #0T				; See if we overflowed, i.e., X != 0
      beq   maxAdvanceTrim		; No, so see if we are at max angle
      lda   #255T			; Overflow value

maxAdvanceTrim:
      cmp   maxAdvAng_f			; Is it above the max allowed advance?
      blo   store_Advance		; No, store the advance
      lda   maxAdvAng_f			; Yes, load the max Advance allowed

store_Advance:
      sta   CltIatAngle			; Store the advance

retard_endJmp:

      jmp retard_end			; If Coolant advance running dont
					; check IAT retard

Advance_end:

*****************************************************************************
**
**  Add Retard of 1 deg per user defined amount of IAT when IAT and
**  boost above setpoints
**
*****************************************************************************

      lda   iatDeg_f			; load the temp per 1 deg of retard.
      beq   noRetard			; If zero then no Retard
      lsra				; Shift bit pattern to the right
					; (Divide by 2)
      bcc   no_carry			; Check if carry bit clear, skip
					; increment
      inca				; otherwise, increment accumulator

no_carry:
      sta   tmp32			; Stores half the iatDeg

      lda   kpa
      cmp   kpaRetard_f			; Setpoint of KPa for retard
      blo   clr_Retard			; If not reached make sure we
					; clear the retard angle

      lda   airTemp			; Actual IAT Temp
      cmp   iatDanger_f			; Setpoint for start of retard
      blo   clr_Retard			; If not reached make sure we
					; clear the retard angle

      sub   iatDanger_f			; How much higher are we? Leaves
					; difference in accumulator
      clrh				; Zero out high 8 bits of 16-bit
					; H:X register
					; Accumulator contains low 8 bits
      ldx   iatDeg_f			; Set divisor
      div				; (H:A) /X -> A, with rem in H

      tax				; Move quotient to index register
      pshh				; Transfer remainder to accumulator
      pula
      cmp   tmp32			; See if the remainder is more than
					; half of divisor
      blo   roundedRetard
      incx				; It was a big remainder, round up.

roundedRetard:
      lda   #3T				; 1 degree
      mul				; X * A -> (X:A)

      sta   tmp31			; Store angle to retard, its an
					; advance angle at the moment
      lda   #255T			;
      sub   tmp31			; (255-angle to retard) turns it
					; into a retard angle

      cpx   #0T				; See if we overflowed, i.e., X != 0
      beq   storeRetardedTrim
      lda   #255T			; Overflow value

storeRetardedTrim:
      sta   CltIatAngle			;
      jmp   retard_end			; finished retard

clr_Retard:
      lda  #$00
      sta  CltIatAngle			; Sets trim angle back to zero when
					; no setpoints met
noRetard:
retard_end:


***************************************************************************
**
** Idle Speed Adjustment
**
**    Ubipa's idle control algorithm with KeithG front end logic and such.
**
**    idleOn = adjustment algorithm is running.  If it is not, then
**    idleLastDC will not be changed.
**
**    if cranking
**       idleDC     = icrankdc
**       idleLastDC = icrankdc
**
**    Active Dashpot
**    small amount added to last idle DC value recorded
**
**    Through the closed loop warmup, activation tracks idle speed because it
**    is 'rpms above idle' not a fixed value.
**
**    JSM added warmup PWM setting. Can choose open loop or closed loop.
**    This is designed to work like a variable version of B&G
**    Can set duty cycle at lower temp. Interpolates to zero at upper temp, where
**    rpm targets take over.
**    If rpm targets are set to zero then valve shut about upper temp.
***************************************************************************
        brset   REUSE_FIDLE,outputpins,idle_DoneJMP1

IdleAdjust:
;         brset   PWMidle,feature2,idlePWM
         lda     feature13_f
         bit     #pwmidleb
         bne     idlePWM

;-- Toggle Mode ----------------------------------------------------------------

idleToggle:
        lda     coolant
        cmp     fastIdleBG_f		; use original B&G on/off temp
        bls     idleFast		; Shouldn't there be some hysteresis
					; here?  On the other hand, the
					; temp should never hover around
					; here, so why bother?
idleSlow:
        clr     idleDC			; Fully closed.
        jmp     idle_Done

idleFast:
        mov     #255T,idleDC		; Wide open.
        jmp     idle_Done

;-- PWM Mode -------------------------------------------------------------------

idlePWM:
	brset   istartbit,EnhancedBits6,Crank_PWM	; loop to stabilize on startup
	brset   crank,engine,Crank_PWM		; open AIC for cranking
	brclr   running,engine,Idle_doneJMP1	; no PWM adjust when not running
;        brset   crank,engine,jeskipAdjust	; Don't adjust idle during cranking
        lda     feature13_f
        bit     #idle_warmupb
        beq     idle_closedloop
;	bra	idle_closedloop  ;?? this prevents open loop from working

; Warmup PWM
idle_openloop:
        lda     coolant
        cmp     slowIdleTemp_f
        blo     idle_loopcold
        lda     feature13_f                 ; If we are not using closed loop then clear DC
        bit     #idle_clb
        beq     clrNskip
        bra     idle_closedloop

clrNskip:
        lda     idle_dc_hi              ; Store hot DC in Idle DC
        sta     idleDC                  ; Added for setting idle DC as if ignition turned
        bra     idle_DoneJMP1		; on when engine hot

idle_loopcold:
        ; determine duty cycle by linear interpolation
        lda     fastIdletemp_f
        sta     liX1
        lda     slowIdleTemp_f
        sta     liX2
        lda     idle_dc_lo
        sta     liY1
        lda     idle_dc_hi
        sta     liy2		       ; rmd upper duty limit
        lda     coolant
        sta     liX
        jsr     lininterp
        mov     liY,idleDC
	bra	idle_closedloop

Idle_doneJMP1:
	jmp	Idle_done

Crank_PWM:
	brset	istartbit,EnhancedBits6,start_delay
	lda     fastIdletemp_f		; interpolate delay to 0 at
	sta     tmp1			; slow idle temp
	lda     slowIdleTemp_f
	sta     tmp2
	lda	idlestartclk_f
	sta     tmp3
	clr     tmp4
	mov     coolant,tmp5
	jsr     lininterp
;	mov     tmp6,idleDelayClock
	lda	tmp6
	sta	idleDelayClock
start_delay:
	lda	idlecrankdc_f
	sta	idleDC
	sta	idlelastdc
	bset	istartbit,EnhancedBits6	; let em know we are starting...
	lda	idledelayClock		; Make sure we settle here for a bit
	bne	idle_doneJMP1		; clear the bit after the wait time
	bclr	istartbit,EnhancedBits6 ; we are no longer starting
	bset	idleon,engine		; we want to idle down
	bset	idashbit,EnhancedBits6	; we want to bypass the rpm test for a bit
	lda	idlestartclk_f		; load start delay clock again
	cmp	idleDelayClock_f
	bhi	longer_delay
	lda	idleDelayClock_f
longer_delay:
	sta	idleDelayClock		; to allow for the decay time

Idle_doneJMP2:
	jmp	Idle_done

idle_closedloop:
;	brclr	idle_cl,feature7,Idle_doneJMP1
        lda     feature13_f
        bit     #idle_clb
        beq     idle_DoneJMP1
	lda     tps
	cmp     IdleThresh_f		; compare tps with treshold
	bhi	close_AIC		; tps based closure

IDLE_RPM:				; Ubipa's idle regulation code
	lda	#24T
	cmp	rpm			; now check rpms
	blo	revs_over		; make sure rpms below are < 2400 rpm
	clr	intacc1			; routine to determine 8 bit RPM value x10
	clr	intacc1+1
	ldhx	rpmph
	sthx	intacc2
	lda	#10T
	ldx	rpmk_f1+1		; LSB of multiplicand.
	mul
	sta	intacc1+3		; LSB of result stored.
	stx	intacc1+2		; Carry on stack.
	lda	#10T
	ldx	rpmk_f1			; MSB of multiplicand.
	mul
	add	intacc1+2		; Add in carry from LSB.
	sta	intacc1+2		; MSB of result.
	jsr	udvd32		        ; 32 / 16 divide
	lda	intacc1+3               ; get 8-bit RPM result
	sta	idlerpm			; of current RPM x10
	bra	IDLE_SPEED

revs_over:				; ensure that revs do not overflow
	lda	#240T			; set at 2400 rpm
	sta	idlerpm
	bra	IDLE_SPEED

close_AIC_rpm:
	brset	idashbit,EnhancedBits6,rpm_delay ; but not if dashpot is set
close_AIC:
	bclr	idashbit,EnhancedBits6	; turn off dashpot bit
	bclr	idleon,engine		; turn off idle bit
	lda	idleCtlClock		; step close the AIC
	cmp	Idashdelay_f		; with this many 1/10 sec between steps
	blo	Idle_doneJMP2
	clr	idleCtlClock
	lda	idleDC
	cmp	idleclosedc_f
	bls	Idle_doneJMP2
	deca
	sta	idleDC
	bra	Idle_doneJMP2

idash:					; simplified dashpot
	brset	idashbit,EnhancedBits6,idle_doneJMP2
	bset	idleon,engine
	bset    idashbit,EnhancedBits6
	lda     idledashdc_f		; take lastidleDC
	add	idlelastdc		; add dashDC
	sta	idleDC
	lda	IdleDelayClock_f	; start delay clock
	sta	idleDelayClock
	bra	idle_doneJMP

IDLE_SPEED:				; Determine idle speed target
	lda     slowIdle_f		; based on coolant temp and targets
	cmp     idleTarget
	beq     RPM_TEST
	lda     fastIdletemp_f
	sta     tmp1
	lda     slowIdleTemp_f
	sta     tmp2
	lda     fastIdle_f
	sta     tmp3
	lda     slowIdle_f
	sta     tmp4
	mov     coolant,tmp5
	jsr     lininterp
	mov     tmp6,idleTarget

RPM_TEST:
	lda	idleTarget
	add	irestorerpm_f		; tests to determine what to do based on RPM
	cmp	idlerpm			; now check rpms
	blo	close_AIC_rpm		; close it above RPM threshold
	brset	idashbit,EnhancedBits6,rpm_delay ; always go here when dashbit is set
	bra	idleDC_test

rpm_delay:
	lda	idleDelayClock		; Make sure we settle below the thresh before we
	bne	IdleDC_test		; clear the bit after the wait time
	bclr	idashbit,EnhancedBits6	; clear the dashbit after delay

idleDC_test:				; make sure that idleDC is reasonable and not closed
	brclr	idleon,engine,idash	; dashpot if idleon is not set
	lda	idlemindc_f
	cmp	idleDC
	bls	IDLE_LOOP
	lda	idlelastdc		; do not let idleDC drop below min for routine
	sta	idleDC			; we want to idle, calc rpm and target
	bra	IDLE_LOOP

Idle_doneJMP:
	bra	idle_done

IDLE_LOOP:				; delay time is proportional to deviance
	lda	ictlrpm2_f		; from target
	sta     tmp1			; upper limit of rpm deviance
	lda     ictlrpm1_f
	sta     tmp2			; lower limit of rpm deviance
	lda	idleperiod_f
	sta     tmp3              	; faster idlectl, lower #
	lda	idleperiod2_f
	sta     tmp4			; slower idlectl, higher #
	lda     idlerpm
	sub	idletarget
	sta     tmp5
	bcc     Ctl_speed
	nega
	sta     tmp5
;	rol     tmp1 ; comment per KG  	; SPEED THIS UP by halving the high rpm
Ctl_speed:
	jsr     lininterp
	lda     tmp6
	cmp     idleCtlClock
	bhi     Idle_done
	lda     idleTarget
	add     Ideadbnd_f	; add tol. e.g. 850+2=870rpm
	cmp     idlerpm		; compare with idle rpm
	blo     idle_dec	; if lower the outside range so adjust
	lda     idleTarget
	sub     Ideadbnd_f	; subtract 870-4=830rpm
	cmp     idlerpm
	bhi     idle_inc
	bra     Idle_done	; idle is ok so exit

IDLE_INC:			; idle rpm is too low increase duty cycle
	lda     idledc
	cmp	idlefreq_f	;these lines to accomodate freqs other than 100
	beq	Idle_done
	inca
	sta     idledc
	bra     IDLE_SAVE

IDLE_DEC:			; idle rpm is too high decrease duty cycle
	lda     idledc
	cmp     idlemindc_f
	beq     idle_done	; lower duty cycle limit
	deca
	sta     idledc

IDLE_SAVE:
	clr     idleCtlClock	; clear delay counter
	sta     idleLastDC	; Save the last active idle dutycycle

Idle_done:

******************************************************************************
**          K n o c k  D e t e c t i o n  S y s t e m         P Ringwood    **
**
**    This receives an input in from the JP1 header, if its low it sees
**    it as a knock.
**    Basic functionality:
**    Are we below the max rpm allowed?
**      Yes- carry on with detection,
**      No- reset all and end knock detection.
**    Knock on input, retard ignition by the 1st retard value
**    (KnockRetard1), start timer
**    wait for timer to time out (KnockTimLft)
**    Is it still knocking?
**      Yes- then add knockretard2 value to total retard.
**      No- then advance by KnockAdv amount.
**    Is the total retard less than 1 degree?
**      Yes- reset all knock settings, goto start.
**      No- so carry on with timer
**    Check for knock. If knocking add retard2 restart timer - if not
**    Wait for timer to time out before adding advance.
**    Is it still knocking?
**      Yes- then add knockretard2 value to total retard, restart timer.
**      No- then advance by KnockAdv amount, restart timer.
**    Is the total retard less than 1 degree?
**      Yes- reset all knock settings, goto start.
**      No- so carry on with timer
**    When timer timed out check for knock? If knocking add knockRetard2,
**    if not advance
**    etc, etc,
**
****************************************************************************
****************************************************************************
Knock_Detection:

        lda     feature3_f
        bit     #KnockDetb
        beq     End_KnockJmp   ; knock not enabled

        lda     feature8_f
        bit     #spkfopb
        bne     End_KnockJmp   ; Spark output F enabled, incompatible

        clrh
        lda    rpm
        cmp    KnockRpmL_f		; Is the engine rpm too high for
					; the knock sensor?
        bhi    Clr_KnockJmp		; If it is clear values, no more retard
        cmp    KnockRpmLL_f		; Is it running lower than the
					; low rpm setpoint?
        blo    Clr_KnockJmp		; If so clear all values, no
					; more retard
        lda    kpa
        cmp    KnockKpaL_f		; Is the boost above the limit
					; for knock system?
        bhi    Clr_KnockJmp		; If it is clear knock values,
					; no more retard.
        brset  Knocked,SparkBits,KnockTLeft	; If knock has been
					; previously detected do timer
        brset  Advancing,RevLimBits,KnockALeft	; If we are advancing back
        brset  KnockIn,portd,End_KnockJmp	; If no knock on input
					; then no knock
        bset   Knocked,SparkBits	; 1st Knock on input so set knocked bit
        lda    KnockRet1_f
        sta    KnockAngle		; Load in first retard amount
        lda    BoostKnock_f		; Value to remove from Boost controller
        sta    KnockBoost		; target
        jmp    Start_KnockTime		; Start the knock timer

KnockTLeft:
        bclr   Advancing,RevLimBits	; Clear advance bit as we are retarding
        lda    KnockTimLft
        cmp    #00T
        beq    NoTimeLeft		; If timer counted down then add
					; some advance
        jmp    End_KnockJmp		; End of Knock

KnockALeft:
        bclr   Knocked,SparkBits	; Clear Retard set bit as we
					; are advancing
        brclr  KnockIn,portd,Knocking_Still	; Do we have any knocking?
        lda    KnockTimLft
        cmp    #00T
        beq    NoTimeLeft		; If timer counted down then add
					; some advance
        jmp    End_KnockJmp		; End of Knock

NoTimeLeft:
         brclr KnockIn,portd,Knocking_Still	; Still knocking?
         bclr  Knocked,SparkBits	; No Knocking so clear knock bit
         bset  Advancing,SparkBits	; Set advancing bit
         lda   Boostknock_f
         beq   No_BoostKnock		; if no Boost Knock value then
					; jump past checks
         lda   KnockBoost		; Value to add to Boost controller
         sub   BoostKnock_f		; target
         sta   KnockBoost
         cmp   #03T
         blo   ClearTime		; If target boost less than
					; 0.5psi then clear all
No_BoostKnock:
         lda   KnockAngle		; No Knock detected and time
					; period over
         sub   KnockAdv_f		; so remove some retard

StoreKnock:
         cmp   #03T
         blo   ClearTime		; If retard is less than 1deg
					; clear timer, we have finished
         cmp   #85T
         bhi   ClearTime		; If we are above 30 Degrees
					; then somethings wrong so clear retard
         sta   KnockAngle
         jmp   Start_KnockTime

Clr_KnockJmp:
         jmp   Clr_Knock
End_KnockJmp:
         jmp   End_Knock

ClearTime:				; No Knocks and retard back to start
					; so clear everything.
         lda   #00T
         sta   KnockAngle		; Clear the knock angle
         sta   KnockTimLft		; Clear the time left value
         sta   KnockAngleRet		; Clears actual knock angle
         sta   KnockBoost		; Clear the boost value to remove
         bclr  Knocked,SparkBits	; Clear the Knocked bit
         bclr  Advancing,RevLimBits	; Clear advance bit
         jmp   End_Knock		; Go to end of knock system

Knocking_Still:
         bset  Knocked,SparkBits	; Set Knocking bit
         bclr  Advancing,RevLimBits	; Clear the advance bit as we are
					; in knock retard
         lda   KnockBoost
         add   BoostKnock_f		; Increase the amount of boost to remove
         cmp   BoostKnMax_f		; Are we at max?
         blo   Store_Boost_Remove	; No so store boost to remove
         lda   BoostKnMax_f		; Yes so store the max
Store_Boost_Remove:
         sta   KnockBoost
         lda   KnockRet2_f		;
         add   KnockAngle		; add the knock retard angle2 to
					; knock angle
         cmp   KnockMax_f		; Are we at the max retard?
         blo   Not_atMax		; If not at max store new angle
         lda   KnockMax_f		; If above max load the max allowed.

Not_atMax:
         sta   KnockAngle		; Store new knock angle

Start_KnockTime:
         lda   KnockTim_f		; Start/Restart the knock timer
         sta   KnockTimLft
         lda   #255T
         sub   KnockAngle		; (255-Knock Angle) turns it into a retard angle
         cmp   #$aa			; Limit the retard to 30 degrees
         bhi   StoreAngle
         lda   #$aa
         jmp   StoreAngle

Clr_Knock:
         bclr   Knocked,SparkBits	; Clear the Knocked bit
         bclr   Advancing,RevLimBits	; Clear advancing bit
         lda    #$00			; Clear the knock angle value
         sta    KnockBoost		; Clear the boost value to remove
         sta    KnockAngle

StoreAngle:
         sta    KnockAngleRet		; Actual retard value for MSnS

End_Knock:
******************************************************************************
******************************************************************************
**  Anti-Rev System                     P Ringwood
**  System based on rate of change of rpm or input signals from
**  2 x Vehicle Speed Sensors
**  Fuel enrichment, to bog down the engine and retard angle are
**  interpolated from the 4 bins of each setting. Spark Cut isn't
**  interpolated as it's not worth the effort as it's such a low
**  figure (1 or 2 cuts)
**  Now added cycle counter so it can hold settings for an interpolated amount
**  of engine cycles. Uses ASEcount, so can only work after start warm up over.
**  Using this saves making h file bigger and adding yet another counter
**  to the interupt.
**
********************************************************************************
********************************************************************************

        lda   feature6_f
        bit   #TractionCb
        beq   Traction_DoneJMP

TractionSystem:
        brclr   running,engine,No_TC_Yet; Only use it if engine running
        brset   crank,engine,No_TC_Yet  ; Dont use it during cranking as we use some
                                        ; traction bytes
        brset   startw,engine,No_TC_Yet	; only use Anti-Rev when after
					; start enrichment over
        brset   WheelSensor,feature7,No_RPM_Thresh	; If using wheel
					; sensors then no need to look at rpm
Do_RPM_TC:
        lda     rpm
        cmp     rpmlast
        bhs     RPM_Thresh		; Has the rpm increased?
NO_TC_Loss:
        brset   Traction,EnhancedBits2,reset_TC_Yet	; Have we selected
					; to wait till cycle counter timed out?
Reset_TC_Now:
        bclr    Traction,EnhancedBits2	; Clear the traction control bit
        lda     #00T
        sta     TCCycles
        sta     TCAngle
        sta     TCAccel
        sta     ASEcount
No_TC_Yet:
        jmp     Traction_Done				; No so return

No_RPM_Thresh:

;      Driven input = egtadc     Non-Driven input = o2_fpadc
; If under max speed and over min speed, multiply driven speed sensor
; input by the scale factor to find the speed the un-driven sensor should be at.
; Then find the allowable slip amount based on calculated estimate speed
; than actual then we have lost traction. I think:-)

        lda     o2_fpadc		; Non-driven speed sensor input
        cmp     UDSpeedLim_f		; Have we reached the speed limit?
        bhi     Reset_TC_Now		; Yes so reset TC
        cmp     UDSpeedLo_f		; Are we above the minimum speed?
        blo     Reset_TC_Now		; Yes so reset TC
        clrh
        ldx     egtadc			; Put Driven input into x reg
        lda     TCScaleFac_f		; Multiply by the differential factor
        mul
        txa				; Transfer high byte to accumulator
        bcc     Carry_LC		; Is the carry bit set?
        inca
Carry_LC:				; Acc contains result
        sta     tmp32
        sub     o2_fpadc		; subtract undriven wheel speed
        bmi     NO_TC_Loss		; Drive wheels slower than undriven,
					; no TC

; Interpolate to find allowable slip depending on vehicle speed
; (store allowed slip in tmp31)
        clr    liX1			; Set minimum speed to 00
        lda    #127T			; Set maximum speed for
					; interpolater to half speed
        sta    liX2
        lda    TCSlipFac_f		; Slip allowed at minimum speed
					; (00 liX1)
        sta    liY1
        lda    TCSlipFacH_f		; Slip allowed at half speed
        sta    liY2
        lda    o2_fpadc			; Actual speed were running at
        sta    liX
        jsr    LinInterp		; Go and find out what slip is
					; allowed at current speed
        sta    tmp31

; Find out if we are slipping over the amount allowed
        ldx     tmp32			; Load x reg with speed undriven
					; wheels should be (calculated
					; from driven wheel)
        lda     tmp31			; Multiply by the allowable
					; difference factor (slip allowed)
        mul
        txa				; Transfer high byte to acc
        bcc     Carry_Slip
        inca
Carry_Slip:
        add     o2_fpadc		; Acc = speed of undriven wheel
					; + slip allowed
        bcs     NO_TC_Loss		; If we go over 255 then no traction
        cmp     tmp32			; Compare to calculated speed of
					; undriven wheel
        bhi     NO_TC_Loss		; Were not over limit so no TC
        sta     tmp31			; Store speed of undriven wheel
					; + slip allowed
        lda     tmp32			; Load calculated value of
					; undriven wheel
        sub     tmp31
        sta     tmp32			; Store amount of traction loss
        bra     VSSThresh_RJMP

Traction_DoneJMP:
        jmp     Traction_Done

; If were here weve had Anti-Rev working and rpm is stable so do we
; reset it yet or later?
reset_TC_Yet:
        brclr   TCcycleSec,feature7,Reset_TC_Now	; Reset it now if
					; stable rpm selected
        bra     Check_TC_Counter	; Not reseting on stable rpm
					; so check cycle counter

RPM_Thresh:
        lda     rpm
        sub     rpmlast
        cmp     RPMthresh_f		; Have we increased rpm above
					; the threshold?
        bhs     Thresh_Reach

Check_TC_Counter:
        lda     ASEcount		; Use after start warmup counter
					; as its only used for a few
					; seconds on start up.
        cmp     TCCycles
        blo     Dont_Reset_Tract	; Only reset angle and accel
					; enrich after nn cycles
        bclr    Traction,EnhancedBits2	; Clear the traction control bit
        lda     #00T
        sta     TCAngle
        sta     TCAccel
        sta     ASEcount
Dont_Reset_Tract:
        jmp     Traction_Done

; For RPM Based Anti-Rev
Thresh_Reach:
        bset    Traction,EnhancedBits2	; Set the traction control bit
        lda     #00T
        sta     ASEcount		; Reset the cycle counter
        clr     tmp2

; Find the rate of change from the table lookup, store it in tmp31 for
; the rest of the interpolaters
        ldhx    #rpmdotrate		; Store address for finding
					; rate of change
        sthx    tmp1
        mov     #$03,tmp3		; Table size 4 (3+1)
        lda     rpm
        sub     rpmlast
        sta     tmp4
        sta     tmp10
        jsr     tablelookup		; Go find the address
        clrh
        lda     tmp5			; Put Address value from lookup
					; into x reg
        tax
        sta     tmp31			; Save tmp5 for next lin inter
        bra     TC_Interpoler

VSSThresh_RJMP:
        bra     VSSThresh_Reach

TC_Interpoler:
; Enrichment interpole
        lda     RPMrate_f,x		; Load the enrich value
        sta     liY2
        decx
        lda     RPMrate_f,x		; Load the enrich value - 1
        sta     liY1
        mov     tmp10,liX
        jsr     LinInterp
        lda     tmp6			; result from Lin Inter
        sta     TCAccel			; Store enrichment

; Retard angle interpole
        ldx     tmp31			; Address from lookup table
        lda     TractDeg_f,x
        sta     liY2
        decx
        lda     TractDeg_f,x		; Load the angle value - 1
        sta     liY1
        mov     tmp10,liX
        jsr     LinInterp
        lda     #255T			; 255 - result = retard angle
        sub     tmp6			; result from Lin Inter
        sta     TCAngle			; Store retard angle

; Engine cycles to hold interpole
        ldx     tmp31			; Address from lookup table
        lda     TractCycle_f,x ;
        sta     liY2
        decx
        lda     TractCycle_f,x		; Load the cycle hold value - 1
        sta     liY1
        mov     tmp10,liX
        jsr     LinInterp
        lda     tmp6
        sta     TCCycles

; Spark Cut finder
        ldx     tmp31
        lda     TractSpark_f,x
        sta     TCSparkCut		; No need to lin interpolate as

        bra     Traction_Done

TC_InterpJMP:
        bra   TC_Interpoler

; For speed sensor Anti-Rev system, find table value. Tmp32 contains loss
VSSThresh_Reach:
        bset    Traction,EnhancedBits2	; Set the traction control bit
        lda     #00T
        sta     ASEcount		; Reset the cycle counter
        clr     tmp2
; Find percentage of loss: Undriven wheel/100 * loss of traction (tmp32)
        lda     o2_fpadc
        clrh
        ldx     #100T
        div				; (H:A) / X ->A, rem in H
        tax
        pshh
        pula
        cmp     #50T			; Is remainder higher than half
					; divisor?
        blo     Round_Slip_Per
        incx
Round_Slip_Per:
        lda     tmp32
        mul				; X*A -> (X:A)
        cpx     #0T			; Did we overflow?
        beq     No_OF_Slip
        lda     #100T			; 100% max
No_OF_Slip:
        cmp     #100T
        blo     Slip_Percentage
        lda     #100T
Slip_Percentage:
        sta     tmp32			; Store percentage slip

; Find the percent slip from the table lookup, store it in tmp31 for
; the rest of the interpolaters
        ldhx    #sliprate		; Store address for finding slipage
        sthx    tmp1
        mov     #$03,tmp3		; Table size 4 (3+1)
        lda     tmp32			; Percentage of loss
        sta     tmp4
        sta     tmp10
        jsr     tablelookup		; Go find the address
        clrh
        lda     tmp5			; Put Address value from lookup
					; into x reg
        tax
        sta     tmp31			; Save tmp5 for next lin inter
        bra     TC_InterpJMP		; Now go and work out the
					; enrichments, etc

Traction_Done:

***************************************************************************
********************    S U B   S E C T I O N    L O O P     **************
***************************************************************************

;SubSectionLoop:
        brset   Primed,EnhancedBits,Prime_Checked	; Have we primed?
        jmp     NotPrimed

Prime_Checked:
        brclr   BoostControl,feature2,no_boost
        jsr     CalcBoostDC

no_boost:
        brclr   Nitrous,feature1,no_nitrous
        jsr     EnableN2O

no_nitrous:
        lda     feature6_f
        bit     #VETable3b
        beq     No_VE_Table_3
        jsr     Check_VE3_Table

No_VE_Table_3:
        lda   feature3_f
        bit   #TargetAFRb
        beq   No_AFRTar_VE1
                            ; Are we using the
							; target afrs for
							; table 1?
        jsr     AFR1_Targets; Get Target AFR
							; from table 1 for VE 1
NO_AfrTar_VE1:
        lda   feature6_f
        bit   #TargetAFR3b
        beq   No_AfrTar_VE3
        jsr     AFR2_Targets; Are we using the
							; target afrs for
							; table 3?
            				; Get Target AFR
							; from table 2 for VE 3
No_AfrTar_VE3:
        brset   running,engine,nospkoff   ; skip next check
        ;if not running then make sure all spark outputs are OFF
        ;this is a bandaid, but better safe than sorry
        jsr     turnallsparkoff     ; subroutine to stop them all
nospkoff:
        lda    personality_f
        beq    No_misc_Spark
        jsr    misc_spark                              ; dwell and other bits

No_misc_Spark:
;This section checks for imminent T2 rollover. Trying to avoid a race condition where
;the timer overflows but we try to read software byte before the overflow handler
; gets there. This would give an incorrect 24bit "current" value
        sei
        brset  roll1,EnhancedBits4,roll1set
        bclr   roll2,EnhancedBits4
        bra    chk_roll
roll1set:
        bset   roll2,EnhancedBits4
chk_roll:
        lda    T2CNTL           ; unlatch any previous read
        lda    T2CNTH
        cmp    #$FF
        bne    roll_not_high
        bset   roll1,EnhancedBits4
        bra    chkroll_end
roll_not_high:
        bclr   roll1,EnhancedBits4
chkroll_end:
        cli

;test code
;check if 0.1ms code has executed since we got here last. Major problem if it
;hasn't.
        brclr  checkbit,EnhancedBits5,troll_ck_done  ; ok
        ;oh dear, we've missed it

        lda     T2CNTL ; unlatch any previous read
        lda     T2CNTH
        sta     tmp1
        lda     T2CNTL
        add     #10T    ; interrupt will occur in 10us
        tax
        lda     tmp1
        adc     #0T
        sta     T2CH0H
        stx     T2CH0L
        bset    TOIE,T2SC0		; re-enable 0.1ms interrupt

troll_ck_done:
        bset   checkbit,EnhancedBits5  ;set it here, 0.1ms will clear it

        jmp    CalcRunningParameters                   ; Start main loop again

***************************************************************************
**
** Cranking Mode
**
** Pulsewidth is directly set by the coolant temperature value of
** 021p added facility to use Inlet Manifold air temp instead / as well
** CWU (at -40 degrees) and CWH (at 165 degrees) - value is interpolated
**
** Leaves result in tmp1, clears tmp2.
**
***************************************************************************

crankingMode:
         brclr    running,engine,ExtraFuelCrank   ; We are stopped so do we add
                                                  ; extra fuel whilst cranking?

crankingModePrime:
        bset    crank,engine		; Turn on cranking mode.
        bclr    startw,engine		; Turn off ASE mode.
        bclr    warmup,engine		; Turn off WUE mode.

        lda     tps			; ~70% comparison value for throttle
					; - flood clear trigger
        cmp     tpsflood_f
        blo     crankingPW
        clr     TCAccel

floodClear:
        clra				; Turn off pulses altogether.
        jmp     crankingDone

; Extra Fueling for Cranking! This is triggered if the TPS goes above the floodclear
; value 3 times before starting. Were using the NosDcOk Bit as its not used at cranking.
; Were also using various Traction Bytes too. All this to save RAM.

ExtraFuelCrank:
        lda     feature11_f4
        bit     #ExCrFuelb
        beq     floodClear              ; If Extra Cranking Fuel not selected then
                                        ; carry on as normal

        lda     tps
        cmp     tpsflood_f
        bhs     HighTPS                             ; Is the TPS higher than the floodclear value?
        brclr   NosDcOk,EnhancedBits,floodClear     ; No so go back to clearing PW
        bclr    NosDcOk,EnhancedBits
        inc     TCCycles                            ; Temp storage of TPS counter
        lda     TCCycles
        cmp     #03T
        blo     floodClear                          ; If we havent done it 3 times then clear PW
        lda     ExtraCrFu_f
        sta     TCAccel
        bra     floodClear

HighTPS:

        brset   NosDcOk,EnhancedBits,floodClear   ; Have we done this?
        bset    NosDcOk,EnhancedBits              ; Set bit so we dont do this again
        bra     floodClear



crankingPW:
;This section is redundant because variable overwritten below
;        clr     liX1			; -40 + 40
;        lda     #205T			; 165 + 40 degrees (because of
;					; offset in lookup table)
;        sta     liX2
;        lda     cwu_f1
;        sta     liY1
;        lda     cwh_f1
;        sta     liY2

; choose coolant, airtemp or average
        lda     feature11_f4
        bit     #matcrankb
        bne     crpwmat
crpwclt:				; if cltcrank bit is 1 or 0
        lda     coolant
        bra     crpwint

crpwmat:

        lda     feature11_f4
        bit     #cltcrankb
        beq     CltOnlyPulse
        lda     airtemp
        add     coolant
;        bcc     Clt_IAT_NOFlow   ; why ????
;        lda     #255T
;Clt_IAT_NOFlow:
        rora				; ( airtemp + coolant ) /2
        bra     crpwint

CltOnlyPulse:
        lda     airtemp                 ; Air Temp only
crpwint:
        sta     liX

; Table look up for Cranking PW, liX already contains temperature to look for - PR
        mov     liX,tmp4		; tmp4 holds the variable to look
					; for in the lookup table
        mov     liX,tmp10		; Save away for later use below
        ldhx    #WWURANGE
        sthx    tmp1
        mov     #$09,tmp3		; 10 bits wide
        jsr     tableLookup		; This finds the bins when the
					; temperatures are set

        clrh
        ldx     tmp5

        lda     CrankPWs_f,x
        sta     liY2
        decx
        lda     CrankPWs_f,x		; This finds the values for the
					; PW at the above temperatures
        sta     liY1
        mov     tmp10,liX

        jsr     LinInterp

; If TCAccel > 0 then we are multiplying the Crank PW by it

        lda     TCAccel
        beq     MultiFacCrank            ; Do we have a value to use?
        sta     tmp10
        clr     tmp11
        lda     tmp6
        sta     tmp12
        clr     tmp13
        jsr     Supernorm
        lda     tmp10
        add     tmp6                    ; Add original PW back
        bra     crankingDone

MultiFacCrank:
        lda     tmp6			; Leave it where expected.

crankingDone:
    ;    sta     egtadc
        sta     tmp1
        brclr   CrankingPW2,feature1,no_crankpw2
        sta     tmp2			; Pulse bank 2 just like bank 1.
       rts
no_crankpw2:
        clr     tmp2			; Zero out bank 2 while cranking.
        rts


***************************************************************************
** Roger Enns' Staged Injection System
** (Modded for MSnS-Extra by P Ringwood)
** Calculate staged mode pulse width:
**
** PW_STAGED = ((TMP11 + TPSACCEL) * ScaleFac / 512) - INJOCFUEL + TMP6
**
** ScaleFac = Primary inj size /(Prim + Sec inj size) * 512, should always
** be <=255.  If identically sized injectors, use 255.
***************************************************************************
CALC_STAGED_PW:
        lda     tmp11
        add     TPSACCEL
	add	NosPW
        bcs     MAX_PWM_ALLOWED2
        tax				; move calc'd pw to x-register
        lda     SCALEFAC_f		; load SCALEFAC constant into
					; accumulator
        mul				; multipy the two together,
					; 16-bit result in x:a
        txa				; transfer high byte of
					; pw*ScaleFac to accumlator,
					; overwriting existing lower byte.
        lsra				; Shift bit pattern to the right
        bcc     NO_INC			; if carry bit clear, skip increment
        inca				; otherwise, increment accumulator
NO_INC:
        add     tmp6			; then add open time
        bcc     FINISHED_PW_COMP
MAX_PWM_ALLOWED2:			; THIS SHOULD NEVER HAPPEN
        lda     #$FE
FINISHED_PW_COMP:
        sta     pw_staged
	; figure out how much to bring in during each pw scheduling time.
	lda	StgCycles_f
; redundant	cmp	#00T
	beq	staged_same		; if gradual transition is off branch

	; if the transition is done, branch
        brset	StgTransDone,EnhancedBits6,staged_same

	; calculate the secondary pulse-width using the following formula:
	; pw_staged2 = (((pw_staged - tmp6 + TPSACCEL) / StgCycles_f)
	;		  * stgTransitionCnt) +	tmp6)

	pshh
	tax
	lda	pw_staged
        sta     tmp22        ; stash a copy of pw_staged in tmp22
	sub	tmp6
	add	TPSACCEL
	add	NosPW
	clrh
	div
	cmp	#00T
	bne	continue_pw_2
	lda	#1T		; the div resulted in a 0 answer, round up
	; ok, now we have in the a register, the amt to add to secondary
	; during every ignition event, so do it
continue_pw_2:
	tax
	lda	stgTransitionCnt
				  ; if the count is 0, change to 1 to avoid
				  ; instant transition
; redundant	cmp	#00T
	bne	continue_mul_2
	lda	#1T
	sta	stgTransitionCnt
continue_mul_2:
	mul
	; now we have the amt to set pw_staged2 to
	; add back the open time
	add	tmp6
	sta	pw_staged2

	; now figure it out for pw_staged using the following formula
	; (tmp11 - ((((tmp11 + tmp6 + TPSACCEL) - pw_staged) / StgCycles_f) *
        ; stgTransitionCnt)) + tmp6
	; we add tmp6 in the innermost set of parens b/c pw_staged already
        ; has the open time in it, and adding the open time to tmp 11 will
        ; give us the time without the open-time when we subtract.

	lda	StgCycles_f
	tax
	lda	tmp11
	add	tmp6
	add	TPSACCEL    ; add this since it was included in calc for pw_staged
	add	NosPW
	sub	pw_staged   ; figure out how far to go from tmp11 to pw_staged
	clrh
	div		    ; then figure out how much per step
	cmp	#00T
	bne	continue_pw_1	; the div resulted in a 0 answer, round up
	lda	#1T
continue_pw_1:
	tax
	lda	stgTransitionCnt
	mul 		    ; calculate the amount to subtract from tmp11
	sta	pw_staged   ; use pw_staged as temporary storage
	lda	tmp11
	add	TPSACCEL
	sub	pw_staged
	add	tmp6
	sta	pw_staged

	cmp	pw_staged2   ; if pw_staged2 is greater than pw_staged,
			     ; we probably rounded, so use the original
			     ; pw_staged instead
	pulh

	bhi	check_staged_on	; we're done here, go see if staging should be
	                        ; on or not.

staged_early_done:
        lda     tmp22   ; overshot so use the value we saved earlier
	sta	pw_staged	; store here in case staged_same not executed
        bra     ss_s

staged_same:
	; gradual transition is off or the transition is done, set the done bit
	; so the count stops
	lda	pw_staged
ss_s:
	sta	pw_staged2
	bset	StgTransDone,EnhancedBits6

***************************************************************************
**
** Check for injector staging - RPE
**
** Staged based on kpa, rpm, or map - selectable via config13 bits 6,7
**
** If >= STGTRANS, staged mode on
** If <= (STGTRANS - STGDELTA), staged mode off
** STGDELTA provides user-definable hysteresis to prevent 'chattering' during
** transition phase.
**
***************************************************************************
check_staged_on:
        lda     feature5_f
        bit     #stagedModeb
        bne     LastCheck   ; If this bit is set then not RPM

        lda     STGTRANS_f		; RPM-based staging
        cmp     rpm
        bls     STAGED_ON
        sub     STGDELTA_f
        cmp     rpm
        bhs     STAGED_OFF
        rts

LastCheck:
        lda     feature5_f
        bit     #stagedb
        beq     MAPSTAGED ; If this bit is set then not TPS

        lda     tps			; TPS-based staging
        cmp     STGTRANS_f
        bhs     STAGED_ON
        lda     STGTRANS_f
        sub     STGDELTA_f
        cmp     tps
        bhs     STAGED_OFF
        rts

MAPSTAGED:				; Must be MAP Based staging
        lda     STGTRANS_f
        cmp     kpa
        bls     STAGED_ON
        sub     STGDELTA_f
        cmp     kpa
        bhs     STAGED_OFF
        rts

STAGED_ON:				; set staged bit to 1
	brclr	StagedMAP2nd,feature7,cont_staged_on
	brclr	StagedAnd,feature7,cont_staged_on
	; if here, both parameters must be on to turn on staging

check_2nd_param:
	lda	Stg2ndParmKPA_f
	cmp	kpa
	bls	cont_staged_on
	sub	Stg2ndParmDlt_f
	cmp	kpa
	bhs	cont_staged_off
	rts	;shouldn't get here

cont_staged_on:
        bset    REStaging,EnhancedBits
        rts

STAGED_OFF:				; clear bit
	brclr	StagedMAP2nd,feature7,cont_staged_off
	; if we get here, we need to see if And is on, because if it is
	; we want to turn off staging... if it isn't, we want to see
 	; if staging should be on
	brset	StagedAnd,feature7,cont_staged_off
	bra	check_2nd_param

cont_staged_off:
        bclr    REStaging,EnhancedBits
	clra
	sta	stgTransitionCnt	; staged is off, clear the staging
					; transition count
	sta	pw_staged2
	bclr	StgTransDone,EnhancedBits6
        rts




****************************************************************

VE_STEP_4:
        mov     tmp13,liX1		; rpm low
        mov     tmp14,liX2		; rpm high
        mov     tmp15,liY1		; ve low
        mov     tmp16,liY2		; ve high
        mov     rpm,liX
        jsr     LinInterp
        mov     tmp6,tmp19		; ve at lower kPa/alpha bound

VE_STEP_5:
        mov     tmp13,liX1		; rpm low
        mov     tmp14,liX2		; rpm high
        mov     tmp17,liY1		; ve low
        mov     tmp18,liY2		; ve high
        mov     rpm,liX
        jsr     LinInterp
        mov     tmp6,tmp11		; ve at upper kPa/alpha bound

VE_STEP_6:
        mov     tmp9,liX1		; kPa/alpha low
        mov     tmp10,liX2		; kPa/alpha high
        mov     tmp19,liY1		; ve low
        mov     tmp11,liY2		; ve high
        lda     kpa_n
        sta     liX
        jsr     LinInterp
        rts

******************************************************
** Boost Controller  table lookup macros
;these lookup macros are messed up because they refer to the
;wrong page and the ram lookup is from the wrong place
; i.e. if two table per flash page it is no good to do VE_r,x
; because that will return the wrong data
; 022i - commented out until they get fixed

					; boost control TABLE 1
$MACRO bc1X				; gets a byte from page8 or RAM.
					; On entry X contains index.
					; Returns byte in A
;        lda     page
;        cmp     #08T    ; it isn't in page !!!!
;        bne     ve7xf
;        lda     VE_r,x
;        bra     ve7xc
ve7xf:  lda     bc_kpa_f,x
ve7xc:
$MACROEND

					; boost control TABLE 2
$MACRO bc2X				; gets a byte from page8 or RAM.
					; On entry X contains index.
					; Returns byte in A
;        lda     page
;        cmp     #08T
;        bne     ve8xf
;        lda     VE_r,x
;        bra     ve8xc
ve8xf:  lda     bc_dc_f,x
ve8xc:
$MACROEND

					; boost control TABLE 3 for
					; switching boost table on the run
$MACRO bc3X				; gets a byte from page8 or RAM.
					; On entry X contains index.
					; Returns byte in A
;        lda     page
;        cmp     #08T
;        bne     ve9xf
;        lda     VE_r,x
;        bra     ve9xc
ve9xf:  lda     bc3_kpa_f,x
ve9xc:
$MACROEND

					; rotary trailing split					; switching boost table on the run
$MACRO rs1X				; gets a byte from flash or RAM.
					; On entry X contains index.
					; Returns byte in A
;just work from flash for now
        lda     page
        cmp     #07T
        bne     rs1xf
        lda     {VE_r+split_f-flash_table7},x   ; offset into ram copy
        bra     rs1xc
rs1xf:  lda     split_f,x
rs1xc:
$MACROEND

***************
; a few boost bits up here to be relative
boostZero:
        clra
        sta    bcDC
boostDone_dupe:
        rts

***************************************************************************
** Boost Controller
**
** Sets bcDC to current pwm duty cycle for boost control.  Current
** implementation assumes Audi-style solenoid plumbing, such that
** zero DC reduces boost as much as possible, while 100% DC
** increases boost as much as possible.  Added change to direction option
** for 100%DC = decrease boost.
**
** The closed loop calc is
** output = output + (kpaTarget-kpa)*pGain - (kpa-kpaLast)*dGain
**
** kpaTarget is the target boost looked up on 6x6 (rpm,tps) map
**
** if kpaTarget-kpa > diff max then output is lookup up on open loop 6x6 (rpm,tps) map
**
***************************************************************************

bcSetPoint equ  tmp6
bcDelta    equ  tmp7
bcP        equ  tmp8

CalcBoostDC:

        lda     kpa
        cmp     Pambient
        blo     boostZero		; If no boost sensed, don't burn
					; up the solenoid.
					; is this good or bad??

        lda     bcCtlClock		; RTC-based updates.
					; Would it be better to use engine revs
        cmp     bcUpdate_f		; See if our clock has expired
        blo     boostDone_dupe
        clr     bcCtlClock

**************************************************************************
**  Compute the target boost value based upon TPS and RPM 6x6 table
**************************************************************************

					; boost control ALWAYS page 8
        mov     tps,kpa_n		; (kpa_n also used in VE_STEP4)

;        brclr   BoostTable3,feature8,BoostT1
        lda     feature8_f
        bit     #BoostTable3b
        beq     BoostT1

        brclr   NosIn,portd,Table3_Boost; If using Boost Table 3 and input
					; low then its time to use it

;bc1_STEP_1:
BoostT1:
        ldhx    #TPSRANGEbc_f
        sthx    tmp1
        mov     #$05,tmp3		; 6x6
        mov     kpa_n,tmp4
        jsr     tableLookup
        mov     tmp5,tmp8		; Index
        mov     tmp1,tmp9		; X1
        mov     tmp2,tmp10		; X2

bc1_STEP_2:
        ldhx    #RPMRANGEbc_f
        sthx    tmp1
        mov     #$05,tmp3		; 6x6
        mov     rpm,tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		; Index
        mov     tmp1,tmp13		; X1
        mov     tmp2,tmp14		; X2
        bra     bc1_STEP_3

Table3_Boost:
        bra    Table3_Boost_J		; Jump

bc1_STEP_3:
        clrh
        ldx     #$06			; 6x6
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        bc1X
        sta     tmp15
        incx
        bc1X
        sta     tmp16
        ldx     #$06			; 6x6
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        bc1X
        sta     tmp17
        incx
        bc1X
        sta     tmp18

        jsr     VE_STEP_4
        bra     No_BTable_3_J
;       result in tmp6, equ'd above to be bcSetPoint

*****************************************************************************
**  Extra Boost Target Table put in for switching over on the run
*****************************************************************************
					; bc3_STEP_1:
Table3_Boost_J:
        ldhx    #TPSRANGE3bc_f
        sthx    tmp1
        mov     #$05,tmp3		; 6x6
        mov     kpa_n,tmp4
        jsr     tableLookup
        mov     tmp5,tmp8		; Index
        mov     tmp1,tmp9		; X1
        mov     tmp2,tmp10		; X2

bc3_STEP_2:
        ldhx    #RPMRANGE3bc_f
        sthx    tmp1
        mov     #$05,tmp3		; 6x6
        mov     rpm,tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		; Index
        mov     tmp1,tmp13		; X1
        mov     tmp2,tmp14		; X2
        bra     bc3_STEP_3

No_BTable_3_J:
        bra     No_BTable_3		; Jump

bc3_STEP_3:
        clrh
        ldx     #$06			; 6x6
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        bc3X
        sta     tmp15
        incx
        bc3X
        sta     tmp16
        ldx     #$06			; 6x6
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        bc3X
        sta     tmp17
        incx
        bc3X
        sta     tmp18
        jsr     VE_STEP_4

No_BTable_3:
					; result in tmp6, equ'd above to
					; be bcSetPoint
*****************************************************************************
** Compute a delta for the current duty cycle.
*****************************************************************************
					; The real boost controller,
					; compute delta.
        lda     bcSetPoint
        sub     KnockBoost		; Subtract boost target with knock
					; detection boost value
        sta     bcSetPoint

*****************************************************************************
**
**  Remove 1 psi of boost per user defined amount of IAT when IAT
**  above setpoint
**
*****************************************************************************
      clr   tmp31
      lda   iatBoostSt_f
      beq   noBoostIAT			; If zero then dont go any further.
      lda   iatBoost_f			; load the temp per 1 psi to remove.
      beq   noBoostIAT			; If zero then dont go any further.
      lsra				; Shift bit pattern to the right
					; (Divide by 2)
      bcc   no_carry_B			; Check if carry bit clear,
					; skip increment

      inca				; otherwise, increment accumulator

no_carry_B:
      sta   tmp32			; Stores half the iatDeg

      lda   tps
      cmp   tpsBooIAT_f			; Setpoint of tps for boost reduction
      blo   noBoostIAT

      lda   airTemp			; Actual IAT Temp
      cmp   iatBoostSt_f		; Setpoint for start of Boost removal
      blo   noBoostIAT

      sub   iatBoostSt_f		; How much higher are we?
					; Leaves difference in accumulator
      clrh				; Zero out high 8 bits of 16-bit
					; H:X register
					; Accumulator contains low 8 bits
      ldx   iatBoost_f			; Set divisor
      div				; (H:A) /X -> A, with rem in H

      tax				; Move quotient to index register
      pshh				; Transfer remainder to accumulator
      pula
      cmp   tmp32			; See if the remainder is more
					; than half of divisor
      blo   FinishBIAT
      incx				; It was a big remainder, round up.
FinishBIAT:
      lda  #07T				; Multiply by 7 KPa (1PSI)
      mul
      sta  tmp31			; Boost to remove
      lda  bcSetPoint
      sub  tmp31
      sta  bcSetPoint			; New boost target
noBoostIAT:

*****************************************************************************
** Matt Dupuis idea
** if abs(target pressure - curr pressure ) > bc_max_diff
**   then use bc_default duty cycle
** This can now make the controller open loop only by setting the
** max diff to zero
*****************************************************************************

        lda     kpa			; Calc P for our PD controller.
        sub     bcSetPoint		; result from interpolate tmp6
        bcc     mboostPos
        nega
mboostPos:
        cmp     bc_max_diff
        bhi     boost_fixed

bc_eric:
;Originated Eric Fahlgren, closed loop method
        bclr    bcTableUse,squirt
        lda     kpa			; Calc P for our PD controller.
        sub     bcSetPoint		; result from interpolate tmp6
        bcc     boostPos
        nega
boostPos:
        ldx     bcPgain_f		; Proportional Gain in percent,
					; 255=100%.
        mul				; returns in x:a
        stx     bcP			; just high byte
				; bcP = abs(kpa-bcSetpoint) * (Pgain / 256)

        lda     kpa			; now calc 'kpadot' in here at
					; same rate
        sub     kpalast
        bcc     kpadotPos
        nega
kpadotPos:
        ldx     bcDgain_f		; Differential Gain
        mul
        txa
        nega				; =  - abs(kpa-kpalast) * (dGain/255)

        add     bcP
        sta     bcDelta			; p term - d term

*****************************************************************************
** We now have a setpoint and a delta, so adjust the duty cycle.
*****************************************************************************

        lda     kpa
        cmp     bcSetPoint
        blo     boostInc		; going up
        bra     boostDec		; coming down

boostDec:
        lda     bcDC
        sub     bcDelta
        bcs     boostZero2
        bra     boostSet

boostInc:
        lda     bcDC
        add     bcDelta
        bcs     boostRail
        bra     boostSet

boostRail:
        lda     #255T
        bra     boostSet

boostZero2:
        clra

boostSet:
        sta    bcDC
boostDone:
        mov     kpa,kpalast
        rts

boost_fixed:
;lookup fixed duty cycle from table. 'out of range' open loop duty

;boost control ALWAYS page 8
        bset    bcTableUse,squirt
        mov     tps,kpa_n		; (kpa_n also used in VE_STEP4)
;bc2_STEP_1:
        ldhx    #TPSRANGEbc_f2
        sthx    tmp1
        mov     #$05,tmp3		; 6x6
        mov     kpa_n,tmp4
        jsr     tableLookup
        mov     tmp5,tmp8		; Index
        mov     tmp1,tmp9		; Y1
        mov     tmp2,tmp10		; Y2

bc2_STEP_2:
        ldhx    #RPMRANGEbc_f2
        sthx    tmp1
        mov     #$05,tmp3		; 6x6
        mov     rpm,tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		; Index
        mov     tmp1,tmp13		; X1
        mov     tmp2,tmp14		; X2

bc2_STEP_3:

        clrh
        ldx     #$06			; 6x6
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        bc2X
        sta     tmp15
        incx
        bc2X
        sta     tmp16
        ldx     #$06			; 6x6
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        bc2X
        sta     tmp17
        incx
        bc2X
        sta     tmp18

        jsr     VE_STEP_4
        mov     tmp6,bcDC
        mov     kpa,kpalast
        rts
***************************************************************************

$MACRO TurnAllSpkOff			; gets called in stall or on
					; entering bootloader mode
					;turn spark outputs to inactive
        brclr    invspk,EnhancedBits4,soin
        ; inverting easy, just put all to zero
        bclr     iasc,porta
        bclr     sled,portc
        bclr     wled,portc
        bclr     aled,portc
        bclr     Output3,portd
        bclr     pin10,portc
        bclr     KnockIn,portd
        bra      soin_done
soin:   ; non inv
        brset    REUSE_FIDLE,outputpins,soin1
        bclr     iasc,porta
        bra      soin2
soin1:  bset     iasc,porta
soin2:  brset    REUSE_LED17,outputpins,soin3
        bclr     sled,portc
        bra      soin4
soin3:  bset     sled,portc
soin4:  brset    REUSE_LED19,outputpins,soin5
        bclr     aled,portc
        bra      soin6
soin5:  bset     aled,portc
soin6:  brclr    REUSE_LED18,outputpins,soin7
        brclr    REUSE_LED18_2,outputpins,soin7
        bset     wled,portc
        bra      soin8
soin7:  bclr     wled,portc
soin8:
        brclr    out3sparkd,feature2,soin9
        bset     Output3,portd
soin9:
        lda	 feature8_f
        bit      #spkeopb
        beq      soin10
        bset     pin10,portc
soin10:
       lda       feature8_f
       bit       #spkfopb
       beq       soin11
       bset      KnockIn,portd
soin11:
soin_done:

;kill the dwell timers too just in case
        clr     SparkOnLeftah
        clr     SparkOnLeftal
        clr     SparkOnLeftbh
        clr     SparkOnLeftbl
        clr     SparkOnLeftch
        clr     SparkOnLeftcl
        clr     SparkOnLeftdh
        clr     SparkOnLeftdl
        clr     SparkOnLefteh
        clr     SparkOnLeftel
        clr     SparkOnLeftfh
        clr     SparkOnLeftfl

$MACROEND

***************************************************************************

$MACRO  SubDwell
                lda     dwelltmpLop
                sub     dwellusl	; dwell target calc'd just earlier
                sta     dwelltmpLop     ; temp result
                lda     dwelltmpHop
                sbc     dwellush
                sta     dwelltmpHop
                lda     dwelltmpXop
                sbc     #0
                sta     dwelltmpXop
$MACROEND
$MACRO DwellRail
; check if we've gone too low
                lda     dwelltmpXop
                beq     dwlnwchk
                bit     #$80
                bne     dwlnwrail       ; gone negative. Rail.
                bra     dwlnwok         ; X byte>0 so dwell long enough
dwlnwchk:
                lda     dwelltmpHop
                bne     dwlnwok         ; H byte>0 so dwell long enough
                lda     dwelltmpLop
                cmp     mindischg_f
                bhs     dwlnwok
dwlnwrail:
                clr     dwelltmpXop     ; rail dwell delay at min discharge
                clr     dwelltmpHop
                lda     mindischg_f
                sta     dwelltmpLop
dwlnwok:
$MACROEND

$MACRO DwellDiv
                ;store result. Convert us to 0.1ms
; don't use udvd32 - wasteful, only need 24/8bit divide
                clrh
                ldx     #100T
                lda     dwelltmpXop
                div                     ;A rem H = (H:A) / X
                sta     dwelltmpXms
                lda     dwelltmpHop
                div
                sta     dwelltmpHms
                lda     dwelltmpLop
                div
                sta     dwelltmpLms

                lda     dwelltmpXms
                beq     dwlldend      ; too long, rail to max
                lda     #255T
                sta     dwelltmpHms
                sta     dwelltmpLms

dwlldend:

;check for high speed when dwell and period may be close
                lda     dwelltmpHms
                bne     save_dwell

                lda     dwelltmpLms
                cmp     mindischg_f	; check if less than minimum period
                bhi     save_dwell
dwell_lim:				; target dwell period>available period
                clr     dwelltmpHms
                lda     mindischg_f
                sta     dwelltmpLms	; minimum X x 0.1ms non-dwell time

save_dwell:
          ;move calculation variable into variable used by CalcDwellspk
                ldhx    dwelltmpHms
$MACROEND

***************************************************************************

turnallsparkoff:
        TurnAllSpkOff
        rts
***************************************************************************
* Spark and Dwell stuff
* Some bits moved out of interrupt routines to save a few ticks
***************************************************************************
* The following table is a dwell period vs battery voltage correction table
* derived from
* T = -L/R * ln(1- RI/V)
***************************************************************************

dwelltv: db     51T,68T,85T,102T,119T,136T	; 6v,8v,10v,12v,14v,16v
dwelltf: db     250T,124T,84T,64T,51T,44T
;Values in table are /4 (i.e. 250 = 250/256*4 = x 3.9)

misc_spark:
        brset   running,engine,hei7_spd   ; skip next check
        ;if not running then make sure all spark outputs are OFF
        ;this is a bandaid, but better safe than sorry
;        TurnAllSpkOff     ; macro to stop them all  - moved to mainloop
;
hei7_spd:
;moved from Sparktime - set/clr HEI7 output
        brclr   HEI7,personality,dwellornot
;024a changed the logic, now transitions when fully out of crank (+1 second)
; and over 400rpm
        brset   crank,engine,hei7zero
;cant_crank only gets set when above cranking rpm for over a second
        brclr   cant_crank,EnhancedBits2,hei7zero
        lda     rpm
        cmp     #4T     ; hardcoded 400rpm transisition
        blo     hei7zero
hei7five:
        bclr    aled,portc
        bra     dwellornot
hei7zero:
;If HEI and low speed set bypass to 0v
        bset    aled,portc

dwellornot:
        brclr   dwellcont,feature7,ms_dwell ; skip if not doing real dwell

;first lookup battery correction factor from above table
        ldhx    #dwelltv
        sthx    tmp1
        mov     #5,tmp3			; 6 elements
        mov     batt,tmp4
        jsr     tableLookup

        clrh
        ldx     tmp5
        lda     dwelltf,x
        sta     liY2
        decx
        lda     dwelltf,x
        sta     liY1
        lda     batt
        sta     liX
        jsr     LinInterp
        ;result in tmp6

        brset   crank,engine,crankdwell

        lda     dwellrun_f
        bra     dwell_corr
crankdwell:
        lda     dwellcrank_f
dwell_corr:
        ldx     tmp6
        mul				; result in x:a
;now multiply by 4 as factor table is /4 and dwell in 0.1ms units

        lsla
        rolx
        bcs     max_dwell

        lsla
        rolx
        bcc     do_dwell_us

max_dwell:
        ldx     #255T			; max dwell 25.5ms
do_dwell_us:
        stx     dwelldms		; save corrected target dwell
					; (in 0.1ms units)

;calculate this in us
        lda     #100T
        mul

        sei				; no ints while we save these
        stx     dwellush                ; this is the microsecond duration of coil-on
        sta     dwellusl
        cli

; we've now calculated target dwell period

;used by dwell and duty cycle
ms_dwell:
                sei             ; avoid interruption between high/low bytes
                mov     iTimeX,dwelltmpX     ; dt-1
                mov     iTimeH,dwelltmpH
                mov     iTimeL,dwelltmpL
                mov     iTimepX,dwelltmpXp   ; dt-2
                mov     iTimepH,dwelltmpHp
                mov     iTimepL,dwelltmpLp
                cli

;For a single period, can..
;predict this period iTime[this] = itime[last]) + (itime[last] - itime[previous])
;calculate acceleration factor (itime[last] - itime[previous]) and store in dwelltmp?ac
;024n sense changed now +ve is accel, -ve is decel. Unlikely to make any difference, but
;worth a try

;025n7, try reversing sense as it was doing more harm than good
;somehow I'd got the sense wrong.

                lda     dwelltmpLp
                sub     dwelltmpL
                sta     dwelltmpLac     ; ddt
                lda     dwelltmpHp
                sbc     dwelltmpH
                sta     dwelltmpHac
                lda     dwelltmpXp
                sbc     dwelltmpX
                sta     dwelltmpXac



;when in accel double the correction factor to compensate for increasing
; advance etc. and to err on the side of a bit more dwell
;               brclr    7,dwelltmpXac,not_dwell_accel ; if positive i.e. decel
;               lsl      dwelltmpLac
;               rol      dwelltmpHac
;               rol      dwelltmpXac

not_dwell_accel:
;dwelltmp?ac now contains the acceleration factor  (-ddt)
;re-write of this whole next section (025i)
; instead of doing some calcs and then branching, have one big section of code for each
; option. Code space isn't a problem. Brain space is!
; Various code options.
; "dwell" duty cycle for 1,2,3,4 outputs - this is pretty much the earlier
; dwell control for 1,2,3,4, rotary2 outputs


                brclr   dwellcont,feature7,dwell_duty_calc
                jmp     true_dwell_calc
dwell_duty_calc:
                brset   wspk,EnhancedBits4,wasted_dwell ; wasted spark/multi-outputs
;just add on (-ddt)
                jmp     dwlprdcalc

wasted_dwell:

;see how many periods we want to dwell across
;Here we'll predict period between sparks on a channel
; i.e. if not wasted spark this is iTime(pred) but if wasted spark then
; we wait 360 degrees (could be 720 actually if someone does 4cyl COP)
;Would be desireable to go "back" only enough periods to give greater accuracy

;for waste spark outputs need to add lots more correction factor
; 2 outputs = 3x
; 3 outputs = 6x
; 4 outputs = 10x
; all assumes uniform acceleration
;residue of old code, checks how many outputs
;for now always calc all periods

;5th and 6th
                lda     feature8_f
                bit     #spkfopb
                bne     jcd_6dd
                bit     #spkeopb
                bne     jcd_5dd
;check if 4th spark output in use
                brset   out3sparkd,feature2,jcd_4dd ; if 4 ops
;check if 3rd spark output in use
;don't check for 2nd output, wouldn't have got here otherwise
                brclr   REUSE_LED18,outputpins,cd_2dd    ; want 1 } spark c
                brclr   REUSE_LED18_2,outputpins,cd_2dd  ; want 1 }
cd_3dd:
;3 periods = 3dt-1 + 3ddt
;3x dt-1
;save a copy in dwelltmp?p
                mov     dwelltmpL,dwelltmpLp
                mov     dwelltmpH,dwelltmpHp
                mov     dwelltmpX,dwelltmpXp

                lsl     dwelltmpL
                rol     dwelltmpH
                rol     dwelltmpX

                lda     dwelltmpL
                add     dwelltmpLp
                sta     dwelltmpL
                lda     dwelltmpH
                adc     dwelltmpHp
                sta     dwelltmpH
                lda     dwelltmpX
                adc     dwelltmpXp
                sta     dwelltmpX

;2x ddt
                lsl     dwelltmpLac
                rol     dwelltmpHac
                rol     dwelltmpXac
;+ ddt
                lda     dwelltmpL
                add     dwelltmpLac
                sta     dwelltmpL
                lda     dwelltmpH
                adc     dwelltmpHac
                sta     dwelltmpH
                lda     dwelltmpX
                adc     dwelltmpXac
                sta     dwelltmpX

                jmp     dwlprdcalc

jcd_4dd:        jmp     cd_4dd
jcd_5dd:        jmp     cd_5dd
jcd_6dd:        jmp     cd_6dd

cd_2dd:
;2 periods = 2dt-1 + 2ddt
;2x dt-1
                lsl     dwelltmpL
                rol     dwelltmpH
                rol     dwelltmpX
;2x ddt
                lsl     dwelltmpLac
                rol     dwelltmpHac
                rol     dwelltmpXac

                jmp     dwlprdcalc

cd_4dd:
;4 periods = 4dt-1 + 4ddt
;4x dt-1
                lsl     dwelltmpL
                rol     dwelltmpH
                rol     dwelltmpX

                lsl     dwelltmpL
                rol     dwelltmpH
                rol     dwelltmpX
;4x ddt
                lsl     dwelltmpLac
                rol     dwelltmpHac
                rol     dwelltmpXac

                lsl     dwelltmpLac
                rol     dwelltmpHac
                rol     dwelltmpXac


                jmp     dwlprdcalc

cd_5dd:
;5 periods = 5dt-1 + 5ddt
;3x dt-1
;save a copy in dwelltmp?p
                mov     dwelltmpL,dwelltmpLp
                mov     dwelltmpH,dwelltmpHp
                mov     dwelltmpX,dwelltmpXp

                lsl     dwelltmpL
                rol     dwelltmpH
                rol     dwelltmpX

                lsl     dwelltmpL
                rol     dwelltmpH
                rol     dwelltmpX

                lda     dwelltmpL
                add     dwelltmpLp
                sta     dwelltmpL
                lda     dwelltmpH
                adc     dwelltmpHp
                sta     dwelltmpH
                lda     dwelltmpX
                adc     dwelltmpXp
                sta     dwelltmpX

;2x ddt
                lsl     dwelltmpLac
                rol     dwelltmpHac
                rol     dwelltmpXac
;2x ddt
                lsl     dwelltmpLac
                rol     dwelltmpHac
                rol     dwelltmpXac

;+ ddt
                lda     dwelltmpL
                add     dwelltmpLac
                sta     dwelltmpL
                lda     dwelltmpH
                adc     dwelltmpHac
                sta     dwelltmpH
                lda     dwelltmpX
                adc     dwelltmpXac
                sta     dwelltmpX

                bra     dwlprdcalc

cd_6dd:
;same as 3dd x 2
;3 periods = 3dt-1 + 3ddt
;3x dt-1
;save a copy in dwelltmp?p
                mov     dwelltmpL,dwelltmpLp
                mov     dwelltmpH,dwelltmpHp
                mov     dwelltmpX,dwelltmpXp

                lsl     dwelltmpL
                rol     dwelltmpH
                rol     dwelltmpX

                lda     dwelltmpL
                add     dwelltmpLp
                sta     dwelltmpL
                lda     dwelltmpH
                adc     dwelltmpHp
                sta     dwelltmpH
                lda     dwelltmpX
                adc     dwelltmpXp
                sta     dwelltmpX

;2x ddt
                lsl     dwelltmpLac
                rol     dwelltmpHac
                rol     dwelltmpXac
;+ ddt
                lda     dwelltmpL
                add     dwelltmpLac
                sta     dwelltmpL
                lda     dwelltmpH
                adc     dwelltmpHac
                sta     dwelltmpH
                lda     dwelltmpX
                adc     dwelltmpXac
                sta     dwelltmpX

;double it
                lsl     dwelltmpL	; high byte
                rol     dwelltmpH	; Divide by 2 to get 50% dwell
                rol     dwelltmpX
;double it
                lsl     dwelltmpLac
                rol     dwelltmpHac
                rol     dwelltmpXac

;                bra     dwlprdcalc


dwlprdcalc:
;add off the accel factor (-ve)
                lda     dwelltmpL
                add     dwelltmpLac
                sta     dwelltmpL
                lda     dwelltmpH
                adc     dwelltmpHac
                sta     dwelltmpH
                lda     dwelltmpX
                adc     dwelltmpXac
                sta     dwelltmpX

;dwelltmp? now contains the predicted period between sparks on one ignition channel
;for single coil this is an ignition event, for wasted spark this is 360 or even 720
;we've now calculated the full period to dwell over so decide what to do with it

;save an un-mutilated copy for rotary
                mov     dwelltmpX,dwelltmpXac
                mov     dwelltmpH,dwelltmpHac
                mov     dwelltmpL,dwelltmpLac

                lsr     dwelltmpX	; high byte
                ror     dwelltmpH	; Divide by 2 to get 50% dwell
                ror     dwelltmpL
;
; original MSnS code uses 75%, but there was discussion that 50% might be
; more suitable for some ignition setups, so I changed it. Now made a
; config option.
;
                brset   dwellduty50,feature2,end_dwell
                lsr     dwelltmpX
                ror     dwelltmpH
                ror     dwelltmpL	; divide by 2 again to get 75% dwell

end_dwell:
;now convert the precision calculation into a raw 0.1ms value
;use by both dwell and duty cylce outputs

; don't use udvd32 - wasteful, only need 24/8bit divide
                clrh
                ldx     #100T
                lda     dwelltmpX
                div                     ;A rem H = (H:A) / X
                sta     dwelltmpX
                lda     dwelltmpH
                div
                sta     dwelltmpH
                lda     dwelltmpL
                div
                sta     dwelltmpL

                lda     dwelltmpX
                beq     dwelldiv_end      ; too long, rail to max
                lda     #255T
                sta     dwelltmpH
                sta     dwelltmpL

dwelldiv_end:

; decide where to save it given new scheme
                ldhx    dwelltmpH
                brset   rotary2,EnhancedBits5,sd_1  ; are we doing rotary split
                brclr   wspk,EnhancedBits4,sd_1 ; or non-wasted, then single output
                lda     feature8_f
                bit     #spkfopb
                bne     sd_6
                bit     #spkeopb
                bne     sd_5
;check if 4th spark output in use
                brset   out3sparkd,feature2,sd_4 ; if 4 ops
;check if 3rd spark output in use
;don't check for 2nd output, wouldn't have got here otherwise
                brclr   REUSE_LED18,outputpins,sd_2    ; want 1 } spark c
                brclr   REUSE_LED18_2,outputpins,sd_2  ; want 1 }
sd_3:
                sthx    dwelldelay3
                ldhx    #0
                sthx    dwelldelay1
                sthx    dwelldelay2
                bra     sd_done
sd_1:
                sthx    dwelldelay1
                bra     sd_done

sd_2:
                sthx    dwelldelay2
                ldhx    #0
                sthx    dwelldelay1
                bra     sd_done

sd_4:
                sthx    dwelldelay4
                ldhx    #0
                sthx    dwelldelay1
                sthx    dwelldelay2
                sthx    dwelldelay3
                bra     sd_done
sd_5:
                sthx    dwelldelay5
                ldhx    #0
                sthx    dwelldelay1
                sthx    dwelldelay2
                sthx    dwelldelay3
                sthx    dwelldelay4
                bra     sd_done
sd_6:
                sthx    dwelldelay6
                ldhx    #0
                sthx    dwelldelay1
                sthx    dwelldelay2
                sthx    dwelldelay3
                sthx    dwelldelay4
                sthx    dwelldelay5
;                bra     sd_done
sd_done:
                jmp     really_done_dwell



true_dwell_calc:
; One section of code depending on number of spark outputs now
; so code can apply delay of 1,2,3,4 periods back depending on rpm/advance
; this is supposed to improve dwell stability at medium speeds when engine conditions
; could have changed a lot between setting the dwell timer and the dwell starting.

; Fixed duty cycle doesn't really need this lot as we always "dwell" across the whole time
; between sparks on one channel.
; Most of the comments in here are related to real dwell control.

;WAS....
;dwellduty1 = dt-1 + acc factor - dwell       dt-1 +   ddt
;dwellduty2 = dwellduty1 + dt-1 + ac + ac    2dt-1 +  3ddt
;dwellduty3 = dwellduty2 + dt-1 + ac + 2ac   3dt-1 +  6ddt
;dwellduty4 = dwellduty3 + dt-1 + 4ac        4dt-1 + 10ddt

;But the massive loads of correction factor seemed to do more harm than good,
;NOW....
;dwellduty1 = dt-1 + acc factor - dwell       dt-1 +   ddt
;dwellduty2 = dwellduty1 + dt-1 + ac + ac    2dt-1 +  2ddt
;dwellduty3 = dwellduty2 + dt-1 + ac + 2ac   3dt-1 +  3ddt
;dwellduty4 = dwellduty3 + dt-1 + 4ac        4dt-1 + 4ddt

;add off the accel factor (-ve)    dt = dt-1 + (-ddt) (predicted next period)
                lda     dwelltmpL     ; dt-1
                add     dwelltmpLac   ; ac
                sta     dwelltmpLp    ; used if wspk
                sta     dwelltmpLop   ; output value
                lda     dwelltmpH
                adc     dwelltmpHac
                sta     dwelltmpHp
                sta     dwelltmpHop
                lda     dwelltmpX
                adc     dwelltmpXac
                sta     dwelltmpXp
                sta     dwelltmpXop

                SubDwell        ; subtract dwell

                brset   rotary2,EnhancedBits5,cd0
                brset   wspk,EnhancedBits4,cd1_start

cd0:
;we are either have one spark output or rotary. We dwell across a single period only.
                DwellRail     ; check if negative or less than mindischarge
                DwellDiv         ; convert microseconds to 0.1ms units
                sthx    dwelldelay1
                jmp     really_done_dwell

cd1_start:
                ;check to see if value we _would_ store in dwelldelay1 is negative
                ; ie. top bit set
                lda     dwelltmpXop
                bmi     cd_1rail   ; if pos ok, else set to zero  ?? is BMI correct?
                DwellDiv
                bra     cd_1store
cd_1rail:
                ldhx    #0
cd_1store:
                sthx    dwelldelay1
cd_2:
;dd2 = dd1 +dt-1 + ac + ac
                lda     dwelltmpLp ; period without dwell removed
                add     dwelltmpL
                sta     dwelltmpLp  ; now 2 periods ready for next calc
                sta     dwelltmpLop
                lda     dwelltmpHp
                adc     dwelltmpH
                sta     dwelltmpHp
                sta     dwelltmpHop
                lda     dwelltmpXp
                adc     dwelltmpX
                sta     dwelltmpXp
                sta     dwelltmpXop

                lda     dwelltmpLop
                add     dwelltmpLac
                sta     dwelltmpLop
                lda     dwelltmpHop
                adc     dwelltmpHac
                sta     dwelltmpHop
                lda     dwelltmpXop
                adc     dwelltmpXac
                sta     dwelltmpXop

                SubDwell        ; subtract dwell

                brclr   REUSE_LED18,outputpins,cd2_done    ; want 1 } spark c
                brclr   REUSE_LED18_2,outputpins,cd2_done  ; want 1 }
                bra     cd2_cont
cd2_done:
                DwellRail     ; check if negative or less than mindischarge
                DwellDiv         ; convert microseconds to 0.1ms units
                sthx    dwelldelay2
;                ldhx    #0
;                sthx    dwelldelay3
;                sthx    dwelldelay4
                jmp     really_done_dwell

cd2_cont:
                ;check to see if value we _would_ store in dwelldelay2 is negative
                ; ie. top bit set
                lda     dwelltmpXop
                bmi     cd_2rail   ; if pos ok, else set to zero  ?? is BPL correct?
                DwellDiv
                bra     cd_2store
cd_2rail:
                ldhx    #0
cd_2store:
                sthx    dwelldelay2

cd_3:
;3 periods = 3dt-1 + 3ddt
;3x dt-1
;save a copy in dwelltmp?p

                lda     dwelltmpLp ; period without dwell removed
                add     dwelltmpL
                sta     dwelltmpLp  ; now 3 periods ready for next calc
                sta     dwelltmpLop
                lda     dwelltmpHp
                adc     dwelltmpH
                sta     dwelltmpHp
                sta     dwelltmpHop
                lda     dwelltmpXp
                adc     dwelltmpX
                sta     dwelltmpXp
                sta     dwelltmpXop

                lda     dwelltmpLop
                add     dwelltmpLac
                sta     dwelltmpLop
                lda     dwelltmpHop
                adc     dwelltmpHac
                sta     dwelltmpHop
                lda     dwelltmpXop
                adc     dwelltmpXac
                sta     dwelltmpXop

                SubDwell        ; subtract dwell

                brset   out3sparkd,feature2,cd3_cont ; if 4 outputs
cd3_done:
                DwellRail     ; check if negative or less than mindischarge
                DwellDiv         ; convert microseconds to 0.1ms units
                sthx    dwelldelay3
;                ldhx    #0
;                sthx    dwelldelay4
                jmp     really_done_dwell

cd3_cont:
                ;check to see if value we _would_ store in dwelldelay3 is negative
                ; ie. top bit set
                lda     dwelltmpXop
                bmi     cd_3rail   ; if pos ok, else set to zero  ?? is BPL correct?
                DwellDiv
                bra     cd_3store
cd_3rail:
                ldhx    #0
cd_3store:
                sthx    dwelldelay3



cd_4:
; suspicion that this calc is not working right
;4 periods = 4dt-1 + 10ddt
;double ac factor again to make it -4ddt ; but we wanted -10ddt ?!
                lsl     dwelltmpLac
                rol     dwelltmpHac
                rol     dwelltmpXac

                lda     dwelltmpLp ; period without dwell removed
                add     dwelltmpL
;                sta     dwelltmpLp  ; now 4 periods ready for next calc
                sta     dwelltmpLop
                lda     dwelltmpHp
                adc     dwelltmpH
;                sta     dwelltmpHp
                sta     dwelltmpHop
                lda     dwelltmpXp
                adc     dwelltmpX
;                sta     dwelltmpXp
                sta     dwelltmpXop

                lda     dwelltmpLop
                add     dwelltmpLac
                sta     dwelltmpLop
                lda     dwelltmpHop
                adc     dwelltmpHac
                sta     dwelltmpHop
                lda     dwelltmpXop
                adc     dwelltmpXac
                sta     dwelltmpXop

                SubDwell        ; subtract dwell

                lda     feature8_f
                bit     #spkeopb
                bne     cd4_cont     ; if 5 outputs
cd4_done:
                DwellRail     ; check if negative or less than mindischarge
                DwellDiv         ; convert microseconds to 0.1ms units
                sthx    dwelldelay4
;                ldhx    #0
;                sthx    dwelldelay5
                jmp     really_done_dwell

cd4_cont:
                ;check to see if value we _would_ store in dwelldelay4 is negative
                ; ie. top bit set
                lda     dwelltmpXop
                bmi     cd_4rail   ; if pos ok, else set to zero  ?? is BPL correct?
                DwellDiv
                bra     cd_4store
cd_4rail:
                ldhx    #0
cd_4store:
                sthx    dwelldelay4

cd_5:
;----------------------
;5 periods = 5dt-1 + 10ddt
;double ac factor again to make it -4ddt ; but we wanted -10ddt ?!
                lsl     dwelltmpLac  ; really ??
                rol     dwelltmpHac
                rol     dwelltmpXac

                lda     dwelltmpLp ; period without dwell removed
                add     dwelltmpL
;                sta     dwelltmpLp  ; now 4 periods ready for next calc
                sta     dwelltmpLop
                lda     dwelltmpHp
                adc     dwelltmpH
;                sta     dwelltmpHp
                sta     dwelltmpHop
                lda     dwelltmpXp
                adc     dwelltmpX
;                sta     dwelltmpXp
                sta     dwelltmpXop

                lda     dwelltmpLop
                add     dwelltmpLac
                sta     dwelltmpLop
                lda     dwelltmpHop
                adc     dwelltmpHac
                sta     dwelltmpHop
                lda     dwelltmpXop
                adc     dwelltmpXac
                sta     dwelltmpXop

                SubDwell        ; subtract dwell

               lda     feature8_f
               bit     #spkfopb
               bne     cd5_cont     ; if 6 outputs
cd5_done:
                DwellRail     ; check if negative or less than mindischarge
                DwellDiv         ; convert microseconds to 0.1ms units
                sthx    dwelldelay5
                jmp     really_done_dwell

cd5_cont:
                ;check to see if value we _would_ store in dwelldelay4 is negative
                ; ie. top bit set
                lda     dwelltmpXop
                bmi     cd_5rail   ; if pos ok, else set to zero  ?? is BPL correct?
                DwellDiv
                bra     cd_5store
cd_5rail:
                ldhx    #0
cd_5store:
                sthx    dwelldelay5


cd_6:
;----------------------
;6 periods = 6dt-1 + ??ddt
;double ac factor again to make it -4ddt ; but we wanted -10ddt ?!
;these calculations need some serious thought for 5 & 6
                lsl     dwelltmpLac  ; really ??
                rol     dwelltmpHac
                rol     dwelltmpXac

                lda     dwelltmpLp ; period without dwell removed
                add     dwelltmpL
;                sta     dwelltmpLp  ; now 4 periods ready for next calc
                sta     dwelltmpLop
                lda     dwelltmpHp
                adc     dwelltmpH
;                sta     dwelltmpHp
                sta     dwelltmpHop
                lda     dwelltmpXp
                adc     dwelltmpX
;                sta     dwelltmpXp
                sta     dwelltmpXop

                lda     dwelltmpLop
                add     dwelltmpLac
                sta     dwelltmpLop
                lda     dwelltmpHop
                adc     dwelltmpHac
                sta     dwelltmpHop
                lda     dwelltmpXop
                adc     dwelltmpXac
                sta     dwelltmpXop

                SubDwell        ; subtract dwell

;cd6_done:
                DwellRail     ; check if negative or less than mindischarge
                DwellDiv         ; convert microseconds to 0.1ms units
                sthx    dwelldelay6
;                jmp     really_done_dwell

really_done_dwell:
;finally we've calculated everything we need to for dwell and saved it away - phew!

                brset   rotary2,EnhancedBits5,rotary_split  ; are we doing rotary split
                jmp     misc_spark_end
;****************
; Rotary trailing split
;
; first check if using a fixed split
;****************
rotary_split:
                mov     dwelltmpHp,dwelltmpHac    ;save delay for rotary
                mov     dwelltmpLp,dwelltmpLac
                lda     page
                cmp     #7
                bne     fixspl_fl
                lda     {VE_r+FixedSplit_f-flash_table7} ; load ram value
                bra     fixspl_c
fixspl_fl:      lda     FixedSplit_f
fixspl_c:
                cmp     #$03
                blo     rs_STEP_1	; Added this as MT doesnt
					; send a perfect 00T
                sta     tmp6	; else use this fixed advance
                jmp     split_lookup_done

rs_STEP_1:
        ldhx    #KPARANGEsplit_f
        sthx    tmp1
        mov     #$05,tmp3		; 6x6
        mov     kpa_n,tmp4
        jsr     tableLookup
        mov     tmp5,tmp8		; Index
        mov     tmp1,tmp9		; X1
        mov     tmp2,tmp10		; X2

rs1_STEP_2:
        ldhx    #RPMRANGEsplit_f
        sthx    tmp1
        mov     #$05,tmp3		; 6x6
        mov     rpm,tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		; Index
        mov     tmp1,tmp13		; X1
        mov     tmp2,tmp14		; X2

rs1_STEP_3:
        clrh
        ldx     #$06			; 6x6
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        rs1X
        sta     tmp15
        incx
        rs1X
        sta     tmp16
        ldx     #$06			; 6x6
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        rs1X
        sta     tmp17
        incx
        rs1X
        sta     tmp18

        jsr     VE_STEP_4
;       result in tmp6 - contains split degrees (0-255 = 0-89.5 deg)


split_lookup_done:
;special values
; 0 deg = no split, simultaneous
; >20 deg = do not fire trailing at all
        lda    tmp6
        cmp    #85T ; 20deg
        bhi    trail_off  ; now set >20deg for no trailing
        cmp    #74T ; 16deg
        bhs    sld2
        bset   rsh_s,EnhancedBits5 ; set split hysteresis bit
sld2:
        cmp    #31T ; (31T = 1 deg)
        blo    trail_simult
;        lda    dwelltmpXac
;        beq    trail_split      ; only do split if fast enough
;        ;at slow speeds < 537rpm no trailing
;        ; this is a technical limitation because the trailing split would need
;        ; re-writing using the 0.1ms spark as well. No plans to do this at the mo.
         bra    trail_split   ; changed by KC

trail_off:
        mov    #85T,tmp6   ; rail calc at 20deg, disabling handled elsewhere
        bclr   rsh_s,EnhancedBits5 ; clear split hysteresis bit
        jmp    split_calc_done

trail_simult:
        clra
        sei
        sta    splitdelH
        sta    splitdelL
        cli
        jmp    split_calc_done
; the above gives intermittent spark? so rail at 1 deg minimum
;        mov    #31T,tmp6

trail_split:
        lda     tmp6
        sub     #28T   ; remove 10 deg offset
        sta     tmp6   ; can't go neg

; now convert this split into a delay, leading to trailing
;dwelltmp?ac contains predicted period = 180 deg
;divide by 2 to get 90deg time
; already determined dwelltmpXac is zero above

        lsr    dwelltmpHac  ; not working ??
        ror    dwelltmpLac  ;

rs_mult:
;nb Sparkdlt? is equ'd to tmp17,18,19 at top
        ; Calculate time for delay angle
        ; Time for 90 deg * Angle (256=90 deg)/256
        lda     tmp6        ; split angle
        ldx     dwelltmpLac
        mul
        stx     SparkdltL
        ;don't care for A

        lda     tmp6
        ldx     dwelltmpHac
        mul
        stx     SparkdltH
        add     SparkdltL
        sta     SparkdltL
        bcc     rsm_ok
        inc     SparkdltH

rsm_ok:
        ;now we've calculated, save to working vars
        sei
        lda     SparkdltH
        sta     splitdelH
        lda     SparkdltL
        sta     splitdelL
        cli
split_calc_done:
;now do rpm based hysteresis of trailing on/off
        lda     rpm
        cmp     #7T
        blo     spcd2
        cmp     #8T
        blo     trail_hys_ck
        bset    rsh_r,EnhancedBits5 ; set rpm hysteresis bit
        bra     trail_hys_ck
spcd2:
        bclr    rsh_r,EnhancedBits5 ; clear rpm hysteresis bit
        bra     trail_dwell_kill
trail_hys_ck:
        brset   rsh_s,EnhancedBits5,misc_spark_end

trail_dwell_kill:
;make sure we don't charge the trailing coil
        clr     SparkOnleftch
        clr     SparkOnleftcl
        clr     SparkOnleftdh
        clr     SparkOnleftdl

misc_spark_end:
        rts

***************************************************************************
**
** * * * * Interrupt Section * * * * *
**
** Following interrupt service routines:
**  - Timer Overflow
**  - ADC Conversion Complete
**  - IRQ input line transistion from high to low
**  - Serial Communication received character
**  - Serial Communications transmit buffer empty (send another character)
**
***************************************************************************

;First some Macros used within the interrupt sections

$MACRO COILNEG
        brset   REUSE_FIDLE,outputpins,dslsx
        brset   rotary2,EnhancedBits5,rot2neg ; twin rotor code
        brclr   TOY_DLI,outputpins,nils	; note, Toyota Multiplex only
					; NON-inverted
        brset   coilabit,coilsel,fcnita
        brset   coilbbit,coilsel,fcnitb
        brset   coilcbit,coilsel,fcnitc
fcnita:
        bclr    coilb,portc
        bclr    wled,portc
        bra     dslsa
fcnitb:
        bset    coilb,portc
        bclr    wled,portc
        bra     dslsa
fcnitc:
        bclr    coilb,portc
        bset    wled,portc
        bra     dslsa
rot2neg:
        brset   rotaryFDign,feature1,fireFD
        brset   coilcbit,coilsel,rot2cn
        brset   coildbit,coilsel,rot2dn
;either A or B both fire the single leading coil on LED17
        bra     dslsa
rot2cn:
        bclr    wled,portc   ; select
        bset    coilb,portc
        bra     cn_end
rot2dn:
        bset    wled,portc
        bset    coilb,portc
        bra     cn_end
nils:					; normal sparking non inverted
        brset   coilabit,coilsel,dslsa
        brset   coilbbit,coilsel,dslsb
        brset   coilcbit,coilsel,dslsc
        brset   coildbit,coilsel,dslsd
        brset   coilebit,coilsel,dslse
        brset   coilfbit,coilsel,dslsf
        bra     cn_end			; should never get here

fireFD:
	brset	coilcbit,coilsel,dslsb
	brset	coildbit,coilsel,dslsc

dslsa:
        bset    coila,portc		; Set spark on
        bra     cn_end

dslsb:
        bset    coilb,portc		; Set spark on
        bra     cn_end
dslsc:
        bset    wled,portc		; Set spark on
        bra     cn_end
dslsd:
        bset    output3,portd		; Set spark on
        bra     cn_end
dslse:
        bset    pin10,portc		; Set spark on
        bra     cn_end
dslsf:
        bset    knockin,portd		; Set spark on
        bra     cn_end
dslsx:
        bset    iasc,porta
cn_end:
$MACROEND

***************************************************************************

$MACRO COILPOS
        brset   REUSE_FIDLE,outputpins,ilsox
        brset   rotary2,EnhancedBits5,rot2pos
					; note no Toyota, because
					; never inverted - ??? is this right
        brset   coilabit,coilsel,ilsoa
        brset   coilbbit,coilsel,ilsob
        brset   coilcbit,coilsel,ilsoc
        brset   coildbit,coilsel,ilsod
        brset   coilebit,coilsel,ilsoe
        brset   coilfbit,coilsel,ilsof
        bra     fc_end			; should never get here
rot2pos:
        brset   rotaryFDign,feature1,chargeFD
        brset   coilcbit,coilsel,rot2cp
        brset   coildbit,coilsel,rot2dp
;either A or B both fire the single leading coil on LED17
        bra     ilsoa
rot2cp:
;        bclr    wled,portc   ; select. Commented by KC, b/c there's no
			      ; rotary inverted... if using stock hardware.
        bclr    coilb,portc
        bra     fc_end
rot2dp:
;        bset    wled,portc
        bclr    coilb,portc
        bra     fc_end
chargeFD:
	brset	coilcbit,coilsel,ilsoc
	brset	coildbit,coilsel,ilsob
ilsoa:
        bclr    coila,portc
        bra     fc_end
ilsob:
        bclr    coilb,portc
        bra     fc_end
ilsoc:
        bclr    wled,portc
        bra     fc_end
ilsod:
        bclr    output3,portd
        bra     fc_end
ilsoe:
        bclr    pin10,portc
        bra     fc_end
ilsof:
        bclr    knockin,portd
        bra     fc_end
ilsox:
        bclr    iasc,porta
fc_end:
$MACROEND

***************************************************************************
**
** Timer Rollover - Occurs every 1/10 of a millisecond - main timing clock
**
**
** Generate time rates:
**  1/10 milliseconds
**  1 milliseconds
**  1/10 seconds
**  seconds
**
** Also, in 1/10 millisecond section, turn on/off injector and
**  check RPM for stall condition
** In milliseconds section, fire off ADC conversion for next channel (5 total),
**  and wrap back when all channels done
**
***************************************************************************

$MACRO CalcDwellspk
; This is now one massive macro. There is a section of code depending on how many spark
; outputs there are - 1,2,3,4,5,6
;022g - macro is now used to apply dwelldelay value calculated in main loop.
; macro only used after spark when mainloop will??? have had time to calc since trigger
                brset   wspk,EnhancedBits4,wastedwell
;for single output dwell always use dwelldelay1
                ldhx    dwelldelay1
                brset   coilabit,coilsel,dd_a
                brset   coilbbit,coilsel,dd_b  ; surely these will never happen though
                brset   coilcbit,coilsel,dd_c
                brset   coildbit,coilsel,dd_d
; no need to consider 5th, 6th because wpsk will always be set
                bra     jdd_end		; how?
dd_a:           sthx    SparkOnLeftah	; Store time to keep output the same
                bra     jdd_end
dd_b:           sthx    SparkOnLeftbh	; Store time to keep output the same
                bra     jdd_end
dd_c:           sthx    SparkOnLeftch	; Store time to keep output the same
                bra     jdd_end
dd_d:           sthx    SparkOnLeftdh	; Store time to keep output the same
jdd_end:        jmp     dd_end

jwdwell6op:     jmp     wdwell6op
jwdwell5op:     jmp     wdwell5op

jwdwell4op:     jmp     wdwell4op
jwdwell2op:     jmp     wdwell2op

wastedwell:
;one section each for 2,3,4,5,6 outputs
;nothing needed for rotary, it's not considered wasted spark
                lda     feature8_f
                bit     #spkfopb
                bne     jwdwell6op
                bit     #spkeopb
                bne     jwdwell5op

                brset   out3sparkd,feature2,jwdwell4op ; if 4 o/ps
;check if 3rd spark output in use
;no need to check for 2nd output, wouldn't have got here otherwise (wspk above)
                brclr   REUSE_LED18,outputpins,jwdwell2op    ; want 1 } spark c
                brclr   REUSE_LED18_2,outputpins,jwdwell2op  ; want 1 }
wdwell3op:
;first off always store a 360deg dwell delay
                ldhx    dwelldelay3    ; precalculated to rail at mindischg
                brset   coilabit,coilsel,wd3a360
                brset   coilbbit,coilsel,wd3b360
                brset   coilcbit,coilsel,wd3c360
wd3a360:        sthx    SparkOnLeftah
                bra     wd3end360
wd3b360:        sthx    SparkOnLeftbh
                bra     wd3end360
wd3c360:        sthx    SparkOnLeftch
wd3end360:

;we've now set the 360deg wait, see if we can delay off previous spark (120deg)
                lda     dwelldelay1
                bne     wd3ok120
                lda     dwelldelay1+1
                cmp     #2
                blo     wd3skip120   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd3ok120:
                ldhx    dwelldelay1
                brset   coilabit,coilsel,wd3a120
                brset   coilbbit,coilsel,wd3b120
                brset   coilcbit,coilsel,wd3c120
wd3a120:        sthx    SparkOnLeftbh
                bra     wd3end120
wd3b120:        sthx    SparkOnLeftch
                bra     wd3end120
wd3c120:        sthx    SparkOnLeftah
wd3end120:
;;;;;;;;;;      jmp     dd_end ; always apply all three

wd3skip120:
;not enough time in 120deg period, see if 240deg will work
                lda     dwelldelay2
                bne     wd3ok240
                lda     dwelldelay2+1
                cmp     #2
                blo     wd3end240   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd3ok240:
                ldhx    dwelldelay2
                brset   coilabit,coilsel,wd3a240
                brset   coilbbit,coilsel,wd3b240
                brset   coilcbit,coilsel,wd3c240
wd3a240:        sthx    SparkOnLeftch
                bra     wd3end240
wd3b240:        sthx    SparkOnLeftah
                bra     wd3end240
wd3c240:        sthx    SparkOnLeftbh
wd3end240:      jmp     dd_end

;****************
wdwell2op:
;first off always store a 360deg dwell delay
                ldhx    dwelldelay2    ; precalculated to rail at mindischg
;;redundant     brset   coilabit,coilsel,wd2a360
                brset   coilbbit,coilsel,wd2b360
wd2a360:        sthx    SparkOnLeftah
                bra     wd2end360
wd2b360:        sthx    SparkOnLeftbh
wd2end360:
;consider oddfire, do not delay from previous spark
                lda     SparkConfig1_f
                bit     #M_SC1oddfire
                bne     wd2skip

;we've now set the 360deg wait, see if we can delay off previous spark (180deg)
                lda     dwelldelay1
                bne     wd2ok
                lda     dwelldelay1+1
                cmp     #2
                blo     wd2skip   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd2ok:
                ldhx    dwelldelay1
                brset   coilabit,coilsel,wd2a180
                brset   coilbbit,coilsel,wd2b180
wd2a180:        sthx    SparkOnLeftbh
                bra     wd2end180
wd2b180:        sthx    SparkOnLeftah
wd2end180:

wd2skip:        jmp     dd_end

;****************

wdwell4op:
;first off always store a 360deg dwell delay
                ldhx    dwelldelay4    ; precalculated to rail at mindischg
                brset   coilabit,coilsel,wd4a360
                brset   coilbbit,coilsel,wd4b360
                brset   coilcbit,coilsel,wd4c360
                brset   coildbit,coilsel,wd4d360
wd4a360:        sthx    SparkOnLeftah
                bra     wd4end360
wd4b360:        sthx    SparkOnLeftbh
                bra     wd4end360
wd4c360:        sthx    SparkOnLeftch
                bra     wd4end360
wd4d360:        sthx    SparkOnLeftdh
wd4end360:

;consider oddfire, do not delay from previous spark
                lda     sparkconfig1_f
                bit     #M_SC1oddfire
                bne     wd4skip90

;we've now set the 360deg wait, see if we can delay off previous spark (90deg)
                lda     dwelldelay1
                bne     wd4ok90 ; if non zero then long delay so ok
                lda     dwelldelay1+1
                cmp     #2
                blo     wd4skip90   ; check if more than 0.2ms
                ; if less, then dwell might get missed
wd4ok90:
                ldhx    dwelldelay1
                brset   coilabit,coilsel,wd4a90
                brset   coilbbit,coilsel,wd4b90
                brset   coilcbit,coilsel,wd4c90
                brset   coildbit,coilsel,wd4d90
wd4a90:        sthx    SparkOnLeftbh
                bra     wd4end90
wd4b90:        sthx    SparkOnLeftch
                bra     wd4end90
wd4c90:        sthx    SparkOnLeftdh
                bra     wd4end90
wd4d90:        sthx    SparkOnLeftah
wd4end90:
;;;       bra     dd_end
;;note! may want to change this so that intermediate periods are set too so that there
;is a smoother transition from 90deg dwell to 180deg etc.

wd4skip90:
;not enough time in 90deg period, see if 180deg will work
                lda     dwelldelay2
                bne     wd4ok180
                lda     dwelldelay2+1
                cmp     #2
                blo     wd4skip180   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd4ok180:
                ldhx    dwelldelay2
                brset   coilabit,coilsel,wd4a180
                brset   coilbbit,coilsel,wd4b180
                brset   coilcbit,coilsel,wd4c180
                brset   coildbit,coilsel,wd4d180
wd4a180:        sthx    SparkOnLeftch
                bra     wd4end180
wd4b180:        sthx    SparkOnLeftdh
                bra     wd4end180
wd4c180:        sthx    SparkOnLeftah
                bra     wd4end180
wd4d180:        sthx    SparkOnLeftbh
wd4end180:
;;      bra     dd_end

wd4skip180:
;consider oddfire, do not delay from previous spark
                lda     sparkconfig1_f
                bit     #M_SC1oddfire
                bne     wd4end270

;not enough time in 180deg period, see if 270deg will work
                lda     dwelldelay3
                bne     wd4ok270
                lda     dwelldelay3+1
                cmp     #2
                blo     wd4end270   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd4ok270:
                ldhx    dwelldelay3
                brset   coilabit,coilsel,wd4a270
                brset   coilbbit,coilsel,wd4b270
                brset   coilcbit,coilsel,wd4c270
                brset   coildbit,coilsel,wd4d270
wd4a270:        sthx    SparkOnLeftdh
                bra     wd4end270
wd4b270:        sthx    SparkOnLeftah
                bra     wd4end270
wd4c270:        sthx    SparkOnLeftbh
                bra     wd4end270
wd4d270:        sthx    SparkOnLeftch
wd4end270:
                jmp     dd_end

;*******************
; 5 spark outputs, angular names as if V10, will actually be double if 5cyl COP
;*******************
wdwell5op:
;first off always store a 360deg dwell delay
                ldhx    dwelldelay5    ; precalculated to rail at mindischg
                brset   coilabit,coilsel,wd5a360
                brset   coilbbit,coilsel,wd5b360
                brset   coilcbit,coilsel,wd5c360
                brset   coildbit,coilsel,wd5d360
                brset   coilebit,coilsel,wd5e360
wd5a360:        sthx    SparkOnLeftah
                bra     wd5end360
wd5b360:        sthx    SparkOnLeftbh
                bra     wd5end360
wd5c360:        sthx    SparkOnLeftch
                bra     wd5end360
wd5d360:        sthx    SparkOnLeftdh
                bra     wd5end360
wd5e360:        sthx    SparkOnLefteh
wd5end360:
;we've now set the 360deg wait, see if we can delay off previous spark (72deg)
                lda     dwelldelay1
                bne     wd5ok72 ; if non zero then long delay so ok
                lda     dwelldelay1+1
                cmp     #2
                blo     wd5skip72   ; check if more than 0.2ms
                ; if less, then dwell might get missed
wd5ok72:
                ldhx    dwelldelay1
                brset   coilabit,coilsel,wd5a72
                brset   coilbbit,coilsel,wd5b72
                brset   coilcbit,coilsel,wd5c72
                brset   coildbit,coilsel,wd5d72
                brset   coilebit,coilsel,wd5e72
wd5a72:         sthx    SparkOnLeftbh
                bra     wd5end72
wd5b72:         sthx    SparkOnLeftch
                bra     wd5end72
wd5c72:         sthx    SparkOnLeftdh
                bra     wd5end72
wd5d72:         sthx    SparkOnLefteh
                bra     wd5end72
wd5e72:         sthx    SparkOnLeftah
wd5end72:
;;;       bra     dd_end
;;note! may want to change this so that intermediate periods are set too so that there
;is a smoother transition from 72deg dwell to 144deg etc.

wd5skip72:

                lda     dwelldelay2
                bne     wd5ok144
                lda     dwelldelay2+1
                cmp     #2
                blo     wd5skip144   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd5ok144:
                ldhx    dwelldelay2
                brset   coilabit,coilsel,wd5a144
                brset   coilbbit,coilsel,wd5b144
                brset   coilcbit,coilsel,wd5c144
                brset   coildbit,coilsel,wd5d144
                brset   coilebit,coilsel,wd5e144
wd5a144:        sthx    SparkOnLeftch
                bra     wd5end144
wd5b144:        sthx    SparkOnLeftdh
                bra     wd5end144
wd5c144:        sthx    SparkOnLefteh
                bra     wd5end144
wd5d144:        sthx    SparkOnLeftah
                bra     wd5end144
wd5e144:        sthx    SparkOnLeftbh
wd5end144:
;;      bra     dd_end

wd5skip144:
;not enough time in 144deg period, see if 216deg will work
                lda     dwelldelay3
                bne     wd5ok216
                lda     dwelldelay3+1
                cmp     #2
                blo     wd5skip216   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd5ok216:
                ldhx    dwelldelay3
                brset   coilabit,coilsel,wd5a216
                brset   coilbbit,coilsel,wd5b216
                brset   coilcbit,coilsel,wd5c216
                brset   coildbit,coilsel,wd5d216
                brset   coilebit,coilsel,wd5e216
wd5a216:        sthx    SparkOnLeftdh
                bra     wd5end216
wd5b216:        sthx    SparkOnLefteh
                bra     wd5end216
wd5c216:        sthx    SparkOnLeftah
                bra     wd5end216
wd5d216:        sthx    SparkOnLeftbh
                bra     wd5end216
wd5e216:        sthx    SparkOnLeftch
wd5end216:
;      bra     dd_end

wd5skip216:
;not enough time in 216deg period, see if 288deg will work
                lda     dwelldelay4
                bne     wd5ok288
                lda     dwelldelay4+1
                cmp     #2
                blo     wd5skip288   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd5ok288:
                ldhx    dwelldelay4
                brset   coilabit,coilsel,wd5a288
                brset   coilbbit,coilsel,wd5b288
                brset   coilcbit,coilsel,wd5c288
                brset   coildbit,coilsel,wd5d288
                brset   coilebit,coilsel,wd5e288
wd5a288:        sthx    SparkOnLefteh
                bra     wd5end288
wd5b288:        sthx    SparkOnLeftah
                bra     wd5end288
wd5c288:        sthx    SparkOnLeftbh
                bra     wd5end288
wd5d288:        sthx    SparkOnLeftch
                bra     wd5end288
wd5e288:        sthx    SparkOnLeftdh
wd5end288:
wd5skip288:
                jmp     dd_end

;*******************
; 6 spark outputs, angular names as if V12, will actually be double if 6cyl COP
;*******************
wdwell6op:
;first off always store a 360deg dwell delay
                ldhx    dwelldelay6    ; precalculated to rail at mindischg
;                brset   coilabit,coilsel,wd6a360
                brset   coilbbit,coilsel,wd6b360
                brset   coilcbit,coilsel,wd6c360
                brset   coildbit,coilsel,wd6d360
                brset   coilebit,coilsel,wd6e360
                brset   coilfbit,coilsel,wd6f360
wd6a360:        sthx    SparkOnLeftah
                bra     wd6end360
wd6b360:        sthx    SparkOnLeftbh
                bra     wd6end360
wd6c360:        sthx    SparkOnLeftch
                bra     wd6end360
wd6d360:        sthx    SparkOnLeftdh
                bra     wd6end360
wd6e360:        sthx    SparkOnLefteh
                bra     wd6end360
wd6f360:        sthx    SparkOnLeftfh
wd6end360:
;consider oddfire, do not delay from previous spark
                lda     sparkconfig1_f
                bit     #M_SC1oddfire
                bne     wd6skip60

;we've now set the 360deg wait, see if we can delay off previous spark (60deg)
                lda     dwelldelay1
                bne     wd6ok60 ; if non zero then long delay so ok
                lda     dwelldelay1+1
                cmp     #5
                blo     wd6skip60   ; check if more than 0.2ms
                ; if less, then dwell might get missed
wd6ok60:
                ldhx    dwelldelay1
                brset   coilabit,coilsel,wd6a60
                brset   coilbbit,coilsel,wd6b60
                brset   coilcbit,coilsel,wd6c60
                brset   coildbit,coilsel,wd6d60
                brset   coilebit,coilsel,wd6e60
                brset   coilfbit,coilsel,wd6f60
wd6a60:         sthx    SparkOnLeftbh
                bra     wd6end60
wd6b60:         sthx    SparkOnLeftch
                bra     wd6end60
wd6c60:         sthx    SparkOnLeftdh
                bra     wd6end60
wd6d60:         sthx    SparkOnLefteh
                bra     wd6end60
wd6e60:         sthx    SparkOnLeftfh
                bra     wd6end60
wd6f60:         sthx    SparkOnLeftah
wd6end60:
;;;       bra     dd_end
;;note! may want to change this so that intermediate periods are set too so that there
;is a smoother transition from 60deg dwell to 120deg etc.

wd6skip60:
;not enough time in 60deg period, see if 120deg will work
                lda     dwelldelay2
                bne     wd6ok120
                lda     dwelldelay2+1
                cmp     #5
                blo     wd6skip120   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd6ok120:
                ldhx    dwelldelay2
                brset   coilabit,coilsel,wd6a120
                brset   coilbbit,coilsel,wd6b120
                brset   coilcbit,coilsel,wd6c120
                brset   coildbit,coilsel,wd6d120
                brset   coilebit,coilsel,wd6e120
                brset   coilfbit,coilsel,wd6f120
wd6a120:        sthx    SparkOnLeftch
                bra     wd6end120
wd6b120:        sthx    SparkOnLeftdh
                bra     wd6end120
wd6c120:        sthx    SparkOnLefteh
                bra     wd6end120
wd6d120:        sthx    SparkOnLeftfh
                bra     wd6end120
wd6e120:        sthx    SparkOnLeftah
                bra     wd6end120
wd6f120:        sthx    SparkOnLeftbh
wd6end120:
;;      bra     dd_end

wd6skip120:
;consider oddfire, do not delay from previous spark
                lda     sparkconfig1_f
                bit     #M_SC1oddfire
                bne     wd6skip180

;not enough time in 120deg period, see if 180deg will work
                lda     dwelldelay3
                bne     wd6ok180
                lda     dwelldelay3+1
                cmp     #5
                blo     wd6skip180   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd6ok180:
                ldhx    dwelldelay3
                brset   coilabit,coilsel,wd6a180
                brset   coilbbit,coilsel,wd6b180
                brset   coilcbit,coilsel,wd6c180
                brset   coildbit,coilsel,wd6d180
                brset   coilebit,coilsel,wd6e180
                brset   coilfbit,coilsel,wd6f180
wd6a180:        sthx    SparkOnLeftdh
                bra     wd6end180
wd6b180:        sthx    SparkOnLefteh
                bra     wd6end180
wd6c180:        sthx    SparkOnLeftfh
                bra     wd6end180
wd6d180:        sthx    SparkOnLeftah
                bra     wd6end180
wd6e180:        sthx    SparkOnLeftbh
                bra     wd6end180
wd6f180:        sthx    SparkOnLeftch
wd6end180:
                bra     dd_end

wd6skip180:
;not enough time in 180deg period, see if 240deg will work
                lda     dwelldelay4
                bne     wd6ok240
                lda     dwelldelay4+1
                cmp     #5
                blo     wd6skip240   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd6ok240:
                ldhx    dwelldelay4
                brset   coilabit,coilsel,wd6a240
                brset   coilbbit,coilsel,wd6b240
                brset   coilcbit,coilsel,wd6c240
                brset   coildbit,coilsel,wd6d240
                brset   coilebit,coilsel,wd6e240
                brset   coilfbit,coilsel,wd6f240
wd6a240:        sthx    SparkOnLefteh
                bra     wd6end240
wd6b240:        sthx    SparkOnLeftfh
                bra     wd6end240
wd6c240:        sthx    SparkOnLeftah
                bra     wd6end240
wd6d240:        sthx    SparkOnLeftbh
                bra     wd6end240
wd6e240:        sthx    SparkOnLeftch
                bra     wd6end240
wd6f240:        sthx    SparkOnLeftdh
wd6end240:
;                jmp     dd_end

wd6skip240:
;consider oddfire, do not delay from previous spark
                lda     sparkconfig1_f
                bit     #M_SC1oddfire
                bne     wd6skip300

;not enough time in 240deg period, see if 300deg will work
                lda     dwelldelay5
                bne     wd6ok300
                lda     dwelldelay5+1
                cmp     #5
                blo     wd6skip300   ; check if more than 0.2ms
                ; if less then dwell might get missed
wd6ok300:
                ldhx    dwelldelay5
                brset   coilabit,coilsel,wd6a300
                brset   coilbbit,coilsel,wd6b300
                brset   coilcbit,coilsel,wd6c300
                brset   coildbit,coilsel,wd6d300
                brset   coilebit,coilsel,wd6e300
                brset   coilfbit,coilsel,wd6f300
wd6a300:        sthx    SparkOnLefteh
                bra     wd6end300
wd6b300:        sthx    SparkOnLeftfh
                bra     wd6end300
wd6c300:        sthx    SparkOnLeftah
                bra     wd6end300
wd6d300:        sthx    SparkOnLeftbh
                bra     wd6end300
wd6e300:        sthx    SparkOnLeftch
                bra     wd6end300
wd6f300:        sthx    SparkOnLeftdh
wd6end300:

wd6skip300:


dd_end:
$MACROEND

********************************************************************************
** EDIS control section up here to permit relative jumps in 0.1ms section
** 2nd EDIS output control
********************************************************************************

edis2_fire:
        brclr   REUSE_LED19,outputpins,go_inj_fire2	; if 2nd output not
					;enabled then skip
        ldhx    SparkOnLeftah		; skip if already zero
        beq     go_inj_fire2

        aix     #-1			; is it time to start 2nd SAW
        sthx    SparkOnLeftah
        cphx    #0
        bne     go_inj_fire2		; skip if non-zero

; start 2nd SAW here and set timer to turn it off
        clr     coilsel
        bset    coilbbit,coilsel	; only support 2nd spark output
        ; assume that other outputs cannot get set
        bset    sparkon,revlimbits	; note that spark is on

        brset   invspk,EnhancedBits4,InvSparkOn2
        bset    coilb,portc
        bra     set_saw_on2
InvSparkOn2:
        bclr    coilb,portc

set_saw_on2:				; now set timer for SAW on period
					; using sawh/l calculated in main loop

; Calculate width of SAW pulse
; grab current timer values - uses same variable as squirt section below.
; But no  cli  so ok
;
        lda     T2CNTL			; unlatch low byte
        ldx     T2CNTH
        stx     T2CurrH			; Save current counter value
        lda     T2CNTL
        sta     T2CurrL			; Save current counter value

        brclr   crank,engine,SAW_COUNTER2
        lda     feature4_f
        bit     #multisparkb
        beq     SAW_COUNTER2
;        brclr   multispark,feature4,SAW_COUNTER2
; at crank we always send 2048us as calibration and multi-spark init
        lda     #$00
        sta     sawl
        lda     #$08
        sta     sawh

;Read the calculated width and store in timer
SAW_COUNTER2:
        lda     sawl
        add     T2CurrL
        tax
        lda     sawh
        adc     T2CurrH
        sta     T2CH1H
        stx     T2CH1L

        bclr    SparkTrigg,Sparkbits	; Clear spark trigg. Next time we get int turn off SAW

        bclr    TOF,T2SC1		; clear any pending interrupt
        bset    TOIE,T2SC1		; Enable timer interrupt
go_inj_fire2:
        jmp     INJ_FIRE_CTL
**** end of 2nd EDIS bit **
edis2_fire_a:
        bra     edis2_fire		; to permit relative jump below

******************************************************************************
;some timerroll equates - local variables that can only be used with irqs blocked
;we'll start using itmp00 - itmp0f in here

TIMERROLL:

                 bclr    checkbit,EnhancedBits5
                 pshh			; Stack h
                lda     T2SC0		; ack the interrupt
                bclr    CHxF,T2SC0	; clear pending bit
                lda     T2CNTL		; unlatch any previous read (added JSM)

;* revised section - from Dan Hiebert's TFI code
                 ldhx    T2CH0H		; Load index register with value
					; in TIM2 CH0
					; register H:L (output compare value)
                 aix     #100T		; Add decimal 100 (100 uS)
                 sthx    T2CH0H		; Copy result to TIM2 CH0 register
					;(new output compare value)
;* end revised section

;if we are stalled don't increment these or we might skip the wheeldecoder
        brclr    running,engine,TIMER_DONE

        inc      lowresL		; 16bit 0.1ms timer
        bne      TIMER_DONE
        inc      lowresH
					; otherwise done
TIMER_DONE:
                bclr     TOIE,T2SC0	; disable 0.1ms interrupt to
					; prevent re-entry
                cli                     ; allow interrupts during the large
					; chunk of code below. This
					; significantly reduces spark
                                        ; jitter. Without it there is
					; ~6deg at 9000rpm
                                        ; only really want IRQ to be allowed

***************************************************************************
***************** 0.1 millisecond section ********************************
***************************************************************************

        brset    config_error,feature2,error_exit
        inc      mms			; bump up 0.1 millisec variable

; Added for boost control - Hope it doesnt screw up the timer -
; James will kill me if it does
        brclr    BoostControl,feature2,bcActDone
        inc      mmsDiv			; Counts up to bcFreqDiv.
        lda      mmsDiv			; Counter at multiples of 0.1 ms
        cmp      bcFreqDiv_f		; 1=39.1 Hz, 2=19.5, 3=13.0 and so on.
        blo      bcActDone
        clr      mmsDiv
        inc      bcActClock
        lda      bcActClock
bcActDone:

        brset   TFI,personality,j_tfi_spk
        brset   EDIS,personality,go_inj_fire3
        brset   MSNEON,personality,neon_irq
        brset   WHEEL,personality,wheel_irq

        lda     personality
        bne     no_wd_trig              ; any other spark modes skip over 2nd irq bits
        jmp     INJ_FIRE_CTL		; skip this section if not
					; controlling spark
error_exit:
        pulh
        rti

go_inj_fire3:
        brset   DUALEDIS,personality,edis2_fire_a
        jmp     INJ_FIRE_CTL

j_tfi_spk:
        jmp     tfi_spk			; branch to next chunk

neon_irq:
; Neon crank decoding
; See if we have seen a rising IRQ edge and save it

        bil     no_wd_trig

        brset   rise,sparkbits,no_wd_trig	; only store the rising edge
        bset    rise,sparkbits

        mov    lowresL,SparkTempL
        mov    lowresH,SparkTempH

        bra    no_wd_trig        ; we've done the Neon bit


wheel_irq:
;more bloat... check for second "reset" spark input
      brclr   wd_2trig,feature1,no_wd_trig

      lda     dtmode_f
      bit     #trig2risefallb
      bne     wd_risefall      ; do rising & falling

      bit     #trig2fallb
      bne     wd_inv

;on rising edge of input reset wheelcount to zero
      brset   rise,sparkbits,wd_rise ; already found so see if ready to clear
;not already in high state so see if pin has been asserted
      brclr   pin11,portc,no_wd_trig   ; inactive
;we've found a rising edge of pin11, so clear wheelcount (tooth zero) and set rise bit
      bset    rise,sparkbits           ; this bit used to monitor the edge of the input
      bra     wd_2_flag
wd_rise:
      brset   pin11,portc,no_wd_trig
      bclr    rise,sparkbits
      bra     no_wd_trig

wd_inv:
;on falling edge of input reset wheelcount to zero
      brset   rise,sparkbits,wd_fall ; already found so see if ready to clear
;not already in high state so see if pin has been asserted
      brclr   pin11,portc,no_wd_trig   ; inactive
      bset    rise,sparkbits
      bra     no_wd_trig
wd_fall:
      brset   pin11,portc,no_wd_trig
;we've found a falling edge of pin11, so clear wheelcount (tooth zero) and set rise bit
      bclr    rise,sparkbits           ; this bit used to monitor the edge of the input
      bra     wd_2_flag

wd_risefall:
;on rising and falling edge of input reset wheelcount to zero
      brset   rise,sparkbits,wd_rf1 ; was high
      brclr   pin11,portc,no_wd_trig   ; still low
      bset    rise,sparkbits
      bra     wd_2_flag

wd_rf1:
      brset   pin11,portc,no_wd_trig ; still high
      bclr    rise,sparkbits
;      bra     wd_2_flag

wd_2_flag:
      bset    trigger2,EnhancedBits6   ; flag the trigger

no_wd_trig:

; now with multi-dwell check them all each time (how much delay to
; 0.1ms routine?) this routine is flawed but only slightly - when one
; coil gets to zero those below don't get decremented so will be 0.1ms
; late. a jsr would be nice.
;
        sei				; no ints while we are
					; stealing this variable
        mov     coilsel,SparkCarry; temporary

	brclr	indwell,EnhancedBits4,sin_a
	brset	rotary2,EnhancedBits5,clr_a_b

sin_a:
        ldhx    SparkOnLeftah
        beq     sin_b
        aix     #-1			; is it time to start charging
        sthx    SparkOnLeftah
        cphx    #0
        bne     sin_b
        clr     coilsel
        bset    coilabit,coilsel
        bra     lowspdspk
sin_b:
        ldhx    SparkOnLeftbh
        beq     sin_c
        aix     #-1			; is it time to start charging
        sthx    SparkOnLeftbh
        cphx    #0
        bne     sin_c
        clr     coilsel
        bset    coilbbit,coilsel
        bra     lowspdspk
clr_a_b:
	ldhx	#0
	sthx	SparkOnLeftah
	sthx	SparkOnLeftbh
sin_c:
        ldhx    SparkOnLeftch
        beq     sin_d
        aix     #-1			; is it time to start charging
        sthx    SparkOnLeftch
        cphx    #0
        bne     sin_d
        clr     coilsel
        bset    coilcbit,coilsel
        bra     lowspdspk
sin_d:
        ldhx    SparkOnLeftdh
        beq     sin_e
        aix     #-1			; is it time to start charging
        sthx    SparkOnLeftdh
        cphx    #0
        bne     sin_e
        clr     coilsel
        bset    coildbit,coilsel
        bra     lowspdspk

sin_e:
        ldhx    SparkOnLefteh
        beq     sin_f
        aix     #-1			; is it time to start charging
        sthx    SparkOnLefteh
        cphx    #0
        bne     sin_f
        clr     coilsel
        bset    coilebit,coilsel
        bra     lowspdspk
sin_f:
        ldhx    SparkOnLeftfh
        beq     j_CSL
        aix     #-1			; is it time to start charging
        sthx    SparkOnLeftfh
        cphx    #0
        bne     j_CSL
        clr     coilsel
        bset    coilfbit,coilsel
        bra     lowspdspk

j_CSL:
        cli
        jmp     CHECK_SPARK_LATE

go_inj_fire:
        jmp     INJ_FIRE_CTL


lowspdspk:
                brclr   rotary2,EnhancedBits5,chkindwell
                brset   coilabit,coilsel,chkindwell
                brset   coilbbit,coilsel,chkindwell
                lda     splitdelH
                cmp     #$FF     ; if trailing is OFF then don't charge coil
                beq     blssd
lss2:
	; add check for rotary, which checks for coilcbit/coildbit
chkcoilcd: ; make sure that we dwell coil c/d even if indwell.
	brset	coilcbit,coilsel,dodwell
	brset	coildbit,coilsel,dodwell
chkindwell:
        brset   indwell,EnhancedBits4,blssd	; if doing hi-res
					; dwell then don't turn on coil now
dodwell:
        bclr    sparkon,revlimbits	; spark now off
;this used to be in SPARKTIME but could have overheated ignitors
        lda     SparkCutCnt	; Check Spark Counter
        inca
        cmp     SparkCutBase_f	; How many sparks to count to
        blo     Dont_ResetCnt
        lda     #01T
Dont_ResetCnt:
        sta     SparkCutCnt	; Store new value to spark counter
        brset   sparkCut,RevLimBits,blssd	; If in spark cut
					; mode jump past spark

        brset   invspk,EnhancedBits4,lsspk_inv ; check if noninv or inv spark
        COILPOS				; charge coil for non-inverted
blssd:
        bra     lsspk_done
lsspk_inv:
        COILNEG				; charge coil for inverted
lsspk_done:
        mov     SparkCarry,coilsel; put it back as we found it
        cli

CHECK_SPARK_LATE:
        brclr   SparkLSpeed,SparkBits,jINJ_FIRE_CTL	; Skip if not low
					; speed sparking
        brclr   sparktrigg,sparkbits,jINJ_FIRE_CTL	; Skip if spark
					; already done

;        brclr   crank,engine,timebased	; if not cranking don't do
;					; irq_spark (NEW 021v)
;Phil R reports problems with this, so try cant_crank instead
;this will give a 1-2 second delay before timebased is used
; hopefully this will not be a problem
        brset   cant_crank,EnhancedBits2,timebased

        lda     SparkConfig1_f		; check if noninv or inv spark
        bit     #M_SC1TimCrnk		; Check if spark on time or IRQ
					; return (SparkConfig1 already in A)
        beq     IRQ_SPARK

timebased:
        ;Check if time for spark
        lda     rpmch
        cmp     SparkDelayH
        bne     jINJ_FIRE_CTL
        lda     rpmcl
        cmp     SparkDelayL
        bne     jINJ_FIRE_CTL
        bra     ChkHold
;**
jINJ_FIRE_CTL:				; convenient place to branch to
        jmp     INJ_FIRE_CTL
;**

IRQ_SPARK:
        brset   MSNEON,personality,irq_spark_neon
        brset   WHEEL,personality,irq_spark_neon
        bil     jINJ_FIRE_CTL		; IRQ still low? then skip

ChkHold:
        bclr    sparktrigg,sparkbits	; No more sparks for this IRQ
        brset   MSNEON,personality,DoSparkLSpeed
        brset   WHEEL,personality,DoSparkLSpeed	; no hold off on wheel decoder
        lda     wheelcount		; (HoldSpark)
					; Check if spark is held (after
					; stall and restart)
        beq     DoSparkLSpeed
        dec     wheelcount		; (HoldSpark)
					; One spark has been held, x to go
        jmp     INJ_FIRE_CTL

; This will not work with wheel decoder, need to use a flag
;        Treat end of third pulse as trigger return
irq_spark_neon:
        brclr   trigret,SparkBits,jINJ_FIRE_CTL
        bclr    trigret,SparkBits	; clear it now
        bclr    sparktrigg,sparkbits	; No more sparks for this IRQ

DoSparkLSpeed:
        bset    sparkon,revlimbits	; spark now on

        brset   invspk,EnhancedBits4,dosls_inv
        COILNEG				; macro = fire coil for non-inverted
        bra     dosls_done
dosls_inv:
        COILPOS				; macro = fire coil for inverted
dosls_done:
; changed - low speed and dwell control, schedule dwell at same time
; as we schedule the spark to maintain a consistent dwell
;
        brset   dwellcont,feature7,b_INJFC2	; don't schedule chg time
					; here (low speed)
        brset   min_dwell,feature2,b_INJFC2	; don't schedule chg time here
        bra     dosls_cd
b_INJFC2:
        jmp     INJ_FIRE_CTL
dosls_fd:
; if doing dwell control, figure out when to schedule dwell.
        brclr   crank,engine,dosls_cd
        brset   min_dwell,feature2,b_INJFC2	; don't schedule chg time here
; in dwell mode min_dwell means turn coil to charge at trigger point,
; but this can give a very long dwell period which won't be good for IGBTs
;
dosls_cd:
        sei
        CalcDwellspk			; Calculate spark on time
        cli
b_INJFC:
        bra     INJ_FIRE_CTL

;fresh section for TFI spark to keep things clearer
TFI_spk:
        ;if tfi & sparkon & low speed & irq high then follow
; ??? next line irrelevant ??? commented 027b 20th Nov 05
;        brclr   sparkon,revlimbits,INJ_FIRE_CTL	; if output not active then
					; skip
;        brclr   sparktrigg,sparkbits,INJ_FIRE_CTL	; if sparktrigg???
					; not active then skip
        brclr   SparkLSpeed,Sparkbits,tfi_fast	; if not slow then do high
					; speed calc
        bil     INJ_FIRE_CTL		; if IRQ still low then skip
        bra     tfispkoff		; irq has risen, de-activate output

tfi_fast:
        ; if high speed only need to worry about trailing (rising) edge
	; of output as the firing (falling) edge of the output is done
	; by the hi-res timer section
        ;
        ldhx    SparkOnLeftah
        beq     INJ_FIRE_CTL		; shouldn't happen, but just in case
        aix     #-1
        sthx    SparkOnLeftah
        cphx    #0
        bne     INJ_FIRE_CTL

tfispkoff:
        bclr    sparkon,revlimbits	; spark now off
        ; with TFI as envisaged it only really makes sense to have one
	; kind of wiring but keep inverted/non-inverted. Only one output
        ;

        brclr   invspk,EnhancedBits4,tfioutoff
;inverted
        brset   REUSE_FIDLE,outputpins,tfiif
        bset    coila,portc
        bra     INJ_FIRE_CTL
tfiif:
        bset    iasc,porta
        bra     INJ_FIRE_CTL

tfioutoff:
        brset   REUSE_FIDLE,outputpins,tfiof
        bclr    coila,portc
        bra     INJ_FIRE_CTL
tfiof:
        bclr    iasc,porta
;        bra     INJ_FIRE_CTL

INJ_FIRE_CTL:
;======== Injector Firing Control ========
;===== Main Injector Control Logic =======
        brset    sched1,squirt,NEW_SQUIRT1
INJF1:
        brset    sched2,squirt,NEW_SQUIRT2
INJF2:
        brset    firing1,squirt,CHK_DONE_1
INJF3:
        brset    firing2,squirt,CHK_DONE_2JMP
        jmp      inj2done

;=== Injector #1 - Start New Injection ===
NEW_SQUIRT1:
        bset     firing1,squirt		; Turn on "firing" bit
        bclr     sched1,squirt		; Turn off schedule bit (is
					; now current operation)
        bset     inj1,squirt
        clr      pwrun1
        brset    REUSE_LED17,outputpins,nsq1
        bset     sled,portc		; squrt LED is ON
nsq1:
        mov      #$00,T1CH0H
        lda      INJPWM_f1
        sta      T1CH0L
	bset	 7,PORTA		; ** Flyback Damper - turn on X0
					; for Inj1
No_FlyBk:
        bclr     inject1,portd		; ^* * * Turn on Injector #1
					; (inverted drive)
	bra	 INJF1

;=== Injector #2 - Start New Injection ===
NEW_SQUIRT2:
        bset     firing2,squirt		; Turn on "firing" bit
        bclr     sched2,squirt		; Turn off schedule bit (is now
					; current operation)
        bset     inj2,squirt
        clr      pwrun2
        brset    REUSE_LED17,outputpins,nsq2
        bset     sled,portc		; squrt LED is ON
nsq2:
        mov      #$00,T1CH1H
        lda      DTmode_f
        bit      #alt_i2t2
        beq      nsq2single

        lda      INJPWM_f2
        bra      nsq2cont
nsq2single:
        lda      INJPWM_f1
nsq2cont:
        sta      T1CH1L
        bset     6,PORTA		; ** Flyback Damper - turn on X1
					; for Injector 2
        bclr     inject2,portd		; ^* * * Turn on Injector #2
					; (inverted drive)

         lda     feature3_f
         bit     #WaterInjb
         beq     INJF2
;        brclr    WaterInj,feature3,INJF2
        brset    water,porta,inject_water	; If water needed go to
					; inject water
	  bra	     INJF2
inject_water:
       brset  Nitrous,feature1,INJF2	; If NOS Selected dont turn on
					; water pulsed output
       bset   water2,porta		; Turn water injector on with
					; fuel inj 2
       bra    INJF2			; Carry on as normal
INJF3JMP:
       bra    INJF3
;=== Injector #1 - Check for end of Injection ===
CHK_DONE_1:
        inc      pwrun1
        lda      pwrun1
        cmp      pw1
        beq      OFF_INJ_1
	brset	 crank,engine,INJF3	; do not perform PWM limiting
					; when cranking
        lda      pwrun1
        cmp      INJPWMT_f1
        beq      PWM_LIMIT_1
	bra	 INJF3
CHK_DONE_2JMP:
        bra      CHK_DONE_2		; Jump added
OFF_INJ_1:
        bclr     firing1,squirt
        bclr     sched1,squirt
        bclr     inj1,squirt
	bclr	 7,PORTA		; ** Flyback Damper - turn off X0
        bset     inject1,portd		; ^* * * Turn Off Injector #1
					; (inverted drive)
        mov      #T1Timerstop,T1SC
        mov      #t1scx_NO_PWM,T1SC0
        mov      #Timergo_NO_INT,T1SC
;        bra      INJF3
        jmp      INJF3
PWM_LIMIT_1:
        mov      #T1Timerstop,T1SC
        mov      #T1SCX_PWM,T1SC0
        mov      #Timergo_NO_INT,T1SC
;        bra      INJF3JMP
        jmp      INJF3

;=== Injector #2 - Check for end of Injection ===
CHK_DONE_2:
        inc      pwrun2
        lda      pwrun2
        cmp      pw2
        beq      OFF_INJ_2
;	brset	 crank,engine,CHECK_RPM	; do not perform PWM limiting
					; when cranking
	brclr	 crank,engine,CKDN2
        jmp      CHECK_RPM
CKDN2:
        lda      DTmode_f
        bit      #alt_i2t2
        beq      ckd2single		; dt=0

        lda      pwrun2			; use PWM settings from second table
        cmp      INJPWMT_f2
        beq      PWM_LIMIT_2
	bra	 inj2done
ckd2single:
        lda      pwrun2			; use PWM settings from first table
        cmp      INJPWMT_f1
        beq      PWM_LIMIT_2
	bra	 inj2done

OFF_INJ_2:
        bclr     firing2,squirt
        bclr     sched2,squirt
        bclr     inj2,squirt
	bclr	 6,PORTA		; ** Flyback Damper - turn off X1
					; (for Inj 2)
        bset     inject2,portd		; ^* * * Turn Off Injector #2
					; (inverted drive)
         lda     feature3_f
         bit     #WaterInjb
         beq     Dont_Clr_Water2
;        brclr    WaterInj,feature3,Dont_Clr_Water2	; if not using water
					; then skip
        bclr     water2,porta		; Turn off water injection pulse
Dont_Clr_Water2:
        mov      #T1Timerstop,T1SC
        mov      #t1scx_NO_PWM,T1SC1
        mov      #Timergo_NO_INT,T1SC
        bra      inj2done
PWM_LIMIT_2:
        mov      #T1Timerstop,T1SC
        mov      #T1SCX_PWM,T1SC1
        mov      #Timergo_NO_INT,T1SC

inj2done:
        brset    REUSE_FIDLE,outputpins,idleActDone

*****************************************************************************
** Idle Control PWM Actuator
**
** Runs at 10000/100 = 100 Hz.  Must be before RPM check.
*****************************************************************************

idleActuator:
        brset    crank,engine,idleActOn	; if cranking then keep it
					; shut (rmd changed from off to on)
        brclr    running,engine,idleActOff	; if not running then close it
        lda      feature13_f 	; skip if on/off mode
        bit      #pwmidleb
        beq      idleActCheck

        inc      idleActClock		; Adjust idle PWM count
        lda      idleActClock
        cmp      idlefreq_f
        bne      idleActCheck
        clr      idleActClock

idleActCheck:
        lda      idleDC
        cmp      #0T
        beq      idleActOff
        cmp      idlefreq_f  ; #255T KG
        beq      idleActOn
        cmp      idleActClock
        bls      idleActOff

idleActOn:
        bset     iasc,porta
        bra      idleActDone

idleActOff:
        bclr     iasc,porta

idleActDone:

*****************************************************************************
**  Boost Controller PWM
**
**  Set bcDC to 0 (0% duty cycle) to 255 (100% DC).  PWM frequency is
**  user-defined by bcFreqDiv, see above.
**
**
**  020w3  0% = low boost, 100% = high boost  in calculations
**  can invert the output to reverse the sense
*****************************************************************************

        brclr  BoostControl,feature2,doneBoostControl
doBoostControl:
        lda     bcDC
        beq     boostOff		; Turn it off, if duty cycle is zero.
        cmp     bcActClock
        blo     boostOff

boostOn:
        lda     feature6_f
        bit     #BoostDirb
        bne     bcClrout
;        brset   BoostDir,feature6,bcClrout	; Change dir for high
					; pulsewidth reduce boost
        bra     bcSetout
boostOff:
        lda     feature6_f
        bit     #BoostDirb
        bne     bcSetout
;        brset   BoostDir,feature6,bcSetout	; Change dir for high
					; pulsewidth reduce boost
        bra     bcClrout

bcSetout:
        bset    boostP,porta
        bra     doneBoostControl

bcClrout:
        bclr    boostP,porta

doneBoostControl:

;=======Check RPM Section=====
CHECK_RPM:
        brclr    running,engine,b_ENABLE; Branch if not running
					; right now
        brset    firing1,squirt,CHK_RE_ENABLE
        brset    firing2,squirt,CHK_RE_ENABLE
        brset    REUSE_LED17,outputpins,CHK_RE_ENABLE
        bclr     sled,portc		; squrt LED is OFF - nothing
					; is injecting

CHK_RE_ENABLE:
;====== Check for re-enabling of IRQ input pulses
        lda      rpmph			; Get high byte of last rpm interval
        beq      RPMLOWBYTECHK		; If zero go ahead check for
					; half interval
        lda      rpmcl			; Check current rpm interval
        cmp      #128T			; 12.8 milliseconds is maximum
					; (JSM changed this and cause 'stumble')
        beq      REARM_IRQ		; time to re-arm IRQ
        bra      INCRPMER		; Jump around rpm half interval check

b_ENABLE: jmp    ENABLE_THE_IRQ

RPMLOWBYTECHK:
	lda	 rpmpl			; Load in the latched previous RPM value
        lsra
	cmp	 rpmcl			; Is it the same value as current RPM Counter?
	bne	 INCRPMER		; If not then jump around this

REARM_IRQ:
; Also do tacho output in here to give 50% output duty
        lda      tachconf_f
        and      #$7f
        beq      CHK_REARM
;tachoff:
        cbeqa    #1T,tachoff_x2
        cbeqa    #2T,tachoff_x3
        cbeqa    #3T,tachoff_x4
        cbeqa    #4T,tachoff_x5
        cbeqa    #5T,tachoff_out3
        cbeqa    #6T,tachoff_pin10
        bra      CHK_REARM
tachoff_x2:
        bclr     water,porta
        bra      CHK_REARM
tachoff_x3:
        bclr     water2,porta
        bra      CHK_REARM
tachoff_x4:
        bclr     output1,porta
        bra      CHK_REARM
tachoff_x5:
        bclr     output2,porta
        bra      CHK_REARM
tachoff_out3:
        bclr     output3,portd
        bra      CHK_REARM
tachoff_pin10:
        bclr     pin10,portc
        bra      CHK_REARM

CHK_REARM:
        brset    MSNEON,personality,INCRPMER	; irq always on in Neon mode
        brset    WHEEL,personality,INCRPMER	; irq always on in Wheel mode

        lda      feature6_f
        bit      #falsetrigb           ; can disable false trigger protection for testing
        bne      INCRPMER

	bset	 ACK,INTSCR		; clear out any latched interrupts
	bclr	 IMASK,INTSCR		; enable interrupts again for IRQ

INCRPMER:
        sei
        inc      rpmcl
        bne      jCHECK_MMS
        inc      rpmch
        brclr    running,engine,jCHECK_MMS	; don't do stall check if
					; not running
        lda      rpmch
        brclr    cant_crank,EnhancedBits2,incrpm_crank	; if we've fully
					; exited crank mode
        cmp      #30T			; then 0.75 seconds timeout
					; (<360rpm on a 2cyl) (was 0.25s)
        blo      jCHECK_MMS
        cli				; ok, we can be interrupted again

        bra      stall
jCHECK_MMS:      jmp  CHECK_MMS
incrpm_crank:
        cmp      #$64			; If RPMPH is 100 (or RPMPeriod =
					; 2.5 sec) then engine stalled
        blo      jCHECK_MMS
        cli				; ok, we can be interrupted again
stall:
        clr      engine			; Engine is stalled, clear all
					; in engine
        bclr     fuelp,porta		; Turn off fuel Pump
        clr      rpmch
        clr      rpmcl

        lda      #00T
        sta      TCCycles               ; If stalled then clear these 3 for Extra
        sta      TCAccel                ; fuel during cranking
        bclr     NosDcOk,EnhancedBits   ;

        lda      #$FF   ; changed 025n, was zero. Causing problems with wheel pickup?
        sta      iTimeL
        sta      iTimeH
        sta      iTimeX

        clr      pw1			; zero out pulsewidth
        clr      pw2			; zero out pulsewidth
        clr      rpm

        bclr     cant_crank,EnhancedBits2	; if we stalled we can
					; crank again

        TurnAllSpkOff			; macro to turn off all spark outputs

stall_cont:
        brset    EDIS,personality,pass_store
        lda      TriggAngle_f		; Calculate crank delay angle
        sub      CrankAngle_f
        add      #28T			; - -10 deg
        sta      DelayAngle
pass_store:
        lda      CrankAngle_f		; Update spark angle for user interface
        sta      SparkAngle
        lda      SparkHoldCyc_f		; Hold spark after stall
        sta      wheelcount		; (HoldSpark)
        brset    MSNEON,personality,wc_wheel
        brset    WHEEL,personality,wc_wheel
        bra      ENABLE_THE_IRQ
wc_wheel:
        mov     #WHEELINIT,wheelcount	; set !sync,holdoff, 3 teeth holdoff
        bclr    wsync,EnhancedBits6
        bset    whold,EnhancedBits6
        lda     #0
        sta     avgtoothh
        sta     avgtoothl

        clr     lowresH			; low res (0.1ms) timer
        clr     lowresL			;

        bset    coilabit,coilsel
        bset    coilerr,RevLimBits

ENABLE_THE_IRQ:
	bclr	 IMASK,INTSCR		; Enable IRQ

CHECK_MMS:
        cli
        lda      mms
        cmp      #$09
        bhi      MSEC			;(was #$0A  beq)
        jmp      RTC_DONE

****************************************************************************
********************* millisecond section ********************************
****************************************************************************

MSEC:
;        brset     egoIgnCount,feature1,No_Ego_mSec	; Are we using mSec
					; for ego counter?
        lda       feature14_f1
        bit       #egoIgnCountb
        bne       No_Ego_mSec
        inc       egocount		; Increment EGO step counter

No_Ego_mSec:

        inc      ms			; bump up millisec
        clr      mms

        brclr    REUSE_LED18,outputpins,FIRE_ADC	; only do this if
					; using as IRQ monitor
        brset    REUSE_LED18_2,outputpins,FIRE_ADC	; not if spark c
        bil      IRQ_LOW		; Check if IRQ pin low
        bclr     wled,portc		; Turn OFF IRQ led

        bra      FIRE_ADC

IRQ_LOW:
        brset    MSNEON,personality,FIRE_ADC	; irrelevant
        brset    WHEEL,personality,FIRE_ADC	; irrelevant
        bset     wled,portc		; Turn ON IRQ led (in case of
					; bouncing points or what ever)

FIRE_ADC:
; Fire off another ADC conversion, channel is pointed to by ADSEL
	lda	adsel
	ora	#%01000000
	sta	adscr

        inc      bcCtlClock

MSDONE:
***************************************************************************
********************* 1/100 second section ********************************
***************************************************************************
        lda      ms
        cbeqa    #00,one00th    ; surely there's a better/quicker way than this?
        cbeqa    #10T,one00th
        cbeqa    #20T,one00th
        cbeqa    #30T,one00th
        cbeqa    #40T,one00th
        cbeqa    #50T,one00th
        cbeqa    #60T,one00th
        cbeqa    #70T,one00th
        cbeqa    #80T,one00th
        cbeqa    #90T,one00th
        bra      end100th

one00th:
        brclr   Launch,portd,nol_timer		; Button is pressed so skip timer
        lda     n2olaunchdel
        beq     nol_timer               ; already zero
        sub     #1
        sta     n2olaunchdel
nol_timer:

;        ;do similar for nitrous fuel hold on
;        brclr   ?????,????,non2o_timer		; Nitrous on so skip timer
;        lda     n2ohold
;        beq     non2o_timer            ; already zero
;        sub     #1
;        sta     n2ohold
;non2o_timer:

end100th:
        lda      ms
        cmp      #$64
        blo      RTC_DONEJMP
***************************************************************************
********************* 1/10 second section *********************************
***************************************************************************

ONETENTH:
        clr      ms
;see if need to restart tooth logger
        lda      page
        cbeqa    #$F0,restart_F0
        cbeqa    #$F1,restart_F1
        bra      oneten_notlog

restart_F0:
        brset    toothlog,EnhancedBits5,oneten_notlog
        lda      txcnt
        bne      oneten_notlog   ; if sending data then do not restart
        bset     toothlog,EnhancedBits5    ; turn logger back on (after send)
        bclr     triglog,EnhancedBits5    ; turn logger back on (after send)
        bra      oneten_notlog

restart_F1:
        brset    triglog,EnhancedBits5,oneten_notlog
        lda      txcnt
        bne      oneten_notlog   ; if sending data then do not restart
        bset     triglog,EnhancedBits5    ; turn logger back on (after send)
        bclr     toothlog,EnhancedBits5    ; turn logger back on (after send)
        bra      oneten_notlog

oneten_notlog:
        inc      tenth
        inc      Out3Timer
        lda      rpm
        sta      rpmlast

        lda      ST2Timer
        beq      ST2Timer_zero
        dec      ST2Timer
ST2Timer_zero:
        lda     VE3Timer		; VE Table3 delay timer
        beq     VE3Timer_zero
        dec     VE3Timer
VE3Timer_zero:
       brset   UseVE3,EnhancedBits,No_VE3_delay	; Are we running from VE3?
       lda     VE3Delay_f
       sta     VE3Timer
No_VE3_delay:
        brclr   NosIn,portd,No_St2Delay
        lda     Spark2Delay_f		; If input not low reset ST2
					; delay timer
        sta     ST2Timer
No_St2Delay:

        brset    taeIgnCount,feature1,No_TPSCount
        inc      tpsaclk

; Save current TPS reading in last_tps variable to compute TPSDOT
; in acceleration enrichment section

       lda     feature4_f
       bit     #KpaDotSetb
       beq     tps_dot_mode
;       brclr   KpaDotSet,feature4,tps_dot_mode	; If not in KPA dot mode
					;jump past KPa settings
       lda     kpa
       bra     Kpa_Dot_Mode
;******
RTC_DONEJMP:
       jmp     RTC_DONE
;******
tps_dot_mode:
       lda      tps
Kpa_Dot_Mode:
       sta      TPSlast

No_TPSCount:

; Check Magnus rev limit times

        lda      SRevLimTimeLeft	; Check if time left already zero
        beq      TimeLeft
        dec      SRevLimTimeLeft	; Count down time left
        bne      TimeLeft		; Time left done
        bset     RevLimHSoft,RevLimBits	; Set soft rev limiter fuel cut bit
TimeLeft:

        lda      tenth
        cmp      #$0A
        blo      RTC_DONE

****************************************************************************
********************** seconds section ***********************************
****************************************************************************
SECONDS:
        inc      OverRunTime

	brclr	 IdleAdvTimeOK,EnhancedBits6,knock_timer_checks
	lda	 idlAdvHld
	inca
	sta	 idlAdvHld

knock_timer_checks:
        lda      KnockTimLft		; Load the knock timer
        cmp      #00T
        beq      Secs			; If its zero carry on with seconds
        deca				; If not dec it
        sta      KnocktimLft
Secs:
        lda      feature10_f5
        bit      #ASEIgnCountb
        beq      sec_cont
        inc      ASEcount
sec_cont:
; crank mode inhibit
; make a 1-2 second delay
; if running and !cranking and !cant_delay then set cant_delay
; if running and !cranking and cant_delay then set cant_crank
; else clear cant_delay
        brset    crank,engine,cant_off
        brclr    running,engine,cant_off
        brset    cant_delay,EnhancedBits2,cant_set
        bset     cant_delay,EnhancedBits2
        bra      sec_fin
cant_set:
        bset     cant_crank,EnhancedBits2
        bra      sec_fin
cant_off:
        bclr     cant_delay,EnhancedBits2
sec_fin:
        clr      tenth
        inc      secl			; bump up second count
        bne      RTC_DONE
        inc      sech

RTC_DONE:
; now check that we haven't already missed the target
        sei
        lda     T2CNTL ; unlatch any previous read
        lda     T2CNTH
        sta     itmp00
        lda     T2CNTL
        sta     itmp01

        lda     T2CH0L
        sub     itmp01
        sta     itmp03
        lda     T2CH0H
        sbc     itmp00
;        sta     itmp02
;assume we need at least 5us? from setting and RTIing before output compare will work
        bne     RTC_reset  ; if high byte non zero then we've already missed it
        lda     itmp03
        cmp     #10T
        bhi     RTC_DONE2     ; if less than 5us then we are likely to miss it
RTC_reset:
        lda     itmp01
        add     #10T   ; allow 10us from here to be sure we don't miss it
                       ; this will cause a "lazy" 0.1ms if it happens often
                       ; but should eliminate total dropout
        tax
        lda     itmp00
        adc     #0T
        sta     T2CH0H
        stx     T2CH0L

RTC_DONE2:
;        bclr    TOF,T2SC0
        bset    TOIE,T2SC0		; re-enable 0.1ms interrupt
NOTSPKTIME:				; close branch for below
        pulh
	rti

***************************************************************************
**
** Spark timing
**
***************************************************************************
INT_SPARK_OFFa:   jmp   INT_SPARK_OFF
j_hires_dwell:    jmp   hires_dwell

SPARKTIME:
                pshh
                lda     T2SC1		; Read interrupt
                bclr    CHxF,T2SC1	; Reset interrupt

                brclr   SparkHSpeed,SparkBits,NOTSPKTIME	; Don't spark
					; on time when going slow
                brset   indwell,EnhancedBits4,j_hires_dwell	; start dwell
					; period
                brset   EDIS,personality,set_spkon
                brclr   SparkTrigg,Sparkbits,NOTSPKTIME	; Should never do this

;spark cut used to be here, but moved to TIMERROLL to eliminate chance of
;overheating ignitors when in spark-cut because coils were left switched ON

set_spkon:
                brclr   SparkTrigg,Sparkbits,INT_SPARK_OFFa	; Check for
					; spark trigg, used end of pulse
set_spkon2:
                bset    sparkon,revlimbits	; spark now on
                brset   invspk,EnhancedBits4,sson_inv
                COILNEG			; macro = fire coil for non-inverted
                bra     SparkOnDone
sson_inv:
                COILPOS			; macro = fire coil for inverted
SparkOnDone:
                brclr   EDIS,personality,sod_ne
                jmp     set_saw_on
jsod_cd_done:   jmp     sod_cd_done

sod_ne:
                bclr    TOIE,T2SC1	; Disable interrupts
                brset   dwellcont,feature7,sod_cd
                brset   min_dwell,feature2,jsod_cd_done	; don't schedule
					; here if minimal dwell wanted
sod_cd:
                CalcDwellspk		; Set spark on time
sod_cd_done:
;now check if we should schedule a trailing spark
                brset   rotary2,EnhancedBits5,chktrail
sparktime_exit:
                bclr    SparkTrigg,Sparkbits	; No more sparks for this IRQ
NOT_SPARK_TIME:
                pulh
                rti

;if in twin rotor mode, check to see if we should schedule or fire the trailing
chktrail:
                brset   coilcbit,coilsel,sparktime_exit   ; already done - exit
                brset   coildbit,coilsel,sparktime_exit   ; already done - exit

                brset   coilbbit,coilsel,ctb
                clr     coilsel
                bset    coilcbit,coilsel        ; was coila, now coilc
                bra     ct_done
ctb:
                clr     coilsel
                bset    coildbit,coilsel        ; was coilc, now coild
ct_done:
;       if trailing split off still "fire the coil" now just in case we have
;       already started charging it - don't want to burn out coil as we
;       transition from trailing to no trailing
; "lowspdspk" code checks and doesn't turn coil on if trailing is off,
; see that section within 0.1ms

                brclr   rsh_s,EnhancedBits5,force_trail_off  ; if split out of range then OFF
                brclr   rsh_r,EnhancedBits5,force_trail_off  ; if rpm out of range then OFF

                lda     splitdelH
                beq     split_min      ; is zero so check for short split
                cmp     #$FF
                bne     split_timed
                jmp     force_trail_off     ; ensure trailing coil off
                ;maybe need some hysteresis with this to avoid jittery behaviour

;check if split < 64us, then fire now
split_min:
                lda     splitdelL
                cmp     #64T             ; 64us
                bhi     split_timed
;split_min_set:
;                clr     splitdelL
;                mov     #64T,splitdelH
                jmp     set_spkon2     ; jump back up to fire next spark
split_timed:
                lda     T2CNTL		; unlatch low byte

                ldx     T2CNTH
                stx     T2CurrH		; Save current counter value
                lda     T2CNTL
                sta     T2CurrL		; Save current counter value

                lda     T2CurrL
                add     splitdelL
                tax
                lda     T2CurrH
                adc     splitdelH
                sta     T2CH1H
                stx     T2CH1L

                bset    SparkTrigg,Sparkbits	; keep spark enabled

                bclr    TOF,T2SC1	; clear any pending interrupt
                bset    TOIE,T2SC1	; Enable timer interrupt
		pulh
                rti

force_trail_off:
          ;ensure trailing coil is really off
	  	bset    wled,portc
                brset   invspk,EnhancedBits4,to_inv
                bset    coilb,portc
                bra     to_exit
to_inv:         bclr    coilb,portc
to_exit:
                bclr    SparkTrigg,Sparkbits	; No more sparks for this IRQ
;kill the dwell timers for trailing in the mainloop
                pulh
                rti

hires_dwell:
                ; never do trailing dwell in "hi-res" so no need to
                ; consider trailing here

;first turn on coil, then reset T2 to spark point saved in sparktargetH/L
;spark cut- actually cut the coil-on
                lda     SparkCutCnt	; Check Spark Counter
                inca
                cmp     SparkCutBase_f	; How many sparks to count to
                blo     Dont_ResetCnt2
                lda     #01T
Dont_ResetCnt2:
                sta     SparkCutCnt	; Store new value to spark counter
                brset   sparkCut,RevLimBits,bhrds	; If in spark cut
					; mode jump past spark

                brset   invspk,EnhancedBits4,hrd_inv
                COILPOS			; macro = charge coil for non-inverted
bhrds:
                bra     hrd_set
hrd_inv:
                COILNEG			; macro = charge coil for inverted
hrd_set:
                bclr    indwell,EnhancedBits4	; turn it off so next
					; sparktime fires coil
                bclr    sparkon,revlimbits	; spark now on
;store pre-calculated spark time into timer and set it off
                lda     SparkTargetH
                sta     T2CH1H
                lda     SparkTargetL
                sta     T2CH1L

                bclr    TOF,T2SC1	; clear any pending interrupt
                bset    TOIE,T2SC1	; Enable timer interrupt

                pulh
                rti

set_saw_on:				; now set timer for SAW on period
					; using sawh/l calculated in main loop

;Calculate width of SAW pulse
;grab current timer values - uses same variable as squirt section below. But no  cli  so ok
                lda     T2CNTL		; unlatch low byte
                ldx     T2CNTH
                stx     T2CurrH		; Save current counter value
                lda     T2CNTL
                sta     T2CurrL		; Save current counter value

                brclr   crank,engine,SAW_COUNTER
                lda     feature4_f
                bit     #multisparkb
                beq     SAW_COUNTER
;                brclr   multispark,feature4,SAW_COUNTER

; at crank we always send 2048us as calibration and multi-spark init
                clr     sawl
                mov     #$08,sawh

;Read the calculated width and store in timer
SAW_COUNTER:
                lda     sawl
                add     T2CurrL
                tax
                lda     sawh
                adc     T2CurrH
                sta     T2CH1H
                stx     T2CH1L

                bclr    SparkTrigg,Sparkbits	; Clear spark trigg.
					; Next time we get int turn off SAW

                bclr    TOF,T2SC1	; clear any pending interrupt
                bset    TOIE,T2SC1	; Enable timer interrupt

                brset   DUALEDIS,personality,set_edis2
                pulh
                rti
set_edis2:
                CalcDwellspk		; set time before the other SAW starts
                pulh
                rti			; uses 0.1ms timer for 1/2 cycle time


INT_SPARK_OFF:				; this is only used for EDIS so
					; coilc has no meaning (yet!)
                brset   invspk,EnhancedBits4,InvSparkOff

                brset   REUSE_FIDLE,outputpins,stimef2
                brset   coilbbit,coilsel,stimeb2
                bclr    coila,portc	; Set spark on
                bra     SparkOffDone
stimeb2:
                bclr    coilb,portc
                bra     SparkOffDone
stimef2:
                bclr    iasc,porta
                bra     SparkOffDone
InvSparkOff:
                brset   REUSE_FIDLE,outputpins,isof2
                brset   coilbbit,coilsel,isob2
                bset    coila,portc	; Set inverted spark on
                bra     SparkOffDone
isob2:
                bset    coilb,portc
                bra     SparkOffDone
isof2:
                bset    iasc,porta
SparkOffDone:
                bclr    SparkTrigg,Sparkbits	; No more sparks for this IRQ
                bclr    TOIE,T2SC1	; Disable interrupts
                pulh
                rti
*** end EDIS ***

***************************************************************************
**
** IRQ - Input trigger for new pulse event
**
** This line is connected to the input trigger (i.e TACH signal from ignition
**  system), and schedules a new injector shot (injector actually opened in
**  1/10 timer section above)
**
**  Wheel encoders now removed (020p2) and available as encoder???.s19
***************************************************************************
;as we don't get interrupted can safely use some of burner area
;but beware that this is non-zero page ram hence slower instructions.
;if enough ram may put back into ZP for a small speed increase
stX:         equ   itmp10          ; temp space used in Neon
stH:         equ   itmp11
stL:         equ   itmp12

cTimeHcp:    equ   itmp13         ; copy of predicted period
cTimeLcp:    equ   itmp14

T2CurrX:     equ   itmp15         ; value of T2 at start of handler
T2CurrH:     equ   itmp16
T2CurrL:     equ   itmp17

currtth14h:  equ   itmp18    ; 1/4 current tooth
currtth14l:  equ   itmp19    ; 1/4 current tooth
avgtth14h:   equ   itmp1a    ; 1/4 avg tooth
avgtth14l:   equ   itmp1b    ; 1/4 avg tooth

avgtth12h:   equ   itmp1c    ; 1/2 of avg tooth
avgtth12l:   equ   itmp1d    ; 1/2 of avg tooth

offsetstep:  equ   itmp1e    ; offset step (used by oddfire)
offsetang:   equ   itmp1f    ; offset angle (used by oddfire)

DOSQUIRT:
        pshh
;First thing to do is read the current T2 value
;this should ensure the maximum spark accuracy. Delay value will be based on timer HERE
;rather than after all the other missing tooth calcs by the time we reach done_decode
        lda     T2CNTL			; Unlatch any previous reads
        ldx     T2CNTH
        stx     T2CurrH			; Save current counter value
        lda     T2CNTL
        sta     T2CurrL			; Save current counter value
        lda     T2CNTX                  ;sw byte
        cpx     #0
        bne     no_rollchk
        brclr   roll2,EnhancedBits4,no_rollchk     ; we were't about to rollover
                                                   ; a few ms ago or byte already
                                                   ; cleared by handler - so skip
        inca                                    ; Missed a rollover so inc top byte
no_rollchk:
        sta     T2CurrX

;new in 029e - surely we must be running if we got an IRQ
        bset      running,engine	; Set engine running value


;check for simulator first
        brset   whlsim,feature1,jwheelsim

        brset   MSNEON,personality,decode_neon
        brset   WHEEL,personality,jdecode_wheel
;set just single coil output
        clr     coilsel
        bset    coilabit,coilsel
        jmp     done_decode		; everything else that doesn't
					; need wheel decoding

jdecode_wheel:
        brset   wd_2trig,feature1,jdecode_wheel2
        jmp   decode_wheel
jdecode_wheel2:
        jmp   decode_wheel2

jwheelsim:
        jmp   wheelsim

decode_neon:

;new - are we logging teeth?
        brclr   toothlog,EnhancedBits5,n_notlog
        ;we are logging so record something
        clrh
        ldx     VE_r+PAGESIZE-2
        lda     cTimeH
        sta     VE_r,x
        incx
        lda     cTimeL
        sta     VE_r,x
        incx
        cpx     #PAGESIZE-4
        blo     ntl
        clrx
        lda     numteeth_f
        cmp     #23T			; hard coded lowres/highres
					; transition (was 20T)
        bhi     nth
        lda     #1                      ; 1 = 0.1ms units
        bra     nts
nth:
        clra                            ; 0 = 1us units
nts:
        sta     VE_r+PAGESIZE-1
ntl:
        stx     VE_r+PAGESIZE-2
n_notlog:

        bclr    rise,sparkbits		; reset flag so we can detect
					; next rising IRQ edge
; 020r3 - do all decoding using 0.1ms timer, count the short teeth
; (0.2ms wide at 8000rpm)
;use lowres timer for calcs
;cTime is zero page space for faster calcs, holds time since last tooth
;sH/L is temp storage as we are about to clear lowres
        lda     lowresL
        sta     stL
        sta     cTimeL
        lda     lowresH
        sta     stH
        sta     cTimeH

        clr     lowresL			; reset to zero ready for next 0.1ms int
        clr     lowresH

tooth_sync:				; ignore first few pulses
        brclr   6,wheelcount,tooth_decode2	; if bit 6 clr then we've
					; done holdoff
        dec     wheelcount
        bne     tooth_rti
        bclr    6,wheelcount
tooth_rti:
;save gap between teeth
        lda     stL
        sta     stLp
        lda     stH
        sta     stHp
        pulh
        rti

tooth_decode2:

        bclr    trigret,SparkBits
        brset   7,wheelcount,tooth_decode3	; bit 7 is !sync.
					; if not synced then look for
					; the long trigger
        lda     wheelcount		; ignore the three short pulses
					; after primary trigger
        beq     tooth_decode3		; =0
        dec     wheelcount
        bne     tooth_rti		; >0
        bset    trigret,SparkBits	; =0, set trigger return
        bra     tooth_rti
tooth_decode3:
        ; divide this cycle time 2
        lsr     cTimeH
        ror     cTimeL    ; was rol - typo!

        ;now see if this period/4 > previous
        lda     cTimeH
        cmp     stHp
        blo     tooth_rti
        bhi     tooth_found
        lda     cTimeL
        cmp     stLp
        bhi     tooth_found
        bra     tooth_rti

tooth_found:  ; this is when we've found the first tooth of the sequence

        mov     #3T,wheelcount		; clear !sync bit in process
;move save lowres values into "previous" variable
        lda     stL
        sta     stLp
        lda     stH
        sta     stHp

;calculate how long first high pulse was to determine coil pack
; using SparkTemp to store rising edge time of "irq" to conserve RAM
; The variable should be safe as it is only used in this interrupt handler
; The 0.1ms section monitors the irq line and stores the lowresH/L
; value into SparkTemp if it detects a rising edge.
; calc how long ago the input went high sparktemp = current - sparktemp

        lda     stL
        sub     SparkTempL
        sta     SparkTempL
        lda     stH
        sbc     SparkTempH
        sta     SparkTempH

        lsr     cTimeH
        ror     cTimeL

;See if the high pulse > iTimet/4
        lda     SparkTempH
        cmp     cTimeH
        bhi     coil_detecta
        blo     coil_detectb
        lda     SparkTempL
        cmp     cTimeL
        bhi     coil_detecta
        bra     coil_detectb

; sequence detection
;
coil_detecta:
        brset   coilerr,revlimbits,set_a_clr
        brset   coilbbit,coilsel,set_a_clr	; we are expecting this
        bset    coilerr,revlimbits	; out of sync once, so ignore
					; and follow instinct
        bra     set_b_detect
set_a_clr:
        bclr    coilerr,revlimbits	; reset error bit
set_a_detect:
        clr     coilsel
        bset    coilabit,coilsel
        bra     j_done_cd

coil_detectb:
        brset   coilerr,revlimbits,set_b_clr
        brset   coilabit,coilsel,set_b_clr	; we are expecting this
        bset    coilerr,revlimbits	; out of sync once, so ignore
					; and follow instinct
        bra     set_a_detect
set_b_clr:
        bclr    coilerr,revlimbits	; reset error bit
set_b_detect:
        clr     coilsel
        bset    coilbbit,coilsel

j_done_cd:  jmp   done_decode

****************************************************************************
**  Wheel simulator. Allows any special decoders to be tested on the stim
**  doesn't look for any pattern, just cycles through outputs. Trigger
**  return WILL NOT WORK
**  Flash variable determines how many outputs, use wheelcount as counter
****************************************************************************
wheelsim:
       lda      wheelcount
       inca
       cmp      whlsimcnt
       bne      whlsimdecode
whlsimreset:
       clra
whlsimdecode:
       sta      wheelcount
       clr      coilsel
;       cbeqa    #0,wsda
       cbeqa    #1,wsdb
       cbeqa    #2,wsdc
       cbeqa    #3,wsdd
       cbeqa    #4,wsde
       cbeqa    #5,wsdf
;wsda:
       bset     coilabit,coilsel
       bra      wheelsimdone
wsdb:
       bset     coilbbit,coilsel
       bra      wheelsimdone
wsdc:
       bset     coilcbit,coilsel
       bra      wheelsimdone
wsdd:
       bset     coildbit,coilsel
       bra      wheelsimdone
wsde:
       bset     coilebit,coilsel
       bra      wheelsimdone
wsdf:
       bset     coilfbit,coilsel
;       bra      wheelsimdone

wheelsimdone:
       jmp      done_decode
****************************************************************************
**  Wheel decoder 2. No missing teeth but a second wheel with "reset" tabs
**
**  The 0.1ms section looks out for the second pulse but we check here too
**  on the rising edge the wheelcount is reset to zero so the next real pulse
**  is tooth no.1
**  This is what the Mazda and Toyota guys are after.
**  Could also be used to do COP on a 4cyl by mounting the "reset" tab on the
**  cam and having two tabs on the crank.
****************************************************************************
decode_wheel2:

;repeat check in here, in case two triggers come at once
;on rising edge of input reset wheelcount to zero
      brset   trigger2,EnhancedBits6,no_wd_trig2 ; already found

      lda     dtmode_f
      bit     #trig2risefallb
      bne     wd_risefall2   ; do rising and falling
      bit     #trig2fallb
      bne     wd_inv2

;on rising edge of input reset wheelcount to zero
      brset   rise,sparkbits,no_wd_trig2 ; already high so bail out
;not already in high state so see if pin has been asserted
      brclr   pin11,portc,no_wd_trig2   ; inactive

;we've found a rising edge of pin11
      bset    rise,sparkbits           ; this bit used to monitor the edge of the input
      bra     wd2_2_flag               ; flag the trigger

wd_inv2:
;on falling edge of input reset wheelcount to zero
      brclr   rise,sparkbits,no_wd_trig2 ; already low so bail out
      brset   pin11,portc,no_wd_trig2

;we've found a falling edge of pin11
      bclr    rise,sparkbits           ; this bit used to monitor the edge of the input
      bra     wd2_2_flag               ; flag the trigger

wd_risefall2:
;on rising and falling edge of input reset wheelcount to zero
      brset   rise,sparkbits,wd2_rf1 ; was high
      brclr   pin11,portc,no_wd_trig2   ; still low
      bset    rise,sparkbits
      bra     wd2_2_flag

wd2_rf1:
      brset   pin11,portc,no_wd_trig2 ; still high
      bclr    rise,sparkbits
;      bra     wd2_2_flag               ; flag the trigger

wd2_2_flag:
      bset    trigger2,EnhancedBits6   ; flag the trigger

no_wd_trig2:

;are we doing missing tooth or non-missing tooth with the 2nd trigger
      lda     feature4_f
      bit     #miss2ndb
      bne     decode_wheel    ; miss + 2nd

;new - are we logging teeth?
        brclr   toothlog,EnhancedBits5,w2dec_notlog
        ;we are logging so record something
        clrh
        ldx     VE_r+PAGESIZE-2
        lda     cTimeH
        sta     VE_r,x
        incx
        lda     cTimeL
        sta     VE_r,x
        incx
        cpx     #PAGESIZE-4
        blo     wd2tl
        clrx
        lda     numteeth_f
        cmp     #23T			; hard coded lowres/highres
					; transition (was 20T)
        bhi     wd2th
        lda     #1                      ; 1 = 0.1ms units
        bra     wd2ts
wd2th:
        clra                            ; 0 = 1us units
wd2ts:
        sta     VE_r+PAGESIZE-1
wd2tl:
        stx     VE_r+PAGESIZE-2
w2dec_notlog:

;this is "real" start of 2nd trigger.
;see if 2nd trigger came in since last time we were in here
      brclr   trigger2,EnhancedBits6,cksync2      ; no it didn't
      bclr    trigger2,EnhancedBits6              ; clear it
      bset    wsync,EnhancedBits6
      clr     wheelcount
      bra     no_wd_trig3
cksync2:
      brset   wsync,EnhancedBits6,no_wd_trig3
      jmp     w_rti             ; go to exit for normal wheel decoder

no_wd_trig3:

      lda     wheelcount
      cmp     numteeth_f
      blo     wd2_cont
      ;we should have received a "reset" tab by now.. declare unsynced and
      ;wait for another reset tab
      bclr    wsync,EnhancedBits6
      clr     wheelcount
      jmp     w_rti             ; go to exit for normal wheel decoder

wd2_cont:
      inc     wheelcount
      jmp     wc_op             ; jump to wheel decoder o/p selection
****************************************************************************
**  generic wheel decoder
**  -1 Missing tooth when iTimet > 1.5 * iTimep
**  -2 Missing teeth when iTimet > 1.5 * iTimep (was 2.5*) (changed 029k)
**  We don't get here until we've had a few teeth. When we've found
** missing tooth then clr top bit of wheelcount
**
****************************************************************************
decode_wheel:
        lda     numteeth_f
        cmp     #23T			; hard coded lowres/highres
					; transition (was 20T)
        bhi     w_high
;XXXX
;        brclr    crank,engine,w_high  ;; XXXX try this to get rpm below 100
w_low:
;as per Neon, use cTimeH/L where poss as it is zp
        ;use lowres timer for calcs
        mov     lowresL,cTimeL
        mov     lowresH,cTimeH

        bra     w_decode

w_high:
        lda     rpm
        bne     w_high_fast
        ;check for very slow rpm that will cause timer overflow.
        ;-1 does *1.5 so max time is 65/1.5 = 43ms  -> 38rpm on 36-1
        ;-2 does *2.5                       = 26ms  -> 38rpm on 60-2
        ;if this check omitted then wacky rpm displayed when really very slow
        ;65ms = $28F x0.1ms
;029q3 put it back in
        lda     lowresH
        cmp     #2
        blo     w_high_fast  ; fast enough
        bhi     j_lost_sync2        ; must re-sync - too slow
        lda     lowresL             ; lowresH=2, so check low byte
        cmp     #$88                ; give a little leeway (64.8ms)
        blo     w_high_fast         ; if less then ok, otherwise re-sync
;029e. Shouldn't check against 26ms then? Try 25.6ms as it is so easy.
;X        lda     lowresH
;X        beq     w_high_fast  ; fast enough
j_lost_sync2:
        clr     lowresL     ; always reset the lowres ready for next int
        clr     lowresH
        jmp     lost_sync_w
w_high_fast:
       ;T2 already read at start of handler
        lda     T2CurrL
        sub     T2PrevL			; Calculate cycle time
        sta     cTimeL
        lda     T2CurrH
        sbc     T2PrevH
        sta     cTimeH

;now try to decode pattern
w_decode:
;new - are we logging teeth?
        brclr   toothlog,EnhancedBits5,w_dec_notlog
        ;we are logging so record something
        clrh
        ldx     VE_r+PAGESIZE-2
        lda     cTimeH
        sta     VE_r,x
        incx
        lda     cTimeL
        sta     VE_r,x
        incx
        cpx     #PAGESIZE-4
        blo     wdtl
        clrx
        lda     numteeth_f
        cmp     #23T			; hard coded lowres/highres
					; transition (was 20T)
        bhi     wdth
        lda     #1                      ; 1 = 0.1ms units
        bra     wdts
wdth:
        clra                            ; 0 = 1us units
wdts:
        sta     VE_r+PAGESIZE-1
wdtl:
        stx     VE_r+PAGESIZE-2
w_dec_notlog:

; added in 029p - always use 024s9 during cranking
        brset   crank,engine,w_decode_ok     ; do not do this while cranking

;Ryan reports problems with the NEW routine below, so now config option to use 024s9
;style decoder instead. This way can swap versions on the fly
        lda     feature6_f
        bit     #wheel_oldb
        beq     decoder_new ; 0 = new decoder

        ;bypass the tooth false trigger
        ;load up old vars into new ones
;        mov     stHp,avgtoothh   ; now the same thing
;        mov     stLp,avgtoothl
        bra     w_decode_ok

decoder_new:
;NEW
;calculate half of average tooth time
        lda     avgtoothh
        lsra
        sta     avgtth12h
        lda     avgtoothl
        rora
        sta     avgtth12l

        brset   whold,EnhancedBits6,w_decode_ok ; still in holdoff, so no check
        brclr   wsync,EnhancedBits6,w_decode_ok ; not synced yet, so no check
;check to see if obvious false trigger
        lda     cTimeH
        cmp     avgtth12h  ; divided by two before storage
        bhi     w_decode_ok
        blo     w_decode_false
        lda     cTimeL
        cmp     avgtth12l
        bhi     w_decode_ok

w_decode_false:
        pulh
        rti    ; get out of here - false trigger

w_decode_ok:
;END NEW
        clr     lowresL     ; always reset the lowres ready for next int
        clr     lowresH
        ; ignore first few pulses
        brclr   whold,EnhancedBits6,w_decode2	; if bit 6 clr then we've done holdoff
        dec     wheelcount
        lda     wheelcount
        and     #$3F               ; ignore top bits during holdoff downcount
                                   ; keeps wheelcount compatible with Neon mode
        bne     w_rti
        bclr    whold,EnhancedBits6
w_rti:
        lda     T2CurrH
        sta     T2PrevH		; Make current value tooth last
        lda     T2CurrL
        sta     T2PrevL

;this section only runs during tooth holdoff - just store last tooth into average
        lda     cTimeL
        sta     avgtoothl
        lda     cTimeH
        sta     avgtoothh
        pulh
        rti

w_decode2:
;NEW... don't just use previous tooth - use average instead

;        brset   WHEEL2,personality,w_dec2m2  commented 029k
        ;mult iTimeH/Lp * .5
        lda     avgtoothh
        lsra
        sta     SparkTempH
        lda     avgtoothl
        rora
        sta     SparkTempL
        ; add iTimep so * 1.5 for -1 teeth
        lda     SparkTempL
        add     avgtoothl
        sta     SparkTempL
        lda     SparkTempH
        adc     avgtoothh
        sta     SparkTempH
;        bra     w_comp
;
;w_dec2m2:
;        ; do * 2, for -2 teeth
;        lda     avgtoothl
;        lsla
;        sta     SparkTempL
;        lda     avgtoothh
;        rola
;        sta     SparkTempH

w_comp:
; now compare current hires time
        lda     cTimeH
        cmp     SparkTempH
        bhi     is_miss
        blo     not_miss
        lda     cTimeL
        cmp     SparkTempL
        bhi     is_miss
        bra     not_miss

is_miss:
        clr     wheelcount		; declare we are synced and
					; reset counter
;now check if 2nd trigger input is set, if so start 2nd revolution at num teeth
; i.e. on a 60-2,  0-359 deg =  0-59
;                360-719 deg = 60-119

        brclr   trigger2,EnhancedBits6,not_2ndmiss
        lda     numteeth_f   ; from 028c now holds 2 revs number (i.e. 60-2 -> 120)
        lsra
        sta     wheelcount
        bclr    trigger2,EnhancedBits6    ; clear flag
not_2ndmiss:
        bset    wsync,EnhancedBits6
        brclr   WHEEL2,personality,not_miss
        inc     wheelcount
not_miss:

        brset   crank,engine,tooth_noavg    ; do not use 025 style during cranking
;check if using old decoder
        lda     feature6_f
        bit     #wheel_oldb
        beq     tooth_avg

tooth_noavg:
;like old method, just store previoud period
        lda     cTimeH
        sta     avgtoothh
        lda     cTimeL
        sta     avgtoothl
        bra     not_miss_skip ; 1 = old decoder

tooth_avg:
;NEW
;update average tooth count
;new average = 3/4 old avg + 1/4 current tooth
;
;get 1/4 current tooth
        lda     cTimeH
        lsra
        sta     currtth14h
        lda     cTimeL
        rora
        sta     currtth14l
        lda     currtth14h
        lsra
        sta     currtth14h
        lda     currtth14l
        rora
        sta     currtth14l
;get 1/4 avg tooth
        lda     avgtoothh
        lsra
        sta     avgtth14h
        lda     avgtoothl
        rora
        sta     avgtth14l
        lda     avgtth14h
        lsra
        sta     avgtth14h
        lda     avgtth14l
        rora
        sta     avgtth14l
;avg tooth - 1/4 avg tooth
        lda     avgtoothl
        sub     avgtth14l
        sta     avgtoothl
        lda     avgtoothh
        sbc     avgtth14h
        sta     avgtoothh
;3/4 avg tooth + 1/4 new tooth
        lda     avgtoothl
        add     currtth14l
        sta     avgtoothl
        lda     avgtoothh
        adc     currtth14h
        sta     avgtoothh
;END NEW
not_miss_skip:
        brclr   wsync,EnhancedBits6,jretw  ; if non synced then wheelcount is meaningless
        inc     wheelcount
        lda     wheelcount
        cmp     numteeth_f
        bls     not_miss_ok
        jmp     lost_sync_w
not_miss_ok:
        brset   wsync,EnhancedBits6,wc_op
jretw:
        jmp     ret_w
wc_op:
;see if our tooth matches the user input trigger point
        lda     wheelcount
        brclr   nextcyl,EnhancedBits4,wc_op2
        brclr   wspk,EnhancedBits4,wc_op2   ; if not multi output doesn't matter

;if running next-cyl and wheel decoder we would send running output to the
;wrong coil unless we take this action here...
;(doesn't work?)

;check if 4th spark output in use
                brset   out3sparkd,feature2,wdnc4
;check if 3rd spark output in use
;don't check for 2nd output, wouldn't have got here otherwise
                brclr   REUSE_LED18,outputpins,wdnc2    ; want 1 } spark c
                brclr   REUSE_LED18_2,outputpins,wdnc2  ; want 1 }
wdnc3:
        cmp     trig1_f
        beq     w_trig2
        cmp     trig2_f
        beq     w_trig3
        cmp     trig3_f
        beq     w_trig1
        jmp     wc_op3
wdnc4:
        cmp     trig1_f
        beq     w_trig2
        cmp     trig2_f
        beq     w_trig3
        cmp     trig3_f
        beq     w_trig4
        cmp     trig4_f
        beq     w_trig1
        jmp     wc_op3
wdnc2:
        cmp     trig1_f
        beq     w_trig2
        cmp     trig2_f
        beq     w_trig1
        jmp     wc_op3


wc_op2:
; decode multiple outputs
        cmp     trig1_f
        beq     w_trig1
        cmp     trig2_f
        beq     w_trig2
        cmp     trig3_f
        beq     w_trig3
        cmp     trig4_f
        beq     w_trig4
        cmp     trig5_f
        beq     w_trig5
        cmp     trig6_f
        beq     w_trig6

wc_op3:
	brset	rsh_r,EnhancedBits5,ret_w ; don't check if doing trailing
        cmp     trig1ret_f
        beq     w_trigret1
        cmp     trig2ret_f
        beq     w_trigret2
        cmp     trig3ret_f
        beq     w_trigret3
        cmp     trig4ret_f
        beq     w_trigret4
        cmp     trig5ret_f
        beq     w_trigret5
        cmp     trig6ret_f
        beq     w_trigret6
        bra     ret_w

w_trig1:
        clr     coilsel
        bset    coilabit,coilsel
        jmp     w_store2

w_trig2:
        brclr   REUSE_LED19,outputpins,w_trig1	; if spark B not defined
					; then just one o/p
        clr     coilsel
        bset    coilbbit,coilsel
        jmp     w_store2

w_trig3:
        brclr   REUSE_LED19,outputpins,w_trig1
        clr     coilsel
        bset    coilcbit,coilsel
        jmp     w_store2

w_trig4:
        brclr   REUSE_LED19,outputpins,w_trig1
        clr     coilsel
        bset    coildbit,coilsel
        jmp     w_store2

w_trig5:
        brclr   REUSE_LED19,outputpins,w_trig1
        clr     coilsel
        bset    coilebit,coilsel
        jmp     w_store2

w_trig6:
        brclr   REUSE_LED19,outputpins,w_trig1
        clr     coilsel
        bset    coilfbit,coilsel
        jmp     w_store2

ret_w2:
        bset    trigret,SparkBits

ret_w:
        lda     T2CurrH
        sta     T2PrevH		; Make current value tooth last
        lda     T2CurrL
        sta     T2PrevL
        pulh
        rti

; now the "trigger return" tooth for cranking timing
w_trigret1:
        clr     coilsel
        bset    coilabit,coilsel
        bra     ret_w2

w_trigret2:
        brclr   REUSE_LED19,outputpins,w_trigret1	; if spark B not
					; defined then just one o/p
        clr     coilsel
        bset    coilbbit,coilsel
        bra     ret_w2

w_trigret3:
        brclr   REUSE_LED19,outputpins,w_trigret1
        clr     coilsel
        bset    coilcbit,coilsel
        bra     ret_w2

w_trigret4:
        brclr   REUSE_LED19,outputpins,w_trigret1
        clr     coilsel
        bset    coildbit,coilsel
        bra     ret_w2

w_trigret5:
        brclr   REUSE_LED19,outputpins,w_trigret1
        clr     coilsel
        bset    coilebit,coilsel
        bra     ret_w2

w_trigret6:
        brclr   REUSE_LED19,outputpins,w_trigret1
        clr     coilsel
        bset    coilfbit,coilsel
        bra     ret_w2

lost_sync_w:				; we found too many teeth after
					; the missing one, start syncing again
					; also do holdoff. This should be
					; rare, but if we lost sync that
					; bad we'd better start all over
        mov     #WHEELINIT,wheelcount	; was %10000000 (missing #)
        bclr    wsync,EnhancedBits6
        bset    whold,EnhancedBits6
;NEW
        lda     #0
        sta     avgtoothh
        sta     avgtoothl
;NEW

;worth killing the dwell timers to avoid dwells starting
        TurnAllSpkOff        ; call macro to turn off all
        jmp     ret_w

w_store2:
        bclr    trigret,SparkBits

w_store:
        lda     T2CurrH
        sta     T2PrevH		; Make current value tooth last
        lda     T2CurrL
        sta     T2PrevL
*****************************************************************************
** When getting here we should have decoded crank signal into one pulse
** per ignition event so we can just drop into the standard MSnS code.
** A smarter implementation would use the individual teeth for more
** accurate timing
*****************************************************************************
done_decode:
        brclr   REUSE_LED18,outputpins,dcd_no_led
        brset   REUSE_LED18_2,outputpins,dcd_no_led	; if coil c
        bset    wled,portc		; Turn on IRQ led, orig MSnS code
dcd_no_led:

;tacho output
        lda     tachconf_f
        bit     #$7f
        beq     tach_done
        bit     #$80     ; see if in divide by 2 mode
        beq     tach_full
        lda     EnhancedBits5
        eor     #ctodivb
        sta     EnhancedBits5
        bit     #ctodivb
        beq     tach_done
tach_full:

; Tacho ouput
        lda      tachconf_f
        and      #$7f
        beq      tach_done
;tachon:
        cbeqa    #1T,tachon_x2
        cbeqa    #2T,tachon_x3
        cbeqa    #3T,tachon_x4
        cbeqa    #4T,tachon_x5
        cbeqa    #5T,tachon_out3
        cbeqa    #6T,tachon_pin10
        bra      tach_done
tachon_x2:
        bset     water,porta
        bra      tach_done
tachon_x3:
        bset     water2,porta
        bra      tach_done
tachon_x4:
        bset     output1,porta
        bra      tach_done
tachon_x5:
        bset     output2,porta
        bra      tach_done
tachon_out3:
        bset     output3,portd
        bra      tach_done
tachon_pin10:
        bset     pin10,portc
;        bra      tach_done

tach_done:
;save old values
        mov       iTimeX,iTimepX
        mov       iTimeH,iTimepH
        mov       iTimeL,iTimepL

;T2 read at start of DOSQUIRT
        lda     T2CurrL
        sub     T2LastL			; Calculate cycle time
        sta     iTimeL                  ; global var
        lda     T2CurrH
        sbc     T2LastH
        sta     iTimeH
        lda     T2CurrX
        sbc     T2LastX
        sta     iTimeX

;Must check to see if iTime has gone negative. This can occur if the interrupt to increment
; the top byte of the timer gets missed. The roll_chk code obviously does not work correctly.

;;;;CODE TO FIX DROPOUT
        brclr   7,iTimeX,noitx_err
;if top bit of iTimeX is set then software rollover must have got missed
;giving a negative time
        lda     T2CurrX
        add     #1     ; increment the saved "current" value of the timer
        sta     T2CurrX
;assume value should really be zero
        clr     iTimeX ; assume top byte is zero
noitx_err:
;;;;CODE TO FIX DROPOUT

;check for dual dizzy feature
        brclr   WHEEL,personality,nondualdizzy  ; if not wheel decoder then skip
        lda     feature6_f
        bit     #dualdizzyb
        beq     nondualdizzy
        brset   coilbbit,coilsel,dualdb
        brset   coilcbit,coilsel,dualda
        brset   coildbit,coilsel,dualdb
        brset   coilebit,coilsel,dualda
        brset   coilfbit,coilsel,dualdb
dualda:
        clr     coilsel
        bset    coilabit,coilsel
        bra     nondualdizzy
dualdb:
        clr     coilsel
        bset    coilbbit,coilsel

nondualdizzy:
*************
; If we are running next cyl and low advance and get a lot of engine
; accel then we can sometime receive the next trigger pulse before
; we've actually sparked.  We'll know if this happens because sparktrigg
; will be set when we get here. If this is the case then we'd better
; fire the coil right now.
;
        brclr   nextcyl,EnhancedBits4,j_miss_ckskp  ; ONLY for next-cylinder
;the nextcyl bit is only set for valid personalities

        brset   crank,engine,miss_chk         ; at crank we ALWAYS fire at trigger
        brset   SparkTrigg,Sparkbits,miss_chk ; if set then we missed one

j_miss_ckskp:    jmp     miss_chk_skip
miss_chk:

        brset   invspk,EnhancedBits4,mc_inv
        COILNEG  ; macro = fire coil for non-inverted
        bra     mc_fire_done

j_miss_ckdn2:    jmp     miss_chk_done
mc_inv:
        COILPOS				; macro = fire coil for inverted
mc_fire_done:
        bclr    TOIE,T2SC1		; Disable timer interrupt
					; (never got there)
        brclr   dwellcont,feature7,mc_fd
        ;if next_cyl and cranking then skip
        brclr   nextcyl,EnhancedBits4,mc_fd2
        brset   crank,engine,mc_cd   ; can cause a conflict
mc_fd2:
        brset   SparkLSpeed,SparkBits,jmcd	; low speed & dwell
					; so don't schedule now
mc_fd:
        brclr   min_dwell,feature2,mc_cd	; don't schedule here
jmcd:	jmp     miss_chk_done			; if minimal dwell wanted
mc_cd:
        CalcDwellspk			; Set spark on time
miss_chk_done:
        brclr   crank,engine,miss_chk_skip ; if not cranking then continue as normal
        jmp     SKIP_CYCLE_CALC
*****************************************************************************

miss_chk_skip:
        bset    SparkTrigg,Sparkbits	; IRQ triggered, but no spark yet

        inc     idleCtlClock		; Idle PWM Clock counter
	lda	idleDelayClock		; Idle PWM delay counter
	beq	delay_done
	deca				; idle seconds clock
	sta	idleDelayClock
delay_done:
	brclr	REStaging,EnhancedBits,cont_inc_counters
	brset	StgTransDone,EnhancedBits6,cont_inc_counters
	; if we're here, we're supposed to be incrementing the staging counter
	lda	stgTransitionCnt
	inca
	sta	stgTransitionCnt


cont_inc_counters:
     	lda	igncount1
	bne     EGOBUMP		       ; Only increment counters if
					; cylinder count is zero
        lda     feature10_f5
        bit     #ASEIgnCountb
        bne     TPS_COUNTER
        inc      asecount		; Increment after-start enrichment
					; counter

TPS_COUNTER:
      brclr    taeIgnCount,feature1,EGOBUMP	; Are we in Cycle counter
					; mode for TPS Accel?
      inc      tpsaclk			; Yes so increment counter

; Save current TPS reading in last_tps variable to compute TPSDOT in
; acceleration enrichment section or KPa in KPa last if in MAP dot

       lda     feature4_f
       bit     #KpaDotSetb
       beq     tps_dot_on
;       brclr   KpaDotSet,feature4,tps_dot_on	; If not in KPA dot mode
					; jump past KPa settings
       lda     kpa
       bra     Kpa_Dot_on
tps_dot_on:
       lda      tps
Kpa_Dot_on:
       sta      TPSlast

EGOBUMP:
       	lda	  rpm
;	sta	  old_rpm1      ; Used in odd-fire code - save the last computed RPM for average

;        brclr     egoIgnCount,feature1,No_Ego_Cnt
        lda       feature14_f1
        bit       #egoIgnCountb
        beq       No_Ego_Cnt
        inc       egocount		; Increment EGO step counter
No_Ego_Cnt:
        brset   running,engine,CYCLE_CALC	; should always be running
					; if we get here
        jmp     SKIP_CYCLE_CALC
CYCLE_CALC:

; revised section new in 015d
; hi-res timer is only 16bit and runs at 1MHz. 1 tick = 1us
; so timer rollover occurs at about 65.5ms. Hence if period > 65.5ms
; we have to use the lo-res spark calculation i.e. use the 0.1ms
; routine instead of the hi-res output compare method in "SPARKTIME"
; 70ms equates to rpmh = $2, rpml = $BC.  Choose set point as $200 as
; simpler.  65ms is $28F
;

;022b 0 T2 is now 24 bit with the extra software byte but may slow this routine
;excessively if we do 24bit maths here in an interrupt handler.
;Stick with Magnus' 0.1ms method for now as it works.

        brclr   EDIS,personality,non_edis
        jmp     edis_speed
non_edis:
;are we doing oddfire wheel ?
        lda     SparkConfig1_f
        bit     #M_SC1oddfire
        beq     CCnot_odd
        brset   coilabit,coilsel,CCofa
        brset   coilbbit,coilsel,CCofb
        brset   coilcbit,coilsel,CCofc
        brset   coildbit,coilsel,CCofd
        brset   coildbit,coilsel,CCofe
        brset   coildbit,coilsel,CCoff
        bra     CCnot_odd
CCofa:
        lda      outaoffs_f
        sta      offsetstep
        lda      outaoffv_f
        sta      offsetang
        bra      CC_cont

CCofb:
        lda      outboffs_f
        sta      offsetstep
        lda      outboffv_f
        sta      offsetang
        bra      CC_cont

CCofc:
        lda      outcoffs_f
        sta      offsetstep
        lda      outcoffv_f
        sta      offsetang
        bra      CC_cont

CCofd:
        lda      outdoffs_f
        sta      offsetstep
        lda      outdoffv_f
        sta      offsetang
        bra      CC_cont

CCofe:
        lda      outeoffs_f
        sta      offsetstep
        lda      outeoffv_f
        sta      offsetang
        bra      CC_cont

CCoff:
        lda      outfoffs_f
        sta      offsetstep
        lda      outfoffv_f
        sta      offsetang
        bra      CC_cont

CCnot_odd:
        lda     #0
        sta     offsetang
        sta     offsetstep
CC_cont:
         lda     rpmch
         cmp     #$1
         bhi     LOW_SPEED		; rpmc > $200  slow
         blo     HIGH_SPEED		;      < $100  fast
         lda     rpmcl
         cmp     #$80
         blo     HIGH_SPEED		;      < $180  fast
         bra     ASIS_SPEED		; in between leave as it was

edis_speed:
        clr     coilsel
        bset    coilabit,coilsel
;If trigg angle zero used fixed delay
        lda     TriggAngle_f
        sta     DelayAngle
        bne     VARIABLE_DELAY
        lda     #$40			; 10us delay. Try 64us
        sta     SparkDelayL
        lda     #$00
        sta     SparkDelayH
        bset    SparkHSpeed,SparkBits	; Turn on high speed ignition
        bclr    SparkLSpeed,SparkBits	; Turn off low speed ignition
        mov     iTimeL,cTimeL		; Prepare to calculate with
        mov     iTimeH,cTimeH           ; highres time
        jmp     set_spk_timer

LOW_SPEED:
        bclr    SparkHSpeed,SparkBits	; Turn off high speed ignition
        bset    SparkLSpeed,SparkBits	; Turn on low speed ignition
        brclr   TFI,personality,LOW_cont
;TFI mode - set the output now (follow IRQ at low speed)
        bset    sparkon,revlimbits	; spark now on
        bclr    sparktrigg,sparkbits	; don't want another one

        brset   invspk,EnhancedBits4,InvLSparkOn2
;; Don't support coils b,c,d in TFI

NInvLSparkOn2:
        brset   REUSE_FIDLE,outputpins,dslsf2
        bset    coila,portc		; Set spark on
        bra     tfi_cont
dslsf2:
        bset    iasc,porta
        bra     tfi_cont
InvLSparkOn2:
        brset   REUSE_FIDLE,outputpins,ilsof2
        bclr    coila,portc		; Set inverted spark on
        bra     tfi_cont
ilsof2:
        bclr     iasc,porta
tfi_cont:
        jmp     SKIP_CYCLE_CALC

LOW_cont:

        bra     DELAY_CALC

ASIS_SPEED:
        ;need to check for low speed+TFI or we'll miss the output
        brclr   TFI,personality,DELAY_CALC
        brclr   SparkLSpeed,SparkBits,DELAY_CALC
        bra     LOW_SPEED

VARIABLE_DELAY:

HIGH_SPEED:
;        brclr   TFI,personality,HIGH_cont
;        lda     rpm
;        cmp     #6			; if < 600rpm and TFI then low speed
;        blo     LOW_SPEED
HIGH_cont:
;hei7 bypass now in main loop
        bset    SparkHSpeed,SparkBits	; Turn on high speed ignition
        bclr    SparkLSpeed,SparkBits	; Turn off low speed ignition

DELAY_CALC:
        lda     config11_f1		; Get engine config
        nsa
        and     #$0f			; Mask out cylinders  (was $07)
        inca				; Prepare loop counter
        tax				; stick in into X for safe keeping

; accel/decel correction..
; If engine is accelerating or decelerating predict our expected next
; cycle time for more accurate spark control. Tom Hafner reported a big
; improvement with a similar method in his MegaSpark.
; Calc is as follows: predicted ctime = ctime + (ctime - ctime prev) =
; 2x ctime - ctimep

        brset   SparkLSpeed,SparkBits,dc_low
        mov     iTimeL,cTimeL		; Prepare to calculate with
					; highres time
        mov     iTimeH,cTimeH

;do high speed accel/decel correction
        lda     iTimepH
        bne     hispdcorr
        lda     iTimepL
        beq     ReCalcDelay		; if previous is zero then skip routine
hispdcorr:
;        clr     SparkCarry
        lsl     cTimeL
        rol     cTimeH
;        rol     SparkCarry		; redundant. If it overflows we'll
					; only subtract it in a sec
        lda     cTimeL
        sub     iTimepL
        sta     cTimeL
        lda     cTimeH
        sbc     iTimepH
        sta     cTimeH

        bra      ReCalcDelay
dc_low:
        mov     rpmcl,cTimeL		; Prepare to calculate with lowres time
        mov     rpmch,cTimeH
;do low speed accel/decel correction
        lda     rpmph
        bne     lospdcorr
        lda     rpmpl
        beq     ReCalcDelay		; if previous is zero then skip routine
lospdcorr:
;        clr     SparkCarry
        lsl     cTimeL
        rol     cTimeH
;        rol     SparkCarry		; redundant. If it overflows we'll
					; only subtract it in a sec
        lda     cTimeL
        sub     rpmpl
        sta     cTimeL
        lda     cTimeH
        sbc     rpmph
        sta     cTimeH

ReCalcDelay:
        mov     cTimeL,SparkTempL
        mov     cTimeH,SparkTempH
        clr     SparkCarry
;take a copy - used later by next-cyl calcs
        lda     cTimeL
        sta     ctimeLcp
        lda     cTimeH
        sta     ctimeHcp

        txa
        cmp     #4
        bhi     more4cyl		; more than 4cyl
        cbeqa   #3T,cyl3		; 3cyl does 2/4 stroke internally

        tax				;1,2,4 are so simple do them here
        lda     config11_f1
        bit     #M_TwoStroke
        beq     lt4_4s			; eq 0 so branch 4 stroke
        ; 2 stroke for 1,2,4
        txa
        cbeqa   #1T,jsmd4
        cbeqa   #2T,jsmd2
        cbeqa   #4T,jsmt
        ; 4 stroke for 1,2,4
lt4_4s:
        txa
        cbeqa   #1T,jsmd8
        cbeqa   #2T,jsmd4
        cbeqa   #4T,jsmd2

more4cyl:
        tax
        lda     config11_f1
        bit     #M_TwoStroke
        bne     cyl_invalid		; don't support 2 stroke >4 cyl
        txa
        cbeqa   #5T,cyl5		; quick calc routines for speed
        cbeqa   #6T,cyl6
        cbeqa   #8T,cyl8a
        cbeqa   #10T,cyl10a
        cbeqa   #12T,cyl12a
        cbeqa   #16T,cyl16a
cyl_invalid:
        jmp     SKIP_CYCLE_CALC		; if 7,9,11,13,14,15 don't do timing

cyl8a:  jmp     cyl8
cyl10a: jmp     cyl10
cyl12a: jmp     cyl12
cyl16a: jmp     cyl16

;**********
;some jumps
jsmd8:  jmp    spk_mult_div8
jsmd4:  jmp    spk_mult_div4
jsmd2:  jmp    spk_mult_div2
jsmt:   jmp    spk_mult

;** special faster routines to calculate the delay. **
;**********
cyl3:   ;  *3 / 8
        lsl     sparkTempL		; *2
        rol     sparkTempH
        rol     SparkCarry

        lda     SparkTempL		; +1 more
        add     cTimeL
        sta     SparkTempL
        lda     SparkTempH
        adc     cTimeH
        sta     SparkTempH
        bcc     cyl3nc
        inc     SparkCarry
cyl3nc:
        lda     config11_f1
        bit     #M_TwoStroke
        bne     bsmd4			; if 2 stroke div4. 4 stroke div8
        bra     bsmd8

;**********
cyl5:  ; *5 /8

        lsl     SparkTempL		; *2
        rol     SparkTempH
        rol     SparkCarry

        lsl     SparkTempL		; *2
        rol     SparkTempH
        rol     SparkCarry

        lda     SparkTempL		; +1 more
        add     cTimeL
        sta     SparkTempL
        lda     SparkTempH
        adc     cTimeH
        sta     SparkTempH
        bcc     spk_mult_div8
        inc     SparkCarry
        bra     spk_mult_div8

;**********
cyl6:   ;  *3 / 4
        lsl     sparkTempL		; *2
        rol     sparkTempH
        rol     SparkCarry

        lda     SparkTempL		; +1 more
        add     cTimeL
        sta     SparkTempL
        lda     SparkTempH
        adc     cTimeH
        sta     SparkTempH
        bcc     spk_mult_div4
        inc     SparkCarry
        bra     spk_mult_div4

;**********
;some relative jumps
bsmd8:  bra    spk_mult_div8
bsmd4:  bra    spk_mult_div4
bsmd2:  bra    spk_mult_div2
bsm:   bra    spk_mult
;**********
cyl8:   ; no change, period - 90 deg already
        mov     cTimeL,SparkTempL
        mov     cTimeH,SparkTempH
        bra     spk_mult

cyl10:  ; *5 /4
        mov     cTimeL,SparkTempL
        mov     cTimeH,SparkTempH
        clr     SparkCarry

        lsl     SparkTempL		; *2
        rol     SparkTempH
        rol     SparkCarry

        lsl     SparkTempL		; *2
        rol     SparkTempH
        rol     SparkCarry

        lda     SparkTempL		; +1 more
        add     cTimeL
        sta     SparkTempL
        lda     SparkTempH
        adc     cTimeH
        sta     SparkTempH
        bcc     spk_mult_div4
        inc     SparkCarry
        bra     spk_mult_div4

;**********
cyl12:
        mov     cTimeL,SparkTempL
        mov     cTimeH,SparkTempH
        clr     SparkCarry

        lsl     sparkTempL		; *2
        rol     sparkTempH
        rol     SparkCarry

        lda     SparkTempL		; +1 more
        add     cTimeL
        sta     SparkTempL
        lda     SparkTempH
        adc     cTimeH
        sta     SparkTempH
        bcc     spk_mult_div2
        inc     SparkCarry
        bra     spk_mult_div2
;**********
cyl16:  ; x2 to get 90 deg period (we will lose a bit below 150 rpm)
        mov     cTimeL,SparkTempL
        mov     cTimeH,SparkTempH
        lsl     sparkTempL
        rol     sparkTempH
        bra     spk_mult

;**********
spk_mult_div8:
        lsr     SparkCarry		; /2
        ror     SparkTempH
        ror     SparkTempL

spk_mult_div4:
        lsr     SparkCarry		; /2
        ror     SparkTempH
        ror     SparkTempL

spk_mult_div2:
        lsr     SparkCarry		; /2
        ror     SparkTempH
        ror     SparkTempL

spk_mult:
        ; Calculate time for delay angle
        ; Time for 90 deg * Angle (256=90 deg)/256
        lda     DelayAngle
        add     offsetang    ; for oddfire, zero otherwise
        ldx     SparkTempH
        mul
        stx     SparkDelayH
        sta     SparkCarry
        lda     DelayAngle
        add     offsetang    ; for oddfire, zero otherwise
        ldx     SparkTempL
        mul
        txa
        add     SparkCarry
        sta     SparkDelayL
        bcc     NoSparkCarry
        inc     SparkDelayH

NoSparkCarry:

;check for oddfire offset
        lda     SparkConfig1_f
        bit     #M_SC1oddfire
        beq     ck_xlong       ; not oddfire, use normal method
;now add oddfire triggers
        lda     offsetstep
        beq     ck_nextcyl     ; if no offset step then skip

        bit     #outoff_45b
        bne     of45           ; add 45 deg

        lda     offsetstep
        bit     #outoff_90b
        bne     AddLongTrigg   ; already contains 90 deg time, add it
;shouldn't get here
        bra     ck_nextcyl

of45:
        lsr     SparkTempH
        ror     SparkTempL
        bra     AddLongTrigg

ck_xlong:
        ; Check for long trigger (more than 90 deg)
        lda     SparkConfig1_f
        bit     #M_SC1LngTrg
        beq     ck_nextcyl

xl45:
        ; Divide 90 deg time by 2 to get 45 deg time (112.5 to 135 deg)
        lsr     SparkTempH
        ror     SparkTempL

        ; Jump out if extra long trigger
        bit     #M_SC1XLngTrg
        bne     AddLongTrigg

xl22:
        ; Divide 45 deg time by 2 to get 22.5 deg time (90 to 112.5 deg)
        lsr     SparkTempH
        ror     SparkTempL

AddLongTrigg:
        ; Add extra time for long trigger
        lda     SparkDelayL
        add     SparkTempL
        sta     SparkDelayL
        lda     SparkDelayH
        adc     SparkTempH
        sta     SparkDelayH

ck_nextcyl:
;check for next cyl mode - only get here if NOT in long-trigger
        brclr   nextcyl,EnhancedBits4,SDelayDone

;now actual delay = itime - "spark delay"
;i.e. if trigger = 10, advance = 17 -> want 7 degrees ahead of trigger
; so we calc the time for 7 deg and then take that time off the iTime
;cTime?cp was saved earlier as the predicted time for this period
        lda     cTimeLcp
        sub     SparkDelayL
        sta     SparkDelayL
        lda     cTimeHcp
        sbc     SparkDelayH
        sta     SparkDelayH

SDelayDone:

        brset   SparkHSpeed,SparkBits,set_spk_timer	; High speed set timer
        brclr   dwellcont,feature7,j_SSC
;if next_cyl and cranking then skip
        brclr   nextcyl,EnhancedBits4,sdd2
        brset   crank,engine,j_SSC   ; can cause a conflict

sdd2:
; low speed dwell
; a copy of some of Calcdwell, but simplified...

; uses SparkTempH/L for temporary space

        lda     SparkDelayL
        sub     dwelldms
        sta     SparkTempL
        lda     SparkDelayH
        sbc     #0
        sta     SparkTempH
        bcc     lsd_done
; < zero = OOOPS! set minimal period
lsd_min:				; target dwell period>available period
        clrh
        ldx     #1			; turn on coil as soon as we can
        bra     lsd_done2
lsd_done:
        ldhx    SparkTempH
lsd_done2:
        brset   coilabit,coilsel,lsd_a
        brset   coilbbit,coilsel,lsd_b
        brset   coilcbit,coilsel,lsd_c
        brset   coildbit,coilsel,lsd_d
        brset   coilebit,coilsel,lsd_e
        brset   coilfbit,coilsel,lsd_f
j_SSC:
        jmp     SKIP_CYCLE_CALC
lsd_a:  sthx    SparkOnLeftah		; Store time to keep output the same
        jmp     SKIP_CYCLE_CALC
lsd_b:  sthx    SparkOnLeftbh		; Store time to keep output the same
        jmp     SKIP_CYCLE_CALC
lsd_c:  sthx    SparkOnLeftch		; Store time to keep output the same
        jmp     SKIP_CYCLE_CALC
lsd_d:  sthx    SparkOnLeftdh		; Store time to keep output the same
        jmp     SKIP_CYCLE_CALC
lsd_e:  sthx    SparkOnLefteh		; Store time to keep output the same
        jmp     SKIP_CYCLE_CALC
lsd_f:  sthx    SparkOnLeftfh		; Store time to keep output the same
        jmp     SKIP_CYCLE_CALC

set_spk_timer:
        brclr   dwellcont,feature7,do_set_spk
;if next_cyl and cranking then skip
        brclr   nextcyl,EnhancedBits4,sst2
        brset   crank,engine,do_set_spk   ; can cause a conflict
sst2:
; now see if we've time for dwell before spark
; this will work when rpm/advance are low and dwell doesn't start
; before trigger this doesn't leave any margin... could be trying to start
; dwell too soon after now and due to latency we'll miss it?

;026g add hysteresis to hrd mode to see if it helps my "1500rpm miss"
; if time < 0.512ms then OFF
; if time > 0.768ms then ON
;in between follows last state

        lda     SparkDelayL
        sub     dwellusl
        tax
        lda     SparkDelayH
        sbc     dwellush
        bcs     hrd_off     ; if negative then OFF
        cmp     #1
        bls     hrd_off     ; <= .511ms so OFF
        cmp     #2
        bhi     hrd_on      ; > 0.768ms so ON
        bra     hrd_ck      ; in between so no change

hrd_on:
; for testing we can disable hi-res dwell altogether
;        lda     feature6_f
;        bit     #hrd_disableb
;        bne     hrd_off        ; disabled
        bset    hrdwon,EnhancedBits6
        bra     hrd_ck
hrd_off:
        bclr    hrdwon,EnhancedBits6
hrd_ck:
        brclr    hrdwon,EnhancedBits6,do_set_spk   ; hrd bit off, so skip

; now want to work out the dwell delay.
;first work out the target time for the spark and store away
dwl_ok:
        lda     SparkDelayL
        add     T2CurrL
        sta     SparkTargetL		; Store low byte in target area
        lda     SparkDelayH
        adc     T2CurrH
        sta     SparkTargetH

;now calc dwell start point into SparkDelay
        lda     SparkDelayL
        sub     dwellusl
        sta     SparkDelayL		; now dwell delay L
        lda     SparkDelayH
        sbc     dwellush
        sta     SparkDelayH		; H
        bset    indwell,EnhancedBits4	; flag that we are doing dwell
					; delay not spark delay

; make sure lowres dwell timers are zero to prevent early less accurate dwell
; change... don't reset the timer. If the timer gets there first it
; should be ignored, but that doesn't FFFFING work???!?!? so zero out the
; timers here anyway
;
        ldhx    #0
        brset   coilabit,coilsel,zd_a
        brset   coilbbit,coilsel,zd_b
        brset   coilcbit,coilsel,zd_c
        brset   coildbit,coilsel,zd_d
        brset   coilebit,coilsel,zd_e
        brset   coilfbit,coilsel,zd_f
        bra     do_set_spk		; how?
zd_a:   sthx    SparkOnLeftah		; Store time to keep output the same
        bra     do_set_spk
zd_b:   sthx    SparkOnLeftbh		; Store time to keep output the same
        bra     do_set_spk
zd_c:   sthx    SparkOnLeftch		; Store time to keep output the same
        bra     do_set_spk
zd_d:   sthx    SparkOnLeftdh		; Store time to keep output the same
        bra     do_set_spk
zd_e:   sthx    SparkOnLefteh		; Store time to keep output the same
        bra     do_set_spk
zd_f:   sthx    SparkOnLeftfh		; Store time to keep output the same

do_set_spk:
        lda     SparkDelayL
	sub     latency_f
	sta     SparkDelayL
	lda     SparkDelayH
	sbc     #0
	sta     SparkDelayH
	bcc     dss2
	clr     SparkDelayH
	lda     #$40
	bra     setit2
dss2:
;check not too soon - minimum delay of 64us
        lda     SparkDelayH
        bne     setit
        lda     SparkDelayL
        cmp     #$40
        bhi     setit
        lda     #$40
        bra     setit2
setit:
        ; Add total highres spark delay time to timer value from IRQ
	; start and set interrupt
        lda     SparkDelayL
setit2:
        add     T2CurrL
        tax				; Store low byte
        lda     SparkDelayH
        adc     T2CurrH
        sta     T2CH1H			; Write high byte timer output
					; compare first
        stx     T2CH1L			; Then low byte

        bclr    TOF,T2SC1		; clear pending interrupt
        bset    TOIE,T2SC1		; Enable timer interrupt

	; rotary low revs ...

	brclr	rotary2,EnhancedBits5,skip_rotary_jmp
	brset	indwell,EnhancedBits4,do_rotary_dwl
skip_rotary_jmp:
	jmp	SKIP_CYCLE_CALC

do_rotary_dwl:
	brclr	rsh_s,EnhancedBits5,SKIP_CYCLE_CALC
	brclr	rsh_r,EnhancedBits5,SKIP_CYCLE_CALC

	; Add rotary split to the SparkDelay

	lda	SparkDelayL
	add	splitdelL
	sta	SparkTempL
	lda	SparkDelayH
	adc	splitdelH
	sta	SparkTempH

	; Div by 100 to get 1/10th ms value

	clrh
	ldx	#100T
	lda	SparkTempH
	div
	sta	SparkTempH
	lda	SparkTempL
	div
	sta	SparkTempL

	; now pick which coil gets the dwell, and store it there.

        ldhx    #0T
        sthx    SparkOnLeftch
        sthx    SparkOnLeftdh
	ldhx	SparkTempH
	brset	rotaryFDign,feature1,set_FD_coils
	brset	coilabit,coilsel,rotary_set_coilc
	brset	coilbbit,coilsel,rotary_set_coild
	bra	end_rotary_dwell ; shouldn't get here

set_FD_coils:
	brset	coilabit,coilsel,rotary_set_coild
	brset	coilbbit,coilsel,rotary_set_coilc
	bra	end_rotary_dwell ; shouldn't get here

rotary_set_coilc:
	sthx	SparkOnLeftch
	bra	end_rotary_dwell

rotary_set_coild:
	sthx	SparkOnLeftdh

end_rotary_dwell:

SKIP_CYCLE_CALC:
; are we logging triggers?
        brclr   triglog,EnhancedBits5,w_dec_notlogt
        ;we are logging so record something
        clrh

        ldx     VE_r+PAGESIZE-2
        brset   SparkHSpeed,SparkBits,tl_high
;tl_low:
        lda     #1
        sta     VE_r+PAGESIZE-1
        lda     rpmch
        sta     VE_r,x
        incx
        lda     rpmcl
        bra     tl_cont
tl_high:
        clra
        sta     VE_r+PAGESIZE-1
        lda     iTimeH
        bne     tlhh
        lda     #$FF
tlhh:
        sta     VE_r,x
        incx
        lda     iTimeL
        bne     tl_cont
        lda     #$FF
tl_cont:
        sta     VE_r,x
        incx
        cpx     #PAGESIZE-4
        blo     wdtlt
        clrx
wdtlt:
        stx     VE_r+PAGESIZE-2
w_dec_notlogt:

        lda     T2CurrX
        sta     T2LastX		; Make current value last
        lda     T2CurrH
        sta     T2LastH
        lda     T2CurrL
        sta     T2LastL

        mov       rpmch,rpmph
        mov       rpmcl,rpmpl

        clr       rpmch
        clr       rpmcl
        bset      fuelp,porta		; Turn on fuel Pump
;scc_run:
        bset      running,engine	; Set engine running value
        brclr     dwellcont,feature7,no_dwell
        ;figure out if we want to schedule dwell now
;;        brclr   crank,engine,bsc1	; we don't
        ; if in crank mode then min_dwell does same thing
        jmp       squirtCheck1

no_dwell:
        brclr     min_dwell,feature2,bsc1
        ; if minimal dwell set coil to charge in 0.1ms
        ; this should help HEI4 pin until I've written dwell
	; control as the high time starts at the trigger
scc_hei4:
        bclr    sparkon,revlimbits	; spark now off
        brset   invspk,EnhancedBits4,sccr_inv
        COILPOS				; charge coil for non-inverted
bsc1:
        bra     squirtCheck1
sccr_inv:
        COILNEG				; charge coil for inverted

*********** now schedule some fuel injection ************

squirtCheck1:
        brset     crank,engine,schedule1a	; Squirt on every pulse
					; if cranking

        inc       IgnCount1		; Check to see if we are to
					; squirt or skip
        lda       IgnCount1
        cmp       divider_f1
        beq       schedule1
        cmp       #16T			; The maximum allowed - reset if match
        blo       squirtDone1
        clr       IgnCount1
        bra       squirtDone1

schedule1:
        clr       IgnCount1

 ;       lda       DTmode_f		; check if DT in use
 ;       bit       #alt_i2t2
 ;       bne       schedule1a		; i2t2=1

        lda       alternate_f1
        beq       schedule1a
        inc       altcount1
        brset     0,altcount1,squirtDone1
schedule1a:
        mov       pwcalc1,pw1
        beq       squirtDone1		; check for zero pulse
        bset      sched1,squirt
        bset      inj1,squirt
squirtDone1:

;-------------------------------------------------------------------------------

squirtCheck2:
        lda       DTmode_f		; check if DT in use
        bit       #alt_i2t2
        bne       sc2dual		; i2t2=1

sc2single:
        brset     crank,engine,schedule2sa	; Squirt on every pulse
					; if cranking

        inc       IgnCount2		; Check to see if we are to
					; squirt or skip
        lda       IgnCount2
        cmp       divider_f1
        beq       schedule2s
        lda       IgnCount2
        cmp       #16T			; The maximum allowed - reset if match
        blo       squirtDone2
        clr       IgnCount2
        bra       squirtDone2

schedule2s:
        clr       IgnCount2
        lda       alternate_f1
        beq       schedule2sa
        inc       altcount2
        brclr     0,altcount2,squirtDone2
schedule2sa:
        mov       pwcalc2,pw2
        beq       squirtDone2		; check for zero pulse
        bset      sched2,squirt
        bset      inj2,squirt
        bra       squirtDone2

sc2dual:
        brset     crank,engine,schedule2da	; Squirt on every pulse
					; if cranking

        inc       IgnCount2		; Check to see if we are to
					; squirt or skip
        lda       IgnCount2
        cmp       divider_f2
        beq       schedule2d
        lda       IgnCount2
        cmp       #16T			; The maximum allowed - reset if match
        bne       squirtDone2
        clr       IgnCount2
        bra       squirtDone2

schedule2d:
        clr       IgnCount2
        lda       alternate_f1
        beq       schedule2da
        inc       altcount2
        brclr     0,altcount2,squirtDone2
schedule2da:
        mov       pwcalc2,pw2
        beq       squirtDone2		; check for zero pulse
        bset      sched2,squirt
        bset      inj2,squirt

squirtDone2:

IRQ_EXIT:
        brset     MSNEON,personality,IRQ_EXIT2
        brset     WHEEL,personality,IRQ_EXIT2
        lda       feature6_f
        bit       #falsetrigb           ; can disable false trigger protection for testing
        bne       IRQ_EXIT2
; These are used to reduce/prevent false triggers but no good for
; the multi-toothed wheels
	bset	  ACK,INTSCR		; Flush out any new interrupts pending
	bset	  IMASK,INTSCR		; Disable IRQ interrupts
        bset      IRQF,INTSCR		; read only ?!?! Won't do anything
IRQ_EXIT2:
        pulh
        rti

***************************************************************************
**
** ADC - Interrupt for ADC conversion complete
**
***************************************************************************
ADCDONE:
        pshh				; Do this because processor does
					; not stack H

        clrh
; Store previous values for derivative
        lda     adsel
        beq     KPa_ADC_Check           ; If doing ADC 0 then check for fixed KPa
        cmp     #$06
        beq     FUEL_JUMP		; Check the fuel pressure sensor
        cmp     #$07
        beq     EGT_JUMP		; Check the EGT input
        bra     Normal_ADSEL

KPa_ADC_Check:
       	brclr   startw,engine,NormMAP_Count ; Are we in ASE mode?
        lda     feature10_f5
        bit     #MAPHoldb           ; Are we holding the MAP at a fixed value during ASE?
        beq     NormMAP_Count
        brset   FxdASEDone,EnhancedBits4,NormMAP_Count  ; Is Fixed ASE done?

        lda     coolant             ; We are in fixed MAP mode
        cmp     CltFixASE_f         ; so are we below the temperature setpoint?
        bls     FixdMAP_ASE
        bra     NormMAP_Count        ; Normal MAP mode

FixdMAP_ASE:
        lda     ASEcount
        cmp     TimFixASE_f
        blo     FixdMAP2                  ; Have we passed the Fixed timer yet?

        bset    FxdASEDone,EnhancedBits4  ; SET the Fixed bit so we dont do it again.
        bra     NormMAP_Count             ; Normal MAP mode

FixdMAP2:
        lda     adr
        lda     MAPFixASE_f               ; We are in fixed MAP mode during ASE, load value
        sta     map
        sta     lmap
        bra     Done_FIXMAP

NormMAP_Count:
        clra                            ; reset offset to zero

Normal_ADSEL:
        tax
        lda     map,x
        sta     lmap,x			; Store the old value

	lda	adr			; Load in the new ADC reading
        add     map,x			; Perform (map + last_map)/2
					; averaging (for all ADC readings)
        rora
	sta	map,x			; MAP is entry point, offset is
					; loaded in index register
Done_FIXMAP:
	lda     adsel
	inca
	cmp	#$08
	bne	ADCPTR
	clra
        bra     ADCPTR

FUEL_JUMP:
       lda      adr
       sta      o2_fpadc			; Fuel Pressure, wheel sensor or
					; second O2 sensor
       lda      adsel
       inca
       bra      ADCPTR

EGT_JUMP:
       lda      adr
       sta      egtadc			; EGT sensor or wheel sensor input.
       clra
ADCPTR:
       sta      adsel
       pulh
       rti
***************************************************************************
**
** SCI Communications
**
** Communications is established when the PC communications program sends
** a command character - the particular character sets the mode:
**
** "A" = send all of the realtime variables via txport.
** "V" = send the VE table and constants via txport (128 bytes)
** "W"+<offset>+<newbyte> = receive new VE or constant byte value and
**  store in offset location
** "X"+<offset>+<count>+<newbyte>+<newbyte>.... = receive series of new data bytes
** "B" = jump to flash burner routine and burn VE/constant values in RAM into flash
** "C" = Test communications - echo back SECL
** "Q" = Send over Embedded Code Revision Number (irrelevant in Extra, send zero)
** "S" = Signature - update every time there is a change in data format 32 bytes
** "T" = full code revision in text. 32 bytes
** "P"+<page> = load page of data from Flash to RAM

** txmode:
**              01 = Getting realtime data
**              02 = ?
**              03 = Sending VE
**              04 = sending signature
**              05 = Getting offset VE
**              06 = Getting data VE
**              07 = Getting offset chunk write
**              08 = Getting count  chunk write
**              09 = Getting data   chunk write
**              0A = Bootloader
**              0B = version string
**              0C = getting table number
**              0D = config error message
**              0E = format string
***************************************************************************
IN_SCI_RCV:
        pshh
        lda     SCS1			; Clear the SCRF bit by reading
					; this register

        lda     txmode			; Check if we are in the middle
					; of a receive new VE/constant
        cbeqa   #$05,TXMODE_5
        cbeqa   #$06,TXMODE_6
        cbeqa   #$07,TXMODE_7
        cbeqa   #$08,TXMODE_8
        cbeqa   #$09,TXMODE_9
        cbeqa   #$0C,TXMODE_C1
        jmp     CHECK_TXCMD
TXMODE_C1:      jmp TXMODE_C

TXMODE_5:				; Getting offset for W command
        mov     SCDR,rxoffset
        inc     txmode			; continue to next mode
        jmp     DONE_RCV
TXMODE_6:
        brset   mv_mode,EnhancedBits2,TX6_MV
        clrh
        lda     SCDR
        ldx     rxoffset
        sta     VE_r,x   ; store it in ram regardless of page
        clr     txmode
TX6_MV:					; in MV mode, just ignore any data sent
        jmp     DONE_RCV

TXMODE_7:				; Getting offset for X command
        mov     SCDR,rxoffset
        inc     txmode			; continue to next mode
        jmp     DONE_RCV

TXMODE_8:				; Getting count for X command
        mov     SCDR,txgoal		; borrow txgoal as we aren't
					; going to using it
        inc     txmode			; continue to next mode
        jmp     DONE_RCV

TXMODE_9:
        clrh
        lda     SCDR
        ldx     rxoffset
        sta     VE_r,x   ; store it in ram regardless of page
        inc     rxoffset
        dec     txgoal			; count down
        bne     TXMODE_9_CONT
        clr     txmode			; have received all bytes we expected
TXMODE_9_CONT:
        jmp     DONE_RCV

;MODE_B moved up here to enable relative branches
MODE_B:
        lda     page
        cmp     #$10                    ; see if tooth logging or invalid page
        blo     MODE_B_OK               ; if it is then do not burn
        jmp     DONE_B
MODE_B_OK:
        bclr    SCRIE,SCC2		; turn off receive interrupt
					; so don't re-enter
;        cli				; re-enable interrupts to reduce
					; stumble during Burn. Too bad
        mov     #$CC,flocker
        jsr     burnConst		; routine disables interrupts during
					; critical sections
;        cli				; returns with ints off
        clr     flocker
        clr     txmode

        lda     page			; check if page0, if so reload
					; quick vars
        beq     ck_page0
        cbeqa   #3,ck_page3             ; do trigger angle / next cyl calc
        cbeqa   #7,ck_page7             ; do rotary setting check
        bra     DONE_B

ck_page0:
; Set up RAM Variable - also when burning page0 search for "burning page0"
        lda     feature1_f
        sta     feature1
        lda     feature2_f
        sta     feature2
;        lda     feature3_f
;        sta     feature3		; ram copy removed
;        lda     feature4_f
;        sta     feature4		; ram copy removed
;        lda     feature5_f
;        sta     feature5		; ram copy removed
;        lda     feature6_f
;        sta     feature6		; ram copy removed
        lda     feature7_f
        sta     feature7
;        lda     feature8_f
;        sta     feature8		; ram copy removed
        lda     outputpins_f
        sta     outputpins
        lda     personality_f
        sta     personality		; move from flash to ram

;is PTC4 (pin11) an input (trig2) or output (shiftlight)
        brclr   wd_2trig,feature1,ckp0_norm_ddrc
        lda     #%00001111              ; make PTC4 an input for second trigger
        bra     ckp0_ddrc
ckp0_norm_ddrc:
        lda     #%00011111		; ** Was 11111111
ckp0_ddrc:
        sta     ddrc			; Outputs for LED

;decide if we are doing multiple wasted spark outputs
;check this here so a changed setting or MSQ load will correctly init the variables
        brset   MSNEON,personality,pz_wspk
        brset   WHEEL,personality,pz_wspk
pz_nwspk:
        bclr    wspk,EnhancedBits4	; set that we are NOT doing wasted spark
        bra     DONE_B
pz_wspk:
        brclr   REUSE_LED19,outputpins,pz_nwspk
        brset   rotary2,EnhancedBits5,pz_nwspk
        bset    wspk,EnhancedBits4	; set that we are doing wasted spark
        bra     DONE_B

ck_page3:
;see if inverted or non-inv output and use a quick bit
        lda     SparkConfig1_f		; check if noninv or inv spark
        bit     #M_SC1InvSpark
        bne     ckp3_inv
        bclr    invspk,EnhancedBits4	; set non-inverted
        bra     ckp3_i_done
ckp3_inv:
        bset    invspk,EnhancedBits4	; set inverted
ckp3_i_done:


;EDIS and NEON are never next-cylinder
        brset   EDIS,personality,not_nc
        brset   MSNEON,personality,not_nc

        lda     TriggAngle_f
        cmp     #57T			; check for next cyl mode
        bhi     not_nc		; trigger angle > 20, continue
        bset    nextcyl,EnhancedBits4
        bra     DONE_B
not_nc:
        bclr    nextcyl,EnhancedBits4
        bra     DONE_B

ck_page7:
        lda     p8feat1_f
        bit     #rotary2b
        beq     ckp7nr
        bset    rotary2,EnhancedBits5
        bclr    wspk,EnhancedBits4	; set that we are NOT doing normal wasted spark
        bra     DONE_B
ckp7nr:
        bclr    rotary2,EnhancedBits5
DONE_B:
        bset    SCRIE,SCC2		; re-enable receive interrupt
        jmp     DONE_RCV
;
CHECK_TXCMD:
        lda     SCDR    ; Get the command byte
        cbeqa   #'A',MODE_A		; realtime vars
        cbeqa   #'B',jMODE_B		; All I hear is BURN
        cbeqa   #'C',MODE_C		; Comm test
        cbeqa   #'V',MODE_V		; (VE) read page
        cbeqa   #'W',jMODE_W		; Write byte
	cbeqa	#'Q',jMODE_Q		; Query version
        cbeqa   #'P',jMODE_P		; Page select
        cbeqa   #'!',jMODE_BOOT		; bootloader
        cbeqa   #'S',jMODE_SIGN		; signature
        cbeqa   #'R',MODE_R		; Added for enhanced stuff was "a"
					; now "R" for Megatunix compatabilty
        cbeqa   #'X',jMODE_X		; Chunk write
        cbeqa   #'T',jMODE_T		; Text version
        jmp     DONE_RCV

jMODE_B:        jmp     MODE_B
jMODE_W:        jmp     MODE_W
jMODE_Q:        jmp     MODE_Q
jMODE_P:        jmp     MODE_P
jMODE_BOOT:     jmp     MODE_BOOT
jMODE_SIGN:     jmp     MODE_SIGN
jMODE_X:        jmp     MODE_X
jMODE_T:        jmp     MODE_T

MODE_A:         ; Big A
        mov     #$16,txgoal		; B&G mode ($17) For Megaview use
        bra     MODE_AA_cont

MODE_R:        ; Big R
        bclr    mv_mode,EnhancedBits2	; clear MegaView mode to allow
					; enhanced comms
        mov     #39T,txgoal		; was 32T in 021, was 36T in 021u,
					; 38T from 021x1 onwards, 023b2:39T
;        mov     #47T,txgoal		; added another 8 bytes for debug

MODE_AA_cont:
;not here - only save when about to send
;        mov     iTimeL,cTimeCommL	; Copy cycle time to comm area
;        mov     iTimeH,cTimeCommH	; otherwise it might get out of
					; sync during communication
        clr     txcnt			; Send back all real-time variables
        lda     #$01
        bra     EN_XMIT

MODE_C:
        clr     txcnt			; Just send back SECL variable to
					; test comm port
        mov     #$1,txgoal
        lda     #$01
        bra     EN_XMIT

MODE_V:
        clr     txcnt
        brset   mv_mode,EnhancedBits2,MODE_V_MV
        mov     #PAGESIZE,txgoal		; no. of bytes to send back
					; (was $7e) was 201 now 213
					; for 12x12 NOW 201 again:-)
        lda     page
        cbeqa   #$F0,MODE_V_F0
        cbeqa   #$F1,MODE_V_F1
;ensure trigger/tooth loggers OFF
        bclr    toothlog,EnhancedBits5
        bclr    triglog,EnhancedBits5
        cbeqa   #$F2,MODE_V_F23
        cbeqa   #$F3,MODE_V_F23
        bra     MODE_V2
MODE_V_F0:
        bclr    toothlog,EnhancedBits5
        bra     MODE_V2
MODE_V_F1:
        bclr    triglog,EnhancedBits5
        bra     MODE_V2
MODE_V_F23:
        clr     txgoal    ; send back all 256 bytes (perhaps)
        bra     MODE_V2
MODE_V_MV:
        mov     #$7D,txgoal
MODE_V2:
        lda     #$03
        bra     EN_XMIT
MODE_W:
        mov     #$05,txmode
        bra     DONE_RCV

MODE_X:
        bclr    mv_mode,EnhancedBits2	; clear MegaView mode to allow
					; enhanced comms
        mov     #$07,txmode
        bra     DONE_RCV

MODE_Q:
        clr     txcnt			; Just send back SECL variable
					; to test comm port
        mov     #$1,txgoal
        lda     #$05
        bra     EN_XMIT

MODE_T:
        clr     txcnt
        mov     #$20,txgoal		; Send 32 Chars of Text version
        lda     #$0E			; TXMode = sending format string
        bra     EN_XMIT

MODE_P:
        bclr    mv_mode,EnhancedBits2	; clear MegaView mode to allow
					; enhanced comms
        mov     #$0C,txmode		; txmode = getting page number
        bra     DONE_RCV

MODE_SIGN:				; Send Signature text - DJLH
        bclr    mv_mode,EnhancedBits2	; clear MegaView mode to allow
					; enhanced comms
        clr     txcnt
        mov     #$20,txgoal		; Send 32 Chars of Signature
        lda     #$04			; TXMode = sending signature
EN_XMIT:
        sta     txmode
        bset    TE,SCC2			; Enable Transmit
        bset    SCTIE,SCC2		; Enable transmit interrupt

DONE_RCV:
        pulh
        rti

MODE_BOOT:
        lda     txmode
        cmp     #$0A
        beq     jBootLoad
        mov     #$0A,txmode
        bra     DONE_RCV
jBootLoad:
        jmp     BootLoad

CONF_ERR:
        ldhx    tmp5			; tmp5,6 contain absolute
					; address of data
        lda     ,x
        bne     conf_err2		; zero is string terminator
        clr     txmode
        jmp     FIN_TX
conf_err2:
        sta     SCDR			; Send char
        aix     #1
        sthx    tmp5
        jmp     DONE_BYTE

tx_done:
;we get here after we've sent the last byte
        bclr    TE,SCC2			; Disable Transmit
        bclr    SCTIE,SCC2		; Disable transmit interrupt
        pulh
        rti

jIN_SIGN_MODE:         jmp       IN_SIGN_MODE
jIN_T_MODE:            jmp       IN_T_MODE
jIN_V_MODE:            jmp       IN_V_MODE
*** Transmit Character Interrupt Handler ***************
IN_SCI_TX:
        pshh
        lda     SCS1			; Clear the SCRF bit by reading
					; this register
        clrh
        ldx     txcnt
        lda     txmode
        beq     tx_done
	cbeqa	#$05,IN_Q_MODEJMP
        cbeqa   #$04,jIN_SIGN_MODE      ; see above
        cbeqa   #$0D,CONF_ERR           ; see above
        cbeqa   #$0E,jIN_T_MODE         ; see above
        cmp     #$01
        bne     jIN_V_MODE
IN_A_OR_C_MODE:
;check for iTime sending. Now send three bytes but don't waste extra byte, only store two
        cpx     #22T
        bne     ac_chk38
        lda     iTimeH
        mov     iTimeL,cTimeCommL	; Copy cycle time to comm area
        mov     iTimeX,cTimeCommH	; otherwise it might get out of
        jmp     CONT_TX			; sync during communication
ac_chk38:
        cpx     #38T
        bne     ac_chk37
        lda     bcDC
        jmp     CONT_TX
ac_chk37:
        cpx     #37T
;        bhi     R_otherbytes
        bne     ac_chk36
        lda     cTimeCommH  ; actually holds iTimeX
        jmp     CONT_TX

;R_otherbytes:
;        lda     dwelldelay1-38T,X	; send dwell delays, may get data corruption
;        bra     CONT_TX
ac_chk36:
        cpx     #36T
        bne     NotTPSLAst_Yet
        lda     TPSlast
        jmp     CONT_TX

NotTPSLAst_Yet:
        cpx     #35T
        bne     inac_cont
        tsx     ; send stack
        txa
        jmp     CONT_TX
inac_cont:
        cpx     #30T
        bhi     send_ports

;Added for MV compatability with 300 & 400KPa MAP sensors
        cpx     #04T			; Are we about to send the MAP value?
        bne     Send_Data_Normal	; No so carry on as normal
        brclr   mv_mode,EnhancedBits2,Send_Data_Normal	; Yes so are we in
					; MV mode?

        lda     config11_f1
        and     #$03
        cbeqa   #2T,kpa300_reading
        cbeqa   #3T,kpa400_reading
        bra     send_data_normal

kpa300_reading:
; If we are here we are using a 300KPa sensor and we have a MV connected,
; so send 86% of the raw map value to MV so it converts it correctly
        lda     kpa
        cmp     #217T
        bhi     Load_Max_Map		; If raw map > 217 then we are
					; above 255KPa, thats the limit in MV
        tax
        lda     #219T			; 86% = 219 in 255 bytes
        mul
        txa
        bcc     Send_Fudged_Data
        inca
        bra     Send_Fudged_Data

IN_Q_MODEJMP:
        bra    IN_Q_MODE

; If we get here we are using a 400KPa sensor and we have a MV connected,
; so send 63% of the raw map value to MV
KPa400_Reading:
        lda     kpa
        cmp     #159T
        bhi     Load_Max_Map		; If raw map > 159 then we are
					; above 255KPa, the limit in MV
        tax
        lda     #160T
        mul
        txa
        bcc     Send_Fudged_Data
        inca
        bra     Send_Fudged_Data

Load_Max_Map:
        lda     #255T			; Load in KPa limit
Send_Fudged_Data:
        bra     CONT_TX


Send_Data_Normal:
        lda     secl,X
        bra     CONT_TX
send_ports:
        txa
        sub     #31T
        tax
        lda     porta,X			; load porta,b,c,d 31=a, 34=d
        cpx     #2
        bne     CONT_TX
        brclr   config_error,feature2,CONT_TX
        ora     #128T   ; set top bit in portc if config error
        bra     CONT_TX
IN_V_MODE
        lda     page
        cbeqa   #$F2,V_f2
        cbeqa   #$F3,V_f3
        brset   mv_mode,EnhancedBits2,IN_V_MV
        lda     ve_r,x			; get data from RAM (must have
					; loaded a page first)
	bra	CONT_TX
IN_V_MV:
        jmp     MV_V_EMUL
V_f2:
        cpx     #$40
        blo     V_f2zero
        lda     0,x
        bra     CONT_TX
V_f2zero:
        clra
        bra     CONT_TX
V_f3:
        lda     $0100,x
        bra     CONT_TX
IN_SIGN_MODE:
	lda	SIGNATURE,x
	bra	CONT_TX
IN_T_MODE:
	lda	textversion_f,x
	bra	CONT_TX
IN_Q_MODE:
	lda	REVNUM,X

CONT_TX:
        sta     SCDR			; Send char
        lda     txcnt
        inca				; Increase number of chars sent
        sta     txcnt
        cmp     txgoal			; Check if done
        bne     DONE_BYTE		; Branch if NOT finished to DONE_BYTE

FIN_TX:
        clr     txcnt
        clr     txgoal
        clr     txmode

;  do these on next entry with TXMODE=0
;        bclr    TE,SCC2			; Disable Transmit
;        bclr    SCTIE,SCC2		; Disable transmit interrupt

DONE_BYTE:
        pulh
        rti

BootLoad:
        bset     IMASK,INTSCR		; disable interrupts for IRQ
					; (the ignition i/p)

; that should be enough to stop the engine and then keep it stalled
; I wouldn't recommend updating the flash with a running engine anyway
; stop timers, disable interrupts
        bset     TSTOP,T1SC
        bclr     TOIE,T1SC
        bset     TSTOP,T2SC
        bclr     TOIE,T2SC

; switch off inj1
        bset     inject1,portd		; ^* * * Turn Off Injector #1
					; (inverted drive)
        bclr     firing1,squirt
        bclr     sched1,squirt
        bclr     inj1,squirt

; switch off inj2
        bset     inject2,portd		; ^* * * Turn Off Injector #2
					; (inverted drive)
        bclr     firing2,squirt
        bclr     sched2,squirt
        bclr     inj2,squirt

        clr      engine			; Engine is stalled, clear all
					; in engine settings
        bclr     fuelp,porta		; Turn off fuel pump
        clr      rpmch
        clr      rpmcl
        clr      pw1			; zero out pulsewidths
        clr      pw2
        clr      rpm

; turn spark outputs to inactive to avoid burning out coil. This will
; cause coils to fire, but that in unavoidable. A "non-inverted" output
; charges coil when signal from board is high i.e. the output pin is low.
; So to make inactive set these pins high
; if inverted set low

        TurnAllSpkOff			; macro to turn off all spark outputs

        jmp      BootReset1

MV_V_EMUL:
        ; we are in Megaview mode. Ideally we'd like to return a B&G
	;style view of our data
        cpx     #116T
        blo     V_MV2
        txa				; need to return config11,12,13
					; to get correct map reading
        add     #88T			; B&G byte 116 is at 204 in this code
        tax
        lda     config11_f1,x
        jmp     CONT_TX
V_MV2:
        clra				; for now, return zero.
        jmp	CONT_TX

TXMODE_C:
        lda     SCDR			; expect 0 to 7 or $F0 or $F1
        cmp     page			; check if already loaded
        beq     DONE_LOAD
        cbeqa   #$F0,toothl_F0
        cbeqa   #$F1,toothl_F1
        cbeqa   #$F2,okpage
        cbeqa   #$F3,okpage
        bclr    toothlog,EnhancedBits5  ; ensure tooth logger is off
        bclr    triglog,EnhancedBits5  ; ensure tooth logger is off
        cmp     #10T			; only 0-8 used in code at present
        bhi     DONE_LOAD
        clrx
        sta     page
        add     #$E0			; hardcoded high byte of page
					; area $Ex00
        psha
        pulh
        bclr    SCRIE,SCC2		; turn off receive interrupt so
					; don't re-enter
        cli				; re-enable interrupts to reduce
					; stumble when MT changes page
load_table:
        lda     0,x			; h:x
        pshh
        clrh
        sta     VE_r,x			; dump into RAM. Bit of a kludge,
					; want h=0
        pulh
        incx
        cpx     #PAGESIZE+1		; copy 256 bytes
					; reduced to 200
					; Increased to 212 for 12x12
					; Back to 200 now for 022+
        bne     load_table
        bra     DONE_LOAD
okpage:
        sta     page
        bra     DONE_LOAD
toothl_F0:
        bset    toothlog,EnhancedBits5
        bra     tooth_log_setup
toothl_F1:
        bset    triglog,EnhancedBits5
tooth_log_setup:
        sta     page
        bclr    SCRIE,SCC2
        clra
        clrx
        clrh
clear_table:
        sta     VE_r,x			; dump into RAM. Bit of a kludge,
        incx
        cpx     #PAGESIZE+1			; clear PAGESIZE bytes
        bne     clear_table

;bytes VE_r+0 - VE_r+197 = data, VE_r+198 = counter

DONE_LOAD:
        bset    SCRIE,SCC2		; re-enable receive interrupt
        clr     txmode
        pulh				; (same as DONE_RECV)
        rti

***************************************************************************
**
** Timer 2 overflow, extends hardware timer with an extra byte in software
**
***************************************************************************
T2overflow:
        lda     T2SC		; Read interrupt
        bclr    TOF,T2SC	; Reset interrupt
        inc     T2CNTX          ; increment software byte
        bclr    roll1,EnhancedBits4    ; clear the roll-over detect bits
        bclr    roll2,EnhancedBits4
        rti
***************************************************************************
**
** Dummy ISR - just performs RTI
**
***************************************************************************
Dummy:					; Dummy vector - there just to
					; keep the assembler happy
	rti

***************************************************************************
**
** Various functions/subroutines Follow
**
**  - Ordered Table Search
**  - Linear Interpolation
**  - 32 x 16 divide
***************************************************************************


***************************************************************************
**
** Ordered Table Search
**
**  X is pointing to the start of the first value in the table
**  tmp1:2 initially hold the start of table address, then they hold the bound values
**  tmp3 is the end of the table (nelements - 1)
**  tmp4 is the comparison value
**  tmp5 is the index result - if zero then comp value is less than beginning of table, and
**    if equal to nelements then it is rail-ed at upper end
**
***************************************************************************
tablelookup:
        clr     tmp5
        ldhx    tmp1
        lda     ,x
;        sta     tmp1
        sta     tmp2
;        cmp     tmp4
;        bhi     GOT_ORD_NUM
REENT:
        incx
        inc     tmp5
        mov     tmp2,tmp1
        lda     ,x
        sta     tmp2

        cmp     tmp4
        bhi     GOT_ORD_NUM
        lda     tmp5
        cmp     tmp3
        bne     REENT

;        inc     tmp5
;        mov     tmp2,tmp1
GOT_ORD_NUM:
        rts

***************************************************************************
**
** Linear Interpolation - 2D
**
**            (y2 - y1)
**  Y = Y1 +  --------- * (x - x1)
**            (x2 - x1)
**
**   tmp1 = x1
**   tmp2 = x2
**   tmp3 = y1
**   tmp4 = y2
**   tmp5 = x
**   tmp6 = y
***************************************************************************
LININTERP:
        clr       tmp7			; This is the negative slope
					; detection bit
        mov     tmp3,tmp6
CHECK_LESS_THAN:
        lda     tmp5
        cmp     tmp1
        bhi     CHECK_GREATER_THAN
        bra     DONE_WITH_INTERP
CHECK_GREATER_THAN:
        lda     tmp5
        cmp     tmp2
        blo     DO_INTERP
        mov     tmp4,tmp6
        bra     DONE_WITH_INTERP

DO_INTERP:
        mov     tmp3,tmp6
        lda     tmp2
        sub     tmp1
        beq     DONE_WITH_INTERP
        psha
        lda     tmp4
        sub     tmp3
	bcc	POSINTERP
        nega
        inc     tmp7
POSINTERP:
        psha
        lda     tmp5
        sub     tmp1
        beq     ZERO_SLOPE
        pulx
        mul
        pshx
        pulh
        pulx

        div

        psha
        lda     tmp7
        bne     NEG_SLOPE
        pula
        add     tmp3
        sta     tmp6
        bra     DONE_WITH_INTERP
NEG_SLOPE:
        pula
        sta     tmp7
        lda     tmp3
        sub     tmp7
        sta     tmp6
        bra     DONE_WITH_INTERP
ZERO_SLOPE:
        pula				;clean stack
        pula				;clean stack
DONE_WITH_INTERP:
        rts


********************************************************************************
** Multiply then divide.
********************************************************************************

uMulAndDiv:

********************************************************************************
** 8 x 16 Multiply
**
** 8-bit value in Accumulator, 16-bit value in tmp11-12, result overwrites
** 16-bit input.  Assumes result cannot overflow.
********************************************************************************

uMul16:
      psha				; Save multiplier.
      ldx     tmp11			; LSB of multiplicand.
      mul
      sta     tmp11			; LSB of result stored.
      pula				; Pop off multiplier.
      pshx				; Carry on stack.
      ldx     tmp12			; MSB of multiplicand.
      mul
      add     1,SP			; Add in carry from LSB.
      sta     tmp12			; MSB of result.
      pula				; Clear the stack.

********************************************************************************
** 16-bit divide by 100T
**
** 16-bit value in tmp11-12 is divided by 100T.  Result is left in tmp11-12.
********************************************************************************

uDivBy100:
      clrh
      lda     tmp12			; MSB of dividend.
      ldx     #100T			; Divisor.
      div
      sta     tmp12			; MSB of quotient.
      lda     tmp11			; LSB of dividend.
      div
      sta     tmp11			; LSB of quotient.

      ; See if we need to round up the quotient.
      pshh
      pula				; Remainder in A.
      cmp     #50T			; Half of the divisor.
      ble     uDivRoundingDone
      inc     tmp11
      bcc     uDivRoundingDone
      inc     tmp12
uDivRoundingDone:
      rts

********************************************************************************
********************************************************************************
*
*     32 / 16 Unsigned Divide
*
*     This routine takes the 32-bit dividend stored in INTACC1.....INTACC1+3
*     and divides it by the 16-bit divisor stored in INTACC2:INTACC2+1.
*     The quotient replaces the dividend and the remainder replaces the divisor.
*
*     Re-written a bit by JSM to eliminate stack usage and use tmp vars instead of
*     8 bytes of reserved ram
; 1,SP = tmp9
; 2,SP = tmp10
; 3,SP = tmp11
UDVD32:
*
DIVIDEND  EQU     INTACC1+2
DIVISOR   EQU     INTACC2
QUOTIENT  EQU     INTACC1
REMAINDER EQU     INTACC1
*
;only called twice in code and regs don't need preserving
        LDA     #!32			;
        STA     tmp11			; loop counter for number of shifts
        LDA     DIVISOR			; get divisor msb
        STA     tmp9			; put divisor msb in working storage
        LDA     DIVISOR+1		; get divisor lsb
        STA     tmp10			; put divisor lsb in working storage
*
*     Shift all four bytes of dividend 16 bits to the right and clear
*     both bytes of the temporary remainder location
*
        MOV     DIVIDEND+1,DIVIDEND+3	; shift dividend lsb
        MOV     DIVIDEND,DIVIDEND+2	; shift 2nd byte of dividend
        MOV     DIVIDEND-1,DIVIDEND+1	; shift 3rd byte of dividend
        MOV     DIVIDEND-2,DIVIDEND	; shift dividend msb
        CLR     REMAINDER		; zero remainder msb
        CLR     REMAINDER+1		; zero remainder lsb
*
*     Shift each byte of dividend and remainder one bit to the left
*
SHFTLP  LDA     REMAINDER		; get remainder msb
        ROLA				; shift remainder msb into carry
        ROL     DIVIDEND+3		; shift dividend lsb
        ROL     DIVIDEND+2		; shift 2nd byte of dividend
        ROL     DIVIDEND+1		; shift 3rd byte of dividend
        ROL     DIVIDEND		; shift dividend msb
        ROL     REMAINDER+1		; shift remainder lsb
        ROL     REMAINDER		; shift remainder msb
*
*     Subtract both bytes of the divisor from the remainder
*
        LDA     REMAINDER+1		; get remainder lsb
        SUB     tmp10			; subtract divisor lsb from
					; remainder lsb
        STA     REMAINDER+1		; store new remainder lsb
        LDA     REMAINDER		; get remainder msb
        SBC     tmp9			; subtract divisor msb from
					; remainder msb
        STA     REMAINDER		; store new remainder msb
        LDA     DIVIDEND+3		; get low byte of dividend/quotient
        SBC     #0			; dividend low bit holds subtract carry
        STA     DIVIDEND+3		; store low byte of dividend/quotient
*
*     Check dividend/quotient lsb. If clear, set lsb of quotient to indicate
*     successful subraction, else add both bytes of divisor back to remainder
*
        BRCLR   0,DIVIDEND+3,SETLSB	; check for a carry from subtraction
					; and add divisor to remainder if set
        LDA     REMAINDER+1		; get remainder lsb
        ADD     tmp10			; add divisor lsb to remainder lsb
        STA     REMAINDER+1		; store remainder lsb
        LDA     REMAINDER		; get remainder msb
        ADC     tmp9			; add divisor msb to remainder msb
        STA     REMAINDER		; store remainder msb
        LDA     DIVIDEND+3		; get low byte of dividend
        ADC     #0			; add carry to low bit of dividend
        STA     DIVIDEND+3		; store low byte of dividend
        BRA     DECRMT			; do next shift and subtract

SETLSB  BSET    0,DIVIDEND+3		; set lsb of quotient to indicate
					; successive subtraction
DECRMT  DBNZ    tmp11,SHFTLP		; decrement loop counter and do next
					; shift
*
*     Move 32-bit dividend into INTACC1.....INTACC1+3 and put 16-bit
*     remainder in INTACC2:INTACC2+1
*
        LDA     REMAINDER		; get remainder msb
        STA     tmp9			; temporarily store remainder msb
        LDA     REMAINDER+1		; get remainder lsb
        STA     tmp10			; temporarily store remainder lsb
        MOV     DIVIDEND,QUOTIENT	;
        MOV     DIVIDEND+1,QUOTIENT+1	; shift all four bytes of quotient
        MOV     DIVIDEND+2,QUOTIENT+2	; 16 bits to the left
        MOV     DIVIDEND+3,QUOTIENT+3	;
        LDA     tmp9			; get final remainder msb
        STA     INTACC2			; store final remainder msb
        LDA     tmp10			; get final remainder lsb
        STA     INTACC2+1		; store final remainder lsb
*
        RTS				; return

        include "burner8b.asm"



***************************************************************************
**
** Computation of Normalized Variables
**
**  The following is the form of the evaluation for the normalized variables:
**
**  (A rem A * B)
**  -------------  = C rem C
**      100
**
**  Where A = Whole part of the percentage,
**        rem A = Remainder of A from previous calculation (range 0 to 99)
**        B = Percentage multiplied (this always has a zero remainder)
**        C = Whole part of result
**        rem C = remainder of result
**
**
**  Calculation is preformed by the following method:
**
**     |(A * B) + (rem A * B)|
**     |          -----------|
**     |              100    |
**     ----------------------- = C rem C
**             100
**
**
**   Inputs:  tmp10 = A
**            tmp11 = rem A
**            tmp12 = B
**
**   Outputs: tmp10 = C
**            tmp11 = rem C
**            tmp13 = high order part of (A rem A) * B
**            tmp14 = low order part of (A rem A) * B
**
***************************************************************************
Supernorm:
	lda	tmp10			; A
        tax
        lda     tmp12			; B
        mul
        stx     tmp13			; High order of A * B
        sta     tmp14			; Low order of A * B

        lda     tmp11			; rem A
        tax
        lda     tmp12			; B
        mul
        pshx
        pulh
        ldx     #$64			; 100
        div

        adc     tmp14			; Add to lower part
        sta     tmp14			; Store back
        bcc     Roundrem		; Branch is no carry occurred
        inc     tmp13			; Increment high-order part because
					; an overflow occurred in add

Roundrem:
        pshh
        pula
        cmp     #$32			; Round if division remainder is
					; greater than 50
        ble     FinalNorm
        lda     tmp14
        adc     #$01
        sta     tmp14
        bcc     FinalNorm
        inc     tmp13


FinalNorm:
        lda     tmp13
        psha
        pulh
        lda     tmp14
        ldx     #$64			; 100
        div
        bcs     RailCalc
        sta     tmp10
        pshh
        pula
        sta     tmp11

        cmp     #$32			; Round if division remainder is
					; greater than 50
        ble     ExitSN
        lda     tmp11
        adc     #$01
        sta     tmp11
        bcc     ExitSN
        lda     tmp10
        add     #$01
        sta     tmp10
        bne     ExitSN

RailCalc:
        mov     #$FF,tmp10		; Rail value if rollover

ExitSN:
        rts

******************************************************************************
**   Nitrous System   (P Ringwood)
**
**  NOS System adds fuel required for extra bhp with NOS, so in theory
**  no extra fueling is needed to be plumbed in. Be Careful, make sure
** your injectors are capable of the extra.
**  Operates between user min rpm and the user Max, linearly interpolates
**  between the 2 values of PW enrichment depending on RPM, as fuel needed
**  for NOS is a constant over time, not rpm.
**  The system checks for a max duty cycle of 93%, actually cuts around
**  90% as there is also the opening time to allow for.
**
**  Added a Turbo Anti-Lag function for NOS.  If KPa between setpoints it
**  will fire NOS to boost engine speed and remove some lag from turbo.
**
**
***********************************************************************************
EnableN2O:
         brclr   LaunchControl,feature2,enablen2o_cont  ; Is Launch selected?
         brclr   Launch,portd,Clr_Nos_Out		; Launch on, so nitrous off
         lda     N2Olaunchdel   ; check the launch/nitrous delay timer
         bne     Clr_Nos_Out    ; if non-zero then ensure N2O is off
enablen2o_cont:

         lda      rpm
         cmp      NosRpm_f		; Are we above the minimum rpm?
         blo      Clr_Nos_Ang		; No, No NOS
         cmp      NosRpmMax_f
         bhi      Clr_Nos_Ang		; Are we above the max rpm?
         lda      tps
         cmp      NosTps_f		; Is throttle position past the minimum?
         blo      Clr_Nos_Ang		; No, no Nos
         lda      coolant
         cmp      NosClt_f		; Is the engine warmer than the
					; minimum point?
         blo      Clr_Nos_Ang		; No, no Nos
         brset    NosDcOk,EnhancedBits,Clr_Nos_Out	; Have we hit 90% DC?
         brclr    Traction,EnhancedBits2,Not_AntiRev_NOS	; Have we
					; activated Anti-Rev?
         brclr    TractionNos,feature7,Not_AntiRev_NOS	; Have we selected
					; to cut NOS during Anti-Rev?
         bra      Clr_Nos_Ang		; Yes so cut NOS during Anti-Rev
Not_AntiRev_NOS:
         lda      feature5_f
         bit      #NosLagSystemb
         beq      Nos_IP_Checked        ; Have we selected
					; Anti-lag?
         brclr    NosSysReady,EnhancedBits,Which_io_First	; If NOS
					;  not ready yet is the input on?
         brset    NosAntiLag,EnhancedBits,Anti_Lag	; If antilag bit
					; set then do Anti-lag checks
         bra      Nos_IP_Checked	; Were in normal NOS mode

; Check if input on before the output, then were in anti-lag mode
Which_io_First:
         brset    NosIn,portd,Nos_IP_Checked	; If input not on then
					; were in normal mode
         bset     NosAntiLag,EnhancedBits	; We are in Anti-lag
					; mode so set the bit
Anti_Lag:
         lda      kpa
         cmp      NosLowKpa_f		; In anti-lag mode so are we
					; above min KPa?
         blo      Clr_Nos_Out
         cmp      NosHiKPa_f		; are we above max KPa?
         bhi      Clr_Nos_Out

; Check if we need to retard Ignition with NOS Angle
Nos_IP_Checked:
         bset   NosSysReady,EnhancedBits; NOS System ready to go
         bset   water2,porta		; Turn Nos output on
         brset  NosIn,portd,Clr_Nos_Angle	; Is the Input for NOS
					; SET? (low=on)
         bset   NosSysOn,EnhancedBits	; NOS System Is Running
         lda    feature5_f
         bit    #SparkTable2b
         bne    Nos_Lin         	; Are we using ST2?
         lda    #255T			;
         sub    NosAngle_f		; (255-NOS Angle) turns it into
					; a retard angle
         cmp    #$aa			; Limit the retard to 30 degrees
					; (plenty)
         bhi    StoreNos
         lda    #$aa
         bra    StoreNos
Clr_Nos_Out:
         bclr   water2,porta		; Turn off the output as we've
					; hit 90% DC or Anti-lag over setpoints
         lda    #$00
         sta    NosPW			; Clear Nos PW and Angle
         sta    NitrousAngle
         bclr   NosSysOn,EnhancedBits	; Clear the Nos running bit
         bclr   NosAntiLag,EnhancedBits	; Clear the antilag bit
         bclr   NosSysReady,EnhancedBits; Clear the ready bit
         bra    Nos_Done
Clr_Nos_Angle:
         bclr   NosSysOn,EnhancedBits	; Clear the Nos Running Bit
         bclr   NosAntiLag,EnhancedBits	; Clear the antilag bit
         lda    #$00			; Clear the Nos angle
         sta    NitrousAngle
         sta    NosPW			; Clear the NosPW
         bra    Nos_Done		; Dont clear the output
Clr_Nos_Ang:
         bclr   NosSysOn,EnhancedBits	; Clear the Nos Running Bit
         lda    #$00			; Clear the Nos angle
         sta    NitrousAngle
         bclr   NosSysReady,EnhancedBits; Clear the ready bit
         bclr   NosDcOk,EnhancedBits	; Clear the NOS DC check bit
         bclr   NosAntiLag,EnhancedBits	; Clear the antilag bit
         bra    Clr_Nos_SystemJMP
StoreNos:
         sta    NitrousAngle		; Store the Angle to retard by for NOS
Nos_Lin:
***************************************************************************
**
**  Linear Interpolation - for finding PW for NOS.
**  Added this as using the original screwed the Spark Angle up.     (P. Ringwood)
**  Ripped off from the original.
**
**            (y2 - y1)
**  Y = Y1 +  --------- * (x - x1)
**            (x2 - x1)
**
**   3000rpm      = x1
**   NosRpmMax    = x2
**   NosFuelLo    = y1
**   NosFuelHi    = y2
**   rpm          = x
**   NosPW        = y
***************************************************************************
        clr     tmp7			; This is the negative slope
					; detection bit
        lda     NosFuelLo_f		; Store the minimum PW incase
					; we are lower than 3000rpm
        sta     NosPW
        lda     rpm
        cmp     NosRpm_f		; Are we above Min RPM for NOS?
        bhi     Are_We_Higher		; No so check if we are too high
        bra     End_Interpole		; Yes so end with minimum rpm
					; value in NosPW
Are_We_Higher:
        lda     rpm
        cmp     NosRpmMax_f		; Are we above the max RPM?
        blo     INTERP_PW		; No so interpolate values
        lda     NosFuelHi_f		; We are above max rpm, so
					; store max rpm PW in NosPW
        sta     NosPW
        bra     End_Interpole		; End Interpolting
Nos_Done:
        bra     Nos_Done_Now		; Added a jump as too far.
INTERP_PW:
        lda     NosFuelLo_f		; Store min rpm nos PW in NosPW
        sta     NosPW
        lda     NosRpmMax_f
        sub     NosRpm_f		; Make sure settings are correctly set
        beq     End_Interpole		; Settings wrong so end with min
					; rpm PW in NosPW
        psha
        lda     NosFuelHi_f
        sub     NosFuelLo_f		; Are we doing a positive interpole?
	  bcc	    Interpole_Plus
        nega
        inc     tmp7
Interpole_Plus:
        psha
        lda     rpm
        sub     NosRpm_f		; Find out difference in rpm and
					; min setpoint
        beq     ZERO_Interpole
        pulx
        mul
        pshx
        pulh
        pulx
        div
        psha
        lda     tmp7
        bne     NEG_Interpole		; Are we doing a negative
					; sloped interpolation?
        pula
        add     NosFuelLo_f
        sta     NosPW
        bra     End_Interpole

Clr_Nos_SystemJMP:
        bra     Clr_Nos_System

NEG_Interpole:
        pula
        sta     tmp7
        lda     NosFuelLo_f
        sub     tmp7
        sta     NosPW
        bra     End_Interpole
ZERO_Interpole:
        pula				;clean stack
        pula				;clean stack
End_Interpole:

; Check if weve hit 90% Duty Cycle with NOS PW
         clrh
         ldx      DIVIDER_f1		; Load x with the divider
         lda      Alternate_f1		; Are we in alternating mode?
         beq      multi_it
         lslx				; Yes so multiply divider by 2
multi_it:
         lda      rpmpl
         mul				; Accumulator now contains time
					; between squirts
         cpx      #00T                  ;
;; this was in error         bne      Stop_Nos
         bne      Nos_Done_Now		; if period > 25.5ms then must
					; be ok as that is our max pulse
         ldx      #237T			; 90% (230/256=0.9) 237 allows
					; for opening time
         mul
         lda      feature4_f
         bit      #DtNosb
         bne      Check_PW2     	; If were using Bank 2
					;then check PW2
         txa
         cmp      pw1			; Are we over 90%?
         blo      Stop_Nos
         bra      Nos_Done_Now		; No so dont cut out NOS System
Check_PW2:
         txa
         cmp      pw2			; Are we over 90%?
         blo      Stop_Nos
         bra      Nos_Done_Now		; No so dont cut out NOS System
Stop_Nos:
         bset     NosDcOk,EnhancedBits	; We are over 90 DC so cut
					; NOS System out
Clr_Nos_System:
         bclr     water2,porta		; Turn off the Nos output
Clr_Nos_PW:
         lda      #00T
         sta      NosPW			; Clear the Nos PW
Nos_Done_Now:

         rts

******************************************************************************
**        Check if were ready to use VE Table 3
******************************************************************************

Check_VE3_Table:
        brclr   Nitrous,feature1,Check_VE3_NOS	; Are we using NOS?
        brclr   NosSysOn,EnhancedBits,Check_VE3_Done	; NOS Mode not ready.
        brset   NosIn,portd,Check_VE3_Done	; If input not low dont
					; use VE 3
        bset    UseVE3,EnhancedBits
        rts
Check_VE3_NOS:
        brset   NosIn,portd,Check_VE3_Done	; If input not low dont
					; use VE 3
        bset    UseVE3,EnhancedBits
        rts
Check_VE3_Done:
        bclr    UseVE3,EnhancedBits
        rts

******************************************************************************
**    8x8 Target AFR Tables                            P Ringwood          ***
**    AFR Table 1 is for VE table 1   AFR Table 2 is for VE table 3        ***
******************************************************************************
AFR1_Targets:
        brset   useVE3,EnhancedBits,No_AFR_ForVE1	; If were running
					; VE3 then no need to go any further
        lda     EGOcount		; Are we about to check the ego?
        cmp     EGOcountcmp_f
        beq     Do_Targets		; If yes then get the target from
					; the table
No_AFR_ForVE1:
        rts				; If No then return, this saves
					; wasting time.

Do_Targets:				; VE 1 Targets from AFR Table 1
        brclr   TPSTargetAFR,feature7,NO_TPS_SetAFR1	; Have we selected
					; to go to targets above tps setpoint?
        lda     tps
        cmp     AFRTarTPS_f
        bhi     NO_TPS_SetAFR1		; If tps higher than setpoint then
					; do tables
        lda     O2targetV_f		; If not load in target from
					; enrichments page
        sta     afrTarget
        rts

NO_TPS_SetAFR1:
        clrh
        clrx
        brset   AlphaTarAFR,feature7,AFR1_AN	; Have we selected to use
					; tps for target afrs instead of kpa?

        lda     kpa                     ; Normal Speed density
        bra     AFR1_STEP_1

AFR1_AN:
        lda     tps

AFR1_STEP_1:
        sta     kpa_n
        ldhx    #KPARANGEAFR_f1
        sthx    tmp1
        lda     #$07			; 8x8
        sta     tmp3
        lda     kpa_n
        sta     tmp4
        jsr     tableLookup
        lda     tmp1
        lda     tmp2
        mov     tmp5,tmp8		; Index
        mov     tmp1,tmp9		; X1
        mov     tmp2,tmp10		; X2

AFR1_STEP_2:
        ldhx    #RPMRANGEAFR_f1
        sthx    tmp1
        mov     #$07,tmp3		; 8x8
        mov     rpm,tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		; Index
        mov     tmp1,tmp13		; X1
        mov     tmp2,tmp14		; X2

AFR1_STEP_3:
        clrh
        ldx     #$08			; 8x8
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        AFR1X
        sta     tmp15
        incx
        AFR1X
        sta     tmp16
        ldx     #$08			; 8x8
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        AFR1X
        sta     tmp17
        incx
        AFR1X
        sta     tmp18
        jsr     VE_STEP_4
        mov     tmp6,afrTarget
        rts

*****************************************************************************
**             VE 3 Targets from AFR Table 2
*****************************************************************************
AFR2_Targets:
        brclr   useVE3,EnhancedBits,No_AFR_ForVE3	; If were not running
					;VE3 then no need to go any further
        lda     EGOcount		; Are we about to check the ego?
        cmp     EGOcountcmp_f
        beq     Do_Targets2		; If yes then get the target from
					; the table
No_AFR_ForVE3:
        rts				; If No then return, this saves
					; wasting time.

Do_Targets2:
        brclr   TPSTargetAFR,feature7,NO_TPS_SetAFR2	; Have we selected
					; to go to targets above tps setpoint?
        lda     tps
        cmp     AFRTarTPS_f
        bhi     NO_TPS_SetAFR2		; If tps higher than setpoint
					; then do tables
        lda     O2targetV_f		; If not load in target from
					; enrichments page
        sta     afrTarget
        rts

NO_TPS_SetAFR2:
        clrh
        clrx
        brset   TPSTargetAFR,feature7,AFR2_AN	; Have we selected to use
					; tps for target afrs instead of kpa?
        lda     kpa
        bra     AFR2_STEP_1
AFR2_AN:
        lda     tps

AFR2_STEP_1:
        sta     kpa_n
        ldhx    #KPARANGEAFR_f2
        sthx    tmp1
        lda     #$07			; 8x8
        sta     tmp3
        lda     kpa_n
        sta     tmp4
        jsr     tableLookup
        lda     tmp1
        lda     tmp2
        mov     tmp5,tmp8		; Index
        mov     tmp1,tmp9		; X1
        mov     tmp2,tmp10		; X2

AFR2_STEP_2:
        ldhx    #RPMRANGEAFR_f2
        sthx    tmp1
        mov     #$07,tmp3		; 8x8
        mov     rpm,tmp4
        jsr     tableLookup
        mov     tmp5,tmp11		; Index
        mov     tmp1,tmp13		; X1
        mov     tmp2,tmp14		; X2

AFR2_STEP_3:
        clrh
        ldx     #$08			; 8x8
        lda     tmp8
        deca
        mul
        add     tmp11
        deca
        tax
        AFR2X
        sta     tmp15
        incx
        AFR2X
        sta     tmp16
        ldx     #$08			; 8x8
        lda     tmp8
        mul
        add     tmp11
        deca
        tax
        AFR2X
        sta     tmp17
        incx
        AFR2X
        sta     tmp18
        jsr     VE_STEP_4
        mov     tmp6,afrTarget
        rts

;------------------------------------------------------------------
;now error messages. Exact postion in memory not important
error_vector:
        dw      error_msg0
        dw      error_msg1
        dw      error_msg2
        dw      error_msg3
        dw      error_msg4
        dw      error_msg5
        dw      error_msg6
        dw      error_msg7
        dw      error_msg8
        dw      error_msg9
        dw      error_msg10
        dw      error_msg11
        dw      error_msg12
        dw      error_msg13
        dw      error_msg14

error_msg0:
        db   'Internal error message 0'
        db   13T,10T,0
error_msg1:
        db   'You have defined a spark mode but no outputs are defined as spark'
        db   13T,10T,0
error_msg2:
        db   'If Neon mode is set you must set LED17+19 to spark outputs'
        db   13T,10T,0
error_msg3:
        db   'If MSnS mode is set you must set LED17 or FIDLE as spark output'
        db   13T,10T,0
error_msg4:
        db   'You cannot use FIDLE for spark control and idle control at the same time'
        db   13T,10T,0
error_msg5:
        db   'You cannot use X2 as water injection and fan control at the same time'
        db   13T,10T,0
error_msg6:
        db   'You cannot use X4 for water injection and nitrous control at the same time'
        db   13T,10T,0
error_msg7:
        db   'In HEI7 mode you must have LED19 set as a spark output for the bypass signal'
        db   13T,10T,0
error_msg8:
        db   'Config error with spark outputs or wheel decoder trigger settings'
        db   13T,10T,0
error_msg9:
        db   'Cannot use FIDLE as a spark output if doing wheel decoding or Neon'
        db   13T,10T,0
error_msg10:
        db   'For rotary trailing you must define LED17,18,19 as spark outputs'
        db   13T,10T,0
error_msg11:
        db   'For rotary trailing you must define two wheel decoder triggers'
        db   13T,10T,0
error_msg12:
        db   'Rotary trailing requires the wheel decoder enabled and configured'
        db   13T,10T,0
error_msg13:
        db   'You cannot have LED17/D14 and FIDLE both set to Spark A'
        db   13T,10T,0
error_msg14:
        db   'You cannot have more than one spark mode defined'
        db   13T,10T,0

;--------------
;------------------------------------------------------------------
;	; Constants not possible to burn

; This is used to set the bin coolant range for WWU
WWURANGE:
        db      0T
        db      20T
        db      40T
        db      60T
        db      80T
        db      100T
        db      120T
        db      140T
        db      170T
        db      200T


REVNUM: db      00T			; not used, always zero
textversion_f:   db   'MS1/Extra rev 029y4 ************' ; full code release
Signature:       db   'MS1/Extra format 029y3 *********' ; data format for
                 ; ini file matching, ONLY change this if the data format changed.
;must be 32 chars     '12345678901234567890123456789012' ; (may change to 20)
rpmdotrate:
        db      3T			; 3,000 rpm delta
        db      4T			; 4,000
        db      6T			; 6,000
        db      10T			; 10,000
sliprate:
        db      05T			; 5% slip from driven wheels
        db      15T			; 15%
        db      30T			; 30%
        db      70T			; 70%

end_of_main:   ; check this var to ensure it does not exceed $DFFF

;------------------------------------------------------------------

        org     $FAC3			; start of bootloader-defined
					; jump table/vector
        db      $12			; scbr regi init value
        db      %00000001		; config1
        db      %00000001		; config2
        dw      start			; megasquirt code start
        dw      $FB00			; bootloader start

; Vector table
;	org	vec_timebase



        db      $CC
	dw	Dummy			; Timebase
        db      $CC
	dw	ADCDONE			; ADC Conversion Complete
        db      $CC
	dw	Dummy			; Keyboard pin
        db      $CC
	dw	IN_SCI_TX		; SCI transmission complete/
					; transmitter empty
        db      $CC
	dw	IN_SCI_RCV		; SCI input idle/receiver full
        db      $CC
	dw	Dummy			; SCI parity/framing/noise/
					; receiver_overrun error
        db      $CC
	dw	Dummy			; SPI Transmitter empty
        db      $CC
	dw	Dummy			; SPI mode/overflow/receiver full
        db      $CC
	dw	T2Overflow		; TIM2 overflow
        db      $CC
	dw	SPARKTIME		; TIM2 Ch1
        db      $CC
	dw	TIMERROLL		; TIM2 Ch 0
        db      $CC
	dw	Dummy			; TIM1 overflow
        db      $CC
	dw	Dummy			; TIM1 Ch1
        db      $CC
	dw	Dummy 			; TIM Ch0
        db      $CC
	dw	Dummy			; CGM
        db      $CC
	dw	DOSQUIRT		; IRQ
        db      $CC
	dw	Dummy			; SWI
        db      $CC
	dw	Start


;------------------------------------------------------------------
; Lookup Tables
        org     $F000
        include "barofactor300k.inc"
        include "barofactor4115.inc"
        include "barofactor4250.inc"
        include "kpafactor4115.inc"
        include "kpafactor4250.inc"
        include "thermfactor.inc"
        include "airdenfactor.inc"
        include "matfactor.inc"
        include "barofactor400k.inc"
    ; Room here for no more inc file
;------------------------------------------------------------------
       org     $E000
; Tables, copied into RAM on demand
; Most functions will primarily work from the flash copy
; 8 Pages in total

flash_table0:  ; config variables

personality_f   db      %00000001	; Only 1 allowed to be set unless in
					; EDIS or WHEEL mode, if all are set
					; to 0 then thats fuel only (std MS)!
;MSNS           equ      1    Megasquirtnspark
;MSNEON         equ      2    MS neon decoder
;WHEEL          equ      4    generalised decoder 36-1, 60-2 etc
;WHEEL2         equ      8    If in WHEEL mode then WHEEL2 is 0 = -1  1 = -2
;EDIS           equ      $10  edis
;DUALEDIS       equ      $20  if in EDIS mode then this allows two edis
;                             modules (for edis4 on V8, edis6 on V12)
;TFI            equ      $40  Ford TFI system
;HEI7           equ      $80  GM 7 pin HEI

outputpins_f    db      %00000110
;               bits=    76543210
;       equ 1       FIDLE for Idle Air Valve || spark output (as per MSnS)
;       equ 2       LED17 for squirt led     || coila output
;
;                   bit 2    bit 3
;                  LED18_2   LED18    function
;                    0         0       wled
;                    0         1       irq
;                    1         0       output4 or fan control (see bit 6)
;                    1         1       spark c

;REUSE_LED19       equ $10   LED19 for accel led || coilb output
;X2_FAN            equ $20   X2 = water Inj pulsed out || fan control
;       ** Please note: Water inj uses X2 to pulse output, X3 will still
;                       come on with water inj or NOS depending on which is on
;
;LED18_FAN         equ $40   LED18 output4 || fan control
;       ** only allowed if bit 2 = 1 and bit 3 = 0
;Mulitplex Ign     equ $80   NORMAL || toyota DLI ignition
; multiplex

SRevLimRPM	db      240T	; Standard RPM limit for spark retard (rpm*100)
SRevLimAngle	db      56T	; Spark retard for above +10 degrees
				; 10 = 10 + 10 i.e. -10 start point.
				; So 56T = 10BTDC )
SRevLimHTime	db      50T	; Time in 1/10Sec in Soft limit till
				; hard limit cuts in *0.1
SRevLimCTime	db      10T	; NOT USED
RevLimit_f	db      250T	; Hard Rev limiter (rpm*100)
Out1Lim		db      0T	; Output1 On point in RAW except for
				; TEMPS then its in F -40, so 200F switch
				; on point = 240F

Out1Source	db      0T	; Output 1 source, index from secl,
				; Standard Out1source
				; This is secl + val up to 30 (ego2 correction)
				; 31 = Traction control  >31 is not valid as
				; this is from RAM

Out2Lim		db      0T	; Output 2 limit As out1Lim

Out2Source	db      0T	; Same as Out1Source

feature1_f	db      %01000010
;wd_2trig       equ 1     wheel decoder 2nd trigger i/p - new in 023c9
;               spare
;whlsim         equ 4     Wheel simulator          off      on
;taeIgnCount	equ 8     Acceleration Timer    Seconds^ || Engine Cycles
; NOT USE       equ $10    NOT USED NOW 023
;hybridAlphaN	equ $20      Hybrid Alpha N           OFF^ || OFF
;CrankingPW2	equ $40      Fire PW2 during Cranking?   YES^ || NO
;Nitrous	equ $80      Nitrous system              OFF || ON
                                                       ;NOT allowed with W Inj

feature2_f	db      %00000000  ; more features
;BoostControl	equ 1        Boost Controller           OFF || ON
;ShiftLight	equ 2        Shift Lights               OFF || ON
;LaunchControl	equ 4        launch Control             OFF || ON
;wasPWMidle	equ 8
;     only if outputpins_f bit 1 = 0
;out3sparkd	equ $10      Output 3             Output 3  || Spark D
;min_dwell	equ $20
;dwellduty50	equ $40
;config_error	equ $80    this is only set if non-sense combination
; of options - don't run.

whlsimcnt       db      04T     ; How many outputs when simulating wheel
bcFreqDiv_f	db      3T	; Solenoid PW rate BITS 0 1 and 2 used :
				; "INVALID","39.0 Hz","19.5 Hz","13.0 Hz",
				; "9.8 Hz","7.8 Hz","6.5 Hz","5.6 Hz"
bcUpdate_f	db      10T	; Boost Controller Update Rate in mS
                		; (10min   255max)
bcPgain_f	db      64T	; B Controller P Gain % (0-100% = 0-255 in
				; MS so MT value displayed = MS*0.3922)
bcDgain_f	db      5T	; Boost Controller D Gain % (0-100% = 0-255
				; in MS so MT value displayed = MS*0.3922)
ShiftLo_f	db      58T	; Shift light LED start point (rpm*100)
ShiftHi_f	db      60T	; Shift Light Final point (RPM * 100)
LaunchLimit_f	db      40T	; Hard limit for Launch control (rpm*100)
edisms_f	db      11T	; max rpm for EDIS multi-spark (rpm*100)
NosClt_f	db      160T	; Nitrous System Min Coolant Temp Minimum
				; point of coolant for NOS to enable in (F-40)
NosRpm_f	db      30T	; Nitrous System Min RPM * 100, 3000rpm is
				; minimum allowed  (23)
NosRpmMax_f	db      60T	; Nitrous Max RPM *100 (used for
				; interpolating and cutting nos)

Trig1_f		db       0T	; wheel decoding
Trig2_f		db       0T	;  "
Trig3_f		db       0T	;  "
Trig4_f		db       0T	;  "
Trig1ret_f	db       0T	;  "
Trig2ret_f	db       0T	;  "
Trig3ret_f	db       0T	;  "
Trig4ret_f	db       0T	;  "

DTmode_f	db      %01100001 ; DualTable control
;		equ $10      Normal single table mode ^   || Dual Table Mode
;		equ $20    Gamma E correction OFF for PW1 || Gamma E ON^
;		equ $40    Gamma E correction OFF for PW2 || Gamma E ON^
alt_i2t2          equ      %00010000  ; inj2: 0 = t1, 1 = t2
alt_i1ge          equ      %00100000
alt_i2ge          equ      %01000000
trig2fallb       equ 1   ; 0 = rising edge trigger, 1 = falling edge
trig2risefallb   equ 2   ; 0 = rising or falling, 1 = rise and falling edge

latency_f      db        0T  ; "known" latency in spark input to output
spare1_2_f      db        0T
spare1_3_f      db        0T
spare1_4_f      db        0T
spare1_5_f      db        0T

EgoLimitKPa_f	db      255T	; MAP KPa Point to change Ego +- limit (39)
EgoLim2_f	db      05T	; New Ego limit when MAP KPa above
				; EgoLimitKPa_f
LC_Throttle_f	db      30T	; Throttle position in RAW data for launch
				; control mode
LC_LimAngle_f	db      42T	; Launch control soft limiter angle
				; *0.352   -28.4     -10 to 45 allowed
LC_Soft_Rpm_f	db      35T	; Launch Soft Limit RPM (43)
Over_B_P_f	db      0T	; Over boost Protection KPa setpoint
				; <100 = no boost protection
SparkCutNum_f	db      3T	; Rev Limiter Hard cut spark cut number to
				; remove sparks from SparkCutBase_f

feature3_f	db      %00110000  ; (46)
KPaTpsOpenb      equ 1
VarLaunchb       equ 2
CltIatIgnitionb  equ 4
WaterInjb        equ 8
Fuel_SparkHardb  equ $10 ; Fuel or Spark cut for Rev limiter
FuelSparkCutb    equ $20 ; Fuel or spark cut for Rev limiter
KnockDetb        equ $40
TargetAFRb       equ $80

cltAdvance_f	db      180T    ; Advance ignition whilst temp below this value F -40
cltDeg_f	db      27T     ; Add 1 degree of advance for this value(F)
				; below cltAdvance_f, so if
				; cltAdvance_f=120(80F) and cltDeg_f=20 then
                                ; at 10F advance will be 80-10/20= 3.5
maxAdvAng_f	db      15T     ; Limit in degrees of advance for coolant
				; related advance so it doesnt add loads of
				; advance when very cold *0.352
iatDeg_f	db      18T     ; Iat Temp for 1 degree of retard related
				; to IAT, exactly the same as cltDeg_f but
				; retard rather than advance and
                                ; IAT rather that CLT. F
kpaRetard_f	db      75T     ; Apply the IAT related retard when above
				; this KPa, to stop retard at tickover
iatDanger_f	db      200T    ; Iat Temp to start Retard F -40
KnockRpmL_f	db      55T     ; Knock sensor max rpm RPM*100 (53)
KnockRpmLL_f	db      15T     ; Knock sensor min rpm RPM*100
KnockKpaL_f	db      255T    ; knock sensor max KPa
KnockRet1_f	db      06T     ; First Retard amount for knock system *0.352
KnockRet2_f	db      03T     ; Subsequent Retard amount *0.352
KnockAdv_f	db      03T     ; Advance amount for knock system *0.352
KnockMax_f	db      15T     ; Max Allowable retard *0.352
KnockTim_f	db      01T     ; Timer for steps of knock advance / retard
				; to be applied in Seconds 1
iatpoint_f	db      100T    ; Water Inj IAT setpoint point F -40 (61)
wateripoint_f	db      120T    ; Water Injection KPa setpoint
wateriRpm_f	db      35T     ; Water Injection RPM setpoint RPM*100
kpaO2_f		db      80T     ; KPa Open loop setpoint for no O2 correction
tpsO2_f		db      192T    ; TPS Open Loop setpoint for no O2 correction Raw ADC

feature4_f	db      %00000000; Another feature bit for enhanced (66)
miss2ndb         equ 1 ; Missing tooth AND 2nd trigger
InvertOutOneb    equ 2
InvertOutTwob    equ 4
multisparkb   equ 8  ;  ; EDIS multi-spark
KPaDotBoostb     equ $10
DtNosb           equ $20  ; If DT which Bank do we add NOS PW to (Bank1=0 Bank2=1)
OverRunOnb       equ $40
KpaDotSetb       equ $80

NosTps_f	db      200T    ; Nitrous System Min TPS RAW ADC
NosAngle_f	db      50T     ; Nitrous System Angle to remove from
				; ignition *0.352 (68)
NosFuelLo_f	db      12T     ; Nitrous Pulse Width to add to fuel at
				; 3000 rpm *0.1 in mSec this is for
				; additional fuel for NOS
NosFuelHi_f	db      03T     ; Nitrous Pulse Width to add to fuel at
				; NosRpmMax_f *0.1 in mSec
ORunRpm_f	db      17T     ; Max RPM for Over run fuel cut *100
ORunKpa_f	db      20T     ; Over run fuel cut when below kpa
ORunTPS_f	db      05T     ; Over run when throttle position lower than this RAW ADC (73)
EfanOnTemp_f	db      234T    ; X2 or LED 17 electric fan output on temp
				; F-40
EfanOffTemp_f	db      185T    ; X2 or LED 17 electric fan output off temp
				; F-40

feature5_f	db      %00110011  ; Yet another feature bit (76)
Fuel_SparkHLCb   equ 1  ; Fuel or Spark cut for Launch
FuelSparkLCb     equ 2  ; Fuel or Spark cut for Launch
stagedb:         equ 4  ; Roger Enns Staged Mode   xxxx00xx = Staged Off  xxxx01xx = RPM Based
stagedModeb:     equ 8  ; Roger Enns Staged Mode   xxxx10xx = MAP Based   xxxx11xx = TPS Based
stagedeither:    equ $0c ; either staging
BoostCutb:       equ $10  ; Over boost Cut type, option2 or spark cut
BoostCut2b:      equ $20  ; Option2 for Over boost Cut type, fuel only or both fuel and spark
NosLagSystemb:   equ $40  ; Nos Anti-lag System used
SparkTable2b:    equ $80  ; Second Spark Table


SparkCutNLC_f	db      03T	; Launch control spark cut, this is the
				; amount of sparks to remove from
				; SparkCutBase_f when in Launch hard cut
SparkCutBase_f	db      06T	; Base number to cut sparks from MS
				; = MT value - 1
SCALEFAC_f	db      255T	; Scaling factor for STAGED INJECTION MODE
				; (prim flow/total flow*100) 255=100% 123=50%
STGTRANS_f	db      25T	; Staged transition point, rpm*100, kpa,
				; or tps raw adc depending on staging
				; method selected (See feature5_f bits 3-4)
STGDELTA_f	db      03T	; Staged operation off at (STGTRANS-STGDELTA)
				; so this is raw data as STGTRANS
BarroHi_f	db      110T	; Barometric Correction Max Limit in KPa (82)
BarroLow_f	db      60T	; Barometric Correction Lower Limit in KPa
SparkCutBNum_f	db      03T	; Number of sparks to remove from BASE value
				; when Over Boost
NosLowKpa_f	db      80T	; Minimum KPa to fire Nos Anti-lag
NosHiKpa_f	db      120T	; Maximum KPa to fire Nos Anti-lag,
				; Anti-lag will switch off when this is reached
Spark2Delay_f	db      00T	; Delay for Spark Table 2 to come in when
				; input received. *0.1   1/10Sec
Out1UpLim_f	db      00T	; Output 1 top limit for window, so output1
				; will go off above this value unless its 0
				; then its ignored
Out2UpLim_f	db      00T	; Output 2 top limit for window (89)
NumTeeth_f	db      12T	; Number of teeth for wheel decoder
MAPThresh_f	db      30T	; MAP dot threshold for Accel Decel
				; Enrichments *10 (KPa/Sec)

feature6_f	db      %00000000  ; More feature bits (92)
VETable3b        equ 1  ; Use VE table 3
TargetAFR3b      equ 2  ; Use Target AFR for VE3
falsetrigb       equ 4  ; 0=Enable false trigger protection, 1=disable   ; testing
wheel_oldb       equ 8  ; 0= new(025) wheel decoder or 1=old(024s9) style ; testing
dualdizzyb       equ $10  ;
TractionCb       equ $20  ; Traction control system on
BoostDirb        equ $40  ; Direction for boost control output
NoDecelBoostb    equ $80  ; No decelleration when in boost

VE3Delay_f	db      00T	; Delay for VE Table 3 to come in when
				; input received. *0.1   1/10Sec
RPMrate_f:
	db      00T		; Fuel enrichment in mSec for 3000RPM/Sec
				; increase or 5% slip if in VSS mode *0.1
       	db     100T		; Fuel enrichment in mSec for 4000RPM/Sec
				; increase or 15% slip if in VSS mode *0.1
       	db     150T		; Fuel enrichment in mSec for 6000RPM/Sec
				; increase or 30% slip if in VSS mode *0.1 (96)
       	db     200T		; Fuel enrichment in mSec for 10000RPM/Sec
				; increase or 70% slip if in VSS mode *0.1

RPMthresh_f	db      2T	; Threshhold for RPM change for traction
				; (rpm * 1000) because it checks every 1/10
				; sec and rpm = rpm*100. So 2 = 2000RPM/Sec
				; threshold
TractDeg_f:
	db      00T		; Ignition retard in Degrees for 3000RPM/Sec
				; increase or 5% slip if in VSS mode *0.352
	db      56T		; Ignition retard in Degrees for 4000RPM/Sec
				; increase or 15% slip if in VSS mode *0.352
	db      56T		; Ignition retard in Degrees for 6000RPM/Sec
				; increase or 30% slip if in VSS mode *0.352
	db      85T		; Ignition retard in Degrees for 10000RPM/Sec
				; increase or 70% slip if in VSS mode *0.352(102)
TractSpark_f:
	db      00T		; Spark Cut from Base number for 3000RPM/Sec
				; increase or 5% slip if in VSS mode MAX
				; ALLOWED 5
	db      00T		; Spark Cut from Base number for 4000RPM/Sec
				; increase or 15% slip if in VSS mode
	db      01T		; Spark Cut from Base number for 6000RPM/Sec
				; increase or 30% slip if in VSS mode
	db      02T		; Spark Cut from Base number for 10000RPM/Sec
				; increase or 70% slip if in VSS mode (106)

BoostKnock_f	db      00T	; Boost to remove from controller target when
				; Knock detected (PSI) so value of MS 1 = 7KPa
BoostKnMax_f	db      30T	; Max Boost to remove when knocking in PSI so
				; send 1 to MS this is 7KPa inside the code

feature7_f	db      %00000010  ; More feature bits     (109)
;029g changed to enable dwell by default
;TractionNos	equ 1   Turn Nos off in Traction Control if traction lost,
				; only if Traction oN TractionCb:feature6 bit 6
;dwellcont	equ 2   Real (crude) dwell control
;TCcycleSec	equ 4   Hold traction settings for cycles || untill rpm
				; stable for 0.1S only if Traction ON
				; see TractionCb:feature6 bit 6
;WheelSensor	equ 8   Traction control    RPM Based || VSS
				; only if Traction ON
				; see TractionCb:feature6 bit 6
;AlphaTarAFR	equ $10  speed density for target afr tables || Alpha-N
				; only if Target AFR tables ON
				; see TargetAFRb:feature3 bit 8
;TPSTargetAFR	equ $20    0=  Use Target AFR all the while || 1=Only when
				; TPS above AFRTarTPS_f  if Target AFR
				; tables ON
				; see TargetAFRb:feature3 bit 8
;spare	equ $40
;spare	equ $80

dwellcrank_f	db       60T	; cranking dwell in 0.1ms
dwellrun_f	db       40T	; running  dwell in 0.1ms  (111)

TractCycle_f:
	db      03T		; Engine cycles to hold enrichment /
				; spark cut / retard for 3000RPM/Sec increase
				; or 5% slip if in VSS mode
	db      05T		; Engine cycles to hold enrichment /
				; spark cut / retard for 4000RPM/Sec increase
				; or 15% slip if in VSS mode
	db      08T		; Engine cycles to hold enrichment /
				; spark cut / retard for 6000RPM/Sec increase
				; or 30% slip if in VSS mode
	db      12T		; Engine cycles to hold enrichment /
				; spark cut / retard for 15000RPM/Sec increase
				; or 70% slip if in VSS mode

feature8_f	db      %00000000  ; More feature bits (116)
;spare 1
;spare 2
BoostTable3b:     equ 4  ; Use boost table 3 when switch table input on
spkeopb           equ 8  ; Enable spark E output (instead of shiftlight)
spkfopb           equ $10 ; Enable spark F output (instead of knock in)
DecelMAPb:        equ $20 ; Use MAP for Decel
InterpAcelb:      equ $40 ; Interpole the accel enrichments down to a setpoint
Out1_Out3b:       equ $80 ; Output3 only if output1 is on.

UDSpeedLo_f	db       00T	; Min speed from the Undriven wheel for
				;traction to work at. Volts *0.0196  5V=255
UDSpeedLim_f	db      255T	; Max speed from the Undriven wheel for
				; traction to work at. Volts *0.0196  5V=255
TCScaleFac_f	db      125T	; Difference factor for speed inputs from
				; driven and undriven inputs
				; (255=100%) *0.39216
TCSlipFac_f	db      25T	; Slip allowed between wheel sensors at low
				; speed (255=100%) *0.39216
AFRTarTPS_f	db      255T	; TPS setpoint to go over to switch to target
				; afr tables in RAW ADC (121)
spare1          db      00T
TCSlipFacH_f	db       5T	; Slip allowed between wheel sensors at
				; high speed (255=100%) *0.39216
LC_flatsel_f	db      255T	; rpm above which arms flat shift mode
bc_max_diff	db      255T	; Boost Controller max Difference in KPa
Out1Hys_f	db      00T	; Hysterisis for Output1 in Raw ADC (126)
Out2Hys_f	db      00T	; Hysterisis for Output2 in Raw ADC
LC_flatlim      db      55T     ; flat shift revlimit
DecelKpa_f	db      255T	; No Decel enrichment above this value in
				; KPa (129)
OverRunT_f	db      00T	; Over Run Timer before enabling over run
				; in Seconds *1
BarCorr300_f	db      255T	; Correction factor for KPA Factor for
				; 300KPa sensor and 400KPa sensors only.
				; 255=100% *0.39216
				; (24%=GM300 28%=6300A Series and
				; 78%= 6400A series)

Out3Source_f	db      00T	; Same as Out1Source

Out3Lim_f	db      00T	; Output 3 On/Off Limit as per standard MSnS
TimerOut3_f	db      00T	; Output 3 OFF delay timer in Seconds (134) *1
iatBoostSt_f	db      00T	; Start point for boost reduction related to
				; IAT when using Boost controller F -40
iatBoost_f	db      00T	; Amount of IAT to remove 1 PSI from boost
				; controller F, same theory as cltDeg_f
tpsBooIAT_f	db      00T	; TPS point to start removing boost from
				; boost controller in RAW ADC

Out4Source_f	db      00T	; Same as Out1Source

Out4Lim_f	db      00T	; Output 4 On/Off Limit as per MSnS
LC_f_slim_f	db      00T	; Retard timing above this rpm in flat shift mode
LC_f_limangle_f	db      00T	; Retard timing to this in flat shift mode
spare3_f	db      00T	;   ** SPARE **
mindischg_f	db      05T	; minimum discharge period for dwell
				; control in mSec *0.1

;pwm idle was here

tachconf_f      db      0T      ; tach output config (159)
Trig5_f		db       0T	; wheel decoding (160)
Trig6_f		db       0T	;  "
Trig5ret_f	db       0T	;  "
Trig6ret_f	db       0T	;  "


RPMbasedrate_f:
	db	05T		; These next 4 are for adding AE based on engine rpm
        db	20T		; This is the actual engine rpm settings
	db	35T		;
	db	55T		; (167)
RPMAQ_f2    db      01T             ; Amount of fuel to add for 1st area of rpm based AE
            db      10T             ; Fuel for 2nd rpm area
            db      15T             ; Fuel for 3rd
RPMAQL_f2:  db      20T             ; Fuel for 4th (171)

n2odel_launch_f: db     00T           ; delay from launch to nitrous activation
n2odel_flat_f:   db     00T           ; delay from flat shift to nitrous activation
n2oholdon_f:     db     00T           ; how long do extra nitrous fuel and retard hold on

xxKPaCorr300_f db    00T     ; KPa correction factor for 400/300KPa sensor (175)


tpsdotrate:
	db	05T		; These next 4 are delta points for TPSdot
				; V/Sec
				; these were hard coded points, now users can
				; select what values
				; they want where. *0.1960784 MAX=25.5
	db	20T		; So 40 = 0.8V/0.1Sec or 8V/Sec as we check it
				; every 0.1Sec
	db	40T		;
	db	77T		; (179)
mapdotrate_f:
	db	05T		; These next 4 are delta points for MAPdot
				; KPa/Sec *10 so 255=2550KPa/Sec as we check it
				; every 0.1Sec
        db	10T		;
	db	15T		;
	db	25T		; (183)
MAPAQ_f:
	db	20T		; Enrichment to add in mSec for first Delta
				; mapdotrate_f when in MAPdot mode *0.1
				; these are all interpoled values)
	db	50T		; Enrichment to add in mSec for second Delta
				; mapdotrate_f when in MAPdot mode *0.1
	db	105T		; Enrichment to add in mSec for third Delta
				; mapdotrate_f when in MAPdot mode *0.1
	db	150T		; Enrichment to add in mSec for fourth Delta
				; mapdotrate_f when in MAPdot mode *0.1 (187)
TPSAQ_f1:
	db	20T		; Enrichment to add in mSec for first Delta
				; tpsdotrate_f when in TPSdot mode *0.1
	db	50T		; Enrichment to add in mSec for second Delta
				; tpsdotrate_f when in TPSdot mode *0.1
	db	105T		; Enrichment to add in mSec for third Delta ;
				; tpsdotrate_f when in TPSdot mode *0.1
	db	150T		; Enrichment to add in mSec for fourth Delta ;
				; tpsdotrate_f when in TPSdot mode *0.1

TPSACOLD_f1	db      90T	; TPSACOLD (ms to add in when cold) *0.1
TPSTHRESH_f1	db      03T	; TPSTHRESH for Accel enrichment when in
				; TPS mode *0.1953125
TPSASYNC_f1	db      02T	; TPSASYNC (accel enrich time in 1/10
				; second increments) or in Enfgine Cycles.
TPSDQ_f1	db      100T	; TPSDQ   (195)
ACMULT_f1	db      100T	; Cold ACCELMULT
OverRunClt_f1	db      100T	; No Over run fuel cut when below this
				; coolant temp F-40 (197)
AccelDecay_f	db       00T	; This is the value in mS that the Accel
				; enrichment will end up at when the timer
				; has run. *0.1

feature9_f	db  %00000000	;  (199)
CrankPWTableb:    equ 1       ; Use cranking PW Table
ASETableb:        equ 2       ; After start enrichment use table
NoAccelASEb:      equ 4       ; No Accel Enrich during After start enrichment
BaroCorConstb:    equ 8       ; If Alpha-n Mode then do we use MAP for Baro cor constantly.
RpmAEBased:       equ $10     ; RPM Based Accel Enrichment
MassAirFlwb:      equ $20     ; Using Mass AirFlow meter instead of a MAP sensor.
NoAirFactorb:     equ $40     ; If using MAF do we use Air Density in fueling cals?
ConsBarCorb:      equ $80     ; Constant Bar Cor using MAP on X7

Pambient_f:       db  100T    ; raw byte value ambient pressure for boost control

;NOTE! do not add any more data to table 0. Any more and stack may collide when in RAM.
;ends at $E0C8
;In 025x1 VE_r=$0106, so end of ram copy of data is $0106+$C8 = $1CE
; lowest observed stack was $1DB, leaving $D (13) bytes free.
; Will reserve 10 more bytes in .h for 025y, but that's it unless these data pages get
; reduced.
; That should make VE_r = $110 highest.

flash_table0_end:                ;marker for easy lookup in lst file

        org     $E100
flash_table1:           ; FUEL 1   12x12 Total Bytes = 144
VE_f1:
	db      39T,40T,41T,44T,44T,44T,45T,45T,45T,46T,47T,50T ; VE(0,0-11)
	db      47T,47T,51T,51T,50T,50T,50T,50T,51T,55T,56T,60T ; VE (1,0-11)
	db      47T,47T,51T,51T,50T,50T,50T,50T,51T,55T,56T,60T ; VE (2,0-11)
	db      52T,55T,55T,57T,60T,61T,61T,65T,67T,70T,72T,75T ; VE (3,0-11)
	db      52T,55T,55T,57T,60T,61T,61T,65T,67T,70T,72T,75T ; VE (4,0-11)
	db      59T,60T,60T,65T,66T,70T,70T,70T,72T,74T,77T,80T ; VE (5,0-11)
	db      61T,63T,65T,65T,68T,70T,72T,75T,77T,80T,84T,85T ; VE (6,0-11)
	db      65T,72T,72T,74T,74T,75T,75T,77T,79T,83T,89T,90T ; VE (7,0-11)
	db      70T,74T,74T,75T,75T,77T,77T,78T,82T,86T,95T,95T ; VE (8,0-11)
	db      70T,74T,74T,75T,75T,77T,77T,78T,82T,86T,95T,95T ; VE (9,0-11)
	db      75T,77T,79T,73T,82T,82T,82T,85T,87T,89T,99T,100T; VE (10,0-11)
	db      75T,77T,79T,73T,82T,82T,82T,85T,87T,89T,99T,100T; VE (11,0-11)

EGOTEMP_f	db      200T	; EGOTEMP
EGOCOUNTCMP_f	db      16T	; EGOCOUNTCMP
EGODELTA_f	db      1T	; EGODELTA
EGOLIMIT_f	db      15T	; EGOLIMIT
REQ_FUEL_f1	db      155T	; REQFUEL (148)
DIVIDER_f1	db      4T	; DIVIDER
Alternate_f1	db      0	; alternate or simult (single table ONLY)
INJOPEN_f1	db      10T	; INJOPEN
INJOCFUEL_f1	db      0T	; INJOCFUEL  NOT USED NOW !!!!!
				; Kept to fill hole
INJPWM_f1	db      75T	; INJPWM
INJPWMT_f1	db      255T	; INJPWMT
BATTFAC_f1	db      12T	; BATTFAC
rpmk_f1		db      $05	; RPMK[0]
		db      $DC	; RPMK[1]
RPMRANGEVE_f1:
	db      5T		; RPMRANGEVE[0]
	db      10T		; RPMRANGEVE[1]
	db      15T		; RPMRANGEVE[2]
	db      20T		; RPMRANGEVE[3]
	db      28T		; RPMRANGEVE[4]
	db      36T		; RPMRANGEVE[5]
	db      44T		; RPMRANGEVE[6]
	db      52T		; RPMRANGEVE[7]
	db      55T		; RPMRANGEVE[8]
	db      60T		; RPMRANGEVE[9]
	db      62T		; RPMRANGEVE[10]
	db      65T		; RPMRANGEVE[11]
KPARANGEVE_f1:
	db      20T		; KPARANGEVE[0]
	db      30T		; KPARANGEVE[1]
	db      40T		; KPARANGEVE[2]
       	db      50T		; KPARANGEVE[3]
	db      60T		; KPARANGEVE[4]
	db      75T		; KPARANGEVE[5]
	db      90T		; KPARANGEVE[6]
	db      100T		; KPARANGEVE[7]
	db      110T		; KPARANGEVE[8]
	db      120T		; KPARANGEVE[9]
	db      130T		; KPARANGEVE[10]
	db      150T		; KPARANGEVE[11]

config11_f1	db      113T	; Config11 (originally 113T for 8 cyl) (182)
config12_f1	db      112T	; Config12 (originally 112T for 8 injectors)
config13_f1	db      00T	; Config13

EGOrpm_f	db      13T	; RPMOXLIMIT
FASTIDLEbg_f	db      234T	;
O2targetV_f	db      26T	; VOLTOXTARGET (187)
feature14_f1    db      %00000000  ; (188)  ; allows EGOigncount to be on page1
egoIgnCountb	equ 1           ;EGO Step Counter         mSecs || Ignition Pulses^

flash_table1_end:

        org     $E200
flash_table2:           ; FUEL 2 - For PW2 when in Dual Table mode, if not
			; in DT mode then this whole page is ignored
VE_f2:           ; 12x12 Total Bytes = 144
	db      39T,40T,41T,44T,44T,44T,45T,45T,45T,46T,47T,50T ; VE (0,0-11)
	db      47T,47T,51T,51T,50T,50T,50T,50T,51T,55T,56T,60T ; VE (1,0-11)
	db      47T,47T,51T,51T,50T,50T,50T,50T,51T,55T,56T,60T ; VE (2,0-11)
       	db      52T,55T,55T,57T,60T,61T,61T,65T,67T,70T,72T,75T ; VE (3,0-11)
       	db      52T,55T,55T,57T,60T,61T,61T,65T,67T,70T,72T,75T ; VE (4,0-11)
       	db      59T,60T,60T,65T,66T,70T,70T,70T,72T,74T,77T,80T ; VE (5,0-11)
       	db      61T,63T,65T,65T,68T,70T,72T,75T,77T,80T,84T,85T ; VE (6,0-11)
       	db      65T,72T,72T,74T,74T,75T,75T,77T,79T,83T,89T,90T ; VE (7,0-11)
       	db      70T,74T,74T,75T,75T,77T,77T,78T,82T,86T,95T,95T ; VE (8,0-11)
       	db      70T,74T,74T,75T,75T,77T,77T,78T,82T,86T,95T,95T ; VE (9,0-11)
       	db      75T,77T,79T,73T,82T,82T,82T,85T,87T,89T,99T,100T; VE (10,0-11)
       	db      75T,77T,79T,73T,82T,82T,82T,85T,87T,89T,99T,100T; VE (11,0-11)

EGOtemp_f2	db      200T    ; For second O2 sensor (feature12_f2)
EGOCOUNTCMP_f2	db      16T	; NOT USED
EGOdelta_f2	db      1T	; For second O2 sensor (feature12_f2) (146)
EGOlimit_f2	db      10T     ; For second O2 sensor (feature12_f2)
REQ_FUEL_f2	db      155T    ; (148)
Divider_f2	db      4T
Alternate_f2	db      0T	; NOT USED
InjOpen_f2	db      10T
InjOCFuel_f2	db      0T	; NOT USED NOW !!!!! Kept to fill hole
INJPWM_f2	db      100T
INJPWMT_f2	db      255T
BATTFAC_f2	db      12T     ; (155)
rpmk_f2:	; type=byte  entries=2  total bytes=2
	db      $05,$DC		; (156,157)
RPMRANGEVE_f2:	; type=byte  entries=8  total bytes=8
	db      5T,10T,15T,20T,28T,36T,44T,52T,55T,60T,65T,70T
KPARANGEVE_f2:   ; type=byte  entries=8  total bytes=8
	db      20T,30T,40T,50T,60T,75T,90T,100T,110T,120T,130T,140T
config11_f2:
config21_f	db      113T	; NOT USED by code, but MT??(182)
config12_f2:
config22_f	db      112T       ; NOT USED
config13_f2:
config23_f	db      %00000000       ; (184)
;  equ $02   Narrow Band   |  Wide Band   Note: DT bank 2 only (second O2 sensor type)
                                                              ;(feature12_f2)
;  equ $04   Speed Density |  Alpha N     Note: DT bank 2 only

EGOrpm_f2	db      13T	; RPMOXLIMIT for second O2 sensor if used (feature12_f2)
       		db      0	; not used
O2targetV_f2	db      26T	; VOLTOXTARGET for second O2 sensor if used (feature12_f2)

feature12_f2    db      %00000000  ; (188)
SecondO2b        equ 1
				; Mode (DTmode_f bit 4)???

flash_table2_end:

        org     $E300
flash_table3:           	; SPARK Table 1
ST_f1: 				; *0.352 -28.4 Min -10  Max 80
	db    53T,53T,58T,70T,90T,119T,131T,131T,131T,131T,131T,131T ;(0,0-11)
	db    53T,53T,58T,70T,87T,113T,119T,119T,119T,119T,119T,119T ;(1,0-11)
	db    58T,58T,64T,70T,84T,107T,113T,113T,113T,113T,113T,113T ;(2,0-11)
	db    58T,58T,64T,70T,81T,104T,107T,107T,107T,107T,107T,107T ;(3,0-11)
	db    58T,58T,64T,70T,81T,93T,101T,101T,101T,101T,101T,101T  ;(4,0-11)
	db    58T,58T,64T,70T,81T,93T,101T,101T,101T,101T,101T,101T  ;(5,0-11)
	db    58T,58T,64T,70T,81T,93T,101T,101T,101T,101T,101T,101T  ;(6,0-11)
	db    58T,58T,64T,70T,81T,93T,101T,101T,101T,101T,101T,101T  ;(7,0-11)
	db    58T,58T,61T,67T,78T,90T,98T,98T,98T,98T,98T,98T        ;(8,0-11)
	db    58T,58T,58T,64T,75T,87T,95T,95T,95T,95T,95T,95T        ;(9,0-11)
	db    58T,58T,55T,61T,72T,84T,92T,92T,92T,92T,92T,92T        ;(a,0-11)
	db    58T,58T,51T,58T,69T,81T,81T,81T,81T,81T,81T,81T        ;(b,0-11) (143)

RPMRANGEST_f1:
	db      05T,07T,13T,20T,30T,40T,50T,60T,61T,62T,63T,64T
				; RPMRANGEST[0-11]

KPARANGEST_f1:
	db      30T,40T,50T,60T,70T,80T,90T,100T,110T,120T,130T,140T  ; (last byte 167)
				; KPARANGEST[0-b]

;; org $d3a8  ; stick them up out of the way at known values
TriggAngle_f	db      171T	; TriggAngle (60 deg)     (168)  *0.352
FixedAngle_f	db      0T	; FixedAngle   *0.352  -28.4   min -10 Max 80
				; THIS MUST BE -10 (0) for non fixed angle
TrimAngle_f	db      0T	; TrimAngle (NOT cleared on startup)  *0.352
CrankAngle_f	db      56T	; Cranking advance (10deg)  *0.352 -28.4
				;  min -10 max 80
SparkHoldCyc_f	db      1T	; SparkHoldCyc (hold spark x cycles on
				; stall and restart)
SparkConfig1_f	db   %00001100	; SparkConfig1 (Normal trigger, trigger
				; return based low speed spark) Standard MSnS
       ; 029g changed default, was %00000100 for non-inverted spark output after re-flash
;Sparkconfig1 equates
M_SC1LngTrg     equ     $01     ; Spark config 1 (0) Long trigger +22.5
M_SC1XLngTrg    equ     $02     ; Spark config 1 (1) Extra Long trigger +45
M_SC1TimCrnk    equ     $04     ; Spark config 1 (2) Time based cranking (not trigger return)
M_SC1InvSpark   equ     $08     ; Spark config 1 (3) Invert spark output
M_SC1oddfire    equ     $10    ; Spark config 1 (4) Oddfire ignition

IdleAdvance_f	db	0T	; IdleAdvance *0.342 -28.4 min -10 max 80
IdleTPSThresh_f	db	0T	; below this TPS value idle advance
IdleRPMThresh_f	db	0T	; below this RPM value idle advance (0 disables)
IdleCLTThresh_f db	0T	; below this CLT value don't use idle advance
IdleDelayTime_f db	1T	; wait this long before using the idle advance

StgCycles_f	db	25T	; gradually bring on secondary injectors over
				; this many ignition events

Stg2ndParmKPA_f db      0T      ; Staged 2nd parameter kPa value

Stg2ndParmDlt_f db      0T      ; staged 2nd parameter delta

spare3_182      db      0T      ; spare byte as demo
spare3_183      db      0T      ; spare byte as demo
spare3_184      db      0T      ; spare byte as demo

flash_table3_end:

        org     $E400
flash_table4:                   ; Spark Table 2, used when input switched
				; low if selected
ST_f2:				; *0.352  -28.4   Min -10 Max 80
	db    53T,53T,58T,70T,90T,119T,131T,131T,131T,131T,131T,131T ;(0,0-11)
	db    53T,53T,58T,70T,87T,113T,119T,119T,119T,119T,119T,119T ;(1,0-11)
	db    58T,58T,64T,70T,84T,107T,113T,113T,113T,113T,113T,113T ;(2,0-11)
	db    58T,58T,64T,70T,81T,104T,107T,107T,107T,107T,107T,107T ;(3,0-11)
	db    58T,58T,64T,70T,81T,93T,101T,101T,101T,101T,101T,101T  ;(4,0-11)
	db    58T,58T,64T,70T,81T,93T,101T,101T,101T,101T,101T,101T  ;(5,0-11)
	db    58T,58T,64T,70T,81T,93T,101T,101T,101T,101T,101T,101T  ;(6,0-11)
	db    58T,58T,64T,70T,81T,93T,101T,101T,101T,101T,101T,101T  ;(7,0-11)
	db    58T,58T,61T,67T,78T,90T,98T,98T,98T,98T,98T,98T        ;(8,0-11)
	db    58T,58T,58T,64T,75T,87T,95T,95T,95T,95T,95T,95T        ;(9,0-11)
	db    58T,58T,55T,61T,72T,84T,92T,92T,92T,92T,92T,92T        ;(a,0-11)
	db    58T,58T,51T,58T,69T,81T,81T,81T,81T,81T,81T,81T        ;(b,0-11)

RPMRANGEST_f2:
        db      05T,07T,13T,20T,30T,40T,50T,60T,61T,62T,63T,64T
				; RPMRANGEST[0-b]

KPARANGEST_f2:
        db      30T,40T,50T,60T,70T,80T,90T,100T,110T,120T,130T,140T						; KPARANGEST[0-b]

flash_table4_end:

        org     $E500
flash_table5:    ; FUEL Table 3 (VE3) used when input switched low if selected
VE_f3:
	db      39T,40T,41T,44T,44T,44T,45T,45T,45T,46T,47T,50T ; VE (0,0-11)
	db      47T,47T,51T,51T,50T,50T,50T,50T,51T,55T,56T,60T ; VE (1,0-11)
	db      47T,47T,51T,51T,50T,50T,50T,50T,51T,55T,56T,60T ; VE (2,0-11)
	db      52T,55T,55T,57T,60T,61T,61T,65T,67T,70T,72T,75T ; VE (3,0-11)
	db      52T,55T,55T,57T,60T,61T,61T,65T,67T,70T,72T,75T ; VE (4,0-11)
	db      59T,60T,60T,65T,66T,70T,70T,70T,72T,74T,77T,80T ; VE (5,0-11)
	db      61T,63T,65T,65T,68T,70T,72T,75T,77T,80T,84T,85T ; VE (6,0-11)
	db      65T,72T,72T,74T,74T,75T,75T,77T,79T,83T,89T,90T ; VE (7,0-11)
	db      70T,74T,74T,75T,75T,77T,77T,78T,82T,86T,95T,95T ; VE (8,0-11)
	db      70T,74T,74T,75T,75T,77T,77T,78T,82T,86T,95T,95T ; VE (9,0-11)
	db      75T,77T,79T,73T,82T,82T,82T,85T,87T,89T,99T,100T; VE (10,0-11)
	db      75T,77T,79T,73T,82T,82T,82T,85T,87T,89T,99T,100T; VE (11,0-11)
RPMRANGEVE_f3:
	db      5T	; RPMRANGEVE[0] (144)
	db      10T	; RPMRANGEVE[1]
	db      15T	; RPMRANGEVE[2]
	db      20T	; RPMRANGEVE[3]
	db      28T	; RPMRANGEVE[4]
	db      36T	; RPMRANGEVE[5]
	db      44T	; RPMRANGEVE[6]
	db      52T	; RPMRANGEVE[7]
	db      55T	; RPMRANGEVE[8]
	db      60T	; RPMRANGEVE[9]
	db      62T	; RPMRANGEVE[10]
	db      65T	; RPMRANGEVE[11]
KPARANGEVE_f3:
       	db      20T	; KPARANGEVE[0] (156)
	db      30T	; KPARANGEVE[1]
	db      40T	; KPARANGEVE[2]
	db      50T	; KPARANGEVE[3]
	db      60T	; KPARANGEVE[4]
	db      75T	; KPARANGEVE[5]
	db      90T	; KPARANGEVE[6]
	db      100T	; KPARANGEVE[7]
	db      110T	; KPARANGEVE[8]
	db      120T	; KPARANGEVE[9]
	db      130T	; KPARANGEVE[10]
	db      150T    ; KPARANGEVE[11]

ASEVTbl_f:
	db      30T	; -40F This is the ASE table, only used if
			; $02 set in feature9_f     (168)
	db      20T	; -20F  this is in percentage *1 so 30 = 30%
	db      15T	; 0F
	db      12T	; 20F
	db      10T	; 40F
	db       9T	; 60F
	db       8T	; 80F
	db       7T	; 100F
	db       6T	; 130F
	db       5T	; 160F   (177)

AWC_f1  	db      250T	; After Start Warmup Time
feature10_f5  db  %00000000  ; (179)
aseIgnCountb     equ 1     ;  AFTER START Enrichment Seconds || Engine Cycles^
ASEHoldb:        equ 2     ; Hold ASE from decaying for a period of time determined by TimFixASE_f
MAPHoldb:        equ 4     ; Fix MAP value during Fixed ASE timer


TimFixASE_f db     5T     ; Amount of time or cycles to hold ase to fixed value (180)
                        ; rather than decay to 0 % over the timer
CltFixASE_f db   85T    ; Coolant temp setpoint to use Fixed value ASE
MAPFixASE_f  db   60T    ; If in fixed MAP mode then hold MAP at this value during fixed ASE time

;NOTE! do not add any more data to table 5. Any more and stack may collide when in RAM.
flash_table5_end:

        org     $E600
flash_table6:		; AFR Table 1 - 8x8 AFR targets for VE table 1
AFR_f1:			; This is in RAW ADC so 255 = 5V from O2 sensor
	db      147T,147T,147T,147T,147T,147T,147T,147T; AFR (0,0-7)
	db      147T,147T,147T,147T,147T,147T,147T,147T; AFR (1,0-7)
	db      147T,147T,147T,147T,147T,147T,147T,147T; AFR (2,0-7)
	db      147T,147T,147T,147T,147T,147T,147T,147T; AFR (3,0-7)
	db      130T,130T,130T,130T,130T,130T,130T,130T; AFR (4,0-7)
	db      125T,125T,125T,125T,125T,125T,125T,125T; AFR (5,0-7)
	db      125T,125T,125T,125T,125T,125T,125T,125T; AFR (6,0-7)
	db      120T,120T,120T,120T,120T,120T,120T,120T; AFR (7,0-7)

RPMRANGEAFR_f1:
	db      5T	; RPMRANGEAFR1[0]
	db      10T	; RPMRANGEAFR1[1]
	db      15T	; RPMRANGEAFR1[2]
	db      20T	; RPMRANGEAFR1[3]
	db      28T	; RPMRANGEAFR1[4]
	db      36T	; RPMRANGEAFR1[5]
	db      50T	; RPMRANGEAFR1[6]
	db      60T	; RPMRANGEAFR1[7]
KPARANGEAFR_f1:
	db      15T	; KPARANGEAFR1[0]
	db      30T	; KPARANGEAFR1[1]
	db      50T	; KPARANGEAFR1[2]
	db      60T	; KPARANGEAFR1[3]
	db      90T	; KPARANGEAFR1[4]
	db      100T	; KPARANGEAFR1[5]
	db      110T	; KPARANGEAFR1[6]
	db      150T	; KPARANGEAFR1[7]

             		; AFR Table 2 - 8x8 AFR targets for VE table 3
			; (VE3) used when input switched low if selected

AFR_f2:			; This is in RAW ADC so 255 = 5V from O2 sensor
	db      147T,147T,147T,147T,147T,147T,147T,147T; AFR (0,0-7)
	db      147T,147T,147T,147T,147T,147T,147T,147T; AFR (1,0-7)
	db      147T,147T,147T,147T,147T,147T,147T,147T; AFR (2,0-7)
	db      147T,147T,147T,147T,147T,147T,147T,147T; AFR (3,0-7)
	db      130T,130T,130T,130T,130T,130T,130T,130T; AFR (4,0-7)
	db      125T,125T,125T,125T,125T,125T,125T,125T; AFR (5,0-7)
	db      125T,125T,125T,125T,125T,125T,125T,125T; AFR (6,0-7)
	db      120T,120T,120T,120T,120T,120T,120T,120T; AFR (7,0-7)

RPMRANGEAFR_f2:
	db      5T	; RPMRANGEAF2[0]
	db      10T	; RPMRANGEAF2[1]
	db      15T	; RPMRANGEAF2[2]
	db      20T	; RPMRANGEAF2[3]
	db      28T	; RPMRANGEAF2[4]
	db      36T	; RPMRANGEAF2[5]
	db      50T	; RPMRANGEAF2[6]
	db      60T	; RPMRANGEAF2[7]
KPARANGEAFR_f2:
	db      15T	; KPARANGEAF2[0]
	db      30T	; KPARANGEAF2[1]
	db      50T	; KPARANGEAF2[2]
	db      60T	; KPARANGEAF2[3]
	db      90T	; KPARANGEAF2[4]
	db      100T	; KPARANGEAF2[5]
	db      110T	; KPARANGEAF2[6]
	db      150T	; KPARANGEAF2[7]

;2nd stage of nitrous
Nos2Rpm_f     db     255T  ; rpm starts at
Nos2RpmMax_f  db     255T  ; rpm ends st
Nos2delay_f   db     0T    ; delay after stage 1
Nos2Angle_f   db     0T    ; retard
Nos2PWLo_f    db     0T    ; +pw at low rpm
Nos2PWHi_f    db     0T    ; +pw at max rpm

;oddfire wheel decoder bits - very experimental
outaoffs_f   db     0T    ; offset in steps
;bit0 = 0, 22.5   ignore for now
;bit1 = 0, 45     use 0 or 45 or 90 only
;bit2 = 0, 90
outaoffv_f   db     0T    ; 0-45deg variable offset
outboffs_f   db     0T
outboffv_f   db     0T
outcoffs_f   db     0T
outcoffv_f   db     0T
outdoffs_f   db     0T
outdoffv_f   db     0T
outeoffs_f   db     0T
outeoffv_f   db     0T
outfoffs_f   db     0T
outfoffv_f   db     0T

flash_table6_end:


                org     $E700
flash_table7:

;boost controller, kpa target rpm vs tps  6x6
bc_kpa_f:
	db      100T,100T,100T,100T,100T,100T
	db      100T,120T,120T,120T,120T,120T
	db      100T,120T,120T,120T,120T,120T
	db      100T,120T,120T,120T,120T,120T
	db      100T,120T,120T,120T,120T,120T
	db      100T,120T,120T,120T,120T,120T

RPMRANGEbc_f:
	db      10T,20T,30T,40T,50T,70T   ; RPMRANGEbc[0-5]
TPSRANGEbc_f:
	db      51T,77T,102T,127T,179T,230T   ; TPSRANGEbc[0-5]

;boost controller, duty cycle target rpm vs tps

bc_dc_f:
	db      50T,50T,50T,50T,50T,50T
	db      50T,50T,50T,50T,50T,50T
	db      50T,50T,50T,50T,50T,50T
	db      50T,50T,50T,50T,50T,50T
	db      50T,50T,50T,50T,50T,50T
	db      50T,50T,50T,50T,50T,50T

RPMRANGEbc_f2:
	db      10T,20T,30T,40T,50T,70T   ; RPMRANGEbc[0-5]
TPSRANGEbc_f2:
	db      51T,77T,102T,127T,179T,230T   ; TPSRANGEbc[0-5]


; Second boost target table, switched over on input if selected.
bc3_kpa_f:
	db      100T,100T,100T,100T,100T,100T
	db      100T,120T,120T,120T,120T,120T
	db      100T,120T,120T,120T,120T,120T
	db      100T,120T,120T,120T,120T,120T
	db      100T,120T,120T,120T,120T,120T
	db      100T,120T,120T,120T,120T,120T

RPMRANGE3bc_f:
	db      10T,20T,30T,40T,50T,70T   ; RPMRANGE2bc[0-5]
TPSRANGE3bc_f:
        db      51T,77T,102T,127T,179T,230T   ; TPSRANGE2bc[0-5]


flash_table7_end:


                org     $E800
flash_table8:
idle_dc_lo	db      50T	; Idle duty cycle at lower temp for 2-wire
				; Fielding Idle control *1  MIn = 0 Max = 100
idlePeriod_f	db      25T	; idle period in ignition events
;idlekickrpm_f	db      07T	; low rpm to trigger kick up of pwm idle duty
;idlekickdc_f	db      55T	; default duty cycle
idlecrankdc_f	db      50T	; cranking idle dc kg
idledelayclock_f db	01T	; idle dashpot settling delay kg

idledashdc_f	db      45T	; dashpot default duty
idlemindc_f	db      27T	; minimum duty cycle

idle_dc_hi      db      00T     ; rmd Idle duty cycle at upper temp for 2-wire (warmup)
;idlekpa1_f      db      100T  ; rmd
;idlekpa2_f      db      100T  ; rmd
;ikpamin1_f      db      30T   ; rmd
;ikpamin2_f      db      30T   ; rmd
ictlrpm1_f      db      3T	; idle deviation rpmx10 kg
ictlrpm2_f      db      10T	; idle deviation rpmx10 kg
Ideadbnd_f      db      03T	; idle deadband range kg
Idashdelay_f    db      0T	; AIC closure delay ign events kg
idlefreq_f      db      100T  ; rmd
;delay2rpm_f     db      20T     ; rmd
idlestartclk_f  db      10T	; startup decay timer ign events kg
idlePeriod2_f   db      10T     ; rmd
irestorerpm_f   db      15T     ; rmd
idleclosedc_f   db      0T      ; rmd (015)

feature13_f      db      2T
PWMidleb         equ $01  ; pwm idle on vs B&G on/off
idle_warmupb     equ $02  ; pwm idle warmup open loop
idle_clb         equ $04  ; pwm idle closed loop
cltMAPb:         equ $08     ; Use Correction table in the Air Density factor
CltMATCheckb:    equ $10   ; Correction table MAT or IAT based

FASTIDLEtemp_f	db      105T	; Feilding 2-Wire Idle control Fast Idle
				; lower temperature F -40
slowIdleTemp_f	db      234T	; Feilding 2-Wire Idle control Slow Idle
				; upper temperature F -40
fastIdle_f	db      110T	; Fast Idle RPM (RPM*10 100-2550 rpm range)
slowIdle_f	db       65T	; Slow Idle RPM (RPM*10 100-2550 rpm range)
idleThresh_f	db       30T	; TPS Raw value for Idle mode to kick in.

WWU_f1	db      180T	; WWU (-40 F) (22)
	db      180T	; WWU (-20 F)
	db      160T	; WWU (0 F)
	db      150T	; WWU (20 F)
	db      135T	; WWU (40 F)
	db      125T	; WWU (60 F)
	db      113T	; WWU (80 F)
	db      108T	; WWU (100 F)
	db      102T	; WWU (130 F)
	db      100T	; WWU (160 F)

; This is the cranking Table so users can select a interpolated value of
; cranking PW the same as Warmup

CrankPWs_f:
	db      180T	; -40F (32)
	db      120T	; -20F
	db      80T	; 0F
	db      60T	; 20F
	db      55T	; 40F
	db      50T	; 60F
	db      45T	; 80F
	db      40T	; 100F
	db      35T	; 130F
	db      30T	; 160F

feature11_f4   db  %00010000       ; (42)
AlwaysPrimeb:     equ 1    ; Only fire pump if Prime pulse ON | Prime pump every time
PrimeLateb        equ 2    ; Fire prime pulse after 2 seconds
PrimeTwiceb       equ 4    ; Fire the Prime Pulses Twice
NoPrimePb:        equ 8    ; Use Priming Table or Use Prime Pulse
cltcrankb:        equ $10  ; use coolant temp for crank pulsewidth
matcrankb:        equ $20  ; use inlet air temp for crank pulsewidth. Both means average
ExCrFuelb:        equ $40  ; Look at TPS to see if we trigger extra fuel during cranking?

CrankRPM_f	db      $03	; Maximum RPM for cranking (rpm*100)
tpsflood_f	db      $B2	; Throttle position for floodclear mode in
				; RAW ADC
primePulse_f    db      04T     ; prime pulse if not using table (feature11_f4 $8) *023
ExtraCrFu_f     db      00T     ; Extra cranking fuel multiplier (feature11_f4 $40) (46)

cltMATcorr_f:                   ;
                db      100T    ; 7 positions for CLT related correction to          (47)
                db      98T    ; IAT Air Density Correction 110 = correction * 110%
                db      96T
                db      94T
                db      92T
                db      90T
                db      88T    ; (53)

RPMReduLo_f     db      10T     ; lowest rpm to reduce correction by (54)
RPMReduHi_f     db      30T    ; Highest rpm when correction is back to normal

CltMATRange:
        db      200T     ; 160F   User defined Temp settings for Clt Related Air Dens (56)
        db      207T    ; etc.
        db      216T    ;
        db      225T    ;
        db      234T    ;
        db      243T    ;
        db      252T    ; 212F (62)

;rotary leading trailing split timing 6x6 table
split_f:   ; (63)
	db      29T,88T,88T,88T,88T,88T
	db      29T,73T,73T,73T,73T,73T
	db      29T,58T,58T,58T,58T,58T
	db      29T,43T,43T,43T,43T,43T
	db      29T,29T,29T,29T,29T,29T
	db      25T,25T,25T,25T,25T,25T

RPMRANGEsplit_f: ;(99)
	db      6T,8T,30T,40T,50T,70T   ; RPMRANGE2bc[0-5]
KPARANGEsplit_f: ;(105)
        db      40T,50T,60T,80T,105T,106T   ; TPSRANGE2bc[0-5]
p8feat1_f:        db   0T       ; a page8 config byte (111)
rotary2b         equ  1         ; enable/disable twin rotor mode for BIT

fixedsplit_f:       db      0T      ; fixed split for testing like Fixed in spark (112)


flash_table8_end:

ms_rf_end_f:

        include "boot_r12.asm"
;check in the .lst file for how big the flash areas are by searching the variable list
;for the following. Do NOT exceed $C2 per table or stack corruption is likely
flash_0_size        equ {flash_table0_end-flash_table0}
flash_1_size        equ {flash_table1_end-flash_table1}
flash_2_size        equ {flash_table2_end-flash_table2}
flash_3_size        equ {flash_table3_end-flash_table3}
flash_4_size        equ {flash_table4_end-flash_table4}
flash_5_size        equ {flash_table5_end-flash_table5}
flash_6_size        equ {flash_table6_end-flash_table6}
flash_7_size        equ {flash_table7_end-flash_table7}
flash_8_size        equ {flash_table8_end-flash_table8}

******************************************************************************
**                           Real Time variables sent out on RS232 port
**                               "R" command = all 37 Bytes
**                               "A" command = first 22 Bytes
******************************************************************************
* Revised by DJA to start from 0, makes more sense
**
**  0    secl
**  1    squirt
**  2    engine
**  3    baroADC
**  4    mapADC
**  5    matADC
**  6    cltADC
**  7    tpsADC
**  8    batADC
**  9    egoADC
**  10   egoCorrection
**  11   airCorrection
**  12   warmupEnrich
**  13   rpm100
**  14   pulseWidth1
**  15   accelEnrich
**  16   baroCorrection
**  17   gammaEnrich
**  18   veCurr1
**  19   pulseWidth2
**  20   veCurr2
**  21   idleDC
**
**  End of "A" command RT Variables for MegaView compatability
**
**  22/23 cTime             16 bit cycle timer.
**  24    advance           Spark Gauge *0.352 -28.7     Min -10   Max 80
**  25    afrtarget         Raw ADC target that MS is trying to reach
**			    from the target table or switch point  255 = 5V.
**  26    fuelADC           Raw ADC from X7 (second O2 or fuel pressure or
**			    VSS sensor)
**  27    egtADC            Raw ADC from X6 If EGT then temp in
**			    F = egtADC*7.15625
**			    C = egtADC*3.90625 if
**			    VSS Volts = egtADC*0.019
**  28    CltIatAngle       Spark Angle added or removed for IAT CLT temp.
**			    Angle = MS value*0.352
**			    (Angle < 45 ? Angle : -90 + Angle)
**  29    KnockAngle        Spark Angle removed due to Knock System
**			    *0.352
**  30    egoCorrection2    Same as egocorrection, but this is for second
**			    O2 sensor when fitted
**  31    porta             Porta raw value for displaying the I/O state
**  32    portb             Portb raw value for displaying the I/O state
**  33    portc             Portc raw value for displaying the I/O state
**  34    portd             Portd raw value for displaying the I/O state
**  35    stackL            Low byte of stack for test purposes only, no
**			    use to users.
**  36    tpsLast           TPS/MAP last value for MT Accel Wizard, so we
**			    have last and current values to give a gauge of dot
****************************************************************************
	end
