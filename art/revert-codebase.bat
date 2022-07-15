@echo off
echo WARNING! THIS WILL ALSO DISCARD *ALL* OF YOUR UNCOMMITTED CHANGES
cd ..
pause
echo Reverting codebase
set cnt=0
for %%A in ('dir /b patches\source') do set /a cnt+=1
git add .
git reset --hard HEAD~%cnt%
echo.
echo done.
pause