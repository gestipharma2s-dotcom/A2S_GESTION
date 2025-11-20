@echo off
REM ===============================================================
REM SUPABASE SCHEMA EXTRACTOR - Windows Batch Script
REM ===============================================================
REM This script automates the complete Supabase schema extraction
REM process on Windows systems without requiring PowerShell.

setlocal enabledelayedexpansion

title Supabase Schema Extractor

echo.
echo ===============================================================
echo SUPABASE COMPLETE DATABASE SCHEMA EXTRACTOR
echo ===============================================================
echo.
echo Project: A2S GESTION
echo Supabase Project: ynoxsibapzatlxhmredp
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found
    echo.
    echo Please install Python 3.7 or higher from: https://www.python.org
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

echo [OK] Python is installed
python --version

REM Check if .env.local exists
if not exist ".env.local" (
    echo.
    echo [ERROR] .env.local not found
    echo Please ensure you're in the project root directory
    echo.
    pause
    exit /b 1
)

echo [OK] Configuration file found

echo.
echo Installing/verifying required packages...

REM Install dependencies
python -m pip install requests psycopg2-binary -q
if %errorlevel% neq 0 (
    echo [WARNING] Could not install all dependencies
    echo Attempting to continue...
)

echo [OK] Dependencies ready

echo.
echo ===============================================================
echo EXTRACTION OPTIONS
echo ===============================================================
echo.
echo 1. Setup connection (first time only)
echo 2. Extract schema with existing connection
echo 3. Exit
echo.

set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo.
    echo Running connection setup...
    python setup_supabase_connection.py
    if %errorlevel% neq 0 (
        echo [ERROR] Setup failed
        pause
        exit /b 1
    )
    echo.
    echo Now running extraction...
    timeout /t 2 /nobreak
)

if "%choice%"=="2" goto extract
if "%choice%"=="3" (
    echo Exiting...
    exit /b 0
)

if not "%choice%"=="1" (
    echo Invalid choice
    pause
    exit /b 1
)

:extract
echo.
echo ===============================================================
echo EXTRACTING DATABASE SCHEMA
echo ===============================================================
echo.

python extract_schema_direct.py

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Extraction failed
    echo Please check the error messages above
    echo.
    pause
    exit /b 1
)

echo.
echo ===============================================================
echo EXTRACTION COMPLETE
echo ===============================================================
echo.

REM Check if output file exists
if exist "SUPABASE_COMPLETE_SCHEMA_DUMP.sql" (
    for %%F in (SUPABASE_COMPLETE_SCHEMA_DUMP.sql) do set "size=%%~zF"
    set /a size_kb=!size!/1024
    
    echo [OK] Schema dump generated successfully
    echo.
    echo File: SUPABASE_COMPLETE_SCHEMA_DUMP.sql
    echo Size: !size_kb! KB
    echo.
    
    echo NEXT STEPS:
    echo.
    echo 1. Review the generated SQL file in a text editor
    echo 2. Backup the file to a secure location
    echo 3. To restore on a new database, use:
    echo.
    echo    psql -d new_database -f SUPABASE_COMPLETE_SCHEMA_DUMP.sql
    echo.
    echo Or use Supabase Web Console:
    echo    - SQL Editor
    echo    - New query
    echo    - Paste entire file content
    echo    - Execute
    echo.
    
    REM Ask to open file
    set /p open_file="Open the SQL file now? (y/n): "
    if /i "%open_file%"=="y" (
        start notepad SUPABASE_COMPLETE_SCHEMA_DUMP.sql
    )
) else (
    echo [ERROR] Output file not found
    echo Extraction may have failed
    echo.
)

echo.
echo Press any key to exit...
pause >nul

endlocal
exit /b 0
