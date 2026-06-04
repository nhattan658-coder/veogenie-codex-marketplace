@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Resolve the installed VeoGenie MCP launcher without assuming a fixed drive.
if "%VEOGENIE_WORKFLOW_BACKEND_URL%"=="" (
  set "VEOGENIE_WORKFLOW_BACKEND_URL=http://127.0.0.1:8788"
)

if not "%VEOGENIE_MCP_LAUNCHER%"=="" (
  if exist "%VEOGENIE_MCP_LAUNCHER%" (
    set "VEOGENIE_MCP_RESOLVED=%VEOGENIE_MCP_LAUNCHER%"
    goto :run
  )

  >&2 echo [veogenie-mcp-launcher] VEOGENIE_MCP_LAUNCHER points to a missing file: "%VEOGENIE_MCP_LAUNCHER%"
  exit /b 1
)

call :try "%LOCALAPPDATA%\VeoGenie\veogenie-mcp.cmd"
if defined VEOGENIE_MCP_RESOLVED goto :run
call :try "%ProgramData%\VeoGenie\veogenie-mcp.cmd"
if defined VEOGENIE_MCP_RESOLVED goto :run
call :try "%LOCALAPPDATA%\Programs\VeoGenie Tool\veogenie-mcp.cmd"
if defined VEOGENIE_MCP_RESOLVED goto :run
call :try "%LOCALAPPDATA%\VeoGenie Tool\veogenie-mcp.cmd"
if defined VEOGENIE_MCP_RESOLVED goto :run
call :try "%ProgramFiles%\VeoGenie Tool\veogenie-mcp.cmd"
if defined VEOGENIE_MCP_RESOLVED goto :run
call :try "%ProgramFiles(x86)%\VeoGenie Tool\veogenie-mcp.cmd"
if defined VEOGENIE_MCP_RESOLVED goto :run
call :try "C:\VeoGenie Tool\veogenie-mcp.cmd"
if defined VEOGENIE_MCP_RESOLVED goto :run
call :try "D:\VeoGenie Tool\veogenie-mcp.cmd"
if defined VEOGENIE_MCP_RESOLVED goto :run
call :try "E:\VeoGenie Tool\veogenie-mcp.cmd"
if defined VEOGENIE_MCP_RESOLVED goto :run

>&2 echo [veogenie-mcp-launcher] Could not find VeoGenie Tool's installed veogenie-mcp.cmd.
>&2 echo [veogenie-mcp-launcher] Install/open VeoGenie Tool, or set VEOGENIE_MCP_LAUNCHER to the full launcher path.
exit /b 1

:try
if "%~1"=="" exit /b 0
if exist "%~1" set "VEOGENIE_MCP_RESOLVED=%~1"
exit /b 0

:run
if "%VEOGENIE_MCP_LAUNCHER_DRY_RUN%"=="1" (
  echo %VEOGENIE_MCP_RESOLVED%
  exit /b 0
)

call "%VEOGENIE_MCP_RESOLVED%" %*
exit /b %ERRORLEVEL%
