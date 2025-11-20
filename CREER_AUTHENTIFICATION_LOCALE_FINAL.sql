-- ========================================
-- 🔧 VERSION CORRIGÉE - AUTHENTIFICATION LOCALE
-- ========================================

-- ========================================
-- 🚨 ÉTAPE 0: Activer pgcrypto
-- ========================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ========================================
-- ✅ ÉTAPE 1: Créer la table users_auth
-- ========================================

CREATE TABLE IF NOT EXISTS users_auth (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_users_auth_email ON users_auth(email);
CREATE INDEX IF NOT EXISTS idx_users_auth_active ON users_auth(is_active);

-- ========================================
-- ✅ ÉTAPE 2: Ajouter auth_id à users
-- ========================================

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'auth_id'
  ) THEN
    ALTER TABLE users ADD COLUMN auth_id UUID REFERENCES users_auth(id) ON DELETE CASCADE;
  END IF;
END $$;

-- ========================================
-- ✅ ÉTAPE 3: FONCTION CORRIGÉE - créer utilisateur
-- ========================================

CREATE OR REPLACE FUNCTION create_user_local(
  p_email TEXT,
  p_password TEXT,
  p_nom TEXT,
  p_role TEXT,
  p_pages_visibles TEXT[] DEFAULT ARRAY[]::TEXT[]
)
RETURNS TABLE (
  user_id UUID,
  email TEXT,
  nom TEXT,
  role TEXT,
  message TEXT
) AS $$
DECLARE
  v_auth_id UUID;
  v_user_id UUID;
BEGIN
  -- Vérifier si l'email existe déjà dans users_auth
  IF EXISTS (SELECT 1 FROM users_auth WHERE LOWER(email) = LOWER(p_email)) THEN
    RETURN QUERY SELECT 
      NULL::UUID, 
      p_email::TEXT, 
      NULL::TEXT,
      NULL::TEXT,
      'Email déjà utilisé'::TEXT;
    RETURN;
  END IF;

  -- Créer l'enregistrement d'authentification avec password hashé
  INSERT INTO users_auth (email, password_hash)
  VALUES (LOWER(p_email), crypt(p_password, gen_salt('bf')))
  RETURNING id INTO v_auth_id;

  -- Créer l'utilisateur dans la table users
  INSERT INTO users (
    id,
    email,
    nom,
    role,
    pages_visibles,
    auth_id
  ) VALUES (
    gen_random_uuid(),
    LOWER(p_email),
    p_nom,
    LOWER(TRIM(p_role)),
    CASE 
      WHEN p_pages_visibles IS NOT NULL AND array_length(p_pages_visibles, 1) > 0
      THEN p_pages_visibles::jsonb
      ELSE '[]'::jsonb
    END,
    v_auth_id
  )
  RETURNING users.id INTO v_user_id;

  -- Retourner le résultat
  RETURN QUERY SELECT 
    v_user_id::UUID,
    LOWER(p_email)::TEXT,
    p_nom::TEXT,
    LOWER(TRIM(p_role))::TEXT,
    'Utilisateur créé avec succès'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- ✅ ÉTAPE 4: FONCTION CORRIGÉE - vérifier mot de passe
-- ========================================

CREATE OR REPLACE FUNCTION verify_user_password(
  p_email TEXT,
  p_password TEXT
)
RETURNS TABLE (
  user_id UUID,
  email TEXT,
  nom TEXT,
  role TEXT,
  is_valid BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id::UUID,
    u.email::TEXT,
    u.nom::TEXT,
    u.role::TEXT,
    (ua.password_hash = crypt(p_password, ua.password_hash))::BOOLEAN as is_valid
  FROM users u
  INNER JOIN users_auth ua ON u.auth_id = ua.id
  WHERE LOWER(ua.email) = LOWER(p_email) 
    AND ua.is_active = TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- ✅ ÉTAPE 5: Mettre à jour dernier login
-- ========================================

CREATE OR REPLACE FUNCTION update_last_login(p_email TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE users_auth
  SET last_login = NOW(), updated_at = NOW()
  WHERE LOWER(email) = LOWER(p_email);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- ✅ ÉTAPE 6: Désactiver utilisateur
-- ========================================

CREATE OR REPLACE FUNCTION deactivate_user(p_email TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE users_auth
  SET is_active = FALSE, updated_at = NOW()
  WHERE LOWER(email) = LOWER(p_email);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- TEST: Vérifier que les fonctions existent
-- ========================================

SELECT 
  routine_name,
  routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN ('create_user_local', 'verify_user_password', 'update_last_login', 'deactivate_user')
ORDER BY routine_name;
