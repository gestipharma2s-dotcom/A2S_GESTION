-- ========================================
-- 🔐 CRÉER UTILISATEURS - SIMPLE
-- ========================================
-- ⚠️ À exécuter DANS SUPABASE SQL EDITOR
-- 
-- IMPORTANT: Avant de lancer ce script:
-- 1. Assurez-vous que CREER_AUTHENTIFICATION_LOCALE.sql a été exécuté
-- 2. Sinon la fonction create_user_local() n'existera pas

-- ========================================
-- EXEMPLE 1: Créer un ADMIN
-- ========================================
SELECT create_user_local(
  'admin@exemple.com',           -- Email
  'AdminPass123!',               -- Mot de passe
  'Admin Principal',             -- Nom
  'admin',                       -- Rôle
  ARRAY['dashboard', 'utilisateurs', 'clients', 'prospects', 'interventions', 'abonnements']  -- Pages
);

-- ========================================
-- EXEMPLE 2: Créer un TECHNICIEN
-- ========================================
SELECT create_user_local(
  'technicien@exemple.com',      -- Email
  'TechPass123!',                -- Mot de passe
  'Technicien Support',          -- Nom
  'technicien',                  -- Rôle
  ARRAY['interventions', 'installations', 'clients']  -- Pages
);

-- ========================================
-- EXEMPLE 3: Créer un COMMERCIAL
-- ========================================
SELECT create_user_local(
  'commercial@exemple.com',      -- Email
  'CommPass123!',                -- Mot de passe
  'Commercial Ventes',           -- Nom
  'commercial',                  -- Rôle
  ARRAY['dashboard', 'prospects', 'clients', 'applications']  -- Pages
);

-- ========================================
-- EXEMPLE 4: Créer un SUPER ADMIN
-- ========================================
SELECT create_user_local(
  'superadmin@exemple.com',      -- Email
  'SuperAdminPass123!',          -- Mot de passe
  'Super Admin Système',         -- Nom
  'super_admin',                 -- Rôle
  ARRAY['dashboard', 'utilisateurs', 'clients', 'prospects', 'interventions', 'abonnements', 'applications']  -- Pages
);

-- ========================================
-- ✅ VÉRIFIER LES UTILISATEURS CRÉÉS
-- ========================================
SELECT 
  u.id,
  u.email,
  u.nom,
  u.role,
  u.created_at,
  ua.last_login
FROM users u
LEFT JOIN users_auth ua ON u.auth_id = ua.id
ORDER BY u.created_at DESC;

-- ========================================
-- 🔍 TESTER LA VÉRIFICATION DE MOT DE PASSE
-- ========================================
-- Exemple: Vérifier admin@exemple.com avec le bon mot de passe
SELECT * FROM verify_user_password(
  'admin@exemple.com',
  'AdminPass123!'
);
-- Résultat attendu: is_valid = true

-- Exemple: Vérifier avec un mauvais mot de passe
SELECT * FROM verify_user_password(
  'admin@exemple.com',
  'MauvaisMotDePasse'
);
-- Résultat attendu: is_valid = false, user_id = NULL

-- ========================================
-- ⚠️ MODIFIER LES EXEMPLES AVEC VOS DONNÉES
-- ========================================
-- À faire:
-- 1. Remplacer les emails par vos emails réels
-- 2. Remplacer les mots de passe par vos mots de passe
-- 3. Ajuster les noms et les pages visibles
-- 4. Lancer les requêtes une par une ou tous ensemble
-- 5. Vérifier dans le résultat que is_valid = true
-- 6. Les utilisateurs peuvent maintenant se connecter!

-- ========================================
-- 🎯 UTILISATION VIA L'APP (RECOMMANDÉ)
-- ========================================
-- Au lieu de faire les requêtes SQL manuellement,
-- vous pouvez créer les utilisateurs directement via l'app:
-- 
-- 1. Allez sur: Utilisateurs → Ajouter un utilisateur
-- 2. Remplissez le formulaire
-- 3. Cliquez: Ajouter
-- 4. ✅ L'utilisateur est créé avec authentification locale!

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
