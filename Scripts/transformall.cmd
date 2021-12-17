@echo off
SETLOCAL EnabledDelayedExpansion

:: set the working dir (default to current dir)
set workingDir=%cd%
if not (%1)==() set workingDir=%1

:: set the file extension (default to cs)
set extension=cs
if not (%2)==() set extension=%2

echo Extracting all App.tt from %workingDir%
:: create a list of all the T4 templates in the working dir
:: dir %workingDir%\App.tt /b /s > t4list.txt
dir %workingDir%\App.tt /b /s > t4list.txt

echo Following T4 templates will be transformed/copied:
type t4list.txt

echo Copying all templates to ...
for /f %%d in (t4list.txt) do ( set target_file_name=%%d
@echo %%d => !target_file_name!    
)
:: set target_file_name=!target_file_name:~0,-3!.%extension%
:: TextTransform.exe -out !target_file_name! %%d
echo Transformation Completed.