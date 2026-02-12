@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ===============================
echo  正在关闭 ComfyUI 和相关进程
echo ===============================

REM ===============================
REM 1. 关闭占用 8188 端口的进程
REM ===============================
echo [INFO] 查找占用 8188 端口的进程...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8188') do (
    echo [INFO] 终止 PID=%%a
    taskkill /PID %%a /F >nul 2>&1
)

REM ===============================
REM 2. 兜底：关闭所有 python main.py（防止端口已释放但进程还在）
REM ===============================
echo [INFO] 检查残留 python 进程...
for /f "tokens=2 delims=," %%a in ('tasklist /FI "IMAGENAME eq python.exe" /FO CSV ^| findstr /I "python.exe"') do (
    taskkill /PID %%~a /F >nul 2>&1
)

REM ===============================
REM 3. 只关闭 ComfyUI 专用 Edge（按 Profile 路径）
REM ===============================
echo [INFO] 关闭 ComfyUI 专用 Edge...
wmic process where "name='msedge.exe' and commandline like '%%ComfyUI_Edge_Profile%%'" call terminate >nul 2>&1

echo ===============================
echo  ComfyUI 已完全关闭
echo ===============================
timeout /t 2 >nul
exit
