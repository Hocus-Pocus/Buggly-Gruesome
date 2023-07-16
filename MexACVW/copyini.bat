@echo off
set MTPATH="c:\program files\megasquirt\megatune2.25"
rem This is copyini.bat - batch file to copy over msns-extra.ini
rem First test if Megatune is installed ok, by checking one file

if exist %PROGRAMFILES%\megasquirt\megatune2.25\mtcfg\megatune.ini goto xp2000
if exist "c:\program files\megasquirt\megatune2.25\mtcfg\megatune.ini" goto english
if exist "C:\Ohjelmatiedostot\megasquirt\megatune2.25\mtcfg\megatune.ini" goto finnish 
if exist "C:\Programme\megasquirt\megatune2.25\mtcfg\megatune.ini" goto prog1
if exist "C:\Programmi\megasquirt\megatune2.25\mtcfg\megatune.ini" goto prog2
if exist "C:\Archivos de programa\megasquirt\megatune2.25\mtcfg\megatune.ini" goto prog3
if exist "C:\Program\megasquirt\megatune2.25\mtcfg\megatune.ini" goto prog4
if exist "C:\Programfiler\megasquirt\megatune2.25\mtcfg\megatune.ini" goto prog5
if exist "C:\Programmer\megasquirt\megatune2.25\mtcfg\megatune.ini" goto prog6
if exist "C:\Programas\megasquirt\megatune2.25\mtcfg\megatune.ini" goto prog7

@echo You do not seem to have Megatune2.25 (release) installed where I am looking.
@echo Either it is not installed, in which case please install it
@echo OR you have an international version of Windows that uses something else instead
@echo of "C:\Program Files" - you will have to copy the .ini file manually.
pause
goto done

:xp2000
set MTPATH=%PROGRAMFILES%\megasquirt\megatune2.25\mtcfg
goto docopy

:english
set MTPATH="c:\program files\megasquirt\megatune2.25\mtcfg"
goto docopy

:finnish
set MTPATH=C:\Ohjelmatiedostot\megasquirt\megatune2.25\mtcfg
goto docopy

:prog1
set MTPATH=C:\Programme\megasquirt\megatune2.25\mtcfg
goto docopy

:prog2
set MTPATH=C:\Programmi\megasquirt\megatune2.25\mtcfg
goto docopy

:prog3
set MTPATH="C:\Archivos de programa\megasquirt\megatune2.25\mtcfg"
goto docopy

:prog4
set MTPATH="C:\Program\megasquirt\megatune2.25\mtcfg"
goto docopy

:prog5
set MTPATH="C:\Programfiler\megasquirt\megatune2.25\mtcfg"
goto docopy

:prog6
set MTPATH="C:\Programmer\megasquirt\megatune2.25\mtcfg"
goto docopy

:prog7
set MTPATH="C:\Programas\megasquirt\megatune2.25\mtcfg"
goto docopy

:docopy
@echo Copying msns-extra.ini file... check for errors below
@echo .
@echo on
copy msns-extra.ini %MTPATH%
copy msns-extra.ini %MTPATH%\msns-extra.ini.029y2
@echo off
@echo .
pause
:done
@echo .
@echo You can now close this window
