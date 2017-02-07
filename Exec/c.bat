@echo off
::
:: Change the current working directory to a configured "well-known" file
:: system location.  Reads a configuration file mapping short names to
:: directory paths, and allows to refer to the directory path using the short
:: name.  The configuration file also supports expansion of environment
:: variables.
::

setlocal EnableDelayedExpansion
set SELF=%~n0

set CONFIG_FILE=%LOCAL_ROOT%\Config\locations.txt

set ARG_HELP=0
set ARG_EDIT=0
set ARG_DRYRUN=0
set ARG_EXPLORER=0
set ARG_LIST=0
set ARG_APPEND=
set ARG_NAME=

goto :readargs

:usage
echo.usage: %SELF% [-n] [-s] ^<location^>
echo.       %SELF% ^(-a ^<name^> ^| -e ^| -l^)
echo.
echo.Change directory to a known location.
echo.
echo.Options:
echo.  -?, -h      Show this help and exit
echo.  -a ^<name^>   Add the current directory as ^<name^> to the configuration file
echo.  -e          Edit the location configuration file and exit
echo.  -l          List all known locations and exit
echo.  -n          Dry run: just print out the path
echo.  -s          Open explorer window instead of changing the directory
echo.
echo.Configuration file: %CONFIG_FILE%
exit /B

:readargs
set ARG=%~1
if "%ARG%" == "" (
  goto :endargs
) else if "%ARG:~0,1%" == "-" (
  if "%ARG%" == "-?" (
    set ARG_HELP=1
  ) else if "%ARG%" == "-a" (
    set ARG_APPEND=%~2
    shift
    if "!ARG_APPEND!" == "" (
      echo.Missing ^<name^>
      goto :invalidarg
    )
    if "!ARG_APPEND:~0,1!" == "-" (
      echo.Missing ^<name^>
      goto :invalidarg
    )
  ) else if "%ARG%" == "-e" (
    set ARG_EDIT=1
  ) else if "%ARG%" == "-h" (
    set ARG_HELP=1
  ) else if "%ARG%" == "-l" (
    set ARG_LIST=1
  ) else if "%ARG%" == "-n" (
    set ARG_DRYRUN=1
  ) else if "%ARG%" == "-s" (
    set ARG_EXPLORER=1
  ) else (
    echo.Unknown option: '%ARG%'
    goto :invalidarg
  )
) else if "%ARG_NAME%" == "" (
  set ARG_NAME=%ARG%
) else (
  echo.Too many arguments.
  goto :invalidarg
)
shift
goto :readargs

:invalidarg
echo.More info with: '%SELF% -?'
exit /B 1

:endargs
if "%ARG_HELP%" == "1" goto :usage

if not exist "%CONFIG_FILE%" (
  echo.Missing configuration file: %CONFIG_FILE%
  exit /B 2
)

if "%ARG_EDIT%" == "1" goto :edit
if "%ARG_LIST%" == "1" goto :list
if not "%ARG_APPEND%" == "" goto :append

if "%ARG_NAME%" == "" (
  echo.No location specified.
  goto :invalidarg
)

call :lookup "%ARG_NAME%"
if not errorlevel 1 (
  call :expand "!LOOKUP_PATH!"
  set TARGET_PATH=!EXPANDED!
) else if exist "%ARG_NAME%" (
  :: Fallback to existing directory (use like 'cd')
  set TARGET_PATH=%ARG_NAME%
) else (
  echo.Unknown location: '%ARG_NAME%'
  exit /B 1
)

if "%ARG_DRYRUN%" == "1" (
  echo.!TARGET_PATH!
  exit /B
)

if "%ARG_EXPLORER%" == "1" (
  start "" "!TARGET_PATH!"
  exit /B
)

endlocal & (
  cd /D "%TARGET_PATH%" || (
    echo.Could not "cd" to: "%TARGET_PATH%"
    exit /B 1
  )
  exit /B
)

:edit
call edit.bat "%CONFIG_FILE%"
exit /B

:list
for /F "eol=; tokens=1*" %%i in (%CONFIG_FILE%) do (
  call :expand "%%j"
  echo.%%i: !EXPANDED!
)
exit /B

:append
:: Backup the configuration file
copy /Y "%CONFIG_FILE%" "%CONFIG_FILE%.bak" >NUL
:: Append the current directory.
echo.%ARG_APPEND% %CD% >>%CONFIG_FILE%
echo.Added '%ARG_APPEND%': %CD%
exit /B

:expand
set STR=%~1
for /F "tokens=*" %%i in ('echo.!STR!') do set EXPANDED=%%i
exit /B

:lookup
set NAME=%~1
:: Look up the given name in the config file.
for /F "eol=; tokens=1*" %%i in (%CONFIG_FILE%) do (
  if "%NAME%" == "%%i" (
    set LOOKUP_PATH=%%j
    exit /B
  )
)
exit /B 1

