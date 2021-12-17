@ECHO OFF &SETLOCAL
CLS

SETLOCAL EnableDelayedExpansion 
SETLOCAL EnableExtensions

CALL :ShowHelp

:: USER settings
SET WORKING_DIR=%~dp0
SET LOG_FILE=C:\TEMP\%date:~-4%_%date:~3,2%_%date:~0,2%_T_%time:~0,2%_%time:~3,2%_%time:~6,2%.log

SET /P USER_ACTION=-Compare Mode BINARY (B) / TEXT (C) ? 
SET /P FOLDER1=-Source Directory ? 
SET /P FOLDER2=-Target Directory ? 

@CALL :TRIM %USER_ACTION% USER_ACTION
@CALL :TRIM %FOLDER1% FOLDER1
@CALL :TRIM %FOLDER2% FOLDER2

IF %USER_ACTION% == [] (
	@ECHO Need to know your purpose of calling this script. Please try again.
	GOTO EOF
)

IF %FOLDER1% == [] (
	@ECHO Source Directory name is required. Please try again.
	GOTO EOF
)

IF %FOLDER2% == [] (
	@ECHO Target Directory name is required. Please try again.
	GOTO EOF
)

@ECHO ..........................................................................................
@ECHO	Please terminate by pressing [Ctrl + C] if you are not sure or do not want to proceed.
@ECHO ..........................................................................................
PAUSE


@CALL :COMPARE_FILES
GOTO :DONE

:COMPARE_FILES
@ECHO Comparing files, Please wait...
	FC /%USER_ACTION% %FOLDER1% %FOLDER2% > %LOG_FILE%
	
IF EXIST %LOG_FILE% (
	@ECHO Please wait, opening comparision results...
	@START "Notepad" notepad %LOG_FILE%
)
@ECHO Comparing Done.
GOTO :EOF


GOTO :DONE

:ShowHelp
@ECHO ********************************************************************
@ECHO *   Compare Files / Folders           - Script by Kiran Kurapaty   *
@ECHO *   Tiny script to do binary/text compare source and target files. *
@ECHO *                                                                  *
@ECHO *   Usage:                                                         *
@ECHO *           -BINARY (B) / TEXT (C) ? C                             *
@ECHO *           -SOURCE DIRECTORY ? C:\CAM\RTB2019                     *
@ECHO *           -TARGET DIRECTORY ? C:\CAM\Calypso.2019                *
@ECHO *                                                                  *
@ECHO ******************************************************************** 
GOTO :EOF

:TRIM
SET %2=%1
GOTO :EOF

:DONE
CD %WORKING_DIR%
@ECHO Process Completed.
PAUSE

:END
ENDLOCAL