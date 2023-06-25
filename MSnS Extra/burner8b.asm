;*****************************************************************************
; Meagasquirt Flash page erase and programming routines
; heavily based on the routines from boot_r12.asm
;
;*****************************************************************************
; JSM - revised timing for 8MHz
; 12 Sep 04. Re-enabled interrupts during programming to avoid missing them
;            when burning lots of data.
; 24 Feb 05, took cli back out again so burner ram can be used within irqs
; 6 Nov 05 (026j7) Changed hardcoded page from $D0 to $E0
;-------------------------------------------------------------------------------
; burnConst: is a PCC compatible FLASH Programming Routine - I think
;-------------------------------------------------------------------------------

burnConst:
        lda       flocker
        cmp       #$CC
        beq       BURN_CONT
        rts
BURN_CONT:
        lda     page
        add     #$E0                    ; hardcoded start of pages
        psha
        pulh
        clrx
        sthx    burnDst
        jsr     ms_EraseFlash           ; Erase the first 128 byte block (disables ints)
;        cli
        ldhx    burnDst
        aix     #64T
        aix     #64T
        sthx    burnDst
        jsr     ms_EraseFlash           ; and the second
;        cli
        lda     page
        add     #$E0                    ; hardcoded start of pages
        psha
        pulh
        clrx
        sthx    burnDst
        ldhx    #VE_r
        sthx    burnSrc

        lda     #200T                    ; burn 200 bytes (was 256) Now 212, NOW 200 for 022xxxxxx
        sta     burncount

        clrh
        clrx
        jmp     ms_ProgramFlash

;-------------------------------------------------------------------------------


;*  Single Flash Page Erase Subroutine  ======================================
;*
; This subroutine will copy the Flash Erase algorithm into RAM and execute
; it to erase the page starting at address pointers "burnDst"
;
ms_EraseFlash:
        ldhx    #ms_EraseRamSize                ; initialize pointer
ms_EraseFlash1:
        lda     ms_MassErase-1,x                ; get program from Flash
        sta     ram_exec-1,x                    ; copy into RAM
        dbnzx   ms_EraseFlash1                  ; decrement pointer and loop back until done
        sei
        jmp     ram_exec                        ; execute Flash Mass Erase algorithm from RAM

;*  Flash Program Subroutine  ================================================
;*
; This subroutine will copy the Flash Program algorithm into RAM and execute it
; to program 'burncount' bytes from the address pointed to by 'burnSrc' to the
; address pointed to by "burnDst"
;
ms_ProgramFlash:
        ldhx    #ms_ProgramRamSize              ; initialize pointer
ms_ProgramFlash1:
        lda     ms_Delay-1,x                    ; get program from Flash
        sta     ram_exec-1,x                    ; copy into RAM
        dbnzx   ms_ProgramFlash1                ; decrement pointer and loop back until done
        sei
        jmp     {ram_exec+ms_ProgramRam}
;
;
;*  Flash Erase Subroutine  ==================================================
;*
;*  This subroutine performs a single Page Erase @ BurnDst
;*  This subroutine has been
;*  tuned for a bus speed of 7.3728 MHz.
;*  constants revised for 8MHz
;*  This subroutine is copied into and executed from RAM.
;*
ms_MassErase:
        ldhx    burnDst            ; initialize pointer to Flash memory address

;   Set ERASE, read the Flash Block Protect Register and write any data into Flash page.
;
        lda     #{ERASE}                    ; set ERASE control bit
        sta     flcr                        ;  in Flash Control Register
        lda     flbpr                       ; read from Flash Block Protect Register
        sta     ,x                          ; write any data to address within page
;
;   Wait for >10us, then set HVEN.
;
        lda     #1                          ; wait
        bsr     ms_delay                       ;  for 11.7us (now 11.1)
        lda     #{ERASE | HVEN}             ; set HVEN control bit
        sta     flcr                        ;  in Flash Control Register
;
;   Wait for >1ms, then clear ERASE.
;
        lda     #105T                        ; wait (was 100T)
        bsr     ms_delay                       ;  for 1.005ms (now 1.012ms)
        lda     #{HVEN}                     ; clear ERASE control bit
        sta     flcr                        ;  in Flash Control Register
;
;   Wait for >5us, then clear HVEN.
;
        lda     #1                          ; wait
        bsr     ms_delay                       ;  for 11.7us (now 11.1)
        clra                                ; clear HVEN control bit
        sta     flcr                        ;  in Flash Control Register

        rts                                 ; return


;*  Delay Subroutine  =======================================================================
;*
;*  This subroutine performs a simple software delay loop based upon the value passed in ACC.
;*  The following timing calculation applies:
;*
;*   was supposed to be  delay = ((ACC * 74) + 12) (tcyc)
;*   actually            delay = ((ACC * 108) + 12) (tcyc) i.e. longer/safer? delays
;*   now                 delay = ((ACC * 77) + 12) (tcyc)
;*
;*  Calling convention:
;*
;*      lda     data
;*      jsr     delay
;*
;*  Returns:    nothing
;*
;*  Changes:    ACC
;*
ms_Delay:
        psha                                ; [2] save outer delay loop parameter
ms_Delay1:
        lda     #23T                         ; [2] initialize inner delay loop counter
ms_Delay2:
        dbnza   ms_Delay2                      ; [3] decrement inner delay loop counter
        dbnz    1,sp,ms_Delay1                 ; [6] decrement outer delay loop counter
        pula                                ; [2] deallocate local variable
        rts                                 ; [4] return

ms_EraseRamSize:   equ     {*-ms_MassErase}
ms_ProgramRam:     equ     {*-ms_Delay}

;*  Flash Program Subroutine  ===============================================================
;*
;*  This subroutine controls the Flash programming sequence.

ms_FlashProgram:

ms_FlashProgram1:

;   Set PGM, read the Flash Block Protect Register and write anywhere in desired Flash row.
;
        lda     #{PGM}                      ; set PGM control bit
        sta     flcr                        ;  in Flash Control Register
        lda     flbpr                       ; read from Flash Block Protect Register
        ldhx    burnDst
        sta     ,x                   ; write any data to first Flash address
;
;   Wait for >10us, then set HVEN.
        lda     #1                          ; wait
        bsr     ms_delay                       ;  for 11.7us (11.1)
        lda     #{PGM | HVEN}               ; set HVEN control bit
        sta     flcr                        ;  in Flash Control Register
;
;   Wait for >5us.
        lda     #1                          ; wait
        bsr     ms_delay                       ;  for 11.7us (11.1)
;
;   Write data to Flash and wait for 30 - 40us.
        ldhx    burnsrc
        lda     ,x                   ; get data byte
        ldhx    burndst
        sta     ,x                   ; write data to Flash
        lda     #3                          ; wait
        bsr     ms_delay                       ;  for 31.7us (30.3)
;
;   Clear PGM.
        lda     #{HVEN}                     ; clear PGM
        sta     flcr                        ;  in Flash Control Register
;
;   Wait for >5us, then clear HVEN.
        lda     #1                          ; wait
        bsr     ms_delay                       ;  for 11.7us (11.1)
        clra                                ; clear HVEN control bit
        sta     flcr                        ;  in Flash Control Register
;
;   Advance destination pointer and decrement data counter.
;
ms_FlashProgram2:
        ldhx    burnsrc
        aix     #1                          ; advance source pointer
        sthx    BurnSrc
        ldhx    burndst
        aix     #1                          ; advance destination pointer
        sthx    BurnDst
        dbnz    burncount,ms_FlashProgram1  ; decrement counter and loop
                                            ; back if not done.
        rts                                 ; return

ms_ProgramRamSize: equ     {*-ms_Delay}


