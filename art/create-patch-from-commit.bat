@echo off
echo Creating patch from the latest commit
cd ..\patches\source
set cnt=1
for %%A in (*) do set /a cnt+=1
cd ..\..
git format-patch --start-number %cnt% -o patches/source -1 HEAD
echo.
echo done.
pause
