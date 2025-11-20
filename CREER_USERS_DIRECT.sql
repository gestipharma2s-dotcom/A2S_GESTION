-- ========================================
-- 🔐 CRÉER UTILISATEURS - DIRECT (Sans fonction)
-- ========================================
-- ⚠️ À exécuter DANS SUPABASE SQL EDITOR
-- 
-- Ce script insère directement dans les tables users_auth et users
-- Sans dépendre de la fonction create_user_local()

-- ========================================
-- ÉTAPE 1: Créer un ADMIN
-- ========================================
-- 1. Insérer dans users_auth
INSERT INTO users_auth (id, email, password_hash, is_active, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'admin@exemple.com',
  crypt('AdminPass123!', gen_salt('bf', 10)),
  true,
  NOW(),
  NOW()
)
ON CONFLICT (email) DO UPDATE SET password_hash = crypt('AdminPass123!', gen_salt('bf', 10))
RETURNING id;

-- 2. Copier le user_id retourné ci-dessus et l'utiliser ici:
INSERT INTO users (id, email, nom, role, pages_visibles, auth_id, created_at, updated_at)
VALUES (
  (SELECT id FROM users_auth WHERE email = 'admin@exemple.com'),
  'admin@exemple.com',
  'Admin Principal',
  'admin',
  ARRAY['dashboard', 'utilisateurs', 'clients', 'prospects', 'interventions', 'abonnements'],
  (SELECT id FROM users_auth WHERE email = 'admin@exemple.com'),
  NOW(),
  NOW()
)
ON CONFLICT (email) DO NOTHING;

-- ========================================
-- ÉTAPE 2: Créer un TECHNICIEN
-- ========================================
INSERT INTO users_auth (id, email, password_hash, is_active, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'technicien@exemple.com',
  crypt('TechPass123!', gen_salt('bf', 10)),
  true,
  NOW(),
  NOW()
)
ON CONFLICT (email) DO UPDATE SET password_hash = crypt('TechPass123!', gen_salt('bf', 10))
RETURNING id;

INSERT INTO users (id, email, nom, role, pages_visibles, auth_id, created_at, updated_at)
VALUES (
  (SELECT id FROM users_auth WHERE email = 'technicien@exemple.com'),
  'technicien@exemple.com',
  'Technicien Support',
  'technicien',
  ARRAY['interventions', 'installations', 'clients'],
  (SELECT id FROM users_auth WHERE email = 'technicien@exemple.com'),
  NOW(),
  NOW()
)
ON CONFLICT (email) DO NOTHING;

-- ========================================
-- ÉTAPE 3: Créer un COMMERCIAL
-- ========================================
INSERT INTO users_auth (id, email, password_hash, is_active, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'commercial@exemple.com',
  crypt('CommPass123!', gen_salt('bf', 10)),
  true,
  NOW(),
  NOW()
)
ON CONFLICT (email) DO UPDATE SET password_hash = crypt('CommPass123!', gen_salt('bf', 10))
RETURNING id;

INSERT INTO users (id, email, nom, role, pages_visibles, auth_id, created_at, updated_at)
VALUES (
  (SELECT id FROM users_auth WHERE email = 'commercial@exemple.com'),
  'commercial@exemple.com',
  'Commercial Ventes',
  'commercial',
  ARRAY['dashboard', 'prospects', 'clients', 'applications'],
  (SELECT id FROM users_auth WHERE email = 'commercial@exemple.com'),
  NOW(),
  NOW()
)
ON CONFLICT (email) DO NOTHING;

-- ========================================
-- ÉTAPE 4: Créer un SUPER ADMIN
-- ========================================
INSERT INTO users_auth (id, email, password_hash, is_active, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'superadmin@exemple.com',
  crypt('SuperAdminPass123!', gen_salt('bf', 10)),
  true,
  NOW(),
  NOW()
)
ON CONFLICT (email) DO UPDATE SET password_hash = crypt('SuperAdminPass123!', gen_salt('bf', 10))
RETURNING id;

INSERT INTO users (id, email, nom, role, pages_visibles, auth_id, created_at, updated_at)
VALUES (
  (SELECT id FROM users_auth WHERE email = 'superadmin@exemple.com'),
  'superadmin@exemple.com',
  'Super Admin Système',
  'super_admin',
  ARRAY['dashboard', 'utilisateurs', 'clients', 'prospects', 'interventions', 'abonnements', 'applications'],
  (SELECT id FROM users_auth WHERE email = 'superadmin@exemple.com'),
  NOW(),
  NOW()
)
ON CONFLICT (email) DO NOTHING;

-- ========================================
-- ✅ VÉRIFIER LES UTILISATEURS CRÉÉS
-- ========================================
SELECT 
  u.id,
  u.email,
  u.nom,
  u.role,
  u.created_at,
  ua.is_active,
  ua.last_login
FROM users u
LEFT JOIN users_auth ua ON u.auth_id = ua.id
ORDER BY u.created_at DESC;

-- ========================================
-- 🔍 TESTER LA VÉRIFICATION DE MOT DE PASSE
-- ========================================
-- Vérifier admin@exemple.com avec le bon mot de passe
SELECT 
  email,
  crypt('AdminPass123!', password_hash) = password_hash AS password_correct
FROM users_auth
WHERE email = 'admin@exemple.com';
-- Résultat attendu: password_correct = true

-- Vérifier avec un mauvais mot de passe
SELECT 
  email,
  crypt('MauvaisMotDePasse', password_hash) = password_hash AS password_correct
FROM users_auth
WHERE email = 'admin@exemple.com';
-- Résultat attendu: password_correct = false

-- ========================================
-- ⚠️ PERSONNALISER AVEC VOS DONNÉES
-- ========================================
-- À faire:
-- 1. Remplacer les emails par vos emails réels
-- 2. Remplacer les mots de passe par vos mots de passe
-- 3. Ajuster les noms et les pages visibles
-- 4. Lancer le script complet
-- 5. Vérifier les résultats dans la dernière requête
-- 6. Les utilisateurs peuvent maintenant se connecter!

-- ========================================
-- 🎯 TEST DE CONNEXION
-- ========================================
-- Après création, testez:
-- 1. Allez sur l'app
-- 2. Logout (déconnectez-vous)
-- 3. Email: admin@exemple.com
-- 4. Password: AdminPass123!
-- 5. Cliquez Se connecter
-- 6. ✅ Vous devriez être connecté!

-- ========================================
-- RÔLES VALIDES
-- ========================================
-- admin          - Accès complet sauf super_admin
-- super_admin    - Accès complet à tout
-- technicien     - Accès interventions et installations
-- commercial     - Accès prospects et clients

-- ========================================
-- PAGES VALIDES (array)
-- ========================================
-- dashboard
-- utilisateurs
-- clients
-- prospects
-- interventions
-- installations
-- abonnements
-- applications
