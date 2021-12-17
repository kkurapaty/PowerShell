@ECHO OFF
REM ***********************************************************
REM Script to Clean the source folder of all temporary files,
REM even the ones Visual Studio seems to leave behind.
REM 
REM Usage: CleanCode slnPath [--all]
REM ***********************************************************
SETLOCAL

:CheckOptions
IF /I "%1" == "?" GOTO Usage
IF /I "%1" == "-help" GOTO Usage

SET solutionPath=%1

:SetupVariables
PUSHD ..

:VsClean
devenv %solutionPath% /Clean "Debug"
devenv %solutionPath% /Clean "Release"

:CleanFiles
DEL /s DesignTimeResolveAssemblyReferencesInput.cache 1> nul 2> nul
DEK /s bin\*.zip 2>nul
FOR /D /R %%i IN (obj) DO DEL /s "%%i\*.g.i.cs" 2> nul
FOR /D /R %%i IN (obj) DO DEL /s "%%i\*.i.cache" 2> nul

:CleanDir
RMDIR /s /q bin
FOR /D /R %%i IN (Debug) DO RMDIR "%%i\TempPE" 2> nul
FOR /D /R %%i IN (Release) DO RMDIR "%%i\TempPE" 2> nul
FOR /D /R %%i IN (Debug) DO RMDIR "%%i\Resources" 2> nul
FOR /D /R %%i IN (Release) DO RMDIR "%%i\Resources" 2> nul
FOR /D /R %%i IN (Debug) DO RMDIR "%%i\UserControls" 2> nul
FOR /D /R %%i IN (Release) DO RMDIR "%%i\UserControls" 2> nul
FOR /D /R %%i IN (Debug) DO RMDIR "%%i\Views" 2> nul
FOR /D /R %%i IN (Release) DO RMDIR "%%i\Views" 2> nul
FOR /D /R %%i IN (Debug) DO RMDIR "%%i" 2> nul
FOR /D /R %%i IN (Release) DO RMDIR "%%i" 2> nul
FOR /D /R %%i IN (obj) DO RMDIR "%%i\x86" 2> nul
FOR /D /R %%i IN (bin) DO RMDIR "%%i" 2> nul
FOR /D /R %%i IN (obj) DO RMDIR "%%i" 2> nul

:CleanAll
IF /I NOT "%2" == "--all" GOTO Success
DEL /S *.csproj.user 2> nul 
DEL /S *.resharper.user 2> nul
DEL /S /AH *.suo 2> nul 2> nul
RMDIR /S /Q Install\_Resharper.Setup 2> nul
RMDIR /S /Q ..\_Resharper.* 2> nul

:Success
POPD
EXIT /B 0

:Usage
ECHO.
ECHO Usage: CleanCode SolutionPath [--all]
ECHO.
EXIT /B 1