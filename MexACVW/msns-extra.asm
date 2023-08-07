;***************************************************************************
;* msns-extra.asm MexACVW3 version
;* By Robert Hiebert, Project started July 11 2023
;*
;* This is a stripped down, no frills version of the MSnS extra 029y4a
;* code designed to run a stock or nearly stock 4cyl air cooled VW engine
;* with Mexican EFI hardware. It uses a modified Megasquirt V2.2 board and a
;* custom relay board and is tuned with Tuner Studio running the 029y4a
;* .ini file.
;* Text editor Notepad++
;* Developement suite Winide.exe
;****************************************************************************
;*
;* MegaSquirt Hardware Wiring
;*
; Port A
;  PTA0 - FP                                            ;* fuelp
;  PTA1 - FIDLE                                         ;* iasc
;  PTA2 - Output 2 (X5)                                 ;* Tacho
;  PTA3 - Output 1 (X4)
;  PTA4             X3
;  PTA5             X2
;  PTA6 - Flyback
;  PTA7 - Flyback

; Port B (ADC inputs)
;  PTB0/AD0 - MAP                                        ;* MAP
;  PTB1/AD1 - MAT                                        ;* MAT
;  PTB2/AD2 - CLT                                        ;* CLT
;  PTB3/AD3 - TPS                                        ;* TPS
;  PTB4/AD4 - BAT                                        ;* BAT
;  PTB5/AD5 - EGO                                        ;* EGO
;  PTB6/AD6 - "X7" spare, EGO2, fuel pressure or 2nd MAP
;  PTB7/AD7 - "X6" spare, EGT

; Port C
;  PTC0 - Squirt LED  or coil a                          ;* coila
;  PTC1 - Accel LED   or coil b or HEI7 bypass           ;* coilb
;  PTC2 - Warmup LED  or coil c or output 4              ;* output4 (test LED)
;  PTC3 } multiplexed shift { or coil e
;  PTC4 } light outputs     { or 2nd trig input

; Port D
;  PTD0/~SS - unused  or coil d
;  PTD1/MISO - nitrous in / table switch
;  PTD2/MOSI - knock in / coil f
;  PTD3/SPSCK - launch in
;  PTD4/T1CH0 - Inj1                                     ;* Inj1
;  PTD5/T1CH1 - Inj2                                     ;* Inj2

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
;*        brset   EDIS,personality,init_edis

;this won't work for next-cyl but will be ignored at low rpm anyway
        lda     TriggAngle_f
        sub     CrankAngle_f
        add     #28T			; - - 10deg
        sta     DelayAngle
        lda     SparkHoldCyc_f
        sta     wheelcount		; (HoldSpark)

init_wheel:
	mov     #WHEELINIT,wheelcount	; holdoff for Neon/Wheel
        bclr    wsync,EnhancedBits6
        bset    whold,EnhancedBits6
        lda     #0
        sta     avgtoothh
        sta     avgtoothl
        lda     #$FF
        sta     iTimeH
        sta     iTimeL
        sta     iTimeX
        bset    invspk,EnhancedBits4	; set inverted
        bclr    rotary2,EnhancedBits5  ; clr rotary quick bit
        bset    wspk,EnhancedBits4	; set that we are doing wasted spark
mv_init:
; set MegaView mode to block enhanced comms, S,P,R,X commands reset
; it to allow normal ops
        bset    mv_mode,EnhancedBits2

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
;*	lda     MATFACTOR,x
	lda     THERMFACTOR,x
        sta     airTemp
	clr     adsel		; Clear the channel selector
TURN_ON_INTS:
        cli			; Turn on all interrupts now

***************************************************************************
**
** Prime Pulse - Shoot out one priming pulse of length PRIMEP now or
** after 2 seconds
** Also added the facility for 2 priming pulses  P Ringwood
**
***************************************************************************
        bset   Primed,EnhancedBits		; set the primed bit
        jsr    crankingModePrime
        lda    tmp6
        bset   running,engine
        bset   fuelp,porta
        sta    pw1
        clr    pwrun1
        bset   sched1,squirt
        bset   inj1,squirt
        sta    pw2
        clr    pwrun2
        bset   sched2,squirt
        bset   inj2,squirt

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
          bra    OneShot_Bar   ;* RJH 8/03/23

bEnd_of_Baro:
        jmp     End_of_Baro		; extend branch below

OneShot_Bar:
        bset    OneShotBArro,EnhancedBits2
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

;do_baro_4250:
        lda     KPAFACTOR4250,x
        sta     Pambient
        lda     BAROFAC4250,x
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
        bra     do_kpa4115

do_kpa4250:
        lda     KPAFACTOR4250,x
        bra     Donekpa

do_kpa4115:
        lda     KPAFACTOR4115,x

Donekpa:
        sta     kpa
        ldx     clt
        lda     THERMFACTOR,x
        sta     coolant			; Coolant temperature in degrees F + 40
        ldx     mat
        lda     THERMFACTOR,x
        sta     airTemp			; Added for enhanced stuff Air Temp in F + 40

;******** NORMAL AIR DENSITY **************************************
NormAirDen:
        ldx     mat
        lda     AIRDENFACTOR,x
Store_AirCor:
        sta     AirCor			; Air Density Correction Factor

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
;        bhi     runIt          ;* doesn't branch until 4T
        bhs     runIt           ;* branches at or above 3T
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

;***************************************************************************
;***************************************************************************
;**
;**  VE 3-D Table Lookup
;**
;**   This is used to determine value of VE based on RPM and MAP
;**   The table looks like:
;**
;**      105 +....+....+....+....+....+....+....+
;**          ....................................
;**      100 +....+....+....+....+....+....+....+
;**                     ...
;**   KPA                 ...
;**                         ...
;**       35 +....+....+....+....+....+....+....+
;**          5    15   25   35   45   55   65   75 RPM/100
;**
;**
;**  Steps:
;**   1) Find the bracketing KPA positions via tableLookup, put index in
;**       tmp8 and bounding values in tmp9(kpa1) and tmp10(kpa2)
;**   2) Find the bracketing RPM positions via tableLookup, store index
;**       in tmp11 and bounding values in tmp13(rpm1) and tmp14(rpm2)
;**   3) Using the VE table, find the table VE values for tmp15=VE(kpa1,rpm1),
;**       tmp16=VE(kpa1,rpm2), tmp17 = VE(kpa2,rpm1), and tmp18 = VE(kpa2,rpm2)
;**   4) Find the interpolated VE value at the lower KPA range :
;**       x1=rpm1, x2=rpm2, y1=VE(kpa1,rpm1), y2=VE(kpa1,rpm2) - put in tmp19
;**   5) Find the interpolated VE value at the upper KPA range :
;**       x1=rpm1, x2=rpm2, y1=VE(kpa2,rpm1), y2=VE(kpa2,rpm2) - put in tmp11
;**   6) Find the final VE value using the two interpolated VE values:
;**       x1=kpa1, x2=kpa2, y1=VE_FROM_STEP_4, y2=VE_FROM_STEP_5
;**
;***************************************************************************

;***************************************************************************
;** JSM changed it to just be one routine per page. Maybe Eric will kill
;** me, but we've plenty of flash and I'm obviously a bit lazy.
;***************************************************************************

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

jWUE_DONE:
        jmp     WUE_DONE 
		
WUE2:

WUE2_ledskip:
        brclr   startw,engine,jWUE_DONE
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
        lda     tmp31
        cmp     TPSthresh_f1		; Are we above the Accel
					; threshold for TPS?
        bhs     AE_SET
        brclr   TPSAEN,ENGINE,acc_done_led   ; If we are not in AE mode then jump to end
        jmp     TAE_CHK_TIME
AE_SET:
        brset   TPSAEN,ENGINE,AE_COMP_SHOOT_AMT

; Add in accel enrichment
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
        bhs     Clear_Decel

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
        brset   NosSysOn,EnhancedBits,SKIP_ALL_O2; If NOS running then no
					;O2 checks
        brset   OverRun,EnhancedBits,SKIP_ALL_O2; Skip O2 if in Overrun mode
        lda     EGOdelta_f		; No delta means open loop.
        beq     SkipO2JMP
        lda   kpaO2_f			; In KPa mode so is it higher
					; than setpoint?
        beq   SETAFR_UP			; If its zero dont check it as
					; no open loop
        cmp   kpa
        blo   SKIP_ALL_O2		; If it is dont check O2
No_KPA_Check:
        bra   SETAFR_UP

SkipO2JMP:
         bra    SKIPO2A

SKIP_ALL_O2:				; Skip both O2 checks
         lda    #100T
         sta    EGOCorr
         sta    EgoCorr2
         jmp    EGOALL_DONE

SETAFR_UP:
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
        lda     Egocorr
        sta     Egocorr2
		
EGOALL_DONE:

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
        mov     tmp10,GammaE

ld_ve_1Done:
        mov     EGOcorr,tmp10		; closed-loop correction percent
					; into tmp10
        clr     tmp11			; remainder is zero
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

Calc_Final1Done:
	mov     tmp20,tmp1		; store PW from table 1

both_table1:
        lda     tmp20
        sta     tmp1
        sta     tmp2

checkRPMsettings:
        ; Do all the rpm related stuff here.
		
        bclr    sparkCut,RevLimBits		; Reset spark cut bit
        bra   checkRevsOk  ;* RJH 8/04/23 

cutChannels:
        clr     tmp1
        clr     tmp2
        bclr    OverRun,EnhancedBits		; Reset Over Run Fuel Cut
        mov     tmp1,pwcalc1
        mov     tmp2,pwcalc2
        bra     spark_lookup					; In fuel cut mode so return
						; with zeros
checkRevsOk:
        brset   OverRun,EnhancedBits,cutChannels; If Over run fuel cut on
						; cut fuel
        mov       tmp1,pwcalc1
        mov       tmp2,pwcalc2

***************************************************************************
**
** Check if fixed spark angle - only works if we are tuning this page
**
***************************************************************************
spark_lookup:
                lda     page
                cmp     #3
                bne     fixed_fl
                lda     FixedAngle_r
                bra     fxr_c

fixed_fl:       lda     FixedAngle_f
fxr_c:
                cmp     #$03
                blo     NOT_FIXED	; Added this as earlier MT didnt
					; send a perfect 00T for -10 (use map)
               ;; sta     SparkAngle	; else use this fixed advance
                jmp     CALC_DELAY
NOT_FIXED:

;***************************************************************************
;**
;**  ST 3-D Table Lookup
;**
;**   This is used to determine value of SparkAngle ST based on RPM and MAP
;**   The table looks like:
;**
;**      105 +....+....+....+....+....+....+....+
;**          ....................................
;**      100 +....+....+....+....+....+....+....+
;**                     ...
;**   KPA                 ...
;**                         ...
;**       35 +....+....+....+....+....+....+....+
;**          5    15   25   35   45   55   65   75 RPM/100
;**
;**
;**  Steps:
;**   1) Find the bracketing KPA positions via tableLookup,
;**       put index in tmp8 and bounding values in tmp9(kpa1) and tmp10(kpa2)
;**   2) Find the bracketing RPM positions via tableLookup, store
;**       index in tmp11 and bounding values in tmp13(rpm1) and tmp14(rpm2)
;**   3) Using the ST table, find the table ST values for tmp15=ST(kpa1,rpm1),
;**       tmp16=ST(kpa1,rpm2), tmp17 = ST(kpa2,rpm1), and tmp18 = ST(kpa2,rpm2)
;**   4) Find the interpolated ST value at the lower KPA range :
;**       x1=rpm1, x2=rpm2, y1=ST(kpa1,rpm1), y2=ST(kpa1,rpm2) - put in tmp19
;**   5) Find the interpolated ST value at the upper KPA range :
;**       x1=rpm1, x2=rpm2, y1=ST(kpa2,rpm1), y2=ST(kpa2,rpm2) - put in tmp11
;**   6) Find the final ST value using the two interpolated ST values:
;**       x1=kpa1, x2=kpa2, y1=ST_FROM_STEP_4, y2=ST_FROM_STEP_5
;**
;***************************************************************************

STTABLELOOKUP:
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
        lda     tmp31			; Reload the look up angle for ST1
        sta     tmp6
Not_ST1:
        lda     page
        cmp     #3
        bne     trim_fl
        lda     TrimAngle_r
        bra     trim_c
		
trim_fl:
        lda     TrimAngle_f
		
trim_c:
        bpl     CHECK_SP_ADD		; check adding of trim
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
        lda     CrankAngle_f		; Update spark angle for User Interface

TRIM_DONE2:

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

store_spark2:
CALC_DELAY:
        tax    ; take a copy in x, but don't save to SparkAngle yet
        stx     SparkAngle
        lda     TriggAngle_f
        sub     SparkAngle
        add     #28T
        sta     DelayAngle

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

IdleAdjust:

idlePWM:
	brset   istartbit,EnhancedBits6,Crank_PWM	; loop to stabilize on startup
	brset   crank,engine,Crank_PWM		; open AIC for cranking
	brclr   running,engine,Idle_doneJMP1	; no PWM adjust when not running

idle_openloop:
        lda     coolant
        cmp     slowIdleTemp_f
        blo     idle_loopcold
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
    bra idle_DoneJMP1  ;*RJH 8/05/23
	
Idle_done:

***************************************************************************
********************    S U B   S E C T I O N    L O O P     **************
***************************************************************************


        jsr     AFR1_Targets; Get Target AFR
							; from table 1 for VE 1

        brset   running,engine,nospkoff   ; skip next check
        ;if not running then make sure all spark outputs are OFF
        ;this is a bandaid, but better safe than sorry
        jsr     turnallsparkoff     ; subroutine to stop them all
nospkoff:

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

floodClear:
        clra				; Turn off pulses altogether.
        jmp     crankingDone

; Extra Fueling for Cranking! This is triggered if the TPS goes above the floodclear
; value 3 times before starting. Were using the NosDcOk Bit as its not used at cranking.
; Were also using various Traction Bytes too. All this to save RAM.

ExtraFuelCrank:
        bra     floodClear   ;* RJH 7/25/23

crankingPW:
        lda     coolant
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
        lda     tmp6			; Leave it where expected.

crankingDone:
        sta     tmp1
        brclr   CrankingPW2,feature1,no_crankpw2
        sta     tmp2			; Pulse bank 2 just like bank 1.
       rts
	   
no_crankpw2:
        clr     tmp2			; Zero out bank 2 while cranking.
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

***************************************************************************

$MACRO TurnAllSpkOff			; gets called in stall or on
					; entering bootloader mode
					;turn spark outputs to inactive

        bclr     iasc,porta
        bclr     sled,portc
        bclr     aled,portc
        bclr     Output3,portd
        bclr     pin10,portc
        bclr     KnockIn,portd

;kill the dwell timers too just in case
        clr     SparkOnLeftah
        clr     SparkOnLeftal
        clr     SparkOnLeftbh
        clr     SparkOnLeftbl

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


                DwellRail     ; check if negative or less than mindischarge
                DwellDiv         ; convert microseconds to 0.1ms units
                sthx    dwelldelay2

;finally we've calculated everything we need to for dwell and saved it away - phew!

        rts

;***************************************************************************
;**
;** * * * * Interrupt Section * * * * *
;**
;** Following interrupt service routines:
;**  - Timer Overflow
;**  - ADC Conversion Complete
;**  - IRQ input line transistion from high to low
;**  - Serial Communication received character
;**  - Serial Communications transmit buffer empty (send another character)
;**
;***************************************************************************

;First some Macros used within the interrupt sections

$MACRO COILNEG

        brset   coilabit,coilsel,dslsa
        brset   coilbbit,coilsel,dslsb
        bra     cn_end			; should never get here

dslsa:
        bset    coila,portc		; Set spark on
        bra     cn_end

dslsb:
        bset    coilb,portc		; Set spark on
        bra     cn_end

cn_end:

$MACROEND

;***************************************************************************

$MACRO COILPOS
        brset   coilabit,coilsel,ilsoa
        brset   coilbbit,coilsel,ilsob
        bra     fc_end			; should never get here
		
ilsoa:
        bclr    coila,portc
        bra     fc_end
ilsob:
        bclr    coilb,portc
        bra     fc_end

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

wdwell2op:
;first off always store a 360deg dwell delay
                ldhx    dwelldelay2    ; precalculated to rail at mindischg
                brset   coilbbit,coilsel,wd2b360
wd2a360:        sthx    SparkOnLeftah
                bra     wd2end360
wd2b360:        sthx    SparkOnLeftbh
wd2end360:

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

wd2skip:        

$MACROEND

******************************************************************************
;some timerroll equates - local variables that can only be used with irqs blocked
;we'll start using itmp00 - itmp0f in here

TIMERROLL:

                 bclr    checkbit,EnhancedBits5
                 pshh			; Stack h
                lda     T2SC0		; ack the interrupt
                bclr    CHxF,T2SC0	; clear pending bit
                lda     T2CNTL		; unlatch any previous read (added JSM)

; revised section - from Dan Hiebert's TFI code
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

        inc      mms			; bump up 0.1 millisec variable

; now with multi-dwell check them all each time (how much delay to
; 0.1ms routine?) this routine is flawed but only slightly - when one
; coil gets to zero those below don't get decremented so will be 0.1ms
; late. a jsr would be nice.
;
        sei				; no ints while we are
					; stealing this variable
        mov     coilsel,SparkCarry; temporary

	brclr	indwell,EnhancedBits4,sin_a


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
        beq     j_CSL
        aix     #-1			; is it time to start charging
        sthx    SparkOnLeftbh
        cphx    #0
        bne     j_CSL
        clr     coilsel
        bset    coilbbit,coilsel
        bra     lowspdspk

j_CSL:
        cli
        jmp     CHECK_SPARK_LATE

lowspdspk:
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

        bra     lsspk_inv       ;* RJH 7/25/23
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
		bra     IRQ_SPARK   ;* RJH 7/25/23

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
        bra    irq_spark_neon  ;* RJH 8/07/23    

ChkHold:
        bclr    sparktrigg,sparkbits	; No more sparks for this IRQ
		bra   DoSparkLSpeed  ;* RJH 8/07/23 

; This will not work with wheel decoder, need to use a flag
;        Treat end of third pulse as trigger return
irq_spark_neon:
        brclr   trigret,SparkBits,jINJ_FIRE_CTL
        bclr    trigret,SparkBits	; clear it now
        bclr    sparktrigg,sparkbits	; No more sparks for this IRQ

DoSparkLSpeed:
        bset    sparkon,revlimbits	; spark now on

        COILPOS				; macro = fire coil for inverted

; changed - low speed and dwell control, schedule dwell at same time
; as we schedule the spark to maintain a consistent dwell

b_INJFC2:
        jmp     INJ_FIRE_CTL

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

nsq2:
        mov      #$00,T1CH1H

        lda      INJPWM_f1
nsq2cont:
        sta      T1CH1L
        bset     6,PORTA		; ** Flyback Damper - turn on X1
					; for Injector 2
        bclr     inject2,portd		; ^* * * Turn on Injector #2
					; (inverted drive)
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
        jmp      INJF3

;=== Injector #2 - Check for end of Injection ===
CHK_DONE_2:
        inc      pwrun2
        lda      pwrun2
        cmp      pw2
        beq      OFF_INJ_2
	brclr	 crank,engine,CKDN2
        jmp      CHECK_RPM
CKDN2:
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
        mov      #T1Timerstop,T1SC
        mov      #t1scx_NO_PWM,T1SC1
        mov      #Timergo_NO_INT,T1SC
        bra      inj2done
PWM_LIMIT_2:
        mov      #T1Timerstop,T1SC
        mov      #T1SCX_PWM,T1SC1
        mov      #Timergo_NO_INT,T1SC

inj2done:

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

;=======Check RPM Section=====
CHECK_RPM:
        brclr    running,engine,b_ENABLE; Branch if not running
					; right now
        brset    firing1,squirt,CHK_RE_ENABLE
        brset    firing2,squirt,CHK_RE_ENABLE

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

       bclr     output2,porta    ;* tacho  off

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
        lda      TriggAngle_f		; Calculate crank delay angle
        sub      CrankAngle_f
        add      #28T			; - -10 deg
        sta      DelayAngle
pass_store:
        lda      CrankAngle_f		; Update spark angle for user interface
        sta      SparkAngle
        lda      SparkHoldCyc_f		; Hold spark after stall
        sta      wheelcount		; (HoldSpark)
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
        inc      ms			; bump up millisec
        clr      mms
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
        lda      rpm
        sta      rpmlast
    bra    No_TPSCount  ;* RJH 7/31/23 

;******
RTC_DONEJMP:
       jmp     RTC_DONE
;******

No_TPSCount:
        lda      tenth
        cmp      #$0A
        blo      RTC_DONE

****************************************************************************
********************** seconds section ***********************************
****************************************************************************
SECONDS:
        inc      OverRunTime

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
        bset    TOIE,T2SC0		; re-enable 0.1ms interrupt
NOTSPKTIME:				; close branch for below
        pulh
	rti

***************************************************************************
**
** Spark timing
**
***************************************************************************

j_hires_dwell:    jmp   hires_dwell

SPARKTIME:
                pshh
                lda     T2SC1		; Read interrupt
                bclr    CHxF,T2SC1	; Reset interrupt

                brclr   SparkHSpeed,SparkBits,NOTSPKTIME	; Don't spark
					; on time when going slow
                brset   indwell,EnhancedBits4,j_hires_dwell	; start dwell
					; period
                brclr   SparkTrigg,Sparkbits,NOTSPKTIME	; Should never do this
                bset    sparkon,revlimbits	; spark now on

                COILPOS			; macro = fire coil for inverted

                bclr    TOIE,T2SC1	; Disable interrupts

                CalcDwellspk		; Set spark on time

sparktime_exit:
                bclr    SparkTrigg,Sparkbits	; No more sparks for this IRQ
                pulh
                rti

hires_dwell:

;first turn on coil, then reset T2 to spark point saved in sparktargetH/L
;spark cut- actually cut the coil-on
                lda     SparkCutCnt	; Check Spark Counter
                inca
                cmp     SparkCutBase_f	; How many sparks to count to
                blo     Dont_ResetCnt2
                lda     #01T
Dont_ResetCnt2:
                sta     SparkCutCnt	; Store new value to spark counter

                COILNEG			; macro = charge coil for inverted

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

****************************************************************************
**  generic wheel decoder
**  -1 Missing tooth when iTimet > 1.5 * iTimep
**  -2 Missing teeth when iTimet > 1.5 * iTimep (was 2.5*) (changed 029k)
**  We don't get here until we've had a few teeth. When we've found
** missing tooth then clr top bit of wheelcount
**
****************************************************************************
decode_wheel:

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
        bset    wsync,EnhancedBits6

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

wc_op2:
; decode multiple outputs
        cmp     trig1_f
        beq     w_trig1
        cmp     trig2_f
        beq     w_trig2

wc_op3:
        cmp     trig1ret_f
        beq     w_trigret1
        cmp     trig2ret_f
        beq     w_trigret2
        bra     ret_w

w_trig1:
        clr     coilsel
        bset    coilabit,coilsel
        jmp     w_store2

w_trig2:
        clr     coilsel
        bset    coilbbit,coilsel
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
        bset     output2,porta    ;* tacho on

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


*****************************************************************************

miss_chk_skip:
        bset    SparkTrigg,Sparkbits	; IRQ triggered, but no spark yet

        inc     idleCtlClock		; Idle PWM Clock counter
	lda	idleDelayClock		; Idle PWM delay counter
	beq	delay_done
	deca				; idle seconds clock
	sta	idleDelayClock
delay_done:

     	lda	igncount1
	bne     EGOBUMP		       ; Only increment counters if
					; cylinder count is zero
    inc      asecount		; Increment after-start enrichment
					; counter

TPS_COUNTER:
      brclr    taeIgnCount,feature1,EGOBUMP	; Are we in Cycle counter
					; mode for TPS Accel?
      inc      tpsaclk			; Yes so increment counter

; Save current TPS reading in last_tps variable to compute TPSDOT in
; acceleration enrichment section or KPa in KPa last if in MAP dot

tps_dot_on:
       lda      tps
Kpa_Dot_on:
       sta      TPSlast

EGOBUMP:
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



LOW_SPEED:
        bclr    SparkHSpeed,SparkBits	; Turn off high speed ignition
        bset    SparkLSpeed,SparkBits	; Turn on low speed ignition

        bra     DELAY_CALC

ASIS_SPEED:
		bra    DELAY_CALC     ;* RJH 7/25/23

VARIABLE_DELAY:

HIGH_SPEED:

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

        lsl     cTimeL
        rol     cTimeH
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
        brset   SparkHSpeed,SparkBits,set_spk_timer	; High speed set timer

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



lsd_a:  sthx    SparkOnLeftah		; Store time to keep output the same
        jmp     SKIP_CYCLE_CALC
lsd_b:  sthx    SparkOnLeftbh		; Store time to keep output the same
        jmp     SKIP_CYCLE_CALC

set_spk_timer:

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

        bra     do_set_spk		; how?
zd_a:   
        sthx    SparkOnLeftah		; Store time to keep output the same
        bra     do_set_spk
		
zd_b:   
        sthx    SparkOnLeftbh		; Store time to keep output the same
        bra     do_set_spk

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
        inc       altcount1
        brset     0,altcount1,squirtDone1
		
schedule1a:
        mov       pwcalc1,pw1
        beq       squirtDone1		; check for zero pulse
        bset      sched1,squirt
        bset      inj1,squirt
		
squirtDone1:
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
        inc       altcount2
        brclr     0,altcount2,squirtDone2
		
schedule2da:
        mov       pwcalc2,pw2
        beq       squirtDone2		; check for zero pulse
        bset      sched2,squirt
        bset      inj2,squirt

squirtDone2:
        pulh
        rti

***************************************************************************
**
** ADC - Interrupt for ADC conversion complete
**
***************************************************************************

ADCDONE:
        pshh            ; Do this because processor does not stack H

        clrh
; Store previous values for derivative
        lda     adsel
        tax
        lda     map,x
        sta     lmap,x  ; Store the old value

	lda	adr     ; Load in the new ADC reading
        add     map,x   ; Perform (map + last_map)/2 averaging (for all ADC readings) - bug fix
        rora
	sta	map,x 	; MAP is entry point, offset is loaded in index register

	lda     adsel
	inca
	cmp	#$06
	bne	ADCPTR
	clra
ADCPTR:
	sta	adsel

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
;*        brclr   wd_2trig,feature1,ckp0_norm_ddrc
;*        lda     #%00001111              ; make PTC4 an input for second trigger
;*        bra     ckp0_ddrc
;*ckp0_norm_ddrc:
        lda     #%00011111		; ** Was 11111111
ckp0_ddrc:
        sta     ddrc			; Outputs for LED

;decide if we are doing multiple wasted spark outputs
;check this here so a changed setting or MSQ load will correctly init the variables
;*        brset   MSNEON,personality,pz_wspk
;*        brset   WHEEL,personality,pz_wspk
;*pz_nwspk:
;*        bclr    wspk,EnhancedBits4	; set that we are NOT doing wasted spark
;*        bra     DONE_B
;*pz_wspk:
;*        brclr   REUSE_LED19,outputpins,pz_nwspk
;*        brset   rotary2,EnhancedBits5,pz_nwspk
        bset    wspk,EnhancedBits4	; set that we are doing wasted spark
        bra     DONE_B

ck_page3:
;see if inverted or non-inv output and use a quick bit
;*        lda     SparkConfig1_f		; check if noninv or inv spark
;*        bit     #M_SC1InvSpark
;*        bne     ckp3_inv
;*        bclr    invspk,EnhancedBits4	; set non-inverted
;*        bra     ckp3_i_done
;*ckp3_inv:
        bset    invspk,EnhancedBits4	; set inverted
ckp3_i_done:


;EDIS and NEON are never next-cylinder
;*        brset   EDIS,personality,not_nc
;*        brset   MSNEON,personality,not_nc

;*        lda     TriggAngle_f
;*        cmp     #57T			; check for next cyl mode
;*        bhi     not_nc		; trigger angle > 20, continue
;*        bset    nextcyl,EnhancedBits4
;*        bra     DONE_B
;*not_nc:
        bclr    nextcyl,EnhancedBits4
        bra     DONE_B

ck_page7:
;*        lda     p8feat1_f
;*        bit     #rotary2b
;*        beq     ckp7nr
;*        bset    rotary2,EnhancedBits5
;*        bclr    wspk,EnhancedBits4	; set that we are NOT doing normal wasted spark
;*        bra     DONE_B
;*ckp7nr:
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
**    8x8 Target AFR Tables                            P Ringwood          ***
**    AFR Table 1 is for VE table 1   AFR Table 2 is for VE table 3        ***
******************************************************************************

AFR1_Targets:
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
        lda     kpa                     ; Normal Speed density
        bra     AFR1_STEP_1

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
textversion_f:   db   'MS1/Extra rev 029y4 MexACVW3****' ; full code release
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
;*        include "barofactor300k.inc"
        include "barofactor4115.inc"
        include "barofactor4250.inc"
        include "kpafactor4115.inc"
        include "kpafactor4250.inc"
        include "thermfactor.inc"
        include "airdenfactor.inc"
;*        include "matfactor.inc"
;*        include "barofactor400k.inc"
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
