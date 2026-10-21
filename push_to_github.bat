@echo off
title Push Intent Bubble to GitHub
echo ========================================================
echo Dang day ma nguon len GitHub: https://github.com/HatoriNguyen/intentbubble
echo ========================================================

cd /d "C:\Users\Hoang Thong\.gemini\antigravity-ide\scratch\intent-bubble-cp3"
"C:\Program Files\Git\cmd\git.exe" push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo DAY LEN GITHUB THANH CONG!
    echo Trang web se hoat dong tai: https://hatoringuyen.github.io/intentbubble/
    echo ========================================================
) else (
    echo.
    echo ========================================================
    echo LUU Y: Neu bao loi 404 hoac repository not found,
    echo ban hay tao repo trong tren GitHub: https://github.com/new
    echo dat ten la: intentbubble (chon Public va khong tao README)
    echo sau do chay lai file nay!
    echo ========================================================
)

pause
