@echo off
setlocal
set "HUNDINO_MERCHANT_PY=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\pythonw.exe"
if not exist "%HUNDINO_MERCHANT_PY%" (
  echo Khong tim thay Python di kem Codex. Can Python 3.10 tro len de bat bo luu.
  pause
  exit /b 1
)
start "" "%HUNDINO_MERCHANT_PY%" "%~dp0tools\local-save-server.py"
start "" "%~dp0HunDino_MerchantWeapons_20261026.rbxl"
exit /b 0
