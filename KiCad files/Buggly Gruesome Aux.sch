EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Buggly Gruesome Aux"
Date ""
Rev "V1.0"
Comp "R. Hiebert Electric"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector:DB25_Female J1
U 1 1 632E3C72
P 800 4450
F 0 "J1" H 718 5942 50  0000 C CNN
F 1 "DB25_Female" H 718 5851 50  0000 C CNN
F 2 "Connector_Dsub:DSUB-25_Female_Horizontal_P2.77x2.84mm_EdgePinOffset9.90mm_Housed_MountingHolesOffset11.32mm" H 800 4450 50  0001 C CNN
F 3 " ~" H 800 4450 50  0001 C CNN
	1    800  4450
	-1   0    0    1   
$EndComp
$Comp
L Device:Polyfuse F2
U 1 1 632E6C67
P 2300 1750
F 0 "F2" V 2400 1700 50  0000 L CNN
F 1 "RXEF135-1" V 2200 1500 50  0000 L CNN
F 2 "Fuse:Fuse_Bourns_MF-RHT750" H 2350 1550 50  0001 L CNN
F 3 "~" H 2300 1750 50  0001 C CNN
	1    2300 1750
	0    -1   -1   0   
$EndComp
$Comp
L Device:Fuse F9
U 1 1 632E755C
P 9950 2950
F 0 "F9" H 10010 2996 50  0000 L CNN
F 1 "5A" H 10010 2905 50  0000 L CNN
F 2 "Buggly Gruesome Aux:01530008Z_Fuse_Holder" V 9880 2950 50  0001 C CNN
F 3 "~" H 9950 2950 50  0001 C CNN
	1    9950 2950
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D9
U 1 1 632E7BD9
P 10050 3700
F 0 "D9" V 10050 3600 50  0000 C CNN
F 1 "EGO" V 10050 3850 50  0000 C CNN
F 2 "LED_THT:LED_D5.0mm" H 10050 3700 50  0001 C CNN
F 3 "~" H 10050 3700 50  0001 C CNN
	1    10050 3700
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R11
U 1 1 632EA2E1
P 10050 3350
F 0 "R11" H 10100 3350 50  0000 L CNN
F 1 "1K" V 10050 3300 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 9980 3350 50  0001 C CNN
F 3 "~" H 10050 3350 50  0001 C CNN
	1    10050 3350
	1    0    0    -1  
$EndComp
$Comp
L Connector:Screw_Terminal_01x03 J4
U 1 1 632EAC31
P 10150 1150
F 0 "J4" H 10230 1192 50  0000 L CNN
F 1 "277-1270-ND" H 10230 1101 50  0000 L CNN
F 2 "Buggly Gruesome Aux:Phoenix_1714968" H 10150 1150 50  0001 C CNN
F 3 "~" H 10150 1150 50  0001 C CNN
	1    10150 1150
	1    0    0    -1  
$EndComp
$Comp
L Panasonic~CM1-R-12V:Panasonic_CM1-R-12V K1
U 1 1 632F999D
P 3100 1200
F 0 "K1" V 2533 1200 50  0000 C CNN
F 1 "Main" V 2624 1200 50  0000 C CNN
F 2 "Buggly Gruesome Aux:Panasonic_CM1-R-12V" H 4240 1160 50  0001 C CNN
F 3 "http://gfinder.findernet.com/assets/Series/353/S40EN.pdf" H 3100 1200 50  0001 C CNN
	1    3100 1200
	0    1    1    0   
$EndComp
Wire Wire Line
	1100 3950 1500 3950
Wire Wire Line
	1100 4150 1500 4150
Wire Wire Line
	1100 4350 1500 4350
Wire Wire Line
	1100 4950 1300 4950
Wire Wire Line
	1100 5150 1500 5150
Wire Wire Line
	1100 5350 1500 5350
Wire Wire Line
	1100 5550 1500 5550
Text GLabel 1500 4950 2    50   Input ~ 0
Inj1-
Text GLabel 1500 4750 2    50   Input ~ 0
Inj2-
Text GLabel 1100 4050 2    50   Input ~ 0
SpkA
Text GLabel 1500 4150 2    50   Input ~ 0
SpkB
Text GLabel 1500 3950 2    50   Input ~ 0
TachOut
Text GLabel 1500 3350 2    50   Input ~ 0
VRout
Text GLabel 1100 5050 2    50   Input ~ 0
Idle-
Text GLabel 1100 3550 2    50   Input ~ 0
ECU
Text GLabel 1100 5650 2    50   Input ~ 0
MAT
Text GLabel 1500 5550 2    50   Input ~ 0
CLT
Text GLabel 1100 5450 2    50   Input ~ 0
O2
Text GLabel 1500 5350 2    50   Input ~ 0
TPS
Text GLabel 2650 3450 2    50   Input ~ 0
5Vlt
Text GLabel 1100 5250 2    50   Input ~ 0
SigRtn
Text GLabel 1500 5150 2    50   Input ~ 0
SigRtn
Text GLabel 2750 7100 1    50   Input ~ 0
MAT
Wire Wire Line
	2850 7100 2850 6750
Wire Wire Line
	3050 7100 3050 6750
Wire Wire Line
	3250 7100 3250 6750
Wire Wire Line
	3450 7100 3450 6750
Wire Wire Line
	3650 7100 3650 6750
Wire Wire Line
	3850 7100 3850 6750
Wire Wire Line
	4050 7100 4050 6750
Text GLabel 2850 6750 1    50   Input ~ 0
CLT
Text GLabel 2950 7100 1    50   Input ~ 0
O2
Text GLabel 3050 6750 1    50   Input ~ 0
TPS
Text GLabel 3750 7100 1    50   Input ~ 0
5Vlt
Text GLabel 3150 7100 1    50   Input ~ 0
SigRtn
Text GLabel 3250 6750 1    50   Input ~ 0
SigRtn
Text GLabel 3350 7100 1    50   Input ~ 0
Idle-
Text GLabel 4150 7100 1    50   Input ~ 0
Tach
Text GLabel 3850 6750 1    50   Input ~ 0
VRshld
Text GLabel 3950 7100 1    50   Input ~ 0
VR-
Text GLabel 4050 6750 1    50   Input ~ 0
VR+
Text GLabel 9700 1050 0    50   Input ~ 0
12VoltUnswitched
Text GLabel 8800 1150 0    50   Input ~ 0
12VoltSwitched
Wire Wire Line
	9950 1050 9800 1050
Wire Wire Line
	9950 1250 9800 1250
$Comp
L power:PWR_FLAG #FLG03
U 1 1 633179DE
P 9800 950
F 0 "#FLG03" H 9800 1025 50  0001 C CNN
F 1 "PWR_FLAG" H 9800 1123 50  0000 C CNN
F 2 "" H 9800 950 50  0001 C CNN
F 3 "~" H 9800 950 50  0001 C CNN
	1    9800 950 
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG04
U 1 1 6331836D
P 9800 1350
F 0 "#FLG04" H 9800 1425 50  0001 C CNN
F 1 "PWR_FLAG" H 9800 1523 50  0000 C CNN
F 2 "" H 9800 1350 50  0001 C CNN
F 3 "~" H 9800 1350 50  0001 C CNN
	1    9800 1350
	-1   0    0    1   
$EndComp
$Comp
L power:PWR_FLAG #FLG02
U 1 1 6331871E
P 8900 1000
F 0 "#FLG02" H 8900 1075 50  0001 C CNN
F 1 "PWR_FLAG" H 8900 1173 50  0000 C CNN
F 2 "" H 8900 1000 50  0001 C CNN
F 3 "~" H 8900 1000 50  0001 C CNN
	1    8900 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	9800 1350 9800 1250
Connection ~ 9800 1250
Wire Wire Line
	9800 950  9800 1050
$Comp
L power:PWR_FLAG #FLG01
U 1 1 6331B02E
P 2350 3500
F 0 "#FLG01" H 2350 3575 50  0001 C CNN
F 1 "PWR_FLAG" H 2350 3673 50  0000 C CNN
F 2 "" H 2350 3500 50  0001 C CNN
F 3 "~" H 2350 3500 50  0001 C CNN
	1    2350 3500
	-1   0    0    1   
$EndComp
$Comp
L Device:R R3
U 1 1 63321512
P 4000 3350
F 0 "R3" H 4070 3396 50  0000 L CNN
F 1 "1K" V 4000 3300 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 3930 3350 50  0001 C CNN
F 3 "~" H 4000 3350 50  0001 C CNN
	1    4000 3350
	1    0    0    -1  
$EndComp
$Comp
L Device:R R2
U 1 1 63321963
P 3400 3800
F 0 "R2" V 3300 3800 50  0000 C CNN
F 1 "1K" V 3400 3800 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 3330 3800 50  0001 C CNN
F 3 "~" H 3400 3800 50  0001 C CNN
	1    3400 3800
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR018
U 1 1 63322C2B
P 9450 1350
F 0 "#PWR018" H 9450 1100 50  0001 C CNN
F 1 "GND" H 9455 1177 50  0000 C CNN
F 2 "" H 9450 1350 50  0001 C CNN
F 3 "" H 9450 1350 50  0001 C CNN
	1    9450 1350
	1    0    0    -1  
$EndComp
Wire Wire Line
	9450 1250 9450 1350
Wire Wire Line
	9450 1250 9800 1250
$Comp
L power:GND #PWR011
U 1 1 63324041
P 4000 4350
F 0 "#PWR011" H 4000 4100 50  0001 C CNN
F 1 "GND" H 4005 4177 50  0000 C CNN
F 2 "" H 4000 4350 50  0001 C CNN
F 3 "" H 4000 4350 50  0001 C CNN
	1    4000 4350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR06
U 1 1 63326003
P 1500 4350
F 0 "#PWR06" H 1500 4100 50  0001 C CNN
F 1 "GND" V 1505 4222 50  0000 R CNN
F 2 "" H 1500 4350 50  0001 C CNN
F 3 "" H 1500 4350 50  0001 C CNN
	1    1500 4350
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR03
U 1 1 63326B7A
P 1100 4250
F 0 "#PWR03" H 1100 4000 50  0001 C CNN
F 1 "GND" V 1105 4122 50  0000 R CNN
F 2 "" H 1100 4250 50  0001 C CNN
F 3 "" H 1100 4250 50  0001 C CNN
	1    1100 4250
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR04
U 1 1 63326FE6
P 1100 4450
F 0 "#PWR04" H 1100 4200 50  0001 C CNN
F 1 "GND" V 1105 4322 50  0000 R CNN
F 2 "" H 1100 4450 50  0001 C CNN
F 3 "" H 1100 4450 50  0001 C CNN
	1    1100 4450
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR07
U 1 1 633278FF
P 1500 4550
F 0 "#PWR07" H 1500 4300 50  0001 C CNN
F 1 "GND" V 1500 4400 50  0000 R CNN
F 2 "" H 1500 4550 50  0001 C CNN
F 3 "" H 1500 4550 50  0001 C CNN
	1    1500 4550
	0    -1   -1   0   
$EndComp
Text GLabel 3100 3800 0    50   Input ~ 0
TachOut
Wire Wire Line
	3700 3800 3650 3800
Wire Wire Line
	3250 3800 3100 3800
Text GLabel 3800 3550 0    50   Input ~ 0
Tach
Text GLabel 3550 5300 2    50   Input ~ 0
5Vlt
$Comp
L power:GND #PWR010
U 1 1 633331AD
P 2250 5100
F 0 "#PWR010" H 2250 4850 50  0001 C CNN
F 1 "GND" V 2250 4950 50  0000 R CNN
F 2 "" H 2250 5100 50  0001 C CNN
F 3 "" H 2250 5100 50  0001 C CNN
	1    2250 5100
	0    1    1    0   
$EndComp
Text GLabel 2550 5200 0    50   Input ~ 0
VR+
Text GLabel 2550 5000 0    50   Input ~ 0
VR-
Text GLabel 3550 5100 2    50   Input ~ 0
VRout
Wire Wire Line
	9800 1050 9700 1050
Connection ~ 9800 1050
Wire Wire Line
	8800 1150 8900 1150
Wire Wire Line
	8900 1000 8900 1150
Connection ~ 8900 1150
Wire Wire Line
	8900 1150 9950 1150
Text GLabel 9100 1400 3    50   Input ~ 0
VRshld
Wire Wire Line
	4250 7100 4250 6750
Text GLabel 4250 6750 1    50   Input ~ 0
FlPmp
Text GLabel 1100 3250 2    50   Input ~ 0
ASD
Text GLabel 3750 2200 2    50   Input ~ 0
ASD
$Comp
L power:GND #PWR09
U 1 1 632FFC1A
P 3750 1000
F 0 "#PWR09" H 3750 750 50  0001 C CNN
F 1 "GND" H 3755 827 50  0000 C CNN
F 2 "" H 3750 1000 50  0001 C CNN
F 3 "" H 3750 1000 50  0001 C CNN
	1    3750 1000
	1    0    0    -1  
$EndComp
Text GLabel 2650 1000 0    50   Input ~ 0
12VoltSwitched
Text GLabel 2200 1400 0    50   Input ~ 0
12VoltUnswitched
Wire Wire Line
	2600 1750 2600 1850
Wire Wire Line
	2600 2200 2600 2600
Connection ~ 2600 2200
Wire Wire Line
	2600 1750 2450 1750
Connection ~ 2600 1750
Wire Wire Line
	2150 1750 2050 1750
Text GLabel 2000 1750 0    50   Input ~ 0
ECU
Text GLabel 9850 3200 3    50   Input ~ 0
EGO+
$Comp
L Device:Fuse F6
U 1 1 633433CC
P 7000 2950
F 0 "F6" H 7060 2996 50  0000 L CNN
F 1 "10A" H 7060 2905 50  0000 L CNN
F 2 "Buggly Gruesome Aux:01530008Z_Fuse_Holder" V 6930 2950 50  0001 C CNN
F 3 "~" H 7000 2950 50  0001 C CNN
	1    7000 2950
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D6
U 1 1 633433D2
P 7600 3800
F 0 "D6" V 7600 3900 50  0000 C CNN
F 1 "CoilB" V 7600 3600 50  0000 C CNN
F 2 "LED_THT:LED_D5.0mm" H 7600 3800 50  0001 C CNN
F 3 "~" H 7600 3800 50  0001 C CNN
	1    7600 3800
	0    1    -1   0   
$EndComp
$Comp
L Device:R R8
U 1 1 633433D8
P 7600 3450
F 0 "R8" H 7650 3450 50  0000 L CNN
F 1 "1K" V 7600 3400 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 7530 3450 50  0001 C CNN
F 3 "~" H 7600 3450 50  0001 C CNN
	1    7600 3450
	1    0    0    -1  
$EndComp
Text GLabel 5550 4100 3    50   Input ~ 0
Inj2-
$Comp
L Device:Fuse F5
U 1 1 633433E7
P 5300 2950
F 0 "F5" H 5360 2996 50  0000 L CNN
F 1 "10A" H 5360 2905 50  0000 L CNN
F 2 "Buggly Gruesome Aux:01530008Z_Fuse_Holder" V 5230 2950 50  0001 C CNN
F 3 "~" H 5300 2950 50  0001 C CNN
	1    5300 2950
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D4
U 1 1 633433ED
P 5550 3850
F 0 "D4" V 5550 3750 50  0000 C CNN
F 1 "INJ2" V 5550 4000 50  0000 C CNN
F 2 "LED_THT:LED_D5.0mm" H 5550 3850 50  0001 C CNN
F 3 "~" H 5550 3850 50  0001 C CNN
	1    5550 3850
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R6
U 1 1 633433F3
P 5550 3450
F 0 "R6" H 5600 3450 50  0000 L CNN
F 1 "1K" V 5550 3400 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 5480 3450 50  0001 C CNN
F 3 "~" H 5550 3450 50  0001 C CNN
	1    5550 3450
	1    0    0    -1  
$EndComp
Text GLabel 5300 3300 3    50   Input ~ 0
Injs+
Text GLabel 7450 4200 0    50   Input ~ 0
SpkB
Text GLabel 7900 3850 1    50   Input ~ 0
CoilB
Wire Wire Line
	7900 3850 7900 3950
Wire Wire Line
	7600 3950 7900 3950
Connection ~ 7900 3950
Wire Wire Line
	7900 3950 7900 4000
Wire Wire Line
	7600 4200 7450 4200
Wire Wire Line
	7900 4400 7900 4500
Wire Wire Line
	7600 3600 7600 3650
$Comp
L Device:LED D5
U 1 1 6331F899
P 6300 3800
F 0 "D5" V 6300 3900 50  0000 C CNN
F 1 "CoilA" V 6300 3600 50  0000 C CNN
F 2 "LED_THT:LED_D5.0mm" H 6300 3800 50  0001 C CNN
F 3 "~" H 6300 3800 50  0001 C CNN
	1    6300 3800
	0    1    -1   0   
$EndComp
$Comp
L Device:R R7
U 1 1 6331F89F
P 6300 3450
F 0 "R7" H 6350 3450 50  0000 L CNN
F 1 "1K" V 6300 3400 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 6230 3450 50  0001 C CNN
F 3 "~" H 6300 3450 50  0001 C CNN
	1    6300 3450
	1    0    0    -1  
$EndComp
Text GLabel 6150 4200 0    50   Input ~ 0
SpkA
Text GLabel 6600 3850 1    50   Input ~ 0
CoilA
Wire Wire Line
	6600 3850 6600 3950
Wire Wire Line
	6300 3950 6600 3950
Connection ~ 6600 3950
Wire Wire Line
	6600 3950 6600 4000
Wire Wire Line
	6300 4200 6150 4200
Wire Wire Line
	6600 4400 6600 4500
Wire Wire Line
	6300 3600 6300 3650
Text GLabel 7000 3300 3    50   Input ~ 0
Coils+
Wire Wire Line
	6300 3300 6300 3200
Wire Wire Line
	6300 3200 7000 3200
Wire Wire Line
	7600 3200 7600 3300
Wire Wire Line
	7000 3100 7000 3200
Connection ~ 7000 3200
Wire Wire Line
	7000 3200 7600 3200
Wire Wire Line
	7000 3200 7000 3300
Wire Wire Line
	5550 3600 5550 3700
Wire Wire Line
	5550 4000 5550 4100
Text GLabel 5050 4100 3    50   Input ~ 0
Inj1-
$Comp
L Device:LED D3
U 1 1 6334CB59
P 5050 3850
F 0 "D3" V 5050 3750 50  0000 C CNN
F 1 "INJ1" V 5050 4000 50  0000 C CNN
F 2 "LED_THT:LED_D5.0mm" H 5050 3850 50  0001 C CNN
F 3 "~" H 5050 3850 50  0001 C CNN
	1    5050 3850
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R5
U 1 1 6334CB5F
P 5050 3450
F 0 "R5" H 5100 3450 50  0000 L CNN
F 1 "1K" V 5050 3400 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 4980 3450 50  0001 C CNN
F 3 "~" H 5050 3450 50  0001 C CNN
	1    5050 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	5050 3600 5050 3700
Wire Wire Line
	5050 4000 5050 4100
Wire Wire Line
	5050 3300 5050 3200
Wire Wire Line
	5050 3200 5300 3200
Wire Wire Line
	5550 3200 5550 3300
Wire Wire Line
	5300 3100 5300 3200
Connection ~ 5300 3200
Wire Wire Line
	5300 3200 5550 3200
Wire Wire Line
	5300 3300 5300 3200
Text GLabel 3650 6750 1    50   Input ~ 0
Injs+
Text GLabel 4650 6750 1    50   Input ~ 0
Coils+
Text GLabel 4350 7100 1    50   Input ~ 0
Idle+
Text GLabel 4750 7100 1    50   Input ~ 0
CoilA
Text GLabel 4850 6750 1    50   Input ~ 0
CoilB
Text GLabel 3450 6750 1    50   Input ~ 0
Inj1-
Text GLabel 3550 7100 1    50   Input ~ 0
Inj2-
Wire Wire Line
	1100 3750 1500 3750
Wire Wire Line
	1100 3350 1500 3350
$Comp
L power:GND #PWR05
U 1 1 6337B29C
P 1100 3850
F 0 "#PWR05" H 1100 3600 50  0001 C CNN
F 1 "GND" V 1105 3722 50  0000 R CNN
F 2 "" H 1100 3850 50  0001 C CNN
F 3 "" H 1100 3850 50  0001 C CNN
	1    1100 3850
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR01
U 1 1 6337B99B
P 1500 3750
F 0 "#PWR01" H 1500 3500 50  0001 C CNN
F 1 "GND" V 1505 3622 50  0000 R CNN
F 2 "" H 1500 3750 50  0001 C CNN
F 3 "" H 1500 3750 50  0001 C CNN
	1    1500 3750
	0    -1   -1   0   
$EndComp
Text GLabel 4550 7100 1    50   Input ~ 0
EGO+
Wire Wire Line
	4450 7100 4450 6750
Wire Wire Line
	4650 7100 4650 6750
Wire Wire Line
	4850 7100 4850 6750
Wire Wire Line
	9850 3200 9850 3150
Wire Wire Line
	9850 3150 9950 3150
Wire Wire Line
	10050 3150 10050 3200
Wire Wire Line
	9950 3100 9950 3150
Connection ~ 9950 3150
Wire Wire Line
	9950 3150 10050 3150
Wire Wire Line
	10050 3500 10050 3550
Wire Wire Line
	10050 3850 10050 3950
$Comp
L Device:LED D1
U 1 1 633AB8B2
P 2050 2400
F 0 "D1" V 2050 2300 50  0000 C CNN
F 1 "ECU" V 2050 2550 50  0000 C CNN
F 2 "LED_THT:LED_D5.0mm" H 2050 2400 50  0001 C CNN
F 3 "~" H 2050 2400 50  0001 C CNN
	1    2050 2400
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R1
U 1 1 633AB8B8
P 2050 2050
F 0 "R1" H 2100 2050 50  0000 L CNN
F 1 "1K" V 2050 2000 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 1980 2050 50  0001 C CNN
F 3 "~" H 2050 2050 50  0001 C CNN
	1    2050 2050
	1    0    0    -1  
$EndComp
Wire Wire Line
	2050 2200 2050 2250
Wire Wire Line
	2050 2550 2050 2650
Wire Wire Line
	2050 1750 2050 1900
Connection ~ 2050 1750
Wire Wire Line
	2050 1750 2000 1750
$Comp
L Device:Fuse F8
U 1 1 633B73FA
P 9300 2950
F 0 "F8" H 9360 2996 50  0000 L CNN
F 1 "5A" H 9360 2905 50  0000 L CNN
F 2 "Buggly Gruesome Aux:01530008Z_Fuse_Holder" V 9230 2950 50  0001 C CNN
F 3 "~" H 9300 2950 50  0001 C CNN
	1    9300 2950
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D8
U 1 1 633B7400
P 9400 3700
F 0 "D8" V 9400 3600 50  0000 C CNN
F 1 "IAC" V 9400 3850 50  0000 C CNN
F 2 "LED_THT:LED_D5.0mm" H 9400 3700 50  0001 C CNN
F 3 "~" H 9400 3700 50  0001 C CNN
	1    9400 3700
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R10
U 1 1 633B7406
P 9400 3350
F 0 "R10" H 9450 3350 50  0000 L CNN
F 1 "1K" V 9400 3300 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 9330 3350 50  0001 C CNN
F 3 "~" H 9400 3350 50  0001 C CNN
	1    9400 3350
	1    0    0    -1  
$EndComp
Text GLabel 9200 3200 3    50   Input ~ 0
Idle+
Wire Wire Line
	9200 3200 9200 3150
Wire Wire Line
	9200 3150 9300 3150
Wire Wire Line
	9400 3150 9400 3200
Wire Wire Line
	9300 3100 9300 3150
Connection ~ 9300 3150
Wire Wire Line
	9300 3150 9400 3150
Wire Wire Line
	9400 3500 9400 3550
Wire Wire Line
	9400 3850 9400 3950
$Comp
L Device:Fuse F7
U 1 1 633C1980
P 8700 2950
F 0 "F7" H 8760 2996 50  0000 L CNN
F 1 "10A" H 8760 2905 50  0000 L CNN
F 2 "Buggly Gruesome Aux:01530008Z_Fuse_Holder" V 8630 2950 50  0001 C CNN
F 3 "~" H 8700 2950 50  0001 C CNN
	1    8700 2950
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D7
U 1 1 633C1986
P 8800 3700
F 0 "D7" V 8800 3600 50  0000 C CNN
F 1 "FP" V 8800 3850 50  0000 C CNN
F 2 "LED_THT:LED_D5.0mm" H 8800 3700 50  0001 C CNN
F 3 "~" H 8800 3700 50  0001 C CNN
	1    8800 3700
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R9
U 1 1 633C198C
P 8800 3350
F 0 "R9" H 8850 3350 50  0000 L CNN
F 1 "1K" V 8800 3300 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 8730 3350 50  0001 C CNN
F 3 "~" H 8800 3350 50  0001 C CNN
	1    8800 3350
	1    0    0    -1  
$EndComp
Text GLabel 8600 3200 3    50   Input ~ 0
FlPmp
Wire Wire Line
	8600 3200 8600 3150
Wire Wire Line
	8600 3150 8700 3150
Wire Wire Line
	8800 3150 8800 3200
Wire Wire Line
	8700 3100 8700 3150
Connection ~ 8700 3150
Wire Wire Line
	8700 3150 8800 3150
Wire Wire Line
	8800 3500 8800 3550
Wire Wire Line
	8800 3850 8800 3950
$Comp
L Device:Polyfuse F1
U 1 1 633CD375
P 2000 3450
F 0 "F1" V 2100 3400 50  0000 L CNN
F 1 "RXEF110" V 1900 3300 50  0000 L CNN
F 2 "Fuse:Fuse_Bourns_MF-RHT650" H 2050 3250 50  0001 L CNN
F 3 "~" H 2000 3450 50  0001 C CNN
	1    2000 3450
	0    -1   -1   0   
$EndComp
$Comp
L Device:Fuse F3
U 1 1 633D274E
P 2500 1400
F 0 "F3" V 2400 1350 50  0000 L CNN
F 1 "20A" V 2600 1300 50  0000 L CNN
F 2 "Buggly Gruesome Aux:01530008Z_Fuse_Holder" V 2430 1400 50  0001 C CNN
F 3 "~" H 2500 1400 50  0001 C CNN
	1    2500 1400
	0    1    1    0   
$EndComp
Wire Wire Line
	2350 1400 2200 1400
$Comp
L power:GND #PWR02
U 1 1 634197DC
P 1100 3650
F 0 "#PWR02" H 1100 3400 50  0001 C CNN
F 1 "GND" V 1105 3522 50  0000 R CNN
F 2 "" H 1100 3650 50  0001 C CNN
F 3 "" H 1100 3650 50  0001 C CNN
	1    1100 3650
	0    -1   -1   0   
$EndComp
$Comp
L Device:Polyfuse F4
U 1 1 63419C1D
P 4000 2950
F 0 "F4" H 4100 3000 50  0000 L CNN
F 1 "RXEF110" H 4100 2900 50  0000 L CNN
F 2 "Fuse:Fuse_Bourns_MF-RHT650" H 4050 2750 50  0001 L CNN
F 3 "~" H 4000 2950 50  0001 C CNN
	1    4000 2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 3100 4000 3150
Wire Wire Line
	9950 2700 9950 2800
Wire Wire Line
	3400 2700 4000 2700
Wire Wire Line
	9300 2800 9300 2700
Connection ~ 9300 2700
Wire Wire Line
	9300 2700 9950 2700
Wire Wire Line
	8700 2800 8700 2700
Connection ~ 8700 2700
Wire Wire Line
	8700 2700 9300 2700
Wire Wire Line
	7000 2800 7000 2700
Connection ~ 7000 2700
Wire Wire Line
	7000 2700 8700 2700
Wire Wire Line
	5300 2800 5300 2700
Connection ~ 5300 2700
Wire Wire Line
	5300 2700 7000 2700
Wire Wire Line
	4000 2800 4000 2700
Connection ~ 4000 2700
Wire Wire Line
	4000 2700 5300 2700
$Comp
L Device:LED D2
U 1 1 6346F903
P 4600 3500
F 0 "D2" V 4600 3400 50  0000 C CNN
F 1 "Tach" V 4600 3650 50  0000 C CNN
F 2 "LED_THT:LED_D5.0mm" H 4600 3500 50  0001 C CNN
F 3 "~" H 4600 3500 50  0001 C CNN
	1    4600 3500
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R4
U 1 1 6346F909
P 4600 3150
F 0 "R4" H 4650 3150 50  0000 L CNN
F 1 "1K" V 4600 3100 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 4530 3150 50  0001 C CNN
F 3 "~" H 4600 3150 50  0001 C CNN
	1    4600 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4600 3300 4600 3350
Wire Wire Line
	4000 3500 4000 3550
Wire Wire Line
	3800 3550 4000 3550
Connection ~ 4000 3550
Wire Wire Line
	4000 3550 4000 3600
Wire Wire Line
	4000 4000 4000 4300
$Comp
L power:GND #PWR014
U 1 1 63490593
P 6600 4500
F 0 "#PWR014" H 6600 4250 50  0001 C CNN
F 1 "GND" H 6605 4327 50  0000 C CNN
F 2 "" H 6600 4500 50  0001 C CNN
F 3 "" H 6600 4500 50  0001 C CNN
	1    6600 4500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR015
U 1 1 63490A73
P 7900 4500
F 0 "#PWR015" H 7900 4250 50  0001 C CNN
F 1 "GND" H 7905 4327 50  0000 C CNN
F 2 "" H 7900 4500 50  0001 C CNN
F 3 "" H 7900 4500 50  0001 C CNN
	1    7900 4500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR016
U 1 1 63490EC6
P 8800 3950
F 0 "#PWR016" H 8800 3700 50  0001 C CNN
F 1 "GND" H 8805 3777 50  0000 C CNN
F 2 "" H 8800 3950 50  0001 C CNN
F 3 "" H 8800 3950 50  0001 C CNN
	1    8800 3950
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR017
U 1 1 63491801
P 9400 3950
F 0 "#PWR017" H 9400 3700 50  0001 C CNN
F 1 "GND" H 9405 3777 50  0000 C CNN
F 2 "" H 9400 3950 50  0001 C CNN
F 3 "" H 9400 3950 50  0001 C CNN
	1    9400 3950
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR019
U 1 1 63491EA3
P 10050 3950
F 0 "#PWR019" H 10050 3700 50  0001 C CNN
F 1 "GND" H 10055 3777 50  0000 C CNN
F 2 "" H 10050 3950 50  0001 C CNN
F 3 "" H 10050 3950 50  0001 C CNN
	1    10050 3950
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR08
U 1 1 63492241
P 2050 2650
F 0 "#PWR08" H 2050 2400 50  0001 C CNN
F 1 "GND" H 2055 2477 50  0000 C CNN
F 2 "" H 2050 2650 50  0001 C CNN
F 3 "" H 2050 2650 50  0001 C CNN
	1    2050 2650
	1    0    0    -1  
$EndComp
Text Notes 6750 4400 0    50   ~ 0
IGBT
Text Notes 8050 4400 0    50   ~ 0
IGBT
Text Notes 8600 3800 0    50   ~ 0
Gn
Text Notes 9200 3800 0    50   ~ 0
Yl\n
Text Notes 9850 3800 0    50   ~ 0
Or
Text Notes 7300 3900 0    50   ~ 0
Bu
Text Notes 6000 3900 0    50   ~ 0
Bu
Text Notes 5350 3950 0    50   ~ 0
Rd
Text Notes 4850 3950 0    50   ~ 0
Rd
Text Notes 1800 2500 0    50   ~ 0
YlGn
Text Notes 4350 3600 0    50   ~ 0
DpRd
$Comp
L Connector:Screw_Terminal_01x11 J3
U 1 1 633129E0
P 4350 7300
F 0 "J3" V 4475 7296 50  0000 C CNN
F 1 "277-1245-ND" V 4566 7296 50  0000 C CNN
F 2 "Buggly Gruesome Aux:Phoenix_1729102" H 4350 7300 50  0001 C CNN
F 3 "~" H 4350 7300 50  0001 C CNN
	1    4350 7300
	0    -1   1    0   
$EndComp
$Comp
L Connector:Screw_Terminal_01x11 J2
U 1 1 6331E9C8
P 3250 7300
F 0 "J2" V 3375 7296 50  0000 C CNN
F 1 "277-1245-ND" V 3466 7296 50  0000 C CNN
F 2 "Buggly Gruesome Aux:Phoenix_1729102" H 3250 7300 50  0001 C CNN
F 3 "~" H 3250 7300 50  0001 C CNN
	1    3250 7300
	0    -1   1    0   
$EndComp
NoConn ~ 3400 1300
NoConn ~ 3400 2500
$Comp
L Device:Q_NPN_CBE Q1
U 1 1 633359BE
P 3900 3800
F 0 "Q1" H 4090 3846 50  0000 L CNN
F 1 "BC33725BU" H 4050 3700 50  0000 L CNN
F 2 "digikey-footprints:TO-92-3_Formed_Leads" H 4100 3900 50  0001 C CNN
F 3 "~" H 3900 3800 50  0001 C CNN
	1    3900 3800
	1    0    0    -1  
$EndComp
Text Notes 3600 7450 0    50   ~ 0
10 Amp Rated\n
Text Notes 10250 1350 0    50   ~ 0
30 Amp Rated
$Comp
L Mechanical:Heatsink_Pad_2Pin HS2
U 1 1 63338A35
P 7900 5050
F 0 "HS2" H 8088 5089 50  0000 L CNN
F 1 "Heatsink_Pad_2Pin" H 8088 4998 50  0000 L CNN
F 2 "Buggly Gruesome Aux:ISL9V3040P3_Heat_Sink" H 7912 5000 50  0001 C CNN
F 3 "~" H 7912 5000 50  0001 C CNN
	1    7900 5050
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:Heatsink_Pad_2Pin HS1
U 1 1 633390F2
P 6600 5050
F 0 "HS1" H 6788 5089 50  0000 L CNN
F 1 "Heatsink_Pad_2Pin" H 6788 4998 50  0000 L CNN
F 2 "Buggly Gruesome Aux:ISL9V3040P3_Heat_Sink" H 6612 5000 50  0001 C CNN
F 3 "~" H 6612 5000 50  0001 C CNN
	1    6600 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	6500 5150 6500 5250
Wire Wire Line
	6500 5250 6700 5250
Wire Wire Line
	8000 5250 8000 5150
Wire Wire Line
	7800 5150 7800 5250
Connection ~ 7800 5250
Wire Wire Line
	7800 5250 8000 5250
Wire Wire Line
	6700 5150 6700 5250
Connection ~ 6700 5250
Wire Wire Line
	6700 5250 7300 5250
$Comp
L power:GND #PWR0101
U 1 1 633512E9
P 7300 5350
F 0 "#PWR0101" H 7300 5100 50  0001 C CNN
F 1 "GND" H 7305 5177 50  0000 C CNN
F 2 "" H 7300 5350 50  0001 C CNN
F 3 "" H 7300 5350 50  0001 C CNN
	1    7300 5350
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 5350 7300 5250
Connection ~ 7300 5250
Wire Wire Line
	7300 5250 7800 5250
Text GLabel 4450 6750 1    50   Input ~ 0
EGO-
Wire Wire Line
	1100 4750 1300 4750
Wire Wire Line
	1100 4550 1500 4550
Wire Wire Line
	1100 4850 1300 4850
Wire Wire Line
	1300 4850 1300 4950
Connection ~ 1300 4950
Wire Wire Line
	1300 4950 1500 4950
Wire Wire Line
	1100 4650 1300 4650
Wire Wire Line
	1300 4650 1300 4750
Connection ~ 1300 4750
Wire Wire Line
	1300 4750 1500 4750
Text GLabel 8750 1400 3    50   Input ~ 0
EGO-
Wire Wire Line
	3400 5100 3550 5100
Wire Wire Line
	2700 5200 2550 5200
Wire Wire Line
	2700 5000 2550 5000
Wire Wire Line
	2700 5100 2250 5100
NoConn ~ 3400 5000
NoConn ~ 3400 5200
NoConn ~ 2700 5300
$Comp
L Buggly~Gruesome~Aux:Single_VR_Signal_Conditioner U1
U 1 1 633D3EB4
P 3050 5100
F 0 "U1" H 3050 5465 50  0000 C CNN
F 1 "Single_VR_Signal_Conditioner" H 3050 5374 50  0000 C CNN
F 2 "BPEM488CWaux:Single_VR_Conditioner" H 3050 5100 50  0001 C CNN
F 3 "" H 3050 5100 50  0001 C CNN
	1    3050 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	3400 5300 3550 5300
Wire Wire Line
	1100 3450 1850 3450
Wire Wire Line
	2150 3450 2350 3450
Wire Wire Line
	2350 3500 2350 3450
Connection ~ 2350 3450
Wire Wire Line
	2350 3450 2650 3450
Wire Wire Line
	9450 1250 9100 1250
Wire Wire Line
	8750 1250 8750 1400
Connection ~ 9450 1250
Wire Wire Line
	9100 1400 9100 1250
Connection ~ 9100 1250
Wire Wire Line
	9100 1250 8750 1250
$Comp
L Device:R R12
U 1 1 633EAC3D
P 3650 4050
F 0 "R12" V 3550 4050 50  0000 C CNN
F 1 "10K" V 3650 4050 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 3580 4050 50  0001 C CNN
F 3 "~" H 3650 4050 50  0001 C CNN
	1    3650 4050
	-1   0    0    1   
$EndComp
Wire Wire Line
	3650 3900 3650 3800
Connection ~ 3650 3800
Wire Wire Line
	3650 3800 3550 3800
Wire Wire Line
	3650 4200 3650 4300
Wire Wire Line
	3650 4300 4000 4300
Connection ~ 4000 4300
Wire Wire Line
	4000 4300 4000 4350
Wire Wire Line
	4600 3000 4450 3000
Wire Wire Line
	4450 3000 4450 3150
Wire Wire Line
	4450 3150 4000 3150
Connection ~ 4000 3150
Wire Wire Line
	4000 3150 4000 3200
Wire Wire Line
	4600 3650 4250 3650
Wire Wire Line
	4250 3650 4250 3550
Wire Wire Line
	4250 3550 4000 3550
Wire Wire Line
	3400 1500 3450 1500
Wire Wire Line
	3450 1500 3450 1650
Wire Wire Line
	2600 1650 2600 1750
Wire Wire Line
	2600 2200 2800 2200
Wire Wire Line
	2600 2600 2800 2600
$Comp
L Device:Q_NIGBT_GCE Q2
U 1 1 633FCEB8
P 6500 4200
F 0 "Q2" H 6690 4246 50  0000 L CNN
F 1 "ISL9V3040P3" H 6690 4155 50  0000 L CNN
F 2 "Buggly Gruesome Aux:TO-220-3_Vertical_Wide" H 6700 4300 50  0001 C CNN
F 3 "~" H 6500 4200 50  0001 C CNN
	1    6500 4200
	1    0    0    -1  
$EndComp
$Comp
L Device:Q_NIGBT_GCE Q3
U 1 1 633FDA0E
P 7800 4200
F 0 "Q3" H 7990 4246 50  0000 L CNN
F 1 "ISL9V3040P3" H 7990 4155 50  0000 L CNN
F 2 "Buggly Gruesome Aux:TO-220-3_Vertical_Wide" H 8000 4300 50  0001 C CNN
F 3 "~" H 7800 4200 50  0001 C CNN
	1    7800 4200
	1    0    0    -1  
$EndComp
$Comp
L Diode:1N4001 D?
U 1 1 635BB0EA
P 3400 700
F 0 "D?" H 3550 800 50  0000 L CNN
F 1 "1N4001" H 3200 800 50  0000 L CNN
F 2 "Diode_THT:D_DO-41_SOD81_P10.16mm_Horizontal" H 3400 525 50  0001 C CNN
F 3 "http://www.vishay.com/docs/88503/1n4001.pdf" H 3400 700 50  0001 C CNN
	1    3400 700 
	1    0    0    -1  
$EndComp
$Comp
L Diode:1N4001 D?
U 1 1 635BCC21
P 3850 6150
F 0 "D?" H 3850 5933 50  0000 C CNN
F 1 "1N4001" H 3850 6024 50  0000 C CNN
F 2 "Diode_THT:D_DO-41_SOD81_P10.16mm_Horizontal" H 3850 5975 50  0001 C CNN
F 3 "http://www.vishay.com/docs/88503/1n4001.pdf" H 3850 6150 50  0001 C CNN
	1    3850 6150
	-1   0    0    1   
$EndComp
Text GLabel 3550 6150 0    50   Input ~ 0
Idle-
Text GLabel 4150 6150 2    50   Input ~ 0
Idle+
Wire Wire Line
	3550 6150 3700 6150
Wire Wire Line
	4000 6150 4150 6150
$Comp
L Panasonic~CM1-R-12V:Panasonic_CM1-R-12V K2
U 1 1 632FAF11
P 3100 2400
F 0 "K2" V 2533 2400 50  0000 C CNN
F 1 "Automatic Shut Down" V 2624 2400 50  0000 C CNN
F 2 "Buggly Gruesome Aux:Panasonic_CM1-R-12V" H 4240 2360 50  0001 C CNN
F 3 "http://gfinder.findernet.com/assets/Series/353/S40EN.pdf" H 3100 2400 50  0001 C CNN
	1    3100 2400
	0    1    1    0   
$EndComp
Wire Wire Line
	2650 1400 2800 1400
Wire Wire Line
	2650 1000 2750 1000
$Comp
L Diode:1N4001 D?
U 1 1 63607FCC
P 3350 1850
F 0 "D?" H 3500 1950 50  0000 L CNN
F 1 "1N4001" H 3150 1950 50  0000 L CNN
F 2 "Diode_THT:D_DO-41_SOD81_P10.16mm_Horizontal" H 3350 1675 50  0001 C CNN
F 3 "http://www.vishay.com/docs/88503/1n4001.pdf" H 3350 1850 50  0001 C CNN
	1    3350 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	2600 1650 3450 1650
Wire Wire Line
	3400 1000 3600 1000
Wire Wire Line
	3400 2200 3600 2200
Wire Wire Line
	3500 1850 3600 1850
Wire Wire Line
	3600 1850 3600 2200
Connection ~ 3600 2200
Wire Wire Line
	3600 2200 3750 2200
Wire Wire Line
	3550 700  3600 700 
Wire Wire Line
	3600 700  3600 1000
Connection ~ 3600 1000
Wire Wire Line
	3600 1000 3750 1000
Wire Wire Line
	3250 700  2750 700 
Wire Wire Line
	2750 700  2750 1000
Connection ~ 2750 1000
Wire Wire Line
	2750 1000 2800 1000
Wire Wire Line
	3200 1850 2600 1850
Connection ~ 2600 1850
Wire Wire Line
	2600 1850 2600 2200
Text Notes 6400 1350 2    50   ~ 0
Note! Flyback diodes are an addition and not part of the board
Text Notes 5200 5850 2    50   ~ 0
Note! Flyback diodes are an addition and not part of the board
$EndSCHEMATC
