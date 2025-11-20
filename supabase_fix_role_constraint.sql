-- ========================================
-- FIX: Vérifier et corriger la contrainte CHECK
-- ========================================
-- ⚠️  À exécuter dans Supabase SQL Editor

-- 1. VÉRIFIER LA CONTRAINTE ACTUELLE
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'users_role_check';

-- 2. VOIR LES RÔLES ACTUELS EN BD
SELECT DISTINCT role FROM users ORDER BY role;

-- 3. SUPPRIMER L'ANCIENNE CONTRAINTE (SI BESOIN)
ALTER TABLE users
DROP CONSTRAINT IF EXISTS users_role_check;

-- 4. AJOUTER LA NOUVELLE CONTRAINTE (CORRECTE)
ALTER TABLE users
ADD CONSTRAINT users_role_check CHECK (
  role IN ('super_admin', 'admin', 'technicien', 'commercial', 'support')
);

-- 5. VÉRIFIER QUE C'EST BON
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'users_role_check';

-- 6. TESTER UNE MISE À JOUR (remplacer l'UUID par le vôtre)
UPDATE users
SET role = 'support'
WHERE id = '6021cb96-d61d-42a4-872a-fa75033657b1';

-- 7. VÉRIFIER LE RÉSULTAT
SELECT id, nom, email, role FROM users WHERE id = '6021cb96-d61d-42a4-872a-fa75033657b1';
