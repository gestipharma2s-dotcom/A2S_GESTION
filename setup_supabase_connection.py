#!/usr/bin/env python3
"""
Setup script to configure Supabase database connection details.
Gets the database password from Supabase project settings.
"""

import os
import sys
from pathlib import Path

def setup_supabase_connection():
    """Interactive setup for Supabase database connection."""
    
    print("=" * 70)
    print("SUPABASE DATABASE CONNECTION SETUP")
    print("=" * 70)
    print()
    
    print("To extract your complete database schema, we need your")
    print("Supabase database connection URL.\n")
    
    print("HOW TO GET YOUR CONNECTION URL:")
    print("-" * 70)
    print("Option A: Full Connection String")
    print("  1. Go to: https://app.supabase.io/project/ynoxsibapzatlxhmredp")
    print("  2. Settings → Database → Connection String")
    print("  3. Copy PostgreSQL connection string")
    print("  4. Paste it when prompted\n")
    
    print("Option B: Password Only")
    print("  1. Go to: https://app.supabase.io/project/ynoxsibapzatlxhmredp")
    print("  2. Settings → Database")
    print("  3. Copy the database password")
    print("  4. Enter it when prompted")
    print("  5. We'll construct the connection URL\n")
    
    print("-" * 70)
    print()
    
    # Try to get full connection string first
    full_url = input("Enter full connection string (or press Enter to use password only): ").strip()
    
    if full_url:
        # Validate URL
        if "postgresql://" in full_url:
            connection_string = full_url
        else:
            print("✗ Error: Invalid connection string format")
            print("Expected format: postgresql://user:password@host:port/database")
            return False
    else:
        # Get password instead
        password = input("\nEnter your Supabase database password: ").strip()
        
        if not password:
            print("✗ Error: Password cannot be empty")
            return False
        
        # Create connection string
        host = "db.ynoxsibapzatlxhmredp.supabase.co"
        port = "5432"
        user = "postgres"
        db = "postgres"
        
        connection_string = f"postgresql://{user}:{password}@{host}:{port}/{db}"
    
    # Save to .env file
    env_file = Path(".env.local")
    
    # Read existing .env if it exists
    existing_content = ""
    if env_file.exists():
        with open(env_file, 'r') as f:
            existing_content = f.read()
    
    # Add or update DATABASE_URL
    if "DATABASE_URL=" in existing_content:
        # Replace existing
        lines = existing_content.split('\n')
        lines = [line for line in lines if not line.startswith("DATABASE_URL=")]
        new_content = "\n".join(lines)
    else:
        new_content = existing_content
    
    # Append new DATABASE_URL
    if new_content and not new_content.endswith('\n'):
        new_content += '\n'
    new_content += f"DATABASE_URL={connection_string}\n"
    
    # Write to file
    with open(env_file, 'w') as f:
        f.write(new_content)
    
    print()
    print("✓ Connection details saved to .env.local")
    print()
    
    # Test connection (optional)
    print("Testing connection...")
    try:
        import psycopg2
        conn = psycopg2.connect(connection_string)
        conn.close()
        print("✓ Connection successful!")
        print()
        print("You can now run: python extract_supabase_schema.py")
        return True
    except ImportError:
        print("⚠ psycopg2 not installed. Installing required packages...")
        os.system("pip install psycopg2-binary")
        return True
    except Exception as e:
        print(f"✗ Connection failed: {e}")
        print("\nPlease verify:")
        print("- Password is correct")
        print("- Supabase project is active")
        print("- Database is accessible from your network")
        return False

if __name__ == "__main__":
    setup_supabase_connection()
