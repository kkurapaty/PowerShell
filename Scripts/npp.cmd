@echo off
:: @echo %~dp0
@echo Please wait, starting Notepad++ ...
IF EXIST "C:\Work\Tools\npp.7.8.6\Notepad++.exe" (
	START "Notepad++" "C:\Work\Tools\npp.7.8.6\notepad++.exe" "%*"
) ELSE  (	
	START "Notepad++" "%LOCALAPPDATA%\Microsoft\AppV\Client\Integration\8FEB8FDD-A309-488C-A2F1-E6301F6E0E0D\Root\notepad++.exe" "%*"
)	