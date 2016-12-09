cd %~dp0..
REM call "virtualenv/ENV/Scripts/activate.bat"
echo.
echo.
echo ----- RUNNING CORE ARCHES TESTS -----
echo.

python manage.py test tests --pattern="*.py"

REM call "virtualenv/ENV/Scripts/deactivate.bat"
pause