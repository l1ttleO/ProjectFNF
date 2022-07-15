@echo off
color 0a
echo YOU NEED GIT INSTALLED TO PROCEED
pause
cd ..
git stash
echo APPLYING PATCHES
for /f %%f in ('dir /b patches\source') do git am patches\source\%%f
xcopy patches\assets assets /S
echo BUILDING GAME
lime build html5 -debug
echo REVERTING CHANGES
git add .
git reset --hard HEAD
git stash pop