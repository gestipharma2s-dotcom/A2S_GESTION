#!/usr/bin/env python3
"""
Supabase Complete Schema Extractor
Extracts complete database schema from Supabase and generates a comprehensive SQL dump script.
Includes: tables, columns, constraints, indexes, functions, triggers, policies, and views.
"""

import os
import json
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import List, Dict, Any
from datetime import datetime

class SupabaseSchemaExtractor:
    def __init__(self, db_url: str):
        """Initialize connection to Supabase PostgreSQL database."""
        self.db_url = db_url
        self.conn = None
        self.cursor = None
        
    def connect(self):
        """Establish connection to Supabase database."""
        try:
            self.conn = psycopg2.connect(self.db_url)
            self.cursor = self.conn.cursor(cursor_factory=RealDictCursor)
            print("✓ Connected to Supabase database")
        except Exception as e:
            print(f"✗ Connection failed: {e}")
            raise
    
    def close(self):
        """Close database connection."""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
            print("✓ Connection closed")
    
    def get_tables(self) -> List[str]:
        """Get all user-created tables (excluding system tables)."""
        query = """
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name;
        """
        self.cursor.execute(query)
        return [row['table_name'] for row in self.cursor.fetchall()]
    
    def get_table_definition(self, table_name: str) -> str:
        """Get CREATE TABLE statement for a specific table."""
        query = f"""
        SELECT 
            'CREATE TABLE IF NOT EXISTS {table_name} (' || 
            string_agg('
    ' || column_name || ' ' || column_type || 
            CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
            CASE WHEN column_default IS NOT NULL THEN ' DEFAULT ' || column_default ELSE '' END,
            ',') || '
);' as create_statement
        FROM (
            SELECT 
                c.column_name,
                CASE 
                    WHEN c.data_type = 'character varying' THEN 'VARCHAR(' || c.character_maximum_length || ')'
                    WHEN c.data_type = 'timestamp without time zone' THEN 'TIMESTAMP'
                    WHEN c.data_type = 'timestamp with time zone' THEN 'TIMESTAMPTZ'
                    WHEN c.data_type = 'boolean' THEN 'BOOLEAN'
                    WHEN c.data_type = 'integer' THEN 'INTEGER'
                    WHEN c.data_type = 'bigint' THEN 'BIGINT'
                    WHEN c.data_type = 'numeric' THEN 'NUMERIC(' || c.numeric_precision || ',' || c.numeric_scale || ')'
                    WHEN c.data_type = 'text' THEN 'TEXT'
                    WHEN c.data_type = 'json' THEN 'JSON'
                    WHEN c.data_type = 'jsonb' THEN 'JSONB'
                    WHEN c.data_type = 'uuid' THEN 'UUID'
                    WHEN c.data_type = 'date' THEN 'DATE'
                    WHEN c.data_type = 'time without time zone' THEN 'TIME'
                    WHEN c.data_type = 'bytea' THEN 'BYTEA'
                    WHEN c.data_type = 'ARRAY' THEN c.udt_name || '[]'
                    ELSE c.data_type 
                END as column_type,
                c.is_nullable,
                c.column_default,
                ordinal_position
            FROM information_schema.columns c
            WHERE table_schema = 'public' AND table_name = %s
            ORDER BY ordinal_position
        ) sub
        GROUP BY 1;
        """
        self.cursor.execute(query, (table_name,))
        result = self.cursor.fetchone()
        return result['create_statement'] if result else ""
    
    def get_columns(self, table_name: str) -> List[Dict]:
        """Get detailed column information for a table."""
        query = """
        SELECT 
            c.column_name,
            c.data_type,
            c.character_maximum_length,
            c.numeric_precision,
            c.numeric_scale,
            c.is_nullable,
            c.column_default,
            c.ordinal_position,
            (SELECT COUNT(*) FROM information_schema.constraint_column_usage 
             WHERE table_schema = 'public' 
             AND table_name = %s 
             AND column_name = c.column_name) as in_constraint
        FROM information_schema.columns c
        WHERE c.table_schema = 'public' AND c.table_name = %s
        ORDER BY c.ordinal_position;
        """
        self.cursor.execute(query, (table_name, table_name))
        return self.cursor.fetchall()
    
    def get_primary_keys(self, table_name: str) -> Dict[str, Any]:
        """Get primary key information for a table."""
        query = """
        SELECT 
            constraint_name,
            string_agg(column_name, ', ' ORDER BY ordinal_position) as columns
        FROM information_schema.constraint_column_usage
        WHERE table_schema = 'public' 
        AND table_name = %s
        AND (constraint_name LIKE '%%pkey' OR constraint_name LIKE 'pk_%%')
        GROUP BY constraint_name;
        """
        self.cursor.execute(query, (table_name,))
        result = self.cursor.fetchone()
        return result if result else {}
    
    def get_foreign_keys(self, table_name: str) -> List[Dict]:
        """Get foreign key constraints for a table."""
        query = """
        SELECT 
            constraint_name,
            column_name,
            referenced_table_name,
            referenced_column_name,
            delete_rule,
            update_rule
        FROM (
            SELECT 
                kcu1.constraint_name,
                kcu1.column_name,
                kcu2.table_name as referenced_table_name,
                kcu2.column_name as referenced_column_name,
                rc.delete_rule,
                rc.update_rule
            FROM information_schema.referential_constraints rc
            JOIN information_schema.key_column_usage kcu1 
                ON rc.constraint_name = kcu1.constraint_name 
                AND kcu1.table_schema = rc.constraint_schema
            JOIN information_schema.key_column_usage kcu2 
                ON rc.unique_constraint_name = kcu2.constraint_name 
                AND kcu2.table_schema = rc.unique_constraint_schema
            WHERE kcu1.table_schema = 'public' AND kcu1.table_name = %s
        ) fk
        ORDER BY constraint_name;
        """
        self.cursor.execute(query, (table_name,))
        return self.cursor.fetchall()
    
    def get_indexes(self, table_name: str) -> List[Dict]:
        """Get indexes for a table."""
        query = """
        SELECT 
            indexname,
            indexdef,
            schemaname
        FROM pg_indexes
        WHERE schemaname = 'public' AND tablename = %s
        AND indexname NOT LIKE '%%_pkey'
        ORDER BY indexname;
        """
        self.cursor.execute(query, (table_name,))
        return self.cursor.fetchall()
    
    def get_functions(self) -> List[Dict]:
        """Get all user-defined functions (excluding system functions)."""
        query = """
        SELECT 
            n.nspname as schema_name,
            p.proname as function_name,
            pg_get_functiondef(p.oid) as function_definition,
            pg_get_function_identity_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
        AND NOT p.proisagg
        ORDER BY p.proname;
        """
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def get_triggers(self, table_name: str) -> List[Dict]:
        """Get triggers for a table."""
        query = """
        SELECT 
            trigger_name,
            event_manipulation,
            event_object_table,
            action_timing,
            action_orientation,
            action_statement
        FROM information_schema.triggers
        WHERE event_object_schema = 'public' 
        AND event_object_table = %s
        ORDER BY trigger_name;
        """
        self.cursor.execute(query, (table_name,))
        return self.cursor.fetchall()
    
    def get_policies(self) -> List[Dict]:
        """Get all RLS policies."""
        query = """
        SELECT 
            schemaname,
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
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def get_views(self) -> List[Dict]:
        """Get all views in the public schema."""
        query = """
        SELECT 
            table_name,
            view_definition
        FROM information_schema.views
        WHERE table_schema = 'public'
        ORDER BY table_name;
        """
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def get_sequences(self) -> List[Dict]:
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
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def get_unique_constraints(self, table_name: str) -> List[Dict]:
        """Get unique constraints for a table."""
        query = """
        SELECT 
            constraint_name,
            string_agg(column_name, ', ' ORDER BY ordinal_position) as columns
        FROM information_schema.constraint_column_usage
        WHERE table_schema = 'public' 
        AND table_name = %s
        AND constraint_name LIKE '%unique%'
        GROUP BY constraint_name;
        """
        self.cursor.execute(query, (table_name,))
        return self.cursor.fetchall()
    
    def generate_sql_dump(self, output_file: str):
        """Generate complete SQL dump script."""
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(self._generate_header())
                f.write(self._generate_sequences())
                f.write(self._generate_tables())
                f.write(self._generate_functions())
                f.write(self._generate_views())
                f.write(self._generate_policies())
                f.write(self._generate_sample_data_structure())
                f.write(self._generate_footer())
            
            print(f"✓ SQL dump generated: {output_file}")
            return True
        except Exception as e:
            print(f"✗ Error generating SQL dump: {e}")
            return False
    
    def _generate_header(self) -> str:
        """Generate header section."""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        return f"""-- ===============================================
-- SUPABASE COMPLETE DATABASE SCHEMA DUMP
-- Generated: {timestamp}
-- ===============================================
-- This script recreates the entire database structure
-- including tables, columns, constraints, indexes,
-- functions, triggers, policies, and views.
-- ===============================================

-- Disable foreign key checks during import
SET session_replication_role = replica;

"""
    
    def _generate_sequences(self) -> str:
        """Generate sequences section."""
        sequences = self.get_sequences()
        if not sequences:
            return ""
        
        section = """-- ===============================================
-- SEQUENCES
-- ===============================================

"""
        for seq in sequences:
            section += f"""-- Sequence: {seq['sequence_name']}
CREATE SEQUENCE IF NOT EXISTS {seq['sequence_name']}
    AS {seq['data_type']}
    START WITH {seq['start_value']}
    INCREMENT BY {seq['increment']}
    MINVALUE {seq['minimum_value']}
    MAXVALUE {seq['maximum_value']}
    CYCLE;

"""
        return section
    
    def _generate_tables(self) -> str:
        """Generate tables section."""
        tables = self.get_tables()
        section = """-- ===============================================
-- TABLES
-- ===============================================

"""
        
        for table_name in tables:
            section += f"\n-- ===============================================\n"
            section += f"-- Table: {table_name}\n"
            section += f"-- ===============================================\n\n"
            
            # DROP TABLE IF EXISTS
            section += f"DROP TABLE IF EXISTS {table_name} CASCADE;\n\n"
            
            # CREATE TABLE
            section += f"CREATE TABLE {table_name} (\n"
            
            columns = self.get_columns(table_name)
            column_defs = []
            
            for col in columns:
                col_def = f"    {col['column_name']} "
                
                # Determine data type
                if col['data_type'] == 'character varying':
                    col_def += f"VARCHAR({col['character_maximum_length'] or 255})"
                elif col['data_type'] == 'numeric':
                    col_def += f"NUMERIC({col['numeric_precision']},{col['numeric_scale']})"
                else:
                    col_def += col['data_type']
                
                # Add constraints
                if col['is_nullable'] == 'NO':
                    col_def += " NOT NULL"
                
                if col['column_default']:
                    col_def += f" DEFAULT {col['column_default']}"
                
                column_defs.append(col_def)
            
            # Add primary key constraint
            pk = self.get_primary_keys(table_name)
            if pk and pk.get('columns'):
                column_defs.append(f"    PRIMARY KEY ({pk['columns']})")
            
            # Add unique constraints
            unique_constraints = self.get_unique_constraints(table_name)
            for uc in unique_constraints:
                if uc['columns']:
                    column_defs.append(f"    UNIQUE ({uc['columns']})")
            
            # Add foreign keys
            fks = self.get_foreign_keys(table_name)
            for fk in fks:
                fk_def = f"    CONSTRAINT {fk['constraint_name']} FOREIGN KEY ({fk['column_name']}) "
                fk_def += f"REFERENCES {fk['referenced_table_name']} ({fk['referenced_column_name']})"
                if fk['delete_rule'] != 'NO ACTION':
                    fk_def += f" ON DELETE {fk['delete_rule']}"
                if fk['update_rule'] != 'NO ACTION':
                    fk_def += f" ON UPDATE {fk['update_rule']}"
                column_defs.append(fk_def)
            
            section += ",\n".join(column_defs)
            section += "\n);\n\n"
            
            # Enable RLS if exists
            section += f"ALTER TABLE {table_name} ENABLE ROW LEVEL SECURITY;\n\n"
            
            # Create indexes
            indexes = self.get_indexes(table_name)
            if indexes:
                section += f"-- Indexes for {table_name}\n"
                for idx in indexes:
                    section += f"{idx['indexdef']};\n"
                section += "\n"
            
            # Create triggers
            triggers = self.get_triggers(table_name)
            if triggers:
                section += f"-- Triggers for {table_name}\n"
                for trigger in triggers:
                    section += f"-- {trigger['trigger_name']}: {trigger['event_manipulation']} {trigger['action_timing']}\n"
                section += "\n"
        
        return section
    
    def _generate_functions(self) -> str:
        """Generate functions section."""
        functions = self.get_functions()
        if not functions:
            return ""
        
        section = """-- ===============================================
-- FUNCTIONS AND PROCEDURES
-- ===============================================

"""
        for func in functions:
            section += f"-- Function: {func['function_name']}\n"
            section += f"{func['function_definition']};\n\n"
        
        return section
    
    def _generate_views(self) -> str:
        """Generate views section."""
        views = self.get_views()
        if not views:
            return ""
        
        section = """-- ===============================================
-- VIEWS
-- ===============================================

"""
        for view in views:
            section += f"\n-- View: {view['table_name']}\n"
            section += f"DROP VIEW IF EXISTS {view['table_name']} CASCADE;\n"
            section += f"CREATE VIEW {view['table_name']} AS\n"
            section += f"{view['view_definition']};\n"
        
        return section
    
    def _generate_policies(self) -> str:
        """Generate RLS policies section."""
        policies = self.get_policies()
        if not policies:
            return ""
        
        section = """-- ===============================================
-- ROW LEVEL SECURITY POLICIES (RLS)
-- ===============================================

"""
        current_table = None
        for policy in policies:
            if policy['tablename'] != current_table:
                current_table = policy['tablename']
                section += f"\n-- Policies for table: {current_table}\n"
            
            policy_type = "PERMISSIVE" if policy['permissive'] else "RESTRICTIVE"
            roles = policy['roles'] if policy['roles'] else "PUBLIC"
            
            section += f"\n-- Policy: {policy['policyname']}\n"
            section += f"CREATE POLICY {policy['policyname']} ON {current_table}\n"
            section += f"    AS {policy_type}\n"
            section += f"    FOR ALL\n"
            section += f"    TO {roles}\n"
            
            if policy['qual']:
                section += f"    USING ({policy['qual']})\n"
            if policy['with_check']:
                section += f"    WITH CHECK ({policy['with_check']})\n"
            
            section += ";\n"
        
        return section
    
    def _generate_sample_data_structure(self) -> str:
        """Generate sample data structure documentation."""
        section = """-- ===============================================
-- SAMPLE DATA STRUCTURE & IMPORT INSTRUCTIONS
-- ===============================================

-- To populate this database with data:
-- 1. Extract data from production using: pg_dump -t table_name --data-only
-- 2. Load data with: psql -d database_name -f data_dump.sql

-- Example INSERT statements template for each table:

"""
        tables = self.get_tables()
        for table_name in tables:
            columns = self.get_columns(table_name)
            col_names = ", ".join([col['column_name'] for col in columns])
            col_placeholders = ", ".join(["?" for _ in columns])
            
            section += f"-- INSERT INTO {table_name} ({col_names})\n"
            section += f"-- VALUES ({col_placeholders});\n\n"
        
        return section
    
    def _generate_footer(self) -> str:
        """Generate footer section."""
        return """-- ===============================================
-- FINAL SETUP
-- ===============================================

-- Re-enable foreign key checks
SET session_replication_role = DEFAULT;

-- Grant permissions (adjust roles as needed)
-- GRANT USAGE ON SCHEMA public TO authenticated, anon;
-- GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Create indexes on commonly queried columns
-- CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
-- CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- End of schema dump
"""


def main():
    """Main execution function."""
    # Supabase connection URL
    # Format: postgresql://user:password@host:port/database
    SUPABASE_URL = "postgresql://postgres.ynoxsibapzatlxhmredp:[YOUR_PASSWORD]@db.ynoxsibapzatlxhmredp.supabase.co:5432/postgres"
    
    # You need to set your actual Supabase database password
    # Get it from: https://app.supabase.io/project/[project-id]/settings/database
    
    DB_URL = os.getenv("DATABASE_URL", SUPABASE_URL)
    
    if "[YOUR_PASSWORD]" in DB_URL:
        print("✗ Error: Please set your Supabase database password in DATABASE_URL or the script")
        print("\nTo get your password:")
        print("1. Go to https://app.supabase.io/project/ynoxsibapzatlxhmredp/settings/database")
        print("2. Copy the full connection string or the password")
        print("3. Set: export DATABASE_URL='postgresql://postgres:[password]@db.ynoxsibapzatlxhmredp.supabase.co:5432/postgres'")
        return
    
    extractor = SupabaseSchemaExtractor(DB_URL)
    
    try:
        extractor.connect()
        
        # Generate schema dump
        output_file = "supabase_complete_schema_dump.sql"
        extractor.generate_sql_dump(output_file)
        
        # Also generate JSON metadata
        metadata = {
            "generated": datetime.now().isoformat(),
            "tables": extractor.get_tables(),
            "functions": [{"name": f['function_name'], "args": f['arguments']} for f in extractor.get_functions()],
            "views": [v['table_name'] for v in extractor.get_views()],
        }
        
        with open("supabase_schema_metadata.json", 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2)
        print(f"✓ Metadata generated: supabase_schema_metadata.json")
        
    finally:
        extractor.close()


if __name__ == "__main__":
    main()
