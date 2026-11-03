@echo off

if not exist dist mkdir dist
if %errorlevel% neq 0 exit /b %errorlevel%

cargo build --release
if %errorlevel% neq 0 exit /b %errorlevel%

cargo test --release
if %errorlevel% neq 0 exit /b %errorlevel%

copy /Y target\release\hello.exe dist\hello.exe >nul
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo All operations completed successfully!
pause