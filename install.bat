@echo off
REM =============================================================
REM infinite-agents — Automated Setup Script (Windows)
REM https://github.com/kkayron/infinite-agents
REM =============================================================

echo.
echo   [infinity] infinite-agents
echo   NVIDIA NIM multi-key swarm — Windows installer
echo.

REM Check Python
python --version >nul 2>&1
IF ERRORLEVEL 1 (
  echo [ERROR] Python not found. Install from https://python.org
  pause
  exit /b 1
)

REM Check / Install uv
uv --version >nul 2>&1
IF ERRORLEVEL 1 (
  echo [1/6] Installing uv...
  powershell -Command "irm https://astral.sh/uv/install.ps1 | iex"
) ELSE (
  echo [1/6] uv already installed.
)

REM Install free-claude-code
echo [2/6] Installing free-claude-code...
uv tool install free-claude-code
echo     fcc-claude and fcc-codex installed.

REM Install LiteLLM
echo [3/6] Setting up LiteLLM...
if not exist "%USERPROFILE%\litellm_proxy" mkdir "%USERPROFILE%\litellm_proxy"
python -m venv "%USERPROFILE%\litellm_proxy\venv"
"%USERPROFILE%\litellm_proxy\venv\Scripts\pip" install litellm[proxy] --quiet
echo     LiteLLM installed.

REM Copy config files
echo [4/6] Copying config files...
if not exist "%USERPROFILE%\litellm_proxy\config.yaml" (
  copy config.example.yaml "%USERPROFILE%\litellm_proxy\config.yaml"
  echo     config.yaml copied. Edit it and replace YOUR_KEY_1..4!
) ELSE (
  echo     config.yaml already exists, skipping.
)

if not exist "%USERPROFILE%\.fcc" mkdir "%USERPROFILE%\.fcc"
if not exist "%USERPROFILE%\.fcc\.env" (
  copy .env.example "%USERPROFILE%\.fcc\.env"
  echo     .env copied.
) ELSE (
  echo     .fcc\.env already exists, skipping.
)

REM Create startup scripts
echo [5/6] Creating Windows startup scripts...
if not exist "%USERPROFILE%\litellm_proxy\start_litellm.bat" (
  echo @echo off > "%USERPROFILE%\litellm_proxy\start_litellm.bat"
  echo "%USERPROFILE%\litellm_proxy\venv\Scripts\litellm" --config "%USERPROFILE%\litellm_proxy\config.yaml" --port 4000 >> "%USERPROFILE%\litellm_proxy\start_litellm.bat"
)

if not exist "%USERPROFILE%\litellm_proxy\start_fcc.bat" (
  echo @echo off > "%USERPROFILE%\litellm_proxy\start_fcc.bat"
  echo timeout /t 5 >> "%USERPROFILE%\litellm_proxy\start_fcc.bat"
  echo fcc-server >> "%USERPROFILE%\litellm_proxy\start_fcc.bat"
)

REM Add to Windows Startup folder
echo [5/6] Adding to Windows Startup...
set STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
copy "%USERPROFILE%\litellm_proxy\start_litellm.bat" "%STARTUP_DIR%\infinite-agents-litellm.bat" >nul
copy "%USERPROFILE%\litellm_proxy\start_fcc.bat" "%STARTUP_DIR%\infinite-agents-fcc.bat" >nul
echo     Startup entries created. Services will auto-start on next login.

REM Start services now
echo [6/6] Starting services...
start /B "" "%USERPROFILE%\litellm_proxy\start_litellm.bat"
timeout /t 5 /nobreak >nul
start /B "" fcc-server

echo.
echo ============================================================
echo   Setup complete!
echo.
echo   NEXT STEP:
echo   Edit: %USERPROFILE%\litellm_proxy\config.yaml
echo   Replace YOUR_KEY_1..4 with real NVIDIA NIM keys
echo   Get free keys: https://build.nvidia.com
echo.
echo   Launch:
echo   fcc-claude   ^<-- Claude Code + Llama 70B
echo   fcc-codex    ^<-- Codex CLI + Mistral 128B
echo.
echo   Inside the agent: type /model then select lmstudio/*
echo ============================================================
pause
