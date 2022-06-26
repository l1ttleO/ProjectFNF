echo Creating patch from the latest commit
cd ..
set cnt=1
for %%A in (*) do set /a cnt+=1
git format-patch --start-number %cnt% -o patches/source -1 HEAD
echo.
echo done.
pause
