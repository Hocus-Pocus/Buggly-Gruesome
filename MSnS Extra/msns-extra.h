;****************************************************
; msns-extra.h - code mods based on megasquirtnspark JSM
; Lots of stuff used from Dual table
;
; MegaSquirt.h Include File - V1.9999
;
; (C) Bruce A. Bowling / Al C. Grippo
;
; This header must appear on all derivatives
; of this file.
;****************************************************
; V2.0 Include File For megasquirt.asm
;****************************************************
;*
;* MegaSquirt Hardware Wiring
;*
;

;Port A
;  PTA0 - FP
;  PTA1 - FIDLE
;  PTA2 - Output 2 (X5)
;  PTA3 - Output 1 (X4)
;  PTA4             X3
;  PTA5             X2
;  PTA6 - Flyback
;  PTA7 - Flyback

;Port B (ADC inputs)
;  PTB0/AD0 - MAP
;  PTB1/AD1 - MAT
;  PTB2/AD2 - CLT
;  PTB3/AD3 - TPS
;  PTB4/AD4 - BAT
;  PTB5/AD5 - EGO
;  PTB6/AD6 - "X7" spare, EGO2, fuel pressure or 2nd MAP
;  PTB7/AD7 - "X6" spare, EGT

;Port C
;  PTC0 - Squirt LED  or coil a
;  PTC1 - Accel LED   or coil b or HEI7 bypass
;  PTC2 - Warmup LED  or coil c or output 4
;  PTC3 } multiplexed shift { or coil e
;  PTC4 } light outputs     { or 2nd trig input

;Port D
;  PTD0/~SS - unused  or coil d
;  PTD1/MISO - nitrous in / table switch
;  PTD2/MOSI - knock in / coil f
;  PTD3/SPSCK - launch in
;  PTD4/T1CH0 - Inj1
;  PTD5/T1CH1 - Inj2


;portd
NosIn:          equ     1
KnockIn:        equ     2
launch:         equ     3
inject1:        equ     4
inject2:        equ     5

;porta
fuelp:          equ     0
iasc:           equ     1
output2:        equ     2
output1:        equ     3
water2:         equ     4
water:		equ     5   ; or used for X2 Electric fan output

boostP          equ     3
Output3:        equ     0

;portc
sled:           equ     0 ; LED17
aled:           equ     1 ; LED19
wled:           equ     2 ; also IRQ LED18 only used in "fuel only" code
coila           equ     0 ; LED17
coilb           equ     1 ; LED19
pin10           equ     3 ; ptc3 - 2nd trigger for wheel decoder or shiftlight
pin11           equ     4 ; ptc4

c13_of            equ      %00000001  ; defined but rarely used in code
c13_o2            equ      %00000010
c13_cs            equ      %00000100
c13_bc            equ      %00001000


WHEELINIT         equ      %11000011   ; 029g holdoff 3 (011), was 5 (101) recently



;oddfire offset setting equates
outoff_22b       equ     $01
outoff_45b       equ     $02
outoff_90b       equ     $04

; this is the size of the data page, used by the P and C commands
PAGESIZE         equ     189T

KPASCALE300     equ      $42   ; 1+ 0.258*256 =  66 hardcoded scaling factor for kpa
KPASCALE400     equ      $a7   ; 1+ 0.652*256 = 167 
;****************************************************
;*
;* MegaSquirt RAM Variables
;*
;* We wish we had plenty of RAM to burn
;****************************************************
ms_ram_start:

; RAM Variables - Ordered List for RS232 realtime download - delivered in one pack
secl:           ds	1	; low seconds - from 0 to 255, then rollover

squirt:         ds      1       ; Event variable bit field for Injector Firing
; Squirt Event Scheduling Variables - bit fields for "squirt" variable
inj1:   equ     0       ; 0 = no squirt 1 = squirt
inj2:   equ     1       ; 0 = no squirt 1 = squirt
sched1: equ     2       ; 0 = nothing scheduled 1 = scheduled to squirt
firing1:equ     3       ; 0 = not squirting 1 = squirting
sched2: equ	4
firing2:equ	5
bcTableUse: equ 6       ; boost control

engine:         ds      1       ; Variable bit-field to hold engine current status
; Engine Operating/Status variables - bit fields for "engine" variable
running:equ     0       ; 0 = engine not running 1 = running
crank:  equ     1       ; 0 = engine not cranking 1 = engine cranking
startw: equ     2       ; 0 = not in startup warmup 1 = in warmup enrichment
warmup: equ     3       ; 0 = not in warmup 1 = in warmup
tpsaen: equ     4       ; 0 = not in TPS acceleration mode 1 = TPS acceleration mode
tpsden: equ     5       ; 0 = not in deacceleration mode 1 = in deacceleration mode
mapaen: equ     6       ; 0 = not in MAP acceleration mode 1 = MAP deaceeleration mode
idleOn: equ     7       ;

baro:           ds	1	; Barometer ADC Raw Reading - KPa (0 - 255)
map:            ds	1	; Manifold Absolute Pressure ADC Raw Reading - KPa (0 - 255)
mat:            ds	1	; Manifold Air Temp ADC Raw Reading - counts (0 - 255)
clt:            ds	1	; Coolant Temperature ADC Raw Reading - counts (0 - 255)
tps:            ds	1	; Throttle Position Sensor ADC Raw Reading - counts, represents 0 - 5 volts
batt:           ds	1	; Battery Voltage ADC Raw Reading - counts
ego:            ds      1       ; Exhaust Gas Oxygen ADC Raw Reading - counts
egocorr:        ds      1       ; Oxygen Sensor Correction
aircor:         ds      1       ; Air Density Correction lookup - percent
warmcor:        ds      1       ; Total Warmup Correction - percent
rpm:            ds      1       ; Computed engine RPM - rpm/100
pw1:            ds      1       ; injector squirt time in 1/10 millesec (0 to 25.5 millisec) - applied
tpsaccel:       ds      1       ; Acceleration enrichment - percent
barocor:        ds      1       ; Barometer Lookup Correction - percent
gammae:         ds      1       ; Total Gamma Enrichments - percent
vecurr:         ds      1       ; Current VE value from lookup table - percent
pw2:            ds      1
vecurr2:        ds      1
idleDC:         ds      1
ctimeCommH:     ds      1       ; Cycle time H for communication
ctimeCommL:     ds      1       ; Cycle time L for communication
SparkAngle:     ds      1       ; Spark angle (256 = 90 deg)
afrTarget:      ds      1       ; AFR Target temp variable
o2_fpadc:       ds      1       ; Second O2 sensor or Fuel Pressure
egtadc:         ds      1       ; EGT Temperature
CltIatAngle:    ds      1       ; Coolant Iat Angle
KnockAngle:     ds      1       ; Knock Angle
egoCorr2:       ds      1       ; Second O2 sensor Ego Correction

;-------------------------

SparkBits:      ds      1       ; Spark timing bits
SparkTrigg      equ     0       ; SparkBits(0) IRQ has triggered, but no spark yet
SparkHSpeed     equ     1       ; SparkBits(1) High speed spark (using highres timer)
SparkLSpeed     equ     2       ; SparkBits(2) Low speed spark (using low speed timer or trigger going low)
dwellcd         equ     3       ; used for rotary to tell calcdwellspk not to dwell trailing
rise            equ     4       ;} found a rising IRQ edge / 2nd multispark / coilcbit
lc_fs           equ     5         ; doing flat shift vs. launch
trigret         equ     6       ; falling edge at end of short pulses - sets crank timing
Knocked         equ     7       ; Knock system working

;Rev limiter variables
RevLimBits      ds      1       ; Rev limiter status bits
RevLimSoft      equ     0       ; RevLimBits(0) Soft rev limiter in action
RevLimHSoft     equ     1       ; RevLimBits(1) Soft rev limiter hard mode
RevLimHard      equ     2       ; RevLimBits(2) Hard rev limiter in action
sparkon         equ     3       ; ran out of space in sparkbits
coilerr         equ     4       ; out of sequence coil detection
sparkCut        equ     5       ; Spark Cut in action
LaunchOn        equ     6       ; Soft Launch On
Advancing       equ     7       ; Advancing Knock system

personality    ds       1   ; code works from ram. loaded from flash at boot
MSNS           equ      0   ; Megasquirtnspark
MSNEON         equ      1   ; MS neon decoder
WHEEL          equ      2   ; generalised decoder 36-1, 60-2 etc
WHEEL2         equ      3   ; 0 = -1  1 = -2
EDIS           equ      4   ; edis
DUALEDIS       equ      5   ; two edis modules (for edis4 on V8, edis6 on V12)
TFI            equ      6   ; Ford TFI system
HEI7           equ      7   ; GM 7 pin HEI

** output bits
** spark output defaults to FIDLE (original MSnS)
** Neon code always put coils on D19 and D17
outputpins       ds  1   ;         0 (B&G)  | 1 (non B&G)
REUSE_FIDLE       equ 0  ; FIDLE for iasc   | spark output
REUSE_LED17       equ 1  ; LED17 for sled   | coila output
REUSE_LED18       equ 2  ; mismatch between .ini and .asm
REUSE_LED18_2     equ 3  ;
; LED18_2   LED18    function
;  0         0       wled
;  0         1       irq
;  1         0       output4
;  1         1       spark c

REUSE_LED19       equ 4  ; LED19 for aled   | coilb output
X2_FAN            equ 5  ; X2   water/n2o   | fan control
LED18_FAN         equ 6  ; LED18 output4    | fan control
TOY_DLI           equ 7  ; toyota DLI ignition multiplex

feature1        ds  1  ; some features taken from Dual Table
wd_2trig        equ 0  ; wheel decoder 2nd trigger i/p - new in 023c9

whlsim          equ 2  ; enable wheel simulator for use on the stim ONLY
taeIgnCount     equ 3
rotaryFDign     equ 4  ; enable rotary FD ignition outputs
hybridAlphaN    equ 5
CrankingPW2     equ 6
Nitrous         equ 7
wd_2trigb       equ 1   ; for use by BIT

feature2        ds  1  ; more
BoostControl    equ 0
ShiftLight      equ 1
LaunchControl   equ 2
;spare  equ 3
out3sparkd      equ 4 ; 1= use output for spark D
min_dwell       equ 5
dwellduty50     equ 6
config_error    equ 7 ; set if non-sense combination of options - don't run.

feature7        ds  1  ; Enhanced stuff
TractionNos     equ 0  ; Turn Nos off in Traction Loss?
dwellcont       equ 1  ; Real (crude) dwell control
TCcycleSec      equ 2  ; Hold traction settings for cycles or till rpm stable for 0.1S
WheelSensor     equ 3  ; TC wheel sensors fitted
AlphaTarAFR     equ 4  ; Alpha n or speed density for target afr
TPSTargetAFR    equ 5  ; TPS setpoint for target AFR's
StagedMAP2nd	equ 6  ; Do we want to use a 2nd param for staged (MAP only for now)
StagedAnd	equ 7  ; and/or operation for Staged second param

;bit definitions of "missing" flash feature vars in .asm

EnhancedBits:     ds  1       ; Enhanced Stuff
NosDcOk:          equ 0       ; Nos System not causing Duty Cycle of >90%
NosSysOn:         equ 1       ; Nos System Running
OverRun:          equ 2       ; Over Run Fuel Cut
REStaging:        equ 3       ; Roger Enns Staging On
NosAntiLag:       equ 4       ; Nos Antilag running
NosSysReady:      equ 5       ; NOS Ready to go
UseVE3:           equ 6       ; Use VE table 3
Primed:           equ 7       ; Fuel System Primed

EnhancedBits2:    ds  1       ; A few more enhanced bits
Traction:         equ 0       ; Traction control running
Output1On:        equ 1       ; Bit for the output 1 on
Output2On:        equ 2       ; Bit for the output 2 on
cant_crank        equ 3       ; Flag that we can't enter crank mode
cant_delay        equ 4       ; delay bit for cant crank mode
over_Run_Set:     equ 5       ; Set over run active for timer
mv_mode:          equ 6       ; we are in Megaview mode, disable enhanced comms
OneShotBArro:     equ 7       ; One check for baro correction

coilsel:    ds  1       ; which coil are we working on
coilabit          equ 0       ; now a bit each to make life easier
coilbbit          equ 1
coilcbit          equ 2
coildbit          equ 3
coilebit          equ 4
coilfbit          equ 5
;don't expect any more!

EnhancedBits4:    ds  1
roll1             equ 0       ; bits to see if we missed a T2 overflow
roll2             equ 1
page2:            equ 2       ; this was a whole byte
wspk              equ 3       ; set if we are running wasted spark type multiple outputs
indwell           equ 4       ; hi-res dwell is in process - may drop
nextcyl           equ 5       ; quick calc for next cyl mode
invspk            equ 6       ; quick calc for inverted / non-inverted spark
FxdASEDone        equ 7       ; Fixed ASE done now use normal ASE

EnhancedBits5:    ds  1
rotary2           equ 0         ; gets copied from flash var on boot and Burn
                                ; enable twin rotor leading/trailing split stuff
checkbit          equ 1         ; For testing the code.
toothlog          equ 2         ; log teeth in wheel decoder
triglog           equ 3         ; log ignition triggers (all ignition codes)
rsh_s             equ 4         ; rotary split hysteresis on split
rsh_r             equ 5         ; rotary split hysteresis on rpm
;cto spare               equ 6         ; tach output armed
ctodiv            equ 7         ; tach output divider bit for half speed
ctodivb           equ $80       ; ctodiv for bit/eor ops

EnhancedBits6:    ds   1
hrdwon            equ  0        ; hi-res dwell hysteresis bit
wsync             equ  1        ; wheel is synced
whold             equ  2        ; wheel not in holdoff
trigger2          equ  3        ; used in conjunction with "rise" bit for 2nd trigger input
IdleAdvTimeOK     equ  4
StgTransDone      equ  5
idashbit          equ  6	; kg PWM idle
istartbit	  equ  7	; kg PWM idle added for startup


; Calculation Variable
pwrun1  ds      1       ; Pulsewidth timing variable - from 0 to 25.5ms
pwrun2  ds	1
pwcalc1 ds      1
pwcalc2 ds      1

; Engine RPM -> RPM = 12000/(ncyl * (rpmph - rpmpl))
rpmph:   ds      1       ; High part of RPM Period
rpmpl:   ds      1       ; Low part of RPM Period
rpmch:   ds      1       ; Counter for high part of RPM
rpmcl:   ds      1       ; Counter for low part of RPM
idleph            ds              1T
idlepl            ds              1T

flocker: ds      1       ; Flash locker semaphore

; Previous ADC values for computing derivatives
lmap:	ds	1	; Manifold Absolute Pressure ADC last Reading
lmat:	ds	1	; Manifold Air Temp ADC last Reading
lclt:	ds	1	; Coolant Temperature ADC last Reading
ltps:	ds	1	; Throttle Position Sensor ADC last Reading
lbatt:	ds	1	; Battery Voltage ADC last Reading
lego:   ds      1       ; Last EGO ADC reading

;Global Time Clock
mms:	ds	1	; 0.0001 second update variable
ms:	ds	1	; 0.001  second increment
tenth:  ds      1       ; 1/10th second
sech:	ds	1	; high seconds - rollover at 65536 secs (1110.933 minutes, 18.51 hours)
tpsaclk:ds      1       ; TPS enrichment timer clock in 0.1 second resolution
egocount:ds     1       ; Counter value for EGO step - incremented every ignition pulse
asecount:ds     1       ; Counter value for after-start enrichment counter - every ignition pulse
igncount1:ds     1       ; Ignition pulse counter
igncount2:ds     1       ; Ignition pulse counter
altcount1:ds     1       ; Alternate count selector
altcount2:ds     1       ; Alternate count selector
Decay_Accel:ds   1       ; Storage for Accel Value to decay from
tpsfuelcut: ds	1	; TPS Fuel Cut (percent)

;SCI parameters/variables
txcnt   ds      1       ; SCI transmitter count (incremented)
txgoal  ds      1       ; SCI number of bytes to transmit
txmode  ds      1       ; Transmit mode flag
rxoffset ds     1       ; offset placeholder when receiving VE/constants vis. SCI
adsel:	ds	1	; ADC Selector Variable

;Timer Equates for real-time clock function
T1Timerstop  equ  %00110010     ;TSC
T1Timergo    equ  %01010010     ;TSC
;T2SC0_No_PWM  equ  %00010000     ;TSC0

; These control Injector PWM mode for T1SC0 and T1SC1
Timergo_NO_INT    equ  %00000010     ;TSC without interrupts
;T1SCX_PWM  equ  %00011010       ; Unbuffered PWM enabled
T1SCX_PWM  equ  %00011110       ; Unbuffered PWM enabled - set high on compare, toggle on overflow

T1SCX_NO_PWM  equ  %00010000    ; No PWM

burnSrc         ds      2T
burnDst         ds      2T
burnCount       ds      1T

; Temporary variables
tmp1    ds      1
tmp2    ds      1
tmp3    ds      1
tmp4    ds      1
tmp5    ds      1
tmp6    ds      1
tmp7    ds      1
tmp8    ds      1
tmp9    ds      1
tmp10   ds      1
tmp11   ds      1
tmp12   ds      1
tmp13   ds      1
tmp14   ds      1
tmp15   ds      1
tmp16   ds      1
tmp17   ds      1
tmp18   ds      1
tmp19   ds      1
tmp20   ds      1
tmp21   ds      1
tmp22   ds      1

T2CNTX     ds   1     ; software 3rd byte of T2
;variables here don't need to be zero page
; Spark timing variables
T2LastX:        ds      1       ; T2 xhigh last
T2LastH:        ds      1       ; Timer 2 high last  ; T2 at last decoded pulse. All spark codes.
T2LastL:        ds      1       ; Timer 2 low last
itimeX:       ds      1       ; Time between decoded triggers in us. X - calc in DOSQUIRT
itimeH:       ds      1       ; mid byte
itimeL:       ds      1       ; low byte
SparkDelayH:    ds      1       ; Spark delay high
SparkDelayL:    ds      1       ; Spark delay low
SparkOnLeftah:   ds      1       ; Time left for spark to be on (0.1ms) coil a high
SparkOnLeftal:   ds      1       ; Time left for spark to be on (0.1ms) coil a low
SparkOnLeftbh:   ds      1       ; Time left for spark to be on (0.1ms) coil b high
SparkOnLeftbl:   ds      1       ; Time left for spark to be on (0.1ms) coil b low
SparkOnLeftch:   ds      1       ; Time left for spark to be on (0.1ms) coil c high
SparkOnLeftcl:   ds      1       ; Time left for spark to be on (0.1ms) coil c low
SparkOnLeftdh:   ds      1       ; Time left for spark to be on (0.1ms) coil d high
SparkOnLeftdl:   ds      1       ; Time left for spark to be on (0.1ms) coil d low
SparkOnLefteh:   ds      1       ; Time left for spark to be on (0.1ms) coil e high
SparkOnLeftel:   ds      1       ; Time left for spark to be on (0.1ms) coil e low
SparkOnLeftfh:   ds      1       ; Time left for spark to be on (0.1ms) coil f high
SparkOnLeftfl:   ds      1       ; Time left for spark to be on (0.1ms) coil f low
cTimeH:         ds      1       ; Cycle time for spark delay calculation
cTimeL:         ds      1       ; Cycle time for spark delay calculation
SparkTempH:     ds      1       ; Temporary storage for spark delay calculation
SparkTempL:     ds      1       ; Temporary storage for spark delay calculation
SparkCarry:     ds      1       ; Temporary storage for spark delay calculation
SRevLimTimeLeft ds      1       ; Soft rev limiter time left to hard mode
T2PrevX:        ds      1       ; top byte - only used for v.low rpm
T2PrevH:        ds      1       ; T2 at last IRQ/tooth - wheel decoder
T2PrevL:        ds      1       ; low byte
acch:           ds      1       ; engine accel/devel
accl:           ds      1       ;     "
Pambient          ds              1T
kpa               ds              1T
coolant           ds              1T
idleLastDC        ds              1T
idleTarget        ds              1T
bcDC              ds              1T
KPAlast           ds              1T
TPSlast           ds              1T
idleCtlClock      ds              1T
idleActClock      ds              1T
bcActClock        ds              1T
bcCtlClock        ds              1T ;DT
TPSfuelCorr       ds              1T

; Enhanced stuff added
OverRunTime:      ds              1       ; Timer for over run to cut in
SparkCutCnt:      ds              1
KnockTimLft:      ds              1
KnockAdv:         ds              1
kpa_n:            ds              1       ; Kpa or TPs value for spark table lookup.
tmp31:            ds              1       ; Tmp storage for anything thats only used in a jsr
tmp32:            ds              1       ; Tmp Storage for anything thats only used in a jsr
ST2Timer:         ds              1       ; Spark Table 2 delay timer
VE3Timer:         ds              1       ; VE Table 3 delay timer
TCAccel:          ds              1       ; Traction Control Enrichment
TCAngle:          ds              1       ; Traction Control Spark Retard
TCSparkCut:       ds              1       ; Traction Control Spark Cut number and prime pulse cnt
mmsDiv:           ds              1       ; 0.1mS counter for Boost Control
TCCycles:         ds              1       ; Engine hold cycles
Out3Timer:        ds              1       ; Output3 timer
;yet more ram variables for EDIS /wheel stuff
wheelcount      ds      1       ; wheel counter for decoder _and_ HoldSpark/toothsync/ignore_small
;note on wheelcount:
;In Neon mode this is used as a holdoff for syncing counting up to zero
;    bit7 = !sync
;    bit6 = holdspark
;    Once synced it is used to count the teeth
; In non-Neon mode it is used as HoldSpark counting down to zero
;these two used by tooth decoders or EDIS
dwelldelay1     ds      1       ; 2 bytes of dwell delay in 0.1ms
                ds      1
dwelldelay2     ds      1       ; same for period +1
                ds      1
dwelldelay3     ds      1       ; same for period +2
                ds      1
dwelldelay4     ds      1       ; same for period +3
                ds      1
dwelldelay5     ds      1       ; same for period +4
                ds      1
dwelldelay6     ds      1       ; same for period +5
                ds      1
sawh:                           ; EDIS SAW width
stHp:
avgtoothh:       ds      1       ; OR.. gap between teeth previous in decoders
sawl:
stLp:
avgtoothl:      ds      1       ; low byte
lowresH         ds      1       ; low res counter. Added for Neon code.
lowresL         ds      1       ;
dwelldms        ds      1       ; target dwell in 0.1ms units
dwellush        ds      1       ; target dwell in us units
dwellusl        ds      1       ;  low byte
sparktargeth    ds      1       ; H target t2 value for spark (used in hi-res dwell)
sparktargetl    ds      1       ; L
iTimepX         ds      1
iTimepH         ds       1      ; previous hi-res cycle time (for accel/decel)
iTimepL         ds       1      ;
splitdelH:      ds      1       ; trailing split delay for rotary
splitdelL:      ds      1
KnockBoost      ds      1       ; Boost to remove from controller if Knock detected
KnockAngleRet:  ds      1       ; Knock Angle storage
rpmlast:          ds              1       ; RPM accel dot last value
VlaunchLimit:     ds              1       ; Variable Launch RPM value
page            ds      1
DelayAngle:     ds      1       ; Angle to delay spark (TriggAngle - SparkAngle)
airTemp:          ds              1
NitrousAngle:     ds              1       ; Nitrous Angle of Retard
NosPW:            ds              1       ; PW to add for NOS System
pw_staged:        ds              1
n2olaunchdel:     ds              1 ; launch to nitrous delay timer
n2ohold:          ds              1 ; nitrous fuel and retard hold-on timer ; not yet used
pw_staged2:       ds 1   ; secondary pulsewidth for staging.
stgTransitionCnt: ds 1   ; transition count for staging.
idlAdvHld:        ds 1   ; Idle Advance Hold off after conditions are met.
; rename and use these place holders as needed
;ramslot10:      ds 1
;ramslot9:       ds 1
idleRPM		  ds		  1T	; PWM idle kg
idleDelayClock	  ds		  1T	; PWM Idle kg
;ramslot8:       ds 1    ; commented one more for safety zone
;xramslot7:       ds 1
;xramslot6:       ds 1
;xramslot5:       ds 1
;xramslot4:       ds 1
;xramslot3:       ds 1
;xramslot2:       ds 1
;xramslot1:       ds 1   ; oh shit, only 1 left!

;no more or ram copy of data will overrun stack
ms_ram_end:
;**************************************************
; Flash Configuration Variables here - variables can be downloaded via serial link
; VETABLE and Constants
; "VE" is entry point, everything is offset from this point
; All of these variables point to RAM locations. Renamed to _r
;
ms_rf_start:
VE_r      rmb     $90     ; 64 bytes for VE Table - Now 144 for 12x12
;CWU_r     rmb     1       ; Crank Enrichment at -40 F
;CWH_r     rmb     1       ; Crank Enrichment at 170 F
;AWEV_r    rmb     1       ; After-start Warmup Percent enrichment add-on value
;AWC_r     rmb     1       ; After-start number of cycles
;WWU_r     rmb     $0A     ; Warmup bins(fn temp)
;TPSAQ_r     rmb     $04     ; TPS acceleration amount (fn TPSDOT) in 0.1 ms units
;tpsacold_r rmb    1       ; Cold acceleration amount (at -40 degrees) in 0.1 ms units
;tpsthresh_r rmb   1       ; Accel TPS DOT threshold
;TPSASYNC_r   rmb  1       ; ***** TPS Acceleration clock value
;TPSDQ_r   rmb     1       ; Deacceleration fuel cut
egotemp_r rmb     1       ; Coolant Temperature where EGO is active
egocountcmp_r rmb 1       ; Counter value where EGO step is to occur
egodelta_r rmb    1       ; EGO Percent step size for rich/lean
egolimit_r rmb    1       ; Upper/Lower EGO rail limit (egocorr is inside 100 +/- Limit)
REQ_FUEL_r rmb    1       ; Fuel Constant
DIVIDER_r  rmb    1       ; IRQ divide factor for pulse
Alternate_r rmb   1       ; Alternate injector drivers
InjOpen_r rmb     1       ; Injector Open Time
InjOCFuel_r rmb   1       ; PW-correlated amount of fuel injected during injector open
INJPWM_r  rmb     1       ; Injector PWM duty cycle at current limit
INJPWMT_r rmb     1       ; Injector PWM mmillisec time at which to activate.
BATTFAC_r rmb     1       ; Battery Gamma Factor
rpmk_r    rmb     2       ; Constant for RPM = 12,000/ncyl - downloaded constant
RPMRANGEVE_r rmb  12      ; VE table RPM Bins for 2-D interpolation
KPARANGEVE_r rmb  12      ; VE Table MAP Pressure Bins for 2_D interp.
CONFIG11_r rmb    1       ; Configuration for PC Configurator
;  Bit 0-1 = MAP Type
;            00 = MPX4115AP
;            01 = MPX4250AP
;            10 = MPXH6300A
;            11 = MPXH6400A
;  Bit 2   = Engine Stroke
;            0 = Four Stroke
;            1 = Two Stroke
;  Bit 3   = Injection Type - NOT USED!
;            0 = Port Injection
;            1 = Throttle Body
;  Bit 4-7 = Number of Cylinders
;            0000 = 1 cylinder
;            0001 = 2 cylinders
;            0010 = 3 cylinders
;            0011 = 4 cylinders
;            0100 = 5 cylinder
;            0101 = 6 cylinders
;            0110 = 7 cylinders
;            0111 = 8 cylinders
;            1000 = 9 cylinders
;            1001 = 10 cylinders
;            1010 = 11 cylinders
;            1011 = 12 cylinders
M_TwoStroke:      equ     4

CONFIG12_r rmb    1	; Configuration for PC Configurator
;  Bit 0-1 = COOL Sensor Type
;            00 = GM
;            01 = User-defined
;            10 = User-defined
;            11 = User-Defined
;  Bit 2-3 = MAT Sensor Type
;            00 = GM
;            01 = Undefined
;            10 = Undefined
;            11 = Undefined
;  Bit 4-7 = Number of Injectors
;            0000 = 1 Injector
;            0001 = 2 Injectors
;            0010 = 3 Injectors
;            0011 = 4 Injectors
;            0100 = 5 Injectors
;            0101 = 6 Injectors
;            0110 = 7 Injectors
;            0111 = 8 Injectors
;            1000 = 9 Injectors
;            1001 = 10 Injectors
;            1010 = 11 Injectors
;            1011 = 12 Injectors
CONFIG13_r  rmb   1	; Configuration for PC Configurator
;  Bit 0   = Odd-fire averaging
;            0 = Normal
;            1 = Odd-Fire
;  Bit 1   = O2 Sensor Type
;            0 = Narrow-band (single wire 14.7 stoch)
;            1 = DIY-WB (Stoch = 2.5V, reverse slope)
;  Bit 2   = Control Stategy
;            0 = Speed-Density
;            1 = Alpha-N
;  Bit 3   = Barometer Correction
;            0 = Enrichment Off (set to 100%)
;            1 = Enrichment On
;PRIMEP_r rmb      1	; Priming pulses (0.1 millisec units)
RPMOXLIMIT_r rmb  1	; Minimum RPM where O2 Closed Loop is Active
FASTIDLE_r    rmb   1       ; Fast idle if enabled
VOLTOXTARGET_r rmb 1	; O2 sensor flip target value
;ACMULT_r    rmb   1       ; Acceleration cold multiplication factor (percent/100)
;BLANK   rmb     4       ; Extra Slots to make up 64 bytes total

;Page 0 variables
;These are flash ONLY so no need to read them from RAM

;Page 3 spark variables that get used from RAM
ST_r             equ       ms_rf_start        ; spark timing table
RPMRANGEST_r      equ     {ms_rf_start + $90}  ; Spark timing RPM bins for 2-D interpolation
KPARANGEST_r      equ     {ms_rf_start + $9c}  ; Spark timing MAP pressure bins for 2-D interpolation

TriggAngle_r      equ     {ms_rf_start + $a8}  ; Trigger angle BTDC
FixedAngle_r      equ     {ms_rf_start + $a9}  ; Fixed angle, 0 = not in used
TrimAngle_r       equ     {ms_rf_start + $aa}  ; Trim angle, positive and negative
CrankAngle_r      equ     {ms_rf_start + $ab}  ; Cranking angle

; Increased to 200 as according to the 'List' file thats the size of ms_fr since 12x12 ?
	org	{ms_rf_start + 200T}  ; reserve 200 bytes for paging use in RAM
ms_rf_end:

;-------------------------------------------------------------------------------
ms_ram_size       equ {ms_ram_end-ms_ram_start}
ms_rf_size        equ {ms_rf_end-ms_rf_start}
ms_total_ram_size equ {ms_rf_end-ms_ram_start}
;-------------------------------------------------------------------------------
;new equates so burner ram_exec area can be used as temp storage WITHIN int handlers
int_ram       equ      $01ED    ; same as ram_exec, space used by burner

itmp00        equ       {int_ram + $00 }
itmp01        equ       {int_ram + $01 }
itmp02        equ       {int_ram + $02 }
itmp03        equ       {int_ram + $03 }
itmp04        equ       {int_ram + $04 }
itmp05        equ       {int_ram + $05 }
itmp06        equ       {int_ram + $06 }
itmp07        equ       {int_ram + $07 }
itmp08        equ       {int_ram + $08 }
itmp09        equ       {int_ram + $09 }
itmp0a        equ       {int_ram + $0a }
itmp0b        equ       {int_ram + $0b }
itmp0c        equ       {int_ram + $0c }
itmp0d        equ       {int_ram + $0d }
itmp0e        equ       {int_ram + $0e }
itmp0f        equ       {int_ram + $0f }

itmp10        equ       {int_ram + $10 }
itmp11        equ       {int_ram + $11 }
itmp12        equ       {int_ram + $12 }
itmp13        equ       {int_ram + $13 }
itmp14        equ       {int_ram + $14 }
itmp15        equ       {int_ram + $15 }
itmp16        equ       {int_ram + $16 }
itmp17        equ       {int_ram + $17 }
itmp18        equ       {int_ram + $18 }
itmp19        equ       {int_ram + $19 }
itmp1a        equ       {int_ram + $1a }
itmp1b        equ       {int_ram + $1b }
itmp1c        equ       {int_ram + $1c }
itmp1d        equ       {int_ram + $1d }
itmp1e        equ       {int_ram + $1e }
itmp1f        equ       {int_ram + $1f }

itmpcomm      equ       {int_ram + $20 }  ; $32 (50) bytes for SCI comm data packet
