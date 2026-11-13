@echo off
setlocal
call "%~dp0mvnw.cmd" clean package -Dmaven.test.skip=true %*
exit /b %errorlevel%
