@echo off
cls
set /p input=Are you sure want to restart your machine? 

IF /I ["%input%"]==["y"] ( 
	goto :Reboot
)
GOTO :END

:Reboot
@echo Please Wait, Restarting Computer now ...
shutdown -r -f -t 0

:END