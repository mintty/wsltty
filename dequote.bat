@echo off
rem https://ss64.com/nt/syntax-dequote.html
for /f "delims=" %%A in ('echo %%%1%%') do set %1=%%~A
