@echo off
@echo Please wait, Cleaning in progress ...
IF EXIST "Client\obj" ( 
	@echo Cleaing Client Objects ...
	rd Client\obj /s /q 
)
IF EXIST "Client\bin" ( 
	@echo Cleaing Client Bin  ...
	rd Client\bin /s /q 
)
IF EXIST "Shared\obj" ( 
	@echo Cleaing Shared Objects ...
	rd Shared\obj /s /q 
)
IF EXIST "Shared\bin" ( 
	@echo Cleaing Shared Bin ...
	rd Shared\bin /s /q 
)
IF EXIST "Server\obj" ( 
	@echo Cleaing Server Objects ...
	rd Server\obj /s /q 
)
IF EXIST "Server\bin" ( 
	@echo Cleaing Server Bin ...
	rd Server\bin /s /q 
)
:: Ideally we shouldn't get this because above step removes everything under bin
IF EXIST "Server\logs" ( 
	@echo Cleaing Server Logs ...
	rd Server\logs /s /q 
)

:: This should delete any other obj/bin/logs directories left over.
FOR /F "tokens=*" %%G IN ('DIR /B /AD /S bin') DO RMDIR /S /Q "%%G"
FOR /F "tokens=*" %%G IN ('DIR /B /AD /S obj') DO RMDIR /S /Q "%%G"
FOR /F "tokens=*" %%G IN ('DIR /B /AD /S logs') DO RMDIR /S /Q "%%G"

@echo Done.
