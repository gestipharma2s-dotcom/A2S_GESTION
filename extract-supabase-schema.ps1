#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Supabase Schema Extractor - Complete Database Backup
    
.DESCRIPTION
    Extracts complete Supabase database schema and generates a SQL dump script
    that can recreate the entire database from scratch.
    
.NOTES
    Requires:
    - Python 3.7+
    - pip packages: requests, psycopg2-binary (optional for direct DB access)
#>

param(
    [string]$Method = "api",  # "api" or "direct"
    [string]$OutputFile = "SUPABASE_COMPLETE_SCHEMA_DUMP.sql"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUPABASE SCHEMA EXTRACTOR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is installed
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    Write-Host "✗ Python not found. Please install Python 3.7+" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Python found: " -ForegroundColor Green -NoNewline
$pythonCmd.Source

# Check if .env.local exists
if (-not (Test-Path ".env.local")) {
    Write-Host "✗ .env.local not found" -ForegroundColor Red
    Write-Host "Please ensure you're in the project root directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Configuration file found" -ForegroundColor Green

Write-Host ""
Write-Host "Checking required Python packages..." -ForegroundColor Yellow

# Install required packages
try {
    python -m pip install requests psycopg2-binary -q
    Write-Host "✓ Dependencies installed/verified" -ForegroundColor Green
} catch {
    Write-Host "⚠ Warning: Could not install all dependencies" -ForegroundColor Yellow
}

Write-Host ""

# Run the extractor
Write-Host "Starting schema extraction using $Method method..." -ForegroundColor Yellow
Write-Host ""

if ($Method -eq "api") {
    python extract_schema_via_api.py
} else {
    Write-Host "Setting up database connection..." -ForegroundColor Yellow
    python setup_supabase_connection.py
    Write-Host ""
    python extract_supabase_schema.py
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EXTRACTION COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $OutputFile) {
    $fileSize = (Get-Item $OutputFile).Length / 1KB
    Write-Host "✓ Schema dump file: $OutputFile" -ForegroundColor Green
    Write-Host "  Size: $([Math]::Round($fileSize, 2)) KB" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "1. Review the generated SQL file in an editor" -ForegroundColor White
    Write-Host "2. Backup the file to a safe location" -ForegroundColor White
    Write-Host "3. To restore on a new database, use:" -ForegroundColor White
    Write-Host "   psql -d new_database_name -f $OutputFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "SECURITY NOTE:" -ForegroundColor Yellow
    Write-Host "- Keep this file secure - it contains your database schema" -ForegroundColor White
    Write-Host "- Consider removing any sensitive default values before sharing" -ForegroundColor White
} else {
    Write-Host "✗ Output file not generated. Check errors above." -ForegroundColor Red
}
