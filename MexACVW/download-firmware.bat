@ECHO OFF
rem Script to help user download firmware

set FILE=msns-extra.s19
set CHOICE=
set DOWNLOAD=
set MFLAG=

cls

rem See if X64
if exist %WINDIR%\system32\choice.exe goto WIN64_OK

rem First check if the zipfile was extracted correctly
if not exist %FILE% goto FAILURE
if exist src\choice.com goto C_OK
if not exist choice.com goto FAILURE
set CHOICE=choice.com
echo CHOICE.COM found in wrong place. This batch file may fail.
echo Ensure you 'use folder names' when extracting.
echo .
pause
goto D_TEST

:WIN64_OK
set CHOICE=%WINDIR%\system32\choice.exe
set MFLAG=/m:
goto D_TEST

:C_OK
set CHOICE=src\choice.com

:D_TEST
if exist src\download.exe goto D_OK
if not exist download.exe goto FAILURE
set DOWNLOAD=download.exe
echo DOWNLOAD.EXE found in wrong place. This batch file may fail.
echo Ensure you 'use folder names' when extracting.
echo .
pause
goto CHKFILE

:D_OK
set DOWNLOAD=src\download.exe

:CHKFILE
if not exist src\%FILE% goto ASK
echo Caution! src\%FILE% found as well, be sure you are downloading
echo the right file.

:ASK
cls
ECHO Downloading new Firmware to Megasquirt board
ECHO ...

echo WARNING:
echo This will wipe out all settings on the Megasquirt.
ECHO ...

ECHO Communication ports:
ECHO    1 - COM1
ECHO    2 - COM2
ECHO    3 - COM3
ECHO    4 - COM4
ECHO    5 - COM5
ECHO    6 - COM6
ECHO    7 - COM7
ECHO    8 - COM8
ECHO    9 - COM9
ECHO    Q - Quit

%CHOICE% /c:123456789Q  %MFLAG%" Select download port [ COM1 ]: Q to Quit "
if errorlevel 1 set PORT=-c1
if errorlevel 2 set PORT=-c2
if errorlevel 3 set PORT=-c3
if errorlevel 4 set PORT=-c4
if errorlevel 5 set PORT=-c5
if errorlevel 6 set PORT=-c6
if errorlevel 7 set PORT=-c7
if errorlevel 8 set PORT=-c8
if errorlevel 9 set PORT=-c9
if errorlevel 10 goto ALL_DONE
:GOT_PORT
cls
echo If you are upgrading from standard Megasquirt code you will need to
echo use the boot jumper soon. If you are upgrading from Megasquirtnspark,
echo DualTable, MegasquirtnEDIS or an earlier MSnS-extra this program
echo will do it for you.
echo .
echo If you are unsure then press  Y     to quit - press Q
echo .
echo .
echo .
echo . Please read the README file!!!
echo .
%CHOICE% /c:YNQ  %MFLAG%"Are you upgrading from standard Megasquirt code "
if errorlevel==3 goto ALL_DONE
if errorlevel==2 goto BOOTLOAD
if errorlevel==1 goto BOOTJUMP

:BOOTJUMP
cls
echo 1. Turn off Megasquirt
echo .
echo .
pause
echo 2. Install Boot jumper (or short out boot resistor)
echo .
echo .
pause
echo 3. Turn on Megasquirt
echo .
echo .
pause
echo .
echo This should count up to 1700+ lines
echo .
echo %DOWNLOAD% %PORT% %FILE%
%DOWNLOAD% %PORT% %FILE%
goto ALL_DONE

rem -------------------------------------------------------
:FAILURE
echo The zipfile has not been extracted correctly - please ensure you
echo 'use folder names' or create sub directories when extracting.
echo This batch file cannot run without:
echo src\CHOICE.COM
echo src\DOWNLOAD.EXE
echo %FILE%
echo .
echo Aborting
goto ALL_DONE

rem -------------------------------------------------------
:BOOTLOAD
echo .
echo This should count up to 1700+ lines
echo .
echo %DOWNLOAD% %PORT% %FILE%
%DOWNLOAD% -b %PORT% %FILE%

:ALL_DONE
pause
SET PORT=
SET FILE=
SET CHOICE=
SET DOWNLOAD=
ECHO.
ECHO.
ECHO.
echo You can now close this window
