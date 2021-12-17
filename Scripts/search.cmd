@echo off
::Pushd "%~dp0"
cls

IF "%*" == [""] (
	@ECHO Please Enter Search String and try again.
	GOTO :EOF
)

@echo Please Wait, Searching for %* ...
C:\SysInternals\strings -s %* * | findstr /s /p /i /n /c:"%*" *.*
@echo off
::popd

:END