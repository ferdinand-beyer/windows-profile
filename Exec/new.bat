@echo off
::
:: Open a new console window for the current directory.  And command line
:: arguments are considered as commands and executed in the new console.
::
start cmd.exe /K "cd %CD% & %*"
