#!/usr/bin/env python3
"""
Supabase Schema Extractor via SQL Editor API
Alternative method that uses Supabase Management API to extract schema
without needing direct database password access.
"""

import requests
import json
import os
from typing import List, Dict, Any
from datetime import datetime
import base64

class SupabaseSQLExtractor:
    """Extract schema using Supabase Management APIs."""
    
    def __init__(self, project_url: str, anon_key: str, service_role_key: str = None):
        """Initialize with Supabase credentials."""
        self.project_url = project_url
        self.anon_key = anon_key
        self.service_role_key = service_role_key or anon_key
        self.headers = {
            'Authorization': f'Bearer {self.service_role_key}',
            'Content-Type': 'application/json',
            'apikey': self.anon_key
        }
    
    def execute_sql(self, query: str) -> List[Dict]:
        """Execute SQL query via Supabase SQL Editor API."""
        url = f"{self.project_url}/rest/v1/rpc/sql"
        
        payload = {
            "query": query
        }
        
        try:
            response = requests.post(
                url,
                headers=self.headers,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                print(f"✗ SQL Error: {response.status_code} - {response.text}")
                return []
        except Exception as e:
            print(f"✗ Request failed: {e}")
            return []
    
    def get_tables_via_sql(self) -> List[str]:
        """Get all tables using SQL."""
        query = """
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name;
        """
        
        try:
            results = self.execute_sql(query)
            return [row['table_name'] for row in results if results]
        except:
            return []
    
    def extract_complete_schema(self, output_file: str = "supabase_schema_dump.sql"):
        """Extract complete schema using multiple SQL queries."""
        
        print("=" * 70)
        print("SUPABASE COMPLETE DATABASE SCHEMA EXTRACTION")
        print("=" * 70)
        print()
        
        sql_dump = self._generate_header()
        
        # Get all tables
        print("Extracting tables...")
        tables = self.get_tables_via_sql()
        
        if not tables:
            print("✗ No tables found or unable to connect to database")
            print("\nTroubleshooting:")
            print("1. Verify VITE_SUPABASE_URL in .env.local")
            print("2. Check that your Supabase project is active")
            print("3. Ensure your project allows API access")
            return False
        
        print(f"✓ Found {len(tables)} tables")
        
        # Generate table schemas
        for table in tables:
            print(f"  - Extracting schema for: {table}")
            sql_dump += self._generate_table_schema(table)
        
        # Get views
        print("Extracting views...")
        sql_dump += self._generate_views_schema()
        
        # Get functions
        print("Extracting functions...")
        sql_dump += self._generate_functions_schema()
        
        # Get policies
        print("Extracting RLS policies...")
        sql_dump += self._generate_policies_schema()
        
        sql_dump += self._generate_footer()
        
        # Write to file
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(sql_dump)
        
        print()
        print(f"✓ Schema dump saved to: {output_file}")
        return True
    
    def _generate_header(self) -> str:
        """Generate SQL dump header."""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        return f"""-- ===============================================================
-- SUPABASE COMPLETE DATABASE SCHEMA DUMP
-- Generated: {timestamp}
-- Project: ynoxsibapzatlxhmredp
-- ===============================================================
-- This script recreates the entire database structure including:
-- - Tables with all columns, types, and constraints
-- - Primary and foreign keys
-- - Unique constraints
-- - Indexes
-- - Views
-- - Functions and procedures
-- - Row Level Security (RLS) policies
-- ===============================================================

-- Start fresh: disable foreign key checks
SET session_replication_role = replica;

"""
    
    def _generate_table_schema(self, table_name: str) -> str:
        """Generate CREATE TABLE statement for a table."""
        section = f"\n-- ======================================================\n"
        section += f"-- TABLE: {table_name}\n"
        section += f"-- ======================================================\n\n"
        
        # Get column information
        col_query = f"""
        SELECT 
            c.column_name,
            c.data_type,
            c.character_maximum_length,
            c.numeric_precision,
            c.numeric_scale,
            c.is_nullable,
            c.column_default,
            c.ordinal_position
        FROM information_schema.columns c
        WHERE c.table_schema = 'public' AND c.table_name = '{table_name}'
        ORDER BY c.ordinal_position;
        """
        
        section += f"DROP TABLE IF EXISTS {table_name} CASCADE;\n\n"
        section += f"CREATE TABLE {table_name} (\n"
        
        try:
            columns = self.execute_sql(col_query)
            
            col_defs = []
            for col in columns:
                col_def = f"    {col['column_name']} "
                
                # Map data types
                data_type = col['data_type']
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
                else:
                    col_def += data_type
                
                # Add NOT NULL
                if col['is_nullable'] == 'NO':
                    col_def += " NOT NULL"
                
                # Add DEFAULT
                if col['column_default']:
                    col_def += f" DEFAULT {col['column_default']}"
                
                col_defs.append(col_def)
            
            section += ",\n".join(col_defs)
            section += "\n);\n\n"
            
            # Get and add constraints
            section += self._add_table_constraints(table_name)
            
            # Get and add indexes
            section += self._add_table_indexes(table_name)
            
            # Enable RLS
            section += f"ALTER TABLE {table_name} ENABLE ROW LEVEL SECURITY;\n\n"
            
        except Exception as e:
            section += f"-- Error extracting columns: {e}\n"
        
        return section
    
    def _add_table_constraints(self, table_name: str) -> str:
        """Add constraints (PK, FK, UNIQUE) for a table."""
        section = ""
        
        # Primary Keys
        pk_query = f"""
        SELECT constraint_name, string_agg(column_name, ', ' ORDER BY ordinal_position) as columns
        FROM information_schema.constraint_column_usage
        WHERE table_schema = 'public' 
        AND table_name = '{table_name}'
        AND (constraint_name LIKE '%pkey' OR constraint_name LIKE 'pk_%')
        GROUP BY constraint_name;
        """
        
        try:
            pks = self.execute_sql(pk_query)
            if pks and len(pks) > 0:
                for pk in pks:
                    section += f"ALTER TABLE {table_name} ADD PRIMARY KEY ({pk['columns']});\n"
        except:
            pass
        
        # Foreign Keys
        fk_query = f"""
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
        JOIN information_schema.key_column_usage kcu2 
            ON rc.unique_constraint_name = kcu2.constraint_name
        WHERE kcu1.table_schema = 'public' AND kcu1.table_name = '{table_name}';
        """
        
        try:
            fks = self.execute_sql(fk_query)
            if fks and len(fks) > 0:
                section += "\n-- Foreign Keys\n"
                for fk in fks:
                    section += f"ALTER TABLE {table_name}\n"
                    section += f"    ADD CONSTRAINT {fk['constraint_name']}\n"
                    section += f"    FOREIGN KEY ({fk['column_name']})\n"
                    section += f"    REFERENCES {fk['referenced_table']} ({fk['referenced_column']})"
                    
                    if fk['delete_rule'] != 'NO ACTION':
                        section += f"\n    ON DELETE {fk['delete_rule']}"
                    if fk['update_rule'] != 'NO ACTION':
                        section += f"\n    ON UPDATE {fk['update_rule']}"
                    
                    section += ";\n"
        except:
            pass
        
        return section
    
    def _add_table_indexes(self, table_name: str) -> str:
        """Add indexes for a table."""
        section = ""
        
        idx_query = f"""
        SELECT indexname, indexdef
        FROM pg_indexes
        WHERE schemaname = 'public' AND tablename = '{table_name}'
        AND indexname NOT LIKE '%_pkey';
        """
        
        try:
            indexes = self.execute_sql(idx_query)
            if indexes and len(indexes) > 0:
                section += "\n-- Indexes\n"
                for idx in indexes:
                    section += f"{idx['indexdef']};\n"
                section += "\n"
        except:
            pass
        
        return section
    
    def _generate_views_schema(self) -> str:
        """Generate CREATE VIEW statements."""
        section = """
-- ======================================================
-- VIEWS
-- ======================================================

"""
        
        view_query = """
        SELECT table_name, view_definition
        FROM information_schema.views
        WHERE table_schema = 'public'
        ORDER BY table_name;
        """
        
        try:
            views = self.execute_sql(view_query)
            if views and len(views) > 0:
                for view in views:
                    section += f"DROP VIEW IF EXISTS {view['table_name']} CASCADE;\n"
                    section += f"CREATE VIEW {view['table_name']} AS\n"
                    section += f"{view['view_definition']};\n\n"
            else:
                section += "-- No views found\n\n"
        except:
            section += "-- Unable to extract views\n\n"
        
        return section
    
    def _generate_functions_schema(self) -> str:
        """Generate CREATE FUNCTION statements."""
        section = """
-- ======================================================
-- FUNCTIONS AND PROCEDURES
-- ======================================================

"""
        
        func_query = """
        SELECT 
            p.proname as function_name,
            pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
        AND NOT p.proisagg
        ORDER BY p.proname;
        """
        
        try:
            functions = self.execute_sql(func_query)
            if functions and len(functions) > 0:
                for func in functions:
                    section += f"-- Function: {func['function_name']}\n"
                    section += f"{func['definition']};\n\n"
            else:
                section += "-- No custom functions found\n\n"
        except:
            section += "-- Unable to extract functions\n\n"
        
        return section
    
    def _generate_policies_schema(self) -> str:
        """Generate RLS policy statements."""
        section = """
-- ======================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ======================================================

"""
        
        policy_query = """
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
        
        try:
            policies = self.execute_sql(policy_query)
            if policies and len(policies) > 0:
                current_table = None
                for policy in policies:
                    if policy['tablename'] != current_table:
                        current_table = policy['tablename']
                        section += f"\n-- Policies for {current_table}\n"
                    
                    section += f"\nCREATE POLICY {policy['policyname']} ON {current_table}\n"
                    section += f"    AS {'PERMISSIVE' if policy['permissive'] else 'RESTRICTIVE'}\n"
                    section += f"    FOR ALL\n"
                    section += f"    TO {policy['roles'] or 'public'}\n"
                    
                    if policy['qual']:
                        section += f"    USING ({policy['qual']})\n"
                    if policy['with_check']:
                        section += f"    WITH CHECK ({policy['with_check']})\n"
                    
                    section += ";\n"
                section += "\n"
            else:
                section += "-- No RLS policies found\n\n"
        except:
            section += "-- Unable to extract RLS policies\n\n"
        
        return section
    
    def _generate_footer(self) -> str:
        """Generate SQL dump footer."""
        return """
-- ======================================================
-- FINALIZATION
-- ======================================================

-- Re-enable foreign key checks
SET session_replication_role = DEFAULT;

-- Set proper permissions (adjust as needed)
-- GRANT USAGE ON SCHEMA public TO authenticated, anon;
-- GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Create or update any required sequences
-- SELECT setval('table_id_seq', (SELECT MAX(id) FROM table));

-- ======================================================
-- END OF SCHEMA DUMP
-- ======================================================
"""


def main():
    """Main execution."""
    
    # Load from .env.local
    from pathlib import Path
    env_file = Path('.env.local')
    
    if not env_file.exists():
        print("✗ .env.local not found")
        return
    
    env_vars = {}
    with open(env_file, 'r') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                env_vars[key] = value.strip('"').strip("'")
    
    supabase_url = env_vars.get('VITE_SUPABASE_URL')
    anon_key = env_vars.get('VITE_SUPABASE_ANON_KEY')
    
    if not supabase_url or not anon_key:
        print("✗ Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY in .env.local")
        return
    
    print(f"\nConnecting to: {supabase_url}")
    print()
    
    extractor = SupabaseSQLExtractor(supabase_url, anon_key)
    
    # Extract schema
    extractor.extract_complete_schema("SUPABASE_COMPLETE_SCHEMA_DUMP.sql")
    
    print()
    print("Next steps:")
    print("1. Review the generated SQL file")
    print("2. To restore on a new database, run: psql -d new_db -f SUPABASE_COMPLETE_SCHEMA_DUMP.sql")
    print()


if __name__ == "__main__":
    main()
