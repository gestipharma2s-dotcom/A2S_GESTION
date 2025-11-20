-- ========================================
-- 🔧 CRÉER TABLE D'UTILISATEURS LOCAL
-- ========================================
-- ⚠️  À exécuter DANS SUPABASE SQL EDITOR
-- 
-- Cette table stocke les utilisateurs SANS dépendre de Supabase Auth
-- Les mots de passe sont hashés avec bcrypt

-- ========================================
-- ✅ ÉTAPE 1: Créer la table users_auth (authentification locale)
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

-- Créer un index sur email pour les recherches rapides
CREATE INDEX IF NOT EXISTS idx_users_auth_email ON users_auth(email);
CREATE INDEX IF NOT EXISTS idx_users_auth_active ON users_auth(is_active);

-- ========================================
-- ✅ ÉTAPE 2: Lier users_auth à users
-- ========================================

-- Ajouter une colonne auth_id à la table users (si elle n'existe pas)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'auth_id'
  ) THEN
    ALTER TABLE users ADD COLUMN auth_id UUID REFERENCES users_auth(id) ON DELETE CASCADE;
    RAISE NOTICE '✅ Colonne auth_id ajoutée à la table users';
  ELSE
    RAISE NOTICE 'ℹ️  Colonne auth_id existe déjà';
  END IF;
END $$;

-- ========================================
-- ✅ ÉTAPE 3: Fonction pour créer un utilisateur (authentification locale)
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
  email VARCHAR,
  nom VARCHAR,
  role VARCHAR,
  message TEXT
) AS $$
DECLARE
  v_auth_id UUID;
  v_user_id UUID;
  v_password_hash VARCHAR;
BEGIN
  -- Vérifier si l'email existe déjà
  IF EXISTS (SELECT 1 FROM users_auth WHERE users_auth.email = p_email) THEN
    RETURN QUERY SELECT 
      NULL::UUID, 
      p_email::VARCHAR, 
      NULL::VARCHAR,
      NULL::VARCHAR,
      'Email déjà utilisé'::TEXT;
    RETURN;
  END IF;

  -- Créer l'enregistrement d'authentification
  INSERT INTO users_auth (email, password_hash)
  VALUES (p_email, crypt(p_password, gen_salt('bf')))
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
    p_email,
    p_nom,
    LOWER(TRIM(p_role)),
    p_pages_visibles::jsonb,
    v_auth_id
  )
  RETURNING users.id INTO v_user_id;

  -- Retourner le résultat
  RETURN QUERY SELECT 
    v_user_id,
    p_email::VARCHAR,
    p_nom::VARCHAR,
    p_role::VARCHAR,
    'Utilisateur créé avec succès'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- ✅ ÉTAPE 4: Fonction pour vérifier un mot de passe
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
    u.id,
    u.email::TEXT,
    u.nom::TEXT,
    u.role::TEXT,
    (ua.password_hash = crypt(p_password, ua.password_hash))::BOOLEAN as is_valid
  FROM users u
  JOIN users_auth ua ON u.auth_id = ua.id
  WHERE ua.email = p_email AND ua.is_active = TRUE;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- ✅ ÉTAPE 5: Fonction pour mettre à jour le dernier login
-- ========================================

CREATE OR REPLACE FUNCTION update_last_login(p_email TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE users_auth
  SET last_login = NOW()
  WHERE email = p_email;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- ✅ ÉTAPE 6: Exemples - Créer les utilisateurs
-- ========================================

-- Admin
SELECT * FROM create_user_local(
  'admin@a2sgestion.fr',
  'AdminPass123!@#Secure',
  'Admin Principal',
  'admin',
  ARRAY['dashboard', 'prospects', 'clients', 'installations', 'abonnements', 'paiements', 'support', 'alertes', 'applications', 'utilisateurs']
);

-- Technicien
SELECT * FROM create_user_local(
  'tech@a2s.dz',
  'TechPass123!@#',
  'Technicien Support',
  'technicien',
  ARRAY['dashboard', 'installations', 'support', 'alertes']
);

-- Commercial
SELECT * FROM create_user_local(
  'commercial@a2s.dz',
  'CommPass123!@#',
  'Commercial Ventes',
  'commercial',
  ARRAY['dashboard', 'prospects', 'clients', 'paiements']
);

-- ========================================
-- ✅ ÉTAPE 7: Vérifier les utilisateurs créés
-- ========================================

SELECT 
  u.id,
  u.email,
  u.nom,
  u.role,
  ua.is_active,
  ua.last_login,
  ua.created_at
FROM users u
LEFT JOIN users_auth ua ON u.auth_id = ua.id
ORDER BY u.created_at DESC;

-- ========================================
-- ✅ ÉTAPE 8: Tester la vérification de mot de passe
-- ========================================

-- Test 1: Bon mot de passe
SELECT * FROM verify_user_password('admin@a2sgestion.fr', 'AdminPass123!@#Secure');

-- Test 2: Mauvais mot de passe
SELECT * FROM verify_user_password('admin@a2sgestion.fr', 'MauvaisMotDePasse');

-- ========================================
-- ✅ Maintenant les utilisateurs sont créés localement!
-- ========================================
-- Avantages:
-- - Authentification sans dépendre de Supabase Auth
-- - Contrôle total sur les utilisateurs
-- - Pas de rate limit d'authentification
-- - Mots de passe hashés avec bcrypt
-- - Gestion complète depuis l'app
