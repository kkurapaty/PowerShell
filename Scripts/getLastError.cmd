@echo off
CLS
COLOR 0F
SETLOCAL EnableDelayedExpansion 
SETLOCAL EnableExtensions

CD C:\Users\kurapatk1

@ECHO OFF
:GetLastError
::IF NOT %ERRORLEVEL%==0 (
	:: Reset variables
	FOR %%A IN (1 10 100) DO SET ERR%%A=

	:: Check error level hundred folds
	FOR %%A IN (0 1 2) DO IF ERRORLEVEL %%A00 SET ERR100=%%A
	IF %ERR100%==2 GOTO 200
	IF %ERR100%==0 IF NOT "%1"=="/0" SET ERR100=

	:: Check error level ten-folds
	FOR %%A IN (0 1 2 3 4 5 6 7 8 9) DO IF ERRORLEVEL %ERR100%%%A0 SET ERR10=%%A
	IF "%ERR100%"=="" IF %ERR10%==0 SET ERR10=

	:1
	:: Check error level units
	FOR %%A IN (0 1 2 3 4 5) DO IF ERRORLEVEL %ERR100%%ERR10%%%A SET ERR1=%%A
	:: Modification necessary for error-level 250+
	IF NOT ERRORLEVEL 250 FOR %%A IN (6 7 8 9) DO IF ERRORLEVEL %ERR100%%ERR10%%%A SET ERR1=%%A
	GOTO End

	:200
	:: In case of error levels over 200 both ten-folds and units are limited to 5
	:: since the highest DOS error level is 255
	FOR %%A IN (0 1 2 3 4 5) DO IF ERRORLEVEL 2%%A0 SET ERR10=%%A
	IF ERR10==5 FOR %%A IN (0 1 2 3 4 5) DO IF ERRORLEVEL 25%%A SET ERR1=%%A
	IF NOT ERR10==5 GOTO 1

	:End
	:: Clean up the mess and show results
	SET ERRORLEV=%ERR100%%ERR10%%ERR1%
	FOR %%A IN (1 10 100) DO SET ERR%%A=
	ECHO ERRORLEVEL  %ERRORLEV%
:: )

:EOF
ENDLOCAL