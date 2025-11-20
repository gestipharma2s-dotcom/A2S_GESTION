-- ========================================
-- Script: Confirmer les emails non confirmés
-- ========================================
-- ✅ À exécuter si utilisateurs ont "Email not confirmed"

-- Confirmer TOUS les emails non confirmés
UPDATE auth.users
SET email_confirmed_at = now()
WHERE email_confirmed_at IS NULL;

-- Vérifier le résultat
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at,
  CASE 
    WHEN email_confirmed_at IS NOT NULL THEN '✅ Confirmé'
    ELSE '❌ Non confirmé'
  END as statut
FROM auth.users
ORDER BY created_at DESC;

-- ========================================
-- Alternative: Confirmer UN SEUL email
-- ========================================

-- Remplacer 'admin@a2sgestion.fr' avec votre email
UPDATE auth.users
SET email_confirmed_at = now()
WHERE email = 'admin@a2sgestion.fr' AND email_confirmed_at IS NULL;

-- Vérifier
SELECT 
  id,
  email,
  email_confirmed_at
FROM auth.users
WHERE email = 'admin@a2sgestion.fr';
