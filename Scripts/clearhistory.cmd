@echo off
DEL \\ldndata05.sbintldirectory.com\userdata$\kurapatk\Recent /F /Q
DEL %userprofile%\AppData\Roaming\Microsoft\Windows\Recent /F /Q
DEL %userprofile%\"AppData\Local\Microsoft\Windows\Temporary Internet Files" /S /F /Q
DEL "%temp%"\*.htm* /F /Q
DEL "%temp%"\*.log /F /Q
DEL "%temp%"\*.tmp /F /Q
DEL "%temp%"\*.bak /F /Q
DEL "%temp%"\*.~* /F /Q

DEL %userprofile%\Kiran\Samples\*.log /S /F /Q
DEL %userprofile%\Kiran\Samples\*.obj /S /F /Q
DEL %userprofile%\Kiran\Samples\*.tmp /S /F /Q
DEL %userprofile%\Kiran\Samples\*.bak /S /F /Q

DEL C:\CAM\*.log /S /F /Q
DEL C:\CAM\*.obj /S /F /Q
DEL C:\CAM\*.tmp /S /F /Q
DEL C:\CAM\*.bak /S /F /Q

DEL C:\Temp\*.log /S /F /Q
DEL C:\Temp\*.obj /S /F /Q
DEL C:\Temp\*.tmp /S /F /Q
DEL C:\Temp\*.bak /S /F /Q
@echo Done
