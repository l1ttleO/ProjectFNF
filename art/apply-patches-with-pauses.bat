@echo off
echo Applying existing patches
cd ..
for /f %%f in ('dir /b patches\source') do (
	git am -3 patches\source\%%f
	pause
)
xcopy patches\assets assets /S
echo.
echo done.
pause