-- ========================================
-- 🔧 CONFIGURER LES RLS POUR LES RPC
-- ========================================

-- ========================================
-- ✅ DÉSACTIVER RLS SUR users_auth (la table d'authentification)
-- ========================================

-- D'abord, vérifier si la table existe et a RLS
ALTER TABLE users_auth DISABLE ROW LEVEL SECURITY;

-- Supprimer toutes les politiques existantes si elles existent
DROP POLICY IF EXISTS "Lecture publique users_auth" ON users_auth;
DROP POLICY IF EXISTS "Insertion publique users_auth" ON users_auth;
DROP POLICY IF EXISTS "Modification publique users_auth" ON users_auth;

-- ========================================
-- ✅ ACTIVER LES RLS (avec des politiques permissives pour les RPC)
-- ========================================

ALTER TABLE users_auth ENABLE ROW LEVEL SECURITY;

-- Politique pour les lectures (nécessaire pour verify_user_password)
CREATE POLICY "Allow read for RPC" ON users_auth
  FOR SELECT
  USING (true);

-- Politique pour les insertions (nécessaire pour create_user_local)
CREATE POLICY "Allow insert for RPC" ON users_auth
  FOR INSERT
  WITH CHECK (true);

-- Politique pour les mises à jour (nécessaire pour update_last_login)
CREATE POLICY "Allow update for RPC" ON users_auth
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ========================================
-- ✅ CONFIGURER LES RLS SUR users TABLE
-- ========================================

DROP POLICY IF EXISTS "Lecture publique users" ON users;
DROP POLICY IF EXISTS "Insertion publique users" ON users;
DROP POLICY IF EXISTS "Modification publique users" ON users;

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Politique pour les lectures
CREATE POLICY "Allow read for RPC" ON users
  FOR SELECT
  USING (true);

-- Politique pour les insertions (nécessaire pour create_user_local)
CREATE POLICY "Allow insert for RPC" ON users
  FOR INSERT
  WITH CHECK (true);

-- Politique pour les mises à jour
CREATE POLICY "Allow update for RPC" ON users
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ========================================
-- ✅ VÉRIFICATION: Lister les politiques RLS
-- ========================================

SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('users', 'users_auth')
ORDER BY tablename, policyname;
