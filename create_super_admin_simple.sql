-- ============================================
-- Script Simple: Créer le Super Admin
-- ============================================
-- ✅ PLUS FACILE: Créer directement l'utilisateur en Auth ET le profil
-- ⚠️  Doit être exécuté comme ADMIN Supabase

-- ============================================
-- 1. MODIFIER CES VALEURS:
-- ============================================
-- Email: admin@a2sgestion.fr  ← VOTRE EMAIL
-- Mot de passe: AdminPass123!@#Secure  ← VOTRE MOT DE PASSE
-- Nom: Administrateur Super  ← VOTRE NOM

-- ============================================
-- 2. EXÉCUTER CE SCRIPT DANS SUPABASE SQL EDITOR
-- ============================================

-- Créer l'utilisateur en Supabase Auth
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_user_meta_data,
  is_super_admin,
  aud,
  confirmation_token,
  recovery_token
)
SELECT
  gen_random_uuid(),
  '00000000-0000-0000-0000-000000000000',
  'admin@a2sgestion.fr',
  crypt('AdminPass123!@#Secure', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider":"email","providers":["email"]}',
  FALSE,
  'authenticated',
  '',
  ''
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users WHERE email = 'admin@a2sgestion.fr'
)
RETURNING id, email INTO STRICT user_id, user_email;

-- Créer le profil dans la table users avec l'ID qu'on vient de créer
-- (Note: Si l'utilisateur existe déjà, on utilise son ID existant)
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
  COALESCE(
    (SELECT id FROM auth.users WHERE email = 'admin@a2sgestion.fr'),
    gen_random_uuid()
  ),
  'Administrateur Super',
  'admin@a2sgestion.fr',
  'super_admin',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb,
  now(),
  now()
ON CONFLICT (id) DO UPDATE SET
  nom = 'Administrateur Super',
  email = 'admin@a2sgestion.fr',
  role = 'super_admin',
  pages_visibles = '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb,
  updated_at = now();

-- ============================================
-- 3. VÉRIFIER QUE ÇA A FONCTIONNÉ
-- ============================================

SELECT 'Auth user' as check_point, id, email FROM auth.users WHERE email = 'admin@a2sgestion.fr'
UNION ALL
SELECT 'Profile user', id, email FROM users WHERE role = 'super_admin';

-- Résultat attendu: 2 lignes (une en auth, une en users)
