@echo off
SETLOCAL EnableDelayedExpansion
::Pushd "%1"
cls
set SEARCH_FILTER=%1

IF /I "%SEARCH_FILTER%" == "/?" goto :ShowHelp

IF /I %SEARCH_FILTER% == [] (set "SEARCH_FILTER=*.*")

for /f "tokens=1,* delims= " %%a in ("%*") do set SEARCH_STRING=%%b

@echo Please Wait, findstr /s /p /i /n /c:%SEARCH_STRING% %SEARCH_FILTER%...
findstr /s /p /i /n /c:%SEARCH_STRING% %SEARCH_FILTER%
goto result%ERRORLEVEL%

:result0
@ECHO Completed.
goto :EOF

:result1
@ECHO %SearchStr% : did not returned any results.
goto :EOF

:result2
@ECHO 2. Unknown error occured
goto :EOF

:result3
@ECHO 3. Unknown error occured.
goto :EOF

:result4
@ECHO 4. Unknown error occured.
goto :EOF

:result5
@ECHO 5. Unknown error occured.
goto :EOF

:ShowHelp
@echo Usage: Finder <search string>
@echo Example: Finder app.tt

:EOF
@echo Done.