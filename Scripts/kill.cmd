@echo off
@SETLOCAL EnableDelayedExpansion 

@if "%1"=="/?" goto ShowHelp
@if /I "%1"=="/help" goto ShowHelp
@if /I "%1"=="/h" goto ShowHelp

@echo Please Wait, Terminating [%1] ...
TASKKILL /F /IM %1.exe /T
@echo Command Completed.

@goto :EOF


:ShowHelp
@echo .
@echo Usage: KILL notepad
@echo .
@goto :EOF

:EOF
@endlocal