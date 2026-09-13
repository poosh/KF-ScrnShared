@echo off

setlocal

set /A ERR=0
set CURDIR=%~dp0
if not exist ..\ScrnMakeEnv.cmd (
    set /A ERR=101
    echo ..\ScrnMakeEnv.cmd not found!
    echo Make ScrnShared first!
    goto end
)
call ..\ScrnMakeEnv.cmd %CURDIR%


xcopy /F /I /Y %BUNDLEDIR%\System\%KFPACKAGE%.u %KFDIR%\System\
set /A ERR=%ERRORLEVEL%
if %ERR% NEQ 0 goto end
xcopy /F /I /Y %BUNDLEDIR%\System\%KFPACKAGE%.u %STEAMDIR%\System\
set /A ERR=%ERRORLEVEL%
if %ERR% NEQ 0 goto end

echo %KFPACKAGE%.u restored to its latest release version
goto end

:end
cd /D %CURDIR%
endlocal & SET _EC=%ERR%
exit /b %_EC%
