-- ========================================
-- Script: Créer le compte Super Admin
-- ========================================
-- ⚠️  IMPORTANT: 
-- 1. Supabase gère auth.users en interne - pas d'INSERT direct
-- 2. Créer d'abord l'utilisateur via Supabase Console
-- 3. Puis exécuter CE SCRIPT pour créer le profil super_admin
-- 
-- MEILLEURE APPROCHE: Utiliser create_super_admin_simple.sql
-- ========================================

-- 🔑 Configuration
-- Modifier ces valeurs selon votre besoin:
-- Email: admin@a2sgestion.fr
-- Mot de passe: AdminPass123!@#Secure
-- Nom: Administrateur Super

-- ========================================
-- ÉTAPE 1: Créer l'utilisateur en Supabase Auth
-- ========================================

-- Utiliser la fonction Supabase admin.create_user
SELECT
  auth.uid() as current_admin_id,  -- Vérifier qu'on est admin
  now() as script_time;

-- ⚠️  NE PAS UTILISER DIRECTEMENT - Supabase gère auth.users en interne
-- À la place: Utiliser Supabase Console ou create_super_admin_simple.sql

-- ========================================
-- ÉTAPE 2: Récupérer l'ID de l'utilisateur créé
-- ========================================

WITH admin_user AS (
  SELECT id as user_id
  FROM auth.users
  WHERE email = 'admin@a2sgestion.fr'
  LIMIT 1
)

-- ========================================
-- ÉTAPE 3: Créer le profil dans la table users
-- ========================================

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
  user_id,
  'Administrateur Super',
  'admin@a2sgestion.fr',
  'super_admin',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb,
  now(),
  now()
FROM admin_user
ON CONFLICT (id) DO UPDATE SET 
  nom = 'Administrateur Super',
  email = 'admin@a2sgestion.fr',
  role = 'super_admin',
  pages_visibles = '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb,
  updated_at = now();

-- ========================================
-- ÉTAPE 4: Vérification
-- ========================================

-- Vérifier que l'utilisateur a été créé en Auth
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at
FROM auth.users
WHERE email = 'admin@a2sgestion.fr';

-- Vérifier que le profil a été créé en users
SELECT 
  id,
  nom,
  email,
  role,
  pages_visibles,
  created_at
FROM users
WHERE role = 'super_admin';

-- ========================================
-- 📝 INSTRUCTIONS MANUELLES ALTERNATIVE
-- ========================================
-- Si le script SQL ne marche pas, créer manuellement:
--
-- 1. Aller à: Supabase Console → Authentication → Users
-- 2. Cliquer "Add user"
-- 3. Entrer:
--    - Email: admin@a2sgestion.fr
--    - Password: AdminPass123!@#Secure
--    - Auto confirm user: OUI
-- 4. Cliquer "Create user"
-- 5. Copier l'ID utilisateur (UUID)
-- 6. Exécuter en SQL:
--    INSERT INTO users VALUES (
--      '[COLLER_UUID_ICI]',
--      'Administrateur Super',
--      'admin@a2sgestion.fr',
--      'super_admin',
--      '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb
--    );

-- ========================================
-- ⚙️  NOTES IMPORTANTES
-- ========================================
-- 1. pages_visibles est JSONB (JSON Binary)
-- 2. Utiliser syntaxe JSON: ["page1", "page2", ...]
-- 3. Terminer par ::jsonb pour le casting
-- 4. Les pages_visibles pour super_admin sont ignorées (accès complet auto)
-- 5. Email DOIT être confirmé (email_confirmed_at NOT NULL)
-- 6. Utiliser crypt() avec bcrypt pour sécurité mot de passe
-- 7. Le mot de passe 'AdminPass123!@#Secure' DOIT être changé après création
