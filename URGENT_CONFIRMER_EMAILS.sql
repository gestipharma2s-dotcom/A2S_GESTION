-- ========================================
-- 🔧 URGENT: Confirmer tous les emails
-- ========================================
-- ⚠️  À exécuter DANS SUPABASE SQL EDITOR
-- 
-- Étapes:
-- 1. Allez à: https://app.supabase.com
-- 2. Cliquez "SQL Editor" (en bas à gauche)
-- 3. Cliquez "New Query"
-- 4. Copiez-collez TOUT le code ci-dessous
-- 5. Cliquez "Run" (Ctrl+Enter)

-- ========================================
-- ✅ ÉTAPE 1: Vérifier les emails non confirmés
-- ========================================
SELECT id, email, email_confirmed_at 
FROM auth.users 
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC;

-- ========================================
-- ✅ ÉTAPE 2: CONFIRMER TOUS LES EMAILS
-- ========================================
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- ========================================
-- ✅ ÉTAPE 3: Vérifier le résultat
-- ========================================
SELECT id, email, email_confirmed_at 
FROM auth.users 
ORDER BY created_at DESC
LIMIT 10;

-- ========================================
-- Après exécution:
-- Les utilisateurs devraient pouvoir se connecter!
-- 
-- Test avec:
-- Email: admin@a2sgestion.fr
-- Password: AdminPass123!@#Secure
-- ========================================
