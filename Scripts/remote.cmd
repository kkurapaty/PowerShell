@echo off
SETLOCAL
SET REMOTE_HOST_NAME=%1

IF /I [%REMOTE_HOST_NAME%] == [] (
	SETLOCAL
	SET /P REMOTE_HOST_NAME=-Enter Host Name : 
)
@echo Please wait, Connecting %REMOTE_HOST_NAME% ...
@CALL MSTSC /v:%REMOTE_HOST_NAME% /console

ENDLOCAL
@echo Done.