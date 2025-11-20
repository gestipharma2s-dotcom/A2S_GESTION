-- ========================================
-- Script: Créer le profil Super Admin
-- ========================================
-- ✅ SCRIPT FONCTIONNEL - À exécuter APRÈS création user en Supabase Console
-- ========================================

-- 📋 PRÉREQUIS:
-- 1. Aller à: Supabase Console → Authentication → Users
-- 2. Cliquer "Add user"
-- 3. Entrer email et password
-- 4. Cliquer "Create user"
-- 5. COPIER L'UUID UTILISATEUR
-- 6. REMPLACER 'YOUR_USER_UUID_HERE' ci-dessous avec cet UUID
-- 7. Exécuter ce script en SQL

-- ========================================
-- Option 1: SI VOUS AVEZ L'UUID
-- ========================================

-- Remplacer 'YOUR_USER_UUID_HERE' avec l'UUID réel
-- Exemple d'UUID: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

INSERT INTO users (
  id,
  nom,
  email,
  role,
  pages_visibles,
  created_at,
  updated_at
)
VALUES (
  'YOUR_USER_UUID_HERE',  -- ← REMPLACER PAR UUID RÉEL
  'Administrateur Super',
  'admin@a2sgestion.fr',
  'super_admin',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb,
  now(),
  now()
)
ON CONFLICT (id) DO UPDATE SET
  nom = 'Administrateur Super',
  email = 'admin@a2sgestion.fr',
  role = 'super_admin',
  pages_visibles = '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb,
  updated_at = now();

-- ========================================
-- Option 2: SI VOUS CONNAISSEZ L'EMAIL
-- ========================================

-- Cette requête cherche l'UUID par email dans auth.users
-- Exécuter APRÈS avoir créé l'utilisateur en Supabase Console

WITH user_found AS (
  SELECT id FROM auth.users 
  WHERE email = 'admin@a2sgestion.fr'
  LIMIT 1
)
INSERT INTO users (
  id,
  nom,
  email,
  role,
  pages_visibles,
  created_at,
  updated_at
)
SELECT
  id,
  'Administrateur Super',
  'admin@a2sgestion.fr',
  'super_admin',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb,
  now(),
  now()
FROM user_found
ON CONFLICT (id) DO UPDATE SET
  nom = 'Administrateur Super',
  email = 'admin@a2sgestion.fr',
  role = 'super_admin',
  pages_visibles = '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb,
  updated_at = now();

-- ========================================
-- VÉRIFICATION
-- ========================================

-- Vérifier le super admin créé
SELECT 
  id,
  nom,
  email,
  role,
  pages_visibles,
  created_at
FROM users
WHERE role = 'super_admin';

-- Vérifier l'utilisateur en auth
SELECT
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users
WHERE email = 'admin@a2sgestion.fr';

-- ========================================
-- 🚀 ÉTAPES DÉTAILLÉES
-- ========================================

-- ÉTAPE 1: Aller à Supabase Console
-- URL: https://app.supabase.com → Votre Projet → Authentication → Users

-- ÉTAPE 2: Cliquer "Add user"

-- ÉTAPE 3: Remplir le formulaire
-- Email: admin@a2sgestion.fr (ou votre email)
-- Password: AdminPass123!@#Secure (ou votre mot de passe)
-- Auto confirm user: OUI ✅

-- ÉTAPE 4: Cliquer "Create user"

-- ÉTAPE 5: Copier l'UUID affiché
-- Vous verrez quelque chose comme:
-- ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890

-- ÉTAPE 6: Venir dans Supabase → SQL Editor

-- ÉTAPE 7: Copier ce script (create_super_admin_working.sql)

-- ÉTAPE 8: Coller et modifier:
-- - Remplacer 'YOUR_USER_UUID_HERE' par l'UUID copié
-- OU
-- - Remplacer 'admin@a2sgestion.fr' par votre email

-- ÉTAPE 9: Exécuter (Run)

-- ÉTAPE 10: Vérifier le résultat
-- Vous devez voir le super admin dans les résultats

-- ========================================
-- ⚠️  NOTES IMPORTANTES
-- ========================================

-- 1. Supabase gère auth.users automatiquement
--    Ne pas essayer d'INSERT directement dans auth.users
--    Utiliser le formulaire Supabase Console

-- 2. L'UUID doit être format valide UUID v4
--    Exemple: a1b2c3d4-e5f6-7890-abcd-ef1234567890

-- 3. La table users est NOTRE table (public.users)
--    Elle synchronise avec auth.users via les IDs

-- 4. pages_visibles est ignoré pour super_admin
--    (accès complet automatiquement)

-- 5. Si vous obtenez "column does not exist"
--    C'est parce que Supabase gère auth.users en interne
--    Utiliser TOUJOURS Supabase Console pour créer des users

-- 6. Le mot de passe doit être changé à la première connexion
--    Supabase vous permet de "Reset password" en Console

-- ========================================
-- 📞 TROUBLESHOOTING
-- ========================================

-- ❌ Erreur: "relation auth.users does not exist"
-- ✅ Solution: Vous devez avoir Supabase Auth activé en Console

-- ❌ Erreur: "column id does not exist"
-- ✅ Solution: Vérifier que la table users existe
--    SELECT * FROM users LIMIT 1;

-- ❌ Erreur: "Conflicting value for key"
-- ✅ Solution: Super admin existe déjà
--    UPDATE users SET role = 'super_admin' WHERE role = 'admin';

-- ❌ Erreur: "Invalid UUID"
-- ✅ Solution: L'UUID n'est pas au bon format
--    Copier exactement depuis Supabase Console

-- ========================================
-- 🎓 EXEMPLE COMPLET
-- ========================================

-- 1. Supabase Console: Créer user
--    Email: admin@example.com
--    Password: SecurePass123!
--    → UUID généré: 550e8400-e29b-41d4-a716-446655440000

-- 2. Venir ici et remplacer:
--    'YOUR_USER_UUID_HERE' 
--    par 
--    '550e8400-e29b-41d4-a716-446655440000'

-- 3. Exécuter le script

-- 4. Résultat:
--    Super admin créé avec cet UUID ✅

-- ========================================
