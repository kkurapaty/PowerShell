@ECHO OFF
REM *********************************************
REM Script to Build the C# based assemblies.
REM
REM Usage: BuildCode [slnPath] [debug or release]
REM *********************************************

SETLOCAL

:CheckOptions
IF /I "%1" == "?" GOTO Usage
IF /I "%1" == "-help" GOTO Usage

SET solutionPath=%1

:SetupVariables
PUSHD ..

SET buildType=/Rebuild

IF /I "%2" == "--NoRebuild" SET buildType=/Build
IF /I "%3" == "--NoRebuild" SET buildType=/Build

:BuildDebugCode
IF /I "%2" == "Release" GOTO BuildReleaseCode
devenv %solutionPath% %buildType% "Debug"
IF ERRORLEVEL 1 GOTO Failed

:BuildReleaseCode
IF /I "%2" == "Debug" GOTO Success
devenv %solutionPath% %buildType% "Release"
IF ERRORLEVEL 1 GOTO Failed

:Success
Goto CleanUp

:Usage
ECHO.
ECHO Usage: BuildCode [solutionPath] [debug ^| release] [--norebuild]
ECHO.
EXIT /B 1

:Failed
POPD
EXIT /B 1

:CleanUp
POPD

:EXIT