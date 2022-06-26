@echo off
echo WARNING! THIS WILL ALSO DISCARD *ALL* OF YOUR UNCOMMITTED CHANGES
cd ..
pause
echo Reverting codebase
git add .
git reset --hard HEAD
echo.
echo done.
pause