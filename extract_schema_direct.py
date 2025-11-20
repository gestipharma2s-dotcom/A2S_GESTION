#!/usr/bin/env python3
"""
Supabase Schema Extractor - Direct PostgreSQL Connection Method
Uses psycopg2 to connect directly to Supabase PostgreSQL database.
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
import json
from pathlib import Path

def load_env():
    """Load environment variables from .env.local"""
    env_vars = {}
    env_file = Path('.env.local')
    
    if not env_file.exists():
        print("✗ .env.local not found")
        return None
    
    with open(env_file, 'r') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                env_vars[key] = value.strip('"').strip("'")
    
    return env_vars

def connect_to_supabase():
    """Connect to Supabase PostgreSQL database."""
    
    env_vars = load_env()
    if not env_vars:
        return None
    
    # Check for DATABASE_URL first (for direct connection)
    db_url = env_vars.get('DATABASE_URL')
    
    if not db_url:
        print("\n⚠ DATABASE_URL not found in .env.local")
        print("\nTo use direct connection method:")
        print("1. Go to https://app.supabase.io/project/ynoxsibapzatlxhmredp/settings/database")
        print("2. Copy the full PostgreSQL connection string")
        print("3. Add to .env.local: DATABASE_URL=postgresql://...")
        
        # Alternative: construct from environment
        supabase_url = env_vars.get('VITE_SUPABASE_URL')
        if supabase_url and 'supabase' in supabase_url:
            project_id = supabase_url.split('//')[1].split('.')[0]
            print(f"\nYour project ID: {project_id}")
            print(f"Connection format: postgresql://postgres:[PASSWORD]@db.{project_id}.supabase.co:5432/postgres")
        
        return None, env_vars
    
    try:
        print(f"Connecting to Supabase database...")
        conn = psycopg2.connect(db_url)
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        print("✓ Connected successfully")
        return conn, env_vars
    except Exception as e:
        print(f"✗ Connection failed: {e}")
        print("\nPlease verify:")
        print("- DATABASE_URL is correct")
        print("- Password is current")
        print("- Supabase project is active")
        return None, env_vars

def get_tables(cursor):
    """Get all tables."""
    query = """
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
    ORDER BY table_name;
    """
    cursor.execute(query)
    return [row['table_name'] for row in cursor.fetchall()]

def get_table_schema(cursor, table_name):
    """Get complete schema for a table."""
    
    section = f"\n-- ======================================================\n"
    section += f"-- TABLE: {table_name}\n"
    section += f"-- ======================================================\n\n"
    section += f"DROP TABLE IF EXISTS {table_name} CASCADE;\n\n"
    section += f"CREATE TABLE {table_name} (\n"
    
    # Get columns
    col_query = """
    SELECT 
        c.column_name,
        c.data_type,
        c.character_maximum_length,
        c.numeric_precision,
        c.numeric_scale,
        c.is_nullable,
        c.column_default,
        c.ordinal_position,
        c.udt_name
    FROM information_schema.columns c
    WHERE c.table_schema = 'public' AND c.table_name = %s
    ORDER BY c.ordinal_position;
    """
    
    cursor.execute(col_query, (table_name,))
    columns = cursor.fetchall()
    
    col_defs = []
    for col in columns:
        col_def = f"    {col['column_name']} "
        
        # Map data types
        data_type = col['data_type']
        udt_name = col['udt_name']
        
        if data_type == 'character varying':
            col_def += f"VARCHAR({col['character_maximum_length'] or 255})"
        elif data_type == 'timestamp without time zone':
            col_def += "TIMESTAMP"
        elif data_type == 'timestamp with time zone':
            col_def += "TIMESTAMPTZ"
        elif data_type == 'numeric':
            precision = col['numeric_precision'] or 10
            scale = col['numeric_scale'] or 0
            col_def += f"NUMERIC({precision},{scale})"
        elif data_type == 'ARRAY':
            col_def += f"{udt_name}[]"
        else:
            col_def += data_type
        
        # Add NOT NULL
        if col['is_nullable'] == 'NO':
            col_def += " NOT NULL"
        
        # Add DEFAULT
        if col['column_default']:
            col_def += f" DEFAULT {col['column_default']}"
        
        col_defs.append(col_def)
    
    # Primary keys
    pk_query = """
    SELECT constraint_name, string_agg(column_name, ', ' ORDER BY ordinal_position) as columns
    FROM information_schema.constraint_column_usage
    WHERE table_schema = 'public' 
    AND table_name = %s
    AND (constraint_name LIKE '%pkey' OR constraint_name LIKE 'pk_%')
    GROUP BY constraint_name;
    """
    
    cursor.execute(pk_query, (table_name,))
    pk_result = cursor.fetchone()
    if pk_result and pk_result['columns']:
        col_defs.append(f"    PRIMARY KEY ({pk_result['columns']})")
    
    # Unique constraints
    uc_query = """
    SELECT constraint_name, string_agg(column_name, ', ' ORDER BY ordinal_position) as columns
    FROM information_schema.constraint_column_usage
    WHERE table_schema = 'public' 
    AND table_name = %s
    AND constraint_name LIKE '%unique%'
    GROUP BY constraint_name;
    """
    
    cursor.execute(uc_query, (table_name,))
    unique_constraints = cursor.fetchall()
    for uc in unique_constraints:
        if uc['columns']:
            col_defs.append(f"    UNIQUE ({uc['columns']})")
    
    # Foreign keys
    fk_query = """
    SELECT 
        kcu1.constraint_name,
        kcu1.column_name,
        kcu2.table_name as referenced_table,
        kcu2.column_name as referenced_column,
        rc.delete_rule,
        rc.update_rule
    FROM information_schema.referential_constraints rc
    JOIN information_schema.key_column_usage kcu1 
        ON rc.constraint_name = kcu1.constraint_name
        AND kcu1.table_schema = rc.constraint_schema
    JOIN information_schema.key_column_usage kcu2 
        ON rc.unique_constraint_name = kcu2.constraint_name
        AND kcu2.table_schema = rc.unique_constraint_schema
    WHERE kcu1.table_schema = 'public' AND kcu1.table_name = %s;
    """
    
    cursor.execute(fk_query, (table_name,))
    fks = cursor.fetchall()
    for fk in fks:
        fk_def = f"    CONSTRAINT {fk['constraint_name']} FOREIGN KEY ({fk['column_name']}) "
        fk_def += f"REFERENCES {fk['referenced_table']} ({fk['referenced_column']})"
        if fk['delete_rule'] != 'NO ACTION':
            fk_def += f" ON DELETE {fk['delete_rule']}"
        if fk['update_rule'] != 'NO ACTION':
            fk_def += f" ON UPDATE {fk['update_rule']}"
        col_defs.append(fk_def)
    
    section += ",\n".join(col_defs)
    section += "\n);\n\n"
    
    # Enable RLS
    section += f"ALTER TABLE {table_name} ENABLE ROW LEVEL SECURITY;\n\n"
    
    # Indexes
    idx_query = """
    SELECT indexname, indexdef
    FROM pg_indexes
    WHERE schemaname = 'public' AND tablename = %s
    AND indexname NOT LIKE '%_pkey';
    """
    
    cursor.execute(idx_query, (table_name,))
    indexes = cursor.fetchall()
    if indexes:
        section += f"-- Indexes\n"
        for idx in indexes:
            section += f"{idx['indexdef']};\n"
        section += "\n"
    
    # Triggers
    trigger_query = """
    SELECT trigger_name, event_manipulation, action_timing, action_statement
    FROM information_schema.triggers
    WHERE event_object_schema = 'public' AND event_object_table = %s;
    """
    
    cursor.execute(trigger_query, (table_name,))
    triggers = cursor.fetchall()
    if triggers:
        section += f"-- Triggers\n"
        for trigger in triggers:
            section += f"-- {trigger['trigger_name']}: {trigger['event_manipulation']} {trigger['action_timing']}\n"
        section += "\n"
    
    return section

def get_views(cursor):
    """Get all views."""
    query = """
    SELECT table_name, view_definition
    FROM information_schema.views
    WHERE table_schema = 'public'
    ORDER BY table_name;
    """
    
    cursor.execute(query)
    return cursor.fetchall()

def get_functions(cursor):
    """Get all user-defined functions."""
    query = """
    SELECT 
        p.proname as function_name,
        pg_get_functiondef(p.oid) as definition
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
    AND NOT p.proisagg
    ORDER BY p.proname;
    """
    
    cursor.execute(query)
    return cursor.fetchall()

def get_sequences(cursor):
    """Get all sequences."""
    query = """
    SELECT 
        sequence_schema,
        sequence_name,
        data_type,
        start_value,
        minimum_value,
        maximum_value,
        increment,
        cycle_option
    FROM information_schema.sequences
    WHERE sequence_schema = 'public'
    ORDER BY sequence_name;
    """
    
    cursor.execute(query)
    return cursor.fetchall()

def get_policies(cursor):
    """Get all RLS policies."""
    query = """
    SELECT 
        tablename,
        policyname,
        permissive,
        roles,
        qual,
        with_check
    FROM pg_policies
    WHERE schemaname = 'public'
    ORDER BY tablename, policyname;
    """
    
    cursor.execute(query)
    return cursor.fetchall()

def generate_sql_dump(cursor, output_file):
    """Generate complete SQL dump."""
    
    with open(output_file, 'w', encoding='utf-8') as f:
        # Header
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        f.write(f"""-- ===============================================================
-- SUPABASE COMPLETE DATABASE SCHEMA DUMP
-- Generated: {timestamp}
-- Project: ynoxsibapzatlxhmredp
-- Database: postgres
-- ===============================================================
-- This script recreates the entire database structure from scratch.
-- Includes: tables, constraints, indexes, functions, views, and RLS.
-- ===============================================================

-- Disable foreign key checks during import
SET session_replication_role = replica;

""")
        
        # Sequences
        print("  - Extracting sequences...")
        sequences = get_sequences(cursor)
        if sequences:
            f.write("-- ===============================================================\n")
            f.write("-- SEQUENCES\n")
            f.write("-- ===============================================================\n\n")
            for seq in sequences:
                f.write(f"CREATE SEQUENCE IF NOT EXISTS {seq['sequence_name']}\n")
                f.write(f"    AS {seq['data_type']}\n")
                f.write(f"    START WITH {seq['start_value']}\n")
                f.write(f"    INCREMENT BY {seq['increment']}\n")
                f.write(f"    MINVALUE {seq['minimum_value']}\n")
                f.write(f"    MAXVALUE {seq['maximum_value']}\n")
                if seq['cycle_option'] == 'YES':
                    f.write(f"    CYCLE\n")
                f.write(";\n\n")
        
        # Tables
        print("  - Extracting tables...")
        tables = get_tables(cursor)
        if tables:
            f.write("-- ===============================================================\n")
            f.write("-- TABLES\n")
            f.write("-- ===============================================================\n")
            for table in tables:
                print(f"    • {table}")
                f.write(get_table_schema(cursor, table))
        
        # Views
        print("  - Extracting views...")
        views = get_views(cursor)
        if views:
            f.write("\n-- ===============================================================\n")
            f.write("-- VIEWS\n")
            f.write("-- ===============================================================\n\n")
            for view in views:
                f.write(f"DROP VIEW IF EXISTS {view['table_name']} CASCADE;\n")
                f.write(f"CREATE VIEW {view['table_name']} AS\n")
                f.write(f"{view['view_definition']};\n\n")
        
        # Functions
        print("  - Extracting functions...")
        functions = get_functions(cursor)
        if functions:
            f.write("\n-- ===============================================================\n")
            f.write("-- FUNCTIONS AND PROCEDURES\n")
            f.write("-- ===============================================================\n\n")
            for func in functions:
                f.write(f"-- Function: {func['function_name']}\n")
                f.write(f"{func['definition']};\n\n")
        
        # RLS Policies
        print("  - Extracting RLS policies...")
        policies = get_policies(cursor)
        if policies:
            f.write("\n-- ===============================================================\n")
            f.write("-- ROW LEVEL SECURITY POLICIES\n")
            f.write("-- ===============================================================\n")
            
            current_table = None
            for policy in policies:
                if policy['tablename'] != current_table:
                    current_table = policy['tablename']
                    f.write(f"\n-- Policies for {current_table}\n")
                
                f.write(f"\nCREATE POLICY {policy['policyname']} ON {current_table}\n")
                f.write(f"    AS {'PERMISSIVE' if policy['permissive'] else 'RESTRICTIVE'}\n")
                f.write(f"    FOR ALL\n")
                f.write(f"    TO {policy['roles'] or 'public'}\n")
                
                if policy['qual']:
                    f.write(f"    USING ({policy['qual']})\n")
                if policy['with_check']:
                    f.write(f"    WITH CHECK ({policy['with_check']})\n")
                
                f.write(";\n")
        
        # Footer
        f.write(f"""

-- ===============================================================
-- FINALIZATION
-- ===============================================================

-- Re-enable foreign key checks
SET session_replication_role = DEFAULT;

-- Grant permissions (customize as needed)
-- GRANT USAGE ON SCHEMA public TO authenticated, anon;
-- GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- ===============================================================
-- END OF SCHEMA DUMP
-- Generated: {timestamp}
-- ===============================================================
""")

def main():
    """Main execution."""
    
    print("\n" + "=" * 70)
    print("SUPABASE COMPLETE DATABASE SCHEMA EXTRACTOR")
    print("=" * 70 + "\n")
    
    conn, env_vars = connect_to_supabase()
    
    if not conn:
        print("\n⚠ Using fallback: Manual setup required")
        print("\nRun the setup script first:")
        print("  python setup_supabase_connection.py")
        return False
    
    try:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        print("\nExtracting schema...")
        output_file = "SUPABASE_COMPLETE_SCHEMA_DUMP.sql"
        
        generate_sql_dump(cursor, output_file)
        
        cursor.close()
        conn.close()
        
        # Get file info
        file_size = os.path.getsize(output_file) / 1024
        
        print(f"\n✓ Schema extraction complete!")
        print(f"✓ Output file: {output_file}")
        print(f"✓ File size: {file_size:.2f} KB")
        
        print("\n" + "=" * 70)
        print("NEXT STEPS")
        print("=" * 70)
        print("1. Review the generated SQL file")
        print("2. Backup to a secure location")
        print("3. To restore on a new database:")
        print(f"   psql -d new_database -f {output_file}")
        print()
        
        return True
        
    except Exception as e:
        print(f"\n✗ Error: {e}")
        return False
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
