-- ========================================
-- 🔐 MIGRER UTILISATEURS EXISTANTS
-- ========================================
-- ⚠️ À exécuter DANS SUPABASE SQL EDITOR
-- 
-- Ce script:
-- 1. Prend tous vos utilisateurs existants dans la table 'users'
-- 2. Les crée dans 'users_auth' avec authentification locale
-- 3. Les lie via auth_id
-- 4. Les mots de passe doivent être définis maintenant!

-- ========================================
-- IMPORTANT: Lire d'abord!
-- ========================================
-- 
-- Vous allez devoir:
-- 1. Changer les mots de passe ci-dessous par vos vrais mots de passe
-- 2. Adapter les emails si nécessaire
-- 3. Exécuter le script
-- 4. Vérifier que les utilisateurs peuvent se connecter
--
-- ATTENTION: Ce script va MODIFIER vos utilisateurs!
-- Faites une sauvegarde avant si possible!

-- ========================================
-- OPTION 1: Migrer un utilisateur spécifique
-- ========================================
-- Remplacer 'ancien-email@exemple.com' et 'MonMotDePasseSecurise123!' 
-- par les vraies valeurs

-- Étape 1: Insérer dans users_auth
INSERT INTO users_auth (id, email, password_hash, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid() as id,
  email,
  crypt('MonMotDePasseSecurise123!', gen_salt('bf', 10)) as password_hash,
  true as is_active,
  NOW() as created_at,
  NOW() as updated_at
FROM users
WHERE email = 'ancien-email@exemple.com'
  AND id NOT IN (SELECT DISTINCT user_id FROM users_auth WHERE user_id IS NOT NULL)
ON CONFLICT (email) DO NOTHING
RETURNING id as new_auth_id, email;

-- Étape 2: Lier l'utilisateur (copier l'id retourné ci-dessus)
UPDATE users
SET auth_id = (SELECT id FROM users_auth WHERE email = 'ancien-email@exemple.com' LIMIT 1)
WHERE email = 'ancien-email@exemple.com'
  AND auth_id IS NULL;

-- ========================================
-- OPTION 2: Migrer TOUS les utilisateurs existants
-- ========================================
-- Attention: Cela va créer des mots de passe temporaires!
-- À faire UNIQUEMENT si vous êtes certain!

-- Créer des mots de passe temporaires pour TOUS les utilisateurs
-- Format: TempPass_XXXX (où XXXX est aléatoire)

WITH user_passwords AS (
  SELECT 
    u.id,
    u.email,
    u.nom,
    'TempPass_' || substr(md5(random()::text), 1, 8) as temp_password
  FROM users u
  WHERE u.auth_id IS NULL  -- Seulement ceux pas encore migrés
)
INSERT INTO users_auth (id, email, password_hash, is_active, created_at, updated_at)
SELECT 
  gen_random_uuid() as id,
  email,
  crypt(temp_password, gen_salt('bf', 10)) as password_hash,
  true as is_active,
  NOW() as created_at,
  NOW() as updated_at
FROM user_passwords
ON CONFLICT (email) DO NOTHING
RETURNING id, email;

-- Mettre à jour les utilisateurs pour les lier à auth
UPDATE users u
SET auth_id = ua.id
FROM users_auth ua
WHERE u.email = ua.email
  AND u.auth_id IS NULL;

-- ========================================
-- ÉTAPE 3: Vérifier la migration
-- ========================================
SELECT 
  u.id,
  u.email,
  u.nom,
  u.role,
  u.auth_id,
  CASE 
    WHEN u.auth_id IS NOT NULL THEN '✅ Migré'
    ELSE '❌ Pas migré'
  END as status,
  ua.is_active,
  ua.created_at
FROM users u
LEFT JOIN users_auth ua ON u.auth_id = ua.id
ORDER BY u.created_at DESC;

-- ========================================
-- ÉTAPE 4: Tester la connexion
-- ========================================
-- Si vous avez utilisé un mot de passe spécifique à l'étape 1:
SELECT * FROM verify_user_password(
  'ancien-email@exemple.com',
  'MonMotDePasseSecurise123!'
);
-- Résultat attendu: is_valid = true

-- Si vous avez utilisé OPTION 2 (mots de passe temporaires):
-- Vous devez les changer dans l'app:
-- 1. Connectez-vous (demander temporaire password)
-- 2. Allez à: Profil → Changer mot de passe
-- 3. Entrez le nouveau mot de passe
-- 4. ✅ C'est bon!

-- ========================================
-- ⚠️ ÉTAPES MANUELLES
-- ========================================
-- 
-- 1. Copier ce script dans SQL Editor
-- 2. Modifier les emails et mots de passe
-- 3. Exécuter
-- 4. Vérifier les résultats
-- 5. Tester la connexion via l'app
-- 6. Demander aux utilisateurs de changer leur mot de passe

-- ========================================
-- 🆘 AIDE
-- ========================================
--
-- Q: "Je ne sais pas quel mot de passe utiliser?"
-- R: Utilisez un mot de passe temporaire, puis demandez aux utilisateurs 
--    de le changer après leur première connexion
--
-- Q: "Je veux des mots de passe différents par utilisateur?"
-- R: Exécutez ce script plusieurs fois, une fois par utilisateur
--    avec des valeurs différentes
--
-- Q: "Ça n'a pas marché?"
-- R: Vérifiez:
--    - L'email existe dans la table users
--    - Vous avez bien remplacé le mot de passe
--    - Il n'y a pas d'erreur SQL (texte rouge)
--
-- Q: "L'utilisateur est toujours pas connecté?"
-- R: 
--    1. Vérifiez que auth_id n'est pas NULL (voir résultat ÉTAPE 3)
--    2. Vérifiez le mot de passe (ÉTAPE 4)
--    3. Déconnectez-vous, reconnectez-vous
--    4. Videz le cache du navigateur (Ctrl+Shift+Delete)

-- ========================================
-- EXEMPLE COMPLET - À adapter
-- ========================================
-- Si vous avez des utilisateurs comme:
-- - admin@a2s.dz
-- - tech@a2s.dz
-- - commercial@a2s.dz
--
-- Exécutez ce code pour chacun:
--
-- INSERT INTO users_auth (id, email, password_hash, is_active, created_at, updated_at)
-- SELECT 
--   gen_random_uuid(),
--   'admin@a2s.dz',
--   crypt('Admin123456!', gen_salt('bf', 10)),
--   true,
--   NOW(),
--   NOW()
-- ON CONFLICT (email) DO NOTHING;
--
-- UPDATE users SET auth_id = (SELECT id FROM users_auth WHERE email = 'admin@a2s.dz' LIMIT 1)
-- WHERE email = 'admin@a2s.dz' AND auth_id IS NULL;
