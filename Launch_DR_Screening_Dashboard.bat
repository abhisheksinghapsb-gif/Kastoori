@echo off
title RETINACARE AI - Launching Dashboard...
echo =======================================================================
echo   RETINACARE AI : RURAL TELE-OPHTHALMOLOGY SCREENING SUITE
echo   Starting MATLAB and launching interactive screening dashboard...
echo =======================================================================
cd /d "g:\sih_backup"
"C:\Program Files\MATLAB\R2026a\bin\matlab.exe" -sd "g:\sih_backup" -r "dr_screening_dashboard"
pause
