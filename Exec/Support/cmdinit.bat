@echo off
::
:: Command Initialization Script
::
:: Set to AutoRun via registry:
:: HKEY_CURRENT_USER\Software\Microsoft\Command Processor\AutoRun
::

call :abspath LOCAL_ROOT %~dp0..\..

set PATH=%LOCAL_ROOT%\Exec;%PATH%

exit /B

:abspath
set %1=%~f2
