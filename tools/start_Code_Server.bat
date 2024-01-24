@echo off
setlocal enabledelayedexpansion

set SRVROOT=%1

%SRVROOT%\bin\httpd.exe -d %SRVROOT% -f %SRVROOT%\conf\httpd.conf

endlocal
