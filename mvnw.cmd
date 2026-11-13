@echo off
call "%~dp0ms-auth\mvnw.cmd" -f "%~dp0pom.xml" %*
exit /b %errorlevel%
