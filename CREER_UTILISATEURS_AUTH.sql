-- ========================================
-- 🔧 CRÉER UTILISATEURS DANS AUTH
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
-- ✅ CRÉER LES UTILISATEURS DANS AUTH
-- ========================================
-- Cette fonction crée un utilisateur dans auth.users
-- avec un mot de passe hashé correctement

CREATE OR REPLACE FUNCTION create_auth_user(
  p_email TEXT,
  p_password TEXT,
  p_user_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_user_id UUID;
  v_existing_id UUID;
BEGIN
  -- Générer l'UUID s'il n'est pas fourni
  v_user_id := COALESCE(p_user_id, gen_random_uuid());
  
  -- Vérifier si l'utilisateur existe déjà
  SELECT id INTO v_existing_id FROM auth.users WHERE email = p_email LIMIT 1;
  
  IF v_existing_id IS NOT NULL THEN
    -- Mettre à jour le mot de passe si l'utilisateur existe
    UPDATE auth.users 
    SET encrypted_password = crypt(p_password, gen_salt('bf')),
        updated_at = NOW()
    WHERE id = v_existing_id;
    RETURN v_existing_id;
  ELSE
    -- Créer le nouvel utilisateur
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      created_at,
      updated_at,
      raw_app_meta_data,
      raw_user_meta_data,
      is_super_admin,
      role
    ) VALUES (
      v_user_id,
      '00000000-0000-0000-0000-000000000000',
      p_email,
      crypt(p_password, gen_salt('bf')),
      NOW(),
      NOW(),
      NOW(),
      jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
      jsonb_build_object(),
      FALSE,
      'authenticated'
    );
    RETURN v_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- Utilisation: Créer les utilisateurs
-- ========================================
-- À adapter avec VOS utilisateurs réels

-- Exemple 1: Admin
SELECT create_auth_user('admin@a2sgestion.fr', 'AdminPass123!@#Secure');

-- Exemple 2: Technicien
SELECT create_auth_user('tech@a2s.dz', 'TechPass123!@#');

-- Exemple 3: Commercial
SELECT create_auth_user('commercial@a2s.dz', 'CommPass123!@#');

-- ========================================
-- Vérifier les utilisateurs créés
-- ========================================
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;

-- ========================================
-- Confirmer TOUS les emails
-- ========================================
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- ========================================
-- ✅ Maintenant les utilisateurs peuvent se connecter!
-- ========================================
-- Test avec:
-- Email: admin@a2sgestion.fr
-- Mot de passe: AdminPass123!@#Secure
