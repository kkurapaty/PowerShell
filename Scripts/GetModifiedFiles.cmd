@ECHO OFF &SETLOCAL
CLS

SETLOCAL EnableDelayedExpansion 
SETLOCAL EnableExtensions

CALL :ShowHelp

:: USER settings
SET WORKING_DIR=%~dp0
SET TARGET_DIR=C:\TEMP\%date:~-4%%date:~3,2%%date:~0,2%T%time:~0,2%%time:~3,2%%time:~6,2%

SET /P USER_ACTION=-LIST / COPY / MOVE ? 
SET /P NUM_DAYS=-HOW MANY DAYS OLD ? 
SET /P DIRECTORY_NAME= -WHICH DIRECTORY ? 

@CALL :TRIM %USER_ACTION% USER_ACTION
@CALL :TRIM %NUM_DAYS% NUM_DAYS
@CALL :TRIM %DIRECTORY_NAME% DIRECTORY_NAME

::SET /A NUM_DAYS=%NUM_DAYS%

IF %NUM_DAYS% EQU [] (
	@ECHO Number of Days is required. Please try again.
	GOTO EOF
)

IF %USER_ACTION% == [] (
	@ECHO Need to know your purpose of calling this script. Please try again.
	GOTO EOF
)

IF %DIRECTORY_NAME% == [] (
	@ECHO Directory name is required. Please try again.
	GOTO EOF
)

@ECHO ..........................................................................................
@ECHO	Are you sure want to %USER_ACTION% files changed within last %NUM_DAYS% days to %TARGET_DIR% ?
@ECHO	Please terminate by pressing [Ctrl + C] if you are not sure or do not want to proceed.
@ECHO ..........................................................................................
PAUSE

IF /I ["%USER_ACTION%"] EQU ["LIST"] (
	@CALL :LIST_FILES
	GOTO :DONE
)

IF /I ["%USER_ACTION%"] EQU ["COPY"] (
	@CALL :COPY_FILES
	GOTO :DONE
)

IF /I ["%USER_ACTION%"] EQU ["MOVE"] (
	@CALL :MOVE_FILES
	GOTO :DONE
)

GOTO :END

:LIST_FILES
@ECHO Listing files, Please wait...
	FORFILES /P %DIRECTORY_NAME% /S /D -%NUM_DAYS% /C "CMD /C @ECHO 0x09 @path 0x09 @fsize bytes"	
@ECHO Listing Complete.
GOTO :EOF

:COPY_FILES
@MKDIR %TARGET_DIR%
@ECHO Copying files, Please wait...
	FORFILES /P %DIRECTORY_NAME% /S /D -%NUM_DAYS% /C "cmd /c @IF (@isdir==FALSE) @COPY @file %%TARGET_DIR%%"	
@ECHO Copy Complete.
GOTO :EOF

:MOVE_FILES
@MKDIR %TARGET_DIR%
@ECHO Moving files, Please wait...	
	FORFILES /P %DIRECTORY_NAME% /S /D -%NUM_DAYS% /C "cmd /c @IF (@isdir==FALSE) @MOVE @file %%TARGET_DIR%%"	
@ECHO Move Complete.
GOTO :EOF

GOTO :DONE

:ShowHelp
@ECHO ********************************************************************
@ECHO *   GetModifiedFiles                  - Script by Kiran Kurapaty   *
@ECHO *   Tiny script to list/copy/move files modified within "n" days.  *
@ECHO *                                                                  *
@ECHO *   Usage:                                                         *
@ECHO *           -LIST / COPY / MOVE ?  LIST                            *
@ECHO *           -HOW MANY DAYS OLD ? 10                                *
@ECHO *           -WHICH DIRECTORY ?  Calypso.2019                       *
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