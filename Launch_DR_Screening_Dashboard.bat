@echo off
title RETINACARE AI - Launching Dashboard...
echo =======================================================================
echo   RETINACARE AI : RURAL TELE-OPHTHALMOLOGY SCREENING SUITE
echo   Starting MATLAB and launching interactive screening dashboard...
echo =======================================================================

cd /d "%~dp0"

:: 1. Try matlab command directly from system PATH
where matlab >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Launching with MATLAB from system PATH...
    start "" matlab -sd "%~dp0" -r "dr_screening_gui"
    exit /b 0
)

:: 2. Try common MATLAB installation paths
for %%V in (R2026b R2026a R2025b R2025a R2024b R2024a R2023b R2023a R2022b R2022a R2021b R2021a) do (
    if exist "C:\Program Files\MATLAB\%%V\bin\matlab.exe" (
        echo Found MATLAB %%V at C:\Program Files\MATLAB\%%V\bin\matlab.exe
        start "" "C:\Program Files\MATLAB\%%V\bin\matlab.exe" -sd "%~dp0" -r "dr_screening_gui"
        exit /b 0
    )
)

echo ERROR: MATLAB installation not found in PATH or standard Program Files locations.
echo Please start MATLAB manually, navigate to this folder, and run: dr_screening_gui
pause

