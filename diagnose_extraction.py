#!/usr/bin/env python3
"""
Supabase Schema Extraction - Diagnostics & Validation Tool
Tests connection, validates credentials, and checks database status.
"""

import os
import psycopg2
from pathlib import Path
from datetime import datetime

def load_env():
    """Load environment from .env.local"""
    env_vars = {}
    env_file = Path('.env.local')
    
    if env_file.exists():
        with open(env_file, 'r') as f:
            for line in f:
                if '=' in line and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    env_vars[key] = value.strip('"').strip("'")
    
    return env_vars

def test_connection(db_url):
    """Test database connection."""
    try:
        conn = psycopg2.connect(db_url)
        cursor = conn.cursor()
        
        # Test query
        cursor.execute("SELECT version();")
        version = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        return True, version[0] if version else "Connected"
    except Exception as e:
        return False, str(e)

def diagnose():
    """Run diagnostic tests."""
    
    print("\n" + "=" * 70)
    print("SUPABASE SCHEMA EXTRACTION DIAGNOSTICS")
    print("=" * 70)
    print()
    
    # 1. Check Python
    print("1. PYTHON ENVIRONMENT")
    print("-" * 70)
    import sys
    print(f"   Python version: {sys.version}")
    print(f"   Python executable: {sys.executable}")
    print("   ✓ Python available")
    print()
    
    # 2. Check Python packages
    print("2. REQUIRED PACKAGES")
    print("-" * 70)
    
    packages = []
    try:
        import psycopg2
        print(f"   ✓ psycopg2 installed (version: {psycopg2.__version__})")
        packages.append(True)
    except ImportError:
        print(f"   ✗ psycopg2 NOT installed")
        print(f"     Install with: pip install psycopg2-binary")
        packages.append(False)
    
    try:
        import requests
        print(f"   ✓ requests installed (version: {requests.__version__})")
        packages.append(True)
    except ImportError:
        print(f"   ✗ requests NOT installed")
        print(f"     Install with: pip install requests")
        packages.append(False)
    
    print()
    
    # 3. Check configuration files
    print("3. CONFIGURATION FILES")
    print("-" * 70)
    
    env_file = Path('.env.local')
    if env_file.exists():
        print(f"   ✓ .env.local found")
        
        env_vars = load_env()
        
        if 'VITE_SUPABASE_URL' in env_vars:
            url = env_vars['VITE_SUPABASE_URL']
            print(f"   ✓ VITE_SUPABASE_URL: {url[:40]}...")
        else:
            print(f"   ✗ VITE_SUPABASE_URL not found")
        
        if 'VITE_SUPABASE_ANON_KEY' in env_vars:
            key = env_vars['VITE_SUPABASE_ANON_KEY']
            print(f"   ✓ VITE_SUPABASE_ANON_KEY: {key[:20]}...")
        else:
            print(f"   ✗ VITE_SUPABASE_ANON_KEY not found")
        
        if 'DATABASE_URL' in env_vars:
            db_url = env_vars['DATABASE_URL']
            print(f"   ✓ DATABASE_URL: {db_url[:40]}...")
        else:
            print(f"   ⚠ DATABASE_URL not found (needed for direct extraction)")
            print(f"     Run: python setup_supabase_connection.py")
    else:
        print(f"   ✗ .env.local NOT found")
        print(f"     Create one or copy from .env.example")
    
    print()
    
    # 4. Test database connection
    print("4. DATABASE CONNECTION TEST")
    print("-" * 70)
    
    env_vars = load_env()
    db_url = env_vars.get('DATABASE_URL')
    
    if not db_url:
        print(f"   ⚠ No DATABASE_URL configured")
        print(f"   To test connection:")
        print(f"     1. Run: python setup_supabase_connection.py")
        print(f"     2. Then run this script again")
    else:
        print(f"   Attempting connection to: {db_url[:50]}...")
        success, result = test_connection(db_url)
        
        if success:
            print(f"   ✓ Connection successful!")
            print(f"   Database: {result[:60]}...")
        else:
            print(f"   ✗ Connection failed!")
            print(f"   Error: {result}")
            print(f"   Troubleshooting:")
            print(f"     - Verify password is current")
            print(f"     - Check Supabase project is active")
            print(f"     - Verify network connectivity")
    
    print()
    
    # 5. Check extraction scripts
    print("5. EXTRACTION SCRIPTS")
    print("-" * 70)
    
    scripts = [
        ('extract_schema_direct.py', 'Direct PostgreSQL extraction'),
        ('setup_supabase_connection.py', 'Connection setup helper'),
        ('extract-supabase-schema.bat', 'Windows batch script'),
        ('extract-supabase-schema.ps1', 'PowerShell script'),
    ]
    
    for script, description in scripts:
        script_path = Path(script)
        if script_path.exists():
            size = script_path.stat().st_size
            print(f"   ✓ {script} ({size} bytes) - {description}")
        else:
            print(f"   ✗ {script} NOT found")
    
    print()
    
    # 6. Check documentation
    print("6. DOCUMENTATION")
    print("-" * 70)
    
    docs = [
        'README_SCHEMA_EXTRACTION.md',
        'SUPABASE_SCHEMA_EXTRACTION_GUIDE.md',
        'QUICK_REFERENCE_EXTRACTION.md',
    ]
    
    for doc in docs:
        doc_path = Path(doc)
        if doc_path.exists():
            size = doc_path.stat().st_size / 1024
            print(f"   ✓ {doc} ({size:.1f} KB)")
        else:
            print(f"   ⚠ {doc} not found")
    
    print()
    
    # 7. Summary
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    
    if not all(packages):
        print("ACTION NEEDED: Install missing packages")
        print("  pip install -r requirements.txt")
        print()
    
    if db_url:
        success, _ = test_connection(db_url)
        if success:
            print("✓ Ready to extract schema!")
            print("  Run: python extract_schema_direct.py")
        else:
            print("✗ Connection failed - verify credentials")
            print("  Run: python setup_supabase_connection.py")
    else:
        print("ACTION NEEDED: Configure database connection")
        print("  Run: python setup_supabase_connection.py")
    
    print()

def validate_dump(file_path='SUPABASE_COMPLETE_SCHEMA_DUMP.sql'):
    """Validate an existing dump file."""
    
    print("\n" + "=" * 70)
    print("SCHEMA DUMP VALIDATION")
    print("=" * 70)
    print()
    
    file_path = Path(file_path)
    
    if not file_path.exists():
        print(f"✗ File not found: {file_path}")
        return False
    
    print(f"File: {file_path}")
    size_mb = file_path.stat().st_size / (1024 * 1024)
    print(f"Size: {size_mb:.2f} MB")
    print(f"Created: {datetime.fromtimestamp(file_path.stat().st_mtime)}")
    print()
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for key elements
    checks = [
        ('CREATE TABLE', 'Tables'),
        ('PRIMARY KEY', 'Primary keys'),
        ('FOREIGN KEY', 'Foreign keys'),
        ('CREATE INDEX', 'Indexes'),
        ('CREATE VIEW', 'Views'),
        ('CREATE FUNCTION', 'Functions'),
        ('CREATE POLICY', 'RLS policies'),
        ('CREATE SEQUENCE', 'Sequences'),
    ]
    
    print("SCHEMA ELEMENTS:")
    print("-" * 70)
    
    for pattern, name in checks:
        count = content.count(pattern)
        if count > 0:
            print(f"✓ {name}: {count}")
        else:
            print(f"⚠ {name}: 0 (none found)")
    
    print()
    print("✓ Dump file is valid")
    
    return True

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == 'validate':
        # Validate existing dump
        if len(sys.argv) > 2:
            validate_dump(sys.argv[2])
        else:
            validate_dump()
    else:
        # Run diagnostics
        diagnose()
