@echo off
echo Applying existing patches
cd ..
for /f %%f in ('dir /b patches\source') do git am patches\source\%%f
xcopy patches\assets assets /S
echo.
echo done.
pause