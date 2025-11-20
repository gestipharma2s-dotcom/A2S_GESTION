-- ========================================
-- Diagnostic: Vérifier la contrainte CHECK
-- ========================================

-- 1. Voir toutes les contraintes de la table users
SELECT 
  constraint_name,
  constraint_type,
  table_name
FROM information_schema.table_constraints
WHERE table_name = 'users';

-- 2. Voir le détail de la contrainte CHECK
SELECT 
  constraint_name,
  check_clause
FROM information_schema.check_constraints
WHERE constraint_name LIKE '%role%';

-- 3. Voir les valeurs de rôle actuelles en BD
SELECT DISTINCT role FROM users ORDER BY role;

-- 4. Essayer une insertion simple
-- (À adapter selon votre UUID)
INSERT INTO users (id, nom, email, role, pages_visibles, created_at, updated_at)
VALUES (
  'test-uuid-12345678901234567890ab',
  'Test User',
  'test@test.com',
  'support',
  '["support"]'::jsonb,
  now(),
  now()
)
ON CONFLICT (id) DO UPDATE SET
  role = 'support';

-- 5. Vérifier la structure complète de la table
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

-- 6. Voir les types ENUM s'il y en a
SELECT typname, typtype, typcategory
FROM pg_type
WHERE typname LIKE '%role%' OR typname LIKE '%users%';
