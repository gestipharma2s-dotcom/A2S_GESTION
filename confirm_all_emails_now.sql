-- ========================================
-- 🔧 CORRIGER: Confirmer tous les emails non confirmés
-- ========================================
-- ⚠️  À exécuter DANS SUPABASE SQL EDITOR (auth schema)
-- Copier ce code et l'exécuter dans: SQL Editor > New Query

-- 1. VÉRIFIER LES EMAILS NON CONFIRMÉS
SELECT id, email, email_confirmed_at, created_at 
FROM auth.users 
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC;

-- 2. CONFIRMER TOUS LES EMAILS NON CONFIRMÉS
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- 3. VÉRIFIER QUE C'EST FAIT
SELECT id, email, email_confirmed_at 
FROM auth.users 
ORDER BY created_at DESC
LIMIT 10;

-- 4. SI VOUS AVEZ UN EMAIL SPÉCIFIQUE À CONFIRMER (remplacer l'email)
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email = 'amine@example.com' AND email_confirmed_at IS NULL;

-- Après exécution: Les utilisateurs devraient pouvoir se connecter!
