@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ===============================
REM 切换到 bat 所在目录（ComfyUI 根目录）
REM ===============================
cd /d "%~dp0"

REM ===============================
REM ComfyUI 访问地址（注意结尾 /）
REM ===============================
set COMFY_URL=http://127.0.0.1:8188/

REM ===============================
REM Edge 路径
REM ===============================
set EDGE_PATH="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

REM ===============================
REM Edge 独立 Profile
REM ===============================
set EDGE_PROFILE=C:\Users\12608\Documents\ComfyUI\ComfyUI_Edge_Profile

REM ===============================
REM 启动 ComfyUI（如未运行）
REM ===============================
netstat -ano | findstr :8188 >nul
if %errorlevel%==0 (
    echo [INFO] ComfyUI 端口已监听
) else (
    echo [INFO] 启动 ComfyUI main.py ...
    start "ComfyUI Server" cmd /k python main.py
)

REM ===============================
REM 等待 WebUI 真正可访问
REM ===============================
echo [INFO] 等待 ComfyUI WebUI 就绪...
:WAIT_LOOP
powershell -command ^
  "try { Invoke-WebRequest -UseBasicParsing %COMFY_URL% -TimeoutSec 2 | Out-Null; exit 0 } catch { exit 1 }"
if errorlevel 1 (
    timeout /t 1 >nul
    goto WAIT_LOOP
)

echo [INFO] ComfyUI WebUI 已就绪，打开 Edge

REM ===============================
REM 打开 Edge 并直达 WebUI
REM ===============================
start "ComfyUI Edge" %EDGE_PATH% ^
 --user-data-dir="%EDGE_PROFILE%" ^
 --disable-gpu ^
 --disable-software-rasterizer ^
 --disable-background-timer-throttling ^
 --disable-renderer-backgrounding ^
 --disable-features=VizDisplayCompositor ^
 %COMFY_URL

exit
